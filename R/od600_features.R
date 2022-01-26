#' od600_features #' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#' @param data data
od600_features = function(data){

    # Fitting the spline
    model = smooth.spline(y = data[,"OD600"], x=data[,"Time"],spar = 0.70)
    pred = as.data.frame(predict(model,x=data[,"Time"]))

    # RMSE
    rmse_od600 = ModelMetrics::rmse(data$OD600,pred$y)

    deriv = as.data.frame(predict(model,x=data[,"Time"],deriv = 1))

    #Defining the max slope and where it occurs
    max_index = which(deriv$y == max(deriv$y))
    max_time = deriv[max_index,1]
    max_slope = deriv[max_index,2]

    #Defining the min slope and where it occurs
    min_index = which(deriv$y == min(deriv$y))
    min_time = deriv[min_index,1]
    min_slope = deriv[min_index,2]

    #Defining the coefficients necessary to determine the tangent line through this point
    max_y = pred[which(pred$x == max_time),"y"]
    max_x = max_time
    max_b = max_y - (max_slope * max_x)

    #Calculating lag phase
    Starting_OD600 = pred[which(pred$x == min(pred$x)),2]
    Lag_end = (Starting_OD600 - max_b)/max_slope
    Lag_length = Lag_end - min(data[,"Time"])

    #Max OD600
    max_OD600 = max(pred$y)
    OD600_decrease = max_OD600 - pred[which(max(pred$x) == pred$x),2]

    #AUC
    auc = MESS::auc(pred$x,pred$y,type = "linear")

    #Returning final data frame
    output = as.data.frame(cbind("starting_od600" = Starting_OD600,
                   "od600_max_gr" = max_slope,
                   "time_of_od600_max_gr" = max_time,
                   "b_of_max_od600_gr_tangent_line" = max_b,
                   "od600_min_gr" = min_slope,
                   "time_of_od600_min_gr" = min_time,
                   "od600_lag_length" = Lag_length,
                   "max_od600"= max_OD600,
                   "difference_between_max_and_end_od600" = OD600_decrease,
                   "auc_od600"= auc,
                   rmse_od600))
    return(output)

}
