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
### Concrete implementations

```@docs
ExtrusionPolytope
Polytope(extrusion::Int...)
ExtrusionPolytope(extrusion::Int...)
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
```
## Degrees of freedom

### Interface

```@docs
Dof
dof_cache(dof,field)
evaluate_dof!(dof,field)
dof_return_type(dof,field)
test_dof(dof,field,v,comp::Function)
evaluate_dof(dof,field)
evaluate(dof::Dof,field)
evaluate_dof_array(dof::AbstractArray,field::AbstractArray)
evaluate(dof::AbstractArray{<:Dof},field::AbstractArray)
```
### Concrete implementations

```@docs
LagrangianDofBasis
LagrangianDofBasis(::Type{T},nodes::Vector{<:Point}) where T
```

## Referece Finite Elements

### Interface

```@docs
ReferenceFE
reffe_polytope(reffe)
reffe_prebasis(reffe)
reffe_dofs(reffe)
reffe_face_dofids(reffe)
ReferenceFE{N}(reffe,nfaceid) where N
reffe_dof_permutations(reffe)
reffe_shapefuns(reffe)
compute_shapefuns(dofs,prebasis)
num_dims(::Type{<:ReferenceFE{D}}) where D
test_reference_fe(reffe::ReferenceFE{D}) where D
```

### Concrete Implementations

```@docs
GenericRefFE
GenericRefFE(::Polytope{D},::Field,::Dof,::Vector{Vector{Int}},::Field) where D
```
