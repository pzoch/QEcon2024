using Statistics, Plots, DelimitedFiles

#Let's get some practice working with vectors and matrices!
data_1 = readdlm("code//data_analysis//datasets//dataset_1.csv", ',',Float64)
data_2 = readdlm("code//data_analysis//datasets//dataset_2.csv", ',',Float64)

#Accessing the first (x) column of the data_1 matrix
data_1[:,1]

#Calculating mean of the first column of the data_1 matrix
mean(data_1[:,1])

#Calculating standard deviation of the first column of the data_1 matrix
std(data_1[:,1])

plot_1 = scatter(data_1[:,1], data_1[:,2]; legend=false, color=:blue, markersize = 5, opacity=0.7)
xaxis!(plot_1, "x")
yaxis!(plot_1, "y")
title!(plot_1, "Scatter plot of data_1")
display(plot_1)

plot_2 = scatter(data_2[:,1], data_2[:,2]; legend=false, color=:purple, markersize = 5)
xaxis!(plot_2, "x")
yaxis!(plot_2, "y")
title!(plot_2, "Scatter plot of data_2")
display(plot_2)

#Combining two plots into one
plot(plot_1,plot_2,layout=(1,2),size=(600, 400))


#data_1 is a matrix, if we want to calculate the mean we need to specify the dimension!
mean(data_1, dims=1)
#dims=2 would produce mean over columns
mean(data_1, dims=2)

#in Julia there are many ways to compute mean of a vector: 
map(mean, eachcol(data_1))
[mean(col) for col in eachcol(data_1)]
 
#Standard deviation, again we need to specify the dimension!
std(data_1, dims=1)


#Pearson correlation coefficient  
cor(data_1)
#The above returns a matrix of correlations between all columns
cor(data_1)[1,2]
cor(data_1[:,1],data_1[:,2])

#Calculate correlations for both datasets!
cor_data_1 = cor(data_1)[1,2]
cor_data_2 = cor(data_2)[1,2]


#Note: This syntax with $(variable) is used to insert the value of a variable into a string
#It will be very useful for your homework!
plot_1 = scatter(data_1[:,1], data_1[:,2]; label="cor(x,y)=$(cor_data_1)", color=:blue, markersize = 5)


cor_data_1 = round(cor_data_1; digits=2)
cor_data_2 = round(cor_data_2; digits=2)

plot_1 = scatter(data_1[:,1], data_1[:,2]; label="cor(x,y)=$(cor_data_1)", color=:blue, markersize = 5)
xaxis!(plot_1, "x")
yaxis!(plot_1, "y")
title!(plot_1, "Scatter plot of data_1")
display(plot_1)



plot_2 = scatter(data_2[:,1], data_2[:,2]; label="cor(x,y)=$cor_data_2", color=:purple, markersize = 5)
xaxis!(plot_2, "x")
yaxis!(plot_2, "y")
title!(plot_2, "Scatter plot of data_2")
display(plot_2)
plot(plot_1,plot_2,layout=(1,2))

#############################        QUICK TASK:         ############################# 
# a. Import dataset_3 as data_3.
# b. Calculate the correlation between x and y in the data.
# c. Plot the data as a red scatter plot, name it properly, and label it with the correlation coefficient.
# d. Combine plot_1, plot_2, and your new plot into one plot (use the option layout=(1,3)).