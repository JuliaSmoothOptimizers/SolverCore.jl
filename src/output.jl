export AbstractSolverOutput, solver_output_type

solver_output_type(::Type{S}) where S <: AbstractSolver = error("Output type not defined for $S")
solver_output_type(::S) where S <: AbstractSolver = solver_output_type(S)

# TODO: Define the required fields and API for all Outputs
"""
    AbstractSolverOutput{T,S}

Base type for output of JSO-compliant solvers.
An output must have at least the following:
- `status :: Symbol`
- `solution`

The type `T` is used for element types of the arrays, and `S` is used for the storage container type.
"""
abstract type AbstractSolverOutput{T, S} end

# TODO: Decision: Should STATUSES be fixed? Should it be all here?
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

function Base.show(io::IO, output::AbstractSolverOutput)
  println(io, "Solver output of type $(typeof(output))")
  println(io, "Status: $(STATUSES[output.status])")
end
