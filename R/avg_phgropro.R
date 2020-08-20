#'avg_phgropro
#' Copyright (c) 2019. Kaleido Biosciences. All Rights Reserved
#'
#'This function is intended to make averaging OD600 and pH values from phgropro across groups very easy.
#'This functiuon also returns the standard deviation for OD600 and pH.
#'New Sample.IDs are assigned by concatanating the conditions that the user chooses to group by in order to make it easy to match the output avg_phgropro to avg_phgrofit.
#'
#' @param phgropro_output The output of phgropro.
#' @param group_by: Character vector of the names of the columns that you would like to group by.
#'
#' @return a data frame with mean_OD600, sd_OD600, mean_pH, sd_pH across the groups specified
#' @export
#'
#' @examples
#' #This would return a data frame with the average and sd pH and OD600 values when grouped by Community and Compound.
#' p1 = avg_phgropro(phgropro_output,c("Community","Compound"))
avg_phgropro = function(phgropro_output,group_by = "Sample.ID"){
    if("pH" %in% names(phgropro_output)){
        readouts = dplyr::vars(OD600,pH)
        groups = dplyr::syms(group_by)

        output = phgropro_output %>%
            dplyr::group_by(!!!groups,Time) %>%
            dplyr::summarise(mean_OD600 = mean(OD600),sd_OD600 = sd(OD600),
                             mean_pH = mean(pH), sd_pH = sd(pH)) %>%
            dplyr::ungroup() %>%
            dplyr::mutate(Sample.ID = paste(!!!groups,sep =",")) %>%
            dplyr::select(Sample.ID,dplyr::everything()) %>%
            as.data.frame()

        return(output)
    }else{
        readouts = dplyr::vars(OD600)
        groups = dplyr::syms(group_by)

        output = phgropro_output %>%
            dplyr::group_by(!!!groups,Time) %>%
            dplyr::summarise(mean_OD600 = mean(OD600),sd_OD600 = sd(OD600)) %>%
            dplyr::ungroup() %>%
            dplyr::mutate(Sample.ID = paste(!!!groups,sep =",")) %>%
            dplyr::select(Sample.ID,dplyr::everything()) %>%
            as.data.frame()
    }
}

