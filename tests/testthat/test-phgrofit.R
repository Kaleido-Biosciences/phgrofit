context("phgrofit data table of parameters")

#Making sure that there are the correct number of rows
test_that("There are the correct number of rows",{

    data = read.csv(system.file("tests/testdata/phgrofit_test_data.csv",package = "phgrofit"))
    output = phgrofit(data,graphs = 0)

        expect(nrow(output) == 44, "Wrong number of rows with test data set")

})

#Spot checking values to ensure they are correct.
test_that("The calculated u1 values are correct",{

    data = read.csv(system.file("tests/testdata/phgrofit_test_data.csv",package = "phgrofit"))
    output = phgrofit(data,graphs = 0)

        expect_equal(output[30,1],0.1849, tolerance = 0.001)
})



