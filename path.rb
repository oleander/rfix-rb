require "jsonpath"
require "json"

json = JSON.parse(File.read("spec/fixtures/rubocop.json"))
result = JsonPath.new("files[:][?(@.offenses[:].corrected==\"true\")].path").on(json)

puts result
