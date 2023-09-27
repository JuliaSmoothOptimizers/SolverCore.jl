using Documenter, SolverCore

makedocs(
  modules = [SolverCore],
  doctest = true,
  linkcheck = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "SolverCore.jl",
  pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/SolverCore.jl.git",
  push_preview = true,
  devbranch = "main",
)
