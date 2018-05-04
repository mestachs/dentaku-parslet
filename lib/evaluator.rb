
IdentifierLit = Struct.new(:var_identifier, :bindings) do
  def eval
    bindings[var_identifier.str] ||= 0
  end
end

IntLit = Struct.new(:int) do
  def eval
    int.to_i
  end
end
FloatLit = Struct.new(:float) do
  def eval
    float.to_f
  end
end
Operation = Struct.new(:left, :operator, :right) do
  def eval
    op = operator.str.strip

    result = if op == "+"
               left.eval + right.eval
             elsif op == "-"
               left.eval - right.eval
             elsif op == ">"
               left.eval > right.eval
             elsif op == "<"
               left.eval < right.eval
             elsif op == "="
               left.eval == right.eval
             else
               raise "unsupported operand : #{operator} : #{left} #{operator} #{right}"
             end
    # puts "#{left.eval} #{op}  #{right.eval} => #{result}"
    result
  end
end

FunCall = Struct.new(:name, :args) do
  def eval
    values = args.map(&:eval)
    function_name = name.strip.downcase
    if function_name == "if"
      raise "expected args #{name} : #{args}" unless args.size != 2
      condition_expression = args[0]
      condition = condition_expression.eval
      condition ? args[1].eval : args[2].eval
    elsif function_name == "sum"
      values.reduce(0, :+)
    else
      raise "unsupported function call  : #{name} : #{args}"
    end
  end
end

class InfixInterpreter < Parslet::Transform
  rule(l: subtree(:l), o: simple(:o), r: subtree(:r)) do
    Operation.new(l, o, r)
  end

  rule(
    funcall: simple(:function_name),
    arglist: subtree(:arglist)
  ) do
    FunCall.new(function_name.str, arglist)
  end

  rule(var_identifier: simple(:var_identifier)) do |d|
    d[:var_identifiers]&.add(d[:var_identifier].str)
    IdentifierLit.new(d[:var_identifier], d[:doc])
  end

  rule(integer: simple(:integer)) { IntLit.new(integer) }
  rule(float: simple(:float)) { FloatLit.new(float) }
end
