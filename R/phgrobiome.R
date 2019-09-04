#'  Extract physiological parameters from kinetic pH and OD600 data using multiple strains and complex carbon sources
#'
#' phgrofit takes pH and OD600 data that has been formated by phgropro and applies a spline interpolation to extract relevant physiological data.
#' @param data This is the input data that has been loaded into r that you would like to model. It is a tidy dataframe containing a column for Sample.ID, OD600,pH, and time. This will most often be the output off phgropro.
#' @param metadata This is the metadata that has been previously loaded into r
#'
#' @return A tidy data frame of 8 values extracted from the spline interpolation.If graphs > 0 then x number of randomly sampled graphs are generated displaying the model fit and relevant parameters.
#' \itemize{
#'  \item{"u1"}{ max growth rate during LEX1.}
#'  \item{"u2"}{ max growth rate during LEX2}
#'  \item{"RAc"}{ max rate of acidification during LEX1}
#'  \item{"RBa"}{ max rate of basification during LEX2}
#'  \item{"LLP_length"}{ length of lag phase}
#'  \item{"LEX1_length"}{ length of first growth phase}
#'  \item{"LTP_length "}{ length of transition phase}
#'  \item{"LEX2_length"}{ length of 2nd growth phase occuring durring the basification.}
#' }
#'  \if{html}{\figure{phgrofit_example.png}}{Test}
#' @export
#'
#' @examples
phgrobiome <- function(data,metadata,unique_graphs = FALSE) {
    #Initializing the final data frame
    output = data.frame()

    #Binding the data and metadata
    metadata$Sample.ID = as.character(metadata$Sample.ID)

    data = inner_join(data,metadata, by = "Sample.ID") %>%
        mutate(Concat = paste0(Community,".",Compound,".",Compound_Concentration,".",Media))

    #Looking at each distinct combination of Community, Compound, Compound Concentration, and Media present in the data set so that each can be plotted.
    distinct_metadata = distinct(data,Concat) %>%
        pull(Concat)

    #Looping through to determine what wells are distinct, randomly picking one to plot.

    randomized_unique = vector()
    for(i in distinct_metadata){
        t0 = filter(data, Time == 0)
        all_values = which(t0$Concat == i)
        temp_randomized_unique = sample(all_values,1)
        randomized_unique = cbind(randomized_unique,temp_randomized_unique)
    }

    #Pulling distinct Sample IDs so that this the fit is applied for every well
    Samples = dplyr::distinct(data,Sample.ID) %>%
        dplyr::pull(Sample.ID)

    #Initializing a count so we can keep track of which iteration we are on
    count = 0

    #Looping through each sample ID to apply the model and graph if unique combination of parameters
    for(i in Samples){

        count = count + 1

        input = dplyr::filter(data,Sample.ID == i)

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
