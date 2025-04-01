export AbstractSolver, AbstractOptimizationSolver, solve!, reset!

"Abstract type from which JSO solvers derive."
abstract type AbstractSolver end

abstract type AbstractOptimizationSolver <: AbstractSolver end

"""
    reset!(solver::::AbstractSolver, model)
    reset!(solver::::AbstractSolver)

Use in the context of restarting or reusing the `solver` structure.
Reset the internal fields of `solver` for the `model` before calling `solve!` on the same structure.
`model` must have the same number of variables, bounds and constraints as that used to instantiate `solver`.
"""
function reset!(solver::AbstractSolver) end
function reset!(solver::AbstractSolver, model) end

"""
    solve!(solver, model; kwargs...)
    solve!(solver, model, stats; kwargs...)

Apply `solver` to `model`.

# Arguments

- `solver::::AbstractSolver`: solver structure to hold all storage necessary for a solve
- `model`: the model solved
- `stats::GenericExecutionStats`: stats structure to hold solution information.

The first invocation allocates and returns a new `GenericExecutionStats`.
The second one fills out a preallocated stats structure and allows for efficient re-solves.

The `kwargs` are passed to the solver.

# Return Value

- `stats::GenericExecutionStats`: stats structure holding solution information.
"""
function solve!(solver::AbstractSolver, model; kwargs...) end
function solve!(solver::AbstractSolver, model, stats; kwargs...) end
