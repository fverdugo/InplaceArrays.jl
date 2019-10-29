module TreeVizTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Arrays: AppliedArray
using InplaceArrays.Arrays: BCasted
using InplaceArrays.Arrays: Func
using InplaceArrays.Arrays: Elem
using FillArrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis
using InplaceArrays.Fields: Valued
using FillArrays
using TensorValues # TODO

using LightGraphs
using TikzGraphs
using TikzPictures

function grow_graph!(g,v,a::AppliedArray)
  push!(v,objname(a) * " $(objectid(a))")
  i = length(v)
  push!(g,(i,i+1))
  grow_graph!(g,v,a.g)
  for fi in a.f
    j = length(v)
    push!(g,(i,j+1))
    grow_graph!(g,v,fi)
  end
end

function objname(a)
  "$(nameof(typeof(a)))"
end

function objname(a::BCasted)
  f = a.f
  "bcast($(string(f)))"
end

function objname(a::Elem)
  f = a.f
  "elem($(string(f)))"
end

function objname(a::Valued)
  f = a.k
  "Valued($(objname(f)))"
end

function objname(a::Func)
  f = a.f
  "f2k($(string(f)))"
end

function grow_graph!(g,v,a::AppliedArray{T,N,F,<:Fill} where {T,N,F})
  push!(v,objname(a.g.value) * " $(objectid(a))")
  i = length(v)
  for fi in a.f
    j = length(v)
    push!(g,(i,j+1))
    grow_graph!(g,v,fi)
  end
end

function grow_graph!(g,v,a::Fill)
  push!(v,objname(a))
  i = length(v)
  push!(g,(i,i+1))
  grow_graph!(g,v,a.value)
end

function grow_graph(a)
  g = Tuple{Int,Int}[]
  v = String[]
  grow_graph!(g,v,a)
  g, v
end

function grow_graph!(g,v,a)
  push!(v,objname(a))
end

function lightgraph(a)
  g, v = grow_graph(a)
  nv = length(v)
  lg = SimpleGraph(nv)
  for (i,j) in g
    add_edge!(lg,i,j)
  end
  lg, v
end

function viztree(a,file)
  g, v = lightgraph(a)
  t = TikzGraphs.plot(g,v)
  TikzPictures.save(PDF(file), t)
end

a = rand(12)
b = rand(12)
c = apply(-,a,b)

g, v = lightgraph(c)
@show g
@show v

viztree(c,"tree_c")

a = fill(rand(2,3),12)
b = rand(12)
c = apply(bcast(-),a,b)
d = apply(bcast(+),a,c)
e = apply(bcast(*),d,c)

g, v = lightgraph(e)
@show g
@show v

viztree(e,"tree_e")

np = 4
p = Point(1,2)
x = fill(p,np)
v = 3.0
d = 2
f = MockField{d}(v)
l = 10
af = Fill(f,l)
ax = fill(x,l)
av = fill(v,l)
ah = apply_to_field(elem(+),af,av)
ag = apply_to_field(elem(-),∇(af),∇(ah))
afx = evaluate(af,ax)
agx = evaluate(ag,ax)

viztree(afx,"tree_afx")
viztree(agx,"tree_agx")
viztree(ag,"tree_ag")

end #module
