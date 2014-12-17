require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:$PATH'

describe "bucky statsd setup" do
  %w(/srv/statsd/conf).each do |d|
    describe file(d) do
      it { should be_directory }
    end
  end

  describe file("/srv/statsd/conf/bucky.conf") do
    it { should be_file }
    it {should be_owned_by "statsd"}
    it {should be_grouped_into "statsd"}
  end

  describe file("/etc/init/statsd.conf") do
    it { should be_file }
    it {should be_owned_by "root"}
    it {should be_grouped_into "root"}
  end

  describe service("statsd") do
    it{ should be_enabled }
    it{ should be_running }
  end

end
