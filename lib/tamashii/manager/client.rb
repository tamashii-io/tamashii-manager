# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    class Client < Tamashii::Server::Connection::Base
      include ClientManager

      attr_reader :env, :url
      attr_reader :channel

      attr_reader :last_beat_timestamp
      attr_reader :last_response_time

      attr_accessor :tag

      def id
        return "<Unauthorized : #{@env['REMOTE_ADDR']}>" if @id.nil?
        @id
      end

      def type
        Type::CLIENT.key(@type)
      end

      def send(packet)
        packet = packet.dump if packet.is_a?(Tamashii::Packet)
        @socket.transmit(packet)
      end

      def authorized?
        !@id.nil?
      end

      def accept(type, id)
        @id = id
        @type = type
        @channel = Channel.subscribe(self)
        packet = Tamashii::Packet.new(
          Tamashii::Type::AUTH_RESPONSE,
          @channel.id,
          true
        )
        Client[id] = self
        send packet.dump
      end

      def beat
        beat_time = Time.now
        @socket.ping("heart-beat-at-#{beat_time}") do
          heartbeat_callback(beat_time)
        end
      end

      def heartbeat_callback(beat_time)
        @last_beat_timestamp = Time.now
        @last_response_time = @last_beat_timestamp - beat_time
        Manager.logger.debug(
          "[#{id}] Heart beat #{beat_time} " \
          "returns at #{@last_beat_timestamp}!" \
          " Delay: #{(@last_response_time * 1000).round} ms"
        )
      end

      def on_open
        Manager.logger.info("Client #{id} is ready")
      end

      def on_message(data)
        Manager.logger.debug("Receive Data: #{data}")
        return unless data.is_a?(Array)
        Tamashii::Resolver.resolve(Tamashii::Packet.load(data), client: self)
      rescue AuthorizationError => reason
        close_on_authorize_failed(reason)
      rescue => e
        on_message_error(e)
      end

      def on_close
        Manager.logger.info("Client #{id} closed connection")
        Client[id] = nil
      end

      def emit_error(message)
        Manager.logger.error("Client #{id} has error => #{message}")
      end

      private

      def close_on_authorize_failed(reason)
        Manager.logger.error(
          "Client #{id} authentication failed => #{reason.message}"
        )
        send(Tamashii::Packet.new(Tamashii::Type::AUTH_RESPONSE, 0, false))
        @socket.close
      end

      def on_message_error(e)
        Manager.logger.error(
          "Error when receiving data from client #{id}: #{e.message}"
        )
        Manager.logger.debug('Backtrace:')
        e.backtrace.each { |msg| Manager.logger.debug(msg) }
      end
    end
  end
end
