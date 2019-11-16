

"""
"""
function MonomialBasis(::Type{T},p::ExtrusionPolytope{D}, orders::NTuple{D,Int}) where {T,D}
  extrusion = Tuple(p.extrusion.array)
  terms = _monomial_terms(extrusion,orders)
  MonomialBasis{D}(T,orders,terms)
end

"""
"""
function MonomialBasis(::Type{T},p::ExtrusionPolytope{D}, order::Int) where {T,D}
  orders = tfill(order,Val{D}())
  MonomialBasis(T,p,orders)
end

function _monomial_terms(extrusion::NTuple{D,Int},orders) where D
  _check_orders(extrusion,orders)
  terms = CartesianIndex{D}[]
  M = mutable(VectorValue{D,Int})
  term = zero(M)
  _orders = M(orders)
  k = 0
  _add_terms!(terms,term,extrusion,_orders,D,k)
  terms
end

function _interior_nodes(p::ExtrusionPolytope,orders)
  extrusion = Tuple(p.extrusion.array)
  _interior_nodes(extrusion,orders)
end

function _interior_nodes(extrusion::NTuple{D,Int},orders) where D
  _check_orders(extrusion,orders)
  terms = CartesianIndex{D}[]
  M = mutable(VectorValue{D,Int})
  term = zero(M)
  _orders = M(orders)
  k = 1
  _add_terms!(terms,term,extrusion,_orders,D,k)
  _terms_to_coords(terms,orders)
end

function _check_orders(extrusion,orders)
  D = length(extrusion)
  @assert length(orders) == D "container of orders not long enough"
  _orders = collect(orders)
  if extrusion[D] == HEX_AXIS
    _orders[D] = 0
  end
  for d in (D-1):-1:1
    if (extrusion[d] == HEX_AXIS || d == 1) && _orders[d+1] == 0
      _orders[d] = 0
    end
  end
  nz = _orders[_orders .!= 0]
  if length(nz) > 1
    @assert all(nz .== nz[1]) "The provided anisotropic order is not compatible with polytope topology"
  end
  nothing
end

function _add_terms!(terms,term,extrusion,orders,dim,k)
  _term = copy(term)
  _orders = copy(orders)
  indexbase = 1
  for i in k:(_orders[dim]-k)
    _term[dim] = i + indexbase
    if dim > 1
      if (extrusion[dim] == TET_AXIS) && i != 0
        _orders .-= 1
      end
      _add_terms!(terms,_term,extrusion,_orders,dim-1,k)
    else
      push!(terms,CartesianIndex(Tuple(_term)))
    end
  end
end

function  _terms_to_coords(terms::Vector{CartesianIndex{D}},orders) where D
  P = Point{D,Float64}
  indexbase = 1
  nodes = P[]
  x = zero(mutable(P))
  for t in terms
    for d in 1:D
      x[d] = (t[d] - indexbase) / orders[d]
    end
    node = P(x)
    push!(nodes,node)
  end
  nodes
end

function _polytope_nodes(p::ExtrusionPolytope{D},order::Int) where D
  orders = tfill(order,Val{D}())
  _polytope_nodes(p,orders)
end

function _polytope_nodes(p::ExtrusionPolytope,orders)
  if all(orders .== 1)
    _polytope_linear_nodes(p)
  else
    _polytope_high_order_nodes(p,orders)
  end
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
      face_prebasis = MonomialBasis(Float64,face,1)
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
  _terms = _coords_to_terms(nodes,orders)
  _nodes = _terms_to_coords(_terms,orders)
  (_nodes, facenodes)
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

function _coords_to_terms(coords::Vector{<:Point{D}},orders) where D
  indexbase = 1
  terms = CartesianIndex{D}[]
  P = Point{D,Int}
  t = zero(mutable(P))
  for x in coords
    for d in 1:D
      t[d] = round(x[d]*orders[d]) + indexbase
    end
    term = CartesianIndex(Tuple(t))
    push!(terms,term)
  end
  terms
end

