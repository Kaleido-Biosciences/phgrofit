#' PCA: Easily making a PCA plot with phgrofit data
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#' Intended to allow the user to easily generate PCA plots from phgrofit data. Note that the values should first be scaled before using this function. This can be acomplished with scale_phgrofit()
#' @param phgrofit_data This is the output origniating from phgrofit or one of it's modifying functions such as scale_phgrofit or avg_phgrofit.
#' @param group This is the name of the column that you would like to color the ordination by. A 95 percent confidence interval for this group will be assigned.
#'
#' @return a ggplot2 object containing the 95 percent confidence interval for the group specified.
#' @export
#' @importFrom magrittr %>%
#' @examples
#' ### phgropro processing
#' \dontrun{phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)}
#'
#' ### phgrofit processing
#' \dontrun{phgrofit_output = phgrofit(phgropro_output)}
#'
#' ## scaling phgrofit data
#'\dontrun{ phgrofit_data = scale_phgrofit(phgrofit_output)}
#'
#' ### printing PCA plot with colored confidence intervals for community
#' \dontrun{community_PCA = PCA(phgrofit_data,"Community")
#' print(community_PCA)}
PCA = function(phgrofit_data,group="Sample.ID",mouse_over = "Compound"){
    if("min_pH" %in% names(phgrofit_data)){
    #if it is phgrofit data
    #Selecting numeric data
    PCA_data = dplyr::select(phgrofit_data,
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
                             auc_pH
    )

    #PCA
    PCA_vals = prcomp(PCA_data,center = FALSE, scale = FALSE)

    #Selecting things that may be groups
    groups = dplyr::select(phgrofit_data,-c(od600_lag_length,
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
    # else it is grofit data
    PCA_data = dplyr::select(phgrofit_data,
                             od600_lag_length,
                             od600_max_gr,
                             max_od600,
                             difference_between_max_and_end_od600,
                             auc_od600)
    #PCA
    PCA_vals = prcomp(PCA_data,center = FALSE, scale = FALSE)

    #Selecting things that may be groups
    groups = dplyr::select(phgrofit_data,-c(od600_lag_length,
                                            od600_max_gr,
                                            max_od600,
                                            difference_between_max_and_end_od600,
                                            auc_od600))

}
    #Selecting specified groups
    sel_group = dplyr::select(groups,group)

    #Getting PCA values
    PCA_df = predict(PCA_vals,PCA_data) %>%
        cbind(groups)

    #extracting proportion of varience explained by the PCAs
    Prop_of_var = data.frame(summary(PCA_vals)$importance)[2,]



    #Plotting with 95% confidence interval
    p1 = ggplot2::ggplot(PCA_df,ggplot2::aes_string("PC1","PC2",color = group))+
        ggplot2::geom_point(ggplot2::aes_string(text = mouse_over))+
        ggplot2::stat_ellipse(level=0.95)+
        ggplot2::theme(legend.position = "bottom")+
        ggplot2::ggtitle(paste0("PCA Plot Colored by ",group))+
        ggplot2::xlab(paste0("PCA-1 ",round(Prop_of_var[1]*100,2),"%"))+
        ggplot2::ylab(paste0("PCA-2 ",round(Prop_of_var[2]*100,2),"%"))+
        ggplot2::theme_bw()+
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))

    return(p1)
}
