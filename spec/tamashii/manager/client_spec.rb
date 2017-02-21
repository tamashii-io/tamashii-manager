require 'spec_helper'

require 'tamashii/common'
require 'tamashii/manager/stream_event_loop'
require 'tamashii/manager/client'
require 'tamashii/manager/channel'

RSpec.describe Tamashii::Manager::Client do
  let :env do
    {
      "REQUEST_METHOD"             => "GET",
      "HTTP_CONNECTION"            => "Upgrade",
      "HTTP_UPGRADE"               => "websocket",
      "HTTP_ORIGIN"                => "http://www.example.com",
      "HTTP_SEC_WEBSOCKET_KEY"     => key,
      "HTTP_SEC_WEBSOCKET_VERSION" => "13",
      "rack.hijack"                => proc {},
      "rack.hijack_io"             => tcp_socket,
    }
  end

  let(:request) { Rack::MockRequest.env_for("/", env) }
  let(:tcp_socket) { double(TCPSocket) }
  let(:event_loop) { double(Tamashii::Manager::StreamEventLoop) }
  let(:key) { "2vBVWg4Qyk3ZoM/5d3QD9Q==" }

  subject { described_class.new(request, event_loop) }

  before do
    allow(event_loop).to receive(:attach)

    allow(tcp_socket).to receive(:write) { |message| @bytes = message.bytes.to_a }
  end


  context "authorized" do
    let(:token) { SecureRandom.hex(16) }
    let(:device_id) { SecureRandom.hex(8) }

    before do
      allow(Tamashii::Manager::Config).to receive(:token).and_return(token)
      subject.parse(tamashii_binary_packet(Tamashii::Type::AUTH_TOKEN, 0, "0,#{device_id},#{token}").pack('C*'))
    end

    describe "#id" do
      it { expect(subject.id).to eq(device_id) }
    end

    describe "#authorized?" do
      it { expect(subject.authorized?).to be true }
    end

    it "should broadcast message to channel" do
      channel = Tamashii::Manager::Channel.get(subject.tag)
      expect(channel).to receive(:broadcast)
      subject.parse(tamashii_binary_packet(0, 0, "").pack('C*'))
    end
  end

  context "not authorized" do

    it "run resolver to authorization" do
      expect(Tamashii::Resolver).to receive(:resolve)
      subject.parse(tamashii_binary_packet(0, 0, "").pack('C*'))
    end

    describe "#id" do
      it { expect(subject.id).to match(/Unauthorized/) }
    end

    describe "#authorized?" do
      it { expect(subject.authorized?).to be false }
    end
  end

  describe "#write" do
    it do
      buffer = tamashii_binary_packet(0, 0, "")
      subject.write(buffer.pack('C*'))
      expect(@bytes).to eq(buffer)
    end
  end

  describe "#send" do
    it do
      buffer = Tamashii::Packet.new(0, 0, "").dump
      subject.send(buffer)
      expect(@bytes[2..-1]).to eq(buffer)
    end
  end

  describe "#parse" do
    it do
      expect(subject).to receive(:receive)
      subject.parse(tamashii_binary_packet(0, 0, "").pack('C*'))
    end
  end
end