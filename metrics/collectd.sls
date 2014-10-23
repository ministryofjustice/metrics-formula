{% from "metrics/map.jinja" import collectd with context %}

include:
  - apparmor

collectd-core:
  pkg.installed:
{% if collectd.revision %}
    - version: {{ collectd.revision }}
{% endif %}
    - watch_in:
      - service: collectd

collectd:
  pkg.installed:
{% if collectd.revision %}
    - version: {{ collectd.revision }}
{% endif %}
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

/etc/collectd/collectd.conf.d:
  file.directory:
    - mode: 755
    - clean: True

# hangover from PPA collectd, we dont use
/etc/collectd/filters.conf:
  file.absent

# hangover from PPA collectd, we dont use
/etc/collectd/thresholds.conf:
  file.absent

/etc/apparmor.d/usr.sbin.collectd:
  file.managed:
    - source: salt://metrics/templates/collectd_apparmor_profile
    - template: jinja
    - watch_in:
      - service: collectd
