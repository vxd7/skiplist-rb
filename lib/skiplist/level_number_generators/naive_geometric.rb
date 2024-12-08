# frozen_string_literal: true

require 'securerandom'

class Skiplist
  module LevelNumberGenerators
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
  end
end
