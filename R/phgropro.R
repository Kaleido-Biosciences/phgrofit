#' phgropro: Tidying kinetic od600 and pH data from biotek plate reader.
#'
#'phgropro- pH growh processing- takes the export from a standardized biotek plate reader and converts it into a tidy format that is convenient for data analysis. This tidy format will oftern serve as the input to phgrofit.
#' @param biotek_export .txt file that results from a specific format of exporting data from the Biotek Gen5 software.
#' @param metadata .csv file that contains information about the contents of the samples. Must contain a column called Sample.ID.
#' @param Plate_Type 96 or 384 specifying which plate type was ran on the plate reader.
#'
#' @return tidy data frame with a column for Sample ID, any metadata columns present,Time, OD600, and pH.
#'
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' ### When we want to extract the data from from a 96 well plate run on the plate reader.
#' output_96 = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 96)
#'
#' ### When we want to extract the data from from a 384 well plate run on the plate reader.
#' output_384 = phgropro(biotek_export = filepath.txt,metadata = metadata.csv,Plate_Type = 384)
phgropro = function(biotek_export,metadata,Plate_Type = 96){

    #Determining how to input the data based on plate type
    if(Plate_Type == 384){
        raw_data = read.delim(biotek_export,row.names = NULL,header = FALSE,col.names = 1:385,na.strings = c("?????",""),stringsAsFactors = FALSE)
    }
    else if(Plate_Type == 96){
        raw_data = read.delim(biotek_export,row.names = NULL,header = FALSE,col.names = 1:97,na.strings = c("?????",""),stringsAsFactors = FALSE)
    }
    else{
        print("Only 96 or 384 well plates are supported")
        stop(call. = TRUE)
    }
        #We need to define known places on the export file so we can scrape the necessary data
        Plate_ID_Index = which(stringr::str_detect(raw_data$X1,"Plate ID:"))
        pH_Final_Index = which(stringr::str_detect(raw_data$X1,"pH_Final"))
        #Initalizing the dataframe to store the tidy OD600 dataframe
        OD600_output = data.frame()
        #Now we need to loop through the export file and put the OD600 data in a tidy format
                for(i in Plate_ID_Index) {
                    #Scrapes the Sample ID Prefix to determine the sample ID of the well
                    Sample_ID_Prefix = as.character(raw_data[i,2])

                    #Need to determine the length of the OD600 data in the ezport files
                    Length_index = pH_Final_Index[1] - Plate_ID_Index[1] -6

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
###Now we need to do the same thing for the pH data that we just did for the OD600 data. ###

#Initalizing the dataframe to store the tidy pH dataframe
    pH_output = data.frame()
                for(i in pH_Final_Index){

                    #Grabing the sample ID
                    iteration = which(pH_Final_Index == i)
                    Plate_ID_location = Plate_ID_Index[iteration]
                    Sample_ID_Prefix = as.character(raw_data[Plate_ID_location,2])

                    #Defining the length to grab, there are two rows between the "pH Final" and the data of interest
                    length = necessary_rows + 1
                    pH_data = raw_data[(i + 2) : (i + length),]

                    #Defining the header columns
                    Header = raw_data[i+1,]
                    Header = sapply(Header,as.character)
                    colnames(pH_data) = Header

                    #Converting the data to a tidy format
                    tidy_pH_data = tidyr::gather(pH_data,Well,pH,2:(Plate_Type+1)) %>%
                        dplyr::mutate(Sample.ID = paste0(Sample_ID_Prefix,Well)) %>%
                        dplyr::select(Sample.ID,Well,Time,pH)

                    #outputing the tidy pH data
                    pH_output = rbind(pH_output,tidy_pH_data)
}
    #Need to change the timepoints so that pH and OD600 match. The plate reader exports them in a format that is too granular.
    #It will be much more convienent to make the timepoints for pH and OD600 match.
    #To do this, lets simpily take the OD600 times and give them to the pH Times
    Standardized_Time = OD600_output$Time
    pH_output$Time = Standardized_Time

    #Combining the pH and OD600 data
    combined_data = dplyr::inner_join(OD600_output,pH_output, by = c("Sample.ID","Time")) %>%
    dplyr::select(-c(2,5))


    #Time information is being loaded in time format, need to convert that to hours for ease of use.
    Time = lubridate::hms(combined_data$Time)
    Hours = lubridate::hour(Time) + (lubridate::minute(Time)/60)
    combined_data$Time = Hours
    combined_data$OD600 = as.numeric(combined_data$OD600)
    combined_data$pH = as.numeric(combined_data$pH)

    #Combining with the metadata
    metadata = read.csv(metadata,stringsAsFactors = FALSE)
    metadata = as.data.frame(apply(metadata, 2, as.character),stringsAsFactors = FALSE)

    final_data = dplyr::inner_join(metadata,combined_data,by = "Sample.ID")
    # returning the final data frame.
    return(final_data)
}

