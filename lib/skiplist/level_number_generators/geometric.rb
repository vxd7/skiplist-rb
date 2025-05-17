# frozen_string_literal: true

require 'securerandom'

class Skiplist
  module LevelNumberGenerators
    # Generate level number using inverse transform method
    # to get geometric distribution from uniformly distributed
    # random variables in O(1) time complexity
    #
    class Geometric
      # @param max_level [Integer] level number cap
      # @param p_value [Float] parameter of geometric
      #   distribution
      #
      def initialize(max_level, p_value)
        @max_level = max_level
        @p_value = p_value
      end

      def call(_skiplist = nil)
        lvl = (Math.log(1.0 - SecureRandom.rand) / Math.log(1.0 - @p_value)).floor
        [lvl, @max_level].min
      end
    end
  end
end
