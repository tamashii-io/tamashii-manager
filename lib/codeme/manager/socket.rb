require "websocket/driver"
require "nio"

require "codeme/manager/stream"

module Codeme
  module Manager
    class Socket
      attr_reader :env, :url

      def initialize(env)
        @env = env

        secure = Rack::Request.new(env).ssl?
        scheme = secure ? 'wss:' : 'ws:'
        @url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"

        @driver = WebSocket::Driver.rack(self)

        env['rack.hijack'].call
        @io = env['rack.hijack_io']

        monitor = Stream.register(@io)
        monitor.value = proc {
          @driver.parse(monitor.io.read_nonblock(4096))
        }

        @driver.on :message do |event|
          puts "Receive: #{event.data}"
        end

        @driver.start
      end

      def write(buffer)
        @io.write(buffer)
      end
    end
  end
end
