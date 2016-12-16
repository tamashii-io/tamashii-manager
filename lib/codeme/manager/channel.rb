module Codeme
  module Manager
    class Channel < Set
      class << self
        def init(pool_size = 2)
          @empty_channel ||= []
          @channels = {}
          @counter = 1

          pool_size.times {
            @empty_channel << Channel.new(@counter)
            @counter += 1
          }
        end

        def get(id)
          @channels[id]
        end

        def subscribe(client)
          channel = Channel.last_empty
          if channel.nil?
            channel = Channel.new(@counter)
            @counter += 1
          end

          channel.add(client)
          client.tag = channel.id
          @channels[channel.id] = channel

          Logger.info("Client #{client.env['REMOTE_ADDR']} subscribe to Channel ##{channel.id}")

          channel
        end

        def unsubscribe(client)
          channel = @channels[client.tag]
          channel.delete(client)

          Logger.info("Client #{client.env['REMOTE_ADDR']} unsubscribe to Channel ##{channel.id}")

          if channel.empty?
            @channels.delete(channel.id)
            @empty_channel << channel
            Logger.debug("Channel Pool add - ##{channel.id}, available channels: #{@empty_channel.size}")
          end
        end

        def last_empty
          return if !available?
          @empty_channel.shift
        end

        def available?
          !@empty_channel.empty?
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
