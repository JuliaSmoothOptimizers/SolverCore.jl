# This package
using SolverCore

# Auxiliary packages
using ADNLPModels, NLPModels

# stdlib
using LinearAlgebra, Logging, Test


if VERSION ≥ v"1.6"
  @testset "Test allocations of solver specific" begin
    nlp = ADNLPModel(x -> sum(x), ones(2))
    stats = GenericExecutionStats(nlp) # stats = GenericExecutionStats(nlp, solver_specific = Dict{Symbol, Bool}())
    function fake_solver(stats)
      set_solver_specific!(stats, :test, true)
      return stats
    end
    @allocated fake_solver(stats)
    a = @allocated fake_solver(stats)
    @test a == 0
  end
end

include("test_logging.jl")
include("test_stats.jl")
include("test_callback.jl")
include("test_restart.jl")
