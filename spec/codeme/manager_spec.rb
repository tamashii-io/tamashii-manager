require "spec_helper"

require "codeme/manager/config"
require "codeme/manager/logger"

describe Codeme::Manager do
  it "has a version number" do
    expect(Codeme::Manager::VERSION).not_to be nil
  end

  it "can get config" do
    expect(Codeme::Manager.config).to be(Codeme::Manager::Config)
  end

  it "can get logger" do
    expect(Codeme::Manager.logger).to be_instance_of(Codeme::Manager::Logger)
  end
end
