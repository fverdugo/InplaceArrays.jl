
"""
"""
function change_basis(basis,changeofbasis::AbstractMatrix)
  BasisFromChangeOfBasis(basis,changeofbasis)
end

struct BasisFromChangeOfBasis{B,M} <: Field
  basis::B
  change::M
  function BasisFromChangeOfBasis(basis,change::AbstractMatrix)
    B = typeof(basis)
    M = typeof(change)
    new{B,M}(basis,change)
  end
end

function field_cache(b::BasisFromChangeOfBasis,x)
  cb = field_cache(b.basis,x)
  bx = evaluate_field!(cb,b.basis,x)
  c = CachedArray(bx*b.change)
  (c,cb)
end

function evaluate_field!(cache,b::BasisFromChangeOfBasis,x)
  c, cb = cache
  bx = evaluate_field!(cb,b.basis,x)
  setsize!(c,size(bx))
  mul!(c,bx,b.change)
  c
end

function gradient_cache(b::BasisFromChangeOfBasis,x)
  cb = gradient_cache(b.basis,x)
  bx = evaluate_gradient!(cb,b.basis,x)
  c = CachedArray(bx*b.change)
  (c,cb)
end

function evaluate_gradient!(cache,b::BasisFromChangeOfBasis,x)
  c, cb = cache
  bx = evaluate_gradient!(cb,b.basis,x)
  setsize!(c,size(bx))
  mul!(c,bx,b.change)
  c
end

function hessian_cache(b::BasisFromChangeOfBasis,x)
  cb = hessian_cache(b.basis,x)
  bx = evaluate_hessian!(cb,b.basis,x)
  c = CachedArray(bx*b.change)
  (c,cb)
end

function evaluate_hessian!(cache,b::BasisFromChangeOfBasis,x)
  c, cb = cache
  bx = evaluate_hessian!(cb,b.basis,x)
  setsize!(c,size(bx))
  mul!(c,bx,b.change)
  c
end

