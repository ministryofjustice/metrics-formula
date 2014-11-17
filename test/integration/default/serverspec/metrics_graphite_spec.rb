require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec

set :path, '/sbin:/usr/local/sbin:$PATH'

describe "dependencies" do
  %w(gcc git).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

describe "graphite setup" do
  describe package("python-cairo-dev") do
    it { should be_installed }
  end

  describe group("graphite") do
    it { should exist }
  end

  describe user("graphite") do
    it { should exist }
    it { should belong_to_group "graphite" }
    it { should have_home_directory "/srv/graphite" }
  end

  %w(/srv/graphite/virtualenv/bin/whisper-auto-resize.py
     /srv/graphite/bin/update_whisper_files_if_config_changed).each do |f|
    describe file(f) do
      it {should be_file}
      it {should be_owned_by "root"}
      it {should be_grouped_into "graphite"}
    end
  end

  %w(/srv/graphite/requirements.txt
    /srv/graphite/application/current/graphite/wsgi.py
    /srv/graphite/application/current/graphite/local_settings.py).each do |f|
    describe file(f) do
      it {should be_file}
      it {should be_owned_by "graphite"}
      it {should be_grouped_into "graphite"}
    end
  end

  %w(/srv/graphite/conf
     /srv/graphite/storage
     /srv/graphite/storage/log/webapp
    ).each do |d|
    describe file(d) do
      it { should be_directory }
      it {should be_owned_by "graphite"}
      it {should be_grouped_into "graphite"}
    end
  end

  %w(/etc/init/graphite.conf
     /etc/init/graphite-make-dirs.conf
     /etc/init/carbon.conf).each do |f|
     describe file(f) do
       it {should be_file}
       it {should be_owned_by "root"}
       it {should be_grouped_into "root"}
     end
  end

  %w(graphite carbon).each do |s|
    describe service(s) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe file("/etc/apparmor.d/srv.graphite.bin.carbon-cache.py") do
    it {should be_file}
    it {should be_owned_by "root"}
    it {should be_grouped_into "root"}
  end

  describe file("/etc/nginx/conf.d/graphite.conf") do
    it {should be_file}
    its(:content) { should match /add_header Access-Control-Allow-Origin "\*";/ }
    its(:content) { should match /add_header Access-Control-Allow-Methods "GET, OPTIONS";/ }
    its(:content) { should match /add_header Access-Control-Allow-Headers "origin, authorization, accept";/ }
  end

end
