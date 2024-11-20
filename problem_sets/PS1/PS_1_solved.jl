# Load the necessary packages:
using DelimitedFiles, Plots, Statistics

###########################Problem 1###########################
function odd_or_even(n::Int)
    if iseven(n)
        println("Even")
    else
        println("Odd")
    end
end

# Example usage
odd_or_even(7) # Output: Odd
odd_or_even(12) # Output: Even

###########################Problem 2###########################

function compare_three(a,b,c)
    if a > 0 && b > 0 && c > 0
        println("All numbers are positive")
    elseif a == 0 && b == 0 && c == 0
        println("All numbers are zero")
    else
        println("At least one number is not positive")
    end
end

# Example usage
compare_three(1, 2, 3) # Output: All numbers are positive
compare_three(0, 0, 0) # Output: All numbers are zero
compare_three(0, 5, 7) # Output: At least one number is not positive
compare_three(0.0, -4.0, 3.0) # Output: At least one number is not positive


###########################Problem 3###########################
function my_factorial(n::Int)
    result = 1
    for i in 1:n
        result *= i
    end
    return result
end

# Example usage
println(my_factorial(5)) # Output: 120
println(my_factorial(7)) # Output: 5040


###########################Problem 4###########################
function count_positives(arr)
    counter = 0
    for num in arr
        if num > 0
            counter += 1
        end
    end
    println(counter)
end

# Example usage
count_positives([1, -3, 4, 7, -2, 0]) # Output: 3
count_positives([-5, -10, 0, 6]) # Output: 1
count_positives([-5.0, -10.0, 0.0, 6.0]) # Output: 1

###########################Problem 5###########################
using Plots

function plot_powers(n::Int)
    power_plot = plot()
    for i in 1:n
        x = -10:0.2:10
        y = x .^ i
        plot!(x, y, label="x^$i", lw=3, linestyle=:dash)
    end
    xlabel!("x")
    ylabel!("y")
    title!("Powers of x")
    return power_plot
end

# Example usage
my_plot = plot_powers(3)
display(my_plot)


###########################Problem 5###########################
#(I mistakenly provided two different problems with the same number, sorry)

function count_positives_broadcasting(arr)
    positive_count = sum(arr .> 0)
    return positive_count
end

# Example usage
count_positives_broadcasting([1, -3, 4, 7, -2, 0]) # Output: 3
count_positives_broadcasting([-5, -10, 1, 6]) # Output: 1


###########################Problem 6###########################
using Statistics
function standard_deviation(x)
    mean_x = sum(x)/length(x)
    squared_differences = (x .- mean_x) .^ 2
    variance = sum(squared_differences) / (length(x) - 1)
    return sqrt(variance)
end

# Example usage
println(standard_deviation([1, 2, 3, 4, 5])) # Output: 1.5811388300841898
# Compare with the std function from the Statistics package
std([1, 2, 3, 4, 5]) # Output: 1.5811388300841898


###########################Problem 7###########################
data = readdlm("problem_sets\\PS1\\dataset.csv", ',', Float64)
earnings        = data[:, 1]
education       = data[:, 2]
hours_worked    = data[:, 3]

# Plot earnings vs education
scatter(education, earnings, label="", color="green", xlabel="Education", ylabel="Earnings", title="Relationship between Earnings and Education")

# Plot earnings vs hours worked
scatter(hours_worked, earnings, label="", color="red", xlabel="Hours Worked", ylabel="Earnings", title="Relationship between Earnings and Hours Worked")

# Calculate correlations
corr_edu    = cor(education, earnings)
corr_hours  = cor(hours_worked, earnings)

println("Correlation between earnings and education: $corr_edu")
println("Correlation between earnings and hours worked: $corr_hours")
