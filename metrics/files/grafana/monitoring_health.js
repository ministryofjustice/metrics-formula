/* global _ */
/*
 * Grafana Scripted Dashboard to:
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
var arg_i    = 'monitoring-01';

var arg_span = 2;
var arg_from = '2h';

var arg_title = "Monitoring Health";
var arg_refresh = "1m";

var arg_es_env  = 'services';
var arg_es_cluster = "elasticsearch";
var arg_es_node = "monitoring_01";

if(!_.isUndefined(ARGS.env)) {
  arg_env = ARGS.env;
}

if(!_.isUndefined(ARGS.i)) {
  arg_i = ARGS.i;
}

if(!_.isUndefined(ARGS.es_env)) {
  arg_es_env = ARGS.es_env;
}

if(!_.isUndefined(ARGS.from)) {
  arg_from = ARGS.from;
}

if(!_.isUndefined(ARGS.title)) {
  arg_title = ARGS.title;
}

if(!_.isUndefined(ARGS.es_node)) {
  arg_es_node = ARGS.es_node;
}

if(!_.isUndefined(ARGS.es_cluster)) {
  arg_es_cluster = ARGS.es_cluster;
}

if(!_.isUndefined(ARGS.refresh)) {
  arg_refresh = ARGS.refresh;
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
    title: 'Links',
    type: 'text',
    mode: 'markdown',
    span: 4,
    error: false,
    content: "[" + node + " base graphs](/#/dashboard/script/instance.js?env=" + arg_env + "&i=" + node + ")",
    style: {}
  }
};

// Inspired by http://obfuscurity.com/2012/06/Watching-the-Carbon-Feed
function panel_carbon_cache(title){
  return {
    title: title,
    type: 'graphite',
    span: 4,
    renderer: "flot",
    y_formats: ["none", "none"],
    grid: {max: null, min: 0},
    lines: true,
    fill: 2,
    linewidth: 1,
    stack: false,
    legend: {show: true},
    percentage: false,
    nullPointMode: "null",
    tooltip: {
      value_type: "individual",
      query_as_alias: true
    },
    targets: [
      { "target": 'alias(sumSeries(group(carbon.agents.*.updateOperations)),"Updates")' },
      { "target": 'alias(sumSeries(group(carbon.agents.*.metricsReceived)), "Metrics Received")' },
      { "target": 'alias(sumSeries(group(carbon.agents.*.committedPoints)),"Committed Points"))' },
      { "target": 'alias(secondYAxis(sumSeries(group(carbon.agents.*.pointsPerUpdate))),"PPU")' },
      { "target": 'alias(secondYAxis(sumSeries(group(carbon.agents.*.creates))),"Creates")' },
    ],
    aliasColors: {
      "Updates": "blue",
      "Metrics Received": "green",
      "Committed Points": "orange",
      "PPU": "yellow",
      "Creates": "purple"
    },
    aliasYAxis: {
      "PPU": 2,
      "Creates": 2,
    }
  }
};

function panel_elasticsearch_gc(title){
  return {
    title: title,
    type: 'graphite',
    span: 4,
    renderer: "flot",
    y_formats: ["ms", "bytes"],
    grid: {max: null, min: 0},
    lines: true,
    fill: 2,
    linewidth: 1,
    stack: false,
    legend: {show: true},
    percentage: false,
    nullPointMode: "null",
    tooltip: {
      value_type: "individual",
      query_as_alias: true
    },
    targets: [
      { "target": 'alias(nonNegativeDerivative(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.jvm.gc.collectors.young.collection_time_in_millis),"Young GC Collect Time")' },
      { "target": 'alias(nonNegativeDerivative(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.jvm.gc.collectors.old.collection_time_in_millis),"Old GC Collect Time")' },
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.jvm.mem.heap_used_percent,"Heap Used %")' },
    ],
    aliasColors: {
      "Young GC Collect Time": "blue",
      "Old GC Collect Time": "green",
      "Heap Used %": "yellow",
    },
    aliasYAxis: {
      "Heap Used %": 2,
    }
  }
};

function panel_elasticsearch_memory(title){
  return {
    title: title,
    type: 'graphite',
    span: 4,
    renderer: "flot",
    y_formats: ["bytes", "bytes"],
    grid: {max: null, min: 0},
    lines: true,
    fill: 1,
    linewidth: 2,
    stack: false,
    legend: {show: true},
    percentage: false,
    nullPointMode: "null",
    tooltip: {
      value_type: "individual",
      query_as_alias: true
    },
    targets: [
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.indices.percolate.memory_size_in_bytes, "percolate")' },
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.indices.id_cache.memory_size_in_bytes, "id_cache")' },
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.indices.filter_cache.memory_size_in_bytes, "filter_cache")' },
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.indices.fielddata.memory_size_in_bytes, "fielddata")' },
      { "target": 'alias(' + arg_es_env + '.' + arg_es_cluster + '.' + arg_es_node + '.jvm.mem.heap_used_in_bytes, "heap_used")' },
    ],
    aliasColors: {
      "heap_used": "blue",
      "fielddata": "green",
      "percolate": "red",
      "id_cache": "yellow",
      "filter_cache": "purple",
    },
    aliasYAxis: {
      "heap_used": 2,
    }
  }
};

function panel_elasticsearch_segments(title){
  return {
    title: title,
    type: 'graphite',
    span: 4,
    renderer: "flot",
    y_formats: ["bytes", null],
    grid: {max: null, min: 0},
    lines: true,
    fill: 1,
    linewidth: 2,
    stack: false,
    legend: {show: true},
    percentage: false,
    nullPointMode: "null",
    tooltip: {
      value_type: "individual",
      query_as_alias: true
    },
    targets: [
      { "target": 'alias(services.elasticsearch.' + arg_es_node + '.indices.segments.memory_in_bytes, "segments_memory")' },
      { "target": 'alias(services.elasticsearch.' + arg_es_node + '.indices.segments.count, "segments_count")' },
      { "target": 'alias(services.elasticsearch.' + arg_es_node + '.jvm.mem.heap_used_in_bytes, "heap_used")' },
    ],
    aliasColors: {
      "heap_used": "blue",
      "segments_memory": "green",
      "segments_count": "red",
    },
    aliasYAxis: {
      "segments_count": 2,
    }
  }
};


//---------------------------------------------------------------------------------------

function row_graphite_health(title,prefix) {
  return {
    title: title,
    height: '250px',
    collapse: false,
    panels: [
      panel_node_links_markdown(arg_i),
      panel_carbon_cache('Carbon Cache'),
    ]
  }
};

function row_elasticsearch_health(title,prefix) {
  return {
    title: title,
    height: '250px',
    collapse: false,
    panels: [
      panel_elasticsearch_gc('ES GC'),
      panel_elasticsearch_memory('ES Memory'),
    ]
  }
};

function row_elasticsearch_scale(title,prefix) {
  return {
    title: title,
    height: '250px',
    collapse: false,
    panels: [
      panel_elasticsearch_segments('ES Segments'),
    ]
  }
};

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

    dashboard.rows.push(
      row_graphite_health('Graphite Health',prefix),
      row_elasticsearch_health('ES Health',prefix),
      row_elasticsearch_scale('ES Scale',prefix)
    );

    // when dashboard is composed call the callback
    // function and pass the dashboard
    callback(dashboard);
  });
}
