require 'spec_helper'

require 'tamashi/manager/server'
require 'tamashi/manager/client'
require 'tamashi/manager/stream_event_loop'

RSpec.describe Tamashi::Manager::Server do
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

  let(:client) { double(Tamashi::Manager::Client) }
  let(:event_loop) { 
    obj = double(Tamashi::Manager::StreamEventLoop)
    allow(obj).to receive(:timer)
    obj
  }

  before do
    # Prevent start thread
    expect(Tamashi::Manager::StreamEventLoop).to receive(:new).and_return(event_loop)
  end

  it "starts http request" do
    request = Rack::MockRequest.env_for("/")
    response = subject.call(request)
    expect(response).to be_instance_of(Array)
  end

  it "starts websocket request" do
    request = Rack::MockRequest.env_for("/", env)
    expect(Tamashi::Manager::Client).to receive(:new).with(request, event_loop).and_return(client)
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
