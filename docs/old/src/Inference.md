
# Inferring return types

In Gridap, we rely as less as possible in type inference. But, when needed, we adopt
the following mechanism in order to compute returned types. We do not rely on
the `Base._return_type` function.

```@docs
return_type(f::Function,::Any...)
return_type_broadcast
testargs
testvalue
testvalues
```
