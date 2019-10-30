module ConstantFieldsTests

using InplaceArrays.Arrays
using InplaceArrays.Fields
using TensorValues # TODO

for v in (3.0,VectorValue(1,2))
  d = 2
  f = v
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  fx = fill(v,np)
  ∇fx = fill(zero(v[1]),np)
  test_field(f,x,fx,grad=∇fx)
end

end # module
