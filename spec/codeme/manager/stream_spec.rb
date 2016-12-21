require 'spec_helper'

require 'codeme/manager/stream_event_loop'
require 'codeme/manager/stream'
require 'codeme/manager/client'

RSpec.describe Codeme::Manager::Stream do

  let(:event_loop) { double(Codeme::Manager::StreamEventLoop) }
  let(:client) { double(Codeme::Manager::Client) }
  let(:tcp_socket) { double(TCPSocket) }

  subject { described_class.new(event_loop, tcp_socket, client) }

  before do
    allow(event_loop).to receive(:attach)
  end

  describe "#receive" do
    it do

      expect(client).to receive(:parse).with(anything())
      subject.receive([])
    end
  end

  describe "#close" do
    it do
      #expect(client).to receive(:close)
      #subject.close
    end
  end

end
