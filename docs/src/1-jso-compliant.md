# JSO-compliant solvers

The following are JSO-compliance expectations and recommendations that are implemented in JuliaSmoothOptimizers.

## Mandatory

- Create a function `solver_name(nlp::AbstractNLPModel; kwargs...)` that returns a `GenericExecutionStats`.

## Recommended

- Create a solver object `SolverName <: SolverCore.AbstractOptimizationSolver`.
- Store all memory-allocating things inside this object. This includes vectors, matrices, and possibly other objects.
- One of these objects should be `solver.x`, that stores the current iterate.
- Implement a constructor `SolverName(nlp; kwargs...)`.
- Implement `SolverCore.solve!(solver, nlp::AbstractNLPModel, stats::GenericExecutionStats)` and change `solver_name` to create a `SolverName` object and call `solve!`.
- Make sure that `solve!` is not allocating.
- Accept the following keyword arguments (`T` is float type and `V` is the container type):
  - `x::V = nlp.meta.x0`: The starting point.
  - `atol::T = sqrt(eps(T))`: Absolute tolerance for the gradient. Use in conjunction with the relative tolerance below to check $\Vert \nabla f(x_k)\Vert \leq \epsilon_a + \epsilon_r\Vert \nabla f(x_0)\Vert$.
  - `rtol::T = sqrt(eps(T))`: Relative tolerance for the gradient. See `atol` above.
  - `max_eval::Int = -1`: Maximum number of objective function evaluation plus constraint function evaluations. Negative number means unlimited.
  - `max_iter::Int = typemax(Int)`: Maximum number of iterations.
  - `max_time::Float64 = 30.0`: Maximum elapsed time.
  - `verbose::Int = 0`: Verbosity level. `0` means nothing and `1` means something. There are no rules on the level of verbosity yet.
  - `callback = (nlp, solver, stats) -> nothing`: A callback function to be called at the end of an iteration, before exit status are defined.
- Use `set_status!` and `get_status` to update `stats` before starting the method loop, and at the end of every iteration.
- Call the `callback` after running `set_status!` in both places.
- Define `done = stats.status != :unknown` and loop with `while !done`.
- To check for logic errors and stop the method use `set_status!(stats, ...)`, `done = true`, and `continue`, where the second argument of `set_status!` is one of the statuses available in SolverCore.STATUSES. You can call `SolverCore.show_statuses()` to see them. If you need more specific statuses, create an issue.
- Use the `set_...!(stats, ...)` functions from `SolverCore` to update the `stats`. For instance, `set_objective!(stats, f)`, `set_time!(stats, time() - start_time)`, and `set_dual_residual!(stats, gnorm)`.
- Don't log when `verbose == 0`. When logging, use `@info log_header(...)` and `@info log_row(...)`.
- Write docstrings for `SolverName`. The format is still a bit loose.
