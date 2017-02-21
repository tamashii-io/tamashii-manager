require 'spec_helper'

require 'tamashii/manager/config'
require 'tamashii/manager/client'
require 'tamashii/manager/authorization'
require 'tamashii/manager/authorizator/token'
require "tamashii/manager/errors/authorization_error"

RSpec.describe Tamashii::Manager::Authorization do
  let(:client) { double(Tamashii::Manager::Client) }
  let(:type) { nil }
  let(:env) { {client: client } }
  let(:data) { nil }
  subject { described_class.new(type, env) }

  it { expect { subject.resolve(data) }.to raise_error(Tamashii::Manager::AuthorizationError, /Invalid authorization type/) }

  describe ".authorize!" do
    context "token authorizator" do
      let(:token) { SecureRandom.hex 16 }
      let(:device_id) { SecureRandom.hex 8 }
      let(:type) { Tamashii::Type::AUTH_TOKEN }
      let(:data) { "0,#{device_id},#{token}" }

      it "has valid token" do
        expect(Tamashii::Manager::Config).to receive(:token).and_return(token)
        expect(client).to receive(:accept).with(0, device_id)
        subject.resolve(data)
      end

      it "has invalid token" do
        expect(Tamashii::Manager::Config).to receive(:token).and_return(SecureRandom.hex(16))
        expect { subject.resolve(data) }.to raise_error(Tamashii::Manager::AuthorizationError, /Token mismatch/)
      end
    end
  end
end
