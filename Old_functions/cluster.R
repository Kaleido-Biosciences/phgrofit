#' colored_dendro
#'
#'This function creates a dendrogram using the output from the meta_combine function using the manhatten distance as the distance method.
#'The ploted dendogram will have a colored bar representing different categorical features of the data as specified by the cols_with_color_label parameter
#'A specified number of clusters can be highlighted via boxes by the num_of clusters parameter.
#'This function can plot a colored legend for a categorical feature as specified by the user.
#'
#'For a more detailed and interactive representation of the data, it is suggested to use the heatmapper function.
#'
#' @param annotated_data this is modeling data from phgrobiome that has been combined with relevant metadata through the meta_combine function.
#' @param cols_with_color_label this is a vector of the names of the columns that you would like to color on the
#' @param num_of_clusters this is the number of clusters that you would like to highlight by boxing. The default is 0
#' @param legend_name this is the name of the condition that you would like the legend to be colored by. The defalut legend is Community.
#' Currently only one legend is supported
#'
#' @return plot of colored dendrogram
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#'
#' annotated_data = meta_combine(phgrobiome_output,metadata,compound_info)
#'
#' colored_dendro(annotated_data,cols_with_color_label = c("Community","Compound","Composition","Manual_Curation"),
#' num_of_clusters = 3,legend_name = "Composition")
#'
#' This will result in a colored dendrogram with colored bars representing distinct Communities, Compounds, Composition of compounds,
#' and a manual curation. The legend will show the corresponding colors for all compositions.
colored_dendro = function(annotated_data,cols_with_color_label,num_of_clusters = 0,legend_name = "Community"){


   ###Defining the numeric part of the matrix###
    numeric_data = annotated_data %>%
        dplyr::select(od600_lag_length:length(annotated_data))

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

        drop_levels = as.character(annotated_data[,column_name])
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
for(i in legend_name){
    fill = unique(list[[i]])
    legend = unique(names(list[[i]]))
    df = cbind(legend, fill)
    legend_list[[i]] = df
}


#Adding a nice color scheme
dendrogram = dendextend::highlight_branches_col(dendrogram)

#Changing the label size to be very small
dendrogram = dendextend::set(dendrogram,"labels_cex", 0.1)

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

    legend("bottomleft",legend = legend_list[[legend_name]][,1],
           fill = legend_list[[legend_name]][,2],title = legend_name,
           xpd = TRUE,cex = 0.9,inset=c(0,-0.8),ncol = 4)

    }else{
        print("Only one legend is supported. Pick one factor to label the legend by.")}
}





