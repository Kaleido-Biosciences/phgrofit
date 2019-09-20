#' heatmapper: Creating an interactive heatmap with colored categorical labels.
#'
#' @param annotated_data This is the annotated data that results from merging the modeling data with relevant metadata using the meta_combine function.
#' @param labels This is a vector specifiying what colored labels you would like to be displayed beside the heatmap
#'
#' @return a plotly heatmap via heatmaply.
#'
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
heatmapper = function(annotated_data,labels = "Community"){

#Selecting just the numeric data
numeric_data = annotated_data %>%
    dplyr::select(od600_lag_length:length(annotated_data))

#Scaling the numeric data
scaled_data = sapply(numeric_data,scale)

#Selecting just the categorical data
Sample_Labels = annotated_data %>%
    dplyr::select(1:(length(annotated_data)-10))

#Setting row names to be sample.ID
row.names(Sample_Labels) = Sample_Labels$Sample.ID

all = cbind(Sample_Labels,scaled_data)

#Setting the row names to be Sample.IDs
row.names(scaled_data) = all$Sample.ID

#Setting up custom hovertext to contain compound information
compound_vector = rep(Sample_Labels$Compound,length(numeric_data))

hover_text = matrix(compound_vector, nrow = length(Sample_Labels$Compound), ncol = length(numeric_data))

#Plotting the interactive heatmap
heatmaply::heatmaply(scaled_data,dist_method = "manhattan",row_side_colors = Sample_Labels[,labels],
                     cexRow = 0.1,cexCol = 0.7,custom_hovertext = hover_text)

}




