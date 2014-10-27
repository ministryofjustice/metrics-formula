# CURRENT

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

