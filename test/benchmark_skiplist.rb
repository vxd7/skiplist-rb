# frozen_string_literal: true

require 'test_helper'
require 'minitest/benchmark'

class BenchmarkSkiplist < Minitest::Benchmark
  include Skiplist::LevelNumberGenerators
  include SkiplistFillingHelpers

  TOLERANCE = 0.90

  def self.bench_range
    (20_000..30_000).step(100)
  end

  def setup
    @skiplists, @elements = setup_benchmark_skiplists(self.class.bench_range)
  end

  def bench_skiplist_insertion
    assert_performance_logarithmic(TOLERANCE) do |n|
      4000.times { @skiplists[n][@elements.sample] = 'abacaba' }
    end
  end

  def bench_skiplist_deletion
    assert_performance_logarithmic(TOLERANCE) do |n|
      4000.times { @skiplists[n].delete(@elements.sample) }
    end
  end
end
