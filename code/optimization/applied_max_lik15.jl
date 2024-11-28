## Remember to add necessary packages to the environment:
using Plots,NLopt,Statistics,Distributions,ForwardDiff,DelimitedFiles

## Provide underlying p
p = 0.2
DGP = Bernoulli(p)
## One draw from the Bernoulli distribution:
rand(DGP,1)
## 100 draws from the Bernoulli distribution:
y_data = rand(DGP,100)
histogram(y_data,bins=-0.05:0.1:1.05,ylabel="Frequency",xlabel="y",label="100 draws from Bernoulli")


function nlopt_objective_fn(params::Vector, grad::Vector,y) ## y will be the data supplied
    ## Params: Vector of parameters (just p in this case)
    ## Grad: Vector storing the gradient of the function
    ## y: The data supplied

    if length(grad) > 0
        grad[1] =  sum(y)/params[1] - sum(1 .- y)/(1 - params[1])
    end
    obj = log(params[1])*sum(y) + log(1 -params[1])*sum((1 .- y))
    println("Params, Function, Gradient: ",round(params[1],digits=7),", ",round(obj,digits=7),", ",round(grad[1],digits=7)) 
    return obj
end

## Optimization procedure:
## Define the optimizer used: 
opt = NLopt.Opt(:LD_MMA, 1) # algorithm and dimensionality
## See: https://nlopt.readthedocs.io/en/latest/NLopt_Algorithms/

## Define the bounds: 
opt.lower_bounds = [ 0.0]   # lower bound for params
opt.upper_bounds = [ 1.0]   # upper bound for params

## NLopt will terminate when the first one of the specified termination conditions is met
## Tolerance on the on the function values. The algorithm stops if from one iteration to the next:
#opt.ftol_rel    = 0.0001  # |Δf|/|f|  < tol_rel 
opt.ftol_abs     = 0.0000001   # |Δf|      < tol_abs

### Tolerance on the parameters. The algorithm stops if from one iteration to the next:
#opt.xtol_rel    = 0.0001  # |Δx|/|x|  < tol_rel 
opt.xtol_abs    = 0.0001  # |Δx|      < tol_abs

#Note: tol_rel is independent of any absolute scale factors or units

## Or you can specify the maximum number of evaluations:
opt.maxeval = 200

## Supply opt. with the function to be maximized
## NOTE: supply only a function of (params, grad), that is why I use a wrapper function!
opt.max_objective = (params,grad)->nlopt_objective_fn(params, grad,y_data)
## Run the optimization, provide an initial guess
max_f, max_param, ret = optimize(opt, [0.00001])

## max_f        = value of the function at the maximum
## max_param    =  value of the parameters at the maximum (p in this case)
## ret          = stopping criteria used 
println("Stopping criteria used: ", ret) 
println("Number of evaluations: ", opt.numevals)


#############################        LOGIT EXAMPLE:         ############################ 
F_bad(x)    = exp(x)/(1+exp(x))
F_bad(2) 
F_bad(2999) # an issue!
F_good(x)   = 1/(1/(exp(x))+1)
F_good(2)
F(2999)     # no issue!
plot(F_good,-10,10,lw=3,label="The probability of 1")

## Prepare the function to be used in log-likelihood
function F(input_val;probability_of=1)
    if probability_of == 1
        return 1/(1/exp(input_val)+1)!=0 ? 1/(1/exp(input_val)+1) : eps(0.0)
    else
        return 1/(exp(input_val)+1)!=0 ? 1/(exp(input_val)+1) : eps(0.0)
    end
end

## The probability of 1 if the input value is 2
F(2;probability_of=1)
## The probability of 0 if the input value is 2
F(2;probability_of=0)

## The probability of 1 if the input value is 10
F(10;probability_of=1)
## The probability of 0 if the input value is 10
F(10;probability_of=0)

plot(input->F(input;probability_of=1),-10,10,lw=3,label="The probability of 1")
plot!(input->F(input;probability_of=0),-10,10,lw=3,label="The probability of 0")


## Suppose this is our vector of data
y_vec   = [1,1,1,0,1,0]
x_vec   = [-10,-1,2,-3,40,50]

plot(x_vec,y_vec,seriestype=:scatter,legend=false,xlabel="y",ylabel="Binary outcome")
correlation = cor(x_vec,y_vec)


## Let's assume that:
β0 = 0.5
β1 = 0.1

## Lets calculate the log likelihood for the first observation:
y_vec[1]
x_vec[1]

## The log likelihood for the first observation:
y_vec[1]*log(F(β0+β1*x_vec[1];probability_of=1)) + (1-y_vec[1])*log(F(β0+β1*x_vec[1];probability_of=0))

## The log likelihood for the second observation:
y_vec[2]*log(F(β0+β1*x_vec[2];probability_of=1)) + (1-y_vec[2])*log(F(β0+β1*x_vec[2];probability_of=0))

## The log likelihood for the "First part" (see slides):
y_vec .* log.(F.(β0.+β1.*x_vec;probability_of=1)) 

## Note the annoying ".". The easier way:
@. y_vec*log(F(β0+β1*x_vec;probability_of=1))

## The "second part" of the log likelihood (see slides):
@. (1-y_vec)*log(F(β0+β1*x_vec;probability_of=0))

## The log likelihood for all observations:
@. y_vec*log(F(β0+β1*x_vec;probability_of=1)) + (1-y_vec)*log(F(β0+β1*x_vec;probability_of=0))

## And you can simply summ this vector up using the sum() function:

################# Concept check! #################
## Fill in this Logit_LogLik a function: 
function Logit_LogLik(params::Vector,y,x) 
    #####INPUTS TO THE FUNCTION:#####
    ## params: a vector of two parameters.
    ### params[1]: the first parameter (β_0 on slides)
    ### params[2]: the second parameter (β_1 on slides)
    ## y: a vector of binary {0,1} outcomes
    ## x: a vector x variable
    
    #### Replace 0 below: ####
    First_part  = 0 #Replace the 0!
    Second_part = 0 #Replace the 0!
    Sum         = sum(First_part .+ Second_part)
    return Sum
end
##################################################


## Plot the log likelihood function in 3D:
n = 100
animation = @animate for i in range(0, stop = 2π, length = n)

    surface(0.5:0.1:1.5, -0.1:0.01:0.01, (x,y) -> Logit_LogLik([x,y],y_vec,x_vec), st=:surface, c=:blues, legend=false,camera = (30 * (1 + cos(i)), 40));
end
gif(animation,fps = 50)


## Define the NLopt objective function for the Logit:
function nlopt_fn(params::Vector, grad::Vector,y,x)
    function Logit_LogLik(params::Vector,y,x) 
        Sum = sum(@. y*log(F(params[1]+params[2]*x;probability_of=1)) + (1-y)*log(F(params[1]+params[2]*x;probability_of=0)))
        return Sum
    end
    if length(grad) > 0
        ## Here we use the ForwardDiff package to calculate the gradient
        grad .=  ForwardDiff.gradient(temp_params->Logit_LogLik(temp_params,y,x), params)
    end
    obj = Logit_LogLik(params,y,x)
    println("Params, Function, Gradient: ",round.(params,digits=5),", ",round(obj,digits=5),", ",round.(grad,digits=5)) 
    return obj 
end

## Define the optimizer used:
opt = NLopt.Opt(:LD_MMA, 2)
## Define the objective function:
NLopt.max_objective!(opt, (params,grad)->nlopt_fn(params, grad,y_vec,x_vec))
## Define the lower bounds for the two parameters:
opt.lower_bounds = [-15,-15] 
## Define the upper bounds for the two parameters:
opt.upper_bounds = [15,15]   
## Define the stopping criteria:
opt.maxeval      = 2000
opt.xtol_rel     = 1e-10     
## Perform optimization on the object defined and the initial guess:
max_f, max_param, ret = NLopt.optimize(opt, [0.1, 0.1])


## Calculate the standard errors:
hess = ForwardDiff.hessian(max_param -> Logit_LogLik(max_param,y_vec,x_vec), max_param)
std_err_β0 = sqrt(-inv(hess)[1,1])
std_err_β1 = sqrt(-inv(hess)[2,2])


############################## Concept check! ##############################
## Suppose you were asked to model the relationship between the 
## probability of getting to college and the (average) parents education. 
############################################################################

## Read in the data:
## Warning you may need to change the path to the data!
data = readdlm("code\\optimization\\data\\Admit_edParents.csv",',')


## The first column of data is the college admission {0,1}
y_data =  #Replace the 0!

## The second column is the average parents education
x_data =  #Replace the 0!


## Plot the data:
college  = plot(x_data,y_data,seriestype=:scatter,legend=false,xlabel="Average parents education",ylabel="College admission")
title!("College admission vs parents education")



### ESTIMATE THE MODEL! ###
## Use the above algorithm to estimate the parameters of the logit model!
## You can copy most parts of the code, but make sure it works.



