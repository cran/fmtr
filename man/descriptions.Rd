% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/descriptions.R
\name{descriptions}
\alias{descriptions}
\alias{descriptions<-}
\title{Get or set descriptions for data frame columns}
\usage{
descriptions(x)

descriptions(x) <- value
}
\arguments{
\item{x}{A data frame or tibble}

\item{value}{A named list of description values.}
}
\value{
A named list of description values.
}
\description{
The \code{descriptions} function extracts all assigned description
attributes from a 
data frame, and returns them in a named list. The function also
assigns description attributes from a named list.
}
\details{
If descriptions are assigned to the "description" 
attributes of the data frame
columns, the \code{descriptions} function will extract those values.  The 
function will return the description values in a named list, 
where the names
correspond to the name of the column that the description was assigned to.
If a column does not have a description attribute assigned, that column
will not be included in the list. 

When used on the receiving side of an assignment, the function will assign
descriptions to a data frame.  The description values 
should be in a named list, where
each name corresponds to the name of the data frame column to assign
values to.

Finally, if you wish to clear out the description attributes, assign
a NULL value to the \code{descriptions} function.
}
\examples{
# Take subset of data
df1 <- mtcars[1:5, c("mpg", "cyl") ]

# Print current state
print(df1)
#                    mpg cyl
# Mazda RX4         21.0   6
# Mazda RX4 Wag     21.0   6
# Datsun 710        22.8   4
# Hornet 4 Drive    21.4   6
# Hornet Sportabout 18.7   8

# Assign descriptions
descriptions(df1) <- list(mpg = "Miles per Gallon", cyl = "Cylinders")

# Display descriptions
descriptions(df1)
# $mpg
# [1] "Miles per Gallon"
# 
# $cyl
# [1] "Cylinders"

# Clear descriptions
descriptions(df1) <- NULL

# Confirm descriptions are cleared
descriptions(df1)
# list()
}
\seealso{
\code{\link{fdata}} to display formatted data, 
\code{\link{value}} to create user-defined formats, and 
\code{\link{fapply}} to apply formatting to a vector.
}
