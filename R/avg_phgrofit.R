#'avg_phgrofit
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#'This function is intended to make averaging the model parameters from phgrofit across groups very easy.
#'New Sample.IDs are assigned by concatanating the conditions that the user chooses to group by in order to make it easy to match the output avg_phgropro to avg_phgrofit.
#'
#' @param phgrofit_output The output of phgropro.
#' @param group_by A character vector of the names of the columns that you would like to group by
#'
#' @return a data frame with mean values for each of the modeling parameters across the groups that were specified.
#' @export
#' @examples
#' #This would return a data frame with the average and sd pH and OD600 values when grouped by Community and Compound- names of columns in the phgropro_out data frame.
#' p1 = avg_phgropro(phgropro_output,c("Community","Compound"))
avg_phgrofit = function(phgrofit_output,group_by = c("Sample.ID")){
    if("min_pH" %in% names(phgrofit_output)){
        features = dplyr::vars(starting_od600,
                               od600_lag_length,
                               od600_max_gr,
                               max_od600,
                               difference_between_max_and_end_od600,
                               auc_od600,
                               starting_pH,
                               max_acidification_rate,
                               min_pH,
                               time_of_min_pH,
                               max_basification_rate,
                               max_pH,
                               difference_between_end_and_min_pH,
                               auc_pH,
                               percent_NA_od600,
                               percent_NA_pH,
                               rmse_od600,
                               rmse_pH)
    }else{
        features = dplyr::vars(starting_od600,
                               od600_lag_length,
                               od600_max_gr,
                               max_od600,
                               difference_between_max_and_end_od600,
                               auc_od600,
                               percent_NA_od600,
                               rmse_od600)
}

    groups = dplyr::syms(group_by)

    output = phgrofit_output %>%
        dplyr::group_by(!!!groups) %>%
        dplyr::summarise_at(features,mean) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(Sample.ID = paste(!!!groups,sep =",")) %>%
        dplyr::select(Sample.ID,dplyr::everything()) %>%
        as.data.frame()

    return(output)
}
