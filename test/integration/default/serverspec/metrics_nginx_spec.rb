require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec

describe "metrics nginx setup" do

  %w(/etc/nginx/conf.d).each do |d|
    describe file(d) do
      it { should be_directory }
    end
  end

  describe service("nginx") do
    it{ should be_enabled }
    it{ should be_running }
  end

  describe "nginx daemon" do
    it "is listening on port 80" do
      expect(port(80)).to be_listening
    end
  end

end
