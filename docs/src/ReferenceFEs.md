```@meta
CurrentModule = InplaceArrays.ReferenceFEs
```

# Gridap.ReferenceFEs

```@docs
ReferenceFEs
``` 

## Polytopes

### Interface

```@docs
Polytope
polytope_faces(p)
polytope_dimrange(p)
Polytope{D}(p,Dfaceid) where D
vertex_coordinates(p)
(==)(a::Polytope{D},b::Polytope{D}) where D
edge_tangents(p)
facet_normals(p)
facet_orientations(p)
vertex_permutations(p)
polytope_vtkid(p)
polytope_vtknodes(p)
test_polytope(p::Polytope{D};optional::Bool) where D
num_dims(::Type{<:Polytope{D}}) where D
num_faces(p::Polytope)
num_faces(p::Polytope,dim::Integer)
num_facets(p::Polytope)
num_edges(p::Polytope)
num_vertices(p::Polytope)
polytope_facedims(p)
polytope_offsets(p)
polytope_offset(p,d)
polytope_faces(p,dimfrom,dimto)
```
### Extrusion polytopes

```@docs
ExtrusionPolytope
ExtrusionPolytope(extrusion::Int...)
Polytope(extrusion::Int...)
HEX_AXIS
TET_AXIS
```

### Pre-defined polytope instances

```@docs
VERTEX
SEGMENT
TRI
QUAD
TET
HEX
WEDGE
PYRAMID
```
## Degrees of freedom

### Interface

```@docs
Dof
evaluate_dof!(cache,dof,field)
dof_cache(dof,field)
dof_return_type(dof,field)
test_dof(dof,field,v,comp::Function)
evaluate_dof(dof,field)
evaluate(dof::Dof,field)
```

### Working with arrays of DOFs

```@docs
evaluate_dof_array(dof::AbstractArray,field::AbstractArray)
evaluate(dof::AbstractArray{<:Dof},field::AbstractArray)
```
### Lagrangian dof bases

```@docs
LagrangianDofBasis
LagrangianDofBasis(::Type{T},nodes::Vector{<:Point}) where T
```

## Reference Finite Elements

### Interface

```@docs
ReferenceFE
num_dofs(reffe::ReferenceFE)
reffe_polytope(reffe)
reffe_prebasis(reffe)
reffe_dofs(reffe)
reffe_face_dofids(reffe)
ReferenceFE{N}(reffe,nfaceid) where N
reffe_dof_permutations(reffe)
INVALID_PERM
reffe_shapefuns(reffe)
compute_shapefuns(dofs,prebasis)
num_dims(::Type{<:ReferenceFE{D}}) where D
test_reference_fe(reffe::ReferenceFE{D}) where D
```

### Generic reference elements

```@docs
GenericRefFE
GenericRefFE(
  polytope::Polytope{D},
  prebasis::Field,
  dofs::Dof,
  facedofids::Vector{Vector{Int}};
  shapefuns::Field,
  ndofs::Int,
  dofperms::Vector{Vector{Int}},
  reffaces) where D
```

### Lagrangian reference elements

```@docs
LagrangianRefFE
LagrangianRefFE(::Type{T},p::Polytope{D},orders) where {T,D}
MonomialBasis(::Type{T},p::Polytope,orders) where T
LagrangianDofBasis(::Type{T},p::Polytope,orders) where T
compute_monomial_basis(::Type{T},p::Polytope,orders) where T
compute_interior_nodes(p::Polytope,orders)
compute_face_orders(p::Polytope,face::Polytope,iface::Int,orders)
compute_nodes(p::Polytope,orders)
compute_node_permutations(p::Polytope, interior_nodes)
compute_lagrangian_reffaces(::Type{T},p::Polytope,orders) where T
```
### Serendipity reference elements

```@docs
SerendipityRefFE
is_serendipity_compatible(p::Polytope)
```

