
using PrettyTables, Plots, LaTeXStrings, LinearAlgebra, NLsolve, Optim, Roots, Calculus



f_univariate(x)     = 2x^2+3x+1
dfdx_univariate(x)  = 4x+3

plot(f_univariate, -2.0, 1.0, label = L"f(x) = 2x^2+3x+1", xlabel = L"x", ylabel = L"f(x)", title = "Univariate Function", lw = 2)
plot!(dfdx_univariate, -2.0, 1.0, label = L"f'(x) = 4x+3", lw = 2)


# use bisection on f'
find_zero(dfdx_univariate, (-2,2), Bisection(), verbose = true, atol = 1e-14)

# use golden section on f
optimize(f_univariate, -2.0, 1.0, GoldenSection(),atol = 1e-14)


# use newton's method
function newton(f,dfdx,dfdx2,x0; ε=10e-6, δ=10e-6, maxcounter = 100, verbose = false)
    # this algorithm is from Judd (1998), page 98
    x_old = x0
    x_new = 2*abs(x0) + 1
    counter = 1
    guesses = []

    while ((abs(dfdx(x_old)) > δ) || (abs(x_new-x_old) > ε * (1+abs(x_old))))
        guesses = push!(guesses,x_old)
        if verbose
            println("Iteration = $counter")    
            println("Point = $x_old")    
            println("Value = $(f(x_old))")  
            println("Derivative = $(dfdx(x_old))")  
            println("")
        end


        if counter > maxcounter
            println("Maximum number of iterations ($maxcounter) reached")
            break
        end

        counter += 1
        x_old = x_new
        x_new = x_old - dfdx(x_old)/dfdx2(x_old)
        
        
    end

    guesses = push!(guesses,x_new)
    return (argmin = x_new, val = f(x_new), derivative  = dfdx(x_new), points = guesses, iteration = counter)
end


dfdx2_univariate(x)  = 4.0

newton(f_univariate,dfdx_univariate,dfdx2_univariate,100.0)


# what if we do not have derivatives?
# we can use Calculus.jl package to get finite differences

# finite differences use the fact that the derivative is the limit of the difference quotient
# f′(x) = lim_{h->0} (f(x+h) - f(x))/h
# so we can approximate it with a small h

# this is usually not the best way to get derivatives 
# here we need to do it like this to use our "newton" function
# this function needs functions as arguments

f_derivative(x)     = derivative(f_univariate,x)
f_2nd_derivative(x) = second_derivative(f_univariate,x)

plot(dfdx_univariate, -2.0, 1.0, label = L"f'(x) = 4x+3", lw = 2)
plot!(f_derivative, -2.0, 1.0, label = L"f'(x) = 4x+3 (approx)", lw = 2, linestyle = :dot)
plot!(dfdx2_univariate, -2.0, 1.0, label = L"f''(x) = 4", lw = 2)
plot!(f_2nd_derivative, -2.0, 1.0, label = L"f''(x) = 4 (approx)", lw = 2, linestyle = :dot)
