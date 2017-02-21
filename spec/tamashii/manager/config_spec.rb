require 'spec_helper'

RSpec.describe Tamashii::Manager::Config do

  describe ".auth_type" do
    it "can be changed" do
      expect(subject.auth_type).to eq(:none)
      subject.auth_type(:token)
      expect(subject.auth_type).to eq(:token)
    end

    it "cannot change to invalid type" do
      origin_auth_type = subject.auth_type
      subject.auth_type(:invalid)
      expect(subject.auth_type).to eq(origin_auth_type)
    end
  end

  describe ".token" do
    it "can be changed" do
      new_token = SecureRandom.hex(16)
      expect(subject.token).to be_nil
      subject.token(new_token)
      expect(subject.token).to eq(new_token)
    end
  end

  describe ".log_file" do
    it "default output to STDOUT" do
      expect(subject.log_file).to eq(STDOUT)
    end
  end

  describe ".log_level" do
    it "default to DEBUG" do
      expect(subject.log_level).to eq(Logger::DEBUG)
    end

    it "can be changed" do
      subject.log_level(Logger::INFO)
      expect(subject.log_level).to eq(Logger::INFO)
    end
  end

  describe ".env" do
    it "default is development" do
      expect(subject.env.development?).to be true
    end

    it "load config from environment variable" do
      expect(ENV).to receive(:[]).with('RACK_ENV').and_return("production")
      expect(subject.env.production?).to be true
    end

    it "can be set by config" do
      subject.env(:production)
      expect(subject.env.production?).to be true
    end

    it "can compare by string" do
      expect(subject.env).to eq("development")
    end

    it "can compare by symbol" do
      expect(subject.env).to eq(:development)
    end
  end

end
