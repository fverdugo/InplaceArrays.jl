module LagrangianRefFEsTests

using Test
using InplaceArrays.Fields
using InplaceArrays.Polynomials
using InplaceArrays.ReferenceFEs

orders = (2,3)
b = MonomialBasis(Float64,QUAD,orders)
r = [(0,0), (1,0), (2,0), (0,1), (1,1), (2,1), (0,2), (1,2), (2,2), (0,3), (1,3), (2,3)]
@test [Tuple(t) for t in b.terms] == r

orders = (1,1,2)
b = MonomialBasis(Float64,WEDGE,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (0,0,1), (1,0,1), (0,1,1), (0,0,2), (1,0,2), (0,1,2)]
@test [Tuple(t) for t in b.terms] == r

orders = (1,1,1)
b = MonomialBasis(Float64,PYRAMID,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (1,1, 0), (0,0,1)]
@test [Tuple(t) for t in b.terms] == r

orders = (1,1,1)
b = MonomialBasis(Float64,TET,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (0,0,1)]
@test [Tuple(t) for t in b.terms] == r

orders = (2,2)
extrusion = Tuple(QUAD.extrusion.array)

using InplaceArrays.ReferenceFEs: _interior_nodes

nodes = _interior_nodes(extrusion,orders)

function _polytope_nodes()
end

function _polytope_linear_nodes(p)
  x = vertex_coordinates(p)
  facenodes = [Int[] for i in 1:num_faces(p)]
  for i in 1:num_vertices(p)
    push!(facenodes[i],i)
  end
  x, facenodes
end

function _polytope_high_order_nodes(p::ExtrusionPolytope{D},orders) where D
  x = vertex_coordinates(p)
  nodes = Point{D,Float64}[]
  facenodes = [Int[] for i in 1:num_faces(p)]
  k = 1 
  for vertex in 1:num_vertices(p)
    push!(nodes,x[vertex])
    push!(facenodes[vertex],k)
    k += 1
  end
  offsets = polytope_offsets(p)
  for d in 1:(num_dims(p)-1)
    offset = offsets[d+1]
    for iface in 1:num_faces(p,d)
      nface = p.nfaces[iface+offset]
      face_orders = _extract_nonzeros(nface.extrusion,orders)
      face = Polytope{d}(p,iface)
      face_prebasis = MonomialBasis(Float64,face,1) # TODO
      face_ref_x = vertex_coordinates(face)
      change = inv(evaluate(face_prebasis,face_ref_x))
      face_shapefuns = change_basis(face_prebasis,change)
      face_vertex_ids = polytope_faces(p,d,0)[iface]
      face_x = x[face_vertex_ids]
      face_interior_nodes = _interior_nodes(face,face_orders)
      face_high_x = evaluate(face_shapefuns,face_interior_nodes)*face_x
      for xi in 1:length(face_high_x)
        push!(nodes,face_high_x[xi])
        push!(facenodes[iface+offset],k)
        k += 1
      end
    end
  end
  p_high_x = _interior_nodes(p,orders)
  for xi in 1:length(p_high_x)
    push!(nodes,p_high_x[xi])
    push!(facenodes[end],k)
    k += 1
  end
  (nodes, facenodes)
end

function _extract_nonzeros(mask,values)
  b = Int[]
  for (m,n) in zip(mask,values)
    if (m != 0)
      push!(b, n)
    end
  end
  return Tuple(b)
end

#@show _polytope_linear_nodes(TET)
#
#@show _polytope_high_order_nodes(QUAD,(2,2))

end # module
