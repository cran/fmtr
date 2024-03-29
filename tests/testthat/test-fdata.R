context("fdata Tests")



test_that("fdata() function works as expected with named vector.", {
  
  res <- c(A = "Label A", B = "Label B", C = "Other", B = "Label B")
  
  fb <- data.frame(id = 100:103, 
                   catc = c("A", "B", "C", "B"), 
                   catn = c(1, 2, 3, 2)) 
  
  
  attr(fb$catc, "format") <- c(A = "Label A", B = "Label B", C = "Other")

  
  fmt_fb <- fdata(fb)
  
  
  expect_equal(all(fmt_fb$catc == res), TRUE)
  

})



test_that("fdata() function works as expected with fmt object.", {
  
  res <- c("Label A", "Label B", "Other", "Label B")
  
  fb <- data.frame(id = 100:103, 
               catc = c("A", "B", "C", "B"), 
               catn = c(1, 2, 3, 2)) 
  
  
  attr(fb$catc, "format") <- 
    value(condition(x == "A", "Label A"),
          condition(x == "B", "Label B"),
          condition(TRUE, "Other"))

  fmt_fb <- fdata(fb)
  
  expect_equal(all(fmt_fb$catc == res), TRUE)
  
})



test_that("fdata() function works as expected with vectorized function.", {
  
  res <- c("Label A", "Label B", "Other", "Label B")
  
  fb <- data.frame(id = 100:103, 
               catc = c("A", "B", "C", "B"), 
               catn = c(1, 2, 3, 2)) 
  
  attr(fb$catc, "format") <- Vectorize(function(x) {
    
    if (x == "A") 
      ret <- "Label A"
    else if (x == "B")
      ret <- "Label B"
    else 
      ret <- "Other"
    
    return(ret)
    
  })
  
  
  fmt_fb <- fdata(fb)

  
  expect_equal(all(fmt_fb$catc == res), TRUE)
  
  
})




test_that("fdata() function works as expected with list of formats.", {

  
  v1 <- c("type1", "type2", "type3", "type2", "type3", "type1")
  v2 <- list(1.258, "H", as.Date("2020-06-19"),
             "L", as.Date("2020-04-24"), 2.8865)
  
  df <- data.frame(type = v1, values = I(v2))
  df
  
  lst <- flist(type  = "row", lookup = v1,
               type1 = "%.1f",
               type2 = value(condition(x == "H", "High"),
                              condition(x == "L", "Low"),
                              condition(TRUE, "NA")),
               type3 = "%y-%m")
  
  
  attr(df$values, "format") <- lst
  df$values
  
  ret <- fdata(df)
  ret
  
  
  expect_equal(as.character(ret[1, 2]), "1.3")
  expect_equal(as.character(ret[2, 2]), "High")
  expect_equal(as.character(ret[3, 2]), "20-06")

})


test_that("fdata() function restores any labels.", {
  
  res <- c(A = "Label A", B = "Label B", C = "Other", B = "Label B")
  
  fb <- data.frame(id = 100:103, 
                   catc = c("A", "B", "C", "B"), 
                   catn = c(1, 2, 3, 2)) 
  
  attr(fb$catc, "label") <- "My Labels" 
  
  attr(fb$catc, "format") <- c(A = "Label A", B = "Label B", C = "Other")
  
  #print(is.null(attr(fb$catc, "label")))
  
  fmt_fb <- fdata(fb)
  
  # print("Here I am in the fdata() check")
  # print(fmt_fb)
  # print(fmt_fb$catc)
  # 
  # attr(fmt_fb$catn, "label") <- "My numeric label"
  # print(attr(fmt_fb$catn, "label"))
  # print(attr(fmt_fb$catc, "label"))
  
  expect_equal(attr(fmt_fb$catc, "label"), "My Labels")
  
  
})



test_that("fdata() function returns character data types.", {
  

  
  fb <- data.frame(id = 100:103, 
                   catc = c("A", "B", "C", "B"), 
                   catn = c(1, 2, 3, 2), 
                   stringsAsFactors = FALSE) 
  
  widths(fb) <- list(id = 10, catc = 10, catn = 10)
  
  expect_equal(class(fb$id), "integer")
  expect_equal(class(fb$catc), "character")
  expect_equal(class(fb$catn), "numeric")
  
  #print(is.null(attr(fb$catc, "label")))
  
  fmt_fb <- fdata(fb)

  
  expect_equal(class(fmt_fb$id), "character")
  expect_equal(class(fmt_fb$catc), "character")
  expect_equal(class(fmt_fb$catn), "character")
  
  
})

test_that("fdata() function works as expected with tibble.", {
  
  dta <- as_tibble(mtcars)
  
  dt1 <- fdata(dta)
  
  expect_equal("tbl_df" %in% class(dt1), TRUE)
  
})

test_that("fdata() parameter checks work as expected.", {
  
  expect_error(fdata("fork"))
  
  dat <- mtcars
  
  res <- fdata(dat, width = 10)
  
  expect_equal(nchar(res[1, 1]), 10)
  
})


