require 'set'
require 'minitest/autorun'

require_relative '../skip_list'

class TestSkipList < Minitest::Test
  attr_reader :skiplist

  def setup
    @skiplist = SkipList.new
  end

  def test_simple_one_value_insert
    elem = fill_skiplist(1)
   
    assert_equal(elem.to_s, skiplist[elem].value)
  end

  def test_search_value_not_exists
    elem = fill_skiplist(1)
   
    assert_nil(skiplist[elem + 1])
  end

  def test_multiple_insert_values
    elems = fill_skiplist(100)

    elems.each do |elem|
      assert_equal(elem.to_s, skiplist[elem].value)
    end
  end

  def test_changing_value
    elem = fill_skiplist(1)

    new_value = 'abacaba'
    skiplist[elem] = new_value
    assert_equal(new_value, skiplist[elem].value)
  end

  def test_single_level_pretty_print
    @skiplist = SkipList.new { 0 }
    elem = fill_skiplist(1)

    str = "L0:\tH\t#{elem}\tF"
    assert_equal(str, skiplist.pretty_print)
  end

  def test_skip_list_level
    target_level = 1 + rand(20)
    @skiplist = SkipList.new { target_level }
    fill_skiplist(10)

    assert_equal(target_level + 1, skiplist.level)
  end

  def test_skip_list_strictly_ordered_at_every_level
    fill_skiplist(1000)

    (0...skiplist.level).each do |lvl|
      assert(
        skiplist.header.traverse_level(lvl).each_cons(2).all? { |c| c[0].key < c[1].key }
      )
    end
  end

  def test_size_when_empty
    assert_equal(0, skiplist.size)
  end

  def test_size_when_filled
    target_size = rand(1000)
    fill_skiplist(target_size)

    assert_equal(target_size, skiplist.size)
  end

  def test_size_not_incrementing_after_elements_modification
    target_size = 1 + rand(100)
    elems = fill_skiplist(target_size)

    elems.to_a.sample(rand(20)).each do |element|
      skiplist[element] = 'abacaba'
    end

    assert_equal(target_size, skiplist.size)
  end

  private

  def fill_skiplist(size)
    return fill_skiplist_with_single_value if size == 1

    elems = Set.new
    loop do
      break if elems.size >= size

      elems << rand(500 * size)
    end

    elems.each { |elem| skiplist[elem] = elem.to_s }
    elems
  end

  def fill_skiplist_with_single_value
    elem = rand(500)

    skiplist[elem] = elem.to_s
    elem
  end
end
