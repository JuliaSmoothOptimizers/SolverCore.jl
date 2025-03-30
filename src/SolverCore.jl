module SolverCore

using LinearAlgebra: LinearAlgebra, Symmetric, factorize, ldiv!, mul!, norm, qr
using NLPModels:
  NLPModels,
  AbstractNLPModel,
  AbstractNLSModel,
  cons!,
  grad!,
  has_bounds,
  hess_coord!,
  jac_coord!,
  neval_cons,
  neval_obj,
  neval_residual,
  obj,
  reset!,
  unconstrained
using Printf: Printf, @printf, @sprintf

include("logger.jl")
include("stats.jl")
include("solver.jl")
include("dummy_solver.jl")

end
