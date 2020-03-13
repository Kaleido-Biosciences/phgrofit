#' PCA: Easily making a PCA plot with phgrofit data
#'
#' @param annotated_data this is annotated data.
#' @param group this is the factor that you would like to color the ordination by. A 95% confidence interval for this group is assigned.
#'
#' @return a ggplot2 object
#' @export
#'
#' @examples
PCA = function(annotated_data,group){

    #Selecting numeric data
    PCA_data = dplyr::select_if(annotated_data, is.numeric)

    #PCA
    PCA_vals = prcomp(PCA_data,center = TRUE, scale = TRUE)

    #Selecting things that may be groups
    groups = dplyr::select_if(annotated_data,function(x){is.factor(x) | is.character(x)})

    #Selecting specified groups
    sel_group = select(groups,group)

    #Getting PCA values
    PCA_df = predict(PCA_vals,PCA_data) %>%
        cbind(sel_group)

    #extracting proportion of varience explained by the PCAs
    Prop_of_var = data.frame(summary(PCA_vals)$importance)[2,]

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
