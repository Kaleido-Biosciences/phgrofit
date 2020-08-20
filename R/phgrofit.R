#' phgrofit: Extract physiological parameters from kinetic pH and OD600 data across diverse samples.
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#' phgrofit takes pH and OD600 data that has been formated by phgropro and applies a smoothing spline to extract relevant physiological data.
#' Importantly, this function drops any NA values that may exist when fitting the spline.
#' These values occasionally occur when measuring pH, either from an erratic read or if the pH is outside of the standard curve.
#' The columns percent_NA_od600 and percent_NA_pH contain the percent of timepoints that were NA for a given well.
#' @param phgropro_output This is the output of phgropro which is a tidy dataframe containing columns exactly named Sample.ID, Time, OD600, and pH at minimum. There may also be any other columns representing any other metadata.
#' @return A tidy data frame of several features that were extracted from a smoothing spline fit. The data frame also contains information that can be used to assess model fit.
#' Physiologial features:
#' \itemize{
#'  \item{"starting_od600"}{This is the starting od600}
#'  \item{"od600_lag_length"}{This is the length of the calculated lag phase.
#'  Calculated by determining the time where the tangent line at the point of the max growth rate meets the starting od600 }
#'  \item{"od600_max_gr"}{ This is the maximum growth rate that is observed. Calculated by determining the max derivitive of the spline fit for OD600}
#'  \item{"max_od600"}{ This is the maximum od600 observed by the spline fit}
#'  \item{"difference_between_max_and_end_od600"}{ This is the difference between the maximum and end od600. Higher values should correspond to a "death phase". Or one could argue the cells are getting smaller.}
#'  \item{"auc_od600"}{This is the area under the curve of the OD600 curves. It is calculated using the trapezoidal rule on fitted values from smooth.spline.}
#'  \item{"starting_pH"}{This is the starting pH}
#'  \item{"max acidification rate"}{ This is the max acidification rate observed in the spline fit. Calculated by determining the min derivitive of the spline fit for pH.}
#'  \item{"min pH"}{ This is the minimum pH that is observed in the spline fit.}
#'  \item{"time_of_min_pH "}{ This is the time that the minimum pH occurs in the spline fit.}
#'  \item{"max_basification_rate"}{ This is the max basification rate observed in the spline fit. Calculated by determining the max derivitive of the spline fit for pH.}
#'  \item{"max_pH"}{ This is the max pH observed in the spline fit.}
#'  \item{"difference_between_end_and_min_pH"}{ This is the difference between the end and the minimum pH. A higher value corresponds to a greater pH increase. Higher values may reflect an increased proteolytic state}
#'  \item{"auc_pH"}{This is the area under the curve of the pH curves. It is calculated using the trapezoidal rule on fitted values from smooth.spline.}
#'  }
#'  Model fit:
#'  \itemize{
#'  \item{"percent_NA_od600"}{The percent of wells that were NA when fitting the spline to the kinetic od600 data}
#'  \item{"percent_NA_pH"}{The percent of wells that were NA when fitting the spline to the kinetic pH data}
#'  \item{"rmse_od600"}{The Root-mean-square deviation for od600}
#'  \item{"rmse_pH"}{The Root-mean-square deviation for pH}
#'  }

#' @export
#' @importFrom magrittr %>%
#' @examples
#' ### phgropro processing
#' phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' ### phgrofit processing
#' phgrofit_output = phgrofit(phgropro_output)
phgrofit = function(phgropro_output){

    data = dplyr::select(phgropro_output,Sample.ID,Time,OD600,pH)
    metadata = dplyr::select(phgropro_output,-Time,-OD600,-pH)   %>%
        dplyr::distinct()

output = data.frame()

    for(i in unique(data$Sample.ID)){
        input = data %>%
            dplyr::filter(Sample.ID == i)
        percent_NA_pH = sum(is.na(input$pH))/length(input$pH) * 100
        percent_NA_od600 = sum(is.na(input$OD600))/length(input$OD600) * 100

        #Filtering out all of the pH values that returned NA
        input_pH = input %>%
            dplyr::filter(!is.na(pH))

        #Selecting only the necessary parameters for further analysis
        pH_features = pH_features(input_pH) %>%
            dplyr::mutate(Sample.ID = as.character(i),
                          percent_NA_pH = percent_NA_pH)

        #Filtering out all of the OD600 values that returned NA
        input_od600 = input %>%
            dplyr::filter(!is.na(OD600))

        #Selecting only the necessary parameters for further analysis
        od600_features = od600_features(input_od600) %>%
            dplyr::mutate(Sample.ID = as.character(i),
                          percent_NA_od600 = percent_NA_od600)
        loop = dplyr::inner_join(pH_features,od600_features,by = "Sample.ID")
        output = rbind(output,loop)
    }

    output = output %>%
        dplyr::select(Sample.ID,
                      starting_od600,
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

    final = dplyr::inner_join(metadata,output,by = "Sample.ID")
    return(final)
}
