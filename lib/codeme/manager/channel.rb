require 'codeme/manager/channel_pool'

module Codeme
  module Manager
    class Channel < Set
      class << self
        def pool
          @pool ||= ChannelPool.new
        end

        def get(id)
          pool[id]
        end

        def subscribe(client)
          channel = pool.get_idle || pool.create!
          channel.add(client)
          client.tag = channel.id

          pool.ready(channel)

          Logger.info("Client #{client.id} subscribe to Channel ##{channel.id}")

          channel
        end

        def unsubscribe(client)
          channel = pool[client.tag]
          channel.delete(client)

          Logger.info("Client #{client.id} unsubscribe to Channel ##{channel.id}")

          if channel.empty?
            pool.idle(channel.id)
            Logger.debug("Channel Pool add - ##{channel.id}, available channels: #{pool.idle.size}")
          end
        end
      end

      attr_reader :id

      def initialize(id, *args)
        super(*args)
        @id = id
      end

      def broadcast(packet)
        Logger.info("Broadcast \"#{packet}\" to Channel ##{@id}")
        each do |client|
          client.send(packet)
        end
      end
    end
  end
end
