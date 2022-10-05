@testset "test restart" begin
  nlp = ADNLPModel(x -> dot(x, x) / 2, ones(2), x -> [sum(x .^ 3) - 1], [0.0], [0.0])
  solver = DummySolver(nlp)
  stats = GenericExecutionStats(nlp)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
  # Try with a new intial guess
  nlp.meta.x0 .= 0.2
  reset!(solver)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
  # Try with a new problem of the same size
  nlp = ADNLPModel(x -> dot(x, x) / 2, ones(2), x -> [sum(x .^ 3)], [0.0], [0.0])
  reset!(solver, nlp)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
end
