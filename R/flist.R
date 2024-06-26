

# Flist Function ----------------------------------------------------------


#' @title Create a formatting list
#' @description A formatting list contains more than one formatting object.
#' @details 
#' To apply more than one formatting object to a vector, use a formatting
#' list.  There are two types of formatting list: column and row.  The column
#' type formatting lists applies all formats to all values in the
#' vector.  The row type formatting list can apply a different format to 
#' each value in the vector.  
#' 
#' Further, there are two styles of row type list: ordered and lookup.  The
#' ordered style applies each format in the list to the vector values
#' in the order specified.  The
#' ordered style will recycle the formats as needed.  The lookup style 
#' formatting list uses a lookup to determine which format from the list to
#' apply to a particular value of the vector.  The lookup column values should
#' correspond to names on the formatting list.  
#' 
#' Examples of column type and row type formatting lists are given below. 
#' @param ... A set of formatting objects.
#' @param type The type of formatting list.  Valid values are 'row' or 'column'.
#' The default value is 'column'.
#' @param lookup A lookup vector.  Used for looking up the format from 
#' the formatting list.  This parameter is only used for 'row' type 
#' formatting lists.
#' @param simplify Whether to simplify the results to a vector.  Valid values 
#' are TRUE or FALSE.  Default is TRUE.  If the value is set to FALSE, the 
#' return type will be a list.
#' @return A vector or list of formatted values.  The type of return value 
#' can be controlled with the \code{simplify} parameter.  The default return
#' type is a vector.
#' @seealso \code{\link{fapply}} for information on how formats are applied
#' to a vector, \code{\link{value}} for how to create a user-defined format,
#' and \code{\link{as.flist}} to convert an existing list of formats 
#' to a formatting
#' list. Also see \link{FormattingStrings} for details on how to use
#' formatting strings.
#' @family flist
#' @export
#' @examples
#' ## Example 1: Formatting List - Column Type ##
#' # Set up data
#' v1 <- c(Sys.Date(), Sys.Date() + 30, Sys.Date() + 60)
#' 
#' # Create formatting list
#' fl1 <- flist("%B", "The month is: %s")
#' 
#' # Apply formatting list to vector
#' fapply(v1, fl1)
#' # [1] "The month is: October"  "The month is: November" "The month is: December"
#' 
#' ## Example 2: Formatting List - Row Type ordered ##
#' # Set up data
#' # Notice each row has a different data type
#' l1 <- list("A", 1.263, as.Date("2020-07-21"), 
#'           "B", 5.8732, as.Date("2020-10-17"))
#'           
#' # These formats will be recycled in the order specified           
#' fl2 <- flist(type = "row",
#'              c(A = "Label A", B = "Label B"),
#'              "%.1f",
#'              "%d%b%Y")
#' 
#' fapply(l1, fl2)
#' # [1] "Label A"   "1.3"       "21Jul2020" "Label B"   "5.9"       "17Oct2020"
#' 
#' 
#' ## Example 3: Formatting List - Row Type with lookup ##
#' 
#' #' # Create formatting list
#' fl3 <- flist(type = "row", 
#'              DEC1 = "%.1f",
#'              DEC2 = "%.2f", 
#'              PCT1 = "%.1f%%")
#'              
#' # Set up data
#' df <- data.frame(CODE = c("DEC1", "DEC2", "PCT1", "DEC2", "PCT1"),
#'                  VAL = c(41.258, 62.948, 12.125, 65.294, 15.825))
#' 
#' # Assign lookup
#' fl3$lookup <- df$CODE
#' 
#' # Apply Formatting List
#' fapply(df$VAL, fl3)
#' # [1] "41.3"  "62.95" "12.1%" "65.29" "15.8%"
#' 
#' ## Example 4: Formatting List - Values with Units ##
#' 
#' #' # Create formatting list
#' fl4 <- flist(type = "row", 
#'              BASO = "%.2f x10(9)/L",
#'              EOS  = "%.2f x10(9)/L",
#'              HCT = "%.1f%%", 
#'              HGB = "%.1f g/dL")
#'              
#' # Set up data
#' df <- data.frame(CODE = c("BASO", "EOS", "HCT", "HGB"),
#'                  VAL = c(0.02384, 0.14683, 40.68374, 15.6345))
#' 
#' # Assign lookup
#' fl4$lookup <- df$CODE
#' 
#' # Apply Formatting List
#' df$VALC <- fapply(df$VAL, fl4)
#'
#' # View results
#' df
#' #   CODE      VAL          VALC
#' # 1 BASO  0.02384 0.02 x10(9)/L
#' # 2  EOS  0.14683 0.15 x10(9)/L
#' # 3  HCT 40.68374         40.7%
#' # 4  HGB 15.63450     15.6 g/dL
flist <- function(..., type = "column", lookup = NULL, simplify = TRUE) {
  
  if (!type %in% c("column", "row"))
    stop (paste("Invalid value for type parameter.", 
                "Value values are 'column' or 'row'"))
  
  if (!simplify %in% c(TRUE, FALSE))
    stop (paste("Invalid value for simplify parameter.", 
                "Valid values are TRUE or FALSE."))
  
  if (is.null(lookup) == FALSE & type == "column")
    stop (paste("Lookup parameter only allowed on type 'row'."))
  
  # Create new structure of class "fmt_lst"
  x <- structure(list(), class = c("fmt_lst", "list"))
  
  x$formats <- list(...)
  x$type <- type
  x$lookup <- lookup
  x$simplify <- simplify
  if (!is.null(lookup))
    x$lookupname <- paste(deparse(substitute(lookup, env = environment())), 
                          collapse = " ")
  
  
  return(x)
  
}


# Utilities ---------------------------------------------------------------



#' @title Is object a formatting list
#' @description Determines if object is a formatting list of class 'fmt_lst'.
#' @param x Object to test.
#' @return TRUE or FALSE, depending on class of object.
#' @family flist
#' @export
#' @examples
#' # Create flist
#' flst <- flist("%d%b%Y", "%.1f")
#' is.flist(flst)
#' is.flist("A")
is.flist <- function(x) {
 
  if (any(class(x) == "fmt_lst"))
    ret <- TRUE
  else
    ret <- FALSE
  
  return(ret)
}

#' @title Convert to a formatting list
#' @description Converts an object to a formatting list.  All
#' other parameters are the same as the \code{flist} function.
#' @param x Object to convert.
#' @return A formatting list object.
#' @inherit flist
#' @family flist
#' @export
as.flist <- function (x, type = "column", lookup = NULL, simplify = TRUE) {
  UseMethod("as.flist", x)
}

#' @title Convert a list to a formatting list
#' @description Converts a normal list to a formatting list.  All
#' other parameters are the same as the \code{flist} function.
#' @param x List to convert.
#' @return A formatting list object.
#' @inherit flist
#' @seealso \code{\link{flist}} function documentation for additional details.
#' @family flist
#' @export
#' @examples
#' # Example 1: Create flist from list - column type
#' lst1 <- list("%d%b%Y", "%.1f")
#' fl1  <- as.flist(lst1, type = "column")
#' 
#' # Example 2: Create flist from list - row type
#' lst2 <- list(lkup = c(A = "Label A", B = "Label B"),
#'              dec1 = "%.1f",
#'              dt1  = "%d%b%Y")
#' fl2 <- as.flist(lst2, type = "row")
#'              
as.flist.list <- function(x, type = "column", lookup = NULL, simplify = TRUE) {
  
  
  if (!type %in% c("column", "row"))
    stop (paste("Invalid value for type parameter.", 
                "Value values are 'column' or 'row'"))
  
  if (!simplify %in% c(TRUE, FALSE))
    stop (paste("Invalid value for simplify parameter.", 
                "Valid values are TRUE or FALSE."))
  
  if (is.null(lookup) == FALSE & type == "column")
    stop (paste("Lookup parameter only allowed on type 'row'."))
  
  # Create new structure of class "fmt_lst"
  f <- structure(list(), class = c("fmt_lst", "list"))
  
  f$formats <- x
  f$type <- type
  f$lookup <- lookup
  f$simplify <- simplify
  
  return(f)
}

#' @title Convert a data frame to a formatting list
#' @description Converts a data frame to a formatting list.  All
#' other parameters are the same as the \code{flist} function.
#' @param x Data frame to convert.
#' @return A formatting list object.
#' @inherit flist
#' @family flist
#' @export
as.flist.data.frame <- function(x, type = "column", lookup = NULL, simplify = TRUE) {
  
  
  if (!type %in% c("column", "row"))
    stop (paste("Invalid value for type parameter.", 
                "Value values are 'column' or 'row'"))
  
  if (!simplify %in% c(TRUE, FALSE))
    stop (paste("Invalid value for simplify parameter.", 
                "Valid values are TRUE or FALSE."))
  
  if (is.null(lookup) == FALSE & type == "column")
    stop (paste("Lookup parameter only allowed on type 'row'."))
  
  # Create new structure of class "fmt_lst"
  f <- structure(list(), class = c("fmt_lst", "list"))
  
  
  f$formats <- unclass(as.fcat(x))
  f$type <- type
  f$lookup <- lookup
  f$simplify <- simplify
  
  
  return(f)
}

#' @title Convert a tibble to a formatting list
#' @description Converts a tibble to a formatting list.  All
#' other parameters are the same as the \code{flist} function.
#' @param x Tibble to convert.
#' @return A formatting list object.
#' @inherit flist
#' @family flist
#' @export
as.flist.tbl_df <- function(x, type = "column", lookup = NULL, simplify = TRUE) {
  
  return(as.flist(as.data.frame(x, stringsAsFactors = FALSE), type, lookup, simplify))
  
}

#' @title Convert a format catalog to a formatting list
#' @description Converts a format catalog to a formatting list.  All
#' other parameters are the same as the \code{flist} function.
#' @param x Format catalog to convert.
#' @return A formatting list object.
#' @inherit flist
#' @family flist
#' @export
as.flist.fcat <- function(x, type = "column", lookup = NULL, simplify = TRUE) {
  

  return(as.flist.list(unclass(x), type, lookup, simplify))
  
}

#' @title Convert a formatting list to a data frame
#' @description This function takes the information stored in a formatting 
#' list, and converts it to a data frame.  The data frame format is 
#' useful for storage, editing, saving to a spreadsheet, etc.  The 
#' data frame shows the name of the formats, their type, and the format 
#' expression.  For user-defined formats, the data frame populates 
#' additional columns for the label and order.
#' @param x The formatting list to convert.
#' @param row.names Row names for the returned data frame.  Default is NULL.
#' @param optional TRUE or FALSE value indicating whether converting to
#' syntactic variable names is desired.  In the case of formats, the 
#' resulting data frame will always be returned with syntactic names, and 
#' this parameter is ignored.
#' @param ... Any follow-on parameters.
#' @return A data frame that contains the values stored in the formatting 
#' list.  
#' @family flist
#' @examples 
#' # Create a formatting list
#' c1 <- flist(num_fmt  = "%.1f",
#'             label_fmt = value(condition(x == "A", "Label A"),
#'                               condition(x == "B", "Label B"),
#'                               condition(TRUE, "Other")),
#'             date_fmt = "%d%b%Y")
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
#' # Convert data frame back to a formatting list
#' c2 <- as.flist(df)
#' c2
#' # # A formatting list: 3 formats
#' # - type: column
#' # - simplify: TRUE
#' #        Name Type Expression   Label Order
#' # 1  date_fmt    S     %d%b%Y          <NA>
#' # 2 label_fmt    U   x == "A" Label A  <NA>
#' # 3 label_fmt    U   x == "B" Label B  <NA>
#' # 4 label_fmt    U       TRUE   Other  <NA>
#' # 5   num_fmt    S       %.1f          <NA>
#' @export
as.data.frame.fmt_lst <- function(x, row.names = NULL, optional = FALSE, ...) {
  
  if (!"fmt_lst" %in% class(x))
    stop("Class of object must include 'fmt_lst'")
  fmts <- x$formats
  tmp <- list()
  
  nms <- names(fmts)
  if (is.null(nms))
    nms <- paste0("format", seq(from = 1, to = length(fmts)))
  
  for (i in seq_along(fmts)) {
    
    nm <- nms[[i]]
    
    if (any(class(fmts[[i]]) == "fmt")) {
      
      tmp[[nm]] <- as.data.frame.fmt(fmts[[i]], name = nm)
      
    } else if (all(class(fmts[[i]]) == "character")) {
      
      if (length(fmts[[i]]) == 1 & is.null(names(fmts[[i]]))) {
        tmp[[nm]] <- data.frame(Name = nm, 
                                Type = "S",
                                Expression = fmts[[i]],
                                Label = "", 
                                Order = NA, 
                                Factor = NA, 
                                stringsAsFactors = FALSE)
      } else {
        tmp[[nm]] <- data.frame(Name = nm, 
                                Type = "V",
                                Expression = paste(deparse(fmts[[i]]), 
                                                   collapse = " "),
                                Label = "", 
                                Order = NA, 
                                Factor = NA, 
                                stringsAsFactors = FALSE)
      }
      
    } else if (any(class(fmts[[i]]) == "function")) {
      
      tmp[[nm]] <-  data.frame(Name = nm, 
                               Type = "F",
                               Expression = paste(deparse(fmts[[i]]), 
                                                  collapse = " "),
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



# Read and Write flist ----------------------------------------------------



#' @title Write a formatting list to the file system
#' @description The \code{write.flist} function writes a formatting list
#' to the file system.  By default, the formatting list will be written to the 
#' current working directory, using the variable name as the file name.  These
#' defaults can be overridden using the appropriate parameters.  The catalog
#' will be saved with a file extension of ".flist". 
#' @param x The formatting list to write.
#' @param dir_path The directory path to write the catalog to. Default is the 
#' current working directory.
#' @param file_name The name of the file to save the catalog as.  Default is
#' the name of the variable that contains the formatting list.  The ".flist" file
#' extension will be added automatically.
#' @return The full path of the saved formatting list.
#' @family flist
#' @examples 
#' # Create formatting list
#' fl <- flist(f1 = "%5.1f",
#'             f2 = "%6.2f",
#'             type = "row")
#'            
#' # Get temp directory
#' tmp <- tempdir()            
#'            
#' # Save formatting list to file system
#' pth <- write.flist(fl, dir_path = tmp)
#' 
#' # Read from file system
#' fr <- read.flist(pth)
#' 
#' # Create sample data
#' dat <- c(12.3844, 292.28432)
#' 
#' # Use formats in the catalog
#' fapply(dat, fr)
#' # [1] " 12.4"  "292.28"
#' 
#' @export
write.flist <- function(x, dir_path = getwd(), file_name = NULL) {
  
  if (is.null(file_name))
    file_name <- deparse(substitute(x, env = environment()))
  
  pth <- file.path(dir_path, paste0(file_name, ".flist"))
  
  
  if (file.exists(pth))
    file.remove(pth)
  
  saveRDS(x, pth)
  
  
  log_logr("Saved formatting list to '" %p% pth %p% "'")
  
  return(pth)
}


#' @title Read a formatting list from the file system
#' @description The \code{read.flist} function reads a formatting list
#' from the file system.  The function accepts a path to the formatting list,
#' reads the list, and returns it.
#' @param file_path The path to the formatting list.
#' @return The formatting list as an R object.
#' @family flist
#' @examples 
#' # Create formatting list
#' fl <- flist(f1 = "%5.1f",
#'             f2 = "%6.2f",
#'             type = "row")
#'            
#' # Get temp directory
#' tmp <- tempdir()            
#'            
#' # Save formatting list to file system
#' pth <- write.flist(fl, dir_path = tmp)
#' 
#' # Read from file system
#' fr <- read.flist(pth)
#' 
#' # Create sample data
#' dat <- c(12.3844, 292.28432)
#' 
#' # Use formats in the catalog
#' fapply(dat, fr)
#' # [1] " 12.4"  "292.28"
#' @export
read.flist <- function(file_path) {
  
  ret <-  readRDS(file_path)
  
  log_logr("Read formatting list from '" %p% file_path %p% "'")
  
  if (log_output()) {
    log_logr(ret)
    print(ret)
  }
  return(ret)
}


#' @title Print a formatting list
#' @param x The formatting list to print
#' @param ... Follow-on parameters to the print function
#' @param verbose Whether to print in summary or list-style.
#' @family flist
#' @export
print.fmt_lst <- function(x, ..., verbose = FALSE) {
  
  if (verbose == TRUE) {
    print(unclass(x)) 
  } else {
    
    grey60 <- make_style(grey60 = "#999999")
    cat(grey60("# A formatting list: " %+% 
                 as.character(length(x$formats)) %+% " formats\n")) 
    if (!is.null(x$type))
      cat(grey60("- type: " %+% x$type %+% "\n"))
    if (!is.null(x$lookupname))
      cat(grey60("- lookup: " %+% x$lookupname %+% "\n"))
    if (!is.null(x$simplify))
      cat(grey60("- simplify: " %+% as.character(x$simplify) %+% "\n"))
    
    print(as.data.frame(x, stringsAsFactors = FALSE))
    
  }
  
  invisible(x)
}




# Testing -----------------------------------------------------------------
# 
# # Simple use case
# id <- 100:109
# col1 <- sample(rep(c("A", "B", "C"), 5), 10)
# col2 <- sample(seq(0, 100, by = .001), 10)
# 
# 
# df <- data.frame(id, col1, col2)
# df
# 
# 
# col1_fmt <- c(A = "Placebo", B = "Drug", C = "Other")
# col2_fmt <- Vectorize(function(x) if (x > 88) "High" else if (x < 12) "Low" else x)
#   
# 
# 
# 
# formats(df) <- list(col1 = col1_fmt, col2 = col2_fmt)
# formats(df)
# 
# format(df)
# 
# col1_fmt2 <- function(x) format(x, justify = "left") 
# col2_fmt2 <- function(x) format(x, justify = "left")
# 
# col1_flist <- flist(col1_fmt, col1_fmt2)
# col2_flist <- flist(col2_fmt, col2_fmt2)
# 
# is.flist(col1_fmt)
# 
# formats(df) <- list(col1_flist, col2_flist)
# 
# col1_flist


