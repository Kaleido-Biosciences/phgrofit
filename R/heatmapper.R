#' heatmapper: Creating an interactive heatmap with colored categorical labels.
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#'Intended to allow the user to easily generate interactive heatmaps from phgrofit data. Note that the values should first be scaled before using this function. This can be acomplished with scale_phgrofit()
#' @param phgrofit_data This is the output origniating from phgrofit or one of it's modifying functions such as scale_phgrofit or avg_phgrofit.
#' @param labels This is a character vector specifiying what colored labels you would like to be displayed beside the heatmap. There can be several labels, but the color palette will get overwhelmed if there are too many values associated with the labels you choose.
#' @param mouse_over This is the name of a column that you would like to include in a mouse over of the heatmap.
#'
#' @return a heatmaply heatmap.
#'
#' @importFrom magrittr %>%
#' @export
#' @examples
#' # phgropro processing
#' phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' # phgrofit processing
#' phgrofit_output = phgrofit(phgropro_output)
#'
#' ## processing phgrofit data by averaging and scaling
#' phgrofit_data = avg_phgrofti(phgrofit_output,c("Community","Compound")) %>%
#' scale_phgrofit()
#
#' ### plotting heatmap with colored labels for community and mouse over information about the compounds.
#'community_heatmap = heatmapper(phgrofit_data,"Community","Compound")
#'community_heatmap
heatmapper = function(phgrofit_data,labels = "Sample.ID",mouse_over = NULL){
    #if it is phgrofit data
    if("min_pH" %in% names(phgrofit_data)){
    #Selecting just the numeric data
    model_data = phgrofit_data %>%
        dplyr::select(od600_lag_length,
                      od600_max_gr,
                      max_od600,
                      difference_between_max_and_end_od600,
                      auc_od600,
                      max_acidification_rate,
                      min_pH,
                      time_of_min_pH,
                      max_basification_rate,
                      max_pH,
                      difference_between_end_and_min_pH,
                      auc_pH)

    #Selecting just the categorical data
    Sample_Labels = phgrofit_data %>%
        dplyr::select(-c(od600_lag_length,
                         od600_max_gr,
                         max_od600,
                         difference_between_max_and_end_od600,
                         auc_od600,
                         max_acidification_rate,
                         min_pH,
                         time_of_min_pH,
                         max_basification_rate,
                         max_pH,
                         difference_between_end_and_min_pH,
                         auc_pH)
        )
    }else{
        #Else it is grofit data
        model_data = phgrofit_data %>%
            dplyr::select(od600_lag_length,
                          od600_max_gr,
                          max_od600,
                          difference_between_max_and_end_od600,
                          auc_od600)

        #Selecting just the categorical data
        Sample_Labels = phgrofit_data %>%
            dplyr::select(-c(od600_lag_length,
                             od600_max_gr,
                             max_od600,
                             difference_between_max_and_end_od600,
                             auc_od600)
            )
    }

    #Setting row names to be sample.ID
    row.names(Sample_Labels) = 1:nrow(Sample_Labels)

    if(is.null(mouse_over)){

        #Plotting the interactive heatmap without hover text
        heatmap = heatmaply::heatmaply(model_data,dist_method = "manhattan",row_side_colors = Sample_Labels[,labels],
                             cexRow = 0.1,cexCol = 0.7)
        return(heatmap)
    }
    else{
        #Setting up custom hovertext to contain specified information
        mouse_over_vector = as.vector(rep(Sample_Labels[,mouse_over],length(model_data)))

        hover_text = matrix(mouse_over_vector, nrow = length(Sample_Labels[,mouse_over]), ncol = length(model_data))

        #Plotting the interactive heatmap with hover text
       heatmap = heatmaply::heatmaply(model_data,dist_method = "manhattan",row_side_colors = Sample_Labels[,labels],
                             cexRow = 0.1,cexCol = 0.7,custom_hovertext = hover_text)
       return(heatmap)
    }
}



