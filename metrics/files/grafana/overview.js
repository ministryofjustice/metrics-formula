/* global _ */
/*
 * Grafana Scripted Dashboard to:
 *  * Give overview of all nodes in a cluster: CPU, Load, Memory
 *  * Provide links to other - more complex - dashboard for each node.
 *
 * Global accessable variables
 * window, document, $, jQuery, ARGS, moment
 *
 * Return a dashboard object, or a function
 *
 * For async scripts, return a function, this function must take a single callback function,
 * call this function with the dasboard object
 *
 * Author: Mike Pountney, Infracode Ltd
 *
 * Heavily inspired by work of: Anatoliy Dobrosynets, Recorded Future, Inc.
 *
 */

// accessable variables in this scope
var window, document, ARGS, $, jQuery, moment, kbn;

// use defaults for URL arguments
var arg_env  = 'metrics';
var arg_span = 2;
var arg_from = '2h';
var arg_nodes = '';

var arg_title = "Overview";
var arg_refresh = "1m";

if(!_.isUndefined(ARGS.env)) {
  arg_env = ARGS.env;
}

if(!_.isUndefined(ARGS.from)) {
  arg_from = ARGS.from;
}

if(!_.isUndefined(ARGS.title)) {
  arg_title = ARGS.title;
}

if(!_.isUndefined(ARGS.refresh)) {
  arg_refresh = ARGS.refresh;
}

if(!_.isUndefined(ARGS.nodes)) {
  arg_nodes = ARGS.nodes;
}

// execute graphite-api /metrics/find query
// return array of metric last names ( func('test.cpu-*') returns ['cpu-0','cpu-1',..] )
function find_filter_values(query){
  var search_url = window.location.protocol + '//' + window.location.hostname.replace(/^grafana/,"graphite") + (window.location.port ? ":" + window.location.port : "") + '/metrics/find/?query=' + query;
  var res = [];
  var req = new XMLHttpRequest();
  req.open('GET', search_url, false);
  req.send(null);
  var obj = JSON.parse(req.responseText);
  for(var key in obj) {
    if (obj[key].hasOwnProperty("text")) {
      res.push(obj[key]["text"]);
    }
  }
  return res;
};

// used to calculate aliasByNode index in panel template
function len(prefix){
  return prefix.split('.').length - 1;
};

//---------------------------------------------------------------------------------------

function panel_node_links_markdown(node) {
  return {
    title: node,
    type: 'text',
    mode: 'markdown',
    span: 2,
    error: false,
    content: "[base graphs](/#/dashboard/script/instance.js?env=" + arg_env + "&i=" + node + ")",
    style: {}
  }
};

function panel_collectd_delta_cpu(title,prefix,node){
  return {
    title: title,
    type: 'graphite',
    span: 2,
    renderer: "flot",
    y_formats: ["none"],
    grid: {max: null, min: 0},
    lines: true,
    fill: 2,
    linewidth: 1,
    stack: true,
    legend: {show: false},
    percentage: true,
    nullPointMode: "null",
    tooltip: {
      value_type: "individual",
      query_as_alias: true
    },
    targets: [
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.interrupt),'1min'),'intrpt')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.softirq),'1min'),'irq')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.steal),'1min'),'steal')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.wait),'1min'),'wait')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.system),'1min'),'system')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.user),'1min'),'user')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.nice),'1min'),'nice')" },
      { "target": "alias(movingMedian(sumSeries(" + prefix + "." + node + ".cpu.*.cpu.idle),'1min'),'idle')" },
    ],
    aliasColors: {
      "user": "#508642",
      "nice": "#609652",
      "system": "#EAB839",
      "wait": "#890F02",
      "steal": "#E24D42",
      "idle": "#6ED0E0"
    }
  }
};

function panel_collectd_loadavg(title, prefix, node) {
  var idx = len(prefix);
  return {
    title: title,
    type: 'graphite',
    span: 2,
    y_formats: ["none"],
    grid: {max: null, min: 0},
    lines: true,
    legend: {show: false},
    fill: 2,
    linewidth: 1,
    nullPointMode: "null",
    targets: [
      { "target": "alias(countSeries(" + prefix + "." + node + ".cpu.*.*.idle),'cpuCount')" },
      { "target": "aliasByNode(movingMedian(" + prefix + "." + node + ".load.load.midterm,'10min')," +(idx+4)+ ")" },
    ],
    aliasColors: {
      "cpuCount": "green",
      "midterm": "red"
    }
  }
};

function panel_collectd_memory(title, prefix, node) {
  var idx = len(prefix);
  return {
    title: title,
    type: 'graphite',
    span: 3,
    y_formats: ["bytes"],
    grid: {max: null, min: 0},
    lines: true,
    legend: {show: false},
    fill: 2,
    linewidth: 1,
    stack: true,
    nullPointMode: "null",
    targets: [
      { "target": "aliasByNode(" + prefix + "." + node + ".memory.memory.{used,cached,buffered,free}, " +(idx+4)+ ")" },
    ],
    aliasColors: {
      "free": "#629E51",
      "used": "#1F78C1",
      "cached": "#EF843C",
      "buffered": "#CCA300"
    }
  }
};

function panel_collectd_logstash_event_types(title, prefix, node) {
  var idx = len(prefix);
  return {
    title: title,
    type: 'graphite',
    span: 3,
    y_formats: ["none"],
    grid: {max: null, min: 0},
    lines: true,
    legend: {show: true},
    fill: 2,
    linewidth: 1,
    stack: true,
    nullPointMode: "null",
    targets: [
      { "target": "aliasByNode(movingMedian(" + prefix + ".monitoring-01.statsd.derive.logstash.per-host." + node + ".*.events.type.*,'1min')," +(idx+10)+ ")" },
    ],
    aliasColors: {
      "nginx": "#629E51",
      "audit": "#EF843C",
      "syslog": "#1F78C1",
      "sensu": "#CCA300"
    }
  }
};

function row_of_node_panels(node,prefix) {
  return {
    title: node,
    height: '150px',
    collapse: false,
    panels: [
      panel_node_links_markdown(node),
      panel_collectd_delta_cpu("CPU",prefix,node),
      panel_collectd_loadavg("Load",prefix,node),
      panel_collectd_memory("Memory",prefix,node),
      panel_collectd_logstash_event_types("Events",prefix,node)
    ]
  }
}

//---------------------------------------------------------------------------------------


return function(callback) {

  // Setup some variables
  var dashboard;
  var prefix = arg_env

  // Intialize a skeleton with nothing but a rows array and service object
  dashboard = {
    rows : [],
    services : {}
  };

  // set filter
  var dashboard_filter = {
    time: {
      from: "now-" + arg_from,
      to: "now"
    },
  };

  // define pulldowns
  pulldowns = [
    {
      type: "filtering",
      collapse: false,
      notice: false,
      enable: true
    },
    {
      type: "annotations",
      enable: false
    }
  ];

  dashboard.title = arg_title;
  dashboard.refresh = arg_refresh;
  dashboard.editable = true;
  dashboard.pulldowns = pulldowns;
  dashboard.services.filter = dashboard_filter;

  // custom dashboard rows (appended to the default dashboard rows)
  var optional_rows = [];

  $.ajax({
    method: 'GET',
    url: '/'
  })
  .done(function(result) {

    display_nodes = arg_nodes.split(',')
    if ( display_nodes.length == 0 ) {
      display_nodes = find_filter_values(prefix + ".*")
    }
    for (var i in display_nodes) {
      dashboard.rows.push(row_of_node_panels(node_list[i], prefix));
    }

    // when dashboard is composed call the callback
    // function and pass the dashboard
    callback(dashboard);
  });
}
