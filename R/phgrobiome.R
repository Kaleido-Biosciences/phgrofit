#' phgrobiome: Extract physiological parameters from kinetic pH and OD600 data across diverse samples.
#'
#' phgrobiome takes pH and OD600 data that has been formated by phgropro and applies a spline interpolation to extract relevant physiological data.
#' This is different from the phgrofit modeling because the modeling parameters used are more robust to deviations from an idealized growth and ph profile.
#' @param data This is the input data that has been loaded into r that you would like to model. It is a tidy dataframe containing a column for Sample.ID, OD600,pH, and time. This will most often be the output off phgropro.
#' @param metadata This is the metadata that has been previously loaded into r. Must contain columns labeled "Community", "Compound","Compound_Concentration","Media" at the minimum.
#' These are the only parameters that will be used to determine if a condition is unique or not.
#' @param unique_graphs This is a TRUE or false input. If true, a plot from all distinct conditions will be printed in order to allow for spot checking model fit.
#' If FALSE, no graphs will be plotted. Either way, a data frame containing all of the model fitted parameters will be returned.
#' @return A tidy data frame of 10 values extracted from the spline interpolation.If unique_graphs = TRUE then a randomly sampled graph of a distinct condition will be printed to the console.
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
#' }
#' @export
#' @importFrom magrittr %>%
#' @examples
#' data = read.csv("Filepath")
#'
#' metadata = read.csv("Filepath")
#'
#' physiological_parameters = phgrobiome(data,metadata,unique_graphs = TRUE)
#' This will return a data frame of physiological parameters and print a randomly sampled replicate of each unique condition to the console.
phgrobiome <- function(data,metadata,unique_graphs = FALSE) {
    #Initializing the final data frame
    output = data.frame()

    #Binding the data and metadata
    metadata$Sample.ID = as.character(metadata$Sample.ID)

    data = dplyr::inner_join(data,metadata, by = "Sample.ID") %>%
        dplyr::mutate(Concat = paste0(Community,".",Compound,".",Compound_Concentration,".",Media))

    #Looking at each distinct combination of Community, Compound, Compound Concentration, and Media present in the data set so that each can be plotted.
    distinct_metadata = dplyr::distinct(data,Concat) %>%
        dplyr::pull(Concat)

    #Looping through to determine what wells are distinct, randomly picking one to plot.

    randomized_unique = vector()
    for(i in distinct_metadata){
        t0 = dplyr::filter(data, Time == 0)
        all_values = which(t0$Concat == i)
        temp_randomized_unique = sample(all_values,1)
        randomized_unique = cbind(randomized_unique,temp_randomized_unique)
    }

    #Removing samples that have 25% or more NA pH values
    NA_Samples = dplyr::group_by(data,Sample.ID) %>%
        dplyr::summarise(n_na = sum(is.na(pH))) %>%
        dplyr::filter(n_na > (0.25 * length(data$pH)/length(unique(data$Sample.ID)))) %>%
        dplyr::pull(Sample.ID)

    `%!in%` = Negate(`%in%`)

    #Pulling distinct Sample IDs that don't have too many NAs so that this the fit is applied for every well
    Samples = dplyr::distinct(data,Sample.ID) %>%
        dplyr::filter(data,Sample.ID %!in% NA_Samples) %>%
        dplyr::pull(Sample.ID)

    #Initializing a count so we can keep track of which iteration we are on
    count = 0

    #Looping through each sample ID to apply the model and graph if unique combination of parameters
    for(i in Samples){

        count = count + 1

    #Removing rows with NA pH values so that a spline can be fit despite a few wonky timepoints that may be present in pH values
        input = dplyr::filter(data,Sample.ID == i) %>%
            dplyr::filter(!is.na(pH))

        parameters = Combine_parameters(input = input)

        #Selecting only the necessary parameters for further analysis


        physiological_parameters = dplyr::select(parameters,Sample.ID,od600_lag_length,od600_max_gr,max_od600,difference_between_max_and_end_od600,
                                                 max_acidification_rate,min_pH,time_of_min_pH,max_basification_rate,max_pH,difference_between_end_and_min_pH)

        output = rbind(output,physiological_parameters)

        if(count %in% randomized_unique & unique_graphs == TRUE){

            p1 = graph_check(input,parameters)
            p2 = ggpubr::annotate_figure(p1,paste0(input$Concat))
            print(p2)
        }
    }
    return(output)
}
