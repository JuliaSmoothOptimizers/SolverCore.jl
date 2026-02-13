module SolverCoreNLPModelsExt

using SolverCore
using NLPModels:
  AbstractNLPModel,
  AbstractNLSModel,
  has_bounds,
  neval_cons,
  neval_obj,
  neval_residual,
  unconstrained

"""
    reset!(stats::GenericExecutionStats, nlp::AbstractNLPModel)

Reset the internal flags of `stats` to `false` to Indicate
that the contents should not be trusted.
If an `AbstractNLPModel` is also provided,
the pre-allocated vectors are adjusted to the problem size.
"""
function SolverCore.reset!(
  stats::GenericExecutionStats{T, S},
  nlp::AbstractNLPModel{T, S},
) where {T, S}
  stats.solution = similar(nlp.meta.x0)
  stats.multipliers = similar(nlp.meta.y0)
  stats.multipliers_L = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0)
  stats.multipliers_U = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0)
  SolverCore.reset!(stats)
  stats
end

"""
    solve!(solver, model; kwargs...)
    solve!(solver, model, stats; kwargs...)

Apply `solver` to `model`.

# Arguments

- `solver::AbstractOptimizationSolver`: solver structure to hold all storage necessary for a solve
- `model::AbstractNLPModel`: the model solved, see `NLPModels.jl`
- `stats::GenericExecutionStats`: stats structure to hold solution information.

The first invocation allocates and returns a new `GenericExecutionStats`.
The second one fills out a preallocated stats structure and allows for efficient re-solves.

The `kwargs` are passed to the solver.

# Return Value

- `stats::GenericExecutionStats`: stats structure holding solution information.
"""
function SolverCore.solve!(
  solver::AOS,
  model::AbstractNLPModel{T, S};
  kwargs...,
) where {AOS <: AbstractOptimizationSolver, T, S}
  stats = GenericExecutionStats(model)
  solve!(solver, model, stats; kwargs...)
end

function SolverCore.solve!(
  ::AbstractOptimizationSolver,
  ::AbstractNLPModel,
  ::GenericExecutionStats;
  kwargs...,
) end

function SolverCore.GenericExecutionStats(
  nlp::AbstractNLPModel{T, S};
  status::Symbol = :unknown,
  solution::S = similar(nlp.meta.x0),
  objective::T = T(Inf),
  dual_feas::T = T(Inf),
  primal_feas::T = unconstrained(nlp) ? zero(T) : T(Inf),
  multipliers::S = similar(nlp.meta.y0),
  multipliers_L::V = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0),
  multipliers_U::V = similar(nlp.meta.y0, has_bounds(nlp) ? nlp.meta.nvar : 0),
  iter::Int = -1,
  step_status::Symbol = :unknown,
  elapsed_time::Real = Inf,
  solver_specific::Dict{Symbol, Tsp} = Dict{Symbol, Any}(),
) where {T, S, V, Tsp}
  SolverCore.check_status(status)
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

SolverCore.eval_fun(nlp::AbstractNLPModel) = neval_obj(nlp) + neval_cons(nlp)
SolverCore.eval_fun(nls::AbstractNLSModel) = neval_residual(nls) + neval_cons(nls)

end # end of module
