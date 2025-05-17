# frozen_string_literal: true

class Skiplist
  module LevelNumberGenerators
    # Generate level numbers using provided values from Array,
    # Enumerator or single numeric value
    #
    class Deterministic
      # @param value [Array, Enumerator, Integer]
      #   when Array it will be used to generate finite amount of
      #     levels numbers
      #   when Enumerator it will be used to generate level numbers
      #     while enumeration is possible
      #   when Integer it will be used to generate the same level
      #     numbers indefinitely
      #
      def initialize(value)
        @values = convert_value(value)
      end

      def call(_skiplist = nil)
        @values.next
      end

      private

      def convert_value(value)
        case value
        when Array then value.each
        when Enumerator then value
        else [value].cycle
        end
      end
    end
  end
end
