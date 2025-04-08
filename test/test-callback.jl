@testset "test callback" begin
  nlp = HS10()
  callback(nlp, solver, stats) = begin
    if stats.iter ≥ 3
      set_status!(stats, :user)
    end
  end
  stats = dummy_solver(nlp, max_eval = 20, callback = callback)
  @test stats.iter == 3
end
