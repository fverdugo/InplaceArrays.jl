using Documenter
using InplaceArrays

#DocMeta.setdocmeta!(InplaceArrays,:DocTestSetup,:(using InplaceArrays))

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
