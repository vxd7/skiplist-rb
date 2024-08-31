class SkipList
  class Node
    attr_reader :key, :forward
    attr_accessor :value

    def initialize(key, value, default: nil)
      @key = key
      @value = value
      @forward = []

      @default_ptr = default
    end

    def forward_ptr_at(lvl)
      forward.fetch(lvl, default_ptr)
    end

    def first_level_ptr
      forward_ptr_at(0)
    end

    def level
      forward.size
    end

    def inspect
      "#<SkipList::Node of level #{level} with @key = #{key}, @value = #{value}>"
    end

    private

    attr_reader :default_ptr
  end
end
