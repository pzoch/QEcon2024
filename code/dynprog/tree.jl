
## Tree Cutting 
using Distributions, Plots, Parameters

@with_kw struct TreeCuttingProblem
    n=100 # number of possible sizes
    h = 0.1 # increment of size
    s_grid = collect(range(0.0,step = h, length = n)) # possible sizes
    S = maximum(s_grid)
    α0 = 0.1 # parameter of the reward function
    α1 = 0.25  # parameter of the reward function
    r = 0.05 # interest rate
    f = x -> α0 * x^α1 # reward function 
    c = 0.0 # cost of cutting down the tree
    p = 0.0 # probability of the tree dying / getting sick 
    q = 0.0 # probability of the recovery from sickness
end


my_tree = TreeCuttingProblem(α0 = 0.1, r=0.05)


### BASIC TREE CUTTING PROBLEM

function T(v,model) # Bellman operator
    @unpack n, s_grid, r, S, f, h = model
    return [max(f(s),  1.0/(1.0+r) * v[min(s_index+1,n)]) for (s_index,s) in enumerate(s_grid)]
end

function get_policy(v,model) # this will be used after finding the fixed point of T
    @unpack n, s_grid, r, S, f, h = model
    return σ = [f(s) >=   1.0/(1.0+r) * v[min(s_index+1,n)] for (s_index,s) in enumerate(s_grid)]
end

function vfi(model;maxiter=1000,tol=1e-8) # value function iteration
    @unpack n, s_grid, r, S, f, h = model
    v_init = f.(s_grid); err = tol + 1.0; iter = 1 #  initialize # initial guess
    v = v_init
    v_history = [v_init]
    while err > tol && iter < maxiter
        v_new = T(v,model)
        err = maximum(abs.(v_new - v)) 
        push!(v_history,v_new)
        v = v_new
        iter += 1
    end
    σ = get_policy(v, model)

    return v, σ, iter, err, v_history
end

v, σ, iter, err, v_history = vfi(my_tree)


plot_v = plot(my_tree.s_grid,v, label="v(s)",linewidth=4,xlabel = "size",ylabel = "v");
plot_σ = plot(my_tree.s_grid,σ, label="policy: 1 = cut down",xlabel = "size", linestyle=:dash,linewidth=2);
plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)

anim = @animate for i in 1:length(v_history)
    plot(my_tree.s_grid, v_history[i], label="iter = $i", alpha = (i+1)/(iter+1), linewidth=4, xlabel="w", ylabel="v",ylim=[0 ,maximum(v)])
end

gif(anim, "v_history.gif", fps = 5)


### TREE CUTTING WITH CUTTING COST 

function T(v,model) # Bellman operator
    @unpack n, s_grid, c, r, S, f, h = model
    return [max(f(s) - c,  1.0/(1.0+r) * v[min(s_index+1,n)]) for (s_index,s) in enumerate(s_grid)]
end

function get_policy(v,model) # this will be used after finding the fixed point of T
    @unpack n, s_grid, c, r, S, f, h = model
    return σ = [ (f(s) - c)  >=   1.0/(1.0+r) * v[min(s_index+1,n)] for (s_index,s) in enumerate(s_grid)]
end


my_tree_costly = TreeCuttingProblem(α0 = 0.1, r=0.05, c = 0.15)

v_costly, σ_costly, iter_costly, err_costly, v_history_costly = vfi(my_tree_costly)


plot_v = plot(my_tree_costly.s_grid,v_costly, label="v(s) - costly",linewidth=4,xlabel = "size",ylabel = "v");
plot!(my_tree_costly.s_grid,v, label="v(s) - free",linewidth=4,color = :red,xlabel = "size",ylabel = "v");
plot_σ = plot(my_tree_costly.s_grid,σ_costly, label="policy: 1 = cut down - costly",xlabel = "size", linestyle=:dash,linewidth=2);
plot!(my_tree_costly.s_grid,σ, label="policy: 1 = cut down - free",color = :red,xlabel = "size", linestyle=:dash,linewidth=2);
plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)


### TREE CUTTING WITH TREE DEATH 

function T(v,model) # Bellman operator
    @unpack n, s_grid, c, r, S, f, h , p  = model
    return [max(f(s) - c,   1.0/(1.0+r) *  ((1 - p) * v[min(s_index+1,n)] + p * 0.5 * f(s))) for (s_index,s) in enumerate(s_grid)]
end

function get_policy(v,model) # this will be used after finding the fixed point of T
    @unpack n, s_grid, c, r, S, f, h, p = model
    return σ = [ (f(s) - c)  >=   1.0/(1.0+r) *  ((1 - p) * v[min(s_index+1,n)] + p * 0.5 * f(s)) for (s_index,s) in enumerate(s_grid)]
end

my_tree_death = TreeCuttingProblem(α0 = 0.1, r=0.05, c = 0.0, p = 0.01)

v_death, σ_death, iter_death, err_death, v_history_death = vfi(my_tree_death)
plot_v = plot(my_tree_death.s_grid,v_death, label="v(s)",linewidth=4,xlabel = "size",ylabel = "v");
plot_σ = plot(my_tree_death.s_grid,σ_death, label="policy: 1 = cut down",xlabel = "size", linestyle=:dash,linewidth=2);
plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)


### TREE CUTTING WITH TREE SICKNESS AND RECOVERY 

function T(v,model) # Bellman operator
    # note - now it takes a matrix as input
    @unpack n, s_grid, c, r, S, f, h , p, q  = model

    v_H = [max(f(s) - c,   1.0/(1.0+r) *  ((1 - p) * v[min(s_index+1,n),1] + p * v[s_index,2])) for (s_index,s) in enumerate(s_grid)]
    v_S = [max(f(s) - c,   1.0/(1.0+r) *  ((1 - q) * v[s_index,2] + q * v[min(s_index+1,n),1])) for (s_index,s) in enumerate(s_grid)]

    return hcat(v_H,v_S)

end

function get_policy(v,model) # this will be used after finding the fixed point of T
    @unpack n, s_grid, c, r, S, f, h, p, q = model

    σ_H  = [ (f(s) - c)  >=   1.0/(1.0+r) *  ((1 - p) * v[min(s_index+1,n),1] + p * v[s_index,2]) for (s_index,s) in enumerate(s_grid)]
    σ_S  = [ (f(s) - c)  >=   1.0/(1.0+r) *  ((1 - q) * v[s_index,2] + q * v[min(s_index+1,n),1]) for (s_index,s) in enumerate(s_grid)]

    return hcat(σ_H,σ_S)
end

function vfi(model;maxiter=1000,tol=1e-8) # value function iteration
    @unpack n, s_grid, r, S, f, h = model
    v_init = [f.(s_grid) f.(s_grid)]; err = tol + 1.0; iter = 1 #  initialize # initial guess
    v = v_init
    v_history = [v_init]
    while err > tol && iter < maxiter
        v_new = T(v,model)
        err = maximum(abs.(v_new - v)) 
        push!(v_history,v_new)
        v = v_new
        iter += 1
    end
    σ = get_policy(v, model)

    return v, σ, iter, err, v_history
end

my_tree_sick = TreeCuttingProblem(α0 = 0.5, r=0.01, c = 0.0, p = 0.25, q = 0.15)

v_sick, σ_sick, iter_sick, err_sick, v_history_sick = vfi(my_tree_sick)


plot_v = plot(my_tree_sick.s_grid,v_sick, label=["v(s) - healthy" "v(s) - sick"] ,linewidth=4,xlabel = "size",ylabel = "v");
plot_σ = plot(my_tree_sick.s_grid,σ_sick, label=["σ(s) - healthy" "σ(s) - sick"],xlabel = "size", linestyle=:dash,linewidth=2);
plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)
