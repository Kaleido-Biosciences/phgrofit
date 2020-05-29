% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scale_phgrofit.R
\name{scale_phgrofit}
\alias{scale_phgrofit}
\title{scale_phgrofit
This function allows the user to scale the results of phgrofit. This should be used upstream of functions requiring a standardization of data.
Scaling is done outside of the plotting functions in order to allow more transparancy as to what is acutally being plotted than would be apparent otherwise.
Additionally, this will allow the user to choose the appropriate scaling function for their application.}
\usage{
scale_phgrofit(phgrofit_output, group_by = NULL)
}
\arguments{
\item{phgrofit_output:}{This is a character vector of the groups that you would like to scale within}
}
\value{
a dataframe containing all of content of phgrofit with each model parameter scaled such that the mean = 0 and values represent Z scores.
}
\description{
scale_phgrofit
This function allows the user to scale the results of phgrofit. This should be used upstream of functions requiring a standardization of data.
Scaling is done outside of the plotting functions in order to allow more transparancy as to what is acutally being plotted than would be apparent otherwise.
Additionally, this will allow the user to choose the appropriate scaling function for their application.
}
\examples{

phgropro_output = phgrofit::phgropro("rawdata.txt","metadata.csv",384)
phgrofit_output = phgrofit::phgrofit(phgropro_output)

#To get the scaled data
scaled_phgrofit = phgrofit::scale_phgrofit(phgrofit_output)

#To get data that has been independantly scaled per community
scaled_phgrofit = phgrofit::scale_phgrofit(phgrofit_output,group_by = "Community")


}