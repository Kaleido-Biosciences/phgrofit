#' dendrospect
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#'Allows the user to easily see what the average kinetic profile corresponding with a given cluster is.
#'Note that data should be scaled before using this function.
#'
#' @param phgrofit_data This is the data origniating from phgrofit or one of it's modifying functions such as scale_phgrofit or avg_phgrofit.
#' @param phgropro_data This is the data origniating from phgropro or one of it's modifying functions such as avg_phgropro. It must contain the same Sample.IDs as phgrofit data.
#' @param colored_bar_label This is the character name of a column that the user would like to include as colored bar below the dendogram.
#' @param k The number of clusters.
#' @return A ggplot2 object containin a colored dendogram whith a colored bar label and the corresponding kinetic OD600 and pH data.
#' @export
#'
#' @examples
#'
#'# phgropro processing
#' \dontrun{phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)}
#'
#' # phgrofit processing
#' \dontrun{phgrofit_output = phgrofit(phgropro_output)}
#'
#' ## processing phgrofit data by averaging and scaling
#'\dontrun{ phgrofit_data = avg_phgrofti(phgrofit_output,c("Community","Compound")) %>%
#' scale_phgrofit()}
#
#' ### plotting heatmap with colored labels for community and mouse over information about the compounds.
#'\dontrun{plot = PCA(phgrofit_data,"Community")
#'plot}
dendrospect = function(phgrofit_data,
                       phgropro_data,
                       colored_bar_label = NULL,
                       k = 8){
    if("min_pH" %in% names(phgrofit_data)){
        model_data = dplyr::select(phgrofit_data,
                                   Sample.ID,
                                   od600_lag_length,
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
                                   auc_pH) %>%
            tibble::column_to_rownames("Sample.ID")
        #Creating a dendogram
        dend = hclust(dist(model_data, method = "manhattan"), method = "complete")

        #Mapping Sample.IDs to the cluster number (total cluster numbers specified by k)
        fermentation_clusters = as.factor(dendextend::cutree(dend, k = k,order_clusters_as_data = FALSE)) %>%
            as.data.frame() %>%
            tibble::rownames_to_column()

        names(fermentation_clusters) = c("Sample.ID","dendrogram_cluster")

        #Mapping fermentation clusters to phgropro data
        cluster_data = phgropro_data %>%
            dplyr::inner_join(fermentation_clusters, by = "Sample.ID") %>%
            #Experimental_might want to remove later. Is the average of the average appropriate to do here?
            dplyr::group_by(Time,dendrogram_cluster) %>%
            dplyr::summarise(sd_OD600 = sd(mean_OD600),
                          mean_OD600 = mean(mean_OD600),
                          sd_pH = sd(mean_pH,na.rm = TRUE),
                          mean_pH = mean(mean_pH,na.rm = TRUE)
            )


        ##Ordering data to use as colored bars
        colored_bar = phgrofit_data[dend$order,]
        colored_bar$Row = 1:nrow(colored_bar)

        #Plotting
        plot = phgrofit:::combined_dendro_plot(dend,cluster_data,colored_bar,k,colored_bar_label)
        return(plot)
    }else{
        model_data = dplyr::select(phgrofit_data,
                                   Sample.ID,
                                   od600_lag_length,
                                   od600_max_gr,
                                   max_od600,
                                   difference_between_max_and_end_od600,
                                   auc_od600) %>%
            tibble::column_to_rownames("Sample.ID")


        #Creating a dendogram
        dend = hclust(dist(model_data, method = "manhattan"), method = "complete")

        #Mapping Sample.IDs to the cluster number (total cluster numbers specified by k)
        fermentation_clusters = as.factor(dendextend::cutree(dend, k = k,order_clusters_as_data = FALSE)) %>%
            as.data.frame() %>%
            tibble::rownames_to_column()

        names(fermentation_clusters) = c("Sample.ID","dendrogram_cluster")

        #Mapping fermentation clusters to phgropro data
        cluster_data = phgropro_data %>%
            dplyr::inner_join(fermentation_clusters, by = "Sample.ID") %>%
            #Experimental_might want to remove later. Is the average of the average appropriate to do here?
            dplyr::group_by(Time,dendrogram_cluster) %>%
            dplyr::summarise(sd_OD600 = sd(mean_OD600),
                          mean_OD600 = mean(mean_OD600))

        ##Ordering data to use as colored bars
        colored_bar = phgrofit_data[dend$order,]
        colored_bar$Row = 1:nrow(colored_bar)

       #Plotting
        plot = phgrofit:::combined_dendro_plot(dend,cluster_data,colored_bar,k,colored_bar_label)
        return(plot)
    }
}

