require 'codeme/manager/channel'

module Codeme
  module Manager
    class ChannelPool < Hash
      def initialize(size = 10)
        @idle = []
        @ptr = 1

        size.times {
          @idle << Channel.new(@ptr)
          @ptr += 1
        }
      end

      def get(id)
        self[id]
      end

      def create!
        @idle << Channel.new(@ptr)
        @ptr += 1
      end

      def idle(channel_id = nil)
        return @idle if channel_id.nil?
        return unless self[channel_id].empty?
        @idle << self[channel_id]
        self[channel_id] = nil
      end

      def ready(channel)
        self[channel.id] = channel
      end

      def available?
        !@idle.empty?
      end

      def get_idle!
        @idle.shift
      end
    end
  end
end
