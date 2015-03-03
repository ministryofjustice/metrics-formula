{% from 'metrics/map.jinja' import grafana with context %}
define(['settings'], function(Settings) {

  return new Settings({

      /* Data sources */

      // Graphite & Elasticsearch example setup
      datasources: {
        graphite: {
          type: 'graphite',
          url: "{{ grafana.graphiteUrl }}",
        },
        elasticsearch: {
          type: 'elasticsearch',
          url: "{{ grafana.elasticsearchUrl }}",
          index: "{{ grafana.index }}",
          grafanaDB: true,
        }
      },

      /* Global configuration options
      * ========================================================
      */

      // specify the limit for dashboard search results
      search: {
        max_results: 100
      },

      // default home dashboard
      default_route: "{{ grafana.default_route }}",

      // set to false to disable unsaved changes warning
      unsaved_changes_warning: true,

      // set the default timespan for the playlist feature
      // Example: "1m", "1h"
      playlist_timespan: "1m",

      // Change window title prefix from 'Grafana - <dashboard title>'
      window_title_prefix: 'Grafana - ',

    });
});



