using Plots, NLopt, LaTeXStrings

## A function to create a generic household object:
function create_HH(;  
    R   = 1,        # Rate of return
    β   = 1,        # Discount factor
    σ   = 1,        # Risk aversion
    a_0 = 0,        # Initial assets
    y   = [5, 2])   # Income path

    function log_u(c)
        return c <= 0 ? -Inf : log(c)
    end
    function crra_u(c,σ)
        return c <= 0 ? -Inf : (c^(1 - σ) - 1) / (1 - σ)
    end
    ## The utility function:
    u   = σ==1 ? c -> log_u(c) : c ->crra_u(c,σ) 
    ## The marginal utility function:
    u′ = σ==1 ? c -> 1/c : c -> c^(-σ)
    return (; R, β, σ,a_0,y,u,u′)
end

## Now we can create a household object:
## This will have all the default values for parameters
hh      = create_HH()
hh.R
hh.β
hh.a_0
## But we can change the defaults!
hh   = create_HH(β=0.9, R=1.1,a_0=2,y=[4,4])
hh.R
hh.β
hh.a_0
hh.y[1]
hh.y[2]
## The HH object also has the utility function, try it for different σ
hh_01   = create_HH(σ=0.1)
hh_1    = create_HH(σ=1)
hh_2    = create_HH(σ=2)

hh_01.u(1.0)
hh_1.u(1.0)
hh_2.u(1.0)

## Plot the utility as a function of consumption for different σ  
plot(hh_01.u,0.3,10,xlabel="Consumption", label="σ=0.1",ylabel="u(c)",lw=3)
plot!(hh_1.u,0.3,10,label="σ=1",lw=3)
plot!(hh_2.u,0.3,10,label="σ=2",lw=3)

## Plot the marginal utility as a function of consumption for different σ
plot(hh_01.u′,0.3,10,xlabel="Consumption", label="σ=0.1",ylabel="u′(c)",lw=3)
plot!(hh_1.u′,0.3,10,label="σ=1",lw=3)
plot!(hh_2.u′,0.3,10,label="σ=2",lw=3)


##############################Two-period model################################
## Define a household to be modelled:
hh    = create_HH(y=[3,1],a_0=1)

## Suppose that household saves a1:
a1 =0
## Consumption then becomes:
c_1 = hh.R*hh.a_0   + hh.y[1]   -a1
c_2 = hh.R*a1       + hh.y[2]

## Define the Lifetime utility function in the two period model:
function two_periods_U(a::Vector,hh) 
    c_1 = hh.R*hh.a_0   + hh.y[1]   - a[1]
    c_2 = hh.R*a[1]     + hh.y[2]
    Lifetime_util       = hh.u(c_1) + hh.β*hh.u(c_2) 
    return Lifetime_util
end
plot(a->two_periods_U([a],hh) ,-0.95,3.95,xlabel="Level of assets saved", ylabel="Lifetime utility",lw=2,label=L"U\left(c_{1},c_{2}\right)")
title!(L"\beta=1,R=1,a_{0}=1,y=[3,1],\sigma=1")


##### Optimization with NLopt #####
## Define the objective function:
function nlopt_objective_fn(a::Vector, grad::Vector,hh)
        c_1             = hh.R*hh.a_0   + hh.y[1] - a[1]
        c_2             = hh.R*a[1]     + hh.y[2]
        Lifetime_util   = hh.u(c_1)     + hh.β*hh.u(c_2)         
        println("Params, Function: ",round.(a,digits=5),", ",round(Lifetime_util,digits=5)) 
    return Lifetime_util 
end

## Define a household to be modelled:
hh    = create_HH(y=[3,1],a_0=1)
## Define the optimizer used:
opt = NLopt.Opt(:LN_COBYLA, 1)
## Define the objective function:
NLopt.max_objective!(opt, (a,grad)->nlopt_objective_fn(a, grad,hh))
## Define the lower bounds for the two parameters:
opt.lower_bounds = [-1.0] 
## Define the upper bounds for the two parameters:
opt.upper_bounds = [5.0]   
## Define the stopping criteria:
opt.maxeval      = 2000
opt.xtol_rel     = 1e-10     
## Perform optimization on the object defined and the initial guess:
max_f, a_optim, ret = NLopt.optimize(opt, [0.1])

## The optimal consumption is:
c_1 = hh.R*hh.a_0       + hh.y[1] -a_optim[1]
c_2 = hh.R*a_optim[1]   + hh.y[2]

plot(a->two_periods_U([a],hh) ,-0.95,3.95,xlabel="Level of assets saved", ylabel="Lifetime utility",lw=2,label=L"U\left(c_{1},c_{2}\right)")
vline!([a_optim[1]],label="Optimal level of assets saved")


##############################Five-period model################################

####################Concept check####################
## 1. Fill in the missing parts in the nlopt_objective_fn function below
## 2. Put in the correct dimensionality while defining the  optimizer used
## 3. Plot the path of optimal consumption

function nlopt_objective_fn(a::Vector, grad::Vector,hh)
    ####### TASK 1:  Fill in the missing parts in the nlopt_objective_fn function #######
        c_1     = 0 #Replace the 0!
        c_2     = 0 #Replace the 0!
        c_3     = 0 #Replace the 0!
        c_4     = 0 #Replace the 0!
        c_5     = 0 #Replace the 0!

        Lifetime_util = 0 # Replace the 0! (what is a lifetime utility?) 
 
        println("Params, Function ",round.(a,digits=5),", ",round(Lifetime_util,digits=5)) 
        return Lifetime_util 

end

## Define a household modelled:
hh    = create_HH(y=[1,4,3,0.5,0.5],a_0=1)

## Define the optimizer used:
####### TASK 2: Define a correct dimensionality: #######
opt = NLopt.Opt(:LN_COBYLA, 0) 
## Define the objective function:
NLopt.max_objective!(opt, (a,grad)->nlopt_objective_fn(a, grad,hh))
## Define the lower bounds for the parameters:
opt.lower_bounds = [-100,-100,-100,-100] 
## Define the upper bounds for the parameters:
opt.upper_bounds = [15,15,15,15] # lower bound
## Define the stopping criteria:
opt.maxeval      = 2000
opt.xtol_rel     = 1e-10     
## Perform optimization on the object defined and the initial guess:
max_f, a_optim, ret = NLopt.optimize(opt, [0.1,0.1,0.1,0.1])

####### TASK 3: Define and plot the path of optimal consumption #######
c_1     = 0 #Replace the 0!
c_2     = 0 #Replace the 0!
c_3     = 0 #Replace the 0!
c_4     = 0 #Replace the 0!
c_5     = 0 #Replace the 0!
plot([c_1,c_2,c_3,c_4,c_5],xlabel="Period",ylabel="Consumption",label="",lw=3,yaxis=[0,3])


####### TASK 3: Define and plot the path of optimal consumption #######

####################The end of concept check####################

## A generic function which can take:
## (1) any household object  (hh)
## (2) any initial guess for the optimizer (initial_a)
## (3) any lower bound for the optimizer (lower_bound)
## and solve the consumption-saving problem!
function solvehh(hh;initial_a_guess=[0.1,0.1,0.1,0.1],lower_bound=-100)
    function nlopt_objective_fn(a::Vector, grad::Vector,hh)
        c_1     = hh.R*hh.a_0   + hh.y[1]   -a[1]
        c_2     = hh.R*a[1]     + hh.y[2]   -a[2]
        c_3     = hh.R*a[2]     + hh.y[3]   -a[3]
        c_4     = hh.R*a[3]     + hh.y[4]   -a[4]
        c_5     = hh.R*a[4]     + hh.y[5]

        Lifetime_utility = hh.u(c_1) + hh.β*hh.u(c_2) + hh.β^2*hh.u(c_3) + hh.β^3*hh.u(c_4) + hh.β^4*hh.u(c_5) 
 
        println("Params, Function ",round.(a,digits=5),", ",round(Lifetime_utility,digits=5)) 
        return Lifetime_utility 
    end
    opt = NLopt.Opt(:LN_COBYLA, 4)
    opt.lower_bounds = [lower_bound,lower_bound,lower_bound,lower_bound]  # lower bound
    opt.upper_bounds = [15,15,15,15] # lower bound
    opt.maxeval      = 20000
    opt.xtol_rel     = 1e-10 # tolerance
    NLopt.max_objective!(opt, (params,grad)->nlopt_objective_fn(params, grad,hh))
    max_f, a_optim, ret = NLopt.optimize(opt, initial_a_guess)
    
    c1     = hh.R*hh.a_0   + hh.y[1]   -a_optim[1]
    c2     = hh.R*a_optim[1]     + hh.y[2]   -a_optim[2]
    c3     = hh.R*a_optim[2]     + hh.y[3]   -a_optim[3]
    c4     = hh.R*a_optim[3]     + hh.y[4]   -a_optim[4]
    c5     = hh.R*a_optim[4]     + hh.y[5]
    C       = (c1=c1,c2=c2,c3=c3,c4=c4,c5=c5)
    A       = (a1=a_optim[1],a2=a_optim[2],a3=a_optim[3],a4=a_optim[4],a5=0)
    return C,A
end

function plot_paths(C,A,hh,;crange=[0,2],arange=[-2,2])
    A_path  = plot([A.a1,A.a2,A.a3,A.a4,A.a5],xlabel="Period",label="Level of assets saved",lw=3,yaxis=arange)
    hline!([0],label="",ls=:dash)
    C_path  = plot([C.c1,C.c2,C.c3,C.c4,C.c5],xlabel="Period",label="Consumption",lw=3,yaxis=crange)
    Y_path  = scatter(hh.y,xlabel="Period",label="Income",lw=3,ls=:dash)
    All_paths = plot(A_path,C_path,Y_path)
    display(All_paths)
end

## Motives for saving: (1) Smoothing motive
## Note: each time I create a new HH with different y path, but equal β and R!

## First example: y path is [1,0,0,0,0]
hh = create_HH(y=[1,0,0,0,0],β=0.9,R=1/0.9)
C,A = solvehh(hh;initial_a_guess=[0.2,0.1,0.1,0.1])
plot_paths(C,A,hh)
## Second example: y path is [0,0,1,0,0], be careful about initial_a_guess!
hh = create_HH(y=[0,0,1,0,0],β=0.9,R=1/0.9)
C,A = solvehh(hh;initial_a_guess=[-0.1,-0.2,0.1,0.1])
plot_paths(C,A,hh)
## Third example: y path is [0,0,0,0,1], be careful about initial_a_guess!
hh = create_HH(y=[0,0,0,0,1],β=0.9,R=1/0.9)
C,A = solvehh(hh;initial_a_guess=[-0.1,-0.2,-0.3,-0.4])
plot_paths(C,A,hh)


## Motives for savings: (2) Intertemporal motive:
## Note: each time I create a new HH with different β and R, but equal y path!
##First example: β=0.99,R=1.05; βR>1
hh = create_HH(y=[1,1,1,1,1],β=0.99,R=1.05)
C,A = solvehh(hh;initial_a_guess=[0.1,0.1,0.1,0.1])
plot_paths(C,A,hh,arange=[-1,1])
C.c2/C.c1
C.c3/C.c2
C.c4/C.c3

##Second example: β=0.9,R=1.05; βR<1
hh = create_HH(y=[1,1,1,1,1],β=0.9,R=1.05)
C,A = solvehh(hh;initial_a_guess=[-0.1,-0.1,-0.1,-0.1])
plot_paths(C,A,hh,arange=[-1,1])

C.c2/C.c1
C.c3/C.c2
C.c4/C.c3

#Note the importance of the borrowing constraint:
## No borrowing constraint:
hh = create_HH(y=[1,3,5,2,1],β=0.9,R=1/0.9)
C,A = solvehh(hh;initial_a_guess=[0.1,0.1,0.1,0.1])
plot_paths(C,A,hh;crange=[0,3],arange=[-2,3])
## Borrowing constraint: a>=0
hh = create_HH(y=[1,3,5,2,1],β=0.9,R=1/0.9)
C,A = solvehh(hh;initial_a_guess=[0.1,0.1,0.1,0.1],lower_bound=0.0)
plot_paths(C,A,hh;crange=[0,4],arange=[-2,4])