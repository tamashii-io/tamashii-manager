# frozen_string_literal: true

module Tamashii
  module Manager
    module Handler
      # :nodoc:
      class Broadcaster < Tamashii::Handler
        def resolve(data = nil)
          client = @env[:client]
          broadcast(client, data) if client.authorized?
        end

        def broadcast(client, data)
          packet = Packet.new(@type, client.tag, data)
          client.channel.broadcast(packet.dump)
        end
      end
    end
  end
end
