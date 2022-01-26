#' gropro: Formatting raw OD600 data from the biotek reader into a tidy data frame.
#'
#' @return tidy data frame
#' @param biotek_export export from biotek plate reader
#' @param metadata metadata
#' @param Plate_Type type of plate 384 or 96
#' @export
#'
#' @examples
#' #Need to format OD600 data exported from biotek plate reader in an experiment with a 96 well plate
#'
#' \dontrun{gropro_output = gropro("path_to_biotek_OD600_export", "path_to_metadata.csv",Plate_Type = 96)}
#'

gropro = function(biotek_export,metadata,Plate_Type = 96){

    #Determining how to input the data based on plate type
    if(Plate_Type == 384){
        raw_data = read.delim(biotek_export,row.names = NULL,header = FALSE,col.names = 1:385,na.strings = c("?????",""),stringsAsFactors = FALSE)
    }else if(Plate_Type == 96){

        raw_data = read.delim(biotek_export,row.names = NULL,header = FALSE,col.names = 1:97,na.strings = c("?????",""),stringsAsFactors = FALSE)
    }else {
        print("Only 96 or 384 well plates are supported")
        stop(call. = TRUE)
    }
    #We need to define known places on the export file so we can scrape the necessary data
    Plate_ID_Index = which(stringr::str_detect(raw_data$X1,"Plate ID:"))
    OD600_Final_Index = which(stringr::str_detect(raw_data$X1,"OD600:600"))
    #Initializing the dataframe to store the tidy OD600 dataframe
    OD600_output = data.frame()
    #Now we need to loop through the export file and put the OD600 data in a tidy format
    for(i in Plate_ID_Index){
        #Scrapes the Sample ID Prefix to determine the sample ID of the well
        Sample_ID_Prefix = as.character(raw_data[i,2])

        #Need to determine the length of the OD600 data in the ezport files
        Length_index = (OD600_Final_Index[2]-5) - (OD600_Final_Index[1] + 1)

        #Defining the header of the
        Header = raw_data[i + 4,]
        Header = sapply(Header,as.character)
        OD600_data = raw_data[i + 5 : (5 + Length_index), ]
        colnames(OD600_data) = Header

        #Need to exclude the time measurements from the biotek export file that were not actually measyred
        not_na = !is.na(OD600_data$A1)
        necessary_rows = sum(not_na)
        OD600_data = OD600_data[1:necessary_rows,]

        #Putting the data in a tidy format
        tidy_OD600_data = tidyr::gather(OD600_data,Well,OD600,2:(Plate_Type + 1)) %>%
            dplyr::mutate(Sample.ID = paste0(Sample_ID_Prefix,Well)) %>%
            dplyr::select(Sample.ID,Well,Time,OD600)

        #outputing the tidy OD600 data
        OD600_output = rbind(OD600_output,tidy_OD600_data)
    }


    #Time information is being loaded in time format, need to convert that to hours for ease of use.
    Time = lubridate::hms(OD600_output$Time)
    Hours = lubridate::hour(Time) + (lubridate::minute(Time)/60)
    OD600_output$Time = Hours
    OD600_output$OD600 = as.numeric(OD600_output$OD600)


    #Combining with the metadata
    metadata = read.csv(metadata,stringsAsFactors = FALSE)
    metadata = as.data.frame(apply(metadata, 2, as.character),stringsAsFactors = FALSE)

    final_data = dplyr::inner_join(metadata,OD600_output,by = "Sample.ID")
    # returning the final data frame.
    return(final_data)


}
