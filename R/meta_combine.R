#' meta_combine: Combinig modeling data,experimental metadata, and compound information
#'
#' The purpose of this function is to provide a convienent method of combining the model output of phgrobiome with metadata and compound information.
#' in doing this, we create an easily manipulatable data frame containing all relacent parameters.
#' This data frame can then be used with the phgrofit::cluster function or for any other type of analysis that the user wants.
#'
#' @param phgrobiome_output This is a data frame that is loaded into R that contains the Sample.IDs and all of the values resulting from the phgrobiome modeling.
#' This is the output of the phgrobiome function
#'
#' @param metadata  This is a data frame that has been loaded into R containing metadata from the experiment.
#' This datatable contains at least columns labeled Sample.ID, Community, Compound, Compound_Concentration, and Media.
#' @param compound_info This is a data table that has been loaded into R that contains information about compounds.
#' This data table contains at least a column labeled Compound, Composition, and AveDP.
#'
#' @return a dataframe containing modeling data, experimental metadata, and compound information.
#' @export
#'
#' @examples
#' d1 = metacombine(phgrobiome_output,metadata,compound_info)
#'
#' This data frame can then easily be filtered
#' d2 = filter(d1, Community == "ECO.38")
#'
#' This can then be used as the input of the phgrofit::cluster function.
#'
#' dendrogram = cluster(d2)
#'
#' print(dendrogram)
#'
meta_combine = function(phgrobiome_output,metadata,compound_info){

    metadata = metadata %>%
        select(Sample.ID,Community,Compound, Compound_Concentration,Media)

    compound_info = compound_info %>%
        dplyr::select(Compound,Composition)

    all_metadata = dplyr::left_join(metadata,compound_info, by = c("Compound"))


    output = left_join(all_metadata,phgrobiome_output,by = "Sample.ID")

    return(output)
}
