require 'spec_helper'

require 'tamashi/manager/config'
require 'tamashi/manager/client'
require 'tamashi/manager/authorization'
require 'tamashi/manager/authorizator/token'
require "tamashi/manager/errors/authorization_error"

RSpec.describe Tamashi::Manager::Authorization do
  let(:client) { double(Tamashi::Manager::Client) }
  let(:type) { nil }
  let(:env) { {client: client } }
  let(:data) { nil }
  subject { described_class.new(type, env) }

  it { expect { subject.resolve(data) }.to raise_error(Tamashi::Manager::AuthorizationError, /Invalid authorization type/) }

  describe ".authorize!" do
    context "token authorizator" do
      let(:token) { SecureRandom.hex 16 }
      let(:device_id) { SecureRandom.hex 8 }
      let(:type) { Tamashi::Type::AUTH_TOKEN }
      let(:data) { "0,#{device_id},#{token}" }

      it "has valid token" do
        expect(Tamashi::Manager::Config).to receive(:token).and_return(token)
        expect(client).to receive(:accept).with(0, device_id)
        subject.resolve(data)
      end

      it "has invalid token" do
        expect(Tamashi::Manager::Config).to receive(:token).and_return(SecureRandom.hex(16))
        expect { subject.resolve(data) }.to raise_error(Tamashi::Manager::AuthorizationError, /Token mismatch/)
      end
    end
  end
end
