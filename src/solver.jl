export AbstractSolver, solve!

# TODO: Define the required fields and API for all Solvers
"""
    AbstractSolver{T,S}

Base type for JSO-compliant solvers.

A solver must have three members:
- `initialized :: Bool`, indicating whether the solver was initialized
- `params :: Dict`, a dictionary of parameters for the solver
- `workspace`, a named tuple with arrays used by the solver.

The type `T` is used for element types of the arrays, and `S` is used for the storage container type.
"""
abstract type AbstractSolver{T, S} end

function Base.show(io::IO, solver::AbstractSolver)
  println(io, "Solver $(typeof(solver))")
end

"""
    output = solve!(solver, problem)

Solve `problem` with `solver`.
"""
function solve! end

# TODO: Define general constructors that automatically call `solve!`, etc.?
