# Version 2.0.2

* Add an ability to set `server_name` for the nginx virtual host for
  both the Graphite and Grafana via a pillar. The default value is
  set via `map.jinja`.

# Version 2.0.1

* Fix a syntax error in the instance.js dashboard.

# Version 2.0.0

* Change quoting requirements on grafana:index pillar value to make it match
  the style of grafana:elasticsearchUrl and grafana:graphiteUrl (**BREAKING
  CHANGE**)
* Upgrade Grafana to 1.9.1.
* Change how we install Grafana to use release tarballs, not git checkouts as
  they are no longer complete

# Version 1.11.1

* remove supervisor dependency
* custom_metric.js dashboard, for displaying arbitrary graphite targets

# Version 1.10.1

* help text on overview.js grafana dashboard
* omit graphs feature for overview.js grafana dashboard
* fix NTP display in overview.js grafana dashboard

# Version 1.10.0

* Add 'Segments' and 'Size' graphs to the monitoring_health.js dashboard

# Version 1.9.0

* Add NTP graph to Grafana overview.js scripted dashboard
* Switch to using Bucky statsd metrics for events in overview.js dashboard
* Add ptrace to trusty kernel collectd apparmor profile

# Version 1.8.0

* statsd is now supervised by upstart
* kitchen-salt now points to its official repo
* added tests for statsd bucky

# Version 1.7.1

* Hotfix - to solve statsd.sls order

# Version 1.7.0

* Prevent collectd from buffering metrics when graphite is not accessible
* Install bucky on monitoring server and bind it to port 8126

# Version 1.6.0

* Allow specification of graphite.data_dir (default /srv/graphite/storage)
* Include grafana scripted dashboards: overview.js, instance.js, monitoring_health.js

# Version 1.5.1

* Fix to allow collectd.prefix on 14.04 and non-12.04 Ubuntu.

# Version 1.5.0

* Allow collectd graphite prefix to be set via collectd.prefix
* Allow the Grafana dashboard prefix to be set, as per above.

# Version 1.4.2

* BUG: Ensure firewall
* Include and cleanly manage the collectd.conf.d dir
* Removed unused filters.conf and thresholds.conf files

# Version 1.4.1

* Support deployment to Ubuntu 14.04.

# Version 1.4.0

* Ask statsd plugin to create derived metrics for timers `*-count`,
  `*-percentile-50`, `*-percentile-95`, and upper and lower bounds.
* Enable ntp plugin to collect metrics about the clock

## Version 1.3.0

* Increase & synchronise resolution of graphite and collectd
* Automatically resize whisper databases on carbon restart, if necessary.
* Fix for carbon start bug introduced by database resize

## Version 1.2.2

* Add extra upstart job to correctly create run dirs for graphite at startup

## Version 1.2.1

* Graphite converted to upstart

## Version 1.2.0

* Added apparmor profiles

## Version 1.1.0

* Added tcpconns plugin to collectd

## Version 1.0.7

* Sensible hostname defaults

## Version 1.0.6

* Set timezones to UTC in Grafana and Graphite

## Version 1.0.5

* Set StoreRates to true in collectd.conf to ensure counters (especially cpu) do not keep incrementing
* Remove unused rrdtool plugin

## Version 1.0.4

* Ensure collectd-core is upgraded with collectd if necessary

## Version 1.0.3

* Fixed error in grafana template

## Version 1.0.2

* Added Grafana to server definition
* Pinned collectd package to 5.4.0 to ensure existing servers take upgrade

## Version 1.0.1

* Update to collectd 5.4.0
* Replaced central bucky statsd listener with per server collectd statsd-plugin instance
* Send metrics directly to graphite
* Default the graphite server to monitoring.local instead of localhost

## Version 1.0.0

* Initial checkin

