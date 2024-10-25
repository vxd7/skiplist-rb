require 'test_helper'
require 'minitest/benchmark'

class BenchmarkSkiplist < Minitest::Benchmark
  include Skiplist::LevelNumberGenerators

  RANGE_MAX = 30000

  def self.bench_range
    (20000..RANGE_MAX).step(100)
  end

  def setup
    @skiplists = {}
    @elems = generate_random_values(RANGE_MAX).to_a

    gen = InverseTransformGeometric.new(
      max_level: Skiplist::DEFAULT_MAX_LEVEL,
      p_value: Skiplist::DEFAULT_P_VALUE
    )
    entropy = Array.new(100) { gen.call }.cycle

    level_number_generator = SimpleDeterministic.new(entropy)
    @ranges = self.class.bench_range.each do |range|
      puts "Setup range: #{range}"
      range_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      skiplist = Skiplist.new
      skiplist.level_number_generator = level_number_generator

      @elems.take(range).each do |elem|
        skiplist[elem] = elem
      end
      range_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Finished in #{range_end - range_start} seconds\n"

      @skiplists[range] = skiplist
    end
  end

  def bench_skip_list_insertion
    assert_performance_logarithmic(0.90) do |n|
      4000.times { @skiplists[n][@elems.sample] = 'abacaba' }
    end
  end

  private

  def generate_random_values(size)
    elems = Set.new
    loop do
      break if elems.size >= size

      elems << rand(500 * size)
    end

    elems
  end
end
