
## Resource Extraction 
using Distributions, Plots, Parameters

@with_kw struct ResourceExtractionProblem
    n = 5 #number of possible prices 
    p_min = 1.0 # lowest price
    p_max = 10.0 # highest price

    p_vals = collect(LinRange(p_min, p_max, n))
    distribution = Categorical(1/n * ones(n))
    ϕ = pdf(distribution)

    S = 50 # size of resource
    s_grid = collect(0:S) # grid for the size of the resource

    α0 = 0.1 # parameter of the reward function
    α1 = 2.25  # parameter of the reward function
    β = 0.95 # discount factor
    c = x -> α0 * x^α1 # cost function 
end




### BASIC RESOURCE EXTRACTION PROBLEM

function T(v,model) # Bellman operator
    @unpack n, p_vals, ϕ, S, c, β, s_grid = model

    v_new = zeros(S+1,n)
    reward = zeros(S+1,S+1)
    σ = zeros(S+1,n)

    for (p_index,p) in enumerate(p_vals) # loop over the prices 
        for (s_index,s) in enumerate(s_grid) # loop over the sizes today 
            for (s_next_index, s_next) in enumerate(s_grid) # loop over the sizes tomorrow

                if s_next <= s # if the size tomorrow is smaller than today, we can extract
                    x = s - s_next # extraction size
                    reward[s_index,s_next_index] = p * x - c(x) + β * ϕ' * v[s_next_index,:]
                elseif s_next > s # if the size tomorrow is larger than today, we cannot extract
                    reward[s_index,s_next_index] = - Inf
                end

            end 

            v_new[s_index,p_index], s_next_index_opt = findmax(reward[s_index,:]) # for each (s,p) pair, find the maximum reward and the optimal next size
            σ[s_index,p_index] = s - s_grid[s_next_index_opt] # optimal extraction size
        end
    end
        
    return v_new, σ
end


function vfi(model;maxiter=1000,tol=1e-8) # value function iteration
    @unpack n, p_vals, ϕ, S, c, β = model
    v_init = zeros(S+1,n); err = tol + 1.0; iter = 1 #  initialize # initial guess
    v = v_init
    v_history = [v_init]
    σ = zeros(S+1,n)
    while err > tol && iter < maxiter
        v_new, σ = T(v,model)
        err = maximum(abs.(v_new - v)) 
        push!(v_history,v_new)
        v = v_new
        iter += 1
    end


    return v, σ, iter, err, v_history
end


my_resource = ResourceExtractionProblem(α0 = 0.1, α1 = 2.25, β = 0.95)

v, σ, iter, err, v_history = vfi(my_resource)


plot_labels = ["p = $p" for p in my_resource.p_vals]
plot_alphas = LinRange(0.1, 1.0, length(my_resource.p_vals))
plot_colors = repeat([:green],outer = length(my_resource.p_vals))

plot_v = plot();
plot_σ = plot();
for p_index in 1:length(my_resource.p_vals)
    plot!(plot_v,my_resource.s_grid,v[:,p_index], label=plot_labels[p_index],linewidth=4,alpha = plot_alphas[p_index],color = plot_colors[p_index],xlabel = "size",ylabel = "v")
    plot!(plot_σ,my_resource.s_grid,σ[:,p_index], label=plot_labels[p_index],linewidth=4,alpha = plot_alphas[p_index],color = plot_colors[p_index],xlabel = "size",ylabel = "σ")
end


plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)


# sample path of the size of the resource

# draw a random path of prices
Time = 50

price_index_path = rand(my_resource.distribution,Time)
price_level_path = my_resource.p_vals[price_index_path]

# simulate the size of the resource
s_path = zeros(Time+1)
s_path[1] = my_resource.S

x_path = zeros(Time)
for t in 1:Time
    x_path[t] =  σ[Int(s_path[t]+1),price_index_path[t]]
    s_path[t+1] = s_path[t] - x_path[t]
end

plot_s_path = plot(1:Time,s_path[1:Time], label="s(t)",linewidth=4,xlabel = "t",ylabel = "s");
plot_x_path = plot(1:Time,x_path, label="x(t)",linewidth=4,xlabel = "t",ylabel = "x");
plot_p_path = plot(1:Time,price_level_path, label="p(t)",linewidth=4,xlabel = "t",ylabel = "p");

plot(plot_s_path,plot_x_path,plot_p_path,layout=(1,3),legend=:topleft)