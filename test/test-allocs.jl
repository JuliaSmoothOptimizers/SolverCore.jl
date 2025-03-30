@testset "Test allocations of solver specific" begin
  nlp = BROWNDEN()
  stats = GenericExecutionStats(nlp) # stats = GenericExecutionStats(nlp, solver_specific = Dict{Symbol, Bool}())
  function fake_solver(stats)
    set_solver_specific!(stats, :test, true)
    return stats
  end
  @allocated fake_solver(stats)
  a = @allocated fake_solver(stats)
  @test a == 0
end
