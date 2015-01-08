require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec

set :path, '/sbin:/usr/local/sbin:$PATH'

describe "grafana setup" do

  grafana_revision = "v1.5.3"
  grafana_path = "/srv/grafana/application"

  describe group("grafana") do
    it { should exist }
  end
  
  describe user("grafana") do
    it { should exist }
    it { should belong_to_group "grafana" }
    it { should have_home_directory "/srv/grafana" }
  end

  describe file("#{grafana_path}/#{grafana_revision}") do
    it { should be_directory }
  end

  describe file("#{grafana_path}/current") do
    it { should be_linked_to "#{grafana_path}/#{grafana_revision}" }
  end

  describe file("/srv/grafana/application/current/src/config.js") do
    it { should be_file}
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

  describe file("/etc/apparmor.d/nginx_local/grafana") do
    it {should be_file}
    it {should be_owned_by "root"}
    it {should be_grouped_into "root"}
  end

  describe file("/etc/nginx/conf.d/grafana.conf") do
    it { should be_file }
    its(:content) { should match /server_name  grafana\.\*;/ }
    its(:content) { should match /root \/srv\/grafana\/application\/current\/src;/ }
  end

  describe file("/srv/grafana/application/current/src/app/dashboards/overview.js") do
    it { should be_file}
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

  describe file("/srv/grafana/application/current/src/app/dashboards/monitoring_health.js") do
    it { should be_file}
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

  describe file("/srv/grafana/application/current/src/app/dashboards/instance.js") do
    it { should be_file}
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

end
