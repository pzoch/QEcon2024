using PrettyTables, Plots, LaTeXStrings, LinearAlgebra


### let's solve a simple system of equations 
A = [1.0 2.5; 3.25 4.125]
b = [5.5,6.75]

x_sol = A\b

# confirm the solution
A*x_sol - b

# let's solve the same system using the inverse
A_inv = inv(A)
x_sol2 = A_inv * b 

# confirm the solution
A*x_sol2 - b

# are the solutions the same?
x_sol == x_sol2
x_sol ≈ x_sol2



### let's count flops!

### solve system using A\b 
n = 50:50:500
t_operator = []
t_inv = []

for n in n 
    A = randn(n,n)
    b = randn(n)
    time = @elapsed for j in 1:100 # do it many times to be able to measure time
        A\b
    end
    push!(t_operator,time)
end

for n in n 
    A = randn(n,n)
    b = randn(n)
    time = @elapsed for j in 1:100 # do it many times to be able to measure time
        inv(A)*b
    end
    push!(t_inv,time)
end

data = hcat(n,t_operator,t_inv)
header = (["size","time operator","time inv"],["n","seconds","seconds"])
pretty_table(data;
    header=header,
    header_crayon=crayon"yellow bold" ,
    formatters = ft_printf("%5.2f",2))


plt = plot(n,t_operator,label="operator",seriestype=:scatter)
plot!(plt,n,t_inv,label="inv(A)*b",seriestype=:scatter,
xaxis=(:log10,L"n"),yaxis = (:log10,"elapsed time (s)"),
title = "Time of matrix-matrix multiplication",)



function forwardsub(L,b)

    n = size(L,1)
    x = zeros(n)
    x[1] = b[1]/L[1,1]
    for i in 2:n
        s = sum( L[i,j]*x[j] for j in 1:i-1 )
        x[i] = ( b[i] - s ) / L[i,i]
    end
    return x
end

function backsub(U,b)

    n = size(U,1)
    x = zeros(n)
    x[n] = b[n]/U[n,n]
    for i in n-1:-1:1
        s = sum( U[i,j]*x[j] for j in i+1:n )
        x[i] = ( b[i] - s ) / U[i,i]
    end
    return x
end


# let's test our functions 
A = rand(1.:9.,5,5)
L = tril(A)
U = triu(A)
b = rand(1.:9.,5)


x_L = forwardsub(L,b)
x_U = backsub(U,b)

resid_L = L*x_L - b
resid_U = U*x_U - b


# let's count flops!
n = 500:500:10000
t = []
for n in n 
    A = randn(n,n)
    L = tril(A)
    b = randn(n)
    time = @elapsed for j in 1:30 # do it many times to be able to measure time
        forwardsub(L,b)
    end
    push!(t,time)
end


scatter(n,t,label="data",legend=false,
xaxis=(:log10,L"n"),yaxis = (:log10,"elapsed time (s)"),
title = "Time of forward elimination",);

plot!(n,t[end]*(n/n[end]).^2,label=L"O(n^2)",lw=2,ls=:dash,lc=:red,legend = :topleft)


### LU factorization 

function my_lu_fact(A)
    n = size(A,1)
    A_ret = float(copy(A))
    for j in 1:n 
        for i in j+1:n
            A_ret[i,j] = A_ret[i,j]/A_ret[j,j]
            for k in j+1:n
                A_ret[i,k] = A_ret[i,k] - A_ret[i,j]*A_ret[j,k]
            end
        end
    end

    return A_ret
end

A = rand(1.:9.,5,5)

A_ret = my_lu_fact(A)
L = tril(A_ret,-1) + I
U = triu(A_ret)

# let's check if the factorization is correct
L*U - A


# combine forward and backward substitution and LU factorization

function my_lu_solve(A,b)
    A_ret = my_lu_fact(A)
    L = tril(A_ret,-1) + I
    U = triu(A_ret)
    y = forwardsub(L,b)
    x = backsub(U,y)
    return x
end

# let's test our function
A = rand(1.:9.,5,5)
b = rand(1.:9.,5)
x = my_lu_solve(A,b)
resid = A*x - b

# let's count flops!

n = 100:100:1500
t_1 = []
t_2 = []
for n in n 
    A = randn(n,n)
    b = randn(n)
    time_1 = @elapsed for j in 1:10 # do it many times to be able to measure time
        my_lu_solve(A,b)
    end
    time_2 = @elapsed for j in 1:10 
        A\b
    end
    push!(t_1,time_1)
    push!(t_2,time_2)
end

plt = plot(n,t_1,label="my LU",seriestype=:scatter)
plot!(plt,n,t_2,label="operator",seriestype=:scatter,
xaxis=(:log10,L"n"),yaxis = (:log10,"elapsed time (s)"),
title = "Time",)
