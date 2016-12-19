require 'spec_helper'

RSpec.describe Codeme::Manager::Config do

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

    it "cannot be changed after defined" do
      log_file = Tempfile.new
      subject.log_file(log_file)
      expect(subject.log_file).not_to eq(log_file)
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

end
