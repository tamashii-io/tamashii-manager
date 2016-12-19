require 'spec_helper'

RSpec.describe Codeme::Manager::Logger do

  LOGGER_FORMAT = /\[[0-9\-\:\s]+\]\s(INFO|DEBUG|WARN|ERROR|FATAL)\t:(.+?)\n/

  subject { Codeme::Manager::Logger }

  it "has alias method" do
    expect(subject).to receive(:info).with("Hello World")
    subject.info("Hello World")
  end

  it "print formatted message" do
    log_file = Tempfile.new
    logger = subject.new(log_file.path)
    logger.info("Hello World")
    expect(log_file.read).to match(LOGGER_FORMAT)
    log_file.close
  end

  it "has default schema" do
    logger = subject.new(Tempfile.new)
    expect(logger.schema).to eq(subject::Colors::SCHEMA[STDOUT])
  end
end
