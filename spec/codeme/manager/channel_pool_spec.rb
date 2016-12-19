require 'spec_helper'

require 'codeme/manager/channel_pool'
require 'codeme/manager/channel'
require 'codeme/manager/client'

RSpec.describe Codeme::Manager::ChannelPool do
  let(:pool_size) { 10 }
  subject { described_class.new(pool_size) }

  it "default has 10 idle channel" do
    expect(subject.idle.size).to eq(10)
  end

  describe "#ready" do
    it "can add to ready pool when channel has client" do
      channel = subject.get_idle
      channel.add(double(Codeme::Manager::Client))
      subject.ready(channel)
      expect(subject.idle.size).not_to be(10)
    end

    it "cannot add empty channel to ready pool" do
      channel = subject.get_idle
      subject.ready(channel)
      expect(subject.idle.size).to be(10)
    end
  end

  describe "#idle" do
    before do
      @client = double(Codeme::Manager::Client)
      @channel = subject.get_idle
      @channel.add(@client)
      subject.ready(@channel)
    end

    it "can set empty channel to idle" do
      @channel.delete(@client)
      subject.idle(@channel.id)
      expect(subject.idle.size).to be(10)
    end

    it "cannot set non-empty channel to idle" do
      subject.idle(@channel.id)
      expect(subject.idle.size).not_to be(10)
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

  describe "#get_idle" do
    it { expect(subject.get_idle).to be_instance_of(Codeme::Manager::Channel) }

    context "pool is zero" do
      let(:pool_size) { 0 }
      it { expect(subject.get_idle).to be nil }
    end
  end
end
