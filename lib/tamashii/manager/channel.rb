# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    class Channel < Set
      SERVER_ID = 0

      class << self
        def pool
          @pool ||= ChannelPool.new
        end

        def get(id)
          pool[id]
        end

        def servers
          @servers ||= Channel.new(SERVER_ID)
        end

        def select_channel(client)
          case client.type
          when :checkin
            servers
          else
            return pool.idle || pool.create! if pool[client.tag].nil?
            pool[client.tag]
          end
        end

        def subscribe(client)
          channel = select_channel(client)
          channel.add(client)
          client.tag = channel.id

          pool.ready(channel)

          Manager.logger.info(
            "Client #{client.id} subscribe to Channel ##{channel.id}"
          )

          channel
        end

        def unsubscribe(client)
          channel = select_channel(client)
          channel.delete(client)

          Manager.logger.info(
            "Client #{client.id} unsubscribe to Channel ##{channel.id}"
          )

          idle_channel(channel) if channel.empty? && channel.id != SERVER_ID
        end

        def idle_channel(channel)
          pool.idle(channel.id)
          # rubocop:disable Metrics/LineLength
          Manager.logger.debug("Channel Pool add - ##{channel.id}, available channels: #{pool.idle.size}")
          # rubocop:enable Metrics/LineLength
        end
      end

      attr_reader :id

      def initialize(id, *args)
        super(*args)
        @id = id
      end

      def send_to(channel_id, packet)
        channel = Channel.pool[channel_id]
        return unless channel.nil?
        channel.broadcast(packet)
      end

      def broadcast(packet, exclude_server = false)
        Manager.logger.info("Broadcast \"#{packet}\" to Channel ##{@id}")
        each do |client|
          client.send(packet)
        end

        # rubocop:disable Metrics/LineLength
        Channel.servers.broadcast(packet) unless id == SERVER_ID || exclude_server
        # rubocop:enable Metrics/LineLength
      end

      def broadcast_all(packet)
        Channel.pool.each do |_id, channel|
          channel&.broadcast(packet, true)
        end
        Channel.servers.broadcast(packet) unless id == SERVER_ID
      end
    end
  end
end
