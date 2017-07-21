# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    module ClientManager
      # rubocop:disable Metrics/MethodLength
      def self.included(other)
        other.class_eval do
          class << self
            def accepted_clients
              @accepted_clients ||= Concurrent::Hash.new
            end

            def [](name)
              accepted_clients[name.to_s]
            end

            # TODO: Fix duplicate name
            def []=(name, client)
              return unless client.is_a?(Client)
              accepted_clients[name.to_s] = client
            end

            def remove_client(name)
              accepted_clients.delete(name)
            end

            def send_to(id, packet)
              Manager.server.pubsub.send_to(id, packet)
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
