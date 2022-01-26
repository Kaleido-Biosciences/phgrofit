#' dendrospect_kinetic
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#'Allows the user to easily acess the OD600 and pH kinetic data corresponding with a given cluster.
#'This is intended to allow for easier examination of the underlying data that is produced with the dendrospect function.
#'Note that the phgrofit_data should first be scaled before using this function. This can be acomplished with scale_phgrofit() function.
#' @param phgrofit_data This is the data origniating from phgrofit or one of it's modifying functions such as scale_phgrofit or avg_phgrofit.
#' @param phgropro_data This is the data origniating from phgropro or one of it's modifying functions such as avg_phgropro. It must contain the same Sample.IDs as phgrofit data.
#' @param k The number of clusters.
#' @return a dataframe containing the phgropro data with a column named dendrogram_cluster that represents the cluster the observations correspond to.
#' @export
#'
#' @examples
#' #Returns a dataframe mapping which of the 8 clusters a Sample.ID belongs to.
#' \dontrun{df = dendrospect_model(phgropro_data,k = 8)}
dendrospect_kinetic = function(phgropro_data,phgrofit_data,k = 8){
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
    }else{
        model_data = dplyr::select(phgrofit_data,
                                   Sample.ID,
                                   od600_lag_length,
                                   od600_max_gr,
                                   max_od600,
                                   difference_between_max_and_end_od600,
                                   auc_od600) %>%
            tibble::column_to_rownames("Sample.ID")
    }

    #Creating a dendogram
    dend = hclust(dist(model_data, method = "manhattan"), method = "complete")

    #Mapping Sample.IDs to the cluster number (total cluster numbers specified by k)
    fermentation_clusters = as.factor(dendextend::cutree(dend, k = k,order_clusters_as_data = FALSE)) %>%
        as.data.frame() %>%
        tibble::rownames_to_column()

    names(fermentation_clusters) = c("Sample.ID","dendrogram_cluster")

    #Mapping fermentation clusters to phgropro data
    cluster_data = phgropro_data %>%
        dplyr::inner_join(fermentation_clusters, by = "Sample.ID")

    return(cluster_data)
}
