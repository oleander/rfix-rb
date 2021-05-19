lines = (0..5).to_a
line = 7

r = lines.to_a.fill(lines.count...line) do |index|
  lines[index] ||= "X"
end.then do |result|
  result.insert(line, "U")
end

pp r
