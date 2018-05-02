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

IdentifierLit = Struct.new(:identifier, :bindings) do
  def eval  
    bindings[identifier.str]
  end
end

IntLit = Struct.new(:int) do
  def eval
    int.to_i
  end
end
Addition = Struct.new(:left, :right) do
  def eval
    left.eval + right.eval
  end
end
FunCall = Struct.new(:name, :args) do
  def eval
    
    values = args.map(&:eval)

    if name == "SUM"
      values.reduce(0, :+)
    elsif name == "puts"
      puts values.inspect
    end
  end
end

class InfixInterpreter < Parslet::Transform
  rule(
    funcall: "SUM",
    arglist: subtree(:arglist)
  ) do
    FunCall.new("SUM", arglist)
  end

  rule(integer: simple(:integer)) { IntLit.new(integer) }
  rule(identifier: simple(:identifier)) do |d|
    IdentifierLit.new(d[:identifier], d[:doc])
  end  
end

tree = parser.parse("SUM(bb,bb)")
puts "******* PARSING"
pp tree
bindings = { "bb" => 2}
result   = InfixInterpreter.new.apply(tree, doc: bindings)
puts "******* TRANSFORM"
pp result
puts "******* EVAL"

pp result.eval
pp bindings
