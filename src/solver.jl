export AbstractSolver, AbstractOptimizationSolver, solve!

"Abstract type from which JSO solvers derive."
abstract type AbstractSolver end

abstract type AbstractOptimizationSolver <: AbstractSolver end

"""
    reset!(solver::AbstractOptimizationSolver, model::AbstractNLPModel)

Use in the context of restarting or reusing the `solver` structure.
Reset the internal fields of `solver` for the `model` before calling `solve!` on the same structure.
`model` must have the same number of variables, bounds and constraints as that used to instantiate `solver`.
"""
function NLPModels.reset!(::AbstractOptimizationSolver, ::AbstractNLPModel) end

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
function solve!(solver::AbstractOptimizationSolver, model::AbstractNLPModel; kwargs...)
  stats = GenericExecutionStats(model)
  solve!(solver, model, stats; kwargs...)
end

function solve!(
  ::AbstractOptimizationSolver,
  ::AbstractNLPModel,
  ::GenericExecutionStats;
  kwargs...,
) end
