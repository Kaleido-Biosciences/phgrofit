#' heatmapper: Creating an interactive heatmap with colored categorical labels.
#'
#' @param phgrofit_output This is the output from phgrofit
#' @param labels This is a charachter vector specifiying what colored labels you would like to be displayed beside the heatmap. There can be several labels, but the color palette will get overwhelmed if there are too many labels.
#'
#' @return a plotly heatmap via heatmaply.
#'
#' @importFrom magrittr %>%
#' @export
#' @examples
#' ### phgropro processing
#' phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' ### phgrofit processing
#' phgrofit_output = phgrofit(phgropro_output)
#'
#' ### printing heatmap with colored labels for community
#' community_heatmap = heatmapper(phgrofit_output,"Community")
#' print(community_heatmap)
heatmapper = function(phgrofit_output,labels = "Sample.ID"){

    #Selecting just the numeric data
    numeric_data = phgrofit_output %>%
        dplyr::select_if(is.numeric)

    #Scaling the numeric data
    scaled_data = sapply(numeric_data,scale)

    #Selecting just the categorical data
    Sample_Labels = phgrofit_output %>%
        dplyr::select_if(function(x){is.factor(x) | is.character(x)})

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





