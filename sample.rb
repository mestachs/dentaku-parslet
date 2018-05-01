require "parslet"
require "pp"
require "byebug"
require_relative "parser"
require_relative "evaluator"
require "pp"
require "json"

require "parslet"
require "parslet/convenience"

# in case of too deep
# class Parslet::Atoms::Context
#   def lookup(obj, pos)
#     p obj
#     @cache[pos][obj.object_id]
#   end
# end

problem = JSON.parse(File.read("problem.json"))

parser = InfixExpressionParser.new
input = "SUM(act1_active_weight_for_1_and_2016q1,act2_active_weight_for_1_and_2016q1,act3_active_weight_for_1_and_2016q1,act4_active_weight_for_1_and_2016q1,act5_active_weight_for_1_and_2016q1,act6_active_weight_for_1_and_2016q1,act7_active_weight_for_1_and_2016q1,act8_active_weight_for_1_and_2016q1,act9_active_weight_for_1_and_2016q1)"
puts input
puts parser.parse(input)
problem.each do |key, expression|
  expression.gsub!(/\s+/, "")
  #puts "***********************"
  #  puts " key #{key} #{expression}"
  int_tree = parser.parse_with_debug(expression)
 # puts JSON.pretty_generate(int_tree)
end
