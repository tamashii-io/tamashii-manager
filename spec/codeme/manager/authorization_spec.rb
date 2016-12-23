require 'spec_helper'

require 'codeme/manager/config'
require 'codeme/manager/client'
require 'codeme/manager/authorization'
require 'codeme/manager/authorizator/token'
require "codeme/manager/errors/authorization_error"

RSpec.describe Codeme::Manager::Authorization do
  let(:client) { double(Codeme::Manager::Client) }
  let(:type) { nil }
  let(:env) { {client: client } }
  let(:data) { nil }
  subject { described_class.new(type, env) }

  it { expect { subject.resolve(data) }.to raise_error(Codeme::Manager::AuthorizationError, /Invalid authorization type/) }

  describe ".authorize!" do
    context "token authorizator" do
      let(:token) { SecureRandom.hex 16 }
      let(:device_id) { SecureRandom.hex 8 }
      let(:type) { Codeme::Type::AUTH_TOKEN }
      let(:data) { "#{device_id},#{token}" }

      it "has valid token" do
        expect(Codeme::Manager::Config).to receive(:token).and_return(token)
        expect(client).to receive(:accept).with(device_id)
        subject.resolve(data)
      end

      it "has invalid token" do
        expect(Codeme::Manager::Config).to receive(:token).and_return(SecureRandom.hex(16))
        expect { subject.resolve(data) }.to raise_error(Codeme::Manager::AuthorizationError, /Token mismatch/)
      end
    end
  end
end
