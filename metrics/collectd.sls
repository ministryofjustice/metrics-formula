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

# The logic below is pretty warped but it seems like the only way
# for salt to treat a managed directory as idempotent to ensure
# that changes in state are not incorrectly generated.

collectd-confd-clean:
  file.directory:
    - name: /etc/collectd/collectd.conf.d
    - mode: 755
    - clean: True
    - require:
      - file: collectd-confd-dir
      - pkg: collectd

collectd-confd-dir:
  file.directory:
    - name: /etc/collectd/collectd.conf.d
    - mode: 755
    - require:
      - pkg: collectd


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
