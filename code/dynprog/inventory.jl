# ## Inventory management problem
# In this example we study **Inventory management problem**.


# The firm faces stochastic demand $D$. It sells each demanded unit at a price $p$. The firm can sell at most $X$ units, the size of its inventory.
# Every period it has to decide whether to place an order. If it decides to do so, it has to choose the amount of goods ordered $F$. It pays $c$ per each unit ordered and a fixed cost of ordering equal to $K$. 

# There is a maximum inventory size, $\bar{X}$.

# The firm maximizes present discounted value of profits. 

# It discounts future at $\beta\in(0,1)$.

# Bellman equation is 

# $$v(X,D) = \max_F  p \cdot \min \left\{D,X\right\} - c \cdot F - K \cdot \mathbb{I}_{F>0}  +  \beta E_{X,D} v(\min\left\{\max \left\{X-D,0\right\} + F,\bar{X}\right\},D^\prime)$$ 

# load some packages we will need today
using Distributions, QuantEcon, IterTools, Plots


function create_inventory_model(; 
    p = 4, # price per unit
    d_par = 0.7, # demand distribution parameter
    ϕ = Geometric(d_par),
    X_max = 30, # maximum inventory
    K = 3, # cost of placing an order
    c = 1, # cost of unit ordered
    β = 0.99, # discount factor
    X_vec = 0:X_max # vector of possible inventory levels

    )
   
    return (; p, ϕ, X_max, K, c, β,X_vec)
end

function T_operator(v,model)

    (;p, ϕ, X_max, K, c, β, X_vec) = model

    v_new = similar(v)
    σ_ind_new = zeros(Int64,length(X_vec),length(X_vec))
    σ_new = zeros(length(X_vec),length(X_vec))

    for (d_ind, d) in enumerate(X_vec)
        for (x_ind, x) in enumerate(X_vec)
    
            RHS_vec = zeros(length(X_vec))
            for (x_next_ind, x_next) in enumerate(X_vec)
                
                sold = min(d,x)
                revenue = p * sold - K * (x_next > (x - sold)) - c * (x_next - (x - sold))
                
                if x_next >= x - sold
                    RHS_vec[x_next_ind] = revenue + β * sum( v[x_next_ind,d_next_ind] * pdf(ϕ,d_next_ind-1) for d_next_ind in 1:X_max+1 )
                else
                    RHS_vec[x_next_ind] = -Inf
                end
    
            end
    
            v_new[x_ind,d_ind], σ_ind_new[x_ind,d_ind] = findmax(RHS_vec)
            σ_new[x_ind,d_ind] = X_vec[σ_ind_new[x_ind,d_ind]]
        end
    end
    return v_new, σ_new, σ_ind_new
end

    
function vfi(model; tol = 1e-6, maxiter = 1000)

    (;p, ϕ, X_max, K, c, β, X_vec) = model
    
    error = tol + 1.0; iter = 1 #  initialize
    v = zeros(X_max+1,X_max+1); 
    while error > tol && iter < maxiter
        v_new = T_operator(v,model)[1]
        error = maximum(abs.(v_new .- v))
        v = v_new
        iter += 1
    end
    # one more iteration to get the policy function
    v, σ = T_operator(v,model)[1:2]
    return v, σ, iter, error
        
end

model = create_inventory_model()


v, σ, iter, error = vfi(model)

    
(;p, ϕ, X_max, K, c, β, X_vec) = model
plot(X_vec, v[:, 3], label="Demand 3")
plot!(X_vec, v[:, 6], label="Demand 6")
plot!(X_vec, v[:, 9], label="Demand 9", xlabel="Inventory", ylabel="Value Function")

plot(X_vec, σ[:, 3], label="Demand 3")
plot!(X_vec, σ[:, 6], label="Demand 6")
plot!(X_vec, σ[:, 9], label="Demand 9", xlabel="Inventory", ylabel="Inventory next period")

P = Matrix{Float64}(undef, X_max+1, X_max+1)
for (i, j) in product(1:X_max+1, 1:X_max+1)
P[i, j] = sum((σ[i, d+1] == j+1) * pdf(ϕ, d) for d in 0:X_max)
end

# normalize (we truncated the distribution of shocks at X_max)
for i in 1:X_max+1
P[i,:] = P[i,:] / sum(P[i,:])
end


mc = MarkovChain(P, X_vec)
X_ts = simulate(mc, 50, init = 10);

plot(X_ts, label="Inventory", xlabel="Time", ylabel="Inventory")

Ψ = stationary_distributions(mc)[1]
plot(X_vec, Ψ, label="stationary distribution", xlabel="Inventory", ylabel="Probability")


## other iterative methods 

function Tσ_operator(v,σ_ind,model)

    (;p, ϕ, X_max, K, c, β, X_vec) = model

    v_new = similar(v)
    for (d_ind, d) in enumerate(X_vec)
        for (x_ind, x) in enumerate(X_vec)
    
            x_next_ind = σ_ind[x_ind,d_ind]    
            x_next = X_vec[x_next_ind]

            sold = min(d,x)
            revenue = p * sold - K * (x_next > (x - sold)) - c * (x_next - (x - sold))

            if x_next >= x - sold
                v_new[x_ind,d_ind] = revenue + β * sum( v[x_next_ind,d_next_ind] * pdf(ϕ,d_next_ind-1) for d_next_ind in 1:X_max+1 )
            else
                v_new[x_ind,d_ind] = -Inf
            end
    
        end
    end

    return v_new

end

function opi(model; tol = 1e-6, maxiter = 1000, max_m = 15)

    (;p, ϕ, X_max, K, c, β, X_vec) = model
    
    tol = 1e-6; maxiter = 1000
    error = tol + 1.0; iter = 1 #  initialize
    v = zeros(X_max+1,X_max+1); 

    while error > tol && iter < maxiter
        v_new, σ_new, σ_ind_new = T_operator(v,model)

        for m in 1:max_m
            v_new = Tσ_operator(v_new,σ_ind_new,model)
        end


        error = maximum(abs.(v_new .- v))
        v = v_new
        iter += 1
    end
    # one more iteration to get the policy function
    v, σ = T_operator(v,model)[1:2]
    return v, σ, iter, error
        
end

v_opi, σ_opi, iter_opi, error_opi = opi(model)


t_vfi = @time vfi(model)
t_opi = @time opi(model)
