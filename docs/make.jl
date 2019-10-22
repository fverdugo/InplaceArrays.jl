using Documenter
using InplaceArrays

pages = [
  "Home" => "index.md",
  "Helpers" => "Helpers.md",
  "Type inference" => "Inference.md",
  "Arrays" => "Arrays.md",
 ]

makedocs(
    sitename = "InplaceArrays",
    format = Documenter.HTML(),
    modules = [InplaceArrays],
    pages = pages
)

deploydocs(
    repo = "github.com/fverdugo/InplaceArrays.jl.git",
)

