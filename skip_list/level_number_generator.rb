class SkipList
  class LevelNumberGenerator
    def self.call(upper_bound)
      lvl = 0
      loop do
        break if rand >= 0.5
        break if lvl >= upper_bound

        lvl += 1
      end

      lvl
    end
  end
end
