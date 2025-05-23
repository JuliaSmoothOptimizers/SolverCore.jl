function test_stats()
  show_statuses()
  nlp = HS10()
  stats = GenericExecutionStats(nlp)
  set_status!(stats, :first_order)
  set_objective!(stats, 1.0)
  set_residuals!(stats, 0.0, 1e-12)
  set_solution!(stats, ones(2))
  set_iter!(stats, 10)
  set_solver_specific!(stats, :matvec, 10)
  set_solver_specific!(stats, :dot, 25)
  set_solver_specific!(stats, :empty_vec, [])
  broadcast_solver_specific!(stats, :empty_vec, [])
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
      nlp = BROWNDEN(T)

      stats = GenericExecutionStats(nlp)
      set_status!(stats, :first_order)
      @test stats.status == :first_order
      @test stats.status_reliable
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T

      nlp = HS14(T)

      stats = GenericExecutionStats(nlp)
      set_status!(stats, :first_order)
      @test stats.status == :first_order
      @test stats.status_reliable
      @test typeof(stats.objective) == T
      @test typeof(stats.dual_feas) == T
      @test typeof(stats.primal_feas) == T

      S = Vector{T}
      stats = GenericExecutionStats{T, S, S, Any}()
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

    stats = GenericExecutionStats{Float64, Vector{Float64}, Vector{Float64}, Any}()
    @test_throws Exception set_status!(stats, :bad)
  end

  @testset "Testing Dummy Solver with multi-precision" begin
    for T in (Float16, Float32, Float64, BigFloat)
      nlp = HS10(T)
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

      stats = GenericExecutionStats{T, Vector{T}, Vector{T}, Any}()
      SolverCore.reset!(stats, nlp)
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
    nlp = HS14(T)
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
    SolverCore.reset!(stats)
    for f ∈ fields
      val = getfield(stats, Symbol("$(f)_reliable"))
      @test val == false
    end
  end
end

test_stats()

@testset "Test get_status" begin
  nlp = BROWNDEN()
  @test get_status(nlp, optimal = true) == :first_order
  @test get_status(nlp, small_residual = true) == :small_residual
  @test get_status(nlp, infeasible = true) == :infeasible
  @test get_status(nlp, unbounded = true) == :unbounded
  @test get_status(nlp, stalled = true) == :stalled
  @test get_status(nlp, iter = 8, max_iter = 5) == :max_iter
  for i = 1:2
    increment!(nlp, :neval_obj)
  end
  @test get_status(nlp, max_eval = 1) == :max_eval
  @test get_status(nlp, elapsed_time = 60.0, max_time = 1.0) == :max_time
  @test get_status(nlp, parameter_too_large = true) == :stalled
  @test get_status(nlp, exception = true) == :exception
  @test get_status(nlp) == :unknown
end

@testset "Test get_status for NLS" begin
  nlp = BNDROSENBROCK()
  @test get_status(nlp, optimal = true) == :first_order
  @test get_status(nlp, small_residual = true) == :small_residual
  @test get_status(nlp, infeasible = true) == :infeasible
  @test get_status(nlp, unbounded = true) == :unbounded
  @test get_status(nlp, stalled = true) == :stalled
  @test get_status(nlp, iter = 8, max_iter = 5) == :max_iter
  for i = 1:2
    increment!(nlp, :neval_residual)
  end
  @test get_status(nlp, max_eval = 1) == :max_eval
  @test get_status(nlp, elapsed_time = 60.0, max_time = 1.0) == :max_time
  @test get_status(nlp, parameter_too_large = true) == :stalled
  @test get_status(nlp, exception = true) == :exception
  @test get_status(nlp) == :unknown
end
