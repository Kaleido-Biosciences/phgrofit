cluster = function(annotated_data,cols_with_color_label,num_of_clusters = 0,legend_name = "Community"){


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

        drop_levels = droplevels(annotated_data[,column_name])
        factor_num = as.numeric(as.factor(drop_levels))

        names = as.character(annotated_data[,column_name])

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

#Defining all of the legend names in order to loop through in the future


#Initalizing a list
legend_list = list()

#Creating a list with all of the legend and fill values.
for(i in legend_names){
    fill = unique(list[[i]])
    legend = unique(names(list[[i]]))
    df = cbind(legend, fill)
    legend_list[[i]] = df
}


#Adding a nice color scheme
dendrogram = dendextend::highlight_branches_col(dendrogram)

par(mar = c(15,5,2,2))


plot(dendrogram)

#allowing for the option to higlight a set number of clusters
if(num_of_clusters > 0){
dendextend::rect.dendrogram(dendrogram,k = num_of_clusters,
                            border = "black", lty = 5, lwd = 2)

}

#Adding the colors
dendextend::colored_bars(colors,dendrogram,rowLabels = names(colors))


#Adding the legends

    if(length(legend_name) <= 1){
    count = count + 1

    legend("bottomleft",legend = legend_list[[legend_name]][,1],
           fill = legend_list[[legend_name]][,2],title = legend_name,
           xpd = TRUE,cex = 0.9,inset=c(0,-0.8),ncol = 4)

    }else{
        print("Only one legend is supported. Pick one factor to label the legend by.")}
}





