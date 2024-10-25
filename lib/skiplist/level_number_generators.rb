# frozen_string_literal: true

require 'securerandom'

class Skiplist
  module LevelNumberGenerators
    # Generate level number using inverse transform method
    # to get geometric distribution from uniformly distributed
    # random variables in O(1) time complexity
    #
    class Geometric
      # @param max_level [Integer] (32) level number cap
      # @param p_value [Float] (0.5) parameter of geometric
      #   distribution
      #
      def initialize(max_level = 32, p_value = 0.5)
        @max_level = max_level
        @p_value = p_value
      end

      def call(_skiplist = nil)
        lvl = (Math.log(1.0 - SecureRandom.rand) / Math.log(1.0 - @p_value)).floor
        [lvl, @max_level].min
      end
    end

    # Generate geometric distribution using manual
    # trial emulation.
    #
    # This method can be considered inefficient and
    # will require on average 1/p random numbers
    # to be generated
    #
    class NaiveGeometric
      # @param max_level [Integer] (32) level number cap
      # @param p_value [Float] (0.5) parameter of geometric
      #   distribution
      #
      def initialize(max_level, p_value)
        @max_level = max_level
        @p_value = p_value
      end

      def call(_skiplist = nil)
        lvl = 0
        loop do
          break if SecureRandom.rand >= @p_value
          break if lvl >= @max_level

          lvl += 1
        end

        lvl
      end
    end

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
