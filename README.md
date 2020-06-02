
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
devtools::install_gitlab("vl32/phgrofit", 
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

![](man/figures/README-unnamed-chunk-3-1.png)<!-- -->

## Modeling with phgrofit

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

![](man/figures/README-unnamed-chunk-5-1.png)<!-- -->

## Checking Model Fit

We can use the function flag to look at the data and see if there are
any obvious problems with our curves.

``` r
flag = flag(phgrofit_output)
DT::datatable(flag)
```

![](man/figures/README-unnamed-chunk-6-1.png)<!-- -->

Here we can see there are a few wells that may be a problem. Based on
what flag returned, we can see that the lag length was calculated to be
negative.

Let’s look to see if this is actually a problem or not using the
model\_fit\_check function. This function will allow you to visually
check the model fit.

``` r
problem_wells = phgropro_output %>% 
  dplyr::filter(Sample.ID %in% flag$Sample.ID)

model_fit_check(problem_wells)
```

![](man/figures/README-unnamed-chunk-7-1.png)<!-- -->![](man/figures/README-unnamed-chunk-7-2.png)<!-- -->

Here we can see that even though the lag length was estimated to be
below 0, it was very close to 0 and is an adequate representation of the
data.

What if we had a different problem? Let’s say for some reason all of the
pH data between 0.5 and 24 hrs was NA.

``` r
phgropro_prob = phgropro_output %>% 
  dplyr::mutate(pH = ifelse(dplyr::between(Time,0.5,24),NA,pH))

phgrofit_prob = phgrofit(phgropro_prob)

problem_flag = flag(phgrofit_prob)

DT::datatable(head(problem_flag))
```

![](man/figures/README-unnamed-chunk-8-1.png)<!-- -->

Now we can see that there is missing\_pH data. This returns TRUE only if
25% or more of the data is NA. Let’s visually check using
model\_fit\_check now.

I didn’t mention this before, but if you pass a grouping\_vars argument
to model\_fit\_check, it will only return a randomly sampled plot from
the distinct conditions of your group. Let’s use this trick to look at a
distinct randomly sampled well with different values for
missing\_pH\_data

``` r
comb = dplyr::left_join(phgropro_prob,problem_flag,by = "Sample.ID")
model_fit_check(comb,"missing_pH_data")
```

![](man/figures/README-unnamed-chunk-9-1.png)<!-- -->

Here we can clearly see that there is as problem with the data, we are
missing a bunch of pH values\!

You can also use the model\_fit\_check function independantly of flag.
Like I mentioned before, this function allows the user to specify
conditions to group by and subsequently plot a randomly sampled plot
from each distinct member of the grouping. This allows the user to check
as many conditions as they may wish. To check all of them, you can
simpily group by Sample.ID.

In this case, we will just check a plot from each community.

Note that there are a few features that are being extracted that aren’t
displayed on the graph because they were hard to overlay
visually.

``` r
model_fit_check(phgropro_output,grouping_vars = c("Community"))
```

![](man/figures/README-unnamed-chunk-10-1.png)<!-- -->![](man/figures/README-unnamed-chunk-10-2.png)<!-- -->![](man/figures/README-unnamed-chunk-10-3.png)<!-- -->![](man/figures/README-unnamed-chunk-10-4.png)<!-- -->

We can see from the above plots that the modeling appears to be working
well.

Also, please note that phgrofit returns the root-mean-square deviation
for both pH and OD600. This should allow the user to specifically look
into values that they think are too high.

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
heatmapper(scaled,labels = c("Compound","Community"))
```

![](images/phgrofit_heatmap.png)

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

![](man/figures/README-unnamed-chunk-14-1.png)<!-- -->

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

![](man/figures/README-unnamed-chunk-15-1.png)<!-- -->

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

![](man/figures/README-unnamed-chunk-16-1.png)<!-- -->

The dendrospect\_model function returns the modeling data with the
dendogram cluster each observation belongs to.

``` r
d2 = dendrospect_model(scaled,k = 8)
DT::datatable(d2)
```

![](man/figures/README-unnamed-chunk-17-1.png)<!-- -->

# OD600 data alone

Say you aren’t interested in pH data and you would like to use these
tools with just OD600 data. That is exactly the case that grofit was
made to solve. It operates on the same type of data as phgrofit, just
without the pH column. Right now there isn’t a dedicated parser
homologous to phgropro, but I may make one in the future if the need
arises (would be called gropro.)

``` r
#Pretending that we only have OD600 data
gropro_output = phgropro_output %>% 
  dplyr::select(-pH)

grofit_output = gropro_output %>% 
  grofit()
```

We are able to detect whether you have used phgrofit or grofit by the
presence or absence of columns that only occur in phgrofit. This means
that you can use all of the functions that you would use with phgrofit
with grofit instead.

Let’s first look at a randomly sampled model fit from each
community

``` r
model_fit_check(gropro_output,"Community")
```

![](man/figures/README-unnamed-chunk-19-1.png)<!-- -->![](man/figures/README-unnamed-chunk-19-2.png)<!-- -->![](man/figures/README-unnamed-chunk-19-3.png)<!-- -->![](man/figures/README-unnamed-chunk-19-4.png)<!-- -->

Let’s average and scale the grofit data just like we would with
phgrofit.

``` r
avg_grofit = avg_phgrofit(grofit_output,c("Community","Compound"))
avg_gropro = avg_phgropro(gropro_output,c("Community","Compound"))

scaled_grofit = scale_phgrofit(avg_grofit)
```

Now let’s look at a PCA

``` r
PCA(scaled_grofit,"Community")
#> Warning: Ignoring unknown aesthetics: text
```

![](man/figures/README-unnamed-chunk-21-1.png)<!-- -->

Here we can see similar clustering to what we had observed previously.
Now we can make a heatmap.

``` r
heatmapper(scaled_grofit,c("Community","Compound"))
```

![](images/grofit_heatmap.png)

And we can even make a dendrogram with associated kinetic profiles.

``` r
dendrospect(scaled_grofit,avg_gropro,"Community",k=4)
```

![](man/figures/README-unnamed-chunk-23-1.png)<!-- -->

Lastly, if you want to see which data corresponds with a cluster, you
can use the other dendrospect functions.

``` r
grofit_clusters = dendrospect_model(scaled_grofit,k = 4)
gropro_clusters = dendrospect_kinetic(phgropro_data = avg_gropro,phgrofit_data = scaled_grofit, k =3)

DT::datatable(head(grofit_clusters,5))
```

![](man/figures/README-unnamed-chunk-24-1.png)<!-- -->

``` r
DT::datatable(head(gropro_clusters,5))
```

![](man/figures/README-unnamed-chunk-24-2.png)<!-- -->

# Function List

1.  phgropro() : Used to process kinetic pH and OD600 data resulting
    from a standardized export from the Biotek Gen5 software and combine
    with user supplied metadata.

2.  phgrofit() : Takes the output of phgrofit::phgropro()) and extracts
    relevant physiological features by fitting a smoothing spline.

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

12. grofit(): Extracts relevant physiological features for just OD600 by
    fitting a smoothing spline. All other functions expecting
    phgrofit\_output can also take grofit\_output instead.
