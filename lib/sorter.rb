require "tsort"

class EquationsSolver
  include TSort

  Equation = Struct.new(:name, :expression, :ast, :evaluable, :dependencies) do
  end

  def initialize
    @parser = InfixExpressionParser.new
    @interpreter = InfixInterpreter.new
    @equations = {}
    @bindings ={}
  end

  alias solving_order tsort

  def add(name, expression)
    ast_tree = @parser.parse(expression)
    var_identifiers = Set.new
    interpretation = @interpreter.apply(ast_tree, doc: @bindings, var_identifiers: var_identifiers)
    @equations[name] = Equation.new(name, expression, ast_tree, interpretation, var_identifiers)
  end

  def solve!
    solution = solving_order.each_with_object({}) do |name, hash|
        equation = @equations[name]
        hash[equation.name] = equation.evaluable.eval
        @bindings[equation.name] = hash[equation.name]
    end
    @bindings.clear
    solution
  end

  def tsort_each_node(&block)
    @equations.each_key(&block)
  end

  def tsort_each_child(node, &block)
    @equations[node].dependencies.each(&block)
  end
end
