require "nio"

require "codeme/manager/connection"
require "codeme/manager/logger"

Thread.abort_on_exception = true

module Codeme
  module Manager
    class Stream
      class << self
        attr_reader :nio
        def register(io, client)
          new(io, client)
        end

        def run
          @nio ||= NIO::Selector.new
          @thread = Thread.new { process } if @thread.nil?
        end

        def process
          loop do
            # TODO: Prevent non-block process
            next unless Connection.available?
            next unless monitors = @nio.select(0)
            monitors.each do |monitor|
              monitor.value.parse
            end
          end
        end
      end

      def initialize(io, client)
        @io = io
        @client = client
        @monitor = Stream.nio.register(io, :r)
        @monitor.value = self
      end

      def parse
        @client.parse(@monitor.io.recv_nonblock(4096))
      end

      def close
        @monitor.close
      end
    end
  end
end
