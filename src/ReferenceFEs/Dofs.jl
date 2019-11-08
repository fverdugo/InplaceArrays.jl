
"""
    abstract type Dof <: Kernel

Abstract type representing a degree of freedom (DOF), a basis of DOFs, and related objects.
These different cases are distinguished by the return type obtained when evaluating the `Dof`
object on a `Field` object.
When a dof is evaluated on a physical field, a scalar number is returned. If either
the `Dof` object is a basis of DOFs, or the `Field` object is a basis of fields,
or both objects are bases, then the returned object is an array of scalar numbers. The first
dimensions in the resulting array are for the `Dof` object and the last ones for the `Field`
object. E.g, a basis of `nd` DOFs evaluated at physical field returns a vector of `nd` entries.
A basis of `nd` DOFs evaluated at a basis of `nf` fields returns a matrix of size `(nd,nf)`.

The following functions needs to be overloaded

- [`dof_cache`](@ref)
- [`evaluate_dof!`](@ref)

The following functions can be overloaded optionally

- [`dof_return_type`](@ref)

In most of the cases it is not strictly needed that types that implement this interface
inherit from `Dof`. However, we recommend to inherit from `Dof`, when possible.

"""
abstract type Dof <: Kernel end

"""
"""
function dof_cache(dof,field)
  @abstractmethod
end

"""
"""
function evaluate_dof!(dof,field)
  @abstractmethod
end

"""
"""
function dof_return_type(dof,field)
  typeof(evaluate_dof(dof,field))
end

# Testers

function test_dof(dof,field,v,comp::Function=(==))
  if isa(dof,Dof)
    test_kernel(dof,(field,),v,comp)
  end
  r = evaluate_dof(dof,field)
  @test comp(r,v)
  @test typeof(r) == dof_return_type(dof,field)
end

# Implement Kernel interface

@inline kernel_cache(dof::Dof,field) = dof_cache(dof,field)

@inline apply_kernel!(cache,dof::Dof,field) = evaluate_dof!(cache,dof,field)

@inline kernel_return_type(dof::Dof,field) = dof_return_type(dof,field)

# Some API

"""
"""
function evaluate_dof(dof,field)
  cache = dof_cache(dof,field)
  evaluate_dof!(cache,dof,field)
end

"""
"""
evaluate(dof::Dof,field) = evaluate_dof(dof,field)

# Working with arrays of Dofs

"""
"""
function evaluate_dof_array(dof::AbstractArray,field::AbstractArray)
  k = DofEval()
  apply(k,dof,field)
end

function evaluate_dof_array(dof::AbstractArray{<:Dof},field::AbstractArray)
  apply(dof,field)
end

"""
"""
function evaluate(dof::AbstractArray{<:Dof},field::AbstractArray)
  evaluate_dof_array(dof,field)
end

struct DofEval <: Kernel end

function kernel_cache(k::DofEval,dof,field)
  dof_cache(dof,field)
end

@inline function apply_kernel!(cache,k::DofEval,dof,field)
  evaluate_dof!(cache,dof,field)
end

function kernel_return_type(k::DofEval,dof,field)
  dof_return_type(dof,field)
end

