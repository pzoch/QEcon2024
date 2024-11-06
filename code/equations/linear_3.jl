# Examples from/based on Fundamentals of Numerical Computation, Julia Edition. Tobin A. Driscoll and Richard J. Braun

using PrettyTables, Plots, LaTeXStrings, LinearAlgebra, IterativeSolvers



### calling iterative solvers

# create an easy example 
A = I(1000) + 0.0001*randn(1000,1000)
b = randn(1000)

# check if A is diagonally dominant
all(sum(abs.(A),dims=2) .<= 2abs.(diag(A)))

#check residual
x = jacobi(A, b)
norm(A*x - b)

x = gauss_seidel(A, b)
norm(A*x - b)


# create a bad example 
A = I(1000) + 5 * randn(1000,1000)
all(sum(abs.(A),dims=2) .<= 2abs.(diag(A)))

#check residual
x = jacobi(A, b)
norm(A*x - b)

x = A\b
norm(A*x - b)

### time 


n = 1000:1000:10000
t_operator = []
t_jacobi = []

for n in n 
    A = I(n) + 0.0001*randn(n,n)
    b = randn(n)
    time_operator = @elapsed for j in 1:10 
        A\b
    end
    time_jacobi = @elapsed for j in 1:10 
        jacobi(A,b)
    end
    push!(t_operator,time_operator)
    push!(t_jacobi,time_jacobi)
end


data = hcat(n,t_operator,t_jacobi)
header = (["size","time operator","time jacobi"],["n","seconds","seconds"])
pretty_table(data;
    header=header,
    header_crayon=crayon"yellow bold" ,
    formatters = ft_printf("%5.2f",2))


plt = plot(n,t_operator,label="operator",seriestype=:scatter)
plot!(plt,n,t_jacobi,label="jacobi",seriestype=:scatter,
xaxis=(:log10,L"n"),yaxis = (:log10,"elapsed time (s)"),
title = "Time",)