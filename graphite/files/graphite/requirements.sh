#!/bin/bash

cd ${HOME}
virtualenv --system-site-packages virtualenv
source virtualenv/bin/activate
pip install -r ${HOME}/requirements.txt
pip install carbon       --install-option="--prefix=/srv/graphite" --install-option="--install-lib=/srv/graphite/virtualenv/lib/python2.7" --install-option="--install-data=/srv/graphite/data"
pip install graphite-web --install-option="--prefix=/srv/graphite" --install-option="--install-lib=/srv/graphite/application/current"      --install-option="--install-data=/srv/graphite/data"

#TODO: consider configuring graphite & carbon to store persistent data in /data

touch ${HOME}/.graphite_virtualenv.done
