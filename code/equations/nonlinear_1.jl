# Examples from/based on Fundamentals of Numerical Computation, Julia Edition. Tobin A. Driscoll and Richard J. Braun

using PrettyTables, Plots, LaTeXStrings, LinearAlgebra, NLsolve, Roots



# example using NLsolve 

f(x) = x.^2 .- 3 .+ x .* sin.( 1 ./ x .+ x .^ 2 )

plot(f, -30, 30, label="f(x) =  x^2 - 3 + x * sin(1/x + x^2 )", legend=:topleft)
plot!(zero, -30, 30, label="y=0")


guess = 20.5
nlsolve(f,[guess],ftol=1e-14,show_trace=true)
nlsolve(f,[guess],method=:newton,ftol=1e-14,show_trace=true)

# example using Roots 

find_zero(f, (0.1,3), Bisection(), verbose = true, atol = 1e-14)
find_zero(f, (1.4,1.5), Order1(), verbose = true)
find_zero(f, 1.4, verbose = true)



# bisection method 
function bisection(f,a,b,tolerance)
    b > a || error("b must be greater than a")
    f(a)*f(b) > 0 && error("f(a) and f(b) must have opposite signs")
    while abs(b-a) > tolerance
    c = (a+b)/2
    sign(f(c)) == sign(f(a)) ? a = c : b = c
    end
    return (a+b)/2
end


bisection(f,1,3,1e-14)


# newton's method

f(x) = x*exp(x) - 2;
dfdx(x) = exp(x)*(x+1);


r = nlsolve(x -> f(x[1]),[1.]).zero

plot(f, -1, 1, label="f(x) = x*exp(x) - 2", legend=:topleft)

x = [BigFloat(10);zeros(7)]
for k = 1:7
    x[k+1] = x[k] - f(x[k]) / dfdx(x[k])
end
r = x[end]

ϵ = @. Float64(x[1:end-1] - r)
logerr = @. log(abs(ϵ))
[ logerr[i+1]/logerr[i] for i in 1:length(logerr)-1 ] # p = 2 


### implement newton's method
function newton(f,dfdx,x₁;maxiter=40,ftol=100*eps(),xtol=100*eps())
    x = [float(x₁)]
    y = f(x₁)
    Δx = Inf   # for initial pass below
    k = 1

    while (abs(Δx) > xtol) && (abs(y) > ftol)
        dydx = dfdx(x[k])
        Δx = -y/dydx            # Newton step
        push!(x,x[k]+Δx)        # append new estimate

        k += 1
        y = f(x[k])
        if k==maxiter
            @warn "Maximum number of iterations reached."
            break   # exit loop
        end
    end
    return x
end

x = newton(f,dfdx,1.0)

myscatter = scatter(;xlim = [0.825,1.1],ylim = [-0.25,3])
plot!(f, 0.825, 1.1, label="f(x) = x*exp(x) - 2", legend=:topleft)
animation = @animate for (ind,point) in enumerate(x)
    scatter!(myscatter,[point], [f(point)], alpha = 1 - ind/length(x),ms = 5 + 10*ind/length(x),color = :blue,lab="")
end


gif(animation,fps = 5)


### babylonian method
f(x) = x^2 - 2
dfdx(x) = 2x
x = 1.0
x = newton(f,dfdx,x)

ϵ = @. Float64(x[1:end-1] - sqrt(2))


### bad case 

f(x) = sign(x) * sqrt(abs(x))
plot(f, -1, 1, label="f(x) = sign(x) * sqrt(abs(x))", legend=:topleft)

dfdx(x) = 1/(2*sqrt(abs(x)))

x = 1.0
x = newton(f,dfdx,x)

myscatter = scatter(;xlim = [-2,2])
plot!(f, -2, 2, label="f(x) = sign(x) * sqrt(abs(x))", legend=:topleft)
animation = @animate for (ind,point) in enumerate(x)
    scatter!(myscatter,[point], [f(point)], alpha =  ind/length(x),ms = 5 + 10*ind/length(x),color = :blue,lab="")
end

gif(animation,fps = 5)

# what happens here??? 

