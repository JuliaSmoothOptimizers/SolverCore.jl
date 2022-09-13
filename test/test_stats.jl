function test_stats()
  show_statuses()
  nlp = ADNLPModel(x -> dot(x, x), zeros(2))
  stats = GenericExecutionStats(nlp)
  set_status!(stats, :first_order)
  set_objective!(stats, 1.0)
  set_residuals!(stats, 0.0, 1e-12)
  set_solution!(stats, ones(2))
  set_iter!(stats, 10)
  set_solver_specific!(stats, :matvec, 10)
  set_solver_specific!(stats, :dot, 25)
  set_solver_specific!(stats, :empty_vec, [])
  set_solver_specific!(stats, :axpy, 20)
  set_solver_specific!(stats, :ray, -1 ./ (1:100))

  show(stats)
  print(stats)
  println(stats)
  open("teststats.out", "w") do f
    println(f, stats)
  end

  println(stats, showvec = (io, x) -> print(io, x))
  open("teststats.out", "a") do f
    println(f, stats, showvec = (io, x) -> print(io, x))
  end

  line = [:status, :objective, :iter]
  for field in line
    value = statsgetfield(stats, field)
    println("$field -> $value")
  end
  println(statshead(line))
  println(statsline(stats, line))

  @testset "Testing inference" begin
    for T in (Float16, Float32, Float64, BigFloat)
      nlp = ADNLPModel(x -> dot(x, x), ones(T, 2))

      stats = GenericExecutionStats(nlp)
      set_status!(stats, :first_order)
      @test stats.status == :first_order
      @test stats.status_reliable
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T

      nlp = ADNLPModel(x -> dot(x, x), ones(T, 2), x -> [sum(x) - 1], T[0], T[0])

      stats = GenericExecutionStats(nlp)
      set_status!(stats, :first_order)
      @test stats.status == :first_order
      @test stats.status_reliable
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T
    end
  end

  @testset "Test throws" begin
    stats = GenericExecutionStats(nlp)
    @test_throws Exception set_status!(stats, :bad)
    @test_throws Exception GenericExecutionStats(:unkwown, nlp, bad = true)
  end

  @testset "Testing Dummy Solver with multi-precision" begin
    for T in (Float16, Float32, Float64, BigFloat)
      nlp = ADNLPModel(x -> dot(x, x), ones(T, 2))
      solver = DummySolver(nlp)

      stats = with_logger(NullLogger()) do
        solve!(solver, nlp)
      end
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T
      @test eltype(stats.solution) == T
      @test eltype(stats.multipliers) == T
      @test eltype(stats.multipliers_L) == T
      @test eltype(stats.multipliers_U) == T

      nlp = ADNLPModel(x -> dot(x, x), ones(T, 2), x -> [sum(x) - 1], T[0], T[0])
      solver = DummySolver(nlp)
      stats = GenericExecutionStats(nlp)

      with_logger(NullLogger()) do
        solve!(solver, nlp, stats)
      end
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T
      @test eltype(stats.solution) == T
      @test eltype(stats.multipliers) == T
      @test eltype(stats.multipliers_L) == T
      @test eltype(stats.multipliers_U) == T
    end
  end

  @testset "Test stats setters" begin
    T = Float64
    nlp = ADNLPModel(x -> dot(x, x), ones(T, 2), x -> [sum(x) - 1], T[0], T[0])
    stats = GenericExecutionStats(nlp)
    fields = (
      "status",
      "solution",
      "objective",
      "primal_residual",
      "dual_residual",
      "multipliers",
      "bounds_multipliers",
      "iter",
      "time",
      "solver_specific",
    )
    for f ∈ fields
      val = getfield(stats, Symbol("$(f)_reliable"))
      @test val == false
    end
    n = 2
    x = ones(T, n) / n
    set_status!(stats, :first_order)
    @test stats.status_reliable
    set_solution!(stats, x)
    @test stats.solution_reliable
    set_objective!(stats, obj(nlp, x))
    @test stats.objective_reliable
    set_residuals!(stats, 1.0e-3, 1.0e-4)
    @test stats.primal_residual_reliable
    @test stats.dual_residual_reliable
    set_multipliers!(stats, [2 / n], T[], T[])
    @test stats.multipliers_reliable
    @test stats.bounds_multipliers_reliable
    set_iter!(stats, 2)
    @test stats.iter_reliable
    set_time!(stats, 0.1)
    @test stats.time_reliable
    set_solver_specific!(stats, :bla, "boo!")
    @test stats.solver_specific_reliable
    reset!(stats)
    for f ∈ fields
      val = getfield(stats, Symbol("$(f)_reliable"))
      @test val == false
    end
  end
end

test_stats()
