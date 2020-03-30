phgroexplore <- function(data,metadata) {
    #Initializing the final data frame
    output = data.frame()


    #Binding the data and metadata
    data = inner_join(data,metadata, by = "Sample.ID") %>%
        mutate(Concat = paste0(Community,".",Compound,".",Compound_Concentration,".",Media))

    #Looking at each distinct combination of Community, Compound, Compound Concentration, and Media present in the data set so that each can be plotted.
    distinct_metadata = distinct(data,Concat) %>%
        pull(Concat)

    #Looping through to determine what wells are distinct, randomly picking one to plot.
    #Setting seed in order to get reproducible results.
    set.seed(2)

    randomized_unique = vector()
    for(i in distinct_metadata){
        t0 = filter(data,Time == 0)
        all_values = which(t0$Concat == i)
        temp_randomized_unique = sample(all_values,1)
        randomized_unique = c(randomized_unique,temp_randomized_unique)
    }


    #Pulling distinct Sample IDs so that this the fit is applied for every well
    Samples = dplyr::distinct(data,Sample.ID) %>%
        dplyr::pull(Sample.ID)

    count = as.vector(0)
    #Looping through each sample ID
    for(i in Samples){

        ###Keeping track of the iteration we are on##
        count = count + 1
        input = dplyr::filter(data,Sample.ID == i)

        if (count %in% randomized_unique){

            p1 = ggplot2::ggplot(input, aes(x= Time, y = OD600))+
                ggplot2::geom_point(size = 0.5)+
                ggplot2::geom_line()+
                ggplot2::ylab("OD600")+
                ggplot2::ggtitle("OD600")


            #Creating the pH plot
            p2 = ggplot2::ggplot(input, aes(x= Time, y = pH))+
                ggplot2::geom_point(size = 0.5)+
                ggplot2::geom_line()+
                ggplot2::ggtitle("pH")

            #Arranging the plots into the same graph
            p3 = ggpubr::ggarrange(p1,p2)
            p4 = ggpubr::annotate_figure(p3, input$Concat)
            print(p4)
        }
    }
}
