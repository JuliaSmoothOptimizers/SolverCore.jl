function dummy_solver(
  nlp::AbstractNLPModel;
  x::AbstractVector = nlp.meta.x0,
  atol::Real = sqrt(eps(eltype(x))),
  rtol::Real = sqrt(eps(eltype(x))),
  max_eval::Int = 1000,
  max_time::Float64 = 30.0,
)
  start_time = time()
  elapsed_time = 0.0

  nvar, ncon = nlp.meta.nvar, nlp.meta.ncon
  T = eltype(x)

  cx = ncon > 0 ? cons(nlp, x) : zeros(T, 0)
  gx = grad(nlp, x)
  Jx = ncon > 0 ? jac(nlp, x) : zeros(T, 0, nvar)
  y = -Jx' \ gx
  Hxy = ncon > 0 ? hess(nlp, x, y) : hess(nlp, x)

  dual = gx + Jx' * y

  iter = 0

  ϵd = atol + rtol * norm(dual)
  ϵp = atol

  fx = obj(nlp, x)
  @info log_header([:iter, :f, :c, :dual, :t, :x], [Int, T, T, T, Float64, Char])
  @info log_row(Any[iter, fx, norm(cx), norm(dual), elapsed_time, 'c'])
  solved = norm(dual) < ϵd && norm(cx) < ϵp
  tired = neval_obj(nlp) + neval_cons(nlp) > max_eval || elapsed_time > max_time

  while !(solved || tired)
    Hxy = ncon > 0 ? hess(nlp, x, y) : hess(nlp, x)
    W = Symmetric([Hxy zeros(T, nvar, ncon); Jx zeros(T, ncon, ncon)], :L)
    Δxy = -W \ [dual; cx]
    Δx = Δxy[1:nvar]
    Δy = Δxy[(nvar + 1):end]
    x += Δx
    y += Δy

    cx = ncon > 0 ? cons(nlp, x) : zeros(T, 0)
    gx = grad(nlp, x)
    Jx = ncon > 0 ? jac(nlp, x) : zeros(T, 0, nvar)
    dual = gx + Jx' * y
    elapsed_time = time() - start_time
    solved = norm(dual) < ϵd && norm(cx) < ϵp
    tired = neval_obj(nlp) + neval_cons(nlp) > max_eval || elapsed_time > max_time

    iter += 1
    fx = obj(nlp, x)
    @info log_row(Any[iter, fx, norm(cx), norm(dual), elapsed_time, 'd'])
  end

  status = if solved
    :first_order
  elseif elapsed_time > max_time
    :max_time
  else
    :max_eval
  end

  stats = GenericExecutionStats(status, nlp)
  set_objective!(stats, fx)
  set_residuals!(stats, norm(cx), norm(dual))
  z = has_bounds(nlp) ? zeros(T, nvar) : zeros(T, 0)
  set_multipliers!(stats, y, z, z)
  set_time!(stats, elapsed_time)
  set_solution!(stats, x)
  set_iter!(stats, iter)
  return stats
end
