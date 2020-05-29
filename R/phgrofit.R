#' phgrofit: Extract physiological parameters from kinetic pH and OD600 data across diverse samples.
#'
#' phgrofit takes pH and OD600 data that has been formated by phgropro and applies a spline interpolation to extract relevant physiological data.
#' This is different from the phgrofit modeling because the modeling parameters used are more robust to deviations from an idealized growth and ph profile.
#' @param phgropro_output This is the output of phgropro which is a tidy dataframe containing columns for the Sample.ID, any metadata passed to phgropro, and the
#' @return A tidy data frame of 10 values extracted from the spline interpolation.
#' \itemize{
#'  \item{"od600_lag_length"}{This is the length of the calculated lag phase.
#'  Calculated by determining the time where the tangent line at the point of the max growth rate meets the starting od600 }
#'  \item{"od600_max_gr"}{ This is the maximum growth rate that is observed. Calculated by determining the max derivitive of the spline fit for OD600}
#'  \item{"max_od600"}{ This is the maximum od600 observed by the spline fit}
#'  \item{"difference_between_max_and_end_od600"}{ This is the difference between the maximum and end od600. Higher values should correspond to a "death phase". Or one could argue the cells are getting smaller.}
#'  \item{"max acidification rate"}{ This is the max acidification rate observed in the spline fit. Calculated by determining the min derivitive of the spline fit for pH.}
#'  \item{"min pH"}{ This is the minimum pH that is observed in the spline fit.}
#'  \item{"time_of_min_pH "}{ This is the time that the minimum pH occurs in the spline fit.}
#'  \item{"max_basification_rate"}{ This is the max basification rate observed in the spline fit. Calculated by determining the max derivitive of the spline fit for pH.}
#'  \item{"max_pH"}{ This is the max pH observed in the spline fit.}
#'  \item{"difference_between_end_and_min_pH"}{ This is the difference between the end and the minimum pH. A higher value corresponds to a greater pH increase. Higher values may reflect an increased proteolytic state}
#'  }
#' @export
#' @importFrom magrittr %>%
#' @examples
#' ### phgropro processing
#' phgropro_output = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' ### phgrofit processing
#' phgrofit_output = phgrofit(phgropro_output)
phgrofit = function(phgropro_output) {
    #Spliting the phgropro input into data and metadata
    data = dplyr::select(phgropro_output,Sample.ID,Time,OD600,pH)
    metadata = dplyr::select(phgropro_output,-Time,-OD600,-pH)   %>%
        dplyr::distinct()

    #Removing samples that have 25% or more NA pH values
    NA_Samples = dplyr::group_by(data,Sample.ID) %>%
        dplyr::summarise(n_na = sum(is.na(pH))) %>%
        dplyr::filter(n_na > (0.5 * length(data$pH)/length(unique(data$Sample.ID)))) %>%
        dplyr::pull(Sample.ID)

    `%!in%` = Negate(`%in%`)

    #Pulling distinct Sample IDs that do not have too many NAs so that this the fit is applied for every well
    Samples = dplyr::distinct(data,Sample.ID) %>%
        dplyr::filter(Sample.ID %!in% NA_Samples) %>%
        dplyr::pull(Sample.ID)

    #Initializing the final data frame
    output = data.frame()

    #Looping through each sample ID to apply the model and graph if unique combination of parameters
    for(i in Samples){
        #Removing rows with NA pH values so that a spline can be fit despite a few wonky timepoints that may be present in pH values
        input = dplyr::filter(data,Sample.ID == i) %>%
            dplyr::filter(!is.na(pH))
        parameters = Combine_parameters(input = input)
        #Selecting only the necessary parameters for further analysis
        physiological_parameters = dplyr::select(parameters,Sample.ID,starting_od600,od600_lag_length,od600_max_gr,max_od600,difference_between_max_and_end_od600,auc_od600,starting_pH,
                                                 max_acidification_rate,min_pH,time_of_min_pH,max_basification_rate,max_pH,difference_between_end_and_min_pH,auc_pH)
        output = rbind(output,physiological_parameters) %>%
            dplyr::mutate(Sample.ID = as.character(Sample.ID))
    }
    final = dplyr::inner_join(metadata,output,by = "Sample.ID")
    return(final)
}
