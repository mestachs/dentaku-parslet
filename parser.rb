class InfixExpressionParser < Parslet::Parser
  def cts(atom)
    atom >> space.repeat
  end

  root(:expression)

  rule(:lparen)     { str("(") >> space? }
  rule(:rparen)     { str(")") >> space? }
  rule(:comma)      { str(",") >> space? }

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:multiplicative_op) { cts match["*/"] }
  rule(:additive_op) { cts match["+-"] }
  rule(:comparison_op) { cts match["<>="] }
  rule(:digit) { match["0-9"] }
  rule(:integer) do
    cts((str("-").maybe >> match["1-9"] >> digit.repeat).as(:integer) | str("0").as(:integer))
  end

  rule(:float) do
    cts((str("-").maybe >> digit.repeat(1) >> str(".") >> digit.repeat(1)).as(:float))
  end

  rule(:identifier) do
    cts((match["a-zA-Z"] >> match["a-zA-Z0-9_"].repeat).as(:indentifier))
  end

  rule(:factor) do
    funcall | identifier | float | integer
  end

  rule(:arglist) do
    expression >> (comma >> expression).repeat
  end

  rule(:funcall) do
    identifier.as(:funcall) >> str(" ").maybe >> lparen >> arglist.as(:arglist) >> rparen
  end

  rule(:expression) do
    infix_expression(factor,
                     [multiplicative_op, 2, :left],
                     [additive_op, 1, :right],
                     [comparison_op, 2, :left])
  end
end
