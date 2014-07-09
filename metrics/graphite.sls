{% from 'supervisor/lib.sls' import supervise with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - .deps
  - python
  - supervisor
  - nginx

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
      - supervisord: supervise-graphite

# pycairo is crazy to build - avoid - so we rely on system-site-packages
# two lines require specific pip arguments


/srv/graphite/application/current/graphite/wsgi.py:
  file:
    - managed
    - source: salt://metrics/files/graphite/graphite.wsgi
    - user: graphite
    - group: graphite
    - watch_in:
      - supervisord: supervise-graphite


/srv/graphite/application/current/graphite/local_settings.py:
  file:
    - managed
    - source: salt://metrics/templates/graphite/local_settings.py
    - template: jinja
    - user: graphite
    - group: graphite
    - watch_in:
      - supervisord: supervise-graphite


/srv/graphite/conf:
  file:
    - recurse
    - source: salt://metrics/files/graphite/conf
    - user: graphite
    - group: graphite
    - watch_in:
      - supervisord: supervise-graphite

/srv/graphite/storage/log/webapp:
  file:
    - directory
    - user: graphite
    - group: graphite
    - makedirs: True
    - require:
      - user: graphite

graphite_seed:
  cmd:
    - script
    - source: salt://metrics/files/graphite/graphite_seed.sh
    - cwd: /srv/graphite/application/current
    - unless: 'test -e /srv/graphite/.graphite_seed.done'
    - user: graphite
    - require:
      - user: graphite
      - file: /srv/graphite/storage/log/webapp
    - watch:
      - cmd: graphite_virtualenv
      - file: /srv/graphite/conf
      - file: /srv/graphite/application/current/graphite/local_settings.py
    - watch_in:
      - supervisord: supervise-graphite


{{ supervise("graphite",
             cmd="/srv/graphite/virtualenv/bin/gunicorn",
             args="graphite.wsgi:application -b unix:///var/run/graphite/graphite.sock",
             numprocs=1,
             working_dir="/srv/graphite/application/current",
             supervise=True) }}

/etc/init/carbon.conf:
  file.managed:
    - source: salt://metrics/files/carbon.conf
    - user: root
    - group: root
    - mode: 644

carbon:
  service:
    - running
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
      server_name: graphite.*
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

#TODO: subsequent executions should not update anything
