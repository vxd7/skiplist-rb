# frozen_string_literal: true

require 'test_helper'

class TestSkiplistDeletion < Minitest::Test
  include Skiplist::LevelNumberGenerators

  def setup
    @skiplist = Skiplist.new
  end

  def test_delete_only_element
    @skiplist[0] = '0'

    @skiplist.delete(0)

    assert_equal(0, @skiplist.size)
    assert_equal(0, @skiplist.level)
  end

  def test_delete_element_not_found
    @skiplist[0] = '0'
    @skiplist[2] = '2'

    @skiplist.delete(1)

    assert_equal(2, @skiplist.size)
    refute_nil(@skiplist[0])
  end

  def test_delete_return_value
    @skiplist[0] = '0'

    node = @skiplist.delete(0)
    assert_equal(0, node.key)
    assert_equal('0', node.value)

    assert_nil(@skiplist.delete(123))
  end

  def test_skiplist_size_after_deletion
    size = 100
    elements = fill_skiplist(size)

    to_delete_size = rand(10..20)
    elements.to_a.sample(to_delete_size).each do |to_delete|
      @skiplist.delete(to_delete)
    end

    assert_equal(size - to_delete_size, @skiplist.size)
  end

  # L0: H   0   1   2   3   4   5   6   F
  # L1: H   0   1   2   3           6   F
  # L2: H   0   1   2                   F
  # L3: H   0   1   2                   F
  # L4: H   0       2                   F
  def test_delete_first_element
    level_numbers = [4, 3, 4, 1, 0, 0, 1]
    @skiplist.level_number_generator = SimpleDeterministic.new(level_numbers)

    elements = (0...level_numbers.size).to_a
    elements.each do |i|
      @skiplist[i] = i.to_s
    end

    @skiplist.delete(0)

    elements[1..].each do |elem|
      refute_nil(@skiplist[elem])
    end
  end

  # L0: H   0   1   2   F
  # L1: H   0   1   2   F
  # L2: H   0   1       F
  # L3: H   0           F
  # L4: H   0           F
  def test_level_truncation_after_deletion
    level_numbers = [4, 2, 1]
    @skiplist.level_number_generator = SimpleDeterministic.new(level_numbers)

    elements = (0...level_numbers.size).to_a
    elements.each do |i|
      @skiplist[i] = i.to_s
    end

    deleted_node = @skiplist.delete(0)

    assert_equal(0, deleted_node.key)
    assert_equal(3, @skiplist.level)
  end

  private

  def fill_skiplist(size)
    elems = Set.new
    loop do
      break if elems.size >= size

      elems << rand(500 * size)
    end

    elems.each do |elem|
      @skiplist[elem] = elem.to_s
    end
  end
end
