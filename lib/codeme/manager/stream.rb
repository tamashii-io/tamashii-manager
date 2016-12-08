require "nio"

module Codeme
  module Manager
    class Stream
      class << self
        def register(io)
          @nio.register(io, :r)
        end

        def run
          @nio ||= NIO::Selector.new
          @thread = Thread.new { process } if @thread.nil?
        end

        def process
          loop do
            # TODO: Prevent non-block process
            next unless monitors = @nio.select(0)
            monitors.each do |monitor|
              monitor.value.call
            end
          end
        end
      end
    end
  end
end
