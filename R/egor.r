#' egor - a data class for ego-centered network data.
#'
#' The function \code{egor()} is used to create an egor object from 
#' ego-centered network data.
#' @param alters.df \code{data.frame} containing the alters.
#' @param egos.df \code{data.frame} containing the egos.
#' @param alter_ties.df \code{data.frame} containing the alter-alter relations in
#' the style of and edge list.
#' @param egoID Name of ego ID variable.
#' @param max.netsize Optional parameter. Constant value used if the
#' number of alteri whose relations were collected is limited.
#' @return returns an \code{egor} object. An egor is a \code{data.frame}, which
#' consists of an ego ID column, nested columns for alter and alte-alter tie 
#' data and regular columns for ego-level data.
#' @details The parameters alters.df, egos.df and alter_ties need to share a common
#' ego ID variable, with corresponding values. Of the three parameters only alters.df
#' is necessary to create an egor object, egos.df and alter_ties.df are optional.
#' @keywords ego-centric network analysis
#' @examples 
#' 
#' @export
egor <- function(alters.df, egos.df = NULL, alter_ties.df = NULL, egoID="egoID") {
  # FUN: Inject empty data.frames with correct colums in to NULL cells in 
  # $alters and $alter_ties
  inj_zero_dfs <- function(x, y) {
    null_entries <- sapply(x[[y]], is.null)
    zero_df <- x[[y]][!null_entries][[1]][0, ]
    zero_dfs <- lapply(x[[y]][null_entries], FUN = function(x) zero_df)
    x[null_entries, ][[y]] <- zero_dfs
    x
  }
  
  # Create initial egor object from ALTERS
  egor <- tidyr::nest_(data = alters.df, 
                             key_col = "alters", 
                             names(alters.df)[names(alters.df) != egoID]) # Select all but the egoID column for nesting
  
  # If specified add alter_ties data to egor
  if(!is.null(alter_ties.df)) {
    alter_ties.tib <- tidyr::nest_(data = alter_ties.df, 
                                   key_col = "alter_ties",    
                                   names(alter_ties.df)[names(alter_ties.df) != egoID])
    egor <- dplyr::full_join(egor, alter_ties.tib, by = egoID)
    egor <- inj_zero_dfs(egor, "alter_ties")
  }
  
  # If speciefied add ego data to egor
  if(!is.null(egos.df)) {
    egor <- dplyr::full_join(egor, egos.df, by = egoID)
    egor <- inj_zero_dfs(egor, "alters")
  }
  
  # Check If egoIDs valid
  if (length(unique(egor[[egoID]])) < length(egor[[egoID]]))
    warning(paste(egoID, "values are note unique. Check your 'egos.df' data."))
  
  # Add meta attribute
  #  ----><----

  class(egor) <- c("egor", class(egor))
  egor
}

filter_egor <- function(egor, obj = c("alters", "alter_ties"), cond) {
  
}


summary.egor <- function(egor) {
  # Network count
  nc <- NROW(egor)
  
  # Average netsize
  nts <- sum(unlist(lapply(egor$alters, FUN = NROW))) / nc
  
  # Average density
  if("alter_ties" %in% names(egor)) dens <- sum(ego_density(egor), na.rm = T) / nc else dens <- NULL
  
  cat(paste(nc, "Egos/ Ego Networks", "\nAverage Netsize", nts, "\n"))
  if(!is.null(dens)) cat(paste("Average Density", dens))

  # Meta Data

}

