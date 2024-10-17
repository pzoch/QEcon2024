using Plots

my_sum = 0
for i in 1:5
    my_sum = my_sum + i
    println("sum: ", my_sum)
end
println("1+2+3+4+5=", my_sum)

#############################        QUICK TASK:         ############################# 
# Write a function that takes a number (n) as an argument and returns the mean of the values 1, 2, 3, ..., n.
# 1. Define a function my_mean(n)
# 2. Define a variable my_sum=0
# 4. Use a for loop to get the sum of numbers from 1 to n
# 5. Then use the calculated sum to get the mean
# 6. Return the mean
# 7. Test the function
####################################################################################### 
function my_mean(n)
    my_sum = 0
    for i in 1:n
        my_sum = my_sum + i #OR total += i
    end
    return my_sum/n
end
my_mean(2)


### Arrays and matrices ###
# We have already seen a Julia array and array indexing in action
y = [1, 2, 3]
y = [1.0, 2.0, 3.0]

y[3]    # third element of an array
y[end]  # the last element of an array

# Other ways to initialize a vector
n = 10

vec = Vector{Float64}(undef, n) 
vec = zeros(n)
vec = ones(n)
vec = rand(n) # random uniform values
vec = rand(1:10,n) # random values from 1:10
vec = randn(n) # random values from a standard Normal.
vec = collect(1:n)

typeof(vec) == Array{Float64, 1} # vector is just an alias for a one-dimensional array 
size(vec) # The syntax (10,) displays a tuple containing one element – the size along the one dimension that exists.

y = [1 2 3 ; 4 5 6]

ndims(y)
y_size = size(y)
y[2,3]
y[end,end]

#Extracting columns and rows!!!
y[1,:]   # only the first row
y[:,end] # only the last column

n = 10
mat = Matrix{Float64}(undef, n,n) 
mat = zeros(n,n)
mat = ones(n,n)
mat = rand(n,n) # random uniform values
mat = randn(n,n) # random values from a standard Normal.
fill(0, 2, 2)

typeof(mat) == Array{Float64, 2} 

#############################        QUICK TASK:         ############################# 
# Let's do some multiplication tables!
# Write a function that does the following:
#   Accepts n, which is the maximum value of a times table.
#   Returns a matrix of size n by n, where the entries of the matrix are the product of the indices of that array.    
# I.e. for n=5, the [3,2] entry is 3 * 2 = 6

# HINTS: 
# 1. Initialize the Matrix with one of the commands we've just discussed
# 2. Use two nested for loops
# 3. M[i,j] will give you element in the i-th row and j-th column
####################################################################################### 


# Broadcasting
# In Julia, definitions of functions follow the rules of mathematics
x = [1 2 3]
size(x)
y = [1, 2, 3]
x*y # the "*" follows matrix multiplication rules (1,3)*(3,1) --> (1,1)
x'
transpose(x)

x*x'

# How should we multiply two vectors element-wise?
y = [1,2,3]
x = [2,2,2]

# x*y <- You get an error, as multiplication of a vector by a vector is not a valid mathematical operation.

# Instead, we need to broadcast the multiplication. In Julia, adding broadcasting to an operator is easy. You just prefix it with a dot (.), like this:
y .* x
# NOTE: the dimensions of the passed objects must match:
y = [1,2,3]
x = [2,2]
y.*x # error

y = [1,2,3]
x = [2,2,2]
# we can get the same result with a simple loop - NOTE: in Julia loops are fast
z = similar(y)
for i in eachindex(y, x)
    z[i] = y[i] * x[i] 
end

# using map 
map(*, x, y)  # The passed function (*, in this case) is applied iteratively elementwise to those collections until one of them is exhausted

# Broadcasting Functions:
times_two(x) = 2 * x
times_two(5)
times_two.(y)
# those can be built-in functions
log.(y)

# or using map function
map(x -> 2*x, y)

# Expanding length-1 dimensions in broadcasting

# There is one exception to the rule that dimensions of all collections taking part in
# broadcasting must match. This exception states that single-element dimensions get
# expanded to match the size of the other collection by repeating the value stored in
# this single element:

[1, 2, 3] .- 1
[1, 2, 3] .- 2



mat_ones = ones(3,3)
vec_horizontal = [0.0 1.0 2.0]
mat_ones .+ vec_horizontal

vec_vertical = [0.0, 1.0, 2.0]
mat_ones .+ vec_vertical

vec_vertical .+ vec_horizontal

#############################        CONCEPT CHECK:         ############################# 
# Multiplication table returns!
# Write a function that does the following:
#   Accepts n, which is the maximum value of a times table.
#   Returns a matrix of size n by n, where the entries of the matrix are the product of the indices of that array.    
# I.e. for n=5, the [3,2] entry is 3 * 2 = 6

# BUT!
# The body of the function must contain only two lines of code:
# 1. Initialize the array containing values 1 to N (see around line 46 for hints)
# 2. Use vector operations (transpose) & broadcasting to get the multiplication table. Do not use any loops.
####################################################################################### 


# Conditional extraction
a = [10, 20, 30]
b = [-100, 0, 100]

a .> 0 # 1 if this particular element of vector a is greater than 0, 0 otherwise
b .> 0

sum(b .> 0) # How many of the elements in the array b that are greater than 0? This will sum 1s and 0s.
b[b .> 0] # Extract only those elements of b which are greater than 0!

a = [10, 20, 30]
b = [10, 0, 100]

a .== b # which element of a is equal to the corresponding element of b?
# Now we extract only the elements of an array that satisfy a condition
a[a .== b]

a = randn(100)
a[a .> 0]



#### Tuples
# Note in Julia it matters whether we use "()" or "[]"
my_tuple_1 = (10, 20, 30)
my_tuple_1[2]
my_tuple_1[2] = 4
my_tuple_2 = (12, "hello?", "Bernanke, Diamond, Dybvig")

my_tuple_2[2]
my_tuple_2[3]
my_named_tuple = (α = 0.33, β = 0.9, r = 0.05)
my_named_tuple.α