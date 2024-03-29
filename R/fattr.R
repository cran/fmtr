
# Format attributes -------------------------------------------------------


#' @title Set formatting attributes
#' @description Assign formatting attributes to a vector. 
#' @details 
#' The \code{fattr} function is a convenience function for assigning 
#' formatting attributes to a vector.  The function accepts parameters
#' for format, width, and justify.  Any formatting attributes assigned 
#' can be applied using \code{\link{fapply}} or
#' \code{\link{fdata}}.
#' @param x The vector or data frame column to assign attributes to.
#' @param format The format to assign to the format attribute.  The format 
#' can be a formatting string, a named vector decode, a vectorized
#' formatting function, or a formatting list. 
#' @param width The desired width of the formatted output. 
#' @param justify Justification of the output vector. Valid values are 
#' 'none', 'left', 'right', 'center', or 'centre'. 
#' @param label A label string to assign to the vector.  This parameter 
#' was added for convenience, as the label is frequently assigned at the 
#' same time the formatting attributes are assigned.
#' @param description A description string to assign to the vector. This parameter 
#' was added for convenience, as the description is frequently assigned at the 
#' same time the formatting attributes are assigned.
#' @param keep Whether to keep any existing formatting attributes and 
#' transfer to the new vector.  Default value is TRUE.
#' @return The vector with formatting attributes assigned.
#' @seealso \code{\link{fdata}} to apply formats to a data frame, 
#'  \code{\link{fapply}} to apply formats to a vector.  See
#' \link{FormattingStrings} for documentation on formatting strings.
#' @export
#' @examples
#' # Create vector
#' a <- c(1.3243, 5.9783, 2.3848)
#' 
#' # Assign format attributes
#' a <- fattr(a, format = "%.1f", width = 10, justify = "center")
#' 
#' # Apply format attributes
#' fapply(a)
#' # [1] "   1.3    " "   6.0    " "   2.4    "
fattr <- function(x, format = NULL, width = NULL, justify = NULL, 
                  label = NULL, description = NULL, keep = TRUE) {
  
  if (!any(class(format) %in% c("NULL", "character", "fmt", 
                            "fmt_lst", "function")))
      stop(paste0("class of format parameter value is invalid:", 
                  class(format)))
  
  if (is.null(width) == FALSE) {
   if (is.numeric(width) == FALSE) 
     stop("width parameter must be numeric.")
    
   if (width <= 0)
     stop("width parameter must be a positive integer")
    
  }
  
  if (is.null(justify) == FALSE) {
   
    if (!justify %in% c("left", "right", "center", "centre", "none"))
      stop(paste("justify parameter is invalid. Valid values are 'left',",
                 "'right', 'center', 'centre', or 'none'."))
  }
  
  if (!(is.null(format) & keep == TRUE))
    attr(x, "format") <- format
  if (!(is.null(width) & keep == TRUE))
    attr(x, "width") <- width
  if (!(is.null(justify) & keep == TRUE))
    attr(x, "justify") <- justify
  if (!(is.null(label) & keep == TRUE))
    attr(x, "label") <- label
  if (!(is.null(description) & keep == TRUE))
    attr(x, "description") <- description
  
  return(x)
  
}


#' @title Set formatting attributes
#' @description Assign formatting attributes to a vector 
#' @details 
#' The \code{fattr} function is a convenience function for assigning 
#' formatting attributes to a vector.  The function accepts a named list of
#' formatting attributes.  Valid names are 'format', 'width', 'justify',
#' 'label' and 'description'.
#' See \code{\link{fattr}} for additional details.  
#' @param x The vector or data frame column to assign attributes to.
#' @param value A named vector of attribute values.
#' @seealso \code{\link{fdata}} to apply formats to a data frame, 
#'  \code{\link{fapply}} to apply formats to a vector.
#' @export
#' @examples
#' # Create vector
#' a <- c(1.3243, 5.9783, 2.3848)
#' 
#' # Assign format attributes
#' fattr(a) <- list(format = "%.1f")
#' 
#' # Apply format attributes
#' fapply(a)
#' # [1] "1.3" "6.0" "2.4"
"fattr<-" <- function(x, value) {
  
  if (!is.null(value[["format"]])) {
    
    format <- value[["format"]]
    if (!any(class(format) %in% c("NULL", "character", "fmt",
                              "fmt_lst", "function")))
      stop(paste0("class of format parameter value is invalid: ", 
                  class(format)))
  }
  
  
  if (!is.null(value[["width"]])) {
    
    width <- value[["width"]]
    
    if (is.numeric(width) == FALSE) 
      stop("width parameter must be numeric.")
    
    if (width <= 0)
      stop("width parameter must be a positive integer.")
     
  }
  
  
  if (!is.null(value[["justify"]])) {
    justify <- value[["justify"]]
      

    if (!justify %in% c("left", "right", "center", "centre", "none"))
      stop(paste("justify parameter is invalid. Valid values are 'left',",
                 "'right', 'center', 'centre', or 'none'."))
    
  }
  

    attr(x, "format") <- value[["format"]]
    attr(x, "width") <- value[["width"]]
    attr(x, "justify") <- value[["justify"]]
    attr(x, "label") <- value[["label"]]
    attr(x, "description") <- value[["description"]]
  
  return(x)
  
}


