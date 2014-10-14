{% from 'metrics/map.jinja' import graphite with context %}

include:
  - python
  - nginx


graphite:
  pkg.installed:
    - pkgs:
        - dsd-python-gunicorn
        - graphite-web
        - graphite-carbon
    - skip_verify: True


graphite-data:
  file.directory:
    - name: {{graphite.data}}/whisper
    - user: _graphite
    - group: _graphite
    - makedirs: True
    - require:
      - pkg: graphite


/usr/bin/whisper-auto-resize.py:
  file:
    - managed
    - source: salt://metrics/files/graphite/contrib/whisper-auto-resize.py
    - user: root
    - group: _graphite
    - mode: 0755
    - require:
      - pkg: graphite


/usr/bin/update_whisper_files_if_config_changed:
  file:
    - managed
    - source: salt://metrics/files/graphite/contrib/update_whisper_files_if_config_changed
    - user: root
    - group: _graphite
    - mode: 0755
    - require:
      - pkg: graphite


/etc/graphite/local_settings.py:
  file:
    - managed
    - source: salt://metrics/templates/graphite/local_settings.py
    - template: jinja
    - user: _graphite
    - group: _graphite
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


/usr/share/graphite-web/wsgi.py:
  file.symlink:
    - target: /usr/share/graphite-web/graphite.wsgi.py
    - force: True


graphite-service:
  service.running:
    - name: graphite
    - enable: True
    - require:
      - file: /etc/init/graphite.conf
      - file: /usr/share/graphite-web/wsgi.py
      - service: carbon-cache


/etc/carbon:
  file.recurse:
    - source: salt://metrics/templates/graphite/carbon
    - template: jinja
    - user: _graphite
    - group: _graphite
    - watch_in:
      - service: graphite-service
      - service: carbon-cache


/etc/default/graphite-carbon:
  file.managed:
    - source: salt://metrics/files/graphite/graphite-carbon
    - require:
        - pkg: graphite
    - watch_in:
      - service: carbon-cache


carbon-cache:
  service.running:
    - enable: True
    - require:
        - pkg: graphite


/etc/apparmor.d/srv.graphite.bin.carbon-cache.py:
  file.managed:
    - source: salt://metrics/templates/graphite/carbon_apparmor_profile
    - template: jinja
    - watch_in:
      - service: carbon-cache


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
      root_dir: /usr/share/graphite-web
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
