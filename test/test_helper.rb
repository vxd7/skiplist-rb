# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'skiplist'
require 'debug'

require 'minitest/autorun'

module SkiplistFillingHelpers
  private

  def fill_skiplist_deterministic(skiplist, level_numbers)
    skiplist.level_number_generator =
      Skiplist::LevelNumberGenerators::SimpleDeterministic.new(level_numbers)

    (0...level_numbers.size).to_a.each do |i|
      skiplist[i] = i
    end
  end

  def fill_skiplist(skiplist, size)
    return rand(500).tap { |n| skiplist[n] = n } if size == 1

    elems = Set.new
    loop do
      break if elems.size >= size

      elems << rand(500 * size)
    end

    elems.each do |elem|
      skiplist[elem] = elem
    end
  end
end
