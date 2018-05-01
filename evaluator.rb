
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
    byebug
    values = args.map(&:eval)

    if name == "sum"
      values.reduce(0, :+)
    elsif name == "puts"
      puts values.inspect
    end
  end
end


class MiniT < Parslet::Transform
  rule(int: simple(:int)) { IntLit.new(int) }
  rule(
    left:  simple(:left),
    right: simple(:right),
    op:    "+"
  ) { Addition.new(left, right) }
  rule(
    funcall: "puts",
    arglist: subtree(:arglist)
  ) { FunCall.new("puts", arglist) }
  rule(
    funcall: "sum",
    arglist: subtree(:arglist)
  ) { FunCall.new("sum", arglist) }
end
