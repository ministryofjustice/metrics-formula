{% from "metrics/map.jinja" import collectd with context %}

include:
  - apparmor

collectd-core:
  pkg.installed:
    - version: {{ collectd.revision }}
    - watch_in:
      - service: collectd

collectd:
  pkg.installed:
    - version: {{ collectd.revision }}
    - watch_in:
      - service: collectd
  service:
    - running
    - enable: True

collectd-utils:
  pkg:
    - installed

/etc/collectd/collectd.conf:
  file:
    - managed
    - source: salt://metrics/templates/collectd/collectd.conf
    - template: jinja
    - watch_in:
      - service: collectd

/etc/apparmor.d/usr.sbin.collectd:
  file.managed:
    - source: salt://metrics/files/collectd_apparmor_profile
    - template: 'jinja'
    - watch_in:
      - command: reload-profiles
      - service: collectd