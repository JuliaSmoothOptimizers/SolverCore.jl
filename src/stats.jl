export AbstractExecutionStats,
  GenericExecutionStats,
  set_solution!,
  set_objective!,
  set_residuals!,
  set_multipliers!,
  set_iter!,
  set_time!,
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
  :unknown => "unknown",
  :user => "user-requested stop",
)

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

abstract type AbstractExecutionStats end

"""
    GenericExecutionStats(status, nlp; ...)

A GenericExecutionStats is a struct for storing output information of solvers.
It contains the following fields:
- `status`: Indicates the output of the solver. Use `show_statuses()` for the full list;
- `solution`: The final approximation returned by the solver (default: an uninitialzed vector like `nlp.meta.x0`);
- `objective`: The objective value at `solution` (default: `Inf`);
- `dual_feas`: The dual feasibility norm at `solution` (default: `Inf`);
- `primal_feas`: The primal feasibility norm at `solution` (default: `0.0` if uncontrained, `Inf` otherwise);
- `multipliers`: The Lagrange multiplers wrt to the constraints (default: an uninitialzed vector like `nlp.meta.y0`);
- `multipliers_L`: The Lagrange multiplers wrt to the lower bounds on the variables (default: an uninitialzed vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `multipliers_U`: The Lagrange multiplers wrt to the upper bounds on the variables (default: an uninitialzed vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `iter`: The number of iterations computed by the solver (default: `-1`);
- `elapsed_time`: The elapsed time computed by the solver (default: `Inf`);
- `solver_specific::Dict{Symbol,Any}`: A solver specific dictionary.

The constructor preallocates storage for the fields above.
Special storage may be used for `multipliers_L` and `multipliers_U` by passing them to the constructor.
For instance, if a problem has few bound constraints, those multipliers could be held in sparse vectors.

The following fields indicate whether the information above has been updated and is reliable:

- `solution_reliable`
- `objective_reliable`
- `residuals_reliable` (for `dual_feas` and `primal_feas`)
- `multipliers_reliable` (for `multiplers`, `multipliers_L` and `multipliers_U`)
- `iter_reliable`
- `time_reliable`
- `solver_specific_reliable`.

Setting fields using one of the methods `set_solution!()`, `set_objective!()`, etc., also marks
the field value as reliable.

The `reset!()` method marks all fields as unreliable.

The `status` field is mandatory on construction.
All other variables can be input as keyword arguments.

Notice that `GenericExecutionStats` does not compute anything, it simply stores.
"""
mutable struct GenericExecutionStats{T, S, V, Tsp} <: AbstractExecutionStats
  status::Symbol
  solution_reliable::Bool
  solution::S # x
  objective_reliable::Bool
  objective::T # f(x)
  residuals_reliable::Bool
  dual_feas::T # ‖∇f(x)‖₂ for unc, ‖P[x - ∇f(x)] - x‖₂ for bnd, etc.
  primal_feas::T # ‖c(x)‖ for equalities
  multipliers_reliable::Bool
  multipliers::S # y
  multipliers_L::V # zL
  multipliers_U::V # zU
  iter_reliable::Bool
  iter::Int
  time_reliable::Bool
  elapsed_time::Float64
  solver_specific_reliable::Bool
  solver_specific::Dict{Symbol, Tsp}
end

function GenericExecutionStats(
  status::Symbol,
  nlp::AbstractNLPModel{T, S};
  solution::S = similar(nlp.meta.x0),
  objective::T = T(Inf),
  dual_feas::T = T(Inf),
  primal_feas::T = unconstrained(nlp) ? zero(T) : T(Inf),
  multipliers::S = similar(nlp.meta.y0),
  multipliers_L::V = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0),
  multipliers_U::V = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0),
  iter::Int = -1,
  elapsed_time::Real = Inf,
  solver_specific::Dict{Symbol, Tsp} = Dict{Symbol, Any}(),
) where {T, S, V, Tsp}
  if !(status in keys(STATUSES))
    @error "status $status is not a valid status. Use one of the following: " join(
      keys(STATUSES),
      ", ",
    )
    throw(KeyError(status))
  end
  return GenericExecutionStats{T, S, V, Tsp}(
    status,
    false,
    solution,
    false,
    objective,
    false,
    dual_feas,
    primal_feas,
    false,
    multipliers,
    multipliers_L,
    multipliers_U,
    false,
    iter,
    false,
    elapsed_time,
    false,
    solver_specific,
  )
end

"""
    reset!(stats::GenericExecutionStats)

Reset the internal flags of `stats` to `false` to Indicate
that the contents should not be trusted.
"""
function NLPModels.reset!(stats::GenericExecutionStats)
  stats.solution_reliable = false
  stats.objective_reliable = false
  stats.residuals_reliable = false
  stats.multipliers_reliable = false
  stats.iter_reliable = false
  stats.time_reliable = false
  stats.solver_specific_reliable = false
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
  stats.primal_feas = primal
  stats.dual_feas = dual
  stats.residuals_reliable = true
  stats
end

"""
    set_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V)

Register `y`, `zL` and `zU` as optimal multipliers associated to equality constraints,
lower-bounded and upper-bounded constraints, respectively, in `stats` and mark them as reliable.
"""
function set_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V) where {T, S, V}
  stats.multipliers .= y
  stats.multipliers_L .= zL
  stats.multipliers_U .= zU
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
    set_time!(stats::GenericExecutionStats, time::Float64)

Register `time` as optimal solution time in `stats` and mark it as reliable.
"""
function set_time!(stats::GenericExecutionStats, time::Float64)
  stats.elapsed_time = time
  stats.time_reliable = true
  stats
end

"""
    set_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)

Register `value` as a solver-specific value identified by `field` in `stats`
and mark it as reliable.
"""
function set_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)
  if field ∈ keys(stats.solver_specific)
    try
      # will fail if typeof(solver_specific[field]) does not support broadcast
      stats.solver_specific[field] .= value
    catch
      stats.solver_specific[field] = value
    end
  else
    stats.solver_specific[field] = value
  end
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
