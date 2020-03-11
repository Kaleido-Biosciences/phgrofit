#' NA_ph_swap
#'
#' @param phgropro_output
#' Sometimes when pH data is captureed using the high throughput mode of the plate reader, a NA value may be present at a given timepoint.
#' This is problematic because the intent of the phgrofit is to do modeling based on a spline fit, and if there is a NA, a spline cannot be fit.
#' This function replaces any NAs that may be present in the pH output of phgropro with the previous pH value. Once these values are replaced, the user can then
#' do the spline based modeling using the phgrobiome function.
#'
#' This should minimally affect the modeling for situations where only a few NAs are in a row, however keep in mind that if there are several NAs in a row
#' this will alter the results of the modeling.
#' @return a data frame with any pH values that are NAs swapped for the pH value at the previous timepoint.
#' For timepoints with multiple NAs in a row, they will all have the same pH as the first pH in the string of NAs.
#' @export
#'
#' @examples
#' data_containing_no_pH_NAs =
NA_ph_swap = function(phgropro_output){

    for(i in 1:length(phgropro_output$pH)){
        if(is.na(phgropro_output$pH[i]) == TRUE){
            if(i == 1){
                phgropro_output$pH[i] = phgropro_output$pH[i + 1]
            }
            else{
                phgropro_output$pH[i] = phgropro_output$pH[i-1]
            }
        }
    }
    return(phgropro_output)
}
