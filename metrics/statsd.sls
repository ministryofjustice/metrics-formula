{% from 'utils/apps/lib.sls' import app_skeleton with context %}
{% from 'metrics/map.jinja' import bucky with context %}

include:
  - .deps
  - python
  - nginx
  - .collectd
  - firewall

#bucky requires collectd types.db
{{ app_skeleton('statsd') }}


/srv/statsd/virtualenv:
  virtualenv.managed:
    - venv_bin: /usr/local/bin/virtualenv
    - system_site_packages: False
    - requirements: salt://metrics/files/statsd/requirements.txt
    - require:
      - pkg: collectd-utils


/srv/statsd/conf:
  file.directory:
    - user: statsd
    - group: statsd
    - require:
      - user: statsd

/srv/statsd/conf/bucky.conf:
  file.managed:
    - template: jinja
    - source: salt://metrics/templates/statsd/bucky.conf
    - user: statsd
    - group: statsd
    - require:
      - file: /srv/statsd/conf
      - user: statsd
    - watch_in:
      - service: statsd

remove_old_supervisor_conf:
  file.absent:
    - name: /etc/supervisor.d/statsd.conf

/etc/init/statsd.conf:
  file.managed:
    - source: salt://metrics/templates/statsd/upstart-statsd.conf
    - template: jinja
    - require:
        - file: /srv/statsd/conf/bucky.conf
    - watch_in:
        - service: statsd

statsd-service:
  service.running:
    - name: statsd
    - enable: True
    - require:
      - user: statsd

{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('statsd-bucky', bucky.port, proto='udp') }}
{{ firewall_enable('statsd-collectd-listener', 25826,proto='udp') }}
