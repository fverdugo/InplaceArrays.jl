
"""

`D` is the environment dimension (typically, 0, 1, 2, or 3d)
This type parameter is needed since there are functions in the 
`Polytope` interface that return containers with `Point{D}` objects
"""
abstract type Polytope{D} end

# Mandatory

"""
"""
function polytope_faces(p)
  @abstractmethod
end

"""
"""
function polytope_dimrange(p)
  @abstractmethod
end

"""
"""
function Polytope{D}(p,Dfaceid) where D
  @abstractmethod
end

"""
"""
function vertex_coordinates(p)
  @abstractmethod
end

"""
"""
function (==)(a::Polytope{D},b::Polytope{D}) where D
  @abstractmethod
end

function (==)(a::Polytope,b::Polytope)
  false
end

# Optional

"""
"""
function edge_tangents(p)
  @abstractmethod
end

"""
"""
function facet_normals(p)
  @abstractmethod
end

"""
"""
function facet_orientations(p)
  @abstractmethod
end

"""
"""
function vertex_permutations(p)
  @abstractmethod
end

"""
"""
function polytope_vtkid(p)
  @abstractmethod
end

"""
"""
function polytope_vtknodes(p)
  @abstractmethod
end

# Some generic API

"""
"""
num_dims(::Type{<:Polytope{D}}) where D = D
num_dims(p::T) where T<:Polytope = num_dims(T)

"""
"""
function num_faces(p::Polytope)
  length(polytope_faces(p))
end

"""
"""
function num_faces(p::Polytope,dim::Integer)
  length(polytope_dimrange(p)[dim+1])
end

"""
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
"""
function num_vertices(p::Polytope)
  num_faces(p,0)
end

"""
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
"""
function polytope_offset(p,d)
  polytope_offsets(p)[d+1]
end

"""
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

It does not test `polytope_vtkid`  nor `polytope_vtknodes`
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

