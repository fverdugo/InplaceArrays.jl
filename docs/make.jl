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

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
