require 'securerandom'

class SkipList
  module LevelNumberGenerators
    # Generate level number using inverse transform method
    # to get geometric distribution from uniformly distributed
    # random variables in O(1) time complexity
    #
    module InverseTransformGeometric
      def self.call(max_level, p)
        lvl = (Math.log(1.0 - SecureRandom.rand)/Math.log(1.0 - p)).floor
        [lvl, max_level].min
      end
    end

    # Generate geometric distribution using manual
    # trial emulation.
    #
    # This method can be considered inefficient and
    # will require on average 1/p random numbers
    # to be generated
    #
    module NaiveGeometric
      def self.call(max_level, p)
        lvl = 0
        loop do
          break if SecureRandom.rand >= p
          break if lvl >= max_level

          lvl += 1
        end

        lvl
      end
    end
  end
end
