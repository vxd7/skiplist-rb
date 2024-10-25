# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'skiplist'
require 'debug'

require 'minitest/autorun'

module SkiplistFillingHelpers
  private

  def fill_skiplist(skiplist, size)
    return fill_skiplist_single_value(skiplist) if size == 1

    elems = Set.new
    loop do
      break if elems.size >= size

      elems << rand(500 * size)
    end

    elems.each do |elem|
      skiplist[elem] = elem.to_s
    end
  end

  def fill_skiplist_single_value(skiplist)
    elem = rand(500)

    skiplist[elem] = elem.to_s
    elem
  end
end
