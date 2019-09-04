cluster = function(annotated_data,cols_with_color_label){


   ###Defining the numeric part of the matrix###
    numeric_data = annotated_data %>%
        select(od600_lag_length:length(annotated_data))

    #scaling the numberic data
      scaled_data = sapply(numeric_data,scale)

    #Generating a distance matrix using the scaled data
      dist = dist(scaled_data,method = "manhattan")

    #creating a dendrogram using this data
      dendrogram = as.dendrogram(hclust(dist))


    ###Creating a function to generate a list of colors that will be used to overlay metadata onto the dendrogram ###
    color_label = function(column_name){

        number = length(unique(annotated_data[,column_name]))

        colors = grDevices::rainbow(number)

        factor_num = as.numeric(as.factor(annotated_data[,column_name]))

        names = annotated_data[,column_name]

        output = colors[factor_num]

        names(output) = names

        return(output)
    }



     ###Applying the color labeling function to all of the necessary media components###


#Initalizing a list
list = list()

#Looping through and adding to the list
for(i in cols_with_color_label){
    color_output = color_label(i)
    list[[i]] = color_output
}

#Coneverting the list to a data frame
colors = dplyr::bind_rows(list)

#Defining all of the legend names in order to loop through in the futuree
legend_names = names(list)

#Initalizing a list
legend_list = list()

#Creating a list with all of the legend and fill values.
for(i in legend_names){
    fill = unique(list[[i]])
    legend = unique(names(list[[i]]))
    df = cbind(legend, fill)
    legend_list[[i]] = df
}


par = par(mar = c(5,4,4,8))
plot(dendrogram)


#Adding the colors
dendextend::colored_bars(colors,dendrogram,rowLabels = names(colors))


#Adding the legends
count = -1
for(i in legend_names){
    #Excluding compounds because there are too many and it is
    #pretty much impossible to see them

    if(i != "Compound"){
    count = count + 1

    #par = par(cex = 0.7)
    legend(390,(33-(20 * count)),legend = legend_list[[i]][,1],
           fill = legend_list[[i]][,2],title = i,
           inset=c(-0.50,0), xpd = TRUE,cex = 0.9)
    }
}

}



