"""
"""
abstract type ReferenceFE{D} end

"""
"""
function reffe_polytope(reffe)
  @abstractmethod
end

"""
"""
function reffe_prebasis(reffe)
  @abstractmethod
end

"""
"""
function reffe_dofs(reffe)
  @abstractmethod
end

"""
"""
function reffe_face_dofids(reffe)
  @abstractmethod
end

# optional

"""
"""
function ReferenceFE{N}(reffe,nfaceid) where N
  @abstractmethod
end

"""
"""
function reffe_dof_permutations(reffe)
  @abstractmethod
end

# API

"""
"""
function reffe_shapefuns(reffe)
  dofs = reffe_dofs(reffe)
  prebasis = reffe_prebasis(reffe)
  compute_shapefuns(dofs,prebasis)
end

"""
"""
function compute_shapefuns(dofs,prebasis)
  change = inv(evaluate(dofs,prebasis))
  change_basis(prebasis,change)
end

"""
"""
num_dims(::Type{<:ReferenceFE{D}}) where D = D
num_dims(reffe::T) where T<:ReferenceFE = num_dims(T)

# Test

"""
"""
function test_reference_fe(reffe::ReferenceFE{D}) where D
  @test D == num_dims(reffe)
  p = reffe_polytope(reffe)
  @test isa(p,Polytope{D})
  basis = reffe_prebasis(reffe)
  @test isa(basis,Field)
  dofs = reffe_dofs(reffe)
  @test isa(dofs,Dof)
  facedofs = reffe_face_dofids(reffe)
  @test isa(facedofs,Vector{Vector{Int}})
  @test length(facedofs) == num_faces(p)
end


# Concrete implementation

"""
    struct GenericRefFE{D,P,B,F,I,S} <: ReferenceFE{D}
      polytope::P
      prebasis::B
      dofs::F
      facedofids::I
      shapefuns::S
    end

This type is a *materialization* of the `ReferenceFE` interface. That is, it is a 
`struct` that stores the values of all abstract methods in the `ReferenceFE` interface.
It only implements the required methods, not the optional ones.
This type is useful to build reference FEs from the underlying ingredients without
the need to create a new type.
"""
struct GenericRefFE{D,P,B,F,I,S} <: ReferenceFE{D}
  polytope::P
  prebasis::B
  dofs::F
  facedofids::I
  shapefuns::S
  @doc """
  """
  function GenericRefFE(
    polytope::Polytope{D},
    prebasis::Field,
    dofs::Dof,
    facedofids::Vector{Vector{Int}},
    shapefuns::Field=compute_shapefuns(dofs,prebasis)) where D
    P = typeof(polytope)
    B = typeof(prebasis)
    F = typeof(dofs)
    I = typeof(facedofids)
    S = typeof(shapefuns)
    new{D,P,B,F,I,S}(polytope,prebasis,dofs,facedofids,shapefuns)
  end
end

reffe_polytope(reffe::GenericRefFE) = reffe.polytope

reffe_prebasis(reffe::GenericRefFE) = reffe.prebasis

reffe_dofs(reffe::GenericRefFE) = reffe.dofs

reffe_face_dofids(reffe::GenericRefFE) = reffe.facedofids

reffe_shapefuns(reffe::GenericRefFE) = reffe.shapefuns

