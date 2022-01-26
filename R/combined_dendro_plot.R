#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'  @param dend dendrogram
#'  @param cluster_data clustering data
#'  @param colored_bar colored bar
#'  @param k what is the k?
#'  @param colored_bar_label what is the label of the colored bar
combined_dendro_plot = function(dend,cluster_data,colored_bar,k,colored_bar_label){
    if("mean_pH" %in% names(cluster_data)){
        #Dendogram plot
        dend_plot = dend %>%
            as.dendrogram() %>%
            dendextend::set("labels_cex", 0) %>%
            dendextend::set("leaves_pch", 19)  %>%
            dendextend::set("nodes_cex", 0.7) %>%
            dendextend::color_branches(k = k) %>%
            dendextend::as.ggdend()

        dendrogram = ggplot2::ggplot(dend_plot)

        colored_bar_plot = ggplot2::ggplot(colored_bar,ggplot2::aes_string(x="Row",y = 1,fill=colored_bar_label))+
            ggplot2::geom_tile()+
            ggplot2::scale_y_continuous(expand=c(0,0))+
            ggplot2::theme(axis.title=ggplot2::element_blank(),
                           axis.ticks= ggplot2::element_blank(),
                           axis.text= ggplot2::element_blank(),
                           legend.position="bottom",
                           legend.title = ggplot2::element_blank(),
                           panel.grid.major = ggplot2::element_blank(),
                           panel.grid.minor = ggplot2::element_blank(),
                           panel.background = ggplot2::element_blank())+
            viridis::scale_fill_viridis(discrete = TRUE)


        #OD600 plot
        OD600 = ggplot2::ggplot(cluster_data,ggplot2::aes(Time,mean_OD600,color = dendrogram_cluster)) +
            ggplot2::geom_point()+
            ggplot2::geom_line()+
            ggplot2::geom_errorbar(ggplot2::aes(ymax = mean_OD600 + sd_OD600, ymin = mean_OD600 - sd_OD600)) +
            ggplot2::facet_grid(~dendrogram_cluster) +
            ggplot2::theme_classic()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                           legend.position = "none")+
            ggplot2::xlab("Time (hr)")

        #pH plot
        pH = ggplot2::ggplot(cluster_data,ggplot2::aes(Time,mean_pH,color = dendrogram_cluster)) +
            ggplot2::geom_point() +
            ggplot2::geom_line() +
            ggplot2::geom_errorbar(ggplot2::aes(ymax = mean_pH + sd_pH, ymin = mean_pH - sd_pH)) +
            ggplot2::facet_grid(~dendrogram_cluster) +
            ggplot2::theme_classic()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                           legend.position = "none")+
            ggplot2::xlab("Time (hr)")

        #Arranging the plots into a complete figure.
        #Dendogram and color bar
        dendrogram_and_bar = ggpubr::ggarrange(dendrogram,colored_bar_plot,nrow = 2,heights = c(4,1))
        #OD600 and pH
        OD600_pH = ggpubr::ggarrange(OD600, pH, nrow = 2, labels = c("B", "C"))

        final = ggpubr::ggarrange(dendrogram_and_bar,
                                  OD600_pH,
                                  nrow = 2,
                                  labels = "A",
                                  legend = "none"
                                  )
    }else{
        #Dendogram plot
        dend_plot = dend %>%
            as.dendrogram() %>%
            dendextend::set("labels_cex", 0) %>%
            dendextend::set("leaves_pch", 19)  %>%
            dendextend::set("nodes_cex", 0.7) %>%
            dendextend::color_branches(k = k) %>%
            dendextend::as.ggdend()

        dendrogram = ggplot2::ggplot(dend_plot)

        colored_bar_plot = ggplot2::ggplot(colored_bar,ggplot2::aes_string(x="Row",y = 1,fill=colored_bar_label))+
            ggplot2::geom_tile()+
            ggplot2::scale_y_continuous(expand=c(0,0))+
            ggplot2::theme(axis.title=ggplot2::element_blank(),
                           axis.ticks= ggplot2::element_blank(),
                           axis.text= ggplot2::element_blank(),
                           legend.position="bottom",
                           legend.title = ggplot2::element_blank(),
                           panel.grid.major = ggplot2::element_blank(),
                           panel.grid.minor = ggplot2::element_blank(),
                           panel.background = ggplot2::element_blank())+
            viridis::scale_fill_viridis(discrete = TRUE)


        #OD600 plot
        OD600 = ggplot2::ggplot(cluster_data,ggplot2::aes(Time,mean_OD600,color = dendrogram_cluster)) +
            ggplot2::geom_point()+
            ggplot2::geom_line()+
            ggplot2::geom_errorbar(ggplot2::aes(ymax = mean_OD600 + sd_OD600, ymin = mean_OD600 - sd_OD600)) +
            ggplot2::facet_grid(~dendrogram_cluster) +
            ggplot2::theme_classic()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                           legend.position = "none")+
            ggplot2::xlab("Time (hr)")

        dendrogram_and_bar = ggpubr::ggarrange(dendrogram,colored_bar_plot,nrow = 2,heights = c(4,1))

        OD600 = ggpubr::ggarrange(OD600, nrow = 1, labels = c("B"))

        final = ggpubr::ggarrange(dendrogram_and_bar,
                                  OD600,
                                  nrow = 2,
                                  labels = "A",
                                  legend = "none"
                                  )
        return(final)
    }
}
