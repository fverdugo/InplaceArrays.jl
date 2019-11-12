
"""
"""
struct Polytope
  faces::Vector{Vector{Int}}
  facedims::Vector{UnitRange{Int}}
  facetypes::Vector{Int}
  reffaces::Vector{Polytope}
  vertexcoordinates::Matrix{Float64}
  edgetangents::Matrix{Float64}
  facetnormals::Matrix{Float64}
  facetorientation::Vector{Int}
end

"""
"""
num_dims(p::Polytope) = length(p.facedims) - 1

"""
"""
num_faces(p::Polytope) = length(p.faces)

"""
"""
function vertex_coordinates(T::Type{<:Point{D,Float64}}, p::Polytope) where D
  @assert D == num_dims(p)
  collect(dropdims(permutedims(reinterpret(T,p.vertexcoordinates)),dims=2))
end

function vertex_coordinates(T::Type{<:Point{0,Float64}}, p::Polytope)
  @assert 0 == num_dims(p)
  Point{0,Float64}[]
end

"""
"""
function edge_tangents(T::Type{<:Point{D,Float64}}, p::Polytope) where D
  @assert D == num_dims(p)
  collect(dropdims(permutedims(reinterpret(T,p.edgetangents)),dims=2))
end

function edge_tangents(T::Type{<:Point{0,Float64}}, p::Polytope)
  @assert 0 == num_dims(p)
  Point{0,Float64}[]
end

"""
"""
function facet_normals(T::Type{<:Point{D,Float64}}, p::Polytope) where D
  @assert D == num_dims(p)
  collect(dropdims(permutedims(reinterpret(T,p.facetnormals)),dims=2))
end

function facet_normals(T::Type{<:Point{0,Float64}}, p::Polytope)
  @assert 0 == num_dims(p)
  Point{0,Float64}[]
end

"""
"""
Polytope(extrusion::Int...) = Polytope(extrusion)

function Polytope(extrusion::NTuple{D,Int}) where D
  p = ExtPolytope(extrusion)
  _to_Polytope(p)
end

# module constants

"""
"""
const VERTEX = Polytope(
  [[1]],[1:1],Int[],Polytope[],zeros(0,1),zeros(0,0),zeros(0,0),Int[])

"""
"""
const HEX_AXIS = 1

"""
"""
const TET_AXIS = 2

# Helpers

function _to_Polytope(p)
  refextfaces = _nface_ref_polytopes(p)
  facetype, reffaces = _setup_reffaces(refextfaces[1:end-1])
  xv = _vertices_coordinates(p)
  x = collect(reinterpret(xv))
  etv = _edge_tangents(p)
  et = collect(reinterpret(etv))
  fnv, or = _face_normals(p)
  fn = collect(reinterpret(fnv))
  Polytope(p.nf_nfs, p.nfacesdim, facetype, reffaces, x, et, fn, or)
end

# n-face of the polytope, i.e., any polytope of lower dimension `N` representing
# its boundary and the polytope itself (for `N` equal to the space dimension `D`)
struct NFace{D}
  anchor::Point{D,Int}
  extrusion::Point{D,Int}
end

# Helper type that encodes a polytope build from an extrussion tuple
struct ExtPolytope{D}
  extrusion::Point{D,Int}
  nfaces::Vector{NFace}
  nfacesdim::Vector{UnitRange{Int}}
  nf_nfs::Vector{Vector{Int}}
  nf_dim::Vector{Vector{UnitRange{Int}}}
end

function ExtPolytope(extrusion::NTuple{N,Int}) where N
  ExtPolytope(Point{N,Int}(extrusion))
end

function ExtPolytope(extrusion::Int...)
  ExtPolytope(extrusion)
end

function ExtPolytope(extrusion::Point{D,Int}) where D
  zerop = Point{D,Int}(zeros(Int64, D))
  pol_nfs_dim = _polytopenfaces(zerop, extrusion)
  pol_nfs = pol_nfs_dim[1]
  pol_dim = pol_nfs_dim[2]
  nfs_id = Dict(nf => i for (i, nf) in enumerate(pol_nfs))
  nf_nfs_dim = _polytopemesh(pol_nfs, nfs_id)
  nf_nfs = nf_nfs_dim[1]
  nf_dim = nf_nfs_dim[2]
  ExtPolytope{D}(extrusion, pol_nfs, pol_dim, nf_nfs, nf_dim)
end

# Generates the array of n-faces of a polytope
function _polytopenfaces(anchor::Point{D,Int}, extrusion::Point{D,Int}) where D
  dnf = _nfdim(extrusion)
  zerop = Point{D,Int}(zeros(Int64, D))
  nf_nfs = []
  nf_nfs = _nfaceboundary!(anchor, zerop, extrusion, true, nf_nfs)
  [sort!(nf_nfs, by = x -> x.anchor[i]) for i = 1:length(extrusion)]
  [sort!(nf_nfs, by = x -> x.extrusion[i]) for i = 1:length(extrusion)]
  [sort!(nf_nfs, by = x -> sum(x.extrusion))]
  numnfs = length(nf_nfs)
  nfsdim = [_nfdim(nf_nfs[i].extrusion) for i = 1:numnfs]
  dimnfs = Array{UnitRange{Int64},1}(undef, dnf + 1)
  dim = 0
  i = 1
  for iface = 1:numnfs
    if (nfsdim[iface] > dim)
      # global dim; # global i
      dim += 1
      dimnfs[dim] = i:iface-1
      i = iface
    end
  end
  dimnfs[dnf+1] = numnfs:numnfs
  return [nf_nfs, dimnfs]
end

_nfdim(a::Point{D,Int}) where D = sum([a[i] > 0 ? 1 : 0 for i = 1:D])

# Generates the list of n-face of a polytope the d-faces for 0 <= d <n on its
# boundary
function _nfaceboundary!(
  anchor::Point{D,Int},
  extrusion::Point{D,Int},
  extend::Point{D,Int},
  isanchor::Bool,
  list) where D

  newext = extend
  list = [list..., NFace{D}(anchor, extrusion)]
  for i = 1:D
    curex = newext[i]
    if (curex > 0) # Perform extension
      func1 = (j -> j == i ? 0 : newext[j])
      newext = Point{D,Int}([func1(i) for i = 1:D])
      func2 = (j -> j == i ? 1 : 0)
      edim = Point{D,Int}([func2(i) for i = 1:D])
      func3 = (j -> j >= i ? anchor[j] : 0)
      tetp = Point{D,Int}([func3(i) for i = 1:D]) + edim
      if (curex == 1) # Quad extension
        list = _nfaceboundary!(anchor + edim, extrusion, newext, false, list)
      elseif (isanchor)
        list = _nfaceboundary!(tetp, extrusion, newext, false, list)
      end
      list = _nfaceboundary!(
        anchor,
        extrusion + edim * curex,
        newext,
        false,
        list)
    end
  end
  return list
end

# Provides for all n-faces of a polytope the d-faces for 0 <= d <n on its
# boundary (e.g., given a face, it provides the set of edges and corners on its
# boundary) using the global n-face numbering of the base polytope
function _polytopemesh(nfaces::Vector{NFace{D}}, nfaceid::Dict) where D
  num_nfs = length(nfaces)
  nfnfs = Vector{Vector{Int64}}(undef, num_nfs)
  nfnfs_dim = Vector{Vector{UnitRange{Int64}}}(undef, num_nfs)
  for (inf, nf) in enumerate(nfaces)
    nfs_dim_nf = _polytopenfaces(nf.anchor, nf.extrusion)
    nf_nfs = nfs_dim_nf[1]
    dimnfs = nfs_dim_nf[2]
    nfnfs[inf] = [get(nfaceid, nf, nf) for nf in nf_nfs]
    nfnfs_dim[inf] = dimnfs
  end
  return [nfnfs, nfnfs_dim]
end

# Generates the array of n-faces of a polytope
function _polytopenfaces(anchor::Point{D,Int}, extrusion::Point{D,Int}) where D
  dnf = _nfdim(extrusion)
  zerop = Point{D,Int}(zeros(Int64, D))
  nf_nfs = []
  nf_nfs = _nfaceboundary!(anchor, zerop, extrusion, true, nf_nfs)
  [sort!(nf_nfs, by = x -> x.anchor[i]) for i = 1:length(extrusion)]
  [sort!(nf_nfs, by = x -> x.extrusion[i]) for i = 1:length(extrusion)]
  [sort!(nf_nfs, by = x -> sum(x.extrusion))]
  numnfs = length(nf_nfs)
  nfsdim = [_nfdim(nf_nfs[i].extrusion) for i = 1:numnfs]
  dimnfs = Array{UnitRange{Int64},1}(undef, dnf + 1)
  dim = 0
  i = 1
  for iface = 1:numnfs
    if (nfsdim[iface] > dim)
      # global dim; # global i
      dim += 1
      dimnfs[dim] = i:iface-1
      i = iface
    end
  end
  dimnfs[dnf+1] = numnfs:numnfs
  return [nf_nfs, dimnfs]
end

# Generates the list of n-face of a polytope the d-faces for 0 <= d <n on its
# boundary
function _nfaceboundary!(
  anchor::Point{D,Int},
  extrusion::Point{D,Int},
  extend::Point{D,Int},
  isanchor::Bool,
  list) where D

  newext = extend
  list = [list..., NFace{D}(anchor, extrusion)]
  for i = 1:D
    curex = newext[i]
    if (curex > 0) # Perform extension
      func1 = (j -> j == i ? 0 : newext[j])
      newext = Point{D,Int}([func1(i) for i = 1:D])
      func2 = (j -> j == i ? 1 : 0)
      edim = Point{D,Int}([func2(i) for i = 1:D])
      func3 = (j -> j >= i ? anchor[j] : 0)
      tetp = Point{D,Int}([func3(i) for i = 1:D]) + edim
      if (curex == 1) # Quad extension
        list = _nfaceboundary!(anchor + edim, extrusion, newext, false, list)
      elseif (isanchor)
        list = _nfaceboundary!(tetp, extrusion, newext, false, list)
      end
      list = _nfaceboundary!(
        anchor,
        extrusion + edim * curex,
        newext,
        false,
        list)
    end
  end
  return list
end

# Returns an array with the reference polytopes for all n-faces (undef for vertices)
function _nface_ref_polytopes(p::ExtPolytope)
  function _eliminate_zeros(a)
    b = Int[]
    for m in a
      if (m != 0)
        push!(b, m)
      end
    end
    return Tuple(b)
  end
  nf_ref_p = Vector{ExtPolytope}(undef, length(p.nfaces))
  ref_nf_ps = ExtPolytope[]
  v = _vertex()
  for (i_nf, nf) in enumerate(p.nfaces)
    r_ext = _eliminate_zeros(nf.extrusion)
    if r_ext != ()
      k = 0
      for (i_p, ref_p) in enumerate(ref_nf_ps)
        if r_ext == ref_p.extrusion
          k = i_p
          nf_ref_p[i_nf] = ref_p
        end
      end
      if k == 0
        ref_p = ExtPolytope(r_ext)
        push!(ref_nf_ps, ref_p)
        k = length(ref_nf_ps) + 1
        nf_ref_p[i_nf] = ref_p
      end
    else
        nf_ref_p[i_nf] = v
    end
  end
  return nf_ref_p
end

function _vertex()
  ext = ()
  nfdim = [[1:1]]
  nfnfs = [[1]]
  nfanc = Point{0,Int}()
  nf = NFace{0}(nfanc,nfanc)
  nfs = [nf]
  return ExtPolytope{0}(ext, nfs, [1:1], nfnfs, nfdim)
end

function _setup_reffaces(refextfaces)
  hash = Dict()
  facetype = Int[]
  reffaces = Polytope[]
  k = 1
  for f in refextfaces
    if haskey(hash,f.extrusion)
      push!(facetype,hash[f.extrusion])
    else
      p = _to_Polytope(f)
      hash[f.extrusion] = k
      push!(facetype,k)
      push!(reffaces,p)
      k += 1
    end
  end
  facetype, reffaces
end

function _dimfrom_fs_dimto_fs(p::ExtPolytope, dim_from::Int, dim_to::Int)
  @assert dim_to <= dim_from
  dim_from += 1
  dim_to += 1
  dffs_r = p.nf_dim[end][dim_from]
  dffs_dtfs = Vector{Vector{Int}}(undef, dffs_r[end] - dffs_r[1] + 1)
  offs = p.nf_dim[end][dim_to][1] - 1
  for (i_dff, dff) in enumerate(dffs_r)
    dff_nfs = p.nf_nfs[dff]
    dff_dtfs_r = p.nf_dim[dff][dim_to]
    dff_dtfs = dff_nfs[dff_dtfs_r]
    dffs_dtfs[i_dff] = dff_dtfs .- offs
    # @santiagobadia : With or without offset ?
  end
  return dffs_dtfs
end

# It generates the list of coordinates of all vertices in the polytope. It is
# assumed that the polytope has the bounding box [0,1]**dim
function _vertices_coordinates(p::ExtPolytope{D}) where D
  vs = _dimfrom_fs_dimto_fs(p, D, 0)[1]
  vcs = Point{D,Float64}[]
  for i = 1:length(vs)
    cs = convert(Vector{Float64}, [p.nfaces[vs[i]].anchor...])
    push!(vcs, cs)
  end
  return vcs
end

# Return the n-faces vertices coordinates array for a given n-face dimension
function _nfaces_vertices(p,d)
  nc = _num_nfaces(p,d)
  verts = _vertices_coordinates(p)
  faces_vs = _dimfrom_fs_dimto_fs(p,d,0)
  cfvs = collect(LocalToGlobalArray(faces_vs,verts))
end

# Returns number of nfaces of dimension dim
function _num_nfaces(polytope::ExtPolytope, dim::Integer)
  n = length(polytope.nf_dim)
  k = 0
  for nface = 1:n
    d = length(polytope.nf_dim[nface]) - 1
    if d == dim
      k += 1
    end
  end
  k
end

# It generates the outwards normals of the facets of a polytope. It returns two
# arrays, the first one being the outward normal and the second one the orientation.
function _face_normals(p::ExtPolytope{D}) where D
  nf_vs = _dimfrom_fs_dimto_fs(p, D - 1, 0)
  vs = _vertices_coordinates(p)
  f_ns = Point{D,Float64}[]
  f_os = Int[]
  for i_f = 1:length(p.nf_dim[end][end-1])
    n, f_o = _facet_normal(p, nf_vs, vs, i_f)
    push!(f_ns, Point{D,Float64}(n))
    push!(f_os, f_o)
  end
  return f_ns, f_os
end

function _face_normals(p::ExtPolytope{0})
  (VectorValue{0,Float64}[], Int[])
end

function _face_normals(p::ExtPolytope{1})
  (VectorValue{1,Float64}[], Int[])
end

# It generates the tangent vectors for polytope edges.
function _edge_tangents(p::ExtPolytope{D}) where D
  ed_vs = _nfaces_vertices(p,1)
  return ts = [(t = vs[2]-vs[1])/norm(t) for vs in ed_vs ]
end

function _edge_tangents(p::ExtPolytope{0})
  VectorValue{0,Float64}[]
end

function _facet_normal(p::ExtPolytope{D}, nf_vs, vs, i_f) where D
  if (length(p.extrusion) > 1)
    v = Float64[]
    for i = 2:length(nf_vs[i_f])
      vi = vs[nf_vs[i_f][i]] - vs[nf_vs[i_f][1]]
      push!(v, vi...)
    end
    n = nullspace(transpose(reshape(v, D, length(nf_vs[i_f]) - 1)))
    n = n .* 1 / sqrt(dot(n, n))
    ext_v = _vertex_not_in_facet(p, i_f, nf_vs)
    v3 = vs[nf_vs[i_f][1]] - vs[ext_v]
    f_or = 1
    if dot(v3, n) < 0.0
      n *= -1
      f_or = -1
    end
  elseif (length(p.extrusion) == 1)
    ext_v = _vertex_not_in_facet(p, i_f, nf_vs)
    n = vs[nf_vs[i_f][1]] - vs[ext_v]
    n = n .* 1 / dot(n, n)
    f_or = 1
  else
    error("O-dim polytopes do not have properly define outward facet normals")
  end
  return n, f_or
end

function _vertex_not_in_facet(p, i_f, nf_vs)
  for i in p.nf_dim[end][1]
    is_in_f = false
    for j in nf_vs[i_f]
      if i == j
        is_in_f = true
        break
      end
    end
    if !is_in_f
      return i
      break
    end
  end
end
