var documenterSearchIndex = {"docs":
[{"location":"Fields/#Physical-fields-1","page":"Physical fields","title":"Physical fields","text":"","category":"section"},{"location":"Fields/#Interface-1","page":"Physical fields","title":"Interface","text":"","category":"section"},{"location":"Fields/#","page":"Physical fields","title":"Physical fields","text":"FieldLike\nField\nBasis\nPoint\nevaluate!\nnew_cache\nreturn_type(::FieldLike)\ngradient(::FieldLike)\nnum_dofs\ntest_fieldlike\ntest_field\ntest_field_with_gradient\ntest_basis","category":"page"},{"location":"Fields/#InplaceArrays.Fields.FieldLike","page":"Physical fields","title":"InplaceArrays.Fields.FieldLike","text":"abstract type FieldLike{D,T,N}\n\nAbstract type representing either a field ( for N==1) or a basis of fields (for N==2) of value T, evaluable at points with D components.\n\nThe following functions need to be overloaded for derived types:\n\nevaluate!\nnew_cache\nreturn_type(::FieldLike)\nnum_dofs (Only for CellBasis, i.e. N==2.)\n\nThe following functions can optionally be also provided\n\ngradient(f::FieldLike)\n\nThe interface can be tested with these functions\n\ntest_fieldlike\ntest_field\ntest_field_with_gradient\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.Field","page":"Physical fields","title":"InplaceArrays.Fields.Field","text":"const Field = FieldLike{D,T,1} where {D,T}\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.Basis","page":"Physical fields","title":"InplaceArrays.Fields.Basis","text":"const Basis = FieldLike{D,T,2} where {D,T}\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.Point","page":"Physical fields","title":"InplaceArrays.Fields.Point","text":"const Point{D,T} = VectorValue{D,T}\n\nType representing a point of D dimensions with coordinates of type T\n\n\n\n\n\n","category":"type"},{"location":"Fields/#InplaceArrays.Fields.evaluate!","page":"Physical fields","title":"InplaceArrays.Fields.evaluate!","text":"evaluate!(cache,f::FieldLike,x::AbstractVector{<:Point}) -> AbstractArray\n\nFor Fields it returns an instance of AbstractVector and for Basis  and an instance of AbstractMatrix.\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.new_cache","page":"Physical fields","title":"InplaceArrays.Fields.new_cache","text":"new_cache(f::FieldLike)\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Inference.return_type-Tuple{FieldLike}","page":"Physical fields","title":"InplaceArrays.Inference.return_type","text":"return_type(::FieldLike) -> DataType\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.gradient-Tuple{FieldLike}","page":"Physical fields","title":"InplaceArrays.Fields.gradient","text":"gradient(f::FieldLike) -> FieldLike\n\n\n\n\n\n","category":"method"},{"location":"Fields/#InplaceArrays.Fields.num_dofs","page":"Physical fields","title":"InplaceArrays.Fields.num_dofs","text":"num_dofs(b::Basis) -> Int\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.test_fieldlike","page":"Physical fields","title":"InplaceArrays.Fields.test_fieldlike","text":"\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.test_field","page":"Physical fields","title":"InplaceArrays.Fields.test_field","text":"\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.test_field_with_gradient","page":"Physical fields","title":"InplaceArrays.Fields.test_field_with_gradient","text":"\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.test_basis","page":"Physical fields","title":"InplaceArrays.Fields.test_basis","text":"\n\n\n\n","category":"function"},{"location":"Fields/#API-1","page":"Physical fields","title":"API","text":"","category":"section"},{"location":"Fields/#","page":"Physical fields","title":"Physical fields","text":"evaluate\nvaluetype\npointdim\ngradtype","category":"page"},{"location":"Fields/#InplaceArrays.Fields.evaluate","page":"Physical fields","title":"InplaceArrays.Fields.evaluate","text":"evaluate(cf::CellFieldLike,x::CellPoints) -> CellArray\n\n\n\n\n\nevaluate(f::FieldLike,x::AbstractVector{<:Point})\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.valuetype","page":"Physical fields","title":"InplaceArrays.Fields.valuetype","text":"valuetype(::Type) -> DataType\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.pointdim","page":"Physical fields","title":"InplaceArrays.Fields.pointdim","text":"pointdim(::Type) -> Int\n\n\n\n\n\n","category":"function"},{"location":"Fields/#InplaceArrays.Fields.gradtype","page":"Physical fields","title":"InplaceArrays.Fields.gradtype","text":"gradtype(::Type) -> DataType\n\n\n\n\n\n","category":"function"},{"location":"Inference/#Inferring-return-types-1","page":"Inferring return types","title":"Inferring return types","text":"","category":"section"},{"location":"Inference/#","page":"Inferring return types","title":"Inferring return types","text":"In Gridap, we rely as less as possible in type inference. But, when needed, we adopt the following mechanism in order to compute returned types. We do not rely on the Base._return_type function.","category":"page"},{"location":"Inference/#","page":"Inferring return types","title":"Inferring return types","text":"return_type\nreturn_type_broadcast\ntestargs\ntestvalue\ntestvalues","category":"page"},{"location":"Inference/#InplaceArrays.Inference.return_type","page":"Inferring return types","title":"InplaceArrays.Inference.return_type","text":"return_type(::FieldLike) -> DataType\n\n\n\n\n\nreturn_type(f::Function,Ts::DataType...) -> DataType\n\nReturns the type returned by function f when called with arguments of the types in Ts.\n\nThe underlying implementation uses the function testargs to generate some test values in order to call the function and determine the returned type. This mechanism does not use Base._return_type. One of the advantages is that the given function f is called, and thus, meaningful error messages will be displayed if there is any error in f. \n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.return_type_broadcast","page":"Inferring return types","title":"InplaceArrays.Inference.return_type_broadcast","text":"return_type_broadcast(f::Function,Ts::DataType...) -> DataType\n\nLike return_type, but when function f is used in a broadcast operation.\n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testargs","page":"Inferring return types","title":"InplaceArrays.Inference.testargs","text":"testargs(f::Function,Ts::DataType...) -> Tuple\n\nReturns a tuple with valid arguments of the types in Ts in order to call function f. It defaults to testvalues(Ts...), see the testvalues function. The user can overload the testargs function for particular functions if the default test arguments are not in the domain of the function and a DomainError is raised.\n\nExamples\n\nFor the following function, the default test argument (which is a zero) is not in the domain. We can overload the testargs function to provide a valid test argument.\n\nfoo(x) = sqrt(x-1)\ntestargs(::typeof(foo),T::DataType) = (zero(T)+one(T),)\nreturn_type(foo, Int) == Float64\n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testvalue","page":"Inferring return types","title":"InplaceArrays.Inference.testvalue","text":"testvalue(::Type{T}) where T\n\nReturns an arbitrary instance of type T. It defaults to zero(T) for non-array types and to an empty array for array types. This function is used to compute the default test arguments in testargs. It can be overloaded for new types T if zero(T) does not makes sense. \n\n\n\n\n\n","category":"function"},{"location":"Inference/#InplaceArrays.Inference.testvalues","page":"Inferring return types","title":"InplaceArrays.Inference.testvalues","text":"testvalues(Ts::DataType...) -> Tuple\n\nReturns a tuple with test values for each of the types in Ts. Equivalent to map(testvalue,Ts).\n\n\n\n\n\n","category":"function"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"DocTestSetup = quote\n    using InplaceArrays\nend","category":"page"},{"location":"Functors/#The-Functor-interface-1","page":"The functor interface","title":"The Functor interface","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"Often, it is needed to implement functions that need some scratch data (e.g., pre-allocating the output). The question is, where to store this data? There are three main answers to this question: 1) store the data in the function object as part of its state, 2) allocate the scratch data each time the operation is performed, and 3) the user allocates and passes the scratch data when needed. Clearly, 1) it is not save if several calls to the operation are using the same scratch data (e.g., multi-threading). 2) is save, but it can be inefficient if the operation is performed at low granularity. 3) is both save and efficient, but requires some extra work by the user.","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"In Gridap, we adopt the 3rd option. In order to unify the interfaces of functions using this approach, we introduce the Functor interface. Any type is referred to as a Functor if it implements the following interface. We rely in duck typing here. There is not an abstract type representing a functor.","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"The functions to be overloaded for a new functor are","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"evaluate_functor!\nfunctor_cache\nfunctor_return_type","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"The functor interface can be tested with the test_functor function.","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"evaluate_functor!\nfunctor_cache\nfunctor_return_type\ntest_functor","category":"page"},{"location":"Functors/#InplaceArrays.Functors.evaluate_functor!","page":"The functor interface","title":"InplaceArrays.Functors.evaluate_functor!","text":"y = evaluate_functor!(cache,f,x...)\n\nEvaluates the functor f at the arguments x... using the scratch data provided in the given cache object. The cache object is built with the functor_cache function using arguments of the same type as in x... In general, the returned value y can share some part of its state with the cache object. If the result of two or more invocations of this function need to be accessed simultaneously (e.g., in multi-threading), create and use various cache objects (e.g., one cache per thread).\n\n\n\n\n\n","category":"function"},{"location":"Functors/#InplaceArrays.Functors.functor_cache","page":"The functor interface","title":"InplaceArrays.Functors.functor_cache","text":"cache = functor_cache(f,x...)\n\nReturns the cache needed to evaluate functor f with arguments of the same type as the objects in x....\n\n\n\n\n\n","category":"function"},{"location":"Functors/#InplaceArrays.Functors.functor_return_type","page":"The functor interface","title":"InplaceArrays.Functors.functor_return_type","text":"functor_return_type(f,Ts::DataType...)\n\nReturns the type of the result of calling functor f with arguments of the types in Ts.\n\n\n\n\n\n","category":"function"},{"location":"Functors/#InplaceArrays.Functors.test_functor","page":"The functor interface","title":"InplaceArrays.Functors.test_functor","text":"test_functor(f,x,y,cmp::Function=(==))\n\nFunction used to test if the functor f has been implemented correctly. f is a functor object, x is the input of the functor, and y is the expected result. Function cmp is used to compare the computed result with the expected one. The checks are done with the @test macro.\n\n\n\n\n\n","category":"function"},{"location":"Functors/#Default-implementations-1","page":"The functor interface","title":"Default implementations","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"We provide some default (obvious) implementations of this interface so that Function, Number, and AbstractArray objects behave like functors.","category":"page"},{"location":"Functors/#Examples-1","page":"The functor interface","title":"Examples","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"Calling the + function via the functor interface.","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"julia> cache = functor_cache(+,0,0)\n\njulia> evaluate_functor!(cache,+,1,2)\n3\n\njulia> evaluate_functor!(cache,+,-1,10)\n9","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"Number and AbstractArray objects behave like \"constant\" functors.","category":"page"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"julia> a = 2.0\n2.0\n\njulia> cache = functor_cache(a,0)\n\njulia> evaluate_functor!(cache,a,1)\n2.0\n\njulia> evaluate_functor!(cache,a,2)\n2.0\n\njulia> evaluate_functor!(cache,a,3)\n2.0","category":"page"},{"location":"Functors/#Evaluating-a-functor-without-cache-1","page":"The functor interface","title":"Evaluating a functor without cache","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"InplaceArrays.Functors.evaluate_functor","category":"page"},{"location":"Functors/#InplaceArrays.Functors.evaluate_functor","page":"The functor interface","title":"InplaceArrays.Functors.evaluate_functor","text":"evaluate_functor(f,x...)\n\nEvaluate the fuctor f at the arguments x... by creating a temporary cache internally. This functions is equivalent to\n\ncache = functor_cache(f,x...)\nevaluate_functor!(cache,f,x...)\n\n\n\n\n\n","category":"function"},{"location":"Functors/#Working-with-several-functors-at-once-1","page":"The functor interface","title":"Working with several functors at once","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"evaluate_functors!\nfunctor_caches","category":"page"},{"location":"Functors/#InplaceArrays.Functors.evaluate_functors!","page":"The functor interface","title":"InplaceArrays.Functors.evaluate_functors!","text":"evaluate_functors!(caches::Tuple,fs::Tuple,x...) -> Tuple\n\nEvaluates the functors in the tuple fs at the arguments x... by using the corresponding cache objects in the tuple caches. The result is also a tuple containing the result for each functor in fs.\n\n\n\n\n\n","category":"function"},{"location":"Functors/#InplaceArrays.Functors.functor_caches","page":"The functor interface","title":"InplaceArrays.Functors.functor_caches","text":"functor_caches(fs::Tuple,x...) -> Tuple\n\nReturns a tuple with the cache corresponding to each functor in fs for the arguments x....\n\n\n\n\n\n","category":"function"},{"location":"Functors/#Broadcasting-1","page":"The functor interface","title":"Broadcasting","text":"","category":"section"},{"location":"Functors/#","page":"The functor interface","title":"The functor interface","text":"bcast","category":"page"},{"location":"Functors/#InplaceArrays.Functors.bcast","page":"The functor interface","title":"InplaceArrays.Functors.bcast","text":"bcast(f::Function)\n\nReturns a functor object that represents the \"boradcasted\" version of the given function f.\n\nExamples\n\njulia> op = bcast(*)\nInplaceArrays.Functors.BCasted{typeof(*)}(*)\n\njulia> x = ones(2,3)\n2×3 Array{Float64,2}:\n 1.0  1.0  1.0\n 1.0  1.0  1.0\n\njulia> y = 2\n2\n\njulia> evaluate_functor(op,x,y)\n2×3 CachedArray{Float64,2,Array{Float64,2}}:\n 2.0  2.0  2.0\n 2.0  2.0  2.0\n\n\n\n\n\n","category":"function"},{"location":"CellFields/#Cell-wise-physical-fields-1","page":"Cell-wise physical fields","title":"Cell-wise physical fields","text":"","category":"section"},{"location":"CellFields/#Definitions-1","page":"Cell-wise physical fields","title":"Definitions","text":"","category":"section"},{"location":"CellFields/#","page":"Cell-wise physical fields","title":"Cell-wise physical fields","text":"CellFieldLike\nCellField\nCellBasis\nCellPoints","category":"page"},{"location":"CellFields/#InplaceArrays.CellFields.CellFieldLike","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.CellFieldLike","text":"const CellFieldLike = CellValue{V} where V<:FieldLike{D,T,N} where {D,T,N}\n\n\n\n\n\n","category":"type"},{"location":"CellFields/#InplaceArrays.CellFields.CellField","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.CellField","text":"const CellField = CellFieldLike{D,T,1} where {D,T}\n\n\n\n\n\n","category":"type"},{"location":"CellFields/#InplaceArrays.CellFields.CellBasis","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.CellBasis","text":"const CellBasis = CellFieldLike{D,T,2} where {D,T}\n\n\n\n\n\n","category":"type"},{"location":"CellFields/#InplaceArrays.CellFields.CellPoints","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.CellPoints","text":"const CellPoints = CellValue{A} where A<:AbstractVector{P} where P<:Point{D,T} where {D,T}\n\n\n\n\n\n","category":"type"},{"location":"CellFields/#API-1","page":"Cell-wise physical fields","title":"API","text":"","category":"section"},{"location":"CellFields/#","page":"Cell-wise physical fields","title":"Cell-wise physical fields","text":"evaluate(cf::CellFieldLike,x::CellPoints)\ngradient(cf::CellFieldLike)","category":"page"},{"location":"CellFields/#InplaceArrays.Fields.evaluate-Tuple{CellValue{V} where V<:FieldLike{D,T,N} where N where T where D,CellValue{A} where A<:AbstractArray{P,1} where P<:TensorValues.MultiValue{Tuple{D},T,1,D} where T where D}","page":"Cell-wise physical fields","title":"InplaceArrays.Fields.evaluate","text":"evaluate(cf::CellFieldLike,x::CellPoints) -> CellArray\n\n\n\n\n\n","category":"method"},{"location":"CellFields/#InplaceArrays.Fields.gradient-Tuple{CellValue{V} where V<:FieldLike{D,T,N} where N where T where D}","page":"Cell-wise physical fields","title":"InplaceArrays.Fields.gradient","text":"gradient(cf::CellFieldLike) -> CellFieldLike\n\n\n\n\n\n","category":"method"},{"location":"CellFields/#Testers-1","page":"Cell-wise physical fields","title":"Testers","text":"","category":"section"},{"location":"CellFields/#","page":"Cell-wise physical fields","title":"Cell-wise physical fields","text":"test_cell_field_like\ntest_cell_field_like_no_array\ntest_cell_field\ntest_cell_basis\ntest_cell_field_like_with_gradient\ntest_cell_field_like_with_gradient_no_array\ntest_cell_field_with_gradient\ntest_cell_basis_with_gradient","category":"page"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field_like","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field_like","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field_like_no_array","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field_like_no_array","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_basis","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_basis","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field_like_with_gradient","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field_like_with_gradient","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field_like_with_gradient_no_array","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field_like_with_gradient_no_array","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_field_with_gradient","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_field_with_gradient","text":"\n\n\n\n","category":"function"},{"location":"CellFields/#InplaceArrays.CellFields.test_cell_basis_with_gradient","page":"Cell-wise physical fields","title":"InplaceArrays.CellFields.test_cell_basis_with_gradient","text":"\n\n\n\n","category":"function"},{"location":"Arrays/#Extended-AbstractArray-interface-1","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"","category":"section"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"When implementing new array types, we encounter a similar problem than when implementing some functions: It can be needed some scratch data (e.g., allocating the output), when recovering an item from an array (typically if the array elements are mutable or non-isbits objects, e.g., for \"lazy\" array of arrays). Here, we adopt the same solution as for functors: the user provides the scratch data. However, the Julia array interface does not support this approach. When calling a[i], in order to get the element with index i in array a, there is no extra argument for the scratch data. In order to circumvent this problem, we add new methods to the AbstractArray interface of Julia. We provide default implementations to the new methods, so that any AbstractArray can be used with the extended interface. The most important among the new methods is getindex!, which allows to recover an item in the array by passing some scratch data. The new mehtods are listed below.","category":"page"},{"location":"Arrays/#New-functions-1","page":"Extended AbstractArray interface","title":"New functions","text":"","category":"section"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"The functions added to the AbstractArray interface are:","category":"page"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"getindex!\narray_cache\nuses_hash\ntestitem","category":"page"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"The new methods can be tested with the these functions:","category":"page"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"test_array\ntest_array_of_functors","category":"page"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"getindex!\narray_cache\nuses_hash\ntestitem\ntest_array\ntest_array_of_functors","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.getindex!","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.getindex!","text":"getindex!(cache,a::AbstractArray,i...)\n\nReturns the item of the array a associated with index i by (possibly) using the scratch data passed in the cache object.\n\nIt defaults to\n\ngetindex!(cache,a::AbstractArray,i...) = a[i...]\n\nThe cache object is constructed with the array_cache function.\n\nExamples\n\njulia> a = collect(1:4)\n4-element Array{Int64,1}:\n 1\n 2\n 3\n 4\n\njulia> cache = array_cache(a)\n\njulia> getindex!(cache,a,2)\n2\n\njulia> getindex!(cache,a,4)\n4\n\nIn this example, using the extended interface provides little benefit, but for new array types that need scratch data, efficient implementations of getindex! can make a performance difference by avoiding  low granularity allocations.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.array_cache","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.array_cache","text":"array_cache(a::AbstractArray)\n\nReturns a cache object to be used in the getindex! function. It defaults to \n\narray_cache(a::T) where T = nothing\n\nfor types T such that uses_hash(T) == Val(false), and \n\nfunction array_cache(a::T) where T\n  hash = Dict{UInt,Any}()\n  array_cache(hash,a)\nend\n\nfor types T such that uses_hash(T) == Val(true), see the uses_hash function. In the later case, the type T should implement the following signature:\n\narray_cache(hash::Dict,a::AbstractArray)\n\nwhere we pass a dictionary (i.e., a hash table) in the first argument. This hash table can be used to test if the object a has already build a cache and re-use it as follows\n\nid = objectid(a)\nif haskey(hash,id)\n  cache = hash[id] # Reuse cache\nelse\n  cache = ... # Build a new cache depending on your needs\n  hash[id] = cache # Register the cache in the hash table\nend\n\nThis mechanism is needed, e.g., to re-use intermediate results in complex lazy operation trees. In multi-threading computations, a different hash table per thread has to be used in order to avoid race conditions.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.uses_hash","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.uses_hash","text":"uses_hash(::Type{T}) where T <:AbstractArray\n\nThis function is used to specify if the type T uses the hash-based mechanism to reuse caches.  It should return either Val(true) or Val(false). It defaults to\n\nuses_hash(::Type{<:AbstractArray}) = Val(false)\n\nOnce this function is defined for the type T it can also be called on instances of T.\n\nExamples\n\njulia> uses_hash(Matrix{Float64})\nVal{false}()\n\njulia> a = ones(2,3)\n2×3 Array{Float64,2}:\n 1.0  1.0  1.0\n 1.0  1.0  1.0\n\njulia> uses_hash(a)\nVal{false}()\n\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.testitem","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.testitem","text":"testitem(a::AbstractArray)\n\nReturns an arbitrary instance of eltype(a). The default returned value is the first entry in the array if length(a)>0 and testvalue(eltype(a)) if length(a)==0 See the testvalue function.\n\nThis function is useful to determine the type resulting from applying a given function to the items in the array without calling the Base._return_type function.\n\nExamples\n\njulia> a = collect(1:0)\n0-element Array{Int64,1}\n\njulia> ai = testitem(a) # Safely works with empty arrays\n0\n\njulia> typeof(sqrt(ai))\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.test_array","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.test_array","text":"test_array(\n  a::AbstractArray{T,N}, b::AbstractArray{S,N},cmp=(==)) where {T,S,N}\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#InplaceArrays.Arrays.test_array_of_functors","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.test_array_of_functors","text":"test_array_of_functors(\n  a::AbstractArray, x::Tuple, r::AbstractArray, cmp=(==) )\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Working-with-several-arrays-1","page":"Extended AbstractArray interface","title":"Working with several arrays","text":"","category":"section"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"testitems","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.testitems","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.testitems","text":"testitems(b::AbstractArray...) -> Tuple\n\nReturns a tuple with the result of testitem applied to each of the arrays in b.\n\n\n\n\n\n","category":"function"},{"location":"Arrays/#Creating-lazy-operation-trees-1","page":"Extended AbstractArray interface","title":"Creating lazy operation trees","text":"","category":"section"},{"location":"Arrays/#","page":"Extended AbstractArray interface","title":"Extended AbstractArray interface","text":"evaluate_array_of_functors(f,a::AbstractArray...)\nevaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)","category":"page"},{"location":"Arrays/#InplaceArrays.Arrays.evaluate_array_of_functors-Tuple{Any,Vararg{AbstractArray,N} where N}","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.evaluate_array_of_functors","text":"evaluate_array_of_functors(f,a::AbstractArray...)\n\nReturns a (lazy) array representing the evaluation of the given functor f to the entries of the input arrays a. The returned array r is such that r[i] == evaluate_functor(f,a[1][i],a[2][i],...) Items in the resulting array r can be memory-efficiently recovered by using the getindex! function. Note that this function returns a lazy object. The operations are not performed until an entry of the array is retrieved. By applying this function to the result r again (possibly with another functor) we create a lazy operation tree. The underlying implementation is able to reuse intermediate results in this operation tree.\n\nExamples\n\njulia> a = collect(1:5)\n5-element Array{Int64,1}:\n 1\n 2\n 3\n 4\n 5\n\njulia> b = collect(6:10)\n5-element Array{Int64,1}:\n  6\n  7\n  8\n  9\n 10\n\njulia> c = evaluate_array_of_functors(+,a,b)\n5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}}:\n  7\n  9\n 11\n 13\n 15\n\njulia> d = evaluate_array_of_functors(*,c,c)\n5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}},InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}}},FillArrays.Fill{typeof(*),1,Tuple{Base.OneTo{Int64}}}}:\n  49\n  81\n 121\n 169\n 225\n\n\n\n\n\n","category":"method"},{"location":"Arrays/#InplaceArrays.Arrays.evaluate_array_of_functors-Tuple{AbstractArray,Vararg{AbstractArray,N} where N}","page":"Extended AbstractArray interface","title":"InplaceArrays.Arrays.evaluate_array_of_functors","text":"evaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)\n\nExamples\n\njulia> g = [+,-,*,mod,max]\n5-element Array{Function,1}:\n +  \n -  \n *  \n mod\n max\n\njulia> x = collect(1:5)\n5-element Array{Int64,1}:\n 1\n 2\n 3\n 4\n 5\n\njulia> y = collect(6:10)\n5-element Array{Int64,1}:\n  6\n  7\n  8\n  9\n 10\n\njulia> evaluate_array_of_functors(g,x,y)\n5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},Array{Function,1}}:\n  7\n -5\n 24\n  4\n 10\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#The-CellValue-interface-1","page":"The CellValue interface","title":"The CellValue interface","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"CellValue\ntest_cell_value","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.CellValue","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellValue","text":"abstract type CellValue{T}\n\nAbstract type representing a collection of values of type T associated with the objects (e.g, cells, but also facets, edges, etc.) of a FE mesh.\n\nA CellValue has to be understood as an array plus (possibly) some extra metatada, e.g., the underlying mesh, fe space, information about the current field in multi-field FE computations etc. The simplest version of CellValue, namely PlainCellValue, has no metadata.\n\nAll concrete types extending CellValue are assumed to have a field named array that contains an instance of AbstractArray{T} representing the collection of values in the CellValue object.\n\nConcrete implementations of CellValue do not need to be type stable. In particular, the type of the array field does not need to be included as a type parameter in the corresponding CellValue concrete type. This allows to pass CellValue objects around without polluting the stack trace if an error occurs. However, the object stored in the array field has to be type stable. This allows to access items in CellValue objects efficiently via the array field (within a function barrier).\n\nThe CellValue interface can be tested with the test_cell_value function.\n\n\n\n\n\n","category":"type"},{"location":"CellValues/#InplaceArrays.CellValues.test_cell_value","page":"The CellValue interface","title":"InplaceArrays.CellValues.test_cell_value","text":"test_cell_value(cv::CellValue,b::AbstractArray,cmp=(==))\n\n\n\n\n\n","category":"function"},{"location":"CellValues/#Constructors-1","page":"The CellValue interface","title":"Constructors","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"CellValue(cv::CellValue,array::AbstractArray)\nCellValue(array::AbstractArray)\nCellValue(value,len::Integer)\nCellValue(value,shape::Integer...)","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.CellValue-Tuple{CellValue,AbstractArray}","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellValue","text":"CellValue(cv::CellValue,array::AbstractArray)\n\nCreates a CellValue object from the array array and (possibly) the metadata available in cv. By default, the metadata in cv is discarded and a PlainCellValue is returned. However, concrete implementations of the CellValue abstract type can overload this constructor in order to generate a new CellValue object from the given array and the metadata in cv.\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#InplaceArrays.CellValues.CellValue-Tuple{AbstractArray}","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellValue","text":"CellValue(array::AbstractArray) -> PlainCellValue\n\nCreates a PlainCellValue from the given array\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#InplaceArrays.CellValues.CellValue-Tuple{Any,Integer}","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellValue","text":"CellValue(value,len::Integer) -> PlainCellValue\n\nCreates a \"constant\" CellValue object with value value and length len.\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#InplaceArrays.CellValues.CellValue-Tuple{Any,Vararg{Integer,N} where N}","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellValue","text":"CellValue(value,shape::Integer...) -> PlainCellValue\n\nCreates a \"constant\" CellValue object with value value and length prod(shape). The size of the generated array is equal to shape.\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#Methods-delegated-to-the-underlying-array-1","page":"The CellValue interface","title":"Methods delegated to the underlying array","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"Base.length(cv::CellValue)","category":"page"},{"location":"CellValues/#Base.length-Tuple{CellValue}","page":"The CellValue interface","title":"Base.length","text":"Base.length(cv::CellValue)\n\nReturns the length of the underlying array\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#Default-concrete-implementations-1","page":"The CellValue interface","title":"Default concrete implementations","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"PlainCellValue","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.PlainCellValue","page":"The CellValue interface","title":"InplaceArrays.CellValues.PlainCellValue","text":"struct PlainCellValue{T} <: CellValue{T}\n  array::AbstractArray{T}\nend\n\nConcrete implementation of CellValue with no meta-data\n\n\n\n\n\n","category":"type"},{"location":"CellValues/#Working-with-several-CellValue-objects-1","page":"The CellValue interface","title":"Working with several CellValue objects","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"getarrays","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.getarrays","page":"The CellValue interface","title":"InplaceArrays.CellValues.getarrays","text":"getarrays(cvs::CellValue...) -> Tuple\n\nReturns a tuple with the underlying arrays in the Cellvalue objects cvs.\n\n\n\n\n\n","category":"function"},{"location":"CellValues/#CellValue-objects-holding-numeric-data-1","page":"The CellValue interface","title":"CellValue objects holding numeric data","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"CellNumber\nCellArray\nCellData","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.CellNumber","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellNumber","text":"const CellNumber = CellValue{T} where T<:Number\n\nAny CellValue{T} type holding numbers of type T.\n\n\n\n\n\n","category":"type"},{"location":"CellValues/#InplaceArrays.CellValues.CellArray","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellArray","text":"const CellArray = CellValue{T} where T<:AbstractArray{S,N} where {S,N}\n\nAny CellValue{T} type holding arrays of type T.\n\n\n\n\n\n","category":"type"},{"location":"CellValues/#InplaceArrays.CellValues.CellData","page":"The CellValue interface","title":"InplaceArrays.CellValues.CellData","text":"const CellData = CellValue{T} where T<:Union{Number,AbstractArray}\n\nAny CellValue{T} type holding numbers or arrays of type T.\n\n\n\n\n\n","category":"type"},{"location":"CellValues/#Creating-lazy-operation-trees-1","page":"The CellValue interface","title":"Creating lazy operation trees","text":"","category":"section"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"apply(f,cvs::CellData...)","category":"page"},{"location":"CellValues/#InplaceArrays.CellValues.apply-Tuple{Any,Vararg{CellValue{T} where T<:Union{Number, AbstractArray},N} where N}","page":"The CellValue interface","title":"InplaceArrays.CellValues.apply","text":"apply(f,cvs::CellData...)\n\nReturns a new CellValue object obtained by applying the functor f to the entries of the given CellData objects cvs.\n\n\n\n\n\n","category":"method"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"The following (lazy) arithmetic operations are defined for CellData objects. When CellArrays are involved, the operations are done in broadcast form in the inner arrays.","category":"page"},{"location":"CellValues/#","page":"The CellValue interface","title":"The CellValue interface","text":"+\n-\n*","category":"page"},{"location":"#Home-1","page":"Home","title":"Home","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Documentation for InplaceArrays.jl","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Pages = [\"index.md\", \"Inference.md\",\n  \"Functors.md\", \"Arrays.md\",\n  \"CellValues.md\", \"Fields.md\", \"CellFields.md\"]","category":"page"}]
}
