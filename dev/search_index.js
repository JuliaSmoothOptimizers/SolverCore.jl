var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [SolverCore]","category":"page"},{"location":"reference/#SolverCore.GenericExecutionStats","page":"Reference","title":"SolverCore.GenericExecutionStats","text":"GenericExecutionStats(status, nlp; ...)\n\nA GenericExecutionStats is a struct for storing output information of solvers. It contains the following fields:\n\nstatus: Indicates the output of the solver. Use show_statuses() for the full list;\nsolution: The final approximation returned by the solver (default: an uninitialzed vector like nlp.meta.x0);\nobjective: The objective value at solution (default: Inf);\ndual_feas: The dual feasibility norm at solution (default: Inf);\nprimal_feas: The primal feasibility norm at solution (default: 0.0 if uncontrained, Inf otherwise);\nmultipliers: The Lagrange multiplers wrt to the constraints (default: an uninitialzed vector like nlp.meta.y0);\nmultipliers_L: The Lagrange multiplers wrt to the lower bounds on the variables (default: an uninitialzed vector like nlp.meta.x0 if there are bounds, or a zero-length vector if not);\nmultipliers_U: The Lagrange multiplers wrt to the upper bounds on the variables (default: an uninitialzed vector like nlp.meta.x0 if there are bounds, or a zero-length vector if not);\niter: The number of iterations computed by the solver (default: -1);\nelapsed_time: The elapsed time computed by the solver (default: Inf);\nsolver_specific::Dict{Symbol,Any}: A solver specific dictionary.\n\nThe constructor preallocates storage for the fields above. Special storage may be used for multipliers_L and multipliers_U by passing them to the constructor. For instance, if a problem has few bound constraints, those multipliers could be held in sparse vectors.\n\nThe following fields indicate whether the information above has been updated and is reliable:\n\nsolution_reliable\nobjective_reliable\nresiduals_reliable (for dual_feas and primal_feas)\nmultipliers_reliable (for multiplers, multipliers_L and multipliers_U)\niter_reliable\ntime_reliable\nsolver_specific_reliable.\n\nSetting fields using one of the methods set_solution!(), set_objective!(), etc., also marks the field value as reliable.\n\nThe reset!() method marks all fields as unreliable.\n\nThe status field is mandatory on construction. All other variables can be input as keyword arguments.\n\nNotice that GenericExecutionStats does not compute anything, it simply stores.\n\n\n\n\n\n","category":"type"},{"location":"reference/#LinearOperators.reset!-Tuple{GenericExecutionStats}","page":"Reference","title":"LinearOperators.reset!","text":"reset!(stats::GenericExecutionStats)\n\nReset the internal flags of stats to false to Indicate that the contents should not be trusted.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.log_header-Tuple{AbstractVector{Symbol}, AbstractVector{DataType}}","page":"Reference","title":"SolverCore.log_header","text":"log_header(colnames, coltypes)\n\nCreates a header using the names in colnames formatted according to the types in coltypes. Uses internal formatting specification given by SolverCore.formats and default header translation given by SolverCore.default_headers.\n\nInput:\n\ncolnames::Vector{Symbol}: Column names.\ncoltypes::Vector{DataType}: Column types.\n\nKeyword arguments:\n\nhdr_override::Dict{Symbol,String}: Overrides the default headers.\ncolsep::Int: Number of spaces between columns (Default: 2)\n\nSee also log_row.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.log_row-Tuple{Any}","page":"Reference","title":"SolverCore.log_row","text":"log_row(vals)\n\nCreates a table row from the values on vals according to their types. Pass the names and types of vals to log_header for a logging table. Uses internal formatting specification given by SolverCore.formats.\n\nTo handle a missing value, add the type instead of the number:\n\n@info log_row(Any[1.0, 1])\n@info log_row(Any[Float64, Int])\n\nPrints\n\n[ Info:  1.0e+00       1\n[ Info:        -       -\n\nKeyword arguments:\n\ncolsep::Int: Number of spaces between columns (Default: 2)\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_iter!-Tuple{GenericExecutionStats, Int64}","page":"Reference","title":"SolverCore.set_iter!","text":"set_iter!(stats::GenericExecutionStats, iter::Int)\n\nRegister iter as optimal iteration number in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_multipliers!-Union{Tuple{V}, Tuple{S}, Tuple{T}, Tuple{GenericExecutionStats{T, S, V}, S, V, V}} where {T, S, V}","page":"Reference","title":"SolverCore.set_multipliers!","text":"set_multipliers!(stats::GenericExecutionStats{T, S, V}, y::S, zL::V, zU::V)\n\nRegister y, zL and zU as optimal multipliers associated to equality constraints, lower-bounded and upper-bounded constraints, respectively, in stats and mark them as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_objective!-Union{Tuple{V}, Tuple{S}, Tuple{T}, Tuple{GenericExecutionStats{T, S, V}, T}} where {T, S, V}","page":"Reference","title":"SolverCore.set_objective!","text":"set_objective!(stats::GenericExecutionStats{T, S, V}, val::T)\n\nRegister val as optimal objective value in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_residuals!-Union{Tuple{V}, Tuple{S}, Tuple{T}, Tuple{GenericExecutionStats{T, S, V}, T, T}} where {T, S, V}","page":"Reference","title":"SolverCore.set_residuals!","text":"set_residuals!(stats::GenericExecutionStats{T, S, V}, primal::T, dual::T)\n\nRegister primal and dual as optimal primal and dual feasibility residuals, respectively, in stats and mark them as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_solution!-Tuple{GenericExecutionStats, AbstractVector}","page":"Reference","title":"SolverCore.set_solution!","text":"set_solution!(stats::GenericExecutionStats, x::AbstractVector)\n\nRegister x as optimal solution in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_solver_specific!-Tuple{GenericExecutionStats, Symbol, Any}","page":"Reference","title":"SolverCore.set_solver_specific!","text":"set_solver_specific!(stats::GenericExecutionStats, field::Symbol, value)\n\nRegister value as a solver-specific value identified by field in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_status!-Tuple{GenericExecutionStats, Symbol}","page":"Reference","title":"SolverCore.set_status!","text":"set_status!(stats::GenericExecutionStats, status::Symbol)\n\nRegister status as final status in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.set_time!-Tuple{GenericExecutionStats, Float64}","page":"Reference","title":"SolverCore.set_time!","text":"set_time!(stats::GenericExecutionStats, time::Float64)\n\nRegister time as optimal solution time in stats and mark it as reliable.\n\n\n\n\n\n","category":"method"},{"location":"reference/#SolverCore.show_statuses-Tuple{}","page":"Reference","title":"SolverCore.show_statuses","text":"show_statuses()\n\nShow the list of available statuses to use with GenericExecutionStats.\n\n\n\n\n\n","category":"method"},{"location":"#Home","page":"Home","title":"SolverCore.jl documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Core package to build novel optimization algorithms in Julia.","category":"page"}]
}
