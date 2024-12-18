
## Neoclassical growth model
using  Plots, Parameters

@with_kw struct NGMProblem

    β = 0.95 # discount factor
    α = 0.3 # production function parameter
    δ = 0.1 # depreciation rate
    σ = 2.0 # intertemporal elasticity of substitution (inverse)

    f = x -> x^α # production function
    u = σ == 1 ? c -> log(c) : c -> c ^ (1-σ) / (1-σ)   # utility function
    k_star = ((β^(-1) - 1 + δ) / α) ^(1/(α-1)) # steady state capital

    k_min  = 0.75 * k_star # minimum capital
    k_max = 1.25 * k_star # maximum capital
    
    n = 100 # number of grid points
    k_grid = range(k_min,stop=k_max,length=n) # grid for capital
    
end




### NGM PROBLEM

function T(v,model) # Bellman operator
    @unpack n, k_grid, β, α, δ, f, u = model

    v_new = zeros(n)
    reward = zeros(n,n)
    σ = zeros(n)

        for (k_index,k) in enumerate(k_grid) # loop over capital today
            for (k_next_index, k_next) in enumerate(k_grid) # loop over capital today

                c = k^α - k_next + (1-δ)*k # consumption
                if c > 0
                    reward[k_index,k_next_index] = u(c) + β * v[k_next_index]
                else
                    reward[k_index,k_next_index] = -Inf
                end

            end 

            v_new[k_index], k_next_index_opt = findmax(reward[k_index,:]) # for each k, find the maximum reward and the optimal next level of capital
            σ[k_index] = k_grid[k_next_index_opt] # store the optimal policy
        end
        
    return v_new, σ
end


function vfi(model;maxiter=1000,tol=1e-8) # value function iteration
    @unpack n, k_grid, β, α, δ, f, u = model
    v_init = zeros(n); err = tol + 1.0; iter = 1 #  initialize # initial guess
    v = v_init
    v_history = [v_init]
    σ = zeros(n)
    while err > tol && iter < maxiter
        v_new, σ = T(v,model)
        err = maximum(abs.(v_new - v)) 
        push!(v_history,v_new)
        v = v_new
        iter += 1
    end


    return v, σ, iter, err, v_history
end


my_ngm = NGMProblem(n=200)

v, σ, iter, err, v_history = vfi(my_ngm)

plot_v = plot(my_ngm.k_grid,v, label="v(k)",linewidth=4,xlabel = "k",ylabel = "v");
plot_σ = plot(my_ngm.k_grid,σ, label="policy: k'(k)", linewidth=4,xlabel = "k",);

# add the 45 degree line
plot!(my_ngm.k_grid,my_ngm.k_grid, label="45 degree line",linewidth=2,linestyle=:dash);

# add the steady state
vline!([my_ngm.k_star], label="steady state",linewidth=2,linestyle=:dash);
plot(plot_v,plot_σ,layout=(1,2),legend=:topleft)

# obtain a sample path for the capital stock

Time = 100 
k_path = zeros(Time)
k_path[1] = my_ngm.k_grid[1] # start at the lowest level of capital

for i in 2:Time
    k_path[i] = σ[findfirst(x->x==k_path[i-1],my_ngm.k_grid)]
end

plot_k_path = plot(1:Time,k_path, label="k(t)",linewidth=4,xlabel = "t",ylabel = "k");




# compare the speed of convergence for two different elasticities of substitution

my_ngm_low_σ = NGMProblem(σ=0.5,n=300)
v_low_σ, σ_low_σ, iter_low_σ, err_low_σ, v_history_low_σ = vfi(my_ngm_low_σ)

my_ngm_high_σ = NGMProblem(σ=5.0,n=300)
v_high_σ, σ_high_σ, iter_high_σ, err_high_σ, v_history_high_σ = vfi(my_ngm_high_σ)

Time = 100 
k_path_low_σ = zeros(Time)
k_path_high_σ = zeros(Time)
k_path_low_σ[1] = my_ngm_low_σ.k_grid[1] # start at the lowest level of capital
k_path_high_σ[1] = my_ngm_high_σ.k_grid[1] # start at the lowest level of capital

for i in 2:Time
    k_path_low_σ[i] = σ_low_σ[findfirst(x->x==k_path_low_σ[i-1],my_ngm_low_σ.k_grid)]
    k_path_high_σ[i] = σ_high_σ[findfirst(x->x==k_path_high_σ[i-1],my_ngm_high_σ.k_grid)]
end


plot_k_convergence = plot(1:Time,k_path_low_σ, label="σ = 0.5",linewidth=4,xlabel = "t",ylabel = "k",legend=:topleft);
plot!(1:Time,k_path_high_σ, label="σ = 5.0",linewidth=4,xlabel = "t",ylabel = "k",legend=:topleft)

# what is wrong here? 
plot(σ_high_σ - my_ngm_high_σ.k_grid)
plot(σ_low_σ - my_ngm_low_σ.k_grid)
