## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Create format catalog
#  c1 <- fcat(num_fmt  = "%.1f",
#             label_fmt = value(condition(x == "A", "Label A"),
#                               condition(x == "B", "Label B"),
#                               condition(TRUE, "Other")),
#             date_fmt = "%d%b%Y")
#  
#  # Use formats in the catalog
#  fapply(2, c1$num_fmt)
#  # [1] "2.0"
#  
#  fapply(c("A", "B", "C", "B"), c1$label_fmt)
#  # [1] "Label A" "Label B" "Other"   "Label B"
#  
#  fapply(Sys.Date(), c1$date_fmt)
#  # [1] "22Jul2021"
#  
#  # Convert to a data frame
#  dat <- as.data.frame(c1)
#  dat
#  #        Name Type Expression   Label Order
#  # 1   num_fmt    S       %.1f            NA
#  # 2 label_fmt    U   x == "A" Label A    NA
#  # 3 label_fmt    U   x == "B" Label B    NA
#  # 4 label_fmt    U       TRUE   Other    NA
#  # 5  date_fmt    S     %d%b%Y            NA
#  
#  # Save format catalog for later use
#  write.fcat(c1, tempdir())
#  

