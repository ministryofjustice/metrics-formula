=======
metrics
=======

Usage
-----

You shouldn't use this formula directly unless you know what you are doing.  If
you want to set up monitoring on your servers you should look at the monitoring
formula.

Install and configure graphite, collectd, bucky and grafana.

There are two statsd interfaces provided.

Firstly, on each host we install collectd with statsd intefrace exposed (default port 8125).
Keys for metrics reported there will be prefixed with "metric.hostname.type".
So use it only to store host specific metrics.

Secondly, in case you need host independent, aggregated metrics
i.e. you want to report data from application scaled horizontally behind loadbalancer,
than use a central metrics endpoint. It's by default located on host:
`monitoring.local` and port 8126.  This functionality is provided by bucky.


Collectd exposes

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


Dependencies
============

.. note::

   This formula has a dependency on the following salt formulas:

   `firewall <https://github.com/ministryofjustice/firewall-formula>`_

   `nginx <https://github.com/ministryofjustice/nginx-formula>`_

   `utils <https://github.com/ministryofjustice/utils-formula>`_

   `python <https://github.com/ministryofjustice/python-formula>`_

Grafana
=======

This formula includes some Grafana scripted dashboards that should work
well with other tools in this formula:

- overview.js -- overview of all nodes under a graphite 'env' prefix.
- instance.js -- detailed information about a node
- monitoring_health.js -- key information about the monitoring server services

Pillar variables
----------------

- grafana:elasticsearchUrl

  The URL at which the Elasticsearch server can be reached by the client
  browser. The default is to take the current host:port and replaces 'grafana'
  part of the hostname with 'elasticsearch'.

- grafana:graphiteUrl

  The URL of the Graphite server to pull data from. Must be reachable by the
  client browser. The default uses the request host:port and replaces 'grafana'
  with 'graphite'.

- grafana:index

  The name of the Elasticsearch index to save grafana's dashboards in. Default
  of 'grafana-dash'

- grafana:default_route

  Dashboard to show when requesting / (what should appear after the '#' fragment). Can be
  over-ridden on a per client basis with cookies. Default of
  '/dashboard/script/overview.js'


The ``elasticsearchUrl``, ``graphiteUrl`` and ``index`` values are wrapped in double
quotes in the resulting `.js` file which means you can have JS expressions use
at runtime so long as you follow this form in your pillar:

.. code-block:: yaml
    grafana:
      index: 'grafana-dash_" + window.location.hostname + "'

The important bits are: no opening quote, ending in an open double quote (``+
"``), and enclosing in single quotes to keep YAML happy.

apparmor
========

This formula includes some simple default apparmor profiles.

App armor is by default in complain mode which means it allows the action and
logs. To make it deny actions that the profile doesn't cover set the following
pillar::

  apparmor:
    profiles:
      collectd:
        enforce: ''
      carbon_cache:
        enforce: ''
