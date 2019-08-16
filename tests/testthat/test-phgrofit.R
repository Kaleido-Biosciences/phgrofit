source("R/phgrofit.R")

testthat::test_that("The correct number of rows are generated", {

 data = read.csv("tests/testdata/phgrofit_test_data.csv")
 graphs = 0

 testthat::expect_equal(nrow(phgrofit(data,graphs)) == 44)

})
