

RSpec.describe "Parsor and interpretor" do
  let(:parser) { InfixExpressionParser.new }
  let(:interpreter) { InfixInterpreter.new }

  describe "solve most problems" do
    let(:solver) { EquationsSolver.new }
    let(:problem) { JSON.parse(File.read("spec/fixtures/problem.json")) }
    let(:expected_solution) { JSON.parse(File.read("spec/fixtures/solution.json")) }
    it "parse and evaluate" do
      problem.each do |key, expression|
        solver.add(key, expression)
      end
      solution = solver.solve!
      # puts JSON.pretty_generate(solution)
      expect(solution).to eq(expected_solution)
    end
  end

  describe "solve big problems" do
    let(:solver) { EquationsSolver.new }
    let(:problem) { JSON.parse(File.read("spec/fixtures/bigproblem.json")) }
    let(:expected_solution) { JSON.parse(File.read("spec/fixtures/bigsolution.json")) }
    it "parse and evaluate" do
      problem.each do |key, expression|
        solver.add(key, expression)
      end
      solution = solver.solve!
      File.open("./spec/fixtures/bigsolution.json", "w") do |f|
        f.write(solution.to_json)
      end

      # puts JSON.pretty_generate(solution)
      expect(solution).to eq(expected_solution)
    end
  end

  describe "support various equations" do
    let(:bindings) { { "bb" => 4 } }

    TESTS = [
      ["1", "bb" => 4, "result" => 1],
      ["0", "bb" => 4, "result" => 0],
      ["-1", "bb" => 4, "result" => -1],
      ["1.0", "bb" => 4, "result" => 1],
      ["1+1 ", "bb" => 4, "result" => 2],
      ["1 + 1 ", "bb" => 4, "result" => 2],
      ["(1 + 1)", "bb" => 4, "result" => 2],
      ["(1 - 1)", "bb" => 4, "result" => 0],
      ["1.0+1.0", "bb" => 4, "result" => 2],
      ["1 + 1.0 ", "bb" => 4, "result" => 2],
      ["1.0 - 1.0 ", "bb" => 4, "result" => 0],
      ["1 > 2 ", "bb" => 4, "result" => false],
      ["1 < 2 ", "bb" => 4, "result" => true],
      ["1 = 2 ", "bb" => 4, "result" => false],
      ["1 = 1 ", "bb" => 4, "result" => true],
      ["1 < 2 ", "bb" => 4, "result" => true],
      ["2< 1.5 ", "bb" => 4, "result" => false],
      ["SUM(1,1.5,3) ", "bb" => 4, "result" => 5.5],
      ["SUM(bb,cc+1.5 + 3)", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["SUM(bb,cc + 1.5+3)", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["SUM(bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["SUM( bb, cc + 1.5+3 )", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["SUM ( bb, cc + 1.5 + 3 )", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["sum ( bb, cc + 1.5 +3)", "bb" => 4, "cc" => 0, "result" => 8.5],
      ["IF (bb<5,1,4)", "bb" => 4, "result" => 1],
      ["if((bb<5) , 1 ,4)", "bb" => 4, "result" => 1],
      ["if(bb < 5,1,4)", "bb" => 4, "result" => 1],
      ["if(bb > 3,1,4)", "bb" => 4, "result" => 1],
      ["if(bb > 5,1,4)", "bb" => 4, "result" => 4],
      ["if(bb = 5,1,4)", "bb" => 4, "result" => 4],
      ["if(bb = 4,1,4)", "bb" => 4, "result" => 1],
      ["if (bb == 5,1,4)", "bb" => 4, "result" => 4],
      ["if(bb == 4,1,4)", "bb" => 4, "result" => 1],
      ["avg(1,2,5)", "bb" => 4, "result" => 2.6666666666666665],
      ["min( 1.0 ,2,5)", "bb" => 4, "result" => 1.0],
      ["max(1,2, 5 )", "bb" => 4, "result" => 5]
    ].freeze

    TESTS.each do |test|
      it "parse #{test}" do
        test_parsing(*test)
      end
    end

    def test_parsing(input, expected_binding = {})
      @logs = []
      parser = InfixExpressionParser.new
      tree = parser.parse(input.gsub(/\r\n?/, "\n"))
      log "-------------------- " + input
      log "******* PARSING "
      pp tree
      log "******* TRANSFORM"
      bindings = { "bb" => 4 }
      result   = interpreter.apply(tree, doc: bindings)
      pp result
      log "******* EVAL"
      raise "no eval methods for #{result.inspect} " unless result.respond_to?(:eval)
      eval_result = result.eval
      pp eval_result
      pp bindings
      bindings["result"] = eval_result
      log "-------"
      expect(bindings).to eq(expected_binding)
    rescue Parslet::ParseFailed => e
      puts "#{input} vs #{expected_binding} =>  #{e.class} : #{e.message}"
      puts e&.parse_failure_cause&.ascii_tree
      raise e
    rescue StandardError => e
      puts "#{input} vs #{expected_binding} =>  #{e.class} : #{e.message}"
      raise e
    end

    def pp(object)
      @logs << object.inspect
    end

    def log(message)
      @logs << message
    end
  end
end
