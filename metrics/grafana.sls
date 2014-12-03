{% from "logstash/map.jinja" import kibana with context %}
{% from "metrics/map.jinja" import grafana with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - nginx
  - logstash.client

{{ app_skeleton('grafana') }}


grafana.git:
  git:
    - latest
    - name: https://github.com/grafana/grafana.git
    - rev: {{ grafana.revision }}
    - target: /srv/grafana/application/{{ grafana.revision }}


/srv/grafana/application/current:
  file:
    - symlink
    - target: /srv/grafana/application/{{ grafana.revision }}
    - makedirs: True
    - watch:
      - git: grafana.git


# configure it only if hosted on separate host than elastic search

/srv/grafana/application/current/src/config.js:
  file:
    - managed
    - source: salt://metrics/templates/grafana/config.js
    - user: root
    - group: root
    - mode: 644 
    - template: jinja
    - require:
      - file: /srv/grafana/application/current

/srv/grafana/application/current/src/app/dashboards/instance.js:
  file.managed:
    - source: salt://metrics/files/grafana/instance.js
    - user: root
    - group: root
    - mode: 755 
    - require:
      - file: /srv/grafana/application/current

/srv/grafana/application/current/src/app/dashboards/overview.js:
  file.managed:
    - source: salt://metrics/files/grafana/overview.js
    - user: root
    - group: root
    - mode: 755 
    - require:
      - file: /srv/grafana/application/current

/srv/grafana/application/current/src/app/dashboards/monitoring_health.js:
  file.managed:
    - source: salt://metrics/files/grafana/monitoring_health.js
    - user: root
    - group: root
    - mode: 755 
    - require:
      - file: /srv/grafana/application/current

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
      server_name: 'grafana.*'
      root_dir: /srv/grafana/application/current/src
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
