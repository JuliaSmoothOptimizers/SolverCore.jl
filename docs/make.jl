using SolverCore
using Documenter

DocMeta.setdocmeta!(SolverCore, :DocTestSetup, :(using SolverCore); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
  file for
  file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
  modules = [SolverCore],
  authors = "Tangi Migot <tangi.migot@gmail.com>, Abel Soares Siqueira <abel.s.siqueira@gmail.com>, Dominique Orban <dominique.orban@gerad.ca>",
  repo = "https://github.com/JuliaSmoothOptimizers/SolverCore.jl/blob/{commit}{path}#{line}",
  sitename = "SolverCore.jl",
  format = Documenter.HTML(; canonical = "https://JuliaSmoothOptimizers.github.io/SolverCore.jl"),
  pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/JuliaSmoothOptimizers/SolverCore.jl")
