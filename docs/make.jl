using Documenter
using InplaceArrays

init = quote
  using InplaceArrays
end

DocMeta.setdocmeta!(InplaceArrays,:DocTestSetup,init)
DocMeta.setdocmeta!(InplaceArrays.Functors,:DocTestSetup,init)
DocMeta.setdocmeta!(InplaceArrays.Arrays,:DocTestSetup,init)

makedocs(
    sitename = "InplaceArrays",
    format = Documenter.HTML(),
    modules = [InplaceArrays]
)

deploydocs(
    repo = "github.com/fverdugo/InplaceArrays.jl.git",
)

