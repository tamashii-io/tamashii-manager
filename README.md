Tamashii Manager [![Gem Version](https://badge.fury.io/rb/tamashii-manager.svg)](https://badge.fury.io/rb/tamashii-manager) [![Build Status](https://travis-ci.org/tamashii-io/tamashii-manager.svg?branch=master)](https://travis-ci.org/tamashii-io/tamashii-manager) [![Test Coverage](https://codeclimate.com/github/tamashii-io/tamashii-manager/badges/coverage.svg)](https://codeclimate.com/github/tamashii-io/tamashii-manager/coverage) [![Code Climate](https://codeclimate.com/github/tamashii-io/tamashii-manager/badges/gpa.svg)](https://codeclimate.com/github/tamashii-io/tamashii-manager)
===

Tamashii Manager is a package for managing IoT devices that can handle communication between IoT devices in a way similar to Rack.

## Installation

Add the following code to your `Gemfile`:

```ruby
gem 'tamashii-manager'
```

And then execute:
```ruby
$ bundle install
```

Or install it yourself with:
```ruby
$ gem install tamashii-manager
```

## Usage

Tamashii Manager can be started directly through `tamashii-manager` .

    $ tamashii-manager

Because the connection of IoT devices may need verification, we implement a simple Token authentication function, which can achieve through the configuration file.

```ruby
# config.rb

Tamashii::Manager.config do |config|
  config.env = :test
  config.auth_type = :token
  config.token = 'abc123'
  config.port = ENV['PORT'] || 3000
end
```

Then start with `tamashii-manager` :

    $ tamashii-manager -C config.rb

### Rack

To integrate with the project that use Rack through `config.ru` .

```ruby
# config.ru

require 'tamashii/manager'
require './config.rb'

run Tamashii::Manager.server
```

Then start Tamashii Manager through the web server.

    $ puma

Use `Rack :: URLMap` to consolidate your project when collocating with Sinatra and other frameworks.

```ruby
# config.ru

Rack::URLMap.new(
   '/' => App,
  '/tamashii' => Tamashii::Manager.server
)
```

### Rails

To integrate with the Rails project, you can use the `mount` function to plug Tamashii Manager onto Rails.

```ruby
# config/routes.rb

Rails.application.routes.draw do
    mount Tamashii::Manager.server => '/tamashii'
end
```

In Rails, we will want to intercept information in the Tamashii Manager, processed in advance and then send to each IoT device, so it will use Tamashii Resolver function.

```ruby
# config/initializer/tamashii.rb

Tamashii::Manager.config do |config|
  config.env = Rails.env
  config.log_file = Rails.root.join('log', 'tamashii.log')
  config.auth_type = :token
  config.token = 'example'
end

Tamashii::Resolver.config do
  hook RailsHookForTamashii
end
```

Use the `call` method in Resolver function to handle incoming packets.

```ruby
# app/tamashii/rails_hook_for_tamashii.rb

class RailsHookForTamashii < Tamashii::Hook
  def initialize(*args)
    super
    @client = @env[:client]
  end

  def call(packet)
      # Handle packets here
      return false if packet.nil? # The processing failed and let the other Handler go on
      true # Finished processing
  end
end
```

In this way, you can use the Hook to handle the packets sent to Tamashii Manager.

### send_to method

Tamashii Manager will require a `serial number` as a machine ID when authenticating, and so we can use the` send_to` function to send packets to a specify machine.

```ruby
Tamashii::Manager::Client.send_to('example', '...')
```

## Development

To get the source code

    $ git clone git@github.com:tamashii-io/tamashii-manager.git

Initialize the development environment

    $ ./bin/setup

Run the spec

    $ rspec

Installation the version of development on localhost

    $ bundle exec rake install

## Contribution

Please report to us on [Github](https://github.com/tamashii-io/tamashii-manager.) if there is any bug or suggested modified.

The project was developed by [5xruby Inc.](https://5xruby.tw/)

