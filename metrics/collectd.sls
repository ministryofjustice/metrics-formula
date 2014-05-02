
pkgrepo.managed:
    - ppa: gds/govuk
    - require_in:
      - pkg: collectd
      - pkg: collectd-utils

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
    - source: salt://metrics/templates/collectd/collectd.conf
    - template: jinja
    - watch_in:
      - service: collectd
