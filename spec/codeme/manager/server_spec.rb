require 'spec_helper'

require 'codeme/manager/server'
require 'codeme/manager/client'
require 'codeme/manager/stream'

RSpec.describe Codeme::Manager::Server do
  let :env do
    {
      "REQUEST_METHOD"             => "GET",
      "HTTP_CONNECTION"            => "Upgrade",
      "HTTP_UPGRADE"               => "websocket",
      "HTTP_ORIGIN"                => "http://www.example.com",
      "HTTP_SEC_WEBSOCKET_KEY"     => "JFBCWHksyIpXV+6Wlq/9pw==",
      "HTTP_SEC_WEBSOCKET_VERSION" => "13",
    }
  end

  before do
    # Prevent start thread
    expect(Codeme::Manager::Stream).to receive(:run).and_return(nil)
  end

  it "starts http request" do
    request = Rack::MockRequest.env_for("/")
    response = subject.call(request)
    expect(response).to be_instance_of(Array)
  end

  it "starts websocket request" do
    request = Rack::MockRequest.env_for("/", env)
    expect(Codeme::Manager::Client).to receive(:new).with(request).and_return(double(Codeme::Manager::Client))
    subject.call(request)
  end

  it "only create one instance" do
    request = Rack::MockRequest.env_for("/")
    described_class.call(request)
    instance = described_class.instance
    described_class.call(request)
    expect(described_class.instance).to eq(instance)
  end
end
