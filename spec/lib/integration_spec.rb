

RSpec.describe "Parsor and interpretor" do
  let(:parser) { InfixExpressionParser.new }
  let(:interpreter) { InfixInterpreter.new }

  describe "support most problems" do
    let(:problem) { JSON.parse(File.read("problem.json")) }
    let(:bindings) { {} }

    it "parse and evaluate" do
      problem.each do |_key, expression|
        expression.gsub!(/\s+/, "")
        tree = parser.parse_with_debug(expression)
        interpreter.apply(tree, doc: bindings)
        # puts JSON.pretty_generate(int_tree)
      end
    end
  end

  describe "support spacing" do
    let(:bindings) { { "bb" => 4 } }

    it "" do
      test_parsing("SUM(bb,cc+1.5 + 3)", "bb" => 4, "cc" => 0, "result" => 8.5)
      test_parsing("SUM(bb,cc + 1.5+3)", "bb" => 4, "cc" => 0, "result" => 8.5)
      test_parsing("SUM(bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
      test_parsing("SUM( bb, cc + 1.5+3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
      test_parsing("SUM ( bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5)
      test_parsing("sum ( bb, cc + 1.5 +3)", "bb" => 4, "cc" => 0, "result" => 8.5)
    end

    it "works on if and comparison" do
      test_parsing("if(bb < 5,1,4)", "bb" => 4, "result" => 1)
      test_parsing("if(bb > 3,1,4)", "bb" => 4, "result" => 1)
      test_parsing("if(bb > 5,1,4)", "bb" => 4, "result" => 4)
      test_parsing("if(bb = 5,1,4)", "bb" => 4, "result" => 4)
      test_parsing("if(bb = 4,1,4)", "bb" => 4, "result" => 1)
    end

    def test_parsing(input, expected_binding = {})
      @logs = []
      parser = InfixExpressionParser.new
      tree = parser.parse_with_debug(input)
      log "-------------------- " + input
      log "******* PARSING "
      pp tree
      log "******* TRANSFORM"
      bindings = { "bb" => 4 }
      result   = interpreter.apply(tree, doc: bindings)
      pp result
      log "******* EVAL"
      eval_result = result.eval
      pp eval_result
      pp bindings
      bindings["result"] = eval_result
      log "-------"
      expect(bindings).to eq(expected_binding)
    end

    def pp(object)
      @logs << object.inspect
    end

    def log(message)
      @logs << message
    end
  end
end
