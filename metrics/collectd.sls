{% from "metrics/map.jinja" import collectd with context %}

collectd:
  pkg:
    - installed
    - version: {{ collectd.revision }}
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
