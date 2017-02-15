require "spec_helper"

require "tamashi/common"
require "tamashi/manager/config"

describe Tamashi::Manager do
  it "has a version number" do
    expect(Tamashi::Manager::VERSION).not_to be nil
  end

  it "can get config" do
    expect(Tamashi::Manager.config).to be(Tamashi::Manager::Config)
  end

  it "can get logger" do
    expect(Tamashi::Manager.logger).to be_instance_of(Tamashi::Logger)
  end
end
