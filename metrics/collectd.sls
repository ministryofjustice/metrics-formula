{% from "metrics/map.jinja" import collectd with context %}

include:
  - apparmor


collectd:
  pkg.installed:
    - watch_in:
      - service: collectd
    - skip_verify: True
  service:
    - running
    - enable: True


collectd-utils:
  pkg.installed


/etc/collectd/collectd.conf:
  file.managed:
    - source: salt://metrics/templates/collectd/collectd.conf
    - template: jinja
    - watch_in:
      - service: collectd


/etc/apparmor.d/usr.sbin.collectd:
  file.managed:
    - source: salt://metrics/templates/collectd_apparmor_profile
    - template: jinja
    - watch_in:
      - service: collectd
