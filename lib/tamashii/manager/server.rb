require "json"
require "securerandom"
require "websocket/driver"

require "tamashii/manager/client"
require "tamashii/manager/stream"
require "tamashii/manager/stream_event_loop"

module Tamashii
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
        setup_heartbeat_timer

        Manager.logger.info("Server is created, read for accept connection")
      end

      def setup_heartbeat_timer
        @heartbeat_timer = @event_loop.timer(Config.heartbeat_interval) do
          @event_loop.post { Connection.instance.map(&:beat) }
        end
      end

      def call(env)
        if WebSocket::Driver.websocket?(env)
          Client.new(env, @event_loop)
          # A dummy rack response
          body = {
            message: "WS connected",
            version: Tamashii::Manager::VERSION
          }.to_json

          [
            200,
            {
              "Content-Type" => "application/json",
              "Content-Length" => body.bytesize
            },
            [body]
          ]
        else

          # TODO: Handle HTTP API
          body = {
            message: "Invalid protocol or api request",
            version: Tamashii::Manager::VERSION
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
