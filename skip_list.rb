require 'singleton'
require 'set'
require 'debug'

require_relative 'skip_list/node'

class SkipList
  attr_reader :max_level, :random_level

  def initialize(max_level = 32, &block)
    @max_level = max_level
    @random_level = block if block_given?
  end

  def search(search_key)
    # puts "Search for search_key: #{search_key}"
    current_node = header

    (0...current_node.level).reverse_each do |level|
      loop do
        break if current_node.forward_ptr_at(level).key >= search_key

        current_node = current_node.forward_ptr_at(level)
      end

      yield(level, current_node) if block_given?
    end

    current_node = current_node.first_level_ptr
    return current_node if current_node.key == search_key

    nil
  end
  alias [] search

  def insert(search_key, new_value)
    # puts "Insert search_key: #{search_key}, new_value: #{new_value}: searching..."
    update = []
    node = search(search_key) { |i, x| update[i] = x }
    return node.value = new_value if node

    new_level = fetch_random_level
    # puts "Insert search_key: #{search_key}, new_value: #{new_value}, new_level: #{new_level}"
    if new_level >= header.level
      (header.level..new_level).each do |level|
        update[level] = header
      end
    end

    new_node = Node.new(search_key, new_value)
    (0..new_level).each do |level|
      new_node.forward[level] = update[level].forward_ptr_at(level)
      update[level].forward[level] = new_node
    end
    # puts "Insert search_key: #{search_key}, new_value: #{new_value}, new_level: #{new_level}: SUCCESS"
  end
  alias []= insert

  def fetch_random_level
    return random_level.call if random_level

    lvl = 0
    loop do
      break if rand >= 0.5
      break if lvl >= max_level

      lvl += 1
    end

    lvl
  end

  def header
    @header ||= Node.new(-Float::INFINITY, nil, default: finish)
  end

  def finish
    @finish ||= Node.new(Float::INFINITY, nil)
  end

  def pretty_print
    rows = [fetch_level(0)[1...-1]]
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

  def fetch_level(level)
    elements = [header]
    elem = header.forward_ptr_at(level)
    loop do
      break unless elem

      elements.append(elem)
      elem = elem.forward_ptr_at(level)
    end

    elements
  end
end
