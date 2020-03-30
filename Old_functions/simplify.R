#' simplify:Simplifying the model fit by taking the averages across distinct groups.
#'
#' @param annotated_data This is the annotated data (output of meta_combine) that the user wants to average replicates across.
#' @param groups This is a vector input containing the names of the columns that the data will be grouped by
#'
#' @return A data frame containing the averaged summerized model fits across the groups provided by the user.
#' @export
#'@importFrom magrittr %>%
#'
#' @examples
#' This code assigns the averaged model fit across Communities, Manual Curations, and Compositions to the object "summarized data".
#' sumarized_data = simplify(annotated_data,groups = c("Community","Manual Curation","Composition"))
#'
#'
simplify = function(annotated_data,groups = c("Community","Composition")){

    sum = group_by_at(annotated_data,vars(groups)) %>%
        summarise_all(mean)

    Sample.ID = row.names(sum)

    #Setting the Sample.ID to be equal to the row names to ensure compatability with the heatmapper function
    sum$Sample.ID = Sample.ID

    sum = select(sum,Sample.ID,everything())

    sum = as.data.frame(ungroup(sum))

    return(sum)
}
