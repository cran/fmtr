% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/widths.R
\name{widths}
\alias{widths}
\alias{widths<-}
\title{Get or set column widths for a data frame}
\usage{
widths(x)

widths(x) <- value
}
\arguments{
\item{x}{A data frame or tibble}

\item{value}{A named list of widths.  The widths must be positive integers
greater than zero.}
}
\value{
A named list of widths. The widths must be positive integers
greater than zero.
}
\description{
The \code{widths} function extracts all assigned widths from a 
data frame, and returns them in a named list. The function also
assigns widths from a named list.
}
\details{
If widths are assigned to the "width" attributes of the data frame
columns, the \code{widths} function will extract those widths.  The 
function will return the widths in a named list, where the names
correspond to the name of the column that the width was assigned to.
If a column does not have a width attribute assigned, that column
will not be included in the list. 

When used on the receiving side of an assignment, the function will assign
widths to a data frame.  The widths should be in a named list, where
each name corresponds to the data frame column to assign the width to.
  
Finally, if you wish to clear out the width attributes, assign
a NULL value to the \code{widths} function.
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

# Assign widths
widths(df1) <- list(mpg = 12, cyl = 10) 

# Display formatted data
fdata(df1)
#                            mpg        cyl
# Mazda RX4                 21.0          6
# Mazda RX4 Wag             21.0          6
# Datsun 710                22.8          4
# Hornet 4 Drive            21.4          6
# Hornet Sportabout         18.7          8

# View assigned widths
widths(df1)
# $mpg
# [1] 12
# 
# $cyl
# [1] 10

# Clear widths
widths(df1) <- NULL

# Confirm widths are cleared
widths(df1)
# list()
}
\seealso{
\code{\link{fdata}} to display formatted data, 
\code{\link{value}} to create user-defined formats, and 
\code{\link{fapply}} to apply formats to a vector.
}
