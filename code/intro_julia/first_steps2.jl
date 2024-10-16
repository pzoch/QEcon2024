using Plots

### Functions ###
### (x,y) in the function below are arguments
function first_functionA(x,y)
    return x*y
end
first_functionA(3,2)
# You can also define a simple function this way:
first_functionB(x,y) = x*y 
first_functionB(3,2)

# You can define a new function that will use another function but ALWAYS evaluate it at a particular value
second_function(x) = first_functionB(x,3)

# 2 becomes a default value for y, though you can still change it when calling the function
function third_function(x,y=2)
    return x*y
end
third_function(3)
third_function(3,2)
third_function(3,3)

# Define a function for a line
function fourth_function(x,a,b)
    return a*x+b
end

fourth_function(2,2,1)

# Sometimes it is useful to have parameters defined as KEYWORD arguments
function fifth_function(x; a, b)
    return a*x+b
end

fifth_function(2,2,1) # ERROR, you need to provide the names of arguments!

fifth_function(2, a=2, b=1)

# You can combine both keyword arguments and default values:
function sixth_function(x; a=2, b=1)
    return a*x+b
end

sixth_function(2, a=2, b=0) 
sixth_function(2)

# You can define a "squared" function in either of these ways:
function squared(x)
    return x^2
end
squared(x) = x^2
plot(squared,-10:0.1:10)

# Short syntax for defining simple functions
times_two(x) = 2 * x
plot!(times_two,-10:0.1:10)

#############################        QUICK TASK:         ############################# 
# Consider the following polynomial function g(x, α, β, γ, δ) = α*x^3 + β*x^2 + γ*x + δ
# a. Write it in Julia such that α, β, γ, δ are keyword arguments. Test for arbitrary values of all parameters. 
# b. Now write a function h(x) that accepts only a value x but evaluates g at the coefficients 4, -3, 2, and 10.
# c. Plot function h at the interval (-100, 100), using a 0.1 step size
####################################################################################### 
# NOTE: the way to write Greek letters is to start typing: \alpha, \beta etc.

function seventh_function(x)
    a = x^2
    b = 2 * a
    return  a, b
end

seventh_function(2)

function eighth_function(x)
    a = x^2
    b = 2 * a
    return (; a, b)  
end
solution = eighth_function(2)
solution.a

(; a, b) = eighth_function(2)

# Often you will see an exclamation mark (!) at the end of the function name
x = [5, 1, 3, 2,1000]
sort(x)
sort!(x)
# Julia convention recommends that developers add ! at the end of functions they create if those functions modify their arguments.

### Loops ###
for i in [1,2,3,4,5]
    println(i)
end
for i in 1:5
    println(i)
end

sum = 0
for i in 1:5
    sum = sum + i
    println("sum: ", sum)
end
println("1+2+3+4+5=", sum)

for i in 1:2:5
    println(i)
end
for i in 5:-1:1
    println(i)
end

for i in [1,2,3,4,5]
    if !iseven(i)
        println(i, " is odd")
    end
end

i = 1
while i <= 5 
    println(i)    
    global i += 1
end

i = 1
while i <= 5 
    global i += 1
    if !iseven(i)
        println(i, " is odd")
    end
end

i = 1
while i <= 5 
    println(i)    
end


#############################        QUICK TASK:         ############################# 
# Write a function that takes a number (n) as an argument and returns the mean of the values 1, 2, 3, ..., n.
# 1. Define a function my_mean(n)
# 2. Define a variable mean=0
# 4. Use a for loop to get the sum of numbers from 1 to n
# 5. Then use the calculated sum to get the mean
# 6. Return the mean
# 7. Test the function
####################################################################################### 


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
y[y_size[1], y_size[2]]
y[end,end]

y[1,:]   # only the first row
y[:,end] # only the last column

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
x*x'
transpose(x)
# How should we multiply two vectors element-wise?
y = [1,2,3]
x = [2,2,2]

# x*y <- You get an error, as multiplication of a vector by a vector is not a valid mathematical operation.

# Instead, we need to broadcast the multiplication. In Julia, adding broadcasting to an operator is easy. You just prefix it with a dot (.), like this:
y .* x
# NOTE: the dimensions of the passed objects must match:
y = [1,2,3]
x = [2,2]
# y.*x

y = [1,2,3]
x = [2,2,2]
# we can get the same result with a simple loop - NOTE: in Julia loops are fast
z = similar(y)
for i in eachindex(y, x)
    z[i] = y[i] * x[i] 
end
z
# we can get the same result with a comprehension 
[y[i] * x[i] for i in eachindex(y, x)]
[0 for i in eachindex(y, x)]

# using map 
map(*, x, y)  # The passed function (*, in this case) is applied iteratively elementwise to those collections until one of them is exhausted

# Broadcasting Functions:
times_two(x) = 2 * x
times_two(5)
times_two.(y)
# those can be built-in functions
log.(y)

# we can get the same result as with a comprehension 
[log(i) for i in y]

# or using map function
map(log, y)
map(x -> 2*x, y)

# Expanding length-1 dimensions in broadcasting

# There is one exception to the rule that dimensions of all collections taking part in
# broadcasting must match. This exception states that single-element dimensions get
# expanded to match the size of the other collection by repeating the value stored in
# this single element:

[1, 2, 3] .- [2]

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
# I.e. for n=5, I want to see a matrix where the [3,2] entry is 3 * 2 = 6

# BUT!
# The body of the function must contain only two lines of code:
# 1. Initialize the array containing values 1 to N (see around line 200 for hints)
# 2. Use vector operations (transpose) & broadcasting to get the multiplication table. Do not use any loops.
####################################################################################### 


# Conditional extraction
a = [10, 20, 30]
b = [-100, 0, 100]

a .> b
a .== b

# Now we extract only the elements of an array that satisfy a condition
a[a .> b]

a = randn(100)
b = randn(100)
b[a .> 0]

# Note in Julia it matters whether we use "()" or "[]"
my_tuple_1 = (10, 20, 30)
my_tuple_1[2]
my_tuple_1[2] = 4
my_tuple_2 = (12, "hello?", "Bernanke, Diamond, Dybvig")

my_tuple_2[2]
my_tuple_2[3]
my_named_tuple = (α = 0.33, β = 0.9, r = 0.05)
my_named_tuple.α