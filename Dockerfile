FROM ubuntu:14.04
ADD /metrics /srv/salt-formulas/metrics
ADD /vendor/_root/ /srv/salt-formulas/metrics
ADD /thin.tgz /tmp/
RUN apt-get update && apt-get install -y python-dev python-apt
RUN cd /tmp && python salt-call --local state.sls metrics.server
EXPOSE 80
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
