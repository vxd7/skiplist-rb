require_relative 'skip_list'

sl = SkipList.new

r = Set.new
loop do
  break if r.size >= 45

  r << rand(500)
end

r.each do |e|
  sl[e] = e.to_s
  # sl.insert(e, e.to_s)
end

binding.b
puts sl.pretty_print

