RSpec.describe EquationsSolver do
  let(:solver) { EquationsSolver.new }

  it "solves in correct order" do
    solver.add("c", "a + b")
    solver.add("a", "10")
    solver.add("b", "10 + a")
    expect(solver.solving_order).to eq(%w[a b c])

    expect(solver.solve!).to eq("a" => 10, "b" => 20, "c" => 30)
  end
end
