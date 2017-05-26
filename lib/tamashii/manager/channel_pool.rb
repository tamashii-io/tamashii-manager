# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    class ChannelPool < Hash
      attr_reader :idles

      def initialize(size = 10)
        @idles = []
        @ptr = 1

        size.times { create! }
      end

      def create!
        @idles << Channel.new(@ptr)
        @ptr += 1
      end

      def idle(channel_id = nil)
        return @idles.first if channel_id.nil?
        return unless self[channel_id]&.empty?
        @idles << self[channel_id]
        self[channel_id] = nil
      end

      def ready(channel)
        return if channel.empty?
        self[channel.id] = channel
        @idles.delete(channel) if @idles.include?(channel)
        channel
      end

      def available?
        !@idles.empty?
      end
    end
  end
end
