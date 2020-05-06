
<!-- README.md is generated from README.Rmd. Please edit that file -->

# phgrofit

phgrofit is a R package designed to provide tools for making kinetic
analysis of OD600 and pH data easy.

The motivation for this package comes from the desire to process kinetic
pH and OD600 data in a somewhat similar manner to this
[paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3187081/).

In short, this package is designed to take OD600 and pH (gained using
the BCECF method described in the paper above) kinetic readouts in
either a 96 or 384 well format and process the data, extract
physiological parameters, and cluster these parameters to infer
relationships between compounds.

## Installation

``` r
devtools::install_gitlab("cbayne/phgrofit", 
                         auth_token = "Your auth token from gitlab",
                         host = "gitlab.kaleidobio.com")
```

<!-- badges: start -->

<!-- badges: end -->

# Using this package

## Processing raw data with phgropro

Phgropro was built to take raw data that is exported from a biotek plate
reader and has very specific structure. The output of phgropro serves as
the input to all of the other phgrofit functions. Thus, you need to have
data in the format produced from phgropro to use the rest of the
phgrofit package.

The easiest way to get data in this format is to use the plate reader
protocols that are in the biotek\_plate\_reader\_protocols folder of
this repository and use the export provided. Unfortunatly, this will
only be usefull if the user happens to have acess to a Biotek Synergy H1
plate reader.

Alternatively, the user can generate a dataframe in R through their own
means that is compatible with the other phgrofit functions. Such a data
frame would need to have “Sample.ID”,“Time”,“OD600”,and “pH” as column
names, and each row should represent a timepoint for a given Sample.ID.
Other columns containing other metadata could be included as well.

Okay, let’s start by formatting our data using phgropro. Here we need to
specify the file path of a file containing the raw data.txt, the file
path of a file containing the metadata for each Sample.ID, and the plate
type that was used (96 or 384).

``` r
library(phgrofit)
#Loading the necessary data
phgropro_output = phgropro("tests/testdata/phgrofit_test_raw_data.txt",
                           "tests/testdata/phgrofit_test_metadata.csv",
                           Plate_Type = 384)
```

The resulting data frame looks like this:

``` r
DT::datatable(head(phgropro_output))
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" /> \#\#
Modeling with phgrofit

Now we can use the phgrofit to model each curve and extract the
physiologically relevant features.

``` r
#Conducting the modeling
phgrofit_output = phgrofit(phgropro_output)
```

This will produce the following data frame.

``` r
DT::datatable(head(phgrofit_output))
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

## Visually Checking Model Fit

Now we can check to see how the model fit is performing using the
model\_fit\_check function. Since there are so many different kinetic
curves, this function allows the user to specify conditions to group by
and subsequently plot a randomly sampled plot from each distinct member
of the grouping. This allows the user to check as many conditions as
they may wish. To check all of them, you can simpily group by Sample.ID.

In this case, we will just check a plot from each community.

Note that there are 3 features that are being extracted that aren’t
displayed on the graph because they were hard to overlay
visually.

``` r
model_fit_check(phgropro_output,grouping_vars = c("Community"))
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" /><img src="man/figures/README-unnamed-chunk-6-2.png" width="100%" /><img src="man/figures/README-unnamed-chunk-6-3.png" width="100%" /><img src="man/figures/README-unnamed-chunk-6-4.png" width="100%" />

We can see from the above plots that the modeling appears to be working
well.

## Transforming data

### Averaging

Oftentimes, the user may wish to average kinetic or modeling data. This
can easily be done with the avg\_phgropro and avg\_phgrofit functions
repectively. The user just has to specify the name of the colums that
they wish to group by and then take the average for. Here it makes sense
to group by Community and
Compound

``` r
averaged_phgropro = avg_phgropro(phgropro_output,c("Community","Compound"))

averaged_phgrofit = avg_phgrofit(phgrofit_output,c("Community","Compound"))
```

### Scaling

For many applications such as heatmaps or PCA plots, the user will need
to scale the data. This can be accomplished with the scale\_phgrofit
function.

This function offers the option to scale for each specified group
independantly.

``` r
# All model parameters are scaled 
scaled = averaged_phgrofit %>%
    scale_phgrofit()

# All model parameters are scaled for each community independantly
scaled_by_community = averaged_phgrofit %>% 
    scale_phgrofit("Community")
```

## Visualizations

### Heatmapper

Now lets look to see how the data clusters. Here we can color by
compound and community. Be sure to use scaled data\!

In this README, you will only see a static image because the function
returns a html file that can not be viewed in the format of this README.
When you go to use the function in your R session it will return a
interactive plotly image

``` r
p1 = heatmapper(scaled,labels = c("Compound","Community"))
p1
```

![](images/heatmapper.png)

### PCA

We can generate a PCA plot using the PCA function. We can specify to
show the 95% confidence interval for any group. In this example, let’s
show the 95% confidence intervals for each community. Be sure to use
scaled data here\!

``` r
p1 = PCA(scaled,"Community")
#> Warning: Ignoring unknown aesthetics: text
p1
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

### Dendrogram and associated kinetic curves

It is often times hard to look at a dendrogram and get a good idea about
what the clusters actually mean. The dendrospect function allows the
user to color the dendrogram into k number of cluster and look at the
average kinetic pH and OD600 profile within each cluster. The function
also allows for the user to label the dendogram by a colored bar for a
specified variable.

``` r
p1 = dendrospect(scaled,averaged_phgropro,"Community", k = 4)

p1
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

### Looking closer at data corresponding with clusters

Oftentimes the user will want to be able to inspect the data displayed
in the above plot more thoroughly. That is the purpose of the
dendropsect\_kinetic and dendorospect\_model functions. The
dendrospect\_kinetic function returns kinetic data with the
dendogram\_cluster each observation belongs to.

``` r
d1 = dendrospect_kinetic(averaged_phgropro,scaled,k=4)

DT::datatable(head(d1))
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

The dendrospect\_model function returns the modeling data with the
dendogram cluster each observation belongs to.

``` r
d2 = dendrospect_model(scaled,k = 8)
DT::datatable(d2)
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

# Function List

1.  phgropro() : Used to process kinetic pH and OD600 data resulting
    from a standardized export from the Biotek Gen5 software and combine
    with user supplied metadata.

2.  phgrofit() : Takes the output of phgrofit::phgropro()) and extracts
    relevant physiological parameters by conducting spline
    interpolation.

3.  model\_fit\_check(): Allows for visual checking of the modeling fit
    by printing graphs for the combination of conditions the user
    supplies.

4.  avg\_phgropro(): Allows the user to easily average phgropro data for
    the specified grouping.

5.  avg\_phgrofit(): Allows the user to easily average phgrofit data for
    the specified grouping.

6.  scale\_phgrofit(): Allows the user to easily scale phgrofit modeling
    data. Can be done individually per specified group

7.  heatmapper(): Creates an interactive heat map with associated
    dendogram that has colored bars based on user input.

8.  PCA(): Visualizes the first two principle components and the 95%
    confidence interval for any specified group.

9.  dendrospect(): Returns a plot visualizing a dendogram that is
    colored by cluster number, and the corresponding average kinetic
    curves for each cluster.

10. dendrospect\_kinetic(): Returns a data frame of the kinetic data
    with the cluster that each Sample.ID would correspond to based on
    hierchical clustering of the modeling data.

11. dendrospect\_model(): Returns a data frame with the modeling data
    from phgrofit with the cluster that each Sample.ID would correspond
    to based on hierchical clustering of the data.
