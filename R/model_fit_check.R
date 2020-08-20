#' model_fit_check
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
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
#'#This would print graphs from a randomly sampled replicate of each combination of variables specified by grouping_vars
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


    #Filtering and looping
    for(i in randomized_unique){
        #if pH and od600
        if("pH" %in% names(kin_and_mod)){
            #getting rid of NAs just like we do in the actual modeling
            input = dplyr::filter(kin_and_mod,Sample.ID == i)
            p1 = graph_check(input)
            p2 = ggpubr::annotate_figure(p1,paste0(input$Concat))
            print(p2)
        }else{
            #else growth only
            #getting rid of NAs just like we do in the actual modeling
            input = dplyr::filter(kin_and_mod,Sample.ID == i) %>%
                dplyr::filter(!is.na(OD600))
            p1 = graph_check(input)
            p2 = ggpubr::annotate_figure(p1,paste0(input$Concat))
            print(p2)
        }
    }
}



