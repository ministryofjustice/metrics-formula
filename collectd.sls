collectd:
  pkg:
    - installed
  service:
    - running
    - enable: True

collectd-utils:
  pkg:
    - installed


/etc/collectd/collectd.conf:
  file:
    - managed
    - source: salt://statistics/templates/collectd/collectd.conf
    - template: jinja
    - watch_in:
      - service: collectd
