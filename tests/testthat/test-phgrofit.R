context("phgrofit data table of parameters")

#Making sure that there are the correct number of rows
test_that("There are the correct number of rows",{

    data = read.csv(system.file("tests/testdata/phgrofit_test_data.csv",package = "phgrofit"))
    metadata = read.csv(system.file("tests/testdata/384_Metadata.csv",package = "phgrofit"))
    output = phgrofit(data,metadata)

        expect(nrow(output) == 44, "Wrong number of rows with test data set")

})

#Spot checking values to ensure they are correct.
test_that("The calculated u1 values are correct",{

    data = read.csv(system.file("tests/testdata/phgrofit_test_data.csv",package = "phgrofit"))
    metadata = read.csv(system.file("tests/testdata/384_Metadata.csv",package = "phgrofit"))
    output = phgrofit(data,metadata)


        expect_equal(output[30,2],0.1849, tolerance = 0.001)
})



