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

    rand_range(size).each do |elem|
      skiplist[elem] = elem
    end
  end

  def rand_range(size)
    range_start = rand(500 * size)
    range_end = range_start + size

    (range_start...range_end).to_a.shuffle
  end

  def setup_benchmark_skiplists(sequence)
    level_numbers = geometric_distribution(100)
    elements = rand_range(sequence.end)
    skiplists = {}

    sequence.each do |num_elems|
      skiplists[num_elems] = setup_benchmark_skiplist(
        level_numbers,
        elements.take(num_elems)
      )
    end

    [skiplists, elements]
  end

  def setup_benchmark_skiplist(level_numbers, elements)
    skiplist = Skiplist.new

    gen = Skiplist::LevelNumberGenerators::SimpleDeterministic.new(level_numbers.cycle)
    skiplist.level_number_generator = gen

    puts "Fill skiplist with #{elements.size} elements"
    range_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    elements.each { |element| skiplist[element] = element }

    range_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "Finished in #{range_end - range_start} seconds\n"

    skiplist
  end

  def geometric_distribution(size)
    gen = Skiplist::LevelNumberGenerators::InverseTransformGeometric.new(
      max_level: Skiplist::DEFAULT_MAX_LEVEL,
      p_value: Skiplist::DEFAULT_P_VALUE
    )

    Array.new(size) { gen.call }
  end
end
