{% from "metrics/map.jinja" import grafana with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - nginx
  - logstash.client

# Remove the old git-based version
/srv/grafana/application:
  file.absent
/srv/grafana/.ssh:
  file.absent

/srv/grafana:
  file.directory:
    - recuse: True

grafana-download:
  file.managed:
    - name: /tmp/grafana-{{ grafana.version }}.tar.gz
    - source: http://grafanarel.s3.amazonaws.com/grafana-{{ grafana.version }}.tar.gz
    - source_hash: {{ grafana.src_checksum }}
    - unless: test -d /srv/grafana/grafana-{{ grafana.version }}
    - require:
      - file: /srv/grafana

grafana-extract:
  cmd.wait:
    - name: tar -zxf /tmp/grafana-{{ grafana.version }}.tar.gz -C /srv/grafana
    - require:
      - file: /srv/grafana
    - watch:
      - file: /tmp/grafana-{{ grafana.version }}.tar.gz

/srv/grafana/current:
  file:
    - symlink
    - target: /srv/grafana/grafana-{{ grafana.version }}
    - require:
      - archive: grafana-download

# configure it only if hosted on separate host than elastic search

/srv/grafana/current/config.js:
  file:
    - managed
    - source: salt://metrics/templates/grafana/config.js
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: /srv/grafana/current

/srv/grafana/current/app/dashboards/instance.js:
  file.managed:
    - source: salt://metrics/files/grafana/instance.js
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /srv/grafana/current

/srv/grafana/current/app/dashboards/overview.js:
  file.managed:
    - source: salt://metrics/files/grafana/overview.js
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /srv/grafana/current

/srv/grafana/current/app/dashboards/custom_metrics.js:
  file.managed:
    - source: salt://metrics/files/grafana/custom_metrics.js
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /srv/grafana/current

/srv/grafana/current/app/dashboards/monitoring_health.js:
  file.managed:
    - source: salt://metrics/files/grafana/monitoring_health.js
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /srv/grafana/current

/etc/nginx/conf.d/grafana.conf:
  file:
    - managed
    - source: salt://nginx/templates/vhost-static.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - watch_in:
      - service: nginx
    - context:
      appslug: grafana
      is_default: False
      server_name: {{ grafana.server_name }}
      root_dir: /srv/grafana/current
      index: False
    - watch_in:
      - service: nginx

/etc/apparmor.d/nginx_local/grafana:
  file.managed:
    - source: salt://metrics/templates/grafana/grafana_apparmor_profile
    - template: jinja
    - watch_in:
      - service: nginx
    - require:
      - file: /etc/apparmor.d/nginx_local

{% from 'logstash/lib.sls' import logship with context %}
{{ logship('grafana-access', '/var/log/nginx/grafana.access.json', 'nginx', ['nginx','grafana','access'], 'rawjson') }}
{{ logship('grafana-error',  '/var/log/nginx/grafana.error.log', 'nginx', ['nginx','grafana','error'], 'json') }}
