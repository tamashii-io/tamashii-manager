# frozen_string_literal: true

Tamashii::Server.config do |config|
  config.connection_class = Tamashii::Manager::Client
  config.pubsub_class = Tamashii::Manager::Subscription
end

module Tamashii
  module Manager
    # :nodoc:
    class Server < Tamashii::Server::Base
      def initialize
        super
        setup_heartbeat_timer
      end

      def call(env)
        setup_heartbeat_timer
        super
      end

      # NOTE: Move into Tamashii::Server maybe better
      def setup_heartbeat_timer
        @heartbeat_timer = @event_loop.timer(Config.heartbeat_interval) do
          @event_loop.post { Client.accepted_clients.values.map(&:beat) }
        end
      end
    end
  end
end
