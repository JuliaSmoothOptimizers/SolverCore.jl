export AbstractExecutionStats,
  GenericExecutionStats,
  set_status!,
  get_status,
  set_solution!,
  set_objective!,
  set_residuals!,
  set_primal_residual!,
  set_dual_residual!,
  set_multipliers!,
  set_constraint_multipliers!,
  set_bounds_multipliers!,
  set_iter!,
  set_step_status!,
  set_time!,
  broadcast_solver_specific!,
  set_solver_specific!,
  statsgetfield,
  statshead,
  statsline,
  getStatus,
  show_statuses

const STATUSES = Dict(
  :exception => "unhandled exception",
  :first_order => "first-order stationary",
  :acceptable => "solved to within acceptable tolerances",
  :infeasible => "problem may be infeasible",
  :max_eval => "maximum number of function evaluations",
  :max_iter => "maximum iteration",
  :max_time => "maximum elapsed time",
  :neg_pred => "negative predicted reduction",
  :not_desc => "not a descent direction",
  :small_residual => "small residual",
  :small_step => "step too small",
  :stalled => "stalled",
  :unbounded => "objective function may be unbounded from below",
  :prox_unbounded => "the regularizer is not prox bounded",
  :unknown => "unknown",
  :user => "user-requested stop",
)

function check_status(status::Symbol)
  if !(status in keys(STATUSES))
    @error "status $status is not a valid status. Use one of the following: " join(
      keys(STATUSES),
      ", ",
    )
    throw(KeyError(status))
  end
end

"""
    show_statuses()

Show the list of available statuses to use with `GenericExecutionStats`.
"""
function show_statuses()
  println("STATUSES:")
  for k in keys(STATUSES) |> collect |> sort
    v = STATUSES[k]
    @printf("  :%-14s => %s\n", k, v)
  end
end

const STEP_STATUSES =
  Dict(:unknown => "unknown", :accepted => "step accepted", :rejected => "step rejected")

function check_step_status(step_status::Symbol)
  if !(step_status in keys(STEP_STATUSES))
    @error "step_status $step_status is not a valid step status. Use one of the following: " join(
      keys(STEP_STATUSES),
      ", ",
    )
    throw(KeyError(step_status))
  end
end

"""
    show_step_statuses()

Show the list of available step statuses to use with `GenericExecutionStats`.
"""
function show_step_statuses()
  println("STEP_STATUSES:")
  for k in keys(STEP_STATUSES) |> collect |> sort
    v = STEP_STATUSES[k]
    @printf("  :%-10s => %s\n", k, v)
  end
end

abstract type AbstractExecutionStats end

"""
    GenericExecutionStats(nlp; ...)
    GenericExecutionStats{T, S, V, Tsp}(;...)

A GenericExecutionStats is a struct for storing the output information of solvers.
It contains the following fields:
- `status`: Indicates the output of the solver. Use `show_statuses()` for the full list;
- `solution`: The final approximation returned by the solver (default: an uninitialized vector like `nlp.meta.x0`);
- `objective`: The objective value at `solution` (default: `Inf`);
- `dual_feas`: The dual feasibility norm at `solution` (default: `Inf`);
- `primal_feas`: The primal feasibility norm at `solution` (default: `0.0` if unconstrained, `Inf` otherwise);
- `multipliers`: The Lagrange multipliers wrt to the constraints (default: an uninitialized vector like `nlp.meta.y0`);
- `multipliers_L`: The Lagrange multipliers wrt to the lower bounds on the variables (default: an uninitialized vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `multipliers_U`: The Lagrange multipliers wrt to the upper bounds on the variables (default: an uninitialized vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `iter`: The number of iterations computed by the solver (default: `-1`);
- `step_status`: The status of the most recently computed step (`:unknown`, `:accepted` or `:rejected`);
- `elapsed_time`: The elapsed time computed by the solver (default: `Inf`);
- `solver_specific::Dict{Symbol,Any}`: A solver specific dictionary.

The constructor preallocates storage for the fields above.
Special storage may be used for `multipliers_L` and `multipliers_U` by passing them to the constructor.
For instance, if a problem has few bound constraints, those multipliers could be held in sparse vectors.

The following fields indicate whether the information above has been updated and is reliable:

- `solution_reliable`
- `objective_reliable`
- `residuals_reliable` (for `dual_feas` and `primal_feas`)
- `multipliers_reliable` (for `multipliers`)
- `bounds_multipliers_reliable` (for `multipliers_L` and `multipliers_U`)
- `iter_reliable`
- `step_status_reliable`
- `time_reliable`
- `solver_specific_reliable`.

Setting fields using one of the methods `set_solution!()`, `set_objective!()`, etc., also marks
the field value as reliable.

The `reset!()` method marks all fields as unreliable.

`nlp` is highly recommended to set default optional fields.
If it is not provided, the function `reset!(stats, nlp)` should be called before `solve!`.

All other variables can be input as keyword arguments.

Notice that `GenericExecutionStats` does not compute anything, it simply stores.
"""
mutable struct GenericExecutionStats{T, S, V, Tsp} <: AbstractExecutionStats
  status_reliable::Bool
  status::Symbol
  solution_reliable::Bool
  solution::S # x
  objective_reliable::Bool
  objective::T # f(x)
  dual_residual_reliable::Bool
  dual_feas::T # ‖∇f(x)‖₂ for unc, ‖P[x - ∇f(x)] - x‖₂ for bnd, etc.
  primal_residual_reliable::Bool
  primal_feas::T # ‖c(x)‖ for equalities
  multipliers_reliable::Bool
  multipliers::S # y
  bounds_multipliers_reliable::Bool
  multipliers_L::V # zL
  multipliers_U::V # zU
  iter_reliable::Bool
  iter::Int
  step_status_reliable::Bool
  step_status::Symbol
  time_reliable::Bool
  elapsed_time::Float64
  solver_specific_reliable::Bool
  solver_specific::Dict{Symbol, Tsp}
end

function GenericExecutionStats{T, S, V, Tsp}(;
  status::Symbol = :unknown,
  solution::S = S(),
  objective::T = T(Inf),
  dual_feas::T = T(Inf),
  primal_feas::T = T(Inf),
  multipliers::S = S(),
  multipliers_L::V = V(),
  multipliers_U::V = V(),
  iter::Int = -1,
  step_status::Symbol = :unknown,
  elapsed_time::Real = Inf,
  solver_specific::Dict{Symbol, Tsp} = Dict{Symbol, Any}(),
) where {T, S, V, Tsp}
  return GenericExecutionStats{T, S, V, Tsp}(
    false,
    status,
    false,
    solution,
    false,
    objective,
    false,
    dual_feas,
    false,
    primal_feas,
    false,
    multipliers,
    false,
    multipliers_L,
    multipliers_U,
    false,
    iter,
    false,
    step_status,
    false,
    elapsed_time,
    false,
    solver_specific,
  )
end

"""
    reset!(stats::GenericExecutionStats)
    reset!(stats::GenericExecutionStats, problem)

Reset the internal flags of `stats` to `false` to Indicate
that the contents should not be trusted.
"""
function reset!(stats::GenericExecutionStats{T, S, V, Tsp}) where {T, S, V, Tsp}
  stats.status_reliable = false
  stats.solution_reliable = false
  stats.objective_reliable = false
  stats.primal_residual_reliable = false
  stats.dual_residual_reliable = false
  stats.multipliers_reliable = false
  stats.bounds_multipliers_reliable = false
  stats.iter_reliable = false
  stats.step_status_reliable = false
  stats.time_reliable = false
  stats.solver_specific_reliable = false
  stats
end

function reset!(stats::GenericExecutionStats, problem::Any)
  return reset!(stats)
end

"""
    set_status!(stats::GenericExecutionStats, status::Symbol)

Register `status` as final status in `stats` and mark it as reliable.
"""
function set_status!(stats::GenericExecutionStats, status::Symbol)
  check_status(status)
  stats.status = status
  stats.status_reliable = true
  stats
end

"""
    set_solution!(stats::GenericExecutionStats, x::AbstractVector)

Register `x` as optimal solution in `stats` and mark it as reliable.
"""
function set_solution!(stats::GenericExecutionStats, x::AbstractVector)
  stats.solution .= x
  stats.solution_reliable = true
  stats
end

"""
    set_objective!(stats::GenericExecutionStats{T, S, V}, val::T)

Register `val` as optimal objective value in `stats` and mark it as reliable.
"""
function set_objective!(stats::GenericExecutionStats{T, S, V}, val::T) where {T, S, V}
  stats.objective = val
  stats.objective_reliable = true
  stats
end

"""
    set_residuals!(stats::GenericExecutionStats{T, S, V}, primal::T, dual::T)

Register `primal` and `dual` as optimal primal and dual feasibility residuals,
respectively, in `stats` and mark them as reliable.
"""
function set_residuals!(stats::GenericExecutionStats{T, S, V}, primal::T, dual::T) where {T, S, V}
  set_primal_residual!(stats, primal)
  set_dual_residual!(stats, dual)
  stats
end

"""
    set_primal_residual!(stats::GenericExecutionStats{T, S, V}, primal::T)

Register `primal` as optimal primal residuals in `stats` and mark it as reliable.
"""
function set_primal_residual!(stats::GenericExecutionStats{T, S, V}, primal::T) where {T, S, V}
  stats.primal_feas = primal
  stats.primal_residual_reliable = true
  stats
end

"""
    set_dual_residual!(stats::GenericExecutionStats{T, S, V}, dual::T)

Register `dual` as optimal dual feasibility residuals in `stats` and mark it as reliable.
"""
function set_dual_residual!(stats::GenericExecutionStats{T, S, V}, dual::T) where {T, S, V}
  stats.dual_feas = dual
  stats.dual_residual_reliable = true
  stats
end

"""
    set_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V)

Register `y`, `zL` and `zU` as optimal multipliers associated to general constraints,
lower-bounded and upper-bounded constraints, respectively, in `stats` and mark them as reliable.
"""
function set_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V) where {T, S, V}
  set_bounds_multipliers!(stats, zL, zU)
  set_constraint_multipliers!(stats, y)
  stats
end

"""
    set_bounds_multipliers!(stats::GenericExecutionStats{T, S, V}, zL::V, zU::V)

Register `zL` and `zU` as optimal multipliers associated to lower-bounded and upper-bounded constraints, respectively, in `stats` and mark them as reliable.
"""
function set_bounds_multipliers!(
  stats::GenericExecutionStats{T, S, V},
  zL::V,
  zU::V,
) where {T, S, V}
  stats.multipliers_L .= zL
  stats.multipliers_U .= zU
  stats.bounds_multipliers_reliable = true
  stats
end

"""
    set_constraint_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V)

Register `y` as optimal multipliers associated to general constraints in `stats` and mark them as reliable.
"""
function set_constraint_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S) where {T, S, V}
  stats.multipliers .= y
  stats.multipliers_reliable = true
  stats
end

"""
    set_iter!(stats::GenericExecutionStats, iter::Int)

Register `iter` as optimal iteration number in `stats` and mark it as reliable.
"""
function set_iter!(stats::GenericExecutionStats, iter::Int)
  stats.iter = iter
  stats.iter_reliable = true
  stats
end

"""
    set_step_status!(stats::GenericExecutionStats, step_status::Symbol)

Register `step_status` as most recent step status in `stats` and mark it as reliable.
"""
function set_step_status!(stats::GenericExecutionStats, step_status::Symbol)
  check_step_status(step_status)
  stats.step_status = step_status
  stats.step_status_reliable = true
  stats
end

"""
    set_time!(stats::GenericExecutionStats, time::Float64)

Register `time` as optimal solution time in `stats` and mark it as reliable.
"""
function set_time!(stats::GenericExecutionStats, time::Float64)
  stats.elapsed_time = time
  stats.time_reliable = true
  stats
end

"""
    broadcast_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)

Broadcast `value` as a solver-specific value identified by `field` in `stats`
and mark it as reliable.
"""
function broadcast_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)
  if field ∈ keys(stats.solver_specific)
    stats.solver_specific[field] .= value
  end
  stats.solver_specific_reliable = true
  stats
end

"""
    set_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)

Register `value` as a solver-specific value identified by `field` in `stats`
and mark it as reliable.
"""
function set_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)
  stats.solver_specific[field] = value
  stats.solver_specific_reliable = true
  stats
end

import Base.show, Base.print, Base.println

function show(io::IO, stats::AbstractExecutionStats)
  show(io, "Execution stats: $(getStatus(stats))")
end

# TODO: Expose NLPModels dsp in nlp_types.jl function print
function disp_vector(io::IO, x::AbstractArray)
  if length(x) == 0
    print(io, "∅")
  elseif length(x) <= 5
    Base.show_delim_array(io, x, "[", " ", "]", false)
  else
    Base.show_delim_array(io, x[1:4], "[", " ", "", false)
    print(io, " ⋯ $(x[end])]")
  end
end

function print(io::IO, stats::GenericExecutionStats; showvec::Function = disp_vector)
  # TODO: Show evaluations
  println(io, "Generic Execution stats")
  println(io, "  status: " * getStatus(stats))
  println(io, "  objective value: ", stats.objective)
  println(io, "  primal feasibility: ", stats.primal_feas)
  println(io, "  dual feasibility: ", stats.dual_feas)
  print(io, "  solution: ")
  showvec(io, stats.solution)
  println(io, "")
  length(stats.multipliers) > 0 &&
    (print(io, "  multipliers: "); showvec(io, stats.multipliers); println(io, ""))
  length(stats.multipliers_L) > 0 &&
    (print(io, "  multipliers_L: "); showvec(io, stats.multipliers_L); println(io, ""))
  length(stats.multipliers_U) > 0 &&
    (print(io, "  multipliers_U: "); showvec(io, stats.multipliers_U); println(io, ""))
  println(io, "  iterations: ", stats.iter)
  println(io, "  elapsed time: ", stats.elapsed_time)
  if length(stats.solver_specific) > 0
    println(io, "  solver specific:")
    for (k, v) in stats.solver_specific
      @printf(io, "    %s: ", k)
      if v isa Vector
        showvec(io, v)
      else
        show(io, v)
      end
      println(io, "")
    end
  end
end
print(stats::GenericExecutionStats; showvec::Function = disp_vector) =
  print(Base.stdout, stats, showvec = showvec)
println(io::IO, stats::GenericExecutionStats; showvec::Function = disp_vector) =
  print(io, stats, showvec = showvec)
println(stats::GenericExecutionStats; showvec::Function = disp_vector) =
  print(Base.stdout, stats, showvec = showvec)

const headsym = Dict(
  :status => "  Status",
  :iter => "   Iter",
  :neval_obj => "   #obj",
  :neval_grad => "  #grad",
  :neval_cons => "  #cons",
  :neval_jcon => "  #jcon",
  :neval_jgrad => " #jgrad",
  :neval_jac => "   #jac",
  :neval_jprod => " #jprod",
  :neval_jtprod => "#jtprod",
  :neval_hess => "  #hess",
  :neval_hprod => " #hprod",
  :neval_jhprod => "#jhprod",
  :objective => "              f",
  :dual_feas => "           ‖∇f‖",
  :elapsed_time => "  Elaspsed time",
)

function statsgetfield(stats::AbstractExecutionStats, name::Symbol)
  t = Int
  if name == :status
    v = getStatus(stats)
    t = String
  elseif name == :step_status
    v = getStepStatus(stats)
    t = String
  elseif name in fieldnames(typeof(stats))
    v = getfield(stats, name)
    t = fieldtype(typeof(stats), name)
  else
    error("Unknown field $name")
  end
  if t <: Int
    @sprintf("%7d", v)
  elseif t <: Real
    @sprintf("%15.8e", v)
  else
    @sprintf("%8s", v)
  end
end

function statshead(line::Array{Symbol})
  return join([headsym[x] for x in line], "  ")
end

function statsline(stats::AbstractExecutionStats, line::Array{Symbol})
  return join([statsgetfield(stats, x) for x in line], "  ")
end

function getStatus(stats::AbstractExecutionStats)
  return STATUSES[stats.status]
end

function getStepStatus(stats::AbstractExecutionStats)
  return STEP_STATUSES[stats.step_status]
end

"""
    get_status(problem, kwargs...)

Return the output of the solver based on the information in the keyword arguments.
Use `show_statuses()` for the full list.

The keyword arguments may contain:
- `elapsed_time::Float64 = 0.0`: current elapsed time (default: `0.0`);
- `iter::Integer = 0`: current number of iterations (default: `0`);
- `optimal::Bool = false`: `true` if the problem reached an optimal solution (default: `false`);
- `small_residual::Bool = false`: `true` if the nonlinear least squares problem reached a solution with small residual (default: `false`);
- `infeasible::Bool = false`: `true` if the problem is infeasible (default: `false`);
- `prox_unbounded::Bool = false`: `true` if the regularizer is not prox bounded (default: `false`);
- `parameter_too_large::Bool = false`: `true` if the parameters are loo large (default: `false`);
- `unbounded::Bool = false`: `true` if the problem is unbounded (default: `false`);
- `stalled::Bool = false`: `true` if the algorithm is stalling (default: `false`);
- `max_eval::Integer`: limit on the number of evaluations defined by `eval_fun` (default: `typemax(Int)`);
- `max_time::Float64 = Inf`: limit on the time (default: `Inf`);
- `max_iter::Integer`: limit on the number of iterations (default: `typemax(Int)`).

The `problem` is used to check number of evaluations with SolverCore.eval_fun(problem).
"""
function get_status(
  nlp;
  elapsed_time::Float64 = 0.0,
  iter::Integer = 0,
  optimal::Bool = false,
  small_residual::Bool = false,
  infeasible::Bool = false,
  prox_unbounded = false,
  parameter_too_large::Bool = false,
  unbounded::Bool = false,
  stalled::Bool = false,
  exception::Bool = false,
  max_eval::Integer = typemax(Int),
  max_time::Float64 = Inf,
  max_iter::Integer = typemax(Int),
)
  if optimal
    :first_order
  elseif small_residual
    :small_residual
  elseif infeasible
    :infeasible
  elseif unbounded
    :unbounded
  elseif stalled
    :stalled
  elseif iter > max_iter ≥ 0
    :max_iter
  elseif eval_fun(nlp) > max_eval ≥ 0
    :max_eval
  elseif elapsed_time > max_time
    :max_time
  elseif parameter_too_large
    :stalled
  elseif prox_unbounded
    :prox_unbounded
  elseif exception
    :exception
  else
    :unknown
  end
end
eval_fun(::Any) = typemax(Int)
