#' model_fit_check
#'
#'This function prints graphs visually displaying the model fits from a randomly sampled set of variables of the users choosing.
#'A replicate from each unique condition specified is randomly sampled and the fit and extracted parameters that are easy to visualize are shown.
#' @param phgropro_output This is the output from phgropro. It contains tidy pH and OD600 data.
#' @param grouping_vars This contains the variables you would like to see the fit for a randomly sampled replicate of.
#'
#' @return prints a randomly sampled plot from each condition to the console as specified by grouping_vars.
#' @export
#' @examples
#'phgropro_output = phgrofit::phgropro_output("Filepath of biotek export.txt","filepath of metadata.csv,Plate_Type = 384)
#'model_fit_check(phgropro_output,grouping_vars = c("Community","Compound))
#'###This would print graphs from a randomly sampled replicate of each combination of variables specified by grouping_vars.
model_fit_check = function(phgropro_output,grouping_vars = "Sample.ID"){

    #extracting the grouping vars in order to work with dplyr framework
    cols_quo = dplyr::syms(grouping_vars)
    kin_and_mod = dplyr::mutate(phgropro_output,Concat = paste(!!!cols_quo,sep =","))

    #Looking at each distinct combination of Community, Compound, Compound Concentration, and Media present in the data set so that each can be plotted.
    distinct_metadata = dplyr::distinct(kin_and_mod,Concat) %>%
        dplyr::pull(Concat)

    randomized_unique = vector()
    for(i in distinct_metadata){
        distinct = dplyr::filter(kin_and_mod,Concat == i) %>%
            dplyr::distinct(Sample.ID) %>%
            dplyr::pull()
        temp_randomized_unique = sample(distinct,1)
        randomized_unique = c(randomized_unique,temp_randomized_unique)
    }

    #fixing the NA problem
    #Removing samples that have 25% or more NA pH values
    NA_Samples = dplyr::group_by(kin_and_mod,Sample.ID) %>%
        dplyr::summarise(n_na = sum(is.na(pH))) %>%
        dplyr::filter(n_na > (0.5 * length(kin_and_mod$pH)/length(unique(kin_and_mod$Sample.ID)))) %>%
        dplyr::pull(Sample.ID)

    `%!in%` = Negate(`%in%`)


    randomized_unique_NA_rm = randomized_unique[randomized_unique %!in% NA_Samples]

    #Filtering and looping
    for(i in randomized_unique_NA_rm){

        #getting rid of NAs so we do not have a problem with fitting splines
        input = dplyr::filter(kin_and_mod,Sample.ID == i) %>%
            dplyr::filter(!is.na(pH))

        #excluding graphs with all NA
        if(length(!is.na(input$pH)) > 0 ){

            p1 = graph_check(input)
            p2 = ggpubr::annotate_figure(p1,paste0(input$Concat))
            print(p2)
        }
    }

}
