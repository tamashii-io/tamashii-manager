require 'spec_helper'

require 'tamashi/manager/channel'
require 'tamashi/manager/channel_pool'
require 'tamashi/manager/client'

RSpec.describe Tamashi::Manager::Channel do

  let(:client) { double(Tamashi::Manager::Client) }
  let(:channel) { Tamashi::Manager::Channel.new(1) }

  it "initialize default pool" do
    expect(described_class.pool).to be_instance_of(Tamashi::Manager::ChannelPool)
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
      pool = Tamashi::Manager::ChannelPool.new(0)
      pool[1] = channel

      expect(client).to receive(:tag).and_return(1).at_least(:once)
      expect(client).to receive(:id).and_return(SecureRandom.hex(8))
      expect(client).to receive(:type).and_return(:agent)
      expect(described_class).to receive(:pool).and_return(pool).at_least(:once)

      described_class.unsubscribe(client)
    end
  end

  context "client is subscribed" do
    before do
      expect(described_class).to receive(:pool).and_return(Tamashi::Manager::ChannelPool.new).at_least(:once)

      @client = double(Tamashi::Manager::Client, {})
      allow(@client).to receive(:tag=).with(1)
      allow(@client).to receive(:tag).and_return(1)
      allow(@client).to receive(:type).and_return(:agent)
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

    context "with two channel" do
      before do
        @client2 = double(Tamashi::Manager::Client, {})
        allow(@client2).to receive(:tag=).with(2)
        allow(@client2).to receive(:tag).and_return(2)
        allow(@client2).to receive(:type).and_return(:agent)
        allow(@client2).to receive(:id).and_return(SecureRandom.hex(8))

        described_class.subscribe(@client2)
      end

      describe "#send_to" do
        it "can send to another channel" do
          allow(@client2).to receive(:send).with("PACKET")
          channel = described_class.get(@client.tag)

          channel.send_to(@client2.tag, "PACKET")
        end
      end

      describe "#broadcast_all" do
        it "can send to all channels" do
          allow(@client).to receive(:send).with("PACKET")
          allow(@client2).to receive(:send).with("PACKET")
          channel = described_class.get(@client.tag)

          channel.broadcast_all("PACKET")
        end
      end
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
