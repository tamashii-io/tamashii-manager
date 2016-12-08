require "json"
require "websocket/driver"

require "codeme/manager/socket"
require "codeme/manager/stream"

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
        Stream.run
      end

      def call(env)
        if WebSocket::Driver.websocket?(env)
          Socket.new(env)
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
