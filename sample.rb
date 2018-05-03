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
problem.each do |_key, expression|
  expression.gsub!(/\s+/, "")
  # puts "***********************"
  #  puts " key #{key} #{expression}"
  # int_tree = parser.parse_with_debug(expression)
  # puts JSON.pretty_generate(int_tree)
end

def test_parsing(input, expected_binding = {})
  parser = InfixExpressionParser.new
  tree = parser.parse_with_debug(input)
  puts "-------------------- " + input
  puts "******* PARSING "
  pp tree
  bindings = { "bb" => 4 }
  result   = InfixInterpreter.new.apply(tree, doc: bindings)
  puts "******* TRANSFORM"
  pp result
  puts "******* EVAL"
  eval_result = result.eval
  pp eval_result
  pp bindings
  bindings["result"] = eval_result
  if bindings != expected_binding
    puts "WARNNNNNNNNNN : got #{bindings} but expected #{expected_binding}"
    raise "failure"
  else
    puts "OK"
  end
  puts "-------"
end

test_parsing("SUM(bb,cc+1.5 + 3)", "bb" => 4, "cc" => 0, "result" => 8.5)
test_parsing("SUM(bb,cc + 1.5+3)", "bb" => 4, "cc" => 0, "result" => 8.5)
test_parsing("SUM(bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
test_parsing("SUM( bb, cc + 1.5+3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
test_parsing("SUM ( bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
test_parsing("sum ( bb, cc + 1.5 +3)", "bb" => 4, "cc" => 0, "result" => 8.5)


test_parsing("if(bb < 5,1,4)", "bb" => 4, "result" => 1)
test_parsing("if(bb > 3,1,4)", "bb" => 4, "result" => 1)
test_parsing("if(bb > 5,1,4)", "bb" => 4, "result" => 4)
test_parsing("if(bb = 5,1,4)", "bb" => 4, "result" => 4)
test_parsing("if(bb = 4,1,4)", "bb" => 4, "result" => 1)
