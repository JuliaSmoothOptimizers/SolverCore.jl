export problem_types_handled, can_solve_type

# TODO: Nothing is decided for traits
"""
    problem_types_handled(solver)

List the problem types handled by the `solver`.
"""
problem_types_handled(::Type{<:AbstractSolver}) = []

"""
    can_solve_type(solver, type)

Check if the `solver` can solve problems of `type`.
Call `problem_types_handled` for a list of problem types that the `solver` can solve.
"""
function can_solve_type(::Type{S}, t::Symbol) where {S <: AbstractSolver}
  return t ∈ problem_types_handled(S)
end
