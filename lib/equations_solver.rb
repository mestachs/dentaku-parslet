class EquationsSolver
  include TSort

  Equation = Struct.new(:name, :evaluable, :dependencies)
  EMPTY_DEPENDENCIES = [].freeze
  FakeEvaluable = Struct.new(:eval)

  def initialize
    @parser = InfixExpressionParser.new
    @interpreter = InfixInterpreter.new
    @equations = {}
    @bindings = {}
  end

  alias solving_order tsort

  def add(name, expression)
    if expression.is_a?(Numeric)
      @equations[name] = Equation.new(
        name,
        FakeEvaluable.new(expression),
        EMPTY_DEPENDENCIES
      )
    else
      ast_tree = @parser.parse(expression)
      var_identifiers = Set.new
      interpretation = @interpreter.apply(
        ast_tree,
        doc:             @bindings,
        var_identifiers: var_identifiers
      )
      @equations[name] = Equation.new(name, interpretation, var_identifiers)
    end
  end

  def solve!
    solving_order.each do |name|
      equation = @equations[name]
      @bindings[equation.name] = equation.evaluable.eval
    end
    solution = @bindings.dup
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
