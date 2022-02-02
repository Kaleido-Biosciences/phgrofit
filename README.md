
<!-- README.md is generated from README.Rmd. Please edit that file -->

# phgrofit

phgrofit is a R package that is designed to provide tools for making
kinetic analysis of OD600 and pH data easy.

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
devtools::install_github("Kaleido-Biosciences/phgrofit")
```

<!-- badges: start -->

[![R-CMD-check](https://github.com/Kaleido-Biosciences/phgrofit/workflows/R-CMD-check/badge.svg)](https://github.com/Kaleido-Biosciences/phgrofit/actions)
[![DOI](https://zenodo.org/badge/288753400.svg)](https://zenodo.org/badge/latestdoi/288753400)


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
print(head(phgropro_output))
#>    Sample.ID Study Plate Row Column Well  Compound Compound_Concentration
#> 1 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#> 2 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#> 3 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#> 4 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#> 5 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#> 6 G798.p1.A1  G798     1   A      1   A1 D-Glucose                    0.5
#>   Community       Media      Time OD600    pH
#> 1   B.theta Mega Medium 0.0000000 0.231 7.029
#> 2   B.theta Mega Medium 0.2333333 0.242 7.017
#> 3   B.theta Mega Medium 0.4833333 0.254 6.958
#> 4   B.theta Mega Medium 0.7333333 0.269 6.989
#> 5   B.theta Mega Medium 1.0000000 0.288 6.987
#> 6   B.theta Mega Medium 1.2500000 0.310 7.035
```

## Modeling with phgrofit

Now we can use the phgrofit to model each curve and extract the
physiologically relevant features.

``` r
#Conducting the modeling
phgrofit_output = phgrofit(phgropro_output)
```

This will produce the following data frame.

``` r
print(head(phgrofit_output))
#>    Sample.ID Study Plate Row Column Well    Compound Compound_Concentration
#> 1 G798.p1.A1  G798     1   A      1   A1   D-Glucose                    0.5
#> 2 G798.p1.B1  G798     1   B      1   B1   D-Glucose                    0.5
#> 3 G798.p1.C1  G798     1   C      1   C1 D-Galactose                    0.5
#> 4 G798.p1.D1  G798     1   D      1   D1 D-Galactose                    0.5
#> 5 G798.p1.E1  G798     1   E      1   E1 D-Arabinose                    0.5
#> 6 G798.p1.F1  G798     1   F      1   F1 D-Arabinose                    0.5
#>   Community       Media starting_od600 od600_lag_length od600_max_gr max_od600
#> 1   B.theta Mega Medium     0.04109686        0.9273289    0.3407801  2.134385
#> 2   B.theta Mega Medium     0.04346234        0.9774426    0.3481509  2.180504
#> 3   B.theta Mega Medium     0.04853609        1.5186534    0.3446916  2.166952
#> 4   B.theta Mega Medium     0.04491131        1.5531334    0.3439335  2.156492
#> 5   B.theta Mega Medium     0.08877224        2.0837220    0.2976787  2.151352
#> 6   B.theta Mega Medium     0.21506327        2.4986636    0.2971100  2.146010
#>   difference_between_max_and_end_od600 auc_od600 starting_pH
#> 1                            0.1696881  90.08715    7.160139
#> 2                            0.1341777  93.55510    7.169610
#> 3                            0.1776668  90.64111    7.112298
#> 4                            0.1989878  89.43158    7.104725
#> 5                            0.1520904  90.00384    7.085658
#> 6                            0.1748502  89.50497    7.096101
#>   max_acidification_rate   min_pH time_of_min_pH max_basification_rate   max_pH
#> 1             -0.2444190 5.605431       42.03333           0.022018604 7.160139
#> 2             -0.2411432 5.644260       47.28333           0.026570630 7.169610
#> 3             -0.2293043 5.683751       10.50000           0.017070186 7.112298
#> 4             -0.2297630 5.682021       10.75000           0.014576254 7.104725
#> 5             -0.1847080 5.760960       21.51667           0.004361004 7.085658
#> 6             -0.1749480 5.770639       23.26667           0.008963011 7.096101
#>   difference_between_end_and_min_pH   auc_pH percent_NA_od600 percent_NA_pH
#> 1                      1.171573e-02 280.9335                0             0
#> 2                      3.815244e-05 282.4024                0             0
#> 3                      3.815786e-02 283.6425                0             0
#> 4                      3.759313e-02 283.3362                0             0
#> 5                      5.531682e-02 285.4200                0             0
#> 6                      5.591642e-02 285.4526                0             0
#>   rmse_od600    rmse_pH
#> 1 0.05971485 0.04659988
#> 2 0.06193201 0.04570372
#> 3 0.05969187 0.04017724
#> 4 0.05984325 0.04046892
#> 5 0.04207331 0.02974554
#> 6 0.04723838 0.02561122
```

## Checking Model Fit

We can use the function flag to look at the data and see if there are
any obvious problems with our curves.

``` r
flag = flag(phgrofit_output)
print(head(flag))
#>    Sample.ID negligable_growth negative_lag_length missing_pH_data
#> 1 G798.p1.D7             FALSE                TRUE           FALSE
#> 2 G798.p1.H8             FALSE                TRUE           FALSE
#>   missing_od600_data starting_od600_higher_than_max
#> 1              FALSE                          FALSE
#> 2              FALSE                          FALSE
```

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

print(head(problem_flag))
#>    Sample.ID negligable_growth negative_lag_length missing_pH_data
#> 1 G798.p1.A1             FALSE               FALSE            TRUE
#> 2 G798.p1.B1             FALSE               FALSE            TRUE
#> 3 G798.p1.C1             FALSE               FALSE            TRUE
#> 4 G798.p1.D1             FALSE               FALSE            TRUE
#> 5 G798.p1.E1             FALSE               FALSE            TRUE
#> 6 G798.p1.F1             FALSE               FALSE            TRUE
#>   missing_od600_data starting_od600_higher_than_max
#> 1              FALSE                          FALSE
#> 2              FALSE                          FALSE
#> 3              FALSE                          FALSE
#> 4              FALSE                          FALSE
#> 5              FALSE                          FALSE
#> 6              FALSE                          FALSE
```

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
missing a bunch of pH values!

You can also use the model\_fit\_check function independantly of flag.
Like I mentioned before, this function allows the user to specify
conditions to group by and subsequently plot a randomly sampled plot
from each distinct member of the grouping. This allows the user to check
as many conditions as they may wish. To check all of them, you can
simpily group by Sample.ID.

In this case, we will just check a plot from each community.

Note that there are a few features that are being extracted that aren’t
displayed on the graph because they were hard to overlay visually.

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
to group by Community and Compound

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
compound and community. Be sure to use scaled data!

In this README, you will only see a static image because the function
returns a html file that can not be viewed in the format of this README.
When you go to use the function in your R session it will return a
interactive plotly image.

``` r
heatmapper(scaled,labels = c("Compound","Community"))
```

![](images/phgrofit_heatmap.png)

### PCA

We can generate a PCA plot using the PCA function. We can specify to
show the 95% confidence interval for any group. In this example, let’s
show the 95% confidence intervals for each community. Be sure to use
scaled data here!

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

head(d1)
#>             Sample.ID Community    Compound      Time mean_OD600    sd_OD600
#> 1 B.theta,D-Arabinose   B.theta D-Arabinose 0.0000000    0.28675 0.140883817
#> 2 B.theta,D-Arabinose   B.theta D-Arabinose 0.2333333    0.26575 0.089544682
#> 3 B.theta,D-Arabinose   B.theta D-Arabinose 0.4833333    0.25425 0.053934374
#> 4 B.theta,D-Arabinose   B.theta D-Arabinose 0.7333333    0.25000 0.027446918
#> 5 B.theta,D-Arabinose   B.theta D-Arabinose 1.0000000    0.25300 0.011460076
#> 6 B.theta,D-Arabinose   B.theta D-Arabinose 1.2500000    0.26525 0.007889867
#>   mean_pH       sd_pH dendrogram_cluster
#> 1 7.01350 0.054224841                  1
#> 2 6.98950 0.034063666                  1
#> 3 6.99850 0.030643107                  1
#> 4 6.97900 0.009416298                  1
#> 5 6.97175 0.013047988                  1
#> 6 6.98975 0.015986974                  1
```

The dendrospect\_model function returns the modeling data with the
dendogram cluster each observation belongs to.

``` r
d2 = dendrospect_model(scaled,k = 8)
head(d2)
#>             Sample.ID Community    Compound starting_od600 od600_lag_length
#> 1 B.theta,D-Arabinose   B.theta D-Arabinose     0.11990889        0.1017570
#> 2  B.theta,D-Fructose   B.theta  D-Fructose     0.18125769       -0.2542864
#> 3 B.theta,D-Galactose   B.theta D-Galactose     0.05706532       -0.1596929
#> 4   B.theta,D-Glucose   B.theta   D-Glucose     0.04224956       -0.4269453
#> 5   B.theta,D-Lactose   B.theta   D-Lactose     0.14353568       -0.1414794
#> 6   B.theta,D-Mannose   B.theta   D-Mannose     0.06869326       -0.2723645
#>   od600_max_gr max_od600 difference_between_max_and_end_od600 auc_od600
#> 1    0.5966122 0.7907250                            0.0950429 0.8496821
#> 2    1.2024706 0.9348515                            0.2870721 1.0824876
#> 3    1.2016324 0.8371996                            0.5017801 0.8798215
#> 4    1.1845056 0.8145312                            0.2100595 0.9450279
#> 5    1.1472902 0.8752052                            0.1997656 0.9918766
#> 6    1.1986093 0.8909467                            0.1037122 1.0245895
#>   starting_pH max_acidification_rate     min_pH time_of_min_pH
#> 1    7.073956             -0.1421476 -0.8095892      0.1862913
#> 2    7.133463             -1.0217992 -1.2841809      2.2689608
#> 3    7.107509             -0.8068949 -0.9960939     -0.4409099
#> 4    7.147899             -0.9962934 -1.1934110      2.0725708
#> 5    7.116614             -0.9166055 -1.1335886      0.2657825
#> 6    7.125909             -0.9142467 -1.2200137      2.3671558
#>   max_basification_rate      max_pH difference_between_end_and_min_pH    auc_pH
#> 1            -1.3747230 -0.10294825                        -0.7641644 -1.249419
#> 2            -0.5401702  0.15866991                        -0.8925923 -1.569948
#> 3            -0.8139461  0.04456342                        -0.7924635 -1.329643
#> 4            -0.6047204  0.22213528                        -0.8707962 -1.498952
#> 5            -0.7213197  0.08459232                        -0.8387045 -1.477587
#> 6            -0.8737991  0.12545686                        -0.8943224 -1.495383
#>   percent_NA_od600 percent_NA_pH rmse_od600    rmse_pH dendrogram_cluster
#> 1                0             0 0.04431524 0.02859445                  2
#> 2                0             0 0.07029572 0.04713001                  2
#> 3                0             0 0.06227051 0.04142766                  2
#> 4                0             0 0.06206526 0.04893169                  2
#> 5                0             0 0.06449833 0.04195363                  2
#> 6                0             0 0.06271213 0.04636216                  2
```

# OD600 data alone

Say you aren’t interested in pH data and you would like to use these
tools with just OD600 data. That is exactly the case that grofit was
made to solve. It operates on the same type of data as phgrofit, just
without the pH column. Right now there isn’t a dedicated parser
homologous to phgropro, but this may be a feature in the future.

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

Let’s first look at a randomly sampled model fit from each community

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

print(head(grofit_clusters,5))
#>             Sample.ID Community    Compound starting_od600 od600_lag_length
#> 1 B.theta,D-Arabinose   B.theta D-Arabinose     0.11990889        0.1017570
#> 2  B.theta,D-Fructose   B.theta  D-Fructose     0.18125769       -0.2542864
#> 3 B.theta,D-Galactose   B.theta D-Galactose     0.05706532       -0.1596929
#> 4   B.theta,D-Glucose   B.theta   D-Glucose     0.04224956       -0.4269453
#> 5   B.theta,D-Lactose   B.theta   D-Lactose     0.14353568       -0.1414794
#>   od600_max_gr max_od600 difference_between_max_and_end_od600 auc_od600
#> 1    0.5966122 0.7907250                            0.0950429 0.8496821
#> 2    1.2024706 0.9348515                            0.2870721 1.0824876
#> 3    1.2016324 0.8371996                            0.5017801 0.8798215
#> 4    1.1845056 0.8145312                            0.2100595 0.9450279
#> 5    1.1472902 0.8752052                            0.1997656 0.9918766
#>   percent_NA_od600 rmse_od600 dendrogram_cluster
#> 1                0 0.04431524                  4
#> 2                0 0.07029572                  4
#> 3                0 0.06227051                  4
#> 4                0 0.06206526                  4
#> 5                0 0.06449833                  4
```

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
