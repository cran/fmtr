context("descriptions() function Tests")




test_that("descriptions() function works as expected.", {
  
  df1 <- mtcars[1:10, c("mpg", "cyl") ]
  
  df1
  # Assign formats
  descriptions(df1) <- list(mpg = "Miles per gallon", 
                             cyl = "Cylinders")

  
  # Extract format list
  lst <- descriptions(df1)
  
  expect_equal(length(lst), 2)
  
  
  format(df1) 
  
})

