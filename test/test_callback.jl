@testset "test callback" begin
  nlp =
    ADNLPModel(x -> dot(x, x) / 2, ones(2), x -> [sum(x .^ 3) - 1], [0.0], [0.0], name = "linquad")
  callback(nlp, solver, stats) = begin
    if stats.iter ≥ 3
      set_status!(stats, :user)
    end
  end
  stats = dummy_solver(nlp, max_eval = 20, callback = callback)
  @test stats.iter == 3
end
