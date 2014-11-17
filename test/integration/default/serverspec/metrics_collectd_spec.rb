require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:$PATH'

describe "collectd setup" do

  collectd_revision = "5.4.0-ppa1~precise1"

  %w(collectd collectd-core).each do |pkg|
    describe package(pkg) do
      it { should be_installed.with_version(collectd_revision) }
    end
  end

  describe package("collectd-utils") do
    it { should be_installed }
  end

  describe file("/etc/collectd/collectd.conf") do
    it { should be_file }
  end

  %w(/etc/collectd/collectd.conf.d
     /etc/collectd/collectd.conf.d).each do |d|
    describe file(d) do
      it { should be_directory }
    end
  end

  describe file("/etc/apparmor.d/usr.sbin.collectd") do
    it { should be_file }
  end

  describe service("collectd") do
    it{ should be_enabled }
    it{ should be_running }
  end

end
