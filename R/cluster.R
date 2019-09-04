
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

        num = length(unique(annotated_data[,column_name]))

        #For some reason colors is getting stuck at the previous num
        colors = grDevices::palette(grDevices::rainbow(num))

        factor_num = as.numeric(as.factor(annotated_data[,column_name]))

        names = annotated_data[,column_name]

        output = colors[factor_num]

        names(output) = names

        return(output)
    }


    test1 = color_label("Community")
    test1 = color_label("Compound")


    final = cbind(test1,test2)
    cols_with_color_label = c("Compound","Community")

     ###Applying the color labeling function to all of the necessary media components###


#Initalizing a list
list = list()

#Looping through and adding to the list
for(i in cols_with_color_label){
    color_output = color_label(i)
    list[[i]] = color_output
}

#Conerverting list to a data frame
colors = dplyr::bind_rows(list)

#ploting the dendrogram
plot(dendrogram)

#Adding the colored pars
dendextend::colored_bars(coloring,dendogram,rowLabels = names(colors))

}



