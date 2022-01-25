#' graph_check
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#' This function is used in the exported function model_fit_check to generate a graphical representation of the model fit
#'
#' @param data: This is the OD600 + pH data from a single well. Contains Columns for Sample.ID, Time, OD600, and pH.
#'
#' @return a ggplot2 object
#'
#' @examples
#'
#' \dontrun{for( i in Sample.ID){
#' loop_data = data %>%
#' dplyr::filter(Sample.ID == i )
#' # graph check is set up to plot each well independantly
#' print(graph_check(loop_data))
#' }}
graph_check = function(data){
    #if this is to include pH
    original_data = data
    if("pH" %in% names(data)){

        data = original_data %>%
            dplyr::select(-pH) %>%
            dplyr::filter(!is.na(OD600))

        parameters = od600_features(data)
    ###Generating OD600 Plot###

        OD600_model = smooth.spline(y = data[,"OD600"], x=data[,"Time"],spar = 0.70)
        OD600_pred = as.data.frame(predict(OD600_model,x=data[,"Time"]))


        OD_x = seq(min(data$Time),max(data$Time), by = 0.1)
        OD_y = OD_x * parameters$od600_max_gr + parameters$b_of_max_od600_gr_tangent_line
        OD_tangent = data.frame(OD_x,OD_y) %>%
            dplyr::filter(OD_y > min(data$OD600) & OD_y < max(data$OD600))


        p1 = ggplot2::ggplot(data,ggplot2::aes(Time,OD600))+
            ggplot2::geom_point()+
            ggplot2::geom_line(data = OD600_pred, ggplot2::aes(x,y))+
            ggplot2::geom_hline(yintercept = parameters$max_od600,color = "green",linetype = "dashed")+
            ggplot2::geom_vline(xintercept = parameters$od600_lag_length,color = "blue",linetype = "dashed")+
            ggplot2::geom_line(data = OD_tangent, ggplot2::aes(OD_x,OD_y),linetype ="dashed",color = "red")+
            ggplot2::theme_bw()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))+
            ggplot2::ggtitle("OD600")

        ###Generating pH plot###
        data = original_data %>%
            dplyr::select(-OD600) %>%
            dplyr::filter(!is.na(pH))

        parameters = pH_features(data)

        pH_model = smooth.spline(y = data[,"pH"], x=data[,"Time"],spar = 0.70)
        pH_pred = as.data.frame(predict(pH_model,x=data[,"Time"]))

        #Generating acidification rate tangent line
        ar_x = seq(min(data$Time),max(data$Time), by = 0.1)
        ar_y = ar_x * parameters$max_acidification_rate + parameters$b_of_max_ar_tangent_line
        ar_tangent = data.frame(ar_x,ar_y) %>%
            dplyr::filter(ar_y > min(data$pH) & ar_y < max(data$pH))

        #Generating basificiation rate tangent line
        br_x = seq(min(data$Time),max(data$Time), by = 0.1)
        br_y = br_x * parameters$max_basification_rate + parameters$b_of_max_br_tangent_line
        br_tangent = data.frame(br_x,br_y) %>%
            dplyr::filter(br_y > min(data$pH) & br_y < max(data$pH))

        p2 = ggplot2::ggplot(data,ggplot2::aes(Time,pH))+
            ggplot2::geom_point()+
            ggplot2::geom_line(data = pH_pred, ggplot2::aes(x,y))+
            ggplot2::geom_hline(yintercept = parameters$max_pH,color = "green",linetype = "dashed")+
            ggplot2::geom_hline(yintercept = parameters$min_pH,color = "blue",linetype = "dashed")+
            ggplot2::geom_line(data = ar_tangent, ggplot2::aes(ar_x,ar_y),linetype ="dashed",color = "red")+
            ggplot2::geom_line(data = br_tangent, ggplot2::aes(br_x,br_y),linetype ="dashed",color = "red")+
            ggplot2::theme_bw()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))+
            ggplot2::ggtitle("pH")

        p3 = ggpubr::ggarrange(p1,p2)

        return(p3)
    }else{
        parameters = od600_features(data)

        ###Generating OD600 Plot###
        OD600_model = smooth.spline(y = data[,"OD600"], x=data[,"Time"],spar = 0.70)
        OD600_pred = as.data.frame(predict(OD600_model,x=data[,"Time"]))


        OD_x = seq(min(data$Time),max(data$Time), by = 0.1)
        OD_y = OD_x * parameters$od600_max_gr + parameters$b_of_max_od600_gr_tangent_line
        OD_tangent = data.frame(OD_x,OD_y) %>%
            dplyr::filter(OD_y > min(data$OD600) & OD_y < max(data$OD600))


        p1 = ggplot2::ggplot(data,ggplot2::aes(Time,OD600))+
            ggplot2::geom_point()+
            ggplot2::geom_line(data = OD600_pred, ggplot2::aes(x,y))+
            ggplot2::geom_hline(yintercept = parameters$max_od600,color = "green",linetype = "dashed")+
            ggplot2::geom_vline(xintercept = parameters$od600_lag_length,color = "blue",linetype = "dashed")+
            ggplot2::geom_line(data = OD_tangent, ggplot2::aes(OD_x,OD_y),linetype ="dashed",color = "red")+
            ggplot2::theme_bw()+
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))+
            ggplot2::ggtitle("OD600")

        p3 = ggpubr::ggarrange(p1)
        return(p3)
    }
}
