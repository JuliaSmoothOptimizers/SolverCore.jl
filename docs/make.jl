using Documenter, SolverCore

makedocs(
  modules = [SolverCore],
  doctest = true,
  linkcheck = true,
  strict = true,
  format = Documenter.HTML(assets = ["assets/style.css"], prettyurls = get(ENV, "CI", nothing) == "true"),
  sitename = "SolverCore.jl",
  pages = ["Home" => "index.md",
           "API" => "api.md",
           "Reference" => "reference.md",
          ]
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/SolverCore.jl.git",
  push_preview = true,
  devbranch = "master"
)
