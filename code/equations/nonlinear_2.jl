
using PrettyTables, Plots, LaTeXStrings, LinearAlgebra, NLsolve





f(x) = [(x[1]^2 + x[2]^2)^2 - 2*(x[1]^2 - x[2]^2);
        (x[1]^2 + x[2]^2 - 1)^3 - x[1]^2*x[2]^3]


    n = 100
    animation = @animate for i in range(0, stop = 2π, length = n)

    surface(-1:0.1:1, -1:0.1:1, (x,y) -> f([x,y])[1], st=:surface, c=:blues, legend=false);
    surface!(-1:0.1:1, -1:0.1:1, (x,y) -> f([x,y])[2], st=:surface, c=:reds, legend=false, alpha=0.5,camera = (30 * (1 + cos(i)), 40))

    end

    gif(animation,fps = 50)

    contourplot = contour(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[1], c=:blues,  levels=[0.0], clabels=true, cbar=false, lw=1);
    contour!(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[2], c=:reds, levels=[0.0], clabels=true, cbar=false, lw=1)



# calculate derivatives 
dfdx(x) = [4*x[1]*(x[1]^2 + x[2]^2 -1)                          4*x[2]*(x[1]^2 + x[2]^2 +1);
           6*x[1]*(x[1]^2 + x[2]^2 - 1)^2 - 2*x[1]*x[2]^3       6*x[2]*(x[1]^2 + x[2]^2 - 1)^2 - 3*x[1]^2*x[2]^2]            


# find all four roots 
initial_x = [0.5,0.5]


r = nlsolve(f, dfdx, initial_x,method=:newton,store_trace=true,extended_trace=true)
x_interations = vcat([(r.trace.states[i].metadata["x"])' for i in 1:r.iterations]...)

function plot_iterations(f,x_interations)
    contourplot = contour(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[1], c=:blues,  levels=[0.0], clabels=true, cbar=false, lw=1);
    contour!(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[2], c=:reds, levels=[0.0], clabels=true, cbar=false, lw=1)

    animation = @animate for i in 1:size(x_interations,1)
        scatter!(contourplot,[x_interations[i,1]], [x_interations[i,2]], color = :blue, lab="iterations", legend=false)
    end
    
    return animation
    
end


animation = plot_iterations(f,x_interations)
gif(animation,fps = 5)
root_1 = r.zero


initial_x = [3.0,4.43]
r = nlsolve(f,initial_x,store_trace=true,extended_trace=true)
x_interations = vcat([(r.trace.states[i].metadata["x"])' for i in 1:r.iterations]...)
animation = plot_iterations(f,x_interations)
gif(animation,fps = 5)
root_2 = r.zero


initial_x = [-1.5,-0.43]
r = nlsolve(f,initial_x,method=:newton,store_trace=true,extended_trace=true)
x_interations = vcat([(r.trace.states[i].metadata["x"])' for i in 1:r.iterations]...)
animation = plot_iterations(f,x_interations)
gif(animation,fps = 5)
root_3 = r.zero


initial_x = [1.5,-0.43]
r = nlsolve(f,initial_x,method=:newton,store_trace=true,extended_trace=true)
x_interations = vcat([(r.trace.states[i].metadata["x"])' for i in 1:r.iterations]...)
animation = plot_iterations(f,x_interations)
gif(animation,fps = 5)
root_4 = r.zero

# plot all four roots
contourplot = contour(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[1], c=:blues,  levels=[0.0], clabels=true, cbar=false, lw=1);
contour!(-2:0.01:2, -2:0.01:2, (x,y) -> f([x,y])[2], c=:reds, levels=[0.0], clabels=true, cbar=false, lw=1)
scatter!(contourplot,[root_1[1],root_2[1],root_3[1],root_4[1]], [root_1[2],root_2[2],root_3[2],root_4[2]], color = [:blue,:blue,:blue,:blue], lab="roots", legend=true)



function consumers_first_order_conditions(x,p,w,α)
    return  [α * x[1]^(-α)*x[2]^(1-α) - x[3]*p[1];
            (1-α) * x[1]^(1-α)*x[2]^(-α) - x[3]* p[2];
            p[1]*x[1] + p[2]*x[2] - w]
end 

# derive demand for an example 
r = nlsolve( x -> consumers_first_order_conditions(x,[1.0,1.0],2.0,0.25),[1.0,1.0,0.5],method=:newton,store_trace=true,extended_trace=true)
r


# suppose we want to do it many times for different prices 
function demand(p,w,α)
    r = nlsolve( x -> consumers_first_order_conditions(x,p,w,α),[1.0,1.0,0.5],method=:newton,store_trace=true,extended_trace=true)
    @assert r.f_converged == true
    return r.zero[1:2]
end

demand([1,1],2,0.25)

# we can use broadcasting to calculate the demand for many prices
x=[]
p1_vec = 0.1:0.1:10.0
for p1 in p1_vec
        push!(x,demand([p1,1.0],2.0,0.25))
end

x = hcat(x...)
plot(p1_vec,x[1,:],label="good 1",xlabel="price",ylabel="quantity",legend=:topleft)

# different convention 
plot(x[1,:],p1_vec,label="good 1",xlabel="quantity",ylabel="price",legend=:topleft)