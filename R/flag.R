#' flag
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#' This function was added in order to allow the user to easily flag wells that may have had problematic model fitting.
#' @param phgrofit_output: a data frane with modeling information from phgrofit
#' @return a data frame with a five columns corresponding to symptoms that may be indicative of poor model fit or weird growth curves
#' \itemize{
#'  \item{"negligable growth"}{ TRUE if max OD600 is less than 1.5x the starting od600}
#'  \item{"negative_lag_length"}{ TRUE if the od600_lag_length was calculated to be negative}
#'  \item{"starting_od600_higher_than_max"}{ TRUE if the starting od600 is higher than max od600}
#'  \item{"missing_od600_data"}{ TRUE if 25 percent of the od600 data for a well is missing}
#'  \item{"missing_pH_data"}{ TRUE if 25 percent of the pH data for a well is missing}
#' }

#' @export
#'
#' @examples
#' dataframe_exploring_potential_problems = flag(phgrofit_output)
#' # if there are no problems an empty data frame will be returned.
flag = function(phgrofit_output){
    if("min_pH" %in% names(phgrofit_output)){
        output = phgrofit_output %>%
            dplyr::mutate(negligable_growth = ifelse(max_od600 <= (1.5 * starting_od600),
                                              TRUE,
                                              FALSE),
                   negative_lag_length = ifelse(od600_lag_length < 0,
                                                TRUE,
                                                FALSE),
                   starting_od600_higher_than_max = ifelse(starting_od600 >= max_od600,
                                                           TRUE,
                                                           FALSE),
                   missing_pH_data = ifelse(percent_NA_pH >= 25,
                                            TRUE,
                                            FALSE),
                   missing_od600_data = ifelse(percent_NA_od600 >= 25,
                                               TRUE,
                                               FALSE)
                   )%>%
            dplyr::select(Sample.ID,
                          negligable_growth,
                          negative_lag_length,
                          missing_pH_data,
                          missing_od600_data,
                          starting_od600_higher_than_max) %>%
            dplyr::filter(negligable_growth == T |
                          starting_od600_higher_than_max == T |
                          missing_pH_data == T |
                          missing_od600_data == T |
                          negative_lag_length == T)
    }else{
        output = phgrofit_output %>%
            dplyr::mutate(negligable_growth = ifelse(max_od600 <= (1.5 * starting_od600),
                                                     TRUE,
                                                     FALSE),
                          negative_lag_length = ifelse(od600_lag_length < 0,
                                                       TRUE,
                                                       FALSE),
                          starting_od600_higher_than_max = ifelse(starting_od600 >= max_od600,
                                                                  TRUE,
                                                                  FALSE),
                          missing_od600_data = ifelse(percent_NA_od600 >= 25,
                                                      TRUE,
                                                      FALSE)
            )%>%
            dplyr::select(Sample.ID,
                          negligable_growth,
                          negative_lag_length,
                          starting_od600_higher_than_max,
                          missing_od600_data) %>%
            dplyr::filter(negligable_growth == T |
                          starting_od600_higher_than_max == T |
                          missing_od600_data == T |
                          negative_lag_length == T)
    }

        return(output)
}



