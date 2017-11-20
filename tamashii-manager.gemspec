# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tamashii/manager/version'

Gem::Specification.new do |spec|
  spec.name          = "tamashii-manager"
  spec.version       = Tamashii::Manager::VERSION
  spec.authors       = ["蒼時弦也", "Liang-Chi Tseng", "五倍紅寶石"]
  spec.email         = ["elct9620@frost.tw", "lctseng@cs.nctu.edu.tw", "hi@5xruby.tw"]

  spec.summary       = %q{The IoT device manager for RubyConf checkin system.}
  spec.description   = %q{The IoT device manager for RubyConf checkin system.}
  spec.homepage      = "https://github.com/lctseng/tamashii-manager"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "puma"
  spec.add_runtime_dependency "concurrent-ruby"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "tamashii", ">= 0.4"
  spec.add_runtime_dependency "tamashii-common", ">= 0.2"
  spec.add_runtime_dependency "tamashii-config"
  spec.add_runtime_dependency "websocket-driver"
  spec.add_runtime_dependency "nio4r"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
