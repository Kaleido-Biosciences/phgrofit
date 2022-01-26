#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#' @param data data
pH_features = function(data){

    # Fitting the spline
    model = smooth.spline(y = data[,"pH"], x=data[,"Time"],spar = 0.70)
    pred = as.data.frame(predict(model,x=data[,"Time"]))

    # RMSE
    rmse_pH = ModelMetrics::rmse(data$pH,pred$y)

    deriv = as.data.frame(predict(model,x=data[,"Time"],deriv = 1))

    #Defining the max slope and where it occurs
    max_index = which(deriv$y == max(deriv$y))
    max_time = deriv[max_index,1]
    max_slope = deriv[max_index,2]

    #Defining the min slope and where it occurs
    min_index = which(deriv$y == min(deriv$y))
    min_time = deriv[min_index,1]
    min_slope =deriv[min_index,2]

    #Defining the coefficients necessary to determine the tangent line through max acidification
    min_y = pred[which(pred$x == min_time),"y"]
    min_x = min_time
    min_b = min_y - (min_slope * min_x)

    #Defining the coefficients necessary to determine the tangent line through max basification
    max_y = pred[which(pred$x == max_time),"y"]
    max_x = max_time
    max_b = max_y - (max_slope * max_x)

    #Starting min and end pH
    starting_pH = pred$y[which(min(pred$x) == pred$x)]
    min_pH = min(pred$y)
    end_min_diff = pred[which(max(pred$x) == pred$x),2] - min_pH
    min_pH_time = pred[which(min_pH == pred$y),1]
    max_pH = max(pred$y)

    #AUC
    auc = MESS::auc(pred$x,pred$y,type = "linear")

    output = as.data.frame(cbind("max_acidification_rate" = min_slope,
                   "time_of_max_ar" = min_time,
                   "b_of_max_ar_tangent_line" = min_b,
                   "max_basification_rate" = max_slope,
                   "time_of_max_br" = max_time,
                   "b_of_max_br_tangent_line" = max_b,
                   starting_pH,
                   min_pH,
                   "time_of_min_pH" = min_pH_time,
                   max_pH,
                   "difference_between_end_and_min_pH" = end_min_diff,
                   "auc_pH"= auc,
                   rmse_pH))

    return(output)
}
