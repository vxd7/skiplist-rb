# frozen_string_literal: true

require_relative 'skip_list/node'
require_relative 'skip_list/level_number_generators'

class SkipList
  attr_accessor :level_number_generator
  attr_reader :size, :default_value

  # Default maximum number of levels possible in the
  # skiplist
  #
  DEFAULT_MAX_LEVEL = 32

  # Default parameter for Geometric distribution
  # used for new level number generation
  #
  DEFAULT_P_VALUE = 0.5

  # Create new SkipList
  #
  def initialize
    @level_number_generator =
      LevelNumberGenerators::InverseTransformGeometric.new(
        max_level: DEFAULT_MAX_LEVEL,
        p_value: DEFAULT_P_VALUE
      )
    @size = 0
  end

  # Search SkipList element by its key
  #
  # @param search_key [Integer] the key to search for
  # @return [SkipList::Node, NilClass] will return the
  #   {SkipList::Node} object if the element is found
  #   and nil otherwise
  #
  def search(search_key)
    current_node = header

    # Traverse levels starting with the highest
    # (with lowest number of elements)
    #
    (0...level).reverse_each do |level|
      current_node.traverse_level(level) do |node|
        # Stop iterating levels when we have already found
        # the element
        #
        return node if node.key == search_key

        # Level change to lower level is needed if the
        # current element is larger than the one searched for
        #
        break if node.key > search_key

        # Current element key is lower than the searched for
        # key. Continue iteration on the current level
        #
        current_node = node
      end

      # Yield the element just before the level transition
      #
      # It is useful for some applications to record the
      # route the search takes
      #
      yield(level, current_node) if block_given?
    end

    # search_key does not exist in the list
    #
    nil
  end
  alias [] search

  def insert(search_key, new_value)
    update = []
    node = search(search_key) do |level, element|
      update[level] = element
    end

    return node.value = new_value if node

    @size += 1

    new_level = level_number_generator.call(self)
    if new_level >= level
      (level..new_level).each do |level|
        update[level] = header
      end
    end

    new_node = Node.new(search_key, new_value)
    (0..new_level).each do |level|
      new_node.forward[level] = update[level].forward_ptr_at(level)
      update[level].forward[level] = new_node
    end
  end
  alias []= insert

  # The level of SkipList.
  #
  # It is equal to the level of its header due to the
  # fact that header is present on every level of the
  # Skiplist
  #
  def level
    header.level
  end

  def header
    @header ||= Node.new(-Float::INFINITY, nil, default: finish)
  end

  def finish
    @finish ||= Node.new(Float::INFINITY, nil)
  end

  def pretty_print
    rows = [header.traverse_level(0).to_a[1...-1]]
    rows[0].each do |element|
      lvl = element.level - 1
      (1..lvl).each do |i|
        rows[i] ||= []
        rows[i] << element
      end

      ((lvl + 1)..header.level).each do |i|
        rows[i] ||= []
        rows[i] << nil
      end
    end

    rows.map.with_index do |e, i|
      next if e.compact.empty?

      ["L#{i}:", 'H', *(e.map { |ee| ee ? ee.key : nil }), 'F'].join("\t")
    end.compact.join("\n")
  end
end
