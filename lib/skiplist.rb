# frozen_string_literal: true

require_relative 'skiplist/version'

require_relative 'skiplist/node'
require_relative 'skiplist/level_number_generators'

class Skiplist
  attr_accessor :level_number_generator
  attr_reader :size

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
    @size = 0
    @level_number_generator = LevelNumberGenerators::Geometric.new(
      max_level: DEFAULT_MAX_LEVEL,
      p_value: DEFAULT_P_VALUE
    )
  end

  # Search SkipList element by its key
  #
  # @param search_key [Integer] the key to search for
  # @param full_search [TrueClass, FalseClass] (false) whether to
  #   continue iteration after the element is found on some non-zero'th
  #   level
  # @return [SkipList::Node, NilClass] will return the
  #   {SkipList::Node} object if the element is found
  #   and nil otherwise
  #
  def search(search_key, full_search: false)
    current_node = header

    # Traverse levels starting with the highest
    # (with lowest number of elements)
    #
    (0...level).reverse_each do |lvl|
      current_node.traverse_level(lvl) do |node|
        # Stop iterating levels when we have already found
        # the element and full search is not requested
        #
        return node if !full_search && node.key == search_key

        # Level change to lower level is needed if the
        # current element is larger than the one searched for;
        #
        # If full search is not requested we will change the
        # level just before the found element
        #
        break if node.key >= search_key

        # Current element key is lower than the searched for
        # key. Continue iteration on the current level
        #
        current_node = node
      end

      # Yield the element just before the level transition
      #
      # It is useful to record the route the search takes
      #
      yield(lvl, current_node) if block_given?
    end

    # If the searched for element exists in the sliplist and
    # full search is requested then we will stop at the
    # zero'th level just before searched for element;
    #
    # If the element does not exist then we will stop
    # just before the finish element of the zero'th level
    #
    current_node = current_node.forward_ptr_at(0)
    current_node if current_node.key == search_key
  end
  alias [] search

  # Add new element to skiplist or change the value
  # of existing element
  #
  # @param search_key [Integer]
  # @param new_value [Object]
  #
  # @return [SkipList::Node] newly added or
  #   existing changed node
  #
  def insert(search_key, new_value)
    update = []
    node = search(search_key) do |lvl, element|
      update[lvl] = element
    end

    # Found existing node in the list
    #
    return node.value = new_value if node

    new_level = level_number_generator.call(self)

    if new_level >= level
      (level..new_level).each do |level|
        update[level] = header
      end
    end

    new_node = Node.new(search_key, new_value)
    (0..new_level).each do |lvl|
      new_node.forward[lvl] = update[lvl].forward_ptr_at(lvl)
      update[lvl].forward[lvl] = new_node
    end

    @size += 1

    new_value
  end
  alias []= insert

  # Delete skiplist node associated with the search_key
  #
  # @param [search_key] Integer
  # @return [Skiplist::Node, NilClass] returns deleted node
  #   object or nil if such node does not exist in skiplist
  def delete(search_key)
    update = []
    node = search(search_key, full_search: true) do |lvl, element|
      update[lvl] = element
    end

    # Did not find node to delete
    #
    return unless node

    (0...node.level).each do |lvl|
      update[lvl].forward[lvl] = node.forward[lvl]
    end

    @size -= 1

    # Find first header forward pointer which points
    # directly at the finish node.
    #
    idx = header.forward.find_index { |e| e == finish }
    return node unless idx

    # Pointers from header node directly to finish node can
    # be deleted. This will lower the level of the whole
    # skiplist by at least one level
    #
    header.forward.slice!(idx..-1)

    node
  end

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
