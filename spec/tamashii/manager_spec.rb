require "spec_helper"

require "tamashii/common"
require "tamashii/manager/config"

describe Tamashii::Manager do
  it "has a version number" do
    expect(Tamashii::Manager::VERSION).not_to be nil
  end

  it "can get config" do
    expect(Tamashii::Manager.config).to be(Tamashii::Manager::Config)
  end
end
