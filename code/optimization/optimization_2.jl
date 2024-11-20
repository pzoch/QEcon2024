
using PrettyTables, Plots, LaTeXStrings, LinearAlgebra, NLsolve, Optim, Roots, Calculus


rosenbrock(x) = (1.0 .- x[1]).^2 .+ 100.0 .* (x[1] .- x[2].^2).^2
grid = -1.5:0.11:1.5;

plot(grid,grid,(x,y)->rosenbrock([x, y]),st=:surface,camera=(50,20))

plot(grid,grid,(x,y)->rosenbrock([x, y]),st=:contour,color=:turbo, levels = 20,clabels=true, cbar=false, lw=1)

## a function to plot the optimization results
function plot_optim(res, start, x,y,ix; offset = 0)
	contour(x, y, (x,y)->sqrt(rosenbrock([x, y])), fill=false, 	color=:turbo, legend=false, levels = 50)
    xtracemat = hcat(Optim.x_trace(res)...)
    plot!(xtracemat[1, (offset+1):ix], xtracemat[2, (offset+1):ix], mc = :white, lab="")
    scatter!(xtracemat[1:1,2:ix], xtracemat[2:2,2:ix], mc=:black, msc=:red, lab="")
    scatter!([1.], [1.], mc=:blue, msc=:blue,markersize = 8, lab="minimum")
    scatter!([start[1]], [start[2]], mc=:yellow, msc=:black, label="start", legend=true)
    scatter!([Optim.minimizer(res)[1]], [Optim.minimizer(res)[2]], mc=:black, msc=:black, label="last", legend=true)

end


## gradient descent 
x0 = [1.0, 0.5]
res_descent = optimize(rosenbrock, x0, GradientDescent(), Optim.Options(store_trace=true, extended_trace=true, iterations = 5000))
plot_optim(res_descent, x0, -0:0.01:1.5, -0:0.01:1.5,10)

## newton's method
res_newton = optimize(rosenbrock, x0, Newton(), Optim.Options(store_trace=true, extended_trace=true, iterations = 5000))
plot_optim(res_newton, x0, -0:0.01:1.5, -0:0.01:1.5,10)


## bfgs
res_bfgs = optimize(rosenbrock, x0, BFGS(), Optim.Options(store_trace=true, extended_trace=true, iterations = 20000))
plot_optim(res_bfgs, x0, -0:0.01:1.5, -0:0.01:1.5,1000)

## bfgs with a stupid stopping criterion
res_stupid = optimize(rosenbrock, x0, BFGS(), Optim.Options(store_trace=true, extended_trace=true,iterations = 10,g_tol = 1e-1, show_trace = true ))
plot_optim(res_stupid, x0, -0:0.01:1.5, -0:0.01:1.5,8)


## nelder mead
res_nm = optimize(rosenbrock, x0, NelderMead(), Optim.Options(iterations = 10, show_trace = true ))

## simulated annealing
res_sa = optimize(rosenbrock, x0, SimulatedAnnealing(), Optim.Options(store_trace=true, extended_trace=true, iterations = 100000))
plot_optim(res_sa, x0, -0:0.01:1.5, -0:0.01:1.5,9000)