require 'spec_helper'

require 'codeme/manager/channel'
require 'codeme/manager/channel_pool'
require 'codeme/manager/client'

RSpec.describe Codeme::Manager::Channel do

  let(:client) { double(Codeme::Manager::Client) }
  let(:channel) { Codeme::Manager::Channel.new(1) }

  it "initialize default pool" do
    expect(described_class.pool).to be_instance_of(Codeme::Manager::ChannelPool)
  end

  describe ".subscribe" do
    it "can add new subscriber" do
      allow(client).to receive(:tag=).with(1)
      allow(client).to receive(:id).and_return(SecureRandom.hex(8))

      expect(described_class).to receive(:subscribe)

      described_class.subscribe(client)
    end
  end

  describe ".unsubscribe" do
    it "can remove subscriber" do
      pool = Codeme::Manager::ChannelPool.new(0)
      pool[1] = channel

      expect(client).to receive(:tag).and_return(1)
      expect(client).to receive(:id).and_return(SecureRandom.hex(8))
      expect(described_class).to receive(:pool).and_return(pool).at_least(:once)

      described_class.unsubscribe(client)
    end
  end

  context "client is subscribed" do
    before do
      expect(described_class).to receive(:pool).and_return(Codeme::Manager::ChannelPool.new).at_least(:once)

      @client = double(Codeme::Manager::Client, {})
      allow(@client).to receive(:tag=).with(1)
      allow(@client).to receive(:tag).and_return(1)
      allow(@client).to receive(:id).and_return(SecureRandom.hex(8))

      described_class.subscribe(@client)
    end

    it "can unsubscribe client" do
      expect(described_class).to receive(:unsubscribe).with(@client)
      described_class.unsubscribe(@client)
    end

    it "can get active channel" do
      channel = described_class.get(@client.tag)
      expect(channel).not_to be_nil
    end

    describe "#broadcast" do
      it "can broadcast to all clients" do
        allow(@client).to receive(:send).with("PACKET")
        channel = described_class.get(@client.tag)

        channel.broadcast("PACKET")
      end
    end
  end

end
