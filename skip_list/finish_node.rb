require_relative 'node'

class SkipList
  class FinishNode < Node
    include Singleton

    def initialize
      super(Float::INFINITY, nil)
    end

    def inspect
      "#<SkipList::FinishNode>"
    end
  end
end
