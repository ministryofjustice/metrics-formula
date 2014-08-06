=======
metrics
=======

Install and configure graphite, collectd and statsd (via bucky) and grafana

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

Usage
=====

.. image:: https://raw.githubusercontent.com/ministryofjustice/metrics-formula/OMGDOCS/docs/monitoring-server.png


Server
------

Firewall
~~~~~~~~

The monitoring server requires the following ports to be open incoming from the clients:


* 2003
* 2513
* 5762
* 6379
* 80
  

Dependencies
~~~~~~~~~~~~

The server requires the following states to be included:

* metrics.server
* logstash.server
* sensu.server



Client
------

On the client side (the instances that will ship logs to the monitoring server) we need the following:

Dependencies
~~~~~~~~~~~~

The server requires the following states to be included along side this one:

* metrics.client
* logstash.client
* sensu.client


Hosts File
~~~~~~~~~

  [internal IP of monitoring server] monitoring.local graphite.local



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
