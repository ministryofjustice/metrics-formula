Upgrading between versions

To v2.x.0
---------

If you have specifed a custom grafana:index pillar key remove the quotes from
around it in the pillar.

Old style:

```yaml
grafana:
  index: '"grafana-dash"'
```

New style:

```yaml
grafana:
  index: 'grafana-dash'
```

To v1.6.0
----------

If you change the graphite.data_dir, you must sync over your old data first:

````
sudo stop graphite
sudo stop carbon
sudo rsync -a /srv/graphite/storage/ /data/graphite/
sudo salt-call state.highstate
````
