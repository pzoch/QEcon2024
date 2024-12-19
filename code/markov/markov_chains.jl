using Distributions, LinearAlgebra,Plots, Random, QuantEcon

## Seting a random seed for reproducibility
Random.seed!(1111) 

## Define a function that simulates a Markov chain
function mc_sample_path(P; init_x = 1, sample_size = 100)
    @assert size(P)[1] == size(P)[2] # square required
    N = size(P)[1] # number of states

    # Translate rows of transition matrix P
    # into a vector of distributions of discrete RV 
    dists = [Categorical(P[i, :]) for i in 1:N]
    
    # Setup the simulation
    X = Vector{Int64}(undef, sample_size) # allocate memory
    X[1] = init_x # set the initial state

    for t in 2:sample_size
        previous_state_value = X[t-1]
        P_Xt = dists[previous_state_value] # appropriate distribution  
        X[t] = rand(P_Xt) # draw new value
    end
    return X
end


## Recall the Categorical function from the Distributions package:
dice = Categorical([1/6, 1/6, 1/6, 1/6, 1/6, 1/6]); # 6 discrete states and their probabilities
@show dice
## roll a dice 3 times!
@show rand(dice, 3);


#### EXAMPLE 1: Markov chain - unemployed/employed agent ####
α = 0.1;   # finds job  
β = 0.05;    # loses job

P = [1-α α; 
     β 1-β]


periods = 100
sample_path_initU = mc_sample_path(P, init_x = 1, sample_size = periods);
sample_path_initE = mc_sample_path(P, init_x = 2, sample_size = periods);


plot(sample_path_initE, label = "start employed")
plot!(sample_path_initU, label = "start unemployed")



## How does the distribution of employed/unemployed agents evolve over time? 

ψ0 = [0.05 0.95] # let this be the initial distribution  
t = 200 # path length

## Allocate memory
U_vals = zeros(t)
E_vals = similar(U_vals)
U_vals[1] = ψ0[1]
E_vals[1] = ψ0[2]

for i in 2:t
    ψ = [U_vals[i-1] E_vals[i-1]] * P # update the distribution
    U_vals[i] = ψ[1]
    E_vals[i] = ψ[2]

end

plt = scatter(U_vals,E_vals, xlim = [0, 1], ylim = [0, 1], label = false)
plot!(xlabel="Unemployement rate", ylabel="Employment rate", title="Markov chain: Employment dynamics")


## get stationary distribution
## iterative approach:
ψs = ψ0*P^1000



#### EXAMPLE 2: Markov chain Hamilton 2005 ####

P = [0.971 0.029 0; 0.145 0.778 0.077; 0 0.508 0.492] # normal growth, mild recession, severe recession
P12 = P^12 # prob of transition in one year

## Let's do the simulation:
periods = 12 * 25
sample_path_initSR = mc_sample_path(P, init_x = 3, sample_size = periods);
gdp_growth = [3.0,1.0,-2.0]; # normal growth, mild recession, severe recession

time_series = gdp_growth[sample_path_initSR];

plot(time_series,xlabel = "time",ylabel = "annualized growth rate", label=false)


#### APPROXIMATION ####
#### Approximation of AR(1) process using the Tauchen method ####
## x_{t+1} = ρ⋅x_t + ε_t
## ε_t ~ N(0, σ^2)
## Let:
ρ = 0.9
σ = 0.02
N_states = 5
tauch_approximation_1 = tauchen(N_states,ρ, σ)
tauch_approximation_1.p
tauch_approximation_1.state_values

state_space_1 = collect(tauch_approximation_1.state_values)

#### Changing the m (see slides) ####
ρ = 0.9
σ = 0.02
N_states = 5
μ = 0
n_std = 5
tauch_approximation_2 = tauchen(N_states,ρ, σ,μ,n_std)

tauch_approximation_2.p
state_space_2 = collect(tauch_approximation_2.state_values)

#### Approximation of AR(1) process using the Rouwenhorst method ####
ρ = 0.9
σ = 0.02
N_states = 5
μ = 0
rouw_approximation  = rouwenhorst(N_states,ρ, σ,μ)

rouw_approximation.p
state_space_2 = collect(rouw_approximation.state_values)