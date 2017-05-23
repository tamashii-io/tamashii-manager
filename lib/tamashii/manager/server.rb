Tamashii::Server.config do |config|
  config.connection_class = Tamashii::Manager::Client
end

module Tamashii
  module Manager
    # :nodoc:
    class Server < Tamashii::Server::Base
      # TODO: Add back heartbeat feature
      def setup_heartbeat_timer
        @heartbeat_timer = @event_loop.timer(Config.heartbeat_interval) do
          @event_loop.post { Connection.instance.map(&:beat) }
        end
      end
    end
  end
end
