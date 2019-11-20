"""
"""
abstract type ReferenceFE{D} end

"""
"""
function num_dofs(reffe::ReferenceFE)
  @abstractmethod
end

"""
"""
function get_polytope(reffe::ReferenceFE)
  @abstractmethod
end

"""
"""
function get_prebasis(reffe::ReferenceFE)
  @abstractmethod
end

"""
"""
function get_dofs(reffe::ReferenceFE)
  @abstractmethod
end

"""
"""
function get_face_dofids(reffe::ReferenceFE)
  @abstractmethod
end

# optional

"""
"""
function ReferenceFE{N}(reffe::ReferenceFE,nfaceid::Integer) where N
  @abstractmethod
end

"""
"""
function get_dof_permutations(reffe::ReferenceFE)
  @abstractmethod
end

# API

"""
"""
function get_shapefuns(reffe::ReferenceFE)
  dofs = get_dofs(reffe)
  prebasis = get_prebasis(reffe)
  compute_shapefuns(dofs,prebasis)
end

"""
"""
function compute_shapefuns(dofs,prebasis)
  change = inv(evaluate(dofs,prebasis))
  change_basis(prebasis,change)
end

num_dims(::Type{<:ReferenceFE{D}}) where D = D

"""
"""
num_dims(reffe::ReferenceFE) = num_dims(typeof(reffe))

# Test

"""
"""
function test_reference_fe(reffe::ReferenceFE{D}) where D
  @test D == num_dims(reffe)
  p = get_polytope(reffe)
  @test isa(p,Polytope{D})
  basis = get_prebasis(reffe)
  @test isa(basis,Field)
  dofs = get_dofs(reffe)
  @test isa(dofs,Dof)
  facedofs = get_face_dofids(reffe)
  @test isa(facedofs,Vector{Vector{Int}})
  @test length(facedofs) == num_faces(p)
  shapefuns = get_shapefuns(reffe)
  @test isa(shapefuns,Field)
  ndofs = num_dofs(reffe)
  m = evaluate(dofs,basis)
  @test ndofs == size(m,1)
  @test ndofs == size(m,2)
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

get_face_dofids(reffe::GenericRefFE) = reffe.facedofids

get_dof_permutations(reffe::GenericRefFE) = reffe.dofperms

get_shapefuns(reffe::GenericRefFE) = reffe.shapefuns

function ReferenceFE{N}(reffe::GenericRefFE,iface::Integer) where N
  @assert reffe.reffaces != nothing "ReferenceFE cannot be provided. Make sure that you are using the keyword argument reffaces in the GenericRefFE constructor."
  reffe.reffaces[N+1][iface]
end

function ReferenceFE{D}(reffe::GenericRefFE{D},iface::Integer) where D
  @assert iface == 1 "Only one D-face"
  reffe
end

