require 'codeme/common'

module Codeme
  module Manager
    module Handler
      class Broadcaster < Codeme::Handler
        def resolve(data = nil)
          client = @env[:client]
          if client.authorized?
            client.channel.broadcast(Packet.new(@type, client.tag , data).dump)
          end
        end
      end
    end
  end
end
