function test_logging()
  nlp = HS10()

  @info "Testing logger"
  log_header([:col_float, :col_int, :col_symbol, :col_string], [Float64, Int, Symbol, String])
  log_row([1.0, 1, :one, "one"])
  log_row([Float64, Int, Symbol, String])

  with_logger(ConsoleLogger()) do
    @info "Testing dummy solver with logger"
    SolverCore.dummy_solver(nlp, max_eval = 20)
  end
end

test_logging()
