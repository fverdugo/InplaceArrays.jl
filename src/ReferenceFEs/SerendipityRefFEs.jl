
"""
"""
function SerendipityRefFE(::Type{T},p::Polytope,order::Int) where T
  @assert is_serendipity_compatible(p) "Polytope not compatible with serendipity elements"
  sp = SerendipityPolytope(p) 
  LagrangianRefFE(T,sp,order)
end

"""
"""
function is_serendipity_compatible(p::Polytope)
  @abstractmethod
end

# Concrete implementation for ExtrusionPolytope

function is_serendipity_compatible(p::ExtrusionPolytope)
  all(p.extrusion.array .== HEX_AXIS)
end


# Helper private type
struct SerendipityPolytope{D,P} <: Polytope{D}
  hex::P
  SerendipityPolytope(p::Polytope{D}) where D = new{D,typeof(p)}(p)
end

# Implemented polytope interface

function polytope_faces(p::SerendipityPolytope)
  polytope_faces(p.hex)
end

function polytope_dimrange(p::SerendipityPolytope)
  polytope_dimrange(p.hex)
end

function Polytope{N}(p::SerendipityPolytope,Nfaceid) where N
  face_hex = Polytope{N}(p.hex, Nfaceid)
  SerendipityPolytope(face_hex)
end

function Polytope{D}(p::SerendipityPolytope{D},Dfaceid) where D
  @assert Dfaceid == 1 "Only one D-face"
  p
end

function vertex_coordinates(p::SerendipityPolytope)
  vertex_coordinates(p.hex)
end

function (==)(a::SerendipityPolytope{D},b::SerendipityPolytope{D}) where D
  a.hex == b.hex
end

function vertex_permutations(p::SerendipityPolytope)
  vertex_permutations(p.hex)
end

# Implemented polytope interface for LagrangianRefFEs

function _s_filter(e,order)
  sum( [ i for i in e if i>1 ] ) <= order
end

function compute_monomial_basis(::Type{T},p::SerendipityPolytope{D},orders) where {T,D}
  MonomialBasis{D}(T,orders,_s_filter)
end

function compute_interior_nodes(p::SerendipityPolytope{0},orders)
  compute_interior_nodes(p.hex,orders)
end

function compute_interior_nodes(p::SerendipityPolytope{1},orders)
  compute_interior_nodes(p.hex,orders)
end

function compute_interior_nodes(p::SerendipityPolytope{2},orders)
  order, = orders
  if order == 4
    o = (2,2)
  elseif order in (0,1,2,3)
    o=(1,1)
  else
    @unreachable "Serendipity elements only up to order 4"
  end
  compute_interior_nodes(p.hex,o)
end

function compute_interior_nodes(p::SerendipityPolytope{3},orders)
  Point{3,Float64}[]
end

function compute_interior_nodes(p::SerendipityPolytope,orders)
  @unreachable "Serendipity elements only up to 3d"
end

function compute_face_orders(
  p::SerendipityPolytope{D},face::SerendipityPolytope{N},iface::Int,orders) where {D,N}
  compute_face_orders(p.hex,face.hex,iface,orders)
end

