# frozen_string_literal: true

Tamashii::Server.config do |config|
  config.connection_class = Tamashii::Manager::Client
  config.pubsub_class = Tamashii::Manager::Subscription
end

module Tamashii
  module Manager
    # :nodoc:
    class Server < Tamashii::Server::Base
      def call(env)
        super
      end

      def inspect
        "Tamashii::Manager::Server v#{VERSION}"
      end
    end
  end
end
