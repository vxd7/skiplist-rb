require 'singleton'
require 'set'

class SkipList
  class Node
    include Comparable

    attr_reader :key, :forward
    attr_accessor :value

    def initialize(key, value)
      @key = key
      @value = value
      @forward = []
    end

    def add(node)
      forward << node
    end

    def level
      forward.size
    end

    def inspect
      "#<SkipList::Node @key = #{key}, @value = #{value}, @forward = #{forward}>"
    end

    def <=>(other)
      key <=> other.key
    end
  end

  class HeaderNode < Node
    include Singleton

    def initialize
      super(-Float::INFINITY, nil)
      @forward = Array.new(32, FinishNode.instance)
    end

    def inspect
      "#<SkipList::HeaderNode>"
    end
  end

  class FinishNode < Node
    include Singleton

    def initialize
      super(Float::INFINITY, nil)
    end
  end

  def initialize(max_level = 32)
    @max_level = max_level
    header.add(finish)
  end

  def search(search_key)
    # puts "Search for search_key: #{search_key}"
    current_node = header

    (0...current_node.level).reverse_each do |level|
      loop do
        break if current_node.forward[level].key >= search_key

        current_node = current_node.forward[level]
      end

      yield(level, current_node) if block_given?
    end

    current_node = current_node.forward.first
    return current_node if current_node.key == search_key

    nil
  end

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
      new_node.forward[level] = update[level].forward[level]
      update[level].forward[level] = new_node
    end
    # puts "Insert search_key: #{search_key}, new_value: #{new_value}, new_level: #{new_level}: SUCCESS"
  end

  def fetch_random_level
    lvl = 0
    loop do
      break if rand >= 0.5
      break if lvl >= @max_level

      lvl += 1
    end

    lvl
  end

  def header
    @header ||= HeaderNode.instance
  end

  def finish
    @finish ||= FinishNode.instance
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

    rows.each_with_index do |e, i|
      next if e.compact.empty?

      vals = ["L#{i}:", 'H', *(e.map { |ee| ee ? ee.key : nil }), 'F']
      puts vals.join("\t")
    end
  end

  def fetch_level(level)
    elements = [header]
    elem = header.forward[level]
    loop do
      break unless elem

      elements.append(elem)
      elem = elem.forward[level]
    end

    elements
  end
end

sl = SkipList.new

r = Set.new
loop do
  break if r.size >= 40

  r << rand(500)
end

r.each { |e| sl.insert(e, 'e') }
sl.pretty_print