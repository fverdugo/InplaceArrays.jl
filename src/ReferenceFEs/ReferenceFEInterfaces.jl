"""
    abstract type ReferenceFE{D}

Abstract type representing a Reference finite element. `D` is the underlying coordinate space dimension.
We follow the Ciarlet definition. A reference finite element
is defined by a polytope (cell topology), a basis of an interpolation space
of top of this polytope (denoted here as the prebasis), and a basis of the dual of this space
(i.e. the degrees of freedom). From this information one can compute the shape functions
(i.e, the canonical basis of w.r.t. the degrees of freedom) with a simple change of basis.
In addition, we also encode in this type information about how the interpolation space
in a reference finite element is "glued" with neighbors in order to build conforming
cell-wise spaces.

The `ReferenceFE` interface is defined by overloading these methods:

- [`num_dofs(reffe::ReferenceFE)`](@ref)
- [`get_polytope(reffe::ReferenceFE)`](@ref)
- [`get_prebasis(reffe::ReferenceFE)`](@ref)
- [`get_dofs(reffe::ReferenceFE)`](@ref)
- [`get_face_own_dofids(reffe::ReferenceFE)`](@ref)

and optionally these ones:

- [`ReferenceFE{N}(reffe::ReferenceFE,nfaceid::Integer) where N`](@ref)
- [`get_own_dofs_permutations(reffe::ReferenceFE)`](@ref)

"""
abstract type ReferenceFE{D} end

"""
    num_dofs(reffe::ReferenceFE) -> Int

Returns the number of DOFs.
"""
function num_dofs(reffe::ReferenceFE)
  @abstractmethod
end

"""
    get_polytope(reffe::ReferenceFE) -> Polytope

Returns the underlying polytope object.
"""
function get_polytope(reffe::ReferenceFE)
  @abstractmethod
end

"""
    get_prebasis(reffe::ReferenceFE) -> Field

Returns the underlying prebasis encoded as a `Field` object.
"""
function get_prebasis(reffe::ReferenceFE)
  @abstractmethod
end

"""
    get_dofs(reffe::ReferenceFE) -> Dof

Returns the underlying dof basis encoded in a `Dof` object. 
"""
function get_dofs(reffe::ReferenceFE)
  @abstractmethod
end

"""
    get_face_own_dofids(reffe::ReferenceFE) -> Vector{Vector{Int}}
"""
function get_face_own_dofids(reffe::ReferenceFE)
  @abstractmethod
end

# optional

"""
    ReferenceFE{N}(reffe::ReferenceFE,nfaceid::Integer) where N
"""
function ReferenceFE{N}(reffe::ReferenceFE,nfaceid::Integer) where N
  @abstractmethod
end

"""
    get_own_dofs_permutations(reffe::ReferenceFE) -> Vector{Vector{Int}}
"""
function get_own_dofs_permutations(reffe::ReferenceFE)
  @abstractmethod
end

# API

"""
    get_shapefuns(reffe::ReferenceFE)
"""
function get_shapefuns(reffe::ReferenceFE)
  dofs = get_dofs(reffe)
  prebasis = get_prebasis(reffe)
  compute_shapefuns(dofs,prebasis)
end

"""
    compute_shapefuns(dofs,prebasis)
"""
function compute_shapefuns(dofs,prebasis)
  change = inv(evaluate(dofs,prebasis))
  change_basis(prebasis,change)
end

num_dims(::Type{<:ReferenceFE{D}}) where D = D

"""
    num_dims(::Type{<:ReferenceFE{D}}) where D
    num_dims(reffe::ReferenceFE{D}) where D

Returns `D`.
"""
num_dims(reffe::ReferenceFE) = num_dims(typeof(reffe))

# Test

"""
    test_reference_fe(reffe::ReferenceFE{D};optional::Bool=false) where D
"""
function test_reference_fe(reffe::ReferenceFE{D};optional::Bool=false) where D
  @test D == num_dims(reffe)
  p = get_polytope(reffe)
  @test isa(p,Polytope{D})
  basis = get_prebasis(reffe)
  @test isa(basis,Field)
  dofs = get_dofs(reffe)
  @test isa(dofs,Dof)
  facedofs = get_face_own_dofids(reffe)
  @test isa(facedofs,Vector{Vector{Int}})
  @test length(facedofs) == num_faces(p)
  shapefuns = get_shapefuns(reffe)
  @test isa(shapefuns,Field)
  ndofs = num_dofs(reffe)
  m = evaluate(dofs,basis)
  @test ndofs == size(m,1)
  @test ndofs == size(m,2)
  if optional
    dofperms = get_own_dofs_permutations(reffe)
    @test isa(dofperms,Vector{Vector{Int}})
    vertexperms = get_vertex_permutations(p)
    @test length(vertexperms) == length(dofperms)
    @test all( length.(dofperms) .== length(facedofs[end]) )
    for d in 0:D
      for iface in 1:num_faces(p,d)
        refface = ReferenceFE{d}(reffe,iface)
        @test isa(refface,ReferenceFE{d})
      end
    end
  end
end


# Concrete implementation

"""
    struct GenericRefFE{D} <: ReferenceFE{D}
      ndofs::Int
      polytope::Polytope{D}
      prebasis::Field
      dofs::Dof
      facedofids::Vector{Vector{Int}}
      shapefuns::Field
      reffaces::Tuple
    end

This type is a *materialization* of the `ReferenceFE` interface. That is, it is a 
`struct` that stores the values of all abstract methods in the `ReferenceFE` interface.
This type is useful to build reference FEs from the underlying ingredients without
the need to create a new type.

Note that this `struct` is type unstable deliberately in order to simplify the
type signature and speed up compilation times. Don't use it in computationally expensive functions,
instead extract the required fields and pass them to the computationally expensive function.
"""
struct GenericRefFE{D} <: ReferenceFE{D}
    ndofs::Int
    polytope::Polytope{D}
    prebasis::Field
    dofs::Dof
    facedofids::Vector{Vector{Int}}
    dofperms::Vector{Vector{Int}}
    shapefuns::Field
    reffaces
  @doc """
  """
  function GenericRefFE(
    polytope::Polytope{D},
    prebasis::Field,
    dofs::Dof,
    facedofids::Vector{Vector{Int}};
    shapefuns::Field = compute_shapefuns(dofs,prebasis),
    ndofs::Int = size(evaluate(dofs,prebasis),1),
    dofperms::Vector{Vector{Int}} = [ fill(INVALID_PERM,length(fi)) for fi in facedofids],
    reffaces = nothing) where D

    new{D}(ndofs,polytope,prebasis,dofs,facedofids,dofperms,shapefuns,reffaces)
  end
end

num_dofs(reffe::GenericRefFE) = reffe.ndofs

get_polytope(reffe::GenericRefFE) = reffe.polytope

get_prebasis(reffe::GenericRefFE) = reffe.prebasis

get_dofs(reffe::GenericRefFE) = reffe.dofs

get_face_own_dofids(reffe::GenericRefFE) = reffe.facedofids

get_own_dofs_permutations(reffe::GenericRefFE) = reffe.dofperms

get_shapefuns(reffe::GenericRefFE) = reffe.shapefuns

function ReferenceFE{N}(reffe::GenericRefFE,iface::Integer) where N
  @assert reffe.reffaces != nothing "ReferenceFE cannot be provided. Make sure that you are using the keyword argument reffaces in the GenericRefFE constructor."
  reffe.reffaces[N+1][iface]
end

function ReferenceFE{D}(reffe::GenericRefFE{D},iface::Integer) where D
  @assert iface == 1 "Only one D-face"
  reffe
end

