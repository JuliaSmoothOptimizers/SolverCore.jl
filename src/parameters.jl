export parameters, are_valid_parameters

"""
    named_tuple = parameters(solver)
    named_tuple = parameters(SolverType)
    named_tuple = parameters(SolverType{T})

Return the parameters of a `solver`, or of the type `SolverType`.
You can specify the type `T` of the `SolverType`.
The returned structure is a nested NamedTuple.
Each key of `named_tuple` is the name of a parameter, and its value is a NamedTuple containing
- `default`: The default value of the parameter.
- `type`: The type of the parameter, such as `Int`, `Float64`, `T`, etc.

and possibly other values depending on the `type`.
Some possibilies are:

- `scale`: How to explore the domain
  - `:linear`: A continuous value within a range
  - `:log`: A positive continuous value that should be explored logarithmically (like 10⁻², 10⁻¹, 1, 10).
- `min`: Minimum value.
- `max`: Maximum value.

Solvers should define

    SolverCore.parameters(::Type{Solver{T}}) where T
"""
function parameters end

parameters(::Type{S}) where {S <: AbstractSolver} = parameters(S{Float64})
parameters(::S) where {S <: AbstractSolver} = parameters(S)

"""
    are_valid_parameters(solver, args...)

Return whether the parameters given in `args` are valid for `solver`.
The order of the parameters must be the same as in `parameters(solver)`.

Solvers should define

    SolverCore.are_valid_parameters(::Type{Solver{T}}, arg1, arg2, ...) where T
"""
function are_valid_parameters end
are_valid_parameters(::Type{S}, args...) where {S <: AbstractSolver} =
  are_valid_parameters(S{Float64}, args...)
are_valid_parameters(::S, args...) where {S <: AbstractSolver} = are_valid_parameters(S, args...)
