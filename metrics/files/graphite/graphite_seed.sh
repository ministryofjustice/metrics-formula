#!/bin/bash

${HOME}/virtualenv/bin/python graphite/manage.py syncdb --noinput
${HOME}/virtualenv/bin/python graphite/manage.py loaddata ${HOME}/conf/graphite_seed.json
${HOME}/virtualenv/bin/python graphite/manage.py collectstatic --noinput

touch ${HOME}/.graphite_seed.done
