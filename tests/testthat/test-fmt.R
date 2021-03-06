context("Format Tests")


test_that("value() function sets class and levels as expected", {
  
  
  res <- c("Label A", "Label B", "Other")
  
  
  fmt1 <- value(condition(x == "A", "Label A"),
                condition(x == "B", "Label B"), 
                condition(TRUE, "Other"))
  
  expect_equal(class(fmt1), "fmt")
  expect_equal(levels(fmt1), res)
  
})

test_that("ordered conditions set levels as expected", {
  
  
  res <- c("Label B", "Other", "Label A")
  
  
  fmt1 <- value(condition(x == "A", "Label A", order = 3),
                condition(x == "B", "Label B", order = 1), 
                condition(TRUE, "Other", order = 2))
  
  
  expect_equal(class(fmt1), "fmt")
  expect_equal(levels(fmt1), res)
  
})



test_that("a format object can be applied to a vector.", {
  
  
  res <- c("Label A", "Label B", "Other", "Label B")
  
  v1 <- c("A", "B", "C", "B")
  
  fmt1 <- value(condition(x == "A", "Label A"),
                condition(x == "B", "Label B"), 
                condition(TRUE, "Other"))
  
  
  a1 <- fapply(v1, fmt1)
  expect_equal(a1 , res)
  
  
  v2 <- c(1, 2, 3, 2)
  
  fmt2 <- value(condition(x == 1, "Label A"),
                condition(x == 2, "Label B"), 
                condition(TRUE, "Other"))
  
  
  a2 <- fapply(v2, fmt2)
  expect_equal(a2, res)
  
  
  fmt3 <- value(condition(x <= 1, "Label A"),
                condition(x > 1 & x <= 2, "Label B"), 
                condition(TRUE, "Other"))
  
  
  a3 <- fapply(v2, fmt3)
  expect_equal(a3, res)
  
  
  fmt4 <- value(condition(x == "A", 1),
                condition(x == "B", 2),
                condition(TRUE, 3))
  
  a4 <- fapply(v1, fmt4)
  expect_equal(a4,  c(1, 2, 3, 2))
  
  
})

test_that("labels() function works as expected", {
  
  
  res <- c("Label A", "Label B", "Other")
  
  
  fmt1 <- value(condition(x == "A", "Label A"),
                condition(x == "B", "Label B"), 
                condition(TRUE, "Other"))
  
  
  lbls <- labels(fmt1)

  expect_equal(lbls, res)
  
})


test_that("order parameter works as expected", {
  
  
  res <- c("Label B", "Label A","Other")
  
  
  fmt1 <- value(condition(x == "A", "Label A", order = 2),
                condition(x == "B", "Label B", order = 1), 
                condition(TRUE, "Other"))
  
  
  lbls <- labels(fmt1)
  
  expect_equal(lbls, res)
  
})

test_that("invalid order parameter generates error.", {
  
  
  res <- c("Label B", "Label A","Other")
  
  
  expect_error(value(condition(x == "A", "Label A", order = 6),
                condition(x == "B", "Label B", order = 1), 
                condition(TRUE, "Other")))
  
  
  
})


test_that("unassigned and NA values in value() function fall through unaltered.", {
  
  v1 <- c("A", "B", "C", "B", NA, 1)
  res <- c("Label A", "Label B", "C", "Label B", NA, "1")
  
  
  fmt1 <- value(condition(x == "A", "Label A"),
                condition(x == "B", "Label B"))
  
  
  fmtd <- fapply(v1, fmt1)
  
  expect_equal(fapply(v1, fmt1), res)

  
})

test_that("as.data.frame.fmt function works as expected", {
  
  
  fmt1 <- value(condition(x == "A", "Label A", order = 2),
                condition(x == "B", "Label B", order = 1), 
                condition(TRUE, "Other"))
  
  ex <- as.data.frame(fmt1)
  
  expect_equal(nrow(ex), 3)
  expect_equal(as.character(ex[1, "Order"]), "2")
  expect_equal(as.character(ex[3, "Label"]), "Other")
  
})


test_that("as.fmt.data.frame function works as expected", {
  
  o <- c(2, 1, NA)
  e <- c("x == \"A\"", "x == \"B\"", "TRUE")
  l <- c("Label A", "Label B", "Other")
  
  dat <- data.frame(Name = "Fork", Type = "U", 
                    Expression = e, Label = l, Order = o)

  
  fmt <- as.fmt(dat)

  
  v1 <- c("A", "B", "C", "B")
  
  res <- fapply(v1, fmt)
  
  expect_equal(length(res), 4)
  expect_equal(res[1], "Label A")
  expect_equal(res[2], "Label B")
  expect_equal(res[3], "Other")
  
})

test_that("as.fmt.data.frame function with NA order works as expected", {
  
  o <- c(NA, NA, NA)
  e <- c("x == \"A\"", "x == \"B\"", "TRUE")
  l <- c("Label A", "Label B", "Other")
  
  dat <- data.frame(Name = "Fork", Type = "U", 
                    Expression = e, Label = l, Order = o)
  
  
  fmt <- as.fmt(dat)
  
  
  v1 <- c("A", "B", "C", "B")
  
  res <- fapply(v1, fmt)
  
  expect_equal(length(res), 4)
  expect_equal(res[1], "Label A")
  expect_equal(res[2], "Label B")
  expect_equal(res[3], "Other")
  
})

test_that("print.fmt function works as expected", {
  
  
  fmt1 <- value(condition(x == "A", "Label A", order = 2),
                condition(x == "B", "Label B", order = 1), 
                condition(TRUE, "Other"))
  
  
  expect_output(print(fmt1, verbose = TRUE))
  expect_output(print(fmt1))
  
  
})


test_that("as.fmt.data.frame function works as expected with caps.", {
  
  o <- c(2, 1, NA)
  e <- c("x == \"A\"", "x == \"B\"", "TRUE")
  l <- c("Label A", "Label B", "Other")
  
  dat <- data.frame(NAME = "Fork", TyPE = "U", 
                    expression = e, LaBel = l, OrdeR = o)

  fmt <- as.fmt(dat)
  
  
  v1 <- c("A", "B", "C", "B")
  
  res <- fapply(v1, fmt)
  
  expect_equal(length(res), 4)
  expect_equal(res[1], "Label A")
  expect_equal(res[2], "Label B")
  expect_equal(res[3], "Other")
  
})


test_that("values function works with range.", {
  
  
  res <- c("Label A", "Label B", "Other", "Label B")
  
  v1 <- c(22, 26.3, 23, 25)


  fmt3 <- value(condition(x > 22 & x <= 25, "Label B"), 
                condition(TRUE, "Other"))
  
  
  a3 <- fapply(v1, fmt3)
  expect_equal(a3, c("Other", "Other", "Label B", "Label B"))
  
})

