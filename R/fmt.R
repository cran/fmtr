
# Format Definition -------------------------------------------------------


#' @title
#' Create a user-defined format
#' 
#' @description 
#' The \code{value} function creates a user-defined format. 
#' 
#' @details 
#' The \code{value} function creates a user defined format object, in a manner
#' similar to a SAS® format.  The \code{value} function accepts 
#' one or more \code{condition} arguments that define the format.  The 
#' conditions map an R expression to a label.  When applied, the format 
#' will return the label corresponding to the first true expression.
#' 
#' The format object is an S3 class of type "fmt". When the object is created,
#' the \strong{levels} attribute of the object will be set with a vector 
#' of values
#' assigned to the \strong{labels} property of the \code{condition} arguments.  
#' These labels may be accessed either from the \code{levels} function or the 
#' \code{labels} function.  If no order has been assigned to the conditions,
#' the labels will be returned in the order the conditions were passed to the
#' \code{value} function.  If an order has been assigned to the conditions,
#' the labels will be returned in the order specified.
#' 
#' The format object may be applied to a vector using the \code{fapply}
#' function.  See \code{\link{fapply}} for further details.
#' 
#' Note that the label may also be a string format.  That means a 
#' user-defined format can be used to apply string formats conditionally.
#' This capability is useful when you want to conditionally format 
#' data values.
#'
#' @param ... One or more \code{\link{condition}} functions.
#' @param log Whether to log the creation of the format.  Default is
#' TRUE. This parameter is used internally.
#' @param as.factor If TRUE, the \code{\link{fapply}} function will return
#' the result as an ordered factor.  Otherwise, the result will be returned
#' as a vector.  Default is FALSE.
#' @return The new format object.
#' @seealso \code{\link{condition}} to define a condition,
#' \code{\link{levels}} or \code{\link{labels.fmt}} to access the labels, and 
#' \code{\link{fapply}} to apply the format to a vector.
#' @family fmt
#' @export
#' @examples 
#' ## Example 1: Character to Character Mapping ##
#' # Set up vector
#' v1 <- c("A", "B", "C", "B")
#' 
#' # Define format
#' fmt1 <- value(condition(x == "A", "Label A"),
#'               condition(x == "B", "Label B"), 
#'               condition(TRUE, "Other"))
#'               
#' # Apply format to vector
#' fapply(v1, fmt1)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' 
#' ## Example 2: Character to Integer Mapping ##
#' fmt2 <- value(condition(x == "A", 1),
#'               condition(x == "B", 2),
#'               condition(TRUE, 3))
#' 
#' # Apply format to vector
#' fapply(v1, fmt2)
#' # [1] 1 2 3 2
#' 
#' ## Example 3: Categorization of Continuous Variable ##
#' # Set up vector
#' v2 <- c(1, 6, 11, 7)
#' 
#' # Define format
#' fmt3 <- value(condition(x < 5, "Low"),
#'               condition(x >= 5 & x < 10, "High"), 
#'               condition(TRUE, "Out of range"))
#'               
#' # Apply format to vector
#' fapply(v2, fmt3)
#' # [1] "Low"          "High"         "Out of range" "High" 
#' 
#' ### Example 4: Conditional formatting
#' v3 <- c(10.398873, 12.98762, 0.5654, 11.588372)
#' 
#' fmt4 <- value(condition(x < 1, "< 1.0"),
#'               condition(TRUE, "%.2f"))
#'               
#' fapply(v3, fmt4)
#' # [1] "10.40" "12.99" "< 1.0" "11.59"
#' 
value <- function(..., log = TRUE, as.factor = FALSE) {
  
  if (...length() == 0)
    stop("At least one condition is required.")
  
  # Create new structure of class "fmt"
  x <- structure(list(...), class = c("fmt"))    
  
  # Assign labels to the levels attribute
  attr(x, "levels") <- labels(x)
  attr(x, "as.factor") <- as.factor
  
  if (log_output() & log) {
    log_logr(x)
    print(x) 
  }

  return(x)

}

#' @title
#' Define a condition for a user-defined format
#' 
#' @description 
#' The \code{condition} function creates a condition for a user-defined format.
#' It is typically used in conjunction with the \code{\link{value}} function. 
#' 
#' @details 
#' The \code{condition} function creates a condition as part of a format 
#' definition.  The format is defined using the \code{\link{value}} 
#' function.  The condition is defined as an expression/label pair.  The 
#' expression parameter can be any valid R expression.   The label parameter
#' can be any valid literal.  Conditions are evaluated in the order they 
#' are assigned.  A default condition is created by assigning the expression
#' parameter to TRUE.  If your data can contain missing values, it is 
#' recommended that you test for those values first.  Any data values that 
#' do not meet one of the conditions will fall through the format as-is.
#' 
#' The condition object is an S3 class of type "fmt_cond". The condition 
#' labels can be extracted from the format using the \code{labels} function.
#' 
#' The format object may be applied to a vector using the \code{fapply}
#' function.  See \code{\link{fapply}} for further details.
#'
#' @param expr A valid R expression.  The value in the expression is identified
#' by the variable 'x', i.e.  x == 'A' or x > 3 & x < 6.  The expression 
#' should not be quoted.  The expression parameter will accept equality, 
#' relational, and logical operators.  It will also accept numeric or string
#' literals.  String literals should be quoted.  It will not accept functions 
#' or any expression that includes a comma.  For these more complex operations, 
#' it is best to use a vectorized function.  See \code{\link{fapply}} for an example of 
#' a vectorized function.
#' @param label A label to be assigned if the expression is TRUE.  The label 
#' can any valid literal value.  Typically, the label will be a character 
#' string.  However, the label parameter does not restrict the data type.
#' Meaning, the label could also be a number, date, or other R object type.
#' The label may also be a string format, which allows you to perform
#' conditional formatting.
#' @param order An optional integer order number. When used, this parameter 
#' will effect the order of the labels returned from the 
#' \code{\link{labels.fmt}} function.  The purpose of the parameter is to control
#' ordering of the format labels independently of the order they are assigned
#' in the conditions.  The order parameter is useful when you are using the format
#' labels to assign ordered levels in a factor.  
#' @return The new condition object.
#' @seealso \code{\link{fdata}} to apply formatting to a data frame,
#' \code{\link{value}} to define a format,
#' \code{\link{levels}} or \code{\link{labels.fmt}} to access the labels, and 
#' \code{\link{fapply}} to apply the format to a vector.
#' @family fmt
#' @export
#' @examples 
#' # Set up vector
#' v1 <- c("A", "B", "C", "B")
#' 
#' # Define format
#' fmt1 <- value(condition(x == "A", "Label A"),
#'               condition(x == "B", "Label B"), 
#'               condition(TRUE, "Other"))
#'               
#' # Apply format to vector
#' v2 <- fapply(v1, fmt1)
#' v2
#' # [1] "Label A" "Label B" "Other"   "Label B"
condition <- function(expr, label, order = NULL) {
  
  y <- structure(list(), class = c("fmt_cnd"))    
  
  y$expression <- substitute(expr, env = environment())
  y$label <- label
  y$order <- order
  
  return(y)
  
}
  


# Conversion Functions ----------------------------------------------------

#' @title Generic casting method for formats
#' @description A generic method for casting objects to
#' a format.  Individual objects will inherit from this function.
#' @param x The object to cast.
#' @return A formatting object, created using the information in the 
#' input object.
#' @family fmt
#' @export
as.fmt <- function (x) {
  UseMethod("as.fmt", x)
}


#' @title Casts a format to a data frame
#' @description Cast a format object to a data frame.  This function is
#' a class-specific implementation of the the generic \code{as.data.frame} 
#' method.
#' @param x An object of class "fmt".
#' @param row.names Row names of the return data frame.  Default is NULL.
#' @param optional TRUE or FALSE value indicating whether converting to
#' syntactic variable names is options.  In the case of formats, the 
#' resulting data frame will always be returned with syntactic names, and 
#' this parameter is ignored.
#' @param ... Any follow-on parameters.
#' @param name An optional name for the format.  By default, the name of 
#' the variable holding the format will be used.
#' @family fmt
#' @export
as.data.frame.fmt <- function(x, row.names = NULL, optional = FALSE, ...,
                              name=deparse(substitute(x, 
                                              env = environment()))) {
  
  if (all(class(x) != "fmt"))
    stop("Parameter x must be an object of class 'fmt'.")
  
  e <- c()
  l <- c()
  o <- c()
  
  f <- FALSE
  isFactor <- attr(x, "as.factor")
  if (!is.null(isFactor)) {
    f <- isFactor
  }
  
  for (cond in x) {
    e[[length(e) + 1]] <- paste(deparse(cond$expression), collapse = " ")
    l[[length(l) + 1]] <- cond$label
    o[[length(o) + 1]] <- ifelse(is.null(cond$order), NA, cond$order)
  }
  
  e <- unlist(e)
  l <- unlist(l)
  o <- unlist(o)
  
  dat <- data.frame(Name = name, Type = "U", 
                    Expression = e, Label = l, Order = o, 
                    Factor = f,
                    stringsAsFactors = FALSE)
  
  if (!is.null(row.names))
    rownames(dat) <- row.names
  
  return(dat)
  
}

#' @title Convert a data frame to a user-defined format 
#' @description This function takes a data frame as input
#' and converts it to a user-defined format based on the information contained
#' in the data frame. The data frame should have 5 columns: "Name", "Type",
#' "Expression", "Label" and "Order".  
#' @details 
#' The \code{as.fmt.data.frame} function converts a data frame to a 
#' user-defined format. 
#' 
#' To understand the structure of the input data frame, create a user-defined 
#' format and use the \code{as.data.frame} method to convert the format 
#' to a data frame.
#' Then observe the columns and organization of the data.
#' @section Input Data Frame Specifications:
#' The input data frame should contain the following columns:
#' \itemize{
#' \item \strong{Name}: The name of the format
#' \item \strong{Type}: The type of format.  See the type codes below.
#' \item \strong{Expression}: The formatting expression. The expression will 
#' hold different types of values depending on the format type.  Within the
#' data frame, this expression is stored as a character string.
#' \item \strong{Label}: The label for user-defined, "U" type formats.
#' \item \strong{Order}: The order for user-defined, "U" type formats. 
#' \item \strong{Factor}: An optional column for "U" type formats that sets
#' the "as.factor" parameter. Valid values are TRUE, FALSE, or NA. 
#' }
#' Any additional columns will be ignored.  Column names are case-insensitive.
#' 
#' Valid values for the "Type" column are as follows:
#' \itemize{
#' \item \strong{U}: User Defined List created with the \code{\link{value}} 
#' function.
#' \item \strong{S}: A formatting string of formatting codes.  
#' See \link{FormattingStrings}.
#' \item \strong{F}: A vectorized function.
#' \item \strong{V}: A named vector lookup.}
#' 
#' The "Label", "Order", and "Factor" columns are used only for a type "U", user-defined
#' format created with the \code{\link{value}} function.
#' @param x The data frame to convert.
#' @return A format catalog based on the information contained in the 
#' input data frame.
#' @examples 
#' # Create a user-defined format 
#' f1 <- value(condition(x == "A", "Label A"),
#'             condition(x == "B", "Label B"),
#'             condition(TRUE, "Other"))
#'            
#' # Convert user-defined format to data frame to view the structure
#' df <- as.data.frame(f1)
#' print(df)
#' 
#' # Name Type Expression   Label Order Factor
#' # 1 f1    U   x == "A" Label A    NA  FALSE
#' # 2 f1    U   x == "B" Label B    NA  FALSE
#' # 3 f1    U       TRUE   Other    NA  FALSE
#' 
#' # Convert data frame back to a user-defined format 
#' f2 <- as.fmt(df)
#' 
#' # Use re-converted format
#' fapply(c("A", "B", "C", "B"), f2)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' @family fmt
#' @export
as.fmt.data.frame <- function(x) {
  
  if ("tbl_df" %in% class(x))
    x <- as.data.frame(x, stringsAsFactors = FALSE)
  
  if (!"data.frame" %in% class(x))
    stop("Input data must be a data frame")
  
  names(x) <- titleCase(names(x))
  
  hasFactor <- ifelse("Factor" %in% names(x), TRUE, FALSE) 
  
  isFactor <- FALSE
  if (hasFactor) {
    if ("logical" %in% class(x[["Factor"]])) {
      isFactor <- all(x[["Factor"]] == TRUE)
    }
  }
  
  if (is.na(isFactor)) {
    isFactor <- FALSE 
  }
  
  ret <- list()
  
  for (i in seq_len(nrow(x))) {
    
    y <- structure(list(), class = c("fmt_cnd"))    
    
    y$expression <- str2lang(as.character(x[i, "Expression"]))
    if (all(class(x[i, "Label"]) %in% 
            c("character", "numeric", "integer", "logical", "Date"))) {
      y$label <- x[i, "Label"]
    } else {
      y$label <- as.character(x[i, "Label"])
    }
    if (all(class(x[i, "Order"]) %in% 
            c("character", "numeric", "integer"))) {
      y$order <- x[i, "Order"]
    } else  {
      y$order <- as.character(x[i, "Order"]) 
    }
    
    ret[[length(ret) + 1]] <- y
  }
  
  class(ret) <- "fmt"
  attr(ret, "levels") <- labels(ret)
  attr(ret, "as.factor") <- isFactor
  
  return(ret)
  
}



# Utilities ---------------------------------------------------------------

#' @title
#' Extract labels from a user-defined format
#' 
#' @description 
#' The \code{labels} function creates a vector of labels associated with 
#' a user-defined format. 
#' 
#' @details 
#' The \code{condition} function creates a condition as part of a format 
#' definition.  Each condition has a label as part of its definition.
#' The \code{labels} function extracts the labels from the conditions and
#' returns them as a vector.  While the labels will typically be of type
#' character, they can be of any data type. See the \code{\link{condition}}
#' function help for further details.  
#'
#' @param object A user-defined format of class "fmt".
#' @param ... Following arguments.
#' @return A vector of label values.
#' @seealso \code{\link{value}} to define a format,
#' \code{\link{condition}} to define the conditions for a format, and 
#' \code{\link{fapply}} to apply the format to a vector.
#' @family fmt
#' @export
#' @examples 
#' # Define format
#' fmt1 <- value(condition(x == "A", "Label A"),
#'               condition(x == "B", "Label B"), 
#'               condition(TRUE, "Other"))
#'               
#' # Extract labels
#' labels(fmt1)
#' # [1] "Label A" "Label B" "Other" 
labels.fmt <- function(object, ...) {
  
  ret <- NULL
  o <- c()
  r <- c()
  
  for (i in seq_along(object)) {
    
    if (is.null( object[[i]][["order"]])) {
      r[length(r) + 1] <- object[[i]][["label"]]
    } else {
      tmp <- object[[i]][["order"]]
      
      if (is.na(tmp))
        r[length(r) + 1] <- object[[i]][["label"]]
      else if (tmp > 0 & tmp <= length(object))
        o[tmp] <- object[[i]][["label"]]
      else
        stop(paste("Order parameter invalid:", tmp))
      
    }
  }

  ret <- c(o, r)

  
  return(ret)
  
}


#' @title
#' Determine whether an object is a user-defined format
#' 
#' @description 
#' The \code{is.format} function can be used to determine if an object is a 
#' user-defined format of class "fmt". 
#' 
#' @details 
#' The \code{is.format} function returns TRUE if the object passed is a 
#' user-defined format.  User-defined formats are defined using the \code{value}
#' function. See the \code{\link{value}}
#' function help for further details.  
#'
#' @param x A user-defined format of class "fmt".
#' @return A logical value or TRUE or FALSE.
#' @seealso \code{\link{value}} to define a format,
#' \code{\link{condition}} to define the conditions for a format, and 
#' \code{\link{fapply}} to apply the format to a vector.
#' @family fmt
#' @export
#' @examples 
#' # Define format
#' fmt1 <- value(condition(x == "A", "Label A"),
#'               condition(x == "B", "Label B"), 
#'               condition(TRUE, "Other"))
#'               
#' # Check for format
#' is.format(fmt1)
#' # [1] TRUE
#' 
#' is.format("A")
#' # [1] FALSE
is.format <- function(x) {
 
  ret <- FALSE
  if (any(class(x) == "fmt"))
    ret <- TRUE
  
  return(ret)
}



#' @title Print a format
#' @description Prints a format object.  This function is
#' a class-specific implementation of the the generic \code{print} method.
#' @param x An object of class "fmt".
#' @param ... Any follow-on parameters to the print function.
#' @param name The name of the format to print. By default, the variable
#' name that holds the format will be used.
#' @param verbose Turn on or off verbose printing mode.  Verbose mode will
#' print object as a list.  Otherwise, the object will be printed as a table.
#' @family fmt
#' @export
print.fmt <- function(x, ..., name = deparse(substitute(x, env = environment())), 
                      verbose = FALSE) {
  
  if (!any(class(x) == "fmt"))
    stop("Class must be of type 'fmt'.")
  
  if (verbose == TRUE) {
    print(unclass(x))
  } else {


    grey60 <- make_style(grey60 = "#999999")
    cat(grey60("# A user-defined format: " %+% 
                 as.character(length(x)) %+% " conditions\n")) 
    if (!is.null(attr(x, "as.factor"))) {
      if (attr(x, "as.factor") == TRUE) { 
        cat(grey60("- as.factor: TRUE\n"))
      }
    }
    
    dat <- as.data.frame(x, name = name, stringsAsFactors = FALSE)
    
    dat$Factor <- NULL
    
    print(dat)
  }
  
  
  invisible(x)
}




#' @noRd
titleCase <- Vectorize(function(x) {
  
  # Split input vector value
  s <- strsplit(x, " ")[[1]]
  
  # Perform title casing and recombine
  ret <- paste(toupper(substring(s, 1,1)), tolower(substring(s, 2)),
        sep="", collapse=" ")
  
  return(ret)
  
}, USE.NAMES = FALSE)


# Testing -----------------------------------------------------------------



# v1 <- c("A", "B", "C", "B")
# 
# fmt1 <- value(condition(x == "A", "Label A"),
#               condition(x == "B", "Label B"),
#               condition(TRUE, "Other"))
# 
# fmt1
# fapply(fmt1, v1)

#
# 
# 
# v2 <- c(1, 2, 3, 2)
# 
# fmt2 <- value(condition(x == 1, "Label A"),
#               condition(x == 2, "Label B"), 
#               condition(TRUE, "Other"))
# 
# 
# fapply(fmt2, v2)
# 
# 
# fmt3 <- value(condition(x <= 1, "Label A"),
#               condition(x > 1 & x <= 2, "Label B"), 
#               condition(TRUE, "Other"))
# 
# 
# fapply(fmt3, v2)
# 
# 
# fmt4 <- value(condition(x == "A", 1),
#               condition(x == "B", 2),
#               condition(TRUE, 3))
# 
# fapply(fmt4, v1)


