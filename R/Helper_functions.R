###Function that will calculate for OD600:  length of lag, max growth rate, min growth rate###
rate_parameters = function(data,measurement){

    model = smooth.spline(y = data[,measurement], x=data[,"Time"],spar = 0.70)
    pred = as.data.frame(predict(model,x=data[,"Time"]))
    deriv = as.data.frame(predict(model,x=data[,"Time"],deriv = 1))

    #Defining the max slope and where it occurs
        max_index = which(deriv$y == max(deriv$y))
        max_time = deriv[max_index,1]
        max_slope = deriv[max_index,2]

    #Defining the min slope and where it occurs
        min_index = which(deriv$y == min(deriv$y))
        min_time = deriv[min_index,1]
        min_slope =deriv[min_index,2]

    #Determining the lag phase for OD600
    if(measurement == "OD600"){

        #Defining the coefficients necessary to determine the tangent line through this point
        max_y = pred[which(pred$x == max_time),"y"]
        max_x = max_time
        max_b = max_y - (max_slope * max_x)

        #Calculating lag phase
        Starting_OD600 = pred[which(pred$x == min(pred$x)),2]
        Lag_end = (Starting_OD600 - max_b)/max_slope
        Lag_length = Lag_end - min(data[,"Time"])

        #binding together all of the important parameters
        output = cbind("od600_max_gr" = max_slope,"time_of_od600_max_gr" = max_time,"b_of_max_od600_gr_tangent_line" = max_b,"od600_min_gr" = min_slope,
                       "time_of_od600_min_gr" = min_time,"od600_lag_length" = Lag_length)
        return(output)
    }
    if(measurement == "pH"){

        #Defining the coefficients necessary to determine the tangent line through max acidification
        min_y = pred[which(pred$x == min_time),"y"]
        min_x = min_time
        min_b = min_y - (min_slope * min_x)
        #Defining the coefficients necessary to determine the tangent line through max basification
        max_y = pred[which(pred$x == max_time),"y"]
        max_x = max_time
        max_b = max_y - (max_slope * max_x)
        output = cbind("max_acidification_rate" = min_slope, "time_of_max_ar" = min_time,"b_of_max_ar_tangent_line" = min_b,
                       "max_basification_rate" = max_slope,"time_of_max_br" = max_time,"b_of_max_br_tangent_line" = max_b)
        return(output)
    }else{
        print("enter `OD600` or `pH` as a measurement")
    }
}

###Function to calculate max OD600, Difference between max and end OD600, min pH,
#time the min pH occurs, max pH, difference between the end and min pH.

absolute_parameters = function(data,measurement){

    model = smooth.spline(y = data[,measurement], x=data[,"Time"],spar = 0.70)
    pred = as.data.frame(predict(model,x=data[,"Time"]))

    if(measurement == "OD600"){
        max_OD600 = max(pred$y)
        OD600_decrease = max_OD600 - pred[which(max(pred$x) == pred$x),2]
        output = cbind("max_od600"= max_OD600,"difference_between_max_and_end_od600" = OD600_decrease)
        return(output)
    }

    if(measurement == "pH"){
        min_pH = min(pred$y)
        end_min_diff = pred[which(max(pred$x) == pred$x),2] - min_pH
        min_pH_time = pred[which(min_pH == pred$y),1]
        max_pH = max(pred$y)

        output = cbind(min_pH,"time_of_min_pH" = min_pH_time, max_pH, "difference_between_end_and_min_pH" = end_min_diff)
        return(output)
    }else{
        print(("enter `OD600` or `pH` as a measurement"))
    }
}


###Function to combine the rate and absolute parameters###
Combine_parameters = function(input){

    step_1 = rate_parameters(input,"pH")
    step_2 = rate_parameters(input,"OD600")
    step_3 = absolute_parameters(input,"pH")
    step_4 = absolute_parameters(input,"OD600")

    input$Sample.ID = as.character(input$Sample.ID)

    Sample.ID = dplyr::distinct(input,Sample.ID) %>%
        dplyr::pull()


    params = as.data.frame(cbind(cbind(step_1,step_2,step_3,step_4)))

    output = cbind(Sample.ID,params)

    return(output)
}

###Function to combine just OD600 rate and absolute parameters###
Combine_OD600_parameters = function(input){

    step_1 = rate_parameters(input,"OD600")
    step_2 = absolute_parameters(input,"OD600")


    input$Sample.ID = as.character(input$Sample.ID)

    Sample.ID = dplyr::distinct(input,Sample.ID) %>%
        dplyr::pull()


    params = as.data.frame(cbind(cbind(step_1,step_2)))

    output = cbind(Sample.ID,params)

    return(output)
}


###Function to generate a plot checking all of the parameters that were derived from the model fit

graph_check = function(data){

    parameters = phgrofit:::Combine_parameters(input = data)

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
}

combined_dendro_plot = function(dend,cluster_data,colored_bar,k,colored_bar_label){

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
        ggplot2::theme_classic()+
        ggplot2::geom_point()+
        ggplot2::geom_line()+
        ggplot2::geom_errorbar(ggplot2::aes(ymax = mean_OD600 + sd_OD600, ymin = mean_OD600 - sd_OD600)) +
        ggplot2::facet_grid(~dendrogram_cluster) +
        ggplot2::theme_bw()+
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                       legend.position = "none")+
        ggplot2::xlab("Time (hr)")

    #pH plot
    pH = ggplot2::ggplot(cluster_data,ggplot2::aes(Time,mean_pH,color = dendrogram_cluster)) +
        ggplot2::theme_classic() +
        ggplot2::geom_point() +
        ggplot2::geom_line() +
        ggplot2::geom_errorbar(ggplot2::aes(ymax = mean_pH + sd_pH, ymin = mean_pH - sd_pH)) +
        ggplot2::facet_grid(~dendrogram_cluster) +
        ggplot2::theme_bw()+
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
}


