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

Server
------

Firewall
~~~~~~~~

The monitoring server requires the following ports to be open incoming:

**TCP**

* 2003
* 8215

**UDP**

* 2514
* 2513
  

Dependencies
~~~~~~~~~~~~

The server requires the following states to be included along side this one:

* logstash.server
* sensu.server

Client
------

On the client side (the instances that will ship logs to the monitoring server) we need the following:

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
