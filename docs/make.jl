using Documenter
using InplaceArrays

init = quote
  using InplaceArrays
end

DocMeta.setdocmeta!(InplaceArrays,:DocTestSetup,init)
DocMeta.setdocmeta!(InplaceArrays.Functors,:DocTestSetup,init)
DocMeta.setdocmeta!(InplaceArrays.Arrays,:DocTestSetup,init)

pages = [
  "Home" => "index.md",
  "The functor interface" => "Functors.md",
  "Extended AbstractArray interface" => "Arrays.md"]

makedocs(
    sitename = "InplaceArrays",
    format = Documenter.HTML(),
    modules = [InplaceArrays],
    pages = pages
)

deploydocs(
    repo = "github.com/fverdugo/InplaceArrays.jl.git",
)

