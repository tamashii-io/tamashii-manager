require "json"
require "securerandom"
require "websocket/driver"

require "codeme/manager/client"
require "codeme/manager/stream"
require "codeme/manager/stream_event_loop"

module Codeme
  module Manager
    class Server
      class << self
        attr_reader :instance

        LOCK = Mutex.new

        def compile
          @instance ||= new
        end

        def call(env)
          LOCK.synchronize { compile } unless instance
          call!(env)
        end

        def call!(env)
          instance.call(env)
        end
      end

      def initialize
        @event_loop = StreamEventLoop.new

        Logger.info("Server is created, read for accept connection")
      end

      def call(env)
        if WebSocket::Driver.websocket?(env)
          Client.new(env, @event_loop)
        else

          # TODO: Handle HTTP API
          body = {
            message: "Invalid protocol or api request",
            version: Codeme::Manager::VERSION
          }.to_json

          [
            404,
            {
              "Content-Type" => "application/json",
              "Content-Length" => body.bytesize
            },
            [body]
          ]
        end
      end
    end
  end
end
