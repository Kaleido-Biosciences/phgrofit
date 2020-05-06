#' scale_phgrofit
#' This function allows the user to scale the results of phgrofit. This should be used upstream of functions requiring a standardization of data.
#' Scaling is done outside of the plotting functions in order to allow more transparancy as to what is acutally being plotted than would be apparent otherwise.
#' Additionally, this will allow the user to choose the appropriate scaling function for their application.
#'
#' @param phgrofit_output: This is the output from the phgrofit
#' @param phgrofit_output: This is a character vector of the groups that you would like to scale within
#' @return a dataframe containing all of content of phgrofit with each model parameter scaled such that the mean = 0 and values represent Z scores.
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' phgropro_output = phgrofit::phgropro("rawdata.txt","metadata.csv",384)
#' phgrofit_output = phgrofit::phgrofit(phgropro_output)
#'
#' #To get the scaled data
#' scaled_phgrofit = phgrofit::scale_phgrofit(phgrofit_output)
#'
#' #To get data that has been independantly scaled per community
#' scaled_phgrofit = phgrofit::scale_phgrofit(phgrofit_output,group_by = "Community")
#'
#'
scale_phgrofit = function(phgrofit_output,group_by = NULL){

    model_parmeters = dplyr::vars(od600_lag_length,
                                  od600_max_gr,
                                  max_od600,
                                  difference_between_max_and_end_od600,
                                  max_acidification_rate,
                                  min_pH,
                                  time_of_min_pH,
                                  max_basification_rate,
                                  max_pH,
                                  difference_between_end_and_min_pH)
    if(is.null(group_by)){
        scaled_data = phgrofit_output %>%
            dplyr::mutate_at(model_parmeters, scale)

        return(scaled_data)
    } else{
        groups = dplyr::syms(group_by)
        scaled_data = phgrofit_output %>%
            dplyr::group_by(!!!groups) %>%
            dplyr::mutate_at(model_parmeters, scale) %>%
            dplyr::ungroup() %>%
            as.data.frame()

        return(scaled_data)
    }

}
