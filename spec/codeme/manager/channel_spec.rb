require 'spec_helper'

require 'codeme/manager/channel'
require 'codeme/manager/channel_pool'
require 'codeme/manager/client'

RSpec.describe Codeme::Manager::Channel do
  before :each do
    allow(described_class).to receive(:pool).and_return(Codeme::Manager::ChannelPool.new)
  end

  it "can add new subscriber" do
      client = double(Codeme::Manager::Client, {})
      allow(client).to receive(:tag=).with(1)
      allow(client).to receive(:id).and_return(SecureRandom.hex(8))

      expect(described_class).to receive(:subscribe)

      described_class.subscribe(client)
    end

  context "client is subscribed" do
    before do
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

        expect(channel).to receive(:broadcast).with("PACKET")
        channel.broadcast("PACKET")
      end
    end
  end
end
