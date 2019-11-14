
"""
    abstract type Polytope{D}

Abstract type representing a polytope (i.e., a polyhedron in arbitrary dimensions).
`D` is the environment dimension (typically, 0, 1, 2, or 3).
This type parameter is needed since there are functions in the 
`Polytope` interface that return containers with `Point{D}` objects.
We adopt the [usual nomenclature](https://en.wikipedia.org/wiki/Polytope) for polytope-related objects.
All objects in a polytope (from vertices to the polytope itself) are called *n-faces* or simply *faces*.
The notation *n-faces* is used only when it is needed to refer to the object dimension n. Otherwise we simply
use *face*. In addition, we say

- vertex (pl. vertices): for 0-faces
- edge: for 1-faces
- facet: for (`D-1`)-faces

The `Polytope` interface is defined by overloading the following functions

- [`polytope_faces(p)`](@ref)
- [`polytope_dimrange(p)`](@ref)
- [`Polytope{N}(p,faceid) where N`](@ref)
- [`vertex_coordinates(p)`](@ref)
- [`(==)(a::Polytope{D},b::Polytope{D}) where D`](@ref)

And optionally these ones:

- [`edge_tangents(p)`](@ref)
- [`facet_normals(p)`](@ref)
- [`facet_orientations(p)`](@ref)
- [`vertex_permutations(p)`](@ref)
- [`polytope_vtkid(p)`](@ref)
- [`polytope_vtknodes(p)`](@ref)

The interface can be tested with the function

- [`test_polytope`](@ref)

"""
abstract type Polytope{D} end

# Mandatory

"""
    polytope_faces(p) -> Vector{Vector{Int}}

Given a polytope `p` the function returns a vector of vectors
defining the *incidence* relation of the faces in the polytope.

Each face in the polytope receives a unique integer id. The id 1 is assigned
to the first 0-face. Consecutive increasing ids are assigned to the other
0-faces, then to 1-faces, and so on. The polytope itself receives the largest id
which coincides with `num_faces(p)`. For a face id `iface`, `polytope_faces(p)[iface]`
is a vector of face ids, corresponding to the faces that are *incident* with the face
labeled with `iface`. That is, faces that are either on its boundary or the face itself. 
In this vector of incident face ids, faces are ordered by dimension, starting with 0-faces.

# Examples

The face labels associated with a segment are `[1,2,3]`, being `1` and `2` for the vertices and 
`3` for the segment itself. In this case, this function would return the vector of vectors
`[[1],[2],[1,2,3]]` meaning that vertex `1` is incident with vertex `1` (idem for vertex 2), and that 
the segment (id `3`) is incident with the vertices `1` and `2` and the segment itself.


"""
function polytope_faces(p)
  @abstractmethod
end

"""
    polytope_dimrange(p) -> Vector{UnitRange{Int}}
"""
function polytope_dimrange(p)
  @abstractmethod
end

"""
    Polytope{N}(p,faceid) where N

Returns a `Polytope{N}` object representing the `N`-face with id `faceid`.
The value `faceid` refers to the numeration restricted to the dimension `N`
(it starts with 1 for the first `N`-face).
"""
function Polytope{D}(p,Dfaceid) where D
  @abstractmethod
end

"""
    vertex_coordinates(p) -> Vector{Point{D,Float64}}
"""
function vertex_coordinates(p)
  @abstractmethod
end

"""
    (==)(a::Polytope{D},b::Polytope{D}) where D

Note that the operator `==` returns `false` by default for polytopes
of different dimensions.
"""
function (==)(a::Polytope{D},b::Polytope{D}) where D
  @abstractmethod
end

function (==)(a::Polytope,b::Polytope)
  false
end

# Optional

"""
    edge_tangents(p) -> Vector{VectorValue{D,Float64}}
"""
function edge_tangents(p)
  @abstractmethod
end

"""
    facet_normals(p) -> Vector{VectorValue{D,Float64}}
"""
function facet_normals(p)
  @abstractmethod
end

"""
    facet_orientations(p) -> Vector{Int}
"""
function facet_orientations(p)
  @abstractmethod
end

"""
    vertex_permutations(p) -> Vector{Vector{Int}}
"""
function vertex_permutations(p)
  @abstractmethod
end

"""
    polytope_vtkid(p)
"""
function polytope_vtkid(p)
  @abstractmethod
end

"""
    polytope_vtknodes(p)
"""
function polytope_vtknodes(p)
  @abstractmethod
end

# Some generic API

"""
    num_dims(::Type{<:Polytope{D}}) where D
    num_dims(p::Polytope{D}) where D

Returns `D`. 
"""
num_dims(::Type{<:Polytope{D}}) where D = D
num_dims(p::T) where T<:Polytope = num_dims(T)

"""
    num_faces(p::Polytope)
"""
function num_faces(p::Polytope)
  length(polytope_faces(p))
end

"""
    num_faces(p::Polytope,dim::Integer)
"""
function num_faces(p::Polytope,dim::Integer)
  length(polytope_dimrange(p)[dim+1])
end

"""
    num_facets(p::Polytope)
"""
function num_facets(p::Polytope)
  D = num_dims(p)
  if D > 0
    num_faces(p,D-1)
  else
    0
  end
end

"""
    num_edges(p::Polytope)
"""
function num_edges(p::Polytope)
  D = num_dims(p)
  if D > 0
    num_faces(p,1)
  else
    0
  end
end

"""
    num_vertices(p::Polytope)
"""
function num_vertices(p::Polytope)
  num_faces(p,0)
end

"""
    polytope_facedims(p) -> Vector{Int}
"""
function polytope_facedims(p)
  n = num_faces(p)
  facedims = zeros(Int,n)
  dimrange = polytope_dimrange(p)
  for (i,r) in enumerate(dimrange)
    d = i-1
    facedims[r] .= d
  end
  facedims
end

"""
    polytope_offsets(p) -> Vector{Int}
"""
function polytope_offsets(p)
  D = num_dims(p)
  dimrange = polytope_dimrange(p)
  offsets = zeros(Int,D+1)
  k = 0
  for i in 0:D
    d = i+1
    offsets[d] = k
    r = dimrange[d]
    k += length(r)
  end
  offsets
end

"""
    polytope_offset(p,d)
"""
function polytope_offset(p,d)
  polytope_offsets(p)[d+1]
end

"""
    polytope_faces(p,dimfrom,dimto) -> Vector{Vector{Int}}
"""
function polytope_faces(p,dimfrom,dimto)
  if dimfrom >= dimto
    _polytope_faces_primal(p,dimfrom,dimto)
  else
    _polytope_faces_dual(p,dimfrom,dimto)
  end
end

function _polytope_faces_primal(p,dimfrom,dimto)
  dimrange = polytope_dimrange(p)
  r = dimrange[dimfrom+1]
  faces = polytope_faces(p)
  faces_dimfrom = faces[r]
  n = length(faces_dimfrom)
  faces_dimfrom_dimto = Vector{Vector{Int}}(undef,n)
  offset = polytope_offset(p,dimto)
  for i in 1:n
    f = Polytope{dimfrom}(p,i)
    rto = polytope_dimrange(f)[dimto+1]
    faces_dimfrom_dimto[i] = faces_dimfrom[i][rto].-offset
  end
  faces_dimfrom_dimto
end

function _polytope_faces_dual(p,dimfrom,dimto)
  tface_to_ffaces = polytope_faces(p,dimto,dimfrom)
  nffaces = num_faces(p,dimfrom)
  fface_to_tfaces = [Int[] for in in 1:nffaces]
  for (tface,ffaces) in enumerate(tface_to_ffaces)
    for fface in ffaces
      push!(fface_to_tfaces[fface],tface)
    end
  end
  fface_to_tfaces
end

# Testers

"""
    test_polytope(p::Polytope{D}; optional::Bool=false) where D

Function that stresses out the functions in the `Polytope` interface.
with `optional=false` (the default), only the mandatory functions are tested.
With `optional=true`, the optional functions are also tested except
`polytope_vtkid`  nor `polytope_vtknodes`
"""
function test_polytope(p::Polytope{D};optional::Bool=false) where D
  @test D == num_dims(p)
  faces = polytope_faces(p)
  @test isa(faces,Vector{Vector{Int}})
  @test num_faces(p) == length(faces)
  offsets = polytope_offsets(p)
  @test isa(offsets,Vector{Int})
  @test length(offsets) == D+1
  dimrange = polytope_dimrange(p)
  @test isa(dimrange,Vector{UnitRange{Int}})
  @test length(dimrange) == D+1
  @test p == p
  for d in 0:D
    for id in 1:num_faces(p,d)
      pd = Polytope{d}(p,id)
      @test isa(pd,Polytope{d})
    end
  end
  for dimfrom in 0:D
    for dimto in 0:D
      fs = polytope_faces(p,dimfrom,dimto)
      @test isa(fs,Vector{Vector{Int}})
    end
  end
  x = vertex_coordinates(p)
  @test isa(x,Vector{Point{D,Float64}})
  @test length(x) == num_faces(p,0)
  if optional
    fn = facet_normals(p)
    @test isa(fn,Vector{VectorValue{D,Float64}})
    @test length(fn) == num_facets(p)
    or = facet_orientations(p)
    @test isa(or,Vector{Int})
    @test length(or) == num_facets(p)
    et = edge_tangents(p)
    @test isa(et,Vector{VectorValue{D,Float64}})
    @test length(et) == num_edges(p)
    perm = vertex_permutations(p)
    @test isa(perm,Vector{Vector{Int}})
  end
end

