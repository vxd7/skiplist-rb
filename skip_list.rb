require 'singleton'
require 'set'
require 'debug'

require_relative 'skip_list/node'
require_relative 'skip_list/level_number_generator'

class SkipList
  attr_reader :max_level, :level_number_generator, :size

  def initialize(max_level = 32, &block)
    @max_level = max_level
    @level_number_generator = block_given? ? block : LevelNumberGenerator

    @size = 0
  end

  def search(search_key)
    current_node = header

    (0...level).reverse_each do |level|
      current_node.traverse_level(level) do |node|
        break if node.key >= search_key

        current_node = node
      end

      yield(level, current_node) if block_given?
    end

    current_node = current_node.forward_ptr_at(0)
    return current_node if current_node.key == search_key

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

    new_level = level_number_generator.call(max_level)
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
