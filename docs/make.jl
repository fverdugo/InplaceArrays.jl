using Documenter
using InplaceArrays

pages = [
  "Home" => "index.md",
  "Helpers" => "Helpers.md",
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

