require 'spec_helper'

require 'tamashii/manager/channel_pool'
require 'tamashii/manager/channel'
require 'tamashii/manager/client'

RSpec.describe Tamashii::Manager::ChannelPool do
  let(:pool_size) { 10 }
  subject { described_class.new(pool_size) }

  it "default has 10 idle channel" do
    expect(subject.idles.size).to eq(10)
  end

  describe "#ready" do
    it "can add to ready pool when channel has client" do
      channel = subject.idle
      channel.add(double(Tamashii::Manager::Client))
      subject.ready(channel)
      expect(subject.idles.size).not_to be(10)
    end

    it "cannot add empty channel to ready pool" do
      channel = subject.idle
      subject.ready(channel)
      expect(subject.idles.size).to be(10)
    end
  end

  describe "#idle" do
    context "has idle channel" do
      before do
        @client = double(Tamashii::Manager::Client)
        @channel = subject.idle
        @channel.add(@client)
        subject.ready(@channel)
      end

      it "can set empty channel to idle" do
        @channel.delete(@client)
        subject.idle(@channel.id)
        expect(subject.idles.size).to be(10)
      end

      it "cannot set non-empty channel to idle" do
        subject.idle(@channel.id)
        expect(subject.idles.size).not_to be(10)
      end
    end

    it { expect(subject.idle).to be_instance_of(Tamashii::Manager::Channel) }

    context "pool is zero" do
      let(:pool_size) { 0 }
      it { expect(subject.idle).to be nil }
    end
  end

  describe "#available?" do
    it { expect(subject.available?).to be true }

    context "pool size is zero" do
      let(:pool_size) { 0 }
      it { expect(subject.available?).to be false }
    end
  end

  describe "#create!" do
    let(:pool_size) { 0 }
    it "new idle channel" do
      subject.create!
      expect(subject.available?).to be true
    end
  end
end
