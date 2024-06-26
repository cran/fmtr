
# Formatting Catalog Definition -------------------------------------------


#' @title Create a format catalog
#' @description A format catalog is a collection of formats.  A format
#' collection allows you to manage and store formats as a unit.  The 
#' \code{fcat} function defines the format catalog.
#' @details A format catalog is an S3 object of class "fcat".  The purpose of 
#' the catalog is to combine related formats, and allow you to manipulate all
#' of them as a single object.  The format catalog can be saved to/from a file 
#' using the \code{\link{write.fcat}} and \code{\link{read.fcat}} functions. 
#' A format catalog can also 
#' be converted to/from a data frame using the \code{\link{as.fcat.data.frame}}
#' and \code{\link{as.data.frame.fcat}} functions.  Formats are accessed in the
#' catalog using list syntax. 
#' 
#' A format catalog can be used to assign formats to a data frame
#' or tibble using the \code{\link{formats}} function. Formats may be applied
#' using the \code{\link{fdata}} and \code{\link{fapply}} functions.
#' 
#' A format catalog may contain any type of format except a formatting list.
#' Allowed formats include a formatting string, a named vector lookup, a 
#' user-defined format, and a vectorized formatting function.  A formatting 
#' list can be converted to a format catalog and saved independently.  See the 
#' \code{\link{flist}} function for more information on formatting lists.
#' 
#' @param ... A set of formats. Pass the formats as a name/value pair.  Multiple
#' name/value pairs are separated by a comma.
#' @param log Whether to log the creation of the format catalog.  Default is
#' TRUE. This parameter is used internally.
#' @return The format catalog object.
#' @seealso \code{\link{formats}} function for assigning formats to a data 
#' frame, and the \code{\link{fdata}} and \code{\link{fapply}} functions for
#' applying formats.
#' @family fcat
#' @examples 
#' # Create format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#' 
#' # Use formats in the catalog
#' fapply(2, c1$num_fmt)
#' # [1] "2.0"
#' 
#' fapply(c("A", "B", "C", "B"), c1$label_fmt)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' 
#' fapply(Sys.Date(), c1$date_fmt)
#' # [1] "06Jan2024"
#' 
#' @export
fcat <- function(..., log = TRUE) {
  
  # Create new structure of class "fcat"
  f <- structure(list(...), class = c("fcat", "list"))
  
  
  if (log_output() & log) {
    log_logr(f)
    print(f) 
  }

  return(f)
  
}



# Conversion Functions -----------------------------------------------------

#' @title Generic casting method for format catalogs
#' @description A generic method for casting objects to
#' a format catalog.  Individual objects will inherit from this function.
#' @param x The object to cast.
#' @return A format catalog, created using the information in the 
#' input object.
#' @seealso For class-specific methods, see \code{\link{as.fcat.data.frame}},
#' \code{\link{as.fcat.list}}, and \code{\link{as.fcat.fmt_lst}}.
#' @family fcat
#' @export
as.fcat <- function (x) {
  UseMethod("as.fcat", x)
}

#' @title Convert a data frame to a format catalog
#' @description This function takes a data frame as input
#' and converts it to a format catalog based on the information contained
#' in the data frame. The data frame should have 5 columns: "Name", "Type",
#' "Expression", "Label" and "Order".  
#' @details 
#' The \code{as.fcat.data.frame} converts a data frame to a format catalog. A
#' corresponding conversion for class "tbl_df" converts a tibble.
#' 
#' To understand the structure of the input data frame, create a format and use
#' the \code{as.data.frame} method to convert the format to a data frame.
#' Then observe the columns and organization of the data.
#' @section Input Data Frame Specifications:
#' The input data frame should contain the following columns:
#' \itemize{
#' \item \strong{Name}: The name of the format
#' \item \strong{Type}: The type of format.  See the type codes below.
#' \item \strong{Expression}: The formatting expression. The expression will 
#' hold different types of values depending on the format type.
#' \item \strong{Label}: The label for user-defined, "U" type formats.
#' \item \strong{Order}: The order for user-defined, "U" type formats. 
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
#' The "Label" and "Order" columns are used only for a type "U", user-defined
#' format created with the \code{\link{value}} function.
#' @param x The data frame to convert.
#' @return A format catalog based on the information contained in the 
#' input data frame.
#' @family fcat
#' @examples 
#' # Create a format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d-%b-%Y")
#'            
#' # Convert catalog to data frame to view the structure
#' df <- as.data.frame(c1)
#' print(df)
#' #       Name Type Expression   Label Order
#' # 1   num_fmt    S       %.1f            NA
#' # 2 label_fmt    U   x == "A" Label A    NA
#' # 3 label_fmt    U   x == "B" Label B    NA
#' # 4 label_fmt    U       TRUE   Other    NA
#' # 5  date_fmt    S   %d-%b-%Y            NA
#' 
#' # Convert data frame back to a format catalog
#' c2 <- as.fcat(df)
#' c2
#' # # A format catalog: 3 formats
#' # - $date_fmt: type S, "%d-%b-%Y"
#' # - $label_fmt: type U, 3 conditions
#' # - $num_fmt: type S, "%.1f"
#' 
#' # Use re-converted catalog
#' fapply(123.456, c2$num_fmt)
#' # [1] "123.5"
#' 
#' fapply(c("A", "B", "C", "B"), c2$label_fmt)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' 
#' fapply(Sys.Date(), c2$date_fmt)
#' # [1] "07-Jan-2024"
#' @export
as.fcat.data.frame <- function(x) {
  
  names(x) <- titleCase(names(x))
  
  s <- split(x, x$Name)
  ret <- fcat(log = FALSE)
  for (df in s) {
    
    nm <- as.character(df[1, "Name"])
    typ <- as.character(df[1, "Type"])
    
    if (typ == "U") {
      ret[[nm]] <- as.fmt(df)
    } else if (typ == "S") {
      ret[[nm]] <- as.character(df[1, "Expression"])
    } else if (typ == "F") {
      ret[[nm]] <- eval(str2lang(as.character(df[1, "Expression"])))
    } else if (typ == "V") {
      ret[[nm]] <- eval(str2lang(as.character(df[1, "Expression"])))
    }
  }

  
  return(ret)
  
}

#' @title Convert a tibble to a format catalog
#' @inherit as.fcat.data.frame
#' @export
as.fcat.tbl_df <- function(x) {
  
 ret <- as.fcat.data.frame(as.data.frame(x, stringsAsFactors = FALSE))
 
 return(ret)
}


#' @title Convert a list to a format catalog
#' @description The \code{as.fcat.list} function converts a list of formats
#' to a format catalog.  Items in the list must be named.  
#' @param x The list to convert.  List must contained named formats.
#' @return A format catalog based on the formats contained in the input list.
#' @family fcat
#' @export
as.fcat.list <- function(x) {
  

  class(x) = c("fcat", "list")
    
  ret <- x
  
  
  return(ret)
}

#' @title Convert a formatting list to a format catalog
#' @description The \code{as.fcat.list} function converts a formatting list
#' to a format catalog.  For additional information on formatting lists,
#' see \code{\link{flist}}.
#' @param x The formatting list to convert.
#' @return A format catalog based on the formats contained in the input
#' formatting list.
#' @family fcat
#' @export
as.fcat.fmt_lst <- function(x) {
  

  ret <- x$formats
  
  class(ret) <- c("fcat", "list")

  
  return(ret)
}

#' @title Convert a format catalog to a data frame
#' @description This function takes the information stored in a format 
#' catalog, and converts it to a data frame.  This data frame is 
#' useful for storage, editing, saving to a spreadsheet, etc.  The 
#' data frame shows the name of the formats, their type, and the format 
#' expression.  For user-defined formats, the data frame populates 
#' additional columns for the label and order.
#' @param x The format catalog to convert.
#' @param row.names Row names of the return data frame.  Default is NULL.
#' @param optional TRUE or FALSE value indicating whether converting to
#' syntactic variable names is desired.  In the case of formats, the 
#' resulting data frame will always be returned with syntactic names, and 
#' this parameter is ignored.
#' @param ... Any follow-on parameters.
#' @return A data frame that contains the values stored in the format 
#' catalog.  
#' @family fcat
#' @examples 
#' # Create a format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#'            
#' # Convert catalog to data frame to view the structure
#' df <- as.data.frame(c1)
#' print(df)
#' #       Name Type Expression   Label Order
#' # 1   num_fmt    S       %.1f            NA
#' # 2 label_fmt    U   x == "A" Label A    NA
#' # 3 label_fmt    U   x == "B" Label B    NA
#' # 4 label_fmt    U       TRUE   Other    NA
#' # 5  date_fmt    S     %d%b%Y            NA
#' 
#' # Convert data frame back to a format catalog
#' c2 <- as.fcat(df)
#' c2
#' # # A format catalog: 3 formats
#' # - $date_fmt: type S, "%d%b%Y"
#' # - $label_fmt: type U, 3 conditions
#' # - $num_fmt: type S, "%.1f"
#' @export
as.data.frame.fcat <- function(x, row.names = NULL, optional = FALSE, ...) {
  
  tmp <- list()

  for (nm in names(x)) {
    
    if (any(class(x[[nm]]) == "fmt")) {
      
      tmp[[nm]] <- as.data.frame.fmt(x[[nm]], name = nm)
      
    } else if (all(class(x[[nm]]) == "character")) {
      
      if (length(x[[nm]]) == 1 & is.null(names(x[[nm]]))) {
        tmp[[nm]] <- data.frame(Name = nm, 
                                Type = "S",
                                Expression = x[[nm]],
                                Label = "", 
                                Order = NA, 
                                Factor = NA,
                                stringsAsFactors = FALSE)
      } else {
        tmp[[nm]] <- data.frame(Name = nm, 
                                Type = "V",
                                Expression = paste(deparse(x[[nm]]), collapse = " "),
                                Label = "", 
                                Order = NA, 
                                Factor = NA,
                                stringsAsFactors = FALSE)
      }
                              
    } else if (any(class(x[[nm]]) == "function")) {
      
      tmp[[nm]] <-  data.frame(Name = nm, 
                               Type = "F",
                               Expression = paste(deparse(x[[nm]]), collapse = " "),
                               Label = "", 
                               Order = NA, 
                               Factor = NA,
                               stringsAsFactors = FALSE)
        
        
    }
    
  }
  
  
  ret <- do.call("rbind", tmp)
  
  if (!is.null(row.names))
    rownames(ret) <- row.names
  else
    rownames(ret) <- NULL
  
  return(ret)

}


# Utility Functions -------------------------------------------------------


#' @title Write a format catalog to the file system
#' @description The \code{write.fcat} function writes a format catalog
#' to the file system.  By default, the catalog will be written to the 
#' current working directory, using the variable name as the file name.  These
#' defaults can be overridden using the appropriate parameters.  The catalog
#' will be saved with a file extension of ".fcat". 
#' @param x The format catalog to write.
#' @param dir_path The directory path to write the catalog to. Default is the 
#' current working directory.
#' @param file_name The name of the file to save the catalog as.  Default is
#' the name of the variable that contains the catalog.  The ".fcat" file
#' extension will be added automatically.
#' @return The full path of the saved format catalog.
#' @family fcat
#' @examples 
#' # Create format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#'            
#' # Get temp directory
#' tmp <- tempdir()            
#'            
#' # Save catalog to file system
#' pth <- write.fcat(c1, dir_path = tmp)
#' 
#' # Read from file system
#' c2 <- read.fcat(pth)
#' 
#' # Use formats in the catalog
#' fapply(2, c1$num_fmt)
#' # [1] "2.0"
#' 
#' fapply(c("A", "B", "C", "B"), c1$label_fmt)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' 
#' fapply(Sys.Date(), c1$date_fmt)
#' # [1] "07Jan2024"
#' @export
write.fcat <- function(x, dir_path = getwd(), file_name = NULL) {
  
  if (is.null(file_name))
    file_name <- deparse(substitute(x, env = environment()))
  
  pth <- file.path(dir_path, paste0(file_name, ".fcat"))

  
  if (file.exists(pth))
    file.remove(pth)
  
  saveRDS(x, pth)
  
  
  log_logr("Saved format catalog to '" %p% pth %p% "'")
  
  return(pth)
}


#' @title Read a format catalog from the file system
#' @description The \code{read.fcat} function reads a format catalog
#' from the file system.  The function accepts a path to the format catalog,
#' reads the catalog, and returns it.
#' @param file_path The path to the format catalog.
#' @return The format catalog as an R object.
#' @family fcat
#' @examples 
#' # Create format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#'            
#' # Get temp directory
#' tmp <- tempdir()            
#'            
#' # Save catalog to file system
#' pth <- write.fcat(c1, dir_path = tmp)
#' 
#' # Read from file system
#' c2 <- read.fcat(pth)
#' 
#' # Use formats in the catalog
#' fapply(2, c1$num_fmt)
#' # [1] "2.0"
#' 
#' fapply(c("A", "B", "C", "B"), c1$label_fmt)
#' # [1] "Label A" "Label B" "Other"   "Label B"
#' 
#' fapply(Sys.Date(), c1$date_fmt)
#' # [1] "07Jan2024"
#' @export
read.fcat <- function(file_path) {
  
  ret <-  readRDS(file_path)
  
  log_logr("Read format catalog from '" %p% file_path %p% "'")
  
  if (log_output()) {
    log_logr(ret)
    print(ret)
  }
  return(ret)
}

#' @title Print a format catalog
#' @description A class-specific instance of the \code{print} function for 
#' format catalogs.  The function prints the format catalog in a tabular manner.  
#' Use \code{verbose = TRUE} to print the catalog as a list.
#' @param x The format catalog to print.
#' @param ... Any follow-on parameters.
#' @param verbose Whether or not to print the format catalog in verbose style.
#' By default, the parameter is FALSE, meaning to print in tabular style.
#' @return The object, invisibly.
#' @family fcat
#' @examples 
#' #' # Create format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#'            
#' # Print the catalog
#' print(c1)
#' # # A format catalog: 3 formats
#' # - $num_fmt: type S, "%.1f"
#' # - $label_fmt: type U, 3 conditions
#' # - $date_fmt: type S, "%d%b%Y"
#' @import crayon
#' @export
print.fcat <- function(x, ..., verbose = FALSE) {
  
  if (verbose == TRUE) {
    
   print(unclass(x))  
    
  } else {
    
  
   grey60 <- make_style(grey60 = "#999999")
   cat(grey60("# A format catalog: " %+% 
                as.character(length(x)) %+% " formats\n"))
    
     
   #dat <- as.data.frame(x)
   for(nm in names(x)) {
     
     ob <- x[[nm]]

     if (any(class(ob) == "fmt")) {
       cat(paste0("- $", nm, ": type U, ", length(ob),  " conditions\n"))
       
       
     }  else if (any(class(x[[nm]]) == "function")) {
        
       cat(paste0("- $", nm, ": type F, ",  "1 function \n"))
       
     } else if (any(class(x[[nm]]) %in% c("character", "numeric", 
                                          "integer", "Date", 
                                          "POSIXct", "POSIXlt"))) {
       
       if (length(ob) > 1)
         cat(paste0("- $", nm, ": type V, ", length(ob),  " elements\n"))
       else 
         cat(paste0("- $", nm, ": type S, \"", ob,"\"\n"))
     }
   }
    
   
  }
    
  invisible(x)
}


# grey60 <- make_style(grey60 = "#999999")
# cat(grey60("# A format catalog: " %+% 
#              as.character(length(x)) %+% " formats\n"))
# 
# 
# dat <- as.data.frame(x)
# if (!is.null(row_limit)) {
#   if (nrow(dat) > row_limit) {
#     dat1 <- dat[1:row_limit, ]
#     print(dat1)
#     cat(grey60(paste("# ... with", nrow(dat) - row_limit, "more rows\n")))
#     
#   } else
#     print(dat)
# } else 
#   print(dat)


#' @title Class test for a format catalog
#' @description This function tests whether an object is a format catalog.  The
#' format catalog has a class of "fcat".  
#' @param x The object to test.
#' @return TRUE or FALSE, depending on whether or not the object is a 
#' format catalog.
#' @family fcat
#' @examples 
#' # Create format catalog
#' c1 <- fcat(num_fmt  = "%.1f",
#'            label_fmt = value(condition(x == "A", "Label A"),
#'                              condition(x == "B", "Label B"),
#'                              condition(TRUE, "Other")),
#'            date_fmt = "%d%b%Y")
#'            
#' # Test for "fcat" class
#' is.fcat(c1)  
#' # [1] TRUE
#' 
#' is.fcat(Sys.Date())   
#' # [1] FALSE       
#' @export
is.fcat <- function(x) {
  
  ret <- FALSE
  if (any(class(x) == "fcat"))
    ret <-  TRUE
    
  return(ret)
}

# Import function ---------------------------------------------------------

# Not quite ready to release this yet

#' @title Import a format catalog from a data frame.
#' @description This function helps to create a format catalog from 
#' a data frame.  It has an advantage over \code{\link{as.fcat.data.frame}}
#' in that it will map the columns and create the value expressions for you.
#' @param data The input data frame.  
#' @param name A quoted value that identifies the column to use for the 
#' format name.  Default is "NAME".
#' @param value The column to use for the expression value.  The function
#' will create an expression of the form "x == " on the values in this column.
#' Default is "CODE".
#' @param label The column to use for the label values.  Default is "DECODE".
#' @param type The type of formats to create.  Default is user-defined type "U".
#' @param order The column to use for the format order.  The default is NULL,
#' meaning the order will be determined by the order of the rows in the 
#' incoming data.
#' @return A formatting object, created using the information in the 
#' input object.
#' @family fcat
#' @noRd
import.fcat <- function(data, name = "NAME", value = "CODE", label = "DECODE", type = "U", order = NULL) {
  
  
  dt <- data
  
  nms <- names(dt)
  
  if (!"data.frame" %in% class(data)) {
    
    stop("Input data must be of class 'data.frame'.") 
  }
  
  if (!name %in% nms) {
    
    stop("Name parameter '" %p% name %p% "; does not exist on the input dataset.") 
  }
  
  if (!value %in% nms) {
    
    stop("Value parameter '" %p% value %p% "; does not exist on the input dataset.") 
  }
  
  if (!label %in% nms) {
    
    stop("Label parameter '" %p% label %p% "; does not exist on the input dataset.") 
  }
  
  if (!is.null(order)) {
    if (!order %in% nms) {
      
      stop("Order parameter '" %p% order %p% "; does not exist on the input dataset.") 
    } 
  }
  
  if (!type %in% c("U", "S", "F", "V")) {
    
    
  }
  
  
  df <- data.frame(Name = dt[[name]],
                   Type = type,
                   Expression =  paste0("x =='", dt[[value]], "'"),
                   Label = dt[[label]],
                   Order = NA)
  
  res <- as.fcat(df)
  
  return(res)
  
}

