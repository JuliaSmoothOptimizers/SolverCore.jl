# This package
using SolverCore

# Auxiliary packages
using ADNLPModels, NLPModels

# stdlib
using LinearAlgebra, Logging, Test

include("dummy_solver.jl")

include("test_logging.jl")
include("test_stats.jl")
include("test_callback.jl")
