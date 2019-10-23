module InferenceTests

using Test
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis
using TensorValues

v = 3.0
d = 2
f = MockField(d,v)
∇f = gradient(f)

@test gradtype(f) == typeof(∇f.v)
@test gradtype(∇f) == MultiValue{Tuple{2,2},Float64,2,4}

end # module
