@testset "Logger" begin
  @info "Testing logger"
  s = log_header([:col_real, :col_int, :col_symbol, :col_string], [Float64, Int, Symbol, String])
  @test s == @sprintf("%8s  %6s  %15s  %15s", "col_real", "col_int", "col_symbol", "col_string")
  s = log_row([1.0, 1, :one, "one"])
  @test s == @sprintf("%8.1e  %6d  %15s  %15s", 1.0, 1, "one", "one")
  s = log_row([Float64, Int, Symbol, String])
  @test s == @sprintf("%8s  %6s  %15s  %15s", "-", "-", "-", "-")
end
