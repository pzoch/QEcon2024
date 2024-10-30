# Examples from/based on Fundamentals of Numerical Computation, Julia Edition. Tobin A. Driscoll and Richard J. Braun

using PrettyTables, Plots, LaTeXStrings, LinearAlgebra


### ------------------------------
### norms 

# vector norms 
x = [1.0,2.0,3.0]
norm(x,1) # L1 norm
norm(x,2) # L2 norm
norm(x,Inf) # infinity norm

y = [5.0,6.0,7.0]

norm(x+y,2)
norm(x,2) + norm(y,2)

# matrix norms

A  = [1.0 2.0; 3.0 4.0]
norm(A) # frobenius norm 
norm(A,1)

opnorm(A) # operator norm (2)
opnorm(A,1) # operator norm (1)
opnorm(A,Inf) # operator norm (inf)



### condition number

A = float(I(4))
κ = cond(A)
rounding_bound = κ*eps() # upper bound from rounding errors


A = [1.0 2.5; 3.25 4.125]
κ = cond(A)
rounding_bound = κ*eps()

A = [ 1/(i+j) for i in 1:2, j in 1:2 ]
κ = cond(A)
rounding_bound = κ*eps()

A = repeat([1 2 3],3,1)
κ = cond(A)
rounding_bound = κ*eps()


### norms 

# an example of how things are not always as they seem
A = [ 1/(i+j) for i in 1:6, j in 1:6 ]
κ = cond(A) # very large!


x = 1:6
b = A*x # cook up a right hand side

x_sol = A\b

resid = A*x_sol - b # things look fine...? - be careful of the intepretation!
difference = x - x_sol # things look fine...?
relative_error = norm(difference) / norm(x)
rounding_bound = κ*eps() # upper bound due to rounding errors


# perturb  the right hand side
Δb = randn(size(b));  Δb = 1e-10*normalize(Δb);

new_x = ((A) \ (b+Δb))
Δx = new_x - x
relative_error = norm(Δx) / norm(x)

println("Upper bound from κ: $(κ*norm(Δb)/norm(b))")



## another example 

A = [ 1/(i+j) for i in 1:15, j in 1:15 ]
κ = cond(A) # very large!


x = 1:15
b = A*x # cook up a right hand side
x_sol = A\b
resid = A*x_sol - b # things look fine...?
difference = x - x_sol # whoah!

relative_error = norm(difference) / norm(x)
rounding_bound = κ*eps() # upper bound 

# perturb  the right hand side
Δb = randn(size(b));  Δb = 1e-10*normalize(Δb);

new_x = ((A) \ (b+Δb))
Δx = new_x - x
relative_error = norm(Δx) / norm(x)

println("Upper bound from κ: $(κ*norm(Δb)/norm(b))")

