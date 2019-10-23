using Documenter
using InplaceArrays

pages = [
  "Home" => "index.md",
  "Gridap" => "Gridap.md",
  "Gridap.Helpers" => "Helpers.md",
  "Gridap.Inference" => "Inference.md",
  "Gridap.Arrays" => "Arrays.md",
  "Gridap.Fields" => "Fields.md",
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

