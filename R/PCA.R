#' PCA: Easily making a PCA plot with phgrofit data
#'
#' @param phgrofit_output this is output from the phgrofit
#' @param group this is the factor that you would like to color the ordination by. A 95 percent confidence interval for this group will be assigned.
#'
#' @return a ggplot2 object containing the 95 percent confidence interval for any group specfied in gorup.
#' @export
#' @importFrom magrittr %>%
#' @examples
#' ### phgropro processing
#' phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' ### phgrofit processing
#' phgrofit_output = phgrofit(phgropro_output)
#'
#' ### printing PCA plot with colored confidence intervals for community
#' community_PCA = PCA(phgrofit_output,"Community")
#' print(community_PCA)
PCA = function(phgrofit_output,group="Sample.ID"){

    #Selecting numeric data
    PCA_data = dplyr::select_if(phgrofit_output, is.numeric)

    #PCA
    PCA_vals = prcomp(PCA_data,center = TRUE, scale = TRUE)

    #Selecting things that may be groups
    groups = dplyr::select_if(phgrofit_output,function(x){is.factor(x) | is.character(x)})

    #Selecting specified groups
    sel_group = dplyr::select(groups,group)

    #Getting PCA values
    PCA_df = predict(PCA_vals,PCA_data) %>%
        cbind(sel_group)

    #extracting proportion of varience explained by the PCAs
    Prop_of_var = data.frame(summary(PCA_vals)$importance)[2,]

    #Setting my perferred theme
    ggplot2::theme_set(ggplot2::theme_bw()+ ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)))

    #Plotting with 95% confidence interval
    p1 = ggplot2::ggplot(PCA_df,ggplot2::aes_string("PC1","PC2",color = group))+
        ggplot2::geom_point()+
        ggplot2::stat_ellipse(level=0.95)+
        ggplot2::theme(legend.position = "bottom")+
        ggplot2::ggtitle(paste0("PCA Plot Colored by ",group))+
        ggplot2::xlab(paste0("PCA-1 ",round(Prop_of_var[1]*100,2),"%"))+
        ggplot2::ylab(paste0("PCA-2 ",round(Prop_of_var[2]*100,2),"%"))

    return(p1)
}
