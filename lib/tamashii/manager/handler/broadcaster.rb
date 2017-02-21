require 'tamashii/common'

module Tamashii
  module Manager
    module Handler
      class Broadcaster < Tamashii::Handler
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
