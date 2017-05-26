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
              @accepted_clients ||= {}
            end

            def [](name)
              accepted_clients[name.to_s]
            end

            def []=(name, client)
              return unless client.is_a?(Client)
              accepted_clients[name.to_s] = client
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
