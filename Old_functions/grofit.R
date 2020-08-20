#' grofit
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#' Allows the user to get modeling data for just OD600
#' @param gropro_output : This is the output of gropro. This is a tidy data frame that has a column for Sample.ID and OD600.
#' OD600 must be the only measurement that occurs at each time. Other metadata can be included as necessary.
#'
#' @return :Modeling
#' @export
#'
#' @examples
#'
#' #This will return modeling information for each Sample.ID
#' grofit_output = grofit(gropro_output)
grofit = function(gropro_output){

    data = dplyr::select(gropro_output,Sample.ID,Time,OD600)
    metadata = dplyr::select(gropro_output,-Time,-OD600)%>%
        dplyr::distinct()

    #Looping through each sample ID to apply the model
    Samples = unique(metadata$Sample.ID)

    output = data.frame()
    for(i in Samples){
        #Removing rows with NA pH values so that a spline can be fit despite a few wonky timepoints that may be present in pH values
        input = dplyr::filter(data,Sample.ID == i)

        parameters = tryCatch(
            error = function(cnd) {
                # code to run when error is thrown
                col_1 = data.frame(matrix(i,ncol =1, nrow =1),stringsAsFactors = F)
                col_2 = data.frame(matrix(c(rep(NA_real_,10)),nrow = 1, ncol = 8))
                error_df = cbind(col_1,col_2)
                #Giving the columns the right names
                names(error_df) = c("Sample.ID","starting_od600","od600_max_gr","time_of_od600_max_gr","b_of_max_od600_gr_tangent_line","od600_min_gr",
                                    "time_of_od600_min_gr","od600_lag_length","max_od600","difference_between_max_and_end_od600","auc_od600")
                return(error_df)
            },
            # code to run while handler is active
            Combine_OD600_parameters(input = input)
        )

        #Selecting only the necessary parameters for further analysis
        physiological_parameters = dplyr::select(parameters,Sample.ID,starting_od600,od600_lag_length,od600_max_gr,max_od600,difference_between_max_and_end_od600,auc_od600)
        output = rbind(output,physiological_parameters) %>%
            dplyr::mutate(Sample.ID = as.character(Sample.ID))
    }
    final = dplyr::inner_join(metadata,output,by = "Sample.ID")
    return(final)
}




