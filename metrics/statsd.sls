{% from 'supervisor/lib.sls' import supervise with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}
{% from 'metrics/map.jinja' import bucky with context %}

include:
  - .deps
  - python
  - supervisor
  - nginx
  - .collectd
  - firewall

#bucky requires collectd types.db
{{ app_skeleton('statsd') }}


/srv/statsd/virtualenv:
  virtualenv:
    - managed
    - venv_bin: /usr/local/bin/virtualenv
    - system_site_packages: False
    - requirements: salt://metrics/files/statsd/requirements.txt
    - require:
      - pkg: collectd-utils


/srv/statsd/conf:
  file:
    - directory
    - user: statsd
    - group: statsd
  require:
    - user: statsd


/srv/statsd/conf/bucky.conf:
  file:
    - managed
    - template: jinja
    - source: salt://metrics/templates/statsd/bucky.conf
    - require:
      - file: /srv/statsd/conf
    - watch_in:
      - service: supervisord


{{ supervise('statsd',
             cmd="/srv/statsd/virtualenv/bin/bucky",
             args="/srv/statsd/conf/bucky.conf",
             numprocs=1,
             supervise=True) }}

{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('statsd-bucky', bucky.port, proto='udp') }}
{{ firewall_enable('statsd-collectd-listener', 25826,proto='udp') }}
