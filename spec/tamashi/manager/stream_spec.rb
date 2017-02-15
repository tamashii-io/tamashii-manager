require 'spec_helper'

require 'tamashi/manager/stream_event_loop'
require 'tamashi/manager/stream'
require 'tamashi/manager/client'

RSpec.describe Tamashi::Manager::Stream do

  let(:event_loop) { double(Tamashi::Manager::StreamEventLoop) }
  let(:client) { double(Tamashi::Manager::Client) }
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
