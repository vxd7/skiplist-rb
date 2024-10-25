# frozen_string_literal: true

require 'test_helper'
require 'skiplist'

class TestSkiplist < Minitest::Test
  include SkiplistFillingHelpers
  include Skiplist::LevelNumberGenerators

  def setup
    @skiplist = Skiplist.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Skiplist::VERSION
  end

  def test_simple_one_value_insert
    elem = fill_skiplist(@skiplist, 1)

    assert_equal(elem, @skiplist[elem].value)
  end

  def test_search_value_not_exists
    elem = fill_skiplist(@skiplist, 1)

    assert_nil(@skiplist[elem + 1])
  end

  def test_multiple_insert_values
    elems = fill_skiplist(@skiplist, 600)

    elems.each do |elem|
      assert_equal(elem, @skiplist[elem].value)
    end
  end

  def test_insert_method_return_value
    value = 'abacaba'
    assert_equal(value, @skiplist[123] = value)

    new_value = 'qwerty'
    assert_equal(new_value, @skiplist[123] = new_value)
  end

  def test_changing_value
    elem = fill_skiplist(@skiplist, 1)

    new_value = 'abacaba'
    @skiplist[elem] = new_value
    assert_equal(new_value, @skiplist[elem].value)
  end

  def test_single_level_pretty_print
    @skiplist.level_number_generator = SimpleDeterministic.new(0)

    elem = fill_skiplist(@skiplist, 1)

    str = "L0:\tH\t#{elem}\tF"
    assert_equal(str, @skiplist.pretty_print)
  end

  def test_skip_list_level
    target_level = rand(1..20)
    @skiplist.level_number_generator = SimpleDeterministic.new(target_level)

    fill_skiplist(@skiplist, 10)

    assert_equal(target_level + 1, @skiplist.level)
  end

  def test_skip_list_strictly_ordered_at_every_level
    fill_skiplist(@skiplist, 1000)

    (0...@skiplist.level).each do |lvl|
      assert(
        @skiplist.header.traverse_level(lvl).each_cons(2).all? do |c|
          c[0].key < c[1].key
        end
      )
    end
  end

  def test_size_when_empty
    assert_equal(0, @skiplist.size)
  end

  def test_size_when_filled
    target_size = rand(1..1000)
    fill_skiplist(@skiplist, target_size)

    assert_equal(target_size, @skiplist.size)
  end

  def test_size_not_incrementing_after_elements_modification
    target_size = rand(20..100)
    elems = fill_skiplist(@skiplist, target_size)

    elems.to_a.sample(rand(20)).each do |element|
      @skiplist[element] = 'abacaba'
    end

    assert_equal(target_size, @skiplist.size)
  end

  # For the following structure of skiplist:
  #
  # L0: H   2   3   4   F
  # L1: H   2   3   4   F
  # L2: H   2   3   4   F
  # L3: H   2       4   F
  # L4: H   2           F
  #
  # Searching for the element with key = 3
  # should return this element
  #
  def test_searching_4_3_2
    @skiplist.level_number_generator = SimpleDeterministic.new([4, 3, 2])

    @skiplist[2] = '2'
    @skiplist[4] = '4'
    @skiplist[3] = '3'

    assert_equal('3', @skiplist[3].value)
  end

  # Test searching for element in empty skiplist
  #
  def test_searching_in_empty_list
    assert_nil(@skiplist[330])
  end

  def test_searching_in_list_of_level_zero
    @skiplist.level_number_generator = SimpleDeterministic.new(0)

    elems = fill_skiplist(@skiplist, 100)

    assert_equal(1, @skiplist.level)
    elems.each do |elem|
      assert_equal(elem, @skiplist[elem].value)
    end
  end
end
