@testset "Root-finding full example" begin
  # Problem
  """
      RootFindingProblem

  Struct for problem ``f(x) = 0``.
  """
  mutable struct RootFindingProblem{T}
    f
    x₀::T
    evals::Int
  end
  RootFindingProblem(f, x₀::T) where {T} = RootFindingProblem{T}(f, x₀, 0)
  function (rfp::RootFindingProblem)(x)
    rfp.evals += 1
    rfp.f(x)
  end
  function SolverCore.reset_problem!(rfp::RootFindingProblem{T}) where {T}
    rfp.evals = 0
  end

  # Output
  mutable struct RFPOutput{T} <: AbstractSolverOutput{T, T}
    status::Symbol
    solution::T
    fx::T
    evals::Int
    elapsed_time::Float64
  end
  function RFPOutput(
    status::Symbol,
    x::T;
    fx::T = T(Inf),
    evals::Int = -1,
    elapsed_time::Float64 = Inf,
  ) where {T}
    RFPOutput{T}(status, x, fx, evals, elapsed_time)
  end

  # Solver
  mutable struct Bissection{T} <: AbstractSolver{T, T}
    initialized::Bool
    params::Dict
    workspace
  end

  SolverCore.solver_output_type(::Type{Bissection{T}}) where T = RFPOutput{T}

  function Bissection{T}(
    rfp::RootFindingProblem{T};
    θ = one(T) / 2,
    δ = one(T),
    explorer = true,
    explorer_tries = 3,
  ) where {T}
    Bissection{T}(true, Dict(:θ => θ, :δ => δ, :explorer => true, :explorer_tries => 3), [])
  end

  Bissection(rfp::RootFindingProblem{T}; kwargs...) where {T} = Bissection{T}(rfp; kwargs...)

  SolverCore.parameters(::Type{Bissection{T}}) where {T} = (
    θ = (default = one(T) / 2, type = T, scale = :linear, min = T(0.1), max = T(0.9)),
    δ = (default = one(T), type = T, scale = :log, min = √eps(T), max = T(10)),
    explorer = (default = true, type = Bool),
    explorer_tries = (default = 3, type = Int, min = 1, max = 3),
  )
  function SolverCore.are_valid_parameters(::Type{Bissection{T}}, θ, δ, _, _2) where {T}
    return (0 ≤ θ ≤ 1) && δ > 0
  end

  function SolverCore.solve!(
    solver::Bissection,
    f::RootFindingProblem;
    atol = 1e-3,
    rtol = 1e-3,
    kwargs...,
  )
    for (k, v) in kwargs
      solver.params[k] = v
    end

    θ = solver.params[:θ]
    δ = solver.params[:δ]
    explorer = solver.params[:explorer]
    explorer_tries = solver.params[:explorer_tries]
    a, b = f.x₀ - δ, f.x₀ + δ
    t₀ = time()

    fa, fb = f(a), f(b)
    ϵ = atol + rtol * (abs(fa) + abs(fb)) / 2
    solved = false
    if abs(fa) < ϵ
      return RFPOutput(:acceptable, a, evals = f.evals, fx = fa, elapsed_time = time() - t₀)
    elseif abs(fb) < ϵ
      return RFPOutput(:acceptable, b, evals = f.evals, fx = fb, elapsed_time = time() - t₀)
    elseif fa * fb > 0
      error("Increasing coverage")
    end
    x = a * θ + b * (1 - θ)
    fx = f(x)
    while abs(fx) ≥ ϵ && f.evals < 100
      (a, b, fa, fb) = fa * fx < 0 ? (a, x, fa, fx) : (x, b, fx, fb)
      x = a * θ + b * (1 - θ)
      fx = f(x)
      if explorer
        for k = 1:explorer_tries
          r = rand()
          xt = a * r + b * (1 - r)
          ft = f(xt)
          if abs(ft) < abs(fx)
            x, fx = xt, ft
          end
        end
      end
    end
    status = :unknown
    if abs(fx) < ϵ
      status = :acceptable
    elseif f.evals ≥ 100
      status = :max_eval
    end
    return RFPOutput(status, x, evals = f.evals, fx = fx, elapsed_time = time() - t₀)
  end

  # Testing
  rfp_problems = [
    RootFindingProblem(x -> x - π, 3.0),
    RootFindingProblem(x -> x^3 - 2, 1.0),
    RootFindingProblem(x -> x * exp(x) - 1, 1.0),
    RootFindingProblem(x -> x / (1 + x^2) - 0.5, 0.0),
    RootFindingProblem(x -> 1 / (1 + exp(-x)) - 0.5, 1.0),
  ]

  for f in rfp_problems
    solver = Bissection(f)
    output = solve!(solver, f)
    @test abs(output.fx) < 1e-2

    solver = Bissection(f, θ = 0.1)
    output = solve!(solver, f)
    @test abs(output.fx) < 1e-2
  end

  for T in [Float16, Float32, Float64, BigFloat]
    @test solver_output_type(Bissection{T}) == RFPOutput{T}
    f = RootFindingProblem(x -> x, one(T))
    solver = Bissection(f)
    @test solver_output_type(solver) == RFPOutput{T}
  end

  # Tuning
  Random.seed!(0)
  grid = with_logger(NullLogger()) do
    grid_search_tune(
      Bissection,
      rfp_problems,
      success = o -> o.status == :acceptable,
      costs = [(o -> o.elapsed_time, 100.0), (o -> o.evals, 100)],
      grid_length = 9,
      δ = 10.0 .^ (-5:1),
    )
  end
  best = sort(grid[:], by = x -> x[2][2])[1][1]
  @test best[1] ≈ 0.3
  @test best[2] ≈ 1
  @test !best[3]
  @test best[4] == 1
end
