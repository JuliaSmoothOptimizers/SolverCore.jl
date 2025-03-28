@testset "test restart" begin
  nlp = HS10()
  solver = SolverCore.DummySolver(nlp)
  stats = GenericExecutionStats(nlp)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
  # Try with a new intial guess
  nlp.meta.x0 .= 0.2
  reset!(solver, nlp)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
  # Try with a new problem of the same size
  nlp = HS10()
  reset!(solver, nlp)
  solve!(solver, nlp, stats, verbose = false)
  @test stats.status == :first_order
end
