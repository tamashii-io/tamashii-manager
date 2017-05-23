require 'json'
require 'securerandom'
require 'websocket/driver'
require 'monitor'

require 'tamashii/server'

require 'tamashii/manager/client'
require 'tamashii/manager/stream'
require 'tamashii/manager/stream_event_loop'

Tamashii::Server.config do |config|
  config.connection_class = Tamashii::Manager::Client
end

module Tamashii
  module Manager
    class Server < Tamashii::Server::Base
      def setup_heartbeat_timer
        @heartbeat_timer = @event_loop.timer(Config.heartbeat_interval) do
          @event_loop.post { Connection.instance.map(&:beat) }
        end
      end
    end
  end
end
