require_relative 'node'

class SkipList
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
end
