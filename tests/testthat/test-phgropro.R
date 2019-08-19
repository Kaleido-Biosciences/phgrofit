context("Output from processing")

#Making sure that there are the correct number of rows
test_that("There are the correct number of rows when processing 96 wells",{

    filepath = system.file("tests/testdata/phgropro_96_test.txt",package = "phgrofit")
    output = phgropro(filepath,96)
    #There are 60 timepoints in the test data set.
    expect(nrow(output) == 96 * 60, "Wrong number of rows with 96 well test data set")

})

#Spot checking values to ensure they are correct.
test_that("There are the correct number of rows when processing 384 wells",{

    filepath = system.file("tests/testdata/phgropro_384_test.txt",package = "phgrofit")
    output = phgropro(filepath,384)
    #There are 77 timepoints in the test data set
    expect(nrow(output) == 384 * 77, "Wrong number of rows with 384 well test data set")

})



