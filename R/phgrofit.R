#' Extract physiological parameters from kinetic pH and OD600 data
#'
#'phgrofit takes pH and OD600 data that has been formated by phgropro and applies a spline interpolation to extract relevant physiological data.
#' @param data This is the input data that you would like to model. It is a tidy dataframe containing a column for Sample.ID, OD600,pH, and time. This will most often be the output off phgropro.
#' @param graphs This is the number specifying how many graphs you would like to print to console. This is useful for visually inspecting the modeling.
#'
#' @return Tidy data frame of 8 values extracted from the spline interpolation.
#' \itemize{
#'  \item{"u1"}{ max growth rate during LEX1.}
#'  \item{"u2"}{ max growth rate during LEX2}
#'  \item{"RAc"}{ max rate of acidification during LEX1}
#'  \item{"RBa"}{ max rate of basification during LEX2}
#'  \item{"LLP_length"}{ length of lag phase}
#'  \item{"LEX1_length"}{ length of first growth phase}
#'  \item{"LTP_length "}{ length of transition phase}
#'  \item{"LEX2_length"}{ length of 2nd growth phase occuring durring the basification.}
#' }
#'  \if{html}{\figure{phgrofit_example.png}}{Test}
#'
#' @export
#'
#' @examples
#' ### When we want 10 random graphs to be generated from a tidy data frame named data.
#' phgrofit(data, graphs = 10)
#' @importFrom magrittr %>%
phgrofit <- function(data,graphs = 1) {
#Initializing the final data frame
output = data.frame()

#Pulling distinct Sample IDs so that this the fit is applied for every well
Samples = dplyr::distinct(data,Sample.ID) %>%
          dplyr::pull(Sample.ID)
#Looping through each sample ID
for(i in Samples){
 ### First we are going to determine all of necessary physiological descriptors that we can from OD600.###
            input = dplyr::filter(data,Sample.ID == i)
            #Taking a random sample of n = graphs. This will allow us to randomly plot graphs so that our spot checking isn't skewed by the samples that occur first.
            random_i = sample.int(length(Samples),graphs)
            #Conducting the spline interpolation for OD600
            OD600_model = smooth.spline(y = input$OD600,x =input$Time,spar = 0.75)

             #Getting the predicted values
            OD600_values = predict(OD600_model,x=input$Time, deriv = 0)

            #Need to generate spline fitted OD600 values for visualization
            sp_OD600_x = seq((0),(max(input$Time)), by = 0.1)
            sp_OD600_y = predict(OD600_model,sp_OD600_x, deriv = 0)$y
            sp_OD600_graph = data.frame(sp_OD600_x,sp_OD600_y)

             #By looking at the max of the derivitive, we are able to determine the maximum slope and determine the equation of that tangent line.
            OD600_deriv = predict(OD600_model,x= input$Time, deriv = 1)
            OD600_max_index = which(OD600_deriv$y == max(OD600_deriv$y))
            u1_slope = max(OD600_deriv$y)

            #Here we can see the max and minimum values for OD600 that were observed
            OD600_max_obs = max(input$OD600)
            OD600_min_obs = min(input$OD600)

            # x value of point with max slope
            OD600_x_max = OD600_values$x[OD600_max_index[1]]

            #y value of point with max slope
            OD600_y_max = OD600_values$y[OD600_max_index[1]]

            #Using the slope and the x and y value of a known point, we are able to calculate the b coefficient through the equation of a line
            OD600_b_max = OD600_y_max -(u1_slope * OD600_x_max)

            #Determining the LLP endpoint (LEX1 startpoint) by the equation of a line
            LLP_end = (OD600_min_obs - OD600_b_max)/u1_slope
            LEX1_start = LLP_end
            LLP_start = min(input$Time)

            #Now we can calculate the length of LLP
            LLP_length = LLP_end - LLP_start

            #Generating values in order to visualize u1
            u1_x =seq((OD600_x_max - 2),(OD600_x_max + 2), by = 0.1)
            u1_y = (u1_x * u1_slope) + OD600_b_max
            u1_graph = data.frame(u1_x,u1_y)

            # Now we can determine the end of the LEX1 interval and it's length.
            LEX1_end = (OD600_max_obs - OD600_b_max)/u1_slope
            LTP_start = LEX1_end
            LEX1_length = LEX1_end - LEX1_start

 ### Now we are going to determine all of necessary physiological descriptors that we can from pH.###
            pH_model = smooth.spline(y = input$pH,x =input$Time,spar = 0.75)
            pH_values = predict(pH_model,x=input$Time, deriv = 0)

            #Need to generate spline fitted OD600 values for visualization
            sp_pH_x = seq((0),(max(input$Time)), by = 0.1)
            sp_pH_y = predict(pH_model,sp_OD600_x, deriv = 0)$y
            sp_pH_graph = data.frame(sp_pH_x,sp_pH_y)

            #By looking at the max of the derivitive, we are able to determine the maximum or minimum slope and determine the equation of that tangent line.
            pH_deriv = predict(pH_model,x= input$Time, deriv = 1)
            RBa_limits = which(pH_deriv$x > LTP_start)
            pH_max_index = which(pH_deriv$y == max(pH_deriv$y[RBa_limits]))

            #To get the pH value of interest, we have to specify that we are talking about the maximum pH that occurs after the minimum. If we didn't do this, we would just get the starting pH of the culutre, because the pH decreases dramatically over the course of the culture.
            pH_min_obs = min(input$pH)
            pH_min_index = which(input$pH == min(input$pH))[1]

            #need to specify that this occurs after the minimum pH point
            RBa_slope = max(pH_deriv$y[RBa_limits])
            pH_max_obs = max(input$pH[pH_min_index:length(pH_values$y)])

            #Determining the x value of point with max slope
            pH_x_max = pH_values$x[pH_max_index[1]]

            #y value of point with max slope
            pH_y_max = pH_values$y[pH_max_index[1]]

             #calculating b coefficient
            pH_b = pH_y_max -(RBa_slope * pH_x_max)
            #calculating the x value for LTP_LEX2
            LTP_end = (pH_min_obs - pH_b)/RBa_slope
            LEX2_start = LTP_end
            LTP_length = LTP_end - LTP_start

            #calculating the x value for LEX2
            LEX2_end = (pH_max_obs - pH_b)/RBa_slope
            LEX2_length = LEX2_end - LEX2_start

            #Generating values in order to visualize Rba
            RBa_x = seq((pH_x_max-2),(pH_x_max + 2))
            RBa_y = (RBa_x *RBa_slope) + pH_b
            RBa_graph = data.frame(RBa_x, RBa_y)

            #Determining the fit of the RAc tangent line
            RAc_slope = min(pH_deriv$y)
            RAc_x_obs = input$Time[which(pH_deriv$y == RAc_slope)[1]]
            RAc_y_obs = input$pH[which(pH_deriv$y == RAc_slope)[1]]
            RAc_b = RAc_y_obs - (RAc_slope * RAc_x_obs)

            #Generating values in order to visualize RAc
            RAc_x = seq(RAc_x_obs - 2, RAc_x_obs + 2, by = 0.1)
            RAc_y = RAc_x * RAc_slope + RAc_b
            RAc_graph = data.frame(RAc_x, RAc_y)

###Last thing needed is to calculate u2, which we can now do by confining our data set to the area inbetween LTP_LEX2 and LEX_2###

            #First need to confine to the area in between LTP_LEX2 and LEX_2
            u2_data = input[which(input$Time > LEX2_start & input$Time < LEX2_end),]
            u2_model = smooth.spline(y = u2_data$OD600,x =u2_data$Time,spar = 0.75)
            u2_values = predict(u2_model,x=u2_data$Time,deriv = 0)
            #By looking at the max of the derivitive, we are able to determine the maximum slope and determine the equation of that tangent line.
            u2_deriv = predict(u2_model,x=u2_data$Time, deriv = 1 )
            u2_slope = max(u2_deriv$y)
            u2_max_x_obs = u2_values$x[which(u2_deriv$y == max(u2_deriv$y))[1]]
            u2_max_y_obs = u2_values$y[which(u2_deriv$y == max(u2_deriv$y))[1]]
            u2_b = u2_max_y_obs - (u2_slope * u2_max_x_obs)
            #Generating values in order to visualize u2
            u2_x = seq((u2_max_x_obs - 2),(u2_max_x_obs + 2), by = 0.1)
            u2_y = u2_x * u2_slope + u2_b
            u2_graph = data.frame(u2_x,u2_y)

             if (i %in% random_i){
                #Creating the OD600 plot
                p1 = ggplot2::ggplot(input, aes(x= Time, y = OD600))+
                        ggplot2::geom_line(data = sp_OD600_graph, aes(sp_OD600_x,sp_OD600_y), color = "blue")+
                        ggplot2::geom_line(data = u1_graph,aes(u1_x,u1_y),linetype = "dashed",color = "red",size = 1.25)+
                        ggplot2::geom_line(data = u2_graph,aes(u2_x,u2_y), linetype = "dashed",color = "red",size = 1.25)+
                        ggplot2::geom_point(size = 0.5)+
                        ggplot2::geom_vline(xintercept = LLP_start,color = "gray",linetype = "dashed")+
                        ggplot2::annotate("text", x = LLP_start, y = 1.2, angle = 90, label = "1",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LEX1_start,color = "gray",linetype = "dashed")+
                        ggplot2::annotate("text", x = LEX1_start, y = 1.2, angle = 90, label = "2",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LTP_start, color = "gray", linetype = "dashed")+
                        ggplot2::annotate("text", x = LTP_start, y = 1.2, angle = 90, label = "3",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LEX2_start, color = "gray", linetype = "dashed")+
                        ggplot2::annotate("text", x = LEX2_start, y = 1.2, angle = 90, label = "4",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LEX2_end, color = "gray", linetype = "dashed")+
                        ggplot2::annotate("text", x = LEX2_end, y = 1.2, angle = 90, label = "5",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::ylab("Ln (OD600)")+
                        ggplot2::ggtitle("OD600")


                #Creating the pH plot
                p2 = ggplot2::ggplot(input, aes(x= Time, y = pH))+
                        ggplot2::geom_line(data = sp_pH_graph,aes(sp_pH_x,sp_pH_y), color = "blue")+
                        ggplot2::geom_line(data = RBa_graph,aes(RBa_x,RBa_y),linetype ="dashed", color = "red",size = 1.25)+
                        ggplot2::geom_line(data = RAc_graph, aes(RAc_x,RAc_y), linetype = "dashed", color = "red",size = 1.25)+
                        ggplot2::geom_point(size = 0.5)+
                        ggplot2::geom_vline(xintercept = LLP_start,color = "gray",linetype = "dashed")+
                        ggplot2::annotate("text", x = LLP_start, y = 7.1, angle = 90, label = "1",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2:: geom_vline(xintercept = LEX1_start,color = "gray",linetype = "dashed")+
                        ggplot2::annotate("text", x = LEX1_start, y = 7.1, angle = 90, label = "2",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LTP_start, color = "gray", linetype = "dashed")+
                        ggplot2::annotate("text", x = LTP_start, y = 7.1, angle = 90, label = "3",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LEX2_start, color = "gray", linetype = "dashed")+
                        ggplot2::annotate("text", x = LEX2_start, y = 7.1, angle = 90, label = "4",
                            vjust = 1.2, parse = TRUE)+
                        ggplot2::geom_vline(xintercept = LEX2_end, color = "gray", linetype = "dashed")+
                            annotate("text", x = LEX2_end, y = 7.1, angle = 90, label = "5",
                        vjust = 1.2, parse = TRUE)+
                        ggplot2::ggtitle("pH")
                #Arranging the plots into the same graph
                    p3 = ggpubr::ggarrange(p1,p2)
                    p4 = ggpubr::annotate_figure(p3, i)
                    print(p4)
                 }
    #Binding all of the growth parameters to the output data frame
            parameters = cbind(u1_slope,u2_slope,RAc_slope,RBa_slope,LLP_length,LEX1_length,LTP_length,LEX2_length)
            output = rbind(output,parameters)
}
    return(output)
}

