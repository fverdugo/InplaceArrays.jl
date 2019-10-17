module CellValuesTests

using Test
using InplaceArrays

a = collect(1:10)
cv = CellValue(a)
test_cell_value(cv,a)

v = 3.0
l = 10
a = fill(v,l)
cv = CellValue(v,l)
test_cell_value(cv,a)

v = 3.0
s = (2,3)
a = fill(v,s)
cv = CellValue(v,s...)
test_cell_value(cv,a)

a = collect(1:10)
b = -a
cv = CellValue(a)
cv2 = CellValue(cv,b)
test_cell_value(cv2,b)

a = collect(1:20)
cv = CellValue(a)
cv2 = apply(-,cv)
@test isa(cv2,CellValue)
test_cell_value(cv2,-a)

a = collect(1:20)
cv = CellValue(a)
cv2 = -cv
@test isa(cv2,CellValue)
test_cell_value(cv2,-a)

a = collect(1:20)
b = collect(21:40)
cva = CellValue(a)
cvb = CellValue(b)
cvc = apply(-,cva,cvb)
@test isa(cvc,CellValue)
test_cell_value(cvc,a-b)

a = [rand(2,3) for i in 1:10]
b = [4 for i in 1:10]
c = [ai.-bi for (ai,bi) in zip(a,b)]
cva = CellValue(a)
cvb = CellValue(b)
cvc = apply(bcast(-),cva,cvb)
@test isa(cvc,CellValue)
test_cell_value(cvc,c)

a = [rand(2,3) for i in 1:10]
b = [4 for i in 1:10]
c = [ai.-bi for (ai,bi) in zip(a,b)]
cva = CellValue(a)
cvb = CellValue(b)
@test isa(cva,CellArray{Float64,2})
@test isa(cva,CellData)
@test isa(cvb,CellNumber{Int})
@test isa(cvb,CellData)
cvc = cva - cvb
@test isa(cvc,CellValue)
test_cell_value(cvc,c)

a = fill(3,10)
b = fill(4,10)
c = [ai-bi for (ai,bi) in zip(a,b)]
cva = CellValue(a)
cvb = CellValue(b)
cvc = cva - cvb
@test isa(cvc,CellValue)
test_cell_value(cvc,c)

a = [rand(2,3) for i in 1:10]
b = [rand(2,1) for i in 1:10]
c = [ai.-bi for (ai,bi) in zip(a,b)]
cva = CellValue(a)
cvb = CellValue(b)
cvc = cva - cvb
@test isa(cvc,CellValue)
test_cell_value(cvc,c)

end # module
