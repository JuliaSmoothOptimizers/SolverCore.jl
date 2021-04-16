@testset "Solver" begin
  mutable struct NoSolver{T, S} <: AbstractSolver{T, S} end
  solver = NoSolver{Float64, Vector{Float64}}()

  @testset "Show" begin
    io = IOBuffer()
    print(io, solver)
    @test String(take!(io)) == "Solver NoSolver{Float64, Vector{Float64}}\n"
  end

  @testset "solve! not implemented" begin
    @test_throws MethodError solve!(solver, 0)
  end

  @testset "Parameters" begin
    SolverCore.parameters(::Type{NoSolver{T, S}}) where {T, S} =
      (Ω = (default = zero(T), type = T, scale = :real, min = -one(T), max = one(T)))
    P = parameters(NoSolver{Float64, Vector{Float64}})
    @test P == parameters(NoSolver)
    @test P == parameters(solver)

    SolverCore.are_valid_parameters(::Type{NoSolver{T, S}}, Ω) where {T, S} = (-1 ≤ Ω ≤ 1)
    @test are_valid_parameters(NoSolver, 1)
    @test are_valid_parameters(solver, 1)
    @test are_valid_parameters(solver, 0)
    @test are_valid_parameters(solver, -1)
    @test !are_valid_parameters(solver, -2)
  end

  @testset "Traits" begin
    @test problem_types_handled(NoSolver) == []
    SolverCore.problem_types_handled(::Type{NoSolver}) = [:none]
    @test problem_types_handled(NoSolver) == [:none]
    @test can_solve_type(NoSolver, :none)
    @test !can_solve_type(NoSolver, :other)
  end
end
