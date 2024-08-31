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
      "#<SkipList::Node of level #{level} with @key = #{key}, @value = #{value}>"
    end

    def <=>(other)
      key <=> other.key
    end
  end
end
