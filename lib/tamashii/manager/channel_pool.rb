# frozen_string_literal: true

module Tamashii
  module Manager
    class ChannelPool < Hash
      def initialize(size = 10)
        @idle = []
        @ptr = 1

        size.times { create! }
      end

      def create!
        @idle << Channel.new(@ptr)
        @ptr += 1
      end

      def idle(channel_id = nil)
        return @idle if channel_id.nil?
        return unless self[channel_id]&.empty?
        @idle << self[channel_id]
        self[channel_id] = nil
      end

      def ready(channel)
        return if channel.empty?
        self[channel.id] = channel
        if @idle.include?(channel)
          @idle.delete(channel)
        end
        channel
      end

      def available?
        !@idle.empty?
      end

      def get_idle
        @idle.first
      end
    end
  end
end
