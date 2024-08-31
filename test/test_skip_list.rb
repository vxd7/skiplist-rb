require 'set'
require 'minitest/autorun'

require_relative '../skip_list'

class TestSkipList < Minitest::Test
  attr_reader :skiplist

  def setup
    @skiplist = SkipList.new
  end

  def test_simple_one_value_insert
    elem = rand(100)
    skiplist.insert(elem, elem.to_s)
   
    assert_equal(skiplist[elem].value, elem.to_s)
  end

  def test_search_value_not_exists
    elem = rand(100)
    skiplist.insert(elem, elem.to_s)
   
    assert_nil(skiplist[elem + 1])
  end

  def test_multiple_insert_values
    # Construct unique elements set
    #
    elems = Set.new
    loop do
      break if elems.size >= 100

      elems << rand(500)
    end

    # Feed elements to the skiplist
    #
    elems.each { |elem| skiplist[elem] = elem.to_s }

    elems.each do |elem|
      assert_equal(skiplist[elem].value, elem.to_s)
    end
  end

  def test_changing_value
    elem = rand(100)
    skiplist.insert(elem, elem.to_s)

    new_value = 'abacaba'
    skiplist[elem] = new_value
    assert_equal(skiplist[elem].value, new_value)
  end
end
