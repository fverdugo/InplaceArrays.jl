var documenterSearchIndex = {"docs":
[{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"CurrentModule = InplaceArrays.Fields","category":"page"},{"location":"Fields/#Gridap.Fields-1","page":"Gridap.Fields","title":"Gridap.Fields","text":"","category":"section"},{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"Fields","category":"page"},{"location":"Fields/#InplaceArrays.Fields","page":"Gridap.Fields","title":"InplaceArrays.Fields","text":"This module provides:\n\nAn interface for physical fields and basis of physical fields.\nHelpers functions to work with fields and basis.\nHelpers functions to create lazy operation trees from fields and arrays of fields\n\nThe exported names are:\n\nBasis\nField\nPoint\napply_kernel_to_field\napply_to_field\ncompose\nevaluate\nevaluate!\nfield_cache\nfield_return_type\ngradient\nlincomb\npointdim\ntest_array_of_fields\ntest_field\nvaluetype\n∇\n\n\n\n\n\n","category":"module"},{"location":"Fields/#Interface-1","page":"Gridap.Fields","title":"Interface","text":"","category":"section"},{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"Field\nBasis\nPoint\nevaluate!(cache,f::Field,x::Point)\nfield_cache(f::Field,x::Point)\ngradient(::Field)\n∇(::Field)\nfield_return_type(f::Field,x::Point)\nevaluate!(cache,f::Field,x::AbstractVector{<:Point})\nfield_cache(f::Field,x::AbstractVector{<:Point})\nfield_return_type(f::Field,x::AbstractVector{<:Point})\ntest_field","category":"page"},{"location":"Fields/#InplaceArrays.Fields.Field","page":"Gridap.Fields","title":"InplaceArrays.Fields.Field","text":"abstract type Field{V,D} <: Kernel\n\nAbstract type representing physical field, basis of fields, and other related objects. \n\nD is the number of components of the points where the field can be evaluated.\nV has to be a type <:Number if the field returns a number when evaluated at a single point.\nV has to be a type <:AbstractArray if the field returns an array when evaluated at a single point. E.g., for basis of fields V is a type <:AbstractVector.\nNote that eltype(V) is allowed to be any number type since the actual returned type can depend in general on the particular type of the evaluation point components.\n\nThe following functions need to be overloaded for derived types:\n\nevaluate!(cache,f::Field,x::Point)\nfield_cache(f::Field,x::Point)\n\nThe following functions can be also provided optionally\n\ngradient(f::Field)\nfield_return_type(f::Field,x::Point)\n\nThe following vectorized versions can be (optionally) rewritten for specific types to improve performance:\n\nevaluate!(cache,f::Field,x::AbstractVector{<:Point})\nfield_cache(f::Field,x::AbstractVector{<:Point})\nfield_return_type(f::Field,x::AbstractVector{<:Point})\n\nThe interface can be tested with\n\ntest_field\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.Basis","page":"Gridap.Fields","title":"InplaceArrays.Fields.Basis","text":"const Basis = Field{V,D} where {V<:AbstractVector, D}\n\nAlias for the particular case, where the field returns a vector of values.\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.Point","page":"Gridap.Fields","title":"InplaceArrays.Fields.Point","text":"const Point{D,T} = VectorValue{D,T}\n\nType representing a point of D dimensions with coordinates of type T\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.evaluate!-Tuple{Any,InplaceArrays.Fields.Field,TensorValues.MultiValue{Tuple{D},T,1,D} where T where D}","page":"Gridap.Fields","title":"InplaceArrays.Fields.evaluate!","text":"evaluate!(cache,f::Field,x::Point)\n\nReturns the value of field at point x. The value of a field is typically a number or an array. When the value is a vector, the field is in fact a basis.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.field_cache-Tuple{InplaceArrays.Fields.Field,TensorValues.MultiValue{Tuple{D},T,1,D} where T where D}","page":"Gridap.Fields","title":"InplaceArrays.Fields.field_cache","text":"field_cache(f::Field,x::Point)\n\nReturns the cache object needed to evaluate field f at point x.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.gradient-Tuple{InplaceArrays.Fields.Field}","page":"Gridap.Fields","title":"InplaceArrays.Fields.gradient","text":"gradient(f::Field) -> Field\n\nReturns another field that represents the gradient of the given one\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.∇-Tuple{InplaceArrays.Fields.Field}","page":"Gridap.Fields","title":"InplaceArrays.Fields.∇","text":"gradient(f::Field) -> Field\n\nReturns another field that represents the gradient of the given one\n\n\n\n\n\ngradient(k::Kernel,f::Field...)\n\nReturns a field representing the gradient of the field obtained with\n\napply_kernel_to_field(k,f...)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.field_return_type-Tuple{InplaceArrays.Fields.Field,TensorValues.MultiValue{Tuple{D},T,1,D} where T where D}","page":"Gridap.Fields","title":"InplaceArrays.Fields.field_return_type","text":"field_return_type(f::Field,x::Point)\n\nComputes the type obtained when evaluating field f at point x.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.evaluate!-Tuple{Any,InplaceArrays.Fields.Field,AbstractArray{#s3,1} where #s3<:(TensorValues.MultiValue{Tuple{D},T,1,D} where T where D)}","page":"Gridap.Fields","title":"InplaceArrays.Fields.evaluate!","text":"evaluate!(cache,f::Field,x::AbstractVector{<:Point})\n\nVectorized version of evaluate!(f::Field,x::Point). \n\nFor fields f with valuetype(f)<:Number, it returns a vector with the value of f at each of the point in x. \n\nFor Fields f with valuetype(f)<:AbstractArray, it returns an array with one dimension more than the value of the field. E.g., for basis, it should return a matrix. The axis associated with the points x is the last axis in the resulting array. E.g., for a basis with ndof degrees of freedom, the returned matrix has size (ndof,length(x)) .\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.field_cache-Tuple{InplaceArrays.Fields.Field,AbstractArray{#s3,1} where #s3<:(TensorValues.MultiValue{Tuple{D},T,1,D} where T where D)}","page":"Gridap.Fields","title":"InplaceArrays.Fields.field_cache","text":"field_cache(f::Field,x::AbstractVector{<:Point})\n\nReturns the cache object needed to evaluate the field f at the vector of points x by means of the vectorized version of evaluate!.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.field_return_type-Tuple{InplaceArrays.Fields.Field,AbstractArray{#s3,1} where #s3<:(TensorValues.MultiValue{Tuple{D},T,1,D} where T where D)}","page":"Gridap.Fields","title":"InplaceArrays.Fields.field_return_type","text":"field_return_type(f::Field,x::AbstractVector{<:Point})\n\nReturns the type of the object obtained when the field f is evaluated at the vector of points x by means of the vectorized version of evaluate!.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.test_field","page":"Gridap.Fields","title":"InplaceArrays.Fields.test_field","text":"test_field(\n  f::Field,\n  x::AbstractVector{<:Point},\n  v::AbstractArray,cmp=(==);\n  grad=nothing)\n\nFunction used to test the field interface.\n\n\n\n\n\n","category":"function"},{"location":"Fields/#Other-functions-using-fields-1","page":"Gridap.Fields","title":"Other functions using fields","text":"","category":"section"},{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"evaluate(f::Field,x)\nvaluetype(::Type{<:Field})\npointdim(::Type{<:Field})\ncompose(g::Function,f...)\nlincomb(a::Basis,b::AbstractVector)","category":"page"},{"location":"Fields/#InplaceArrays.Fields.valuetype-Tuple{Type{#s3} where #s3<:InplaceArrays.Fields.Field}","page":"Gridap.Fields","title":"InplaceArrays.Fields.valuetype","text":"valuetype(::Type{Field{T,D}}) where {T,D}\n\nReturns T\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.pointdim-Tuple{Type{#s3} where #s3<:InplaceArrays.Fields.Field}","page":"Gridap.Fields","title":"InplaceArrays.Fields.pointdim","text":"pointdim(::Type{Field{T,D}}) where {T,D}\n\nReturns D\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.compose-Tuple{Function,Vararg{Any,N} where N}","page":"Gridap.Fields","title":"InplaceArrays.Fields.compose","text":"compose(g::Function,f...)\n\nReturns a new field obtained by composition of function g and the fields f. The value of the resulting field at point x is numerically equivalent to\n\nfx = [ evaluate(fi,x) for fi in f]\napply_kernel(elem(g), fx...)\n\nThe gradient of the resulting field evaluated at point x is equivalent to\n\nfx = [ evaluate(fi,x) for fi in f]\napply_kernel(elem(gradient(g)), fx...)\n\nNote that it is needed to overload gradient(::typeof(g)) for the given function g in order to be able to compute the gradient.\n\nAs in function apply_kernel_to_field if any of the inputs in f is a number or an array instead of a field it will be treated as a \"constant field\".\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.lincomb-Tuple{InplaceArrays.Fields.Field{#s26,D} where D where #s26<:(AbstractArray{T,1} where T),AbstractArray{T,1} where T}","page":"Gridap.Fields","title":"InplaceArrays.Fields.lincomb","text":"lincomb(a::Basis,b::AbstractVector)\n\nReturns a field f with valuetype(f) <: Number obtained by the \"linear combination\" of the value of the basis a and the vector b. That is, the value of the resulting field f at a point x is defined as\n\nk = contract(outer)\nax = evaluate(a,x)\napply_kernel(k,ax,b)\n\nOn the other hand, the gradient of the resulting field is defined as\n\nk = contract(outer)\n∇ax = evaluate(gradient(a),x)\napply_kernel(k,∇ax,b)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#Applying-kernels-to-fields-1","page":"Gridap.Fields","title":"Applying kernels to fields","text":"","category":"section"},{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"apply_kernel_to_field(k::Kernel,f::FieldNumberOrArray{D}...) where D\ngradient(k::Kernel,f::Field...)","category":"page"},{"location":"Fields/#InplaceArrays.Fields.apply_kernel_to_field-Union{Tuple{D}, Tuple{InplaceArrays.Arrays.Kernel,Vararg{Union{Number, AbstractArray, InplaceArrays.Fields.Field{T,D} where T},N} where N}} where D","page":"Gridap.Fields","title":"InplaceArrays.Fields.apply_kernel_to_field","text":"apply_kernel_to_field(k::Kernel,f...) -> Field\n\nReturns a field obtained by applying the kernel k to the  values of the fields in f. That is, the returned field evaluated at a point x provides the value obtained by applying kernel k to the values of the fields f at point x. Formally, the resulting field at a point  x is defined as\n\nfx = [ evaluate(fi,x) for fi in f]\napply_kernel(k,fx...)\n\nif any of the inputs in f is a number or an array of numbers instead of a field it will be treated as a \"constant field\". That is a filed that evaluated at any point x returns always the underlying number or array.\n\nIn order to be able to call the gradient function of the resulting field, one needs to define the gradient operator associated with the underlying kernel. This is done by adding a new method gradient(k::Kernel,f::Field...) for each kernel type.\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.gradient-Tuple{InplaceArrays.Arrays.Kernel,Vararg{InplaceArrays.Fields.Field,N} where N}","page":"Gridap.Fields","title":"InplaceArrays.Fields.gradient","text":"gradient(k::Kernel,f::Field...)\n\nReturns a field representing the gradient of the field obtained with\n\napply_kernel_to_field(k,f...)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#Working-with-arrays-of-fields-1","page":"Gridap.Fields","title":"Working with arrays of fields","text":"","category":"section"},{"location":"Fields/#","page":"Gridap.Fields","title":"Gridap.Fields","text":"evaluate(::AbstractArray{<:Field},::AbstractArray)\ngradient(::AbstractArray{<:Field})\napply_to_field(k::Kernel,f::AbstractArray...)\nfield_cache(::AbstractArray{<:Field},::AbstractArray)\ncompose(g::Function,f::AbstractArray...)\nlincomb(a::AbstractArray{<:Field},b::AbstractArray)\ntest_array_of_fields","category":"page"},{"location":"Fields/#InplaceArrays.Fields.evaluate-Tuple{AbstractArray{#s3,N} where N where #s3<:InplaceArrays.Fields.Field,AbstractArray}","page":"Gridap.Fields","title":"InplaceArrays.Fields.evaluate","text":"evaluate(a::AbstractArray{<:Field},x::AbstractArray)\n\nEvaluates the fields in the array a at the locations provided in the array x (which can be an array of points or an array of vectors of points).\n\nThe result is numerically equivalent to \n\nmap(evaluate,a,x)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.gradient-Tuple{AbstractArray{#s3,N} where N where #s3<:InplaceArrays.Fields.Field}","page":"Gridap.Fields","title":"InplaceArrays.Fields.gradient","text":"gradient(a::AbstractArray{<:Field})\n\nReturns an array containing the gradients of the fields in the array a. Numerically equivalent to \n\nmap(gradient,a)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.field_cache-Tuple{AbstractArray{#s3,N} where N where #s3<:InplaceArrays.Fields.Field,AbstractArray}","page":"Gridap.Fields","title":"InplaceArrays.Fields.field_cache","text":"field_cache(a::AbstractArray{<:Field},x::AbstractArray) -> Tuple\n\nReturns the caches needed to perform the following iteration\n\nca, cfi, cx = field_cache(a,x)\n\nfor i in length(a)\n  fi = getindex!(ca,a,i)\n  xi = getindex!(cx,x,i)\n  fxi = evaluate!(cfi,fi,xi)\nend\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.compose-Tuple{Function,Vararg{AbstractArray,N} where N}","page":"Gridap.Fields","title":"InplaceArrays.Fields.compose","text":"compose(g::Function,f::AbstractArray...)\n\nReturns an array of fields numerically equivalent to\n\nmap( (x...)->compose(g,x...), f...)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.lincomb-Tuple{AbstractArray{#s3,N} where N where #s3<:InplaceArrays.Fields.Field,AbstractArray}","page":"Gridap.Fields","title":"InplaceArrays.Fields.lincomb","text":"lincomb(a::AbstractArray{<:Field},b::AbstractArray)\n\nReturns an array of field numerically equivalent to\n\nmap(lincomb,a,b)\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.test_array_of_fields","page":"Gridap.Fields","title":"InplaceArrays.Fields.test_array_of_fields","text":"function test_array_of_fields(\n  a::AbstractArray{<:Field},\n  x::AbstractArray,\n  v::AbstractArray,\n  cmp::Function=(==);\n  grad = nothing)\n\nFunction to test an array of fields.\n\n\n\n\n\n","category":"function"},{"location":"Inference/#","page":"Gridap.Inference","title":"Gridap.Inference","text":"CurrentModule = InplaceArrays.Inference","category":"page"},{"location":"Inference/#Gridap.Inference-1","page":"Gridap.Inference","title":"Gridap.Inference","text":"","category":"section"},{"location":"Inference/#","page":"Gridap.Inference","title":"Gridap.Inference","text":"Inference\nreturn_type(f::Function,::Any...)\nreturn_type_broadcast\ntestargs\ntestargs_broadcast\ntestvalue\ntestvalues","category":"page"},{"location":"Inference/#InplaceArrays.Inference","page":"Gridap.Inference","title":"InplaceArrays.Inference","text":"This module provides a set of helper function to safely infer return types of functions.\n\nIn Gridap, we rely as less as possible in type inference. But, when needed, we adopt the following mechanism in order to compute returned types. We do not rely on the Base._return_type function.\n\nThis module exports following functions:\n\nreturn_type\nreturn_type_broadcast\ntestargs\ntestargs_broadcast\ntestvalue\ntestvalues\n\n\n\n\n\n","category":"module"},{"location":"Inference/#InplaceArrays.Inference.return_type-Tuple{Function,Vararg{Any,N} where N}","page":"Gridap.Inference","title":"InplaceArrays.Inference.return_type","text":"return_type(f::Function, Ts::Vararg{Any,N} where N) -> DataType\n\n\nReturns the type returned by function f when called with arguments of the types in Ts.\n\nThe underlying implementation uses the function testargs to generate some test values in order to call the function and determine the returned type. This mechanism does not use Base._return_type. One of the advantages is that the given function f is called, and thus, meaningful error messages will be displayed if there is any error in f. \n\n\n\n\n\n","category":"method"},{"location":"Inference/#InplaceArrays.Inference.return_type_broadcast","page":"Gridap.Inference","title":"InplaceArrays.Inference.return_type_broadcast","text":"return_type_broadcast(f::Function,Ts::DataType...) -> DataType\n\nLike return_type, but when function f is used in a broadcast operation.\n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testargs","page":"Gridap.Inference","title":"InplaceArrays.Inference.testargs","text":"testargs(f::Function,Ts::DataType...) -> Tuple\n\nReturns a tuple with valid arguments of the types in Ts in order to call function f. It defaults to testvalues(Ts...), see the testvalues function. The user can overload the testargs function for particular functions if the default test arguments are not in the domain of the function and a DomainError is raised.\n\nExamples\n\nFor the following function, the default test argument (which is a zero) is not in the domain. We can overload the testargs function to provide a valid test argument.\n\nusing InplaceArrays.Inference\nimport InplaceArrays.Inference: testargs\nfoo(x) = sqrt(x-1)\ntestargs(::typeof(foo),T::DataType) = (one(T),)\nreturn_type(foo, Int)\n# output\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testargs_broadcast","page":"Gridap.Inference","title":"InplaceArrays.Inference.testargs_broadcast","text":"testargs_broadcast(f, Ts)\n\n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testvalue","page":"Gridap.Inference","title":"InplaceArrays.Inference.testvalue","text":"testvalue(::Type{T}) where T\n\nReturns an arbitrary instance of type T. It defaults to zero(T) for non-array types and to an empty array for array types. This function is used to compute the default test arguments in testargs. It can be overloaded for new types T if zero(T) does not makes sense. \n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testvalues","page":"Gridap.Inference","title":"InplaceArrays.Inference.testvalues","text":"testvalues(Ts::DataType...) -> Tuple\n\nReturns a tuple with test values for each of the types in Ts. Equivalent to map(testvalue,Ts).\n\n\n\n\n\n","category":"function"},{"location":"Gridap/#Gridap-1","page":"Gridap","title":"Gridap","text":"","category":"section"},{"location":"Gridap/#","page":"Gridap","title":"Gridap","text":"InplaceArrays","category":"page"},{"location":"Gridap/#InplaceArrays","page":"Gridap","title":"InplaceArrays","text":"Gridap, grid-based approximation of PDEs in the Julia programming language\n\nThis module provides rich set of tools for the numerical solution of PDE, mainly based on finite element methods.\n\nThe module is structured in the following sub-modules:\n\nInplaceArrays.Helpers\nInplaceArrays.Inference\nInplaceArrays.Arrays\nInplaceArrays.Fields\n\nThe exported names are:\n\napply\narray_cache\nbcast\ngetindex!\n\n\n\n\n\n","category":"module"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"CurrentModule = InplaceArrays.Arrays","category":"page"},{"location":"Arrays/#Gridap.Arrays-1","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"Arrays","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays","page":"Gridap.Arrays","title":"InplaceArrays.Arrays","text":"This module provides:\n\nAn extension of the AbstractArray interface in order to properly deal with mutable caches.\nA mechanism to generate lazy arrays resulting from operations between arrays.\nA collection of concrete implementations of AbstractArray.\n\nThe exported names in this module are:\n\nCachedArray\nCachedMatrix\nCachedVector\nKernel\napply\napply_all\napply_kernel\napply_kernel!\napply_kernels!\narray_cache\narray_caches\nbcast\ncontract\nelem\nf2k\ngetindex!\ngetitems!\nkernel_cache\nkernel_caches\nkernel_return_type\nkernel_return_types\nsetsize!\ntest_array\ntest_kernel\ntestitem\ntestitems\nuses_hash\n\n\n\n\n\n","category":"module"},{"location":"Arrays/#Extended-AbstractArray-interface-1","page":"Gridap.Arrays","title":"Extended AbstractArray interface","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"When implementing new array types, it can be needed some scratch data (e.g., allocating the output), when recovering an item from an array (typically if the array elements are non-isbits objects). To circumvent this, the user could provide the scratch data needed when getting an item. However, the Julia array interface does not support this approach. When calling a[i], in order to get the element with index i in array a, there is no extra argument for the scratch data. In order to solve this problem, we add new methods to the AbstractArray interface of Julia. We provide default implementations to the new methods, so that any AbstractArray can be used with the extended interface. New array implementations can overload these default implementations to improve performance. The most important among the new methods is getindex!, which allows to recover an item in the array by passing some scratch data.","category":"page"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"The new methods are:","category":"page"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"getindex!(cache,a::AbstractArray,i...)\narray_cache(a::AbstractArray)\nuses_hash(::Type{<:AbstractArray})\ntestitem(a::AbstractArray)","category":"page"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"These methods can be stressed with the following function","category":"page"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"test_array","category":"page"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"getindex!(cache,a::AbstractArray,i...)\ngetitems!\narray_cache(a::AbstractArray)\narray_caches\nuses_hash(::Type{<:AbstractArray})\ntestitem(a::AbstractArray)\ntestitems\ntest_array","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.getindex!-Tuple{Any,AbstractArray,Vararg{Any,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.getindex!","text":"getindex!(cache,a::AbstractArray,i...)\n\nReturns the item of the array a associated with index i by (possibly) using the scratch data passed in the cache object.\n\nIt defaults to\n\ngetindex!(cache,a::AbstractArray,i...) = a[i...]\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.getitems!","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.getitems!","text":"getitems!(c::Tuple,a::Tuple,i...) -> Tuple\n\nExtracts the i-th entry of all arrays in the tuple a using the caches in the tuple c. The results is a tuple containing each one of the extracted entries.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.array_cache-Tuple{AbstractArray}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.array_cache","text":"array_cache(a::AbstractArray)\n\nReturns a cache object to be used in the getindex! function. It defaults to \n\narray_cache(a::T) where T = nothing\n\nfor types T such that uses_hash(T) == Val(false), and \n\nfunction array_cache(a::T) where T\n  hash = Dict{UInt,Any}()\n  array_cache(hash,a)\nend\n\nfor types T such that uses_hash(T) == Val(true), see the uses_hash function. In the later case, the type T should implement the following signature:\n\narray_cache(hash::Dict,a::AbstractArray)\n\nwhere we pass a dictionary (i.e., a hash table) in the first argument. This hash table can be used to test if the object a has already build a cache and re-use it as follows\n\nid = objectid(a)\nif haskey(hash,id)\n  cache = hash[id] # Reuse cache\nelse\n  cache = ... # Build a new cache depending on your needs\n  hash[id] = cache # Register the cache in the hash table\nend\n\nThis mechanism is needed, e.g., to re-use intermediate results in complex lazy operation trees. In multi-threading computations, a different hash table per thread has to be used in order to avoid race conditions.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.array_caches","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.array_caches","text":"array_caches(a::AbstractArray...) -> Tuple\n\nReturns a tuple with the cache of each array in a.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.uses_hash-Tuple{Type{#s3} where #s3<:AbstractArray}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.uses_hash","text":"uses_hash(::Type{<:AbstractArray})\n\nThis function is used to specify if the type T uses the hash-based mechanism to reuse caches.  It should return either Val(true) or Val(false). It defaults to\n\nuses_hash(::Type{<:AbstractArray}) = Val(false)\n\nOnce this function is defined for the type T it can also be called on instances of T.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.testitem-Tuple{AbstractArray}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.testitem","text":"Returns an arbitrary instance of eltype(a). The default returned value is the first entry in the array if length(a)>0 and testvalue(eltype(a)) if length(a)==0 See the testvalue function.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.testitems","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.testitems","text":"testitems(b::AbstractArray...) -> Tuple\n\nReturns a tuple with the result of testitem applied to each of the arrays in b.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.test_array","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.test_array","text":"test_array(\n  a::AbstractArray{T,N}, b::AbstractArray{S,N},cmp=(==)) where {T,S,N}\n\nChecks if the entries in a and b are equal using the comparison function cmp. It also stresses the new methods added to the AbstractArray interface interface.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Creting-lazy-operation-trees-1","page":"Gridap.Arrays","title":"Creting lazy operation trees","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"apply(f::Kernel,a::AbstractArray...)\napply(f::Function,a::AbstractArray...)\napply(f::AbstractArray,a::AbstractArray...)\napply_all","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.apply-Tuple{InplaceArrays.Arrays.Kernel,Vararg{AbstractArray,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply","text":"apply(f::Kernel,a::AbstractArray...) -> AbstractArray\n\nApplies the kernel f to the entries of the arrays in a (see the definition of Kernel).\n\nThe resulting array r is such that r[i] equals to apply_kernel(f,ai...) where ai is the tuple containing the i-th entry of the arrays in a (see function apply_kernel for more details). In other words, the resulting array is numerically equivalent to:\n\nmap( (x...)->apply_kernel(f,x...), a...)\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.apply-Tuple{Function,Vararg{AbstractArray,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply","text":"apply(f::Function, a::AbstractArray...)\n\nSyntactic sugar for apply(f2k(f),a...).  See the meaning of function f2k for more details.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.apply-Tuple{AbstractArray,Vararg{AbstractArray,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply","text":"apply(f::AbstractArray,a::AbstractArray...) -> AbstractArray\n\nApplies the kernels in the array of kernels f to the entries in the arrays in a.\n\nThe resulting array has the same entries as the one obtained with:\n\nmap( apply_kernel, f, a...)\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.apply_all","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply_all","text":"apply_all(f::Tuple,a::AbstractArray...) -> Tuple\n\nNumerically equivalent to \n\ntuple( ( apply(fi, a...) for fi in f)... )\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Operation-kernels-1","page":"Gridap.Arrays","title":"Operation kernels","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"Kernel\napply_kernel!(cache,f::Kernel,x...)\nkernel_cache(f::Kernel,x...)\nkernel_return_type(f::Kernel,x...)\ntest_kernel\napply_kernel\napply_kernels!\nkernel_caches\nkernel_return_types","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.Kernel","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.Kernel","text":"Abstract type representing operations to be used in the apply function.\n\nDerived types must implement the following method:\n\napply_kernel!(cache,k::Kernel,x...)\n\nand optionally these ones:\n\nkernel_cache(k::Kernel,x...)\nkernel_return_type(k::Kernel,x...)\n\nThe kernel interface can be tested with the test_kernel function.\n\n\n\n\n\n","category":"type"},{"location":"Arrays/#InplaceArrays.Arrays.apply_kernel!-Tuple{Any,InplaceArrays.Arrays.Kernel,Vararg{Any,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply_kernel!","text":"apply_kernel!(cache, f, x)\n\n\napplies the kernel f at the arguments x... using the scratch data provided in the given cache object. The cache object is built with the kernel_cache function using arguments of the same type as in x... In general, the returned value y can share some part of its state with the cache object. If the result of two or more invocations of this function need to be accessed simultaneously (e.g., in multi-threading), create and use various cache objects (e.g., one cache per thread).\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.kernel_cache-Tuple{InplaceArrays.Arrays.Kernel,Vararg{Any,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.kernel_cache","text":"kernel_cache(f, x)\n\n\nReturns the cache needed to apply kernel f with arguments of the same type as the objects in x.... This function returns nothing by default.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.kernel_return_type-Tuple{InplaceArrays.Arrays.Kernel,Vararg{Any,N} where N}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.kernel_return_type","text":"kernel_return_type(f, x)\n\n\nReturns the type of the result of calling kernel f with arguments of the types of the objects x.\n\nIt defaults to typeof(apply_kernel(f,x...))\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.test_kernel","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.test_kernel","text":"test_kernel(f, x, y)\ntest_kernel(f, x, y, cmp)\n\n\nFunction used to test if the kernel f has been implemented correctly. f is a kernel object, x is the input of the kernel, and y is the expected result. Function cmp is used to compare the computed result with the expected one. The checks are done with the @test macro.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.apply_kernel","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply_kernel","text":"apply_kernel(f,x...)\n\napply the fuctor f at the arguments x... by creating a temporary cache internally. This functions is equivalent to\n\ncache = kernel_cache(f,x...)\napply_kernel!(cache,f,x...)\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.apply_kernels!","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.apply_kernels!","text":"apply_kernels!(caches::Tuple,fs::Tuple,x...) -> Tuple\n\nApplies the kernels in the tuple fs at the arguments x... by using the corresponding cache objects in the tuple caches. The result is also a tuple containing the result for each kernel in fs.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.kernel_caches","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.kernel_caches","text":"kernel_caches(fs::Tuple,x...) -> Tuple\n\nReturns a tuple with the cache corresponding to each kernel in fs for the arguments x....\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.kernel_return_types","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.kernel_return_types","text":"kernel_return_types(f::Tuple,x...) -> Tuple\n\nComputes the return types of the kernels in f when called with arguments x.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Build-in-kernels-1","page":"Gridap.Arrays","title":"Build-in kernels","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"f2k\nbcast\nelem\ncontract","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.f2k","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.f2k","text":"f2k(f::Function)\n\nTransforms function f to a kernel. Applying the resulting kernel object is numerically equivalent to evaluating the function.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.bcast","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.bcast","text":"bcast(f::Function)\n\nReturns a kernel object that represents the \"boradcasted\" version of the given function f.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.elem","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.elem","text":"elem(f::Function)\n\nReturns a kernel that represents the element-wise version of the operation f It does not broadcast in singleton axes. Thus, allows some performance optimizations with respect to broadcast.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.contract","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.contract","text":"contract(f::Function)\n\nLike the dot product between to vectors, but using operation f instead of * between components.\n\nExamples\n\nusing InplaceArrays.Arrays\nk = contract(-)\napply_kernel(k,[1,2],[2,4]) # Equivalent to (1-2) + (2-4)\n# output\n-3\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Concrete-array-implementations-1","page":"Gridap.Arrays","title":"Concrete array implementations","text":"","category":"section"},{"location":"Arrays/#CachedArray-1","page":"Gridap.Arrays","title":"CachedArray","text":"","category":"section"},{"location":"Arrays/#","page":"Gridap.Arrays","title":"Gridap.Arrays","text":"CachedArray\nCachedArray(a::AbstractArray)\nCachedArray(T,N)\nsetsize!\nCachedMatrix\nCachedVector","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.CachedArray","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.CachedArray","text":"mutable struct CachedArray{T, N, A<:AbstractArray{T,N}} <: AbstractArray{T,N}\n\nType providing a re-sizable array that only allocates memory when the underlying buffer needs to grow.\n\nThe size of a CachedArray is changed via the setsize! function.\n\nA CachedArray can be build with the constructors\n\nCachedArray(a::AbstractArray)\nCachedArray(T,N)\n\nusing InplaceArrays.Arrays\n# Create an empty CachedArray\na = CachedArray(Float64,2)\n# Resize to new shape (2,3)\nsetsize!(a,(2,3))\nsize(a)\n# output\n(2, 3)\n\n\n\n\n\n","category":"type"},{"location":"Arrays/#InplaceArrays.Arrays.CachedArray-Tuple{AbstractArray}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.CachedArray","text":"CachedArray(a::AbstractArray)\n\nConstructs a CachedArray from a given array.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.CachedArray-Tuple{Any,Any}","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.CachedArray","text":"CachedArray(T,N)\n\nConstructs an empty CachedArray of element type T and N dimensions.\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.setsize!","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.setsize!","text":"setsize!(a, s)\n\n\nChanges the size of the CachedArray a to the size described the the tuple s. After calling setsize!, the array can store uninitialized values.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.CachedMatrix","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.CachedMatrix","text":"const CachedMatrix{T,A} = CachedArray{T,2,A}\n\n\n\n\n\n","category":"type"},{"location":"Arrays/#InplaceArrays.Arrays.CachedVector","page":"Gridap.Arrays","title":"InplaceArrays.Arrays.CachedVector","text":"const CachedVector{T,A} = CachedArray{T,1,A}\n\n\n\n\n\n","category":"type"},{"location":"Helpers/#","page":"Gridap.Helpers","title":"Gridap.Helpers","text":"CurrentModule = InplaceArrays.Helpers","category":"page"},{"location":"Helpers/#Gridap.Helpers-1","page":"Gridap.Helpers","title":"Gridap.Helpers","text":"","category":"section"},{"location":"Helpers/#","page":"Gridap.Helpers","title":"Gridap.Helpers","text":"Modules = [Helpers,]","category":"page"},{"location":"Helpers/#InplaceArrays.Helpers","page":"Gridap.Helpers","title":"InplaceArrays.Helpers","text":"This module provides a set of helper macros.\n\nThe exported macros are:\n\n@abstractmethod\n@notimplemented\n@notimplementedif\n@unreachable\n\n\n\n\n\n","category":"module"},{"location":"Helpers/#InplaceArrays.Helpers.@abstractmethod-Tuple{}","page":"Gridap.Helpers","title":"InplaceArrays.Helpers.@abstractmethod","text":"@abstractmethod\n\nMacro used in generic functions that must be overloaded by derived types.\n\n\n\n\n\n","category":"macro"},{"location":"Helpers/#InplaceArrays.Helpers.@notimplemented","page":"Gridap.Helpers","title":"InplaceArrays.Helpers.@notimplemented","text":"@notimplemented\n@notimplemented \"Error message\"\n\nMacro used to raise an error, when something is not implemented.\n\n\n\n\n\n","category":"macro"},{"location":"Helpers/#InplaceArrays.Helpers.@notimplementedif","page":"Gridap.Helpers","title":"InplaceArrays.Helpers.@notimplementedif","text":"@notimplementedif condition\n@notimplementedif condition \"Error message\"\n\nMacro used to raise an error if the condition is true\n\n\n\n\n\n","category":"macro"},{"location":"Helpers/#InplaceArrays.Helpers.@unreachable","page":"Gridap.Helpers","title":"InplaceArrays.Helpers.@unreachable","text":"@unreachable\n@unreachable \"Error message\"\n\nMacro used to make sure that a line of code is never reached.\n\n\n\n\n\n","category":"macro"},{"location":"#Home-1","page":"Home","title":"Home","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Documentation for InplaceArrays.jl","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Pages = [\n  \"index.md\",\n  \"Gridap.md\",\n  \"Helpers.md\",\n  \"Inference.md\",\n  \"Arrays.md\",\n  \"Fields.md\",\n  ]","category":"page"}]
}
