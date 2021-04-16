@testset "Output" begin
  mutable struct SimpleOutput{T} <: AbstractSolverOutput{T}
    status::Symbol
    solution
  end

  output = SimpleOutput{Float64}(:unknown, 0.0)

  @testset "Show" begin
    io = IOBuffer()
    print(io, output)
    @test String(take!(io)) == "Solver output of type SimpleOutput{Float64}\nStatus: unknown\n"
  end
end
