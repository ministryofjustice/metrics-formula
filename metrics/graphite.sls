{% from 'metrics/map.jinja' import graphite with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - .deps
  - python
  - nginx
  - firewall

# graphite had issues with graph rendering with memcache on
#  - memcached


{{ app_skeleton('graphite') }}

python-cairo-dev:
  pkg:
    - installed


/srv/graphite/requirements.txt:
  file:
    - managed
    - source: salt://metrics/files/graphite/requirements.txt
    - user: graphite
    - group: graphite


graphite_virtualenv:
  cmd:
    - script
    - source: salt://metrics/files/graphite/requirements.sh
    - unless: 'test -e /srv/graphite/.graphite_virtualenv.done'
    - user: graphite
    - require:
      - file: /srv/graphite/requirements.txt
    - require_in:
      - service: graphite-service

/srv/graphite/virtualenv/bin/whisper-auto-resize.py:
  file:
    - managed
    - source: salt://metrics/files/graphite/contrib/whisper-auto-resize.py
    - user: root
    - group: graphite
    - mode: 0755
    - require:
      - cmd: graphite_virtualenv

/srv/graphite/bin/update_whisper_files_if_config_changed:
  file:
    - managed
    - source: salt://metrics/files/graphite/contrib/update_whisper_files_if_config_changed
    - user: root
    - group: graphite
    - mode: 0755

# pycairo is crazy to build - avoid - so we rely on system-site-packages
# two lines require specific pip arguments


/srv/graphite/application/current/graphite/wsgi.py:
  file:
    - managed
    - source: salt://metrics/files/graphite/graphite.wsgi
    - user: graphite
    - group: graphite
    - watch_in:
      - service: graphite-service


/srv/graphite/application/current/graphite/local_settings.py:
  file:
    - managed
    - source: salt://metrics/templates/graphite/local_settings.py
    - template: jinja
    - user: graphite
    - group: graphite
    - watch_in:
      - service: graphite-service


/srv/graphite/conf:
  file:
    - recurse
    - source: salt://metrics/files/graphite/conf
    - user: graphite
    - group: graphite
    - watch_in:
      - service: graphite-service
      - service: carbon

{{ graphite.data_dir }}:
  file:
    - directory
    - user: graphite
    - group: graphite
    - require:
      - user: graphite

{{ graphite.data_dir }}/log/webapp:
  file:
    - directory
    - user: graphite
    - group: graphite
    - makedirs: True
    - require:
      - user: graphite
      - file: {{ graphite.data_dir }}

graphite_seed:
  cmd:
    - script
    - source: salt://metrics/files/graphite/graphite_seed.sh
    - cwd: /srv/graphite/application/current
    - unless: 'test -e /srv/graphite/.graphite_seed.done -a -f {{ graphite.data_dir }}/graphite.db'
    - user: graphite
    - require:
      - user: graphite
      - file: {{ graphite.data_dir }}/log/webapp
    - watch:
      - cmd: graphite_virtualenv
      - file: /srv/graphite/conf
      - file: /srv/graphite/application/current/graphite/local_settings.py
    - watch_in:
      - service: graphite-service

/etc/init/graphite.conf:
  file.managed:
    - source: salt://metrics/files/graphite/graphite.conf
    - user: root
    - group: root
    - mode: 644

/etc/init/graphite-make-dirs.conf:
  file.managed:
    - source: salt://metrics/files/graphite/graphite-make-dirs.conf
    - user: root
    - group: root
    - mode: 644

/etc/init/carbon.conf:
  file.managed:
    - source: salt://metrics/files/graphite/carbon.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /srv/graphite/bin/update_whisper_files_if_config_changed

graphite-service:
  service.running:
    - name: graphite
    - enable: True
    - require:
      - file: /etc/init/graphite.conf
      - service: carbon

carbon:
  service.running:
    - enable: True
    - require:
      - file: /etc/init/carbon.conf

/etc/apparmor.d/srv.graphite.bin.carbon-cache.py:
  file.managed:
    - source: salt://metrics/templates/graphite/carbon_apparmor_profile
    - template: jinja
    - watch_in:
      - service: carbon

/etc/nginx/conf.d/graphite.conf:
  file:
    - managed
    - source: salt://nginx/templates/vhost-unixproxy.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      unix_socket: /var/run/graphite/graphite.sock
      appslug: graphite
      server_name: {{ graphite.server_name }}
      is_default: False
      root_dir: /srv/graphite/data/webapp
      headers:
       add_header Access-Control-Allow-Origin "*";
       add_header Access-Control-Allow-Methods "GET, OPTIONS";
       add_header Access-Control-Allow-Headers "origin, authorization, accept";
    - watch_in:
      - service: nginx

/etc/apparmor.d/nginx_local/graphite:
  file.managed:
    - source: salt://metrics/templates/graphite/graphite_apparmor_profile
    - template: jinja
    - watch_in:
      - service: nginx
    - require:
      - file: /etc/apparmor.d/nginx_local

{% from 'firewall/lib.sls' import firewall_enable with context %}
{{ firewall_enable('graphite-tcp', 2003, proto='tcp') }}
{{ firewall_enable('graphite-udp', 2003, proto='udp') }}
{{ firewall_enable('graphite-pickle', 2004, proto='tcp') }}
{{ firewall_enable('graphite-cache', 7002, proto='tcp') }}
