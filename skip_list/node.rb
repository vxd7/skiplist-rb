class SkipList
  class Node
    include Comparable

    attr_reader :key, :forward
    attr_accessor :value

    def initialize(key, value, default_ptr = nil)
      @key = key
      @value = value
      @forward = Hash.new(default_ptr)
    end

    def level
      forward.size
    end

    def inspect
      "#<SkipList::Node of level #{level} with @key = #{key}, @value = #{value}>"
    end
  end
end
