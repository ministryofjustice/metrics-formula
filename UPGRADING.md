Upgrading between versions

To v1.6.0
----------

If you change the graphite.data_dir, you must sync over your old data first:

````
sudo stop graphite
sudo stop carbon
sudo rsync -a /srv/graphite/storage/ /data/graphite/
sudo salt-call state.highstate
````
