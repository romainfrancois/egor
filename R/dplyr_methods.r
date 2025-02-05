if (getRversion() >= "2.15.1") utils::globalVariables(c("tmp_ix__", ".srcID", ".tgtID", ".egoID"))

# dplyr helper functions
restore_egor_attributes <- function(result, egor_obj) {
  attrs_old <- attributes(egor_obj)
  attrs_old <- attrs_old[!names(attrs_old) %in% c("names", "row.names")]
  attrs_new <- attributes(result)
  attrs_new <- attrs_new[!names(attrs_new) %in% names(attrs_old)]
  attributes(result) <-  c(attrs_old, attrs_new)
  update_ego_design(result)
}

update_ego_design <- function(result) {
  new_variables <- as_tibble(result)
  attr_keep <- attributes(new_variables)
  attr_keep <- attr_keep[names(attr_keep) %in% c("names", "row.names", "class")]
  attributes(new_variables) <- attr_keep
  attributes(result)$ego_design$variables <- new_variables
  result
}

#' Trims alter-alter ties of alters that are missing/ deleted from alters data
#' 
#' @param object An `egor` object.
#' @return An `egor` object with trimmed alter-alter ties (.aaties).
#' @export
trim_aaties <- function(object) {
  object$aatie <-
    purrr::map_dfr(split(object$aatie, object$aatie$.egoID),
                   function(x) {
                     if (nrow(x) > 0) {
                       alter_subset <- filter(object$alter, .egoID == x$.egoID[[1]])
                       
                       filter(
                         x,
                         .egoID %in% object$ego$.egoID,
                         .srcID %in% alter_subset$.altID,
                         .tgtID %in% alter_subset$.altID
                       )
                     } else x
                   })
  
  object
}

#' Trims alters that are missing/ deleted from ego data
#' 
#' @param object An `egor` object.
#' @return An `egor` object with trimmed alter-alter ties (.aaties).
#' @export
trim_alters <- function(object) {
  object$alter <-
    filter(object$alter, .egoID %in% object$ego$.egoID)
  object
}
  
bind_IDs_if_missing <- function(.data, result) {
  a <- unlist(IDVARS[IDVARS %in% names(.data[[attr(.data, "active")]])], use.names = FALSE)
  b <- a[!a %in% names(result)]
  if (length(b) >= 1)
    result <- bind_cols(select(.data[[attr(.data, "active")]], b),
                        result)
  select(result, a, everything())
}

return_egor_with_result <- 
  function(.data, result, trim = TRUE) {
    .data[[attr(.data, "active")]] <- result
    if(trim) {
      .data <- trim_aaties(.data)
      trim_alters(.data)
    } else .data
  }

# mutate ------------------------------------------------------------------

#' @export
#' @noRd
#' @method mutate egor
mutate.egor <- function(.data, ...) {
  result <- mutate(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}

#' @export
#' @noRd
#' @method transmute egor
transmute.egor <- function(.data, ...) {
  result <- transmute(.data[[attr(.data, "active")]], ...)
  result <- 
    bind_IDs_if_missing(.data, result)

  return_egor_with_result(.data, result)
}


# select ------------------------------------------------------------------

#' @export
#' @noRd
#' @method select egor
select.egor <- function(.data, ...) {
  result <- select(.data[[attr(.data, "active")]], ...)
  result <- 
    bind_IDs_if_missing(.data, result)
  return_egor_with_result(.data, result)
}

#' @export
#' @noRd
#' @method rename egor
rename.egor <- function(.data, ...) {
  result <- rename(.data[[attr(.data, "active")]], ...)
  result <- 
    bind_IDs_if_missing(.data, result)
  return_egor_with_result(.data, result)
}


# filter ------------------------------------------------------------------

#' @export
#' @noRd
#' @method filter egor
filter.egor <- function(.data, ...) {
  result <- filter(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}

#' @export
#' @noRd
#' @method slice egor
slice.egor <- function(.data, ...) {
  result <- slice(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}


# group_by count tally summarise ------------------------------------------

#' @export
#' @noRd
#' @method group_by egor
group_by.egor <- function(.data, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  result <- group_by(.data[[attr(.data, "active")]], ..., add = FALSE, .drop = group_by_drop_default(.data))
  return_egor_with_result(.data, result, trim = FALSE)
}

#' @export
#' @noRd
#' @method ungroup egor
ungroup.egor <- function(x, ...) {
  result <- ungroup(x[[attr(x, "active")]], ...)
  return_egor_with_result(x, result)
}

#' #' @export
#' #' @noRd
#' #' @method count egor
#' count.egor <- function(.data, ...) {
#'   count(.data[[attr(.data, "active")]], ...)
#' }

#' #' @export
#' #' @noRd
#' #' @method tally egor
#' tally.egor <- function(x, wt = NULL, sort = FALSE, name = "n") {
#'   tally(x[[attr(x, "active")]], wt = NULL, sort = FALSE, name = "n")
#' }

#' #' @export
#' #' @noRd
#' #' @method add_count egor
#' add_count.egor <- function(.data, ...) {
#'   result <- add_count(.data[[attr(.data, "active")]], ...)
#'   return_egor_with_result(.data, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method add_tally egor
#' add_tally.egor <- function(x, wt = NULL, sort = FALSE, name = "n") {
#'   result <- add_tally(x[[attr(x, "active")]], wt = NULL, sort = FALSE, name = "n")
#'   return_egor_with_result(.data, result)
#' }

#' @export
#' @noRd
#' @method summarise egor
summarise.egor <- function(.data, ...) {
  summarise(.data[[attr(.data, "active")]], ...)
}

#' @export
#' @noRd
#' @method summarize egor
summarize.egor <- function(.data, ...) {
  summarize(.data[[attr(.data, "active")]], ...)
}

# arrange -----------------------------------------------------------------

#' @export
#' @noRd
#' @method arrange egor
arrange.egor <- function(.data, ...) {
  result <- arrange(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}
# should arrange commands to ego level ripple through to the other two levels?

# joins -------------------------------------------------------------------

#' @export
#' @noRd
#' @method inner_join egor
inner_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- inner_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix, ...)
  return_egor_with_result(x, result)
  
}

#' @export
#' @noRd
#' @method left_join egor
left_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- left_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix,...)
  return_egor_with_result(x, result)
  
}

#' @export
#' @noRd
#' @method right_join egor
right_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- right_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix,...)
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method full_join egor
full_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- full_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix,...)
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method semi_join egor
semi_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- semi_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix,...)
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method nest_join egor
nest_join.egor <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  result <- nest_join(x[[attr(x, "active")]], y, by = by, copy = copy, keep = keep, name = name,...)
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method anti_join egor
anti_join.egor <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  result <- anti_join(x[[attr(x, "active")]], y, by = by, copy = copy, suffix = suffix,...)
  return_egor_with_result(x, result)
}


# select_ rename_ ---------------------------------------------------------

#' @export
#' @noRd
#' @method tbl_vars egor
tbl_vars.egor <- 
  function(x) {
    tbl_vars(x[[attr(x, "active")]])
  }

#' @export
#' @noRd
#' @method rename_ egor
rename_.egor <- rename.egor

#' #' @export
#' #' @noRd
#' #' @method select_all egor
#' select_all.egor <- function(.tbl, .funs = list(), ...) {
#'   result <- select_all(.tbl[[attr(.tbl, "active")]], .funs = .funs, ...)
#'   result <- 
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method rename_all egor
#' rename_all.egor <- function(.tbl, .funs = list(), ...) {
#'   result <- rename_all(.tbl[[attr(.tbl, "active")]], .funs = .funs, ...)
#'   result <-
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method select_if egor
#' select_if.egor <- function(.tbl, .predicate, .funs = list(), ...) {
#'   result <- select_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs = .funs, ...)
#'   result <- 
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method rename_if egor
#' rename_if.egor <- function(.tbl, .predicate, .funs = list(), ...) {
#'   result <- rename_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs = .funs, ...)
#'   result <- 
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }


#' #' @export
#' #' @noRd
#' #' @method select_at egor
#' select_at.egor <- function(.tbl, .vars, .funs = list(), ...) {
#'   result <- select_at(.tbl[[attr(.tbl, "active")]], .vars, .funs = .funs, ...)
#'   result <- 
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method rename_at egor
#' rename_at.egor <- function(.tbl, .vars, .funs = list(), ...) {
#'   result <- rename_at(.tbl[[attr(.tbl, "active")]], .vars = .vars, .funs = .funs, ...)
#'   result <- 
#'     bind_IDs_if_missing(.tbl, result)
#'   return_egor_with_result(.tbl, result)
#' }


# filter_ -----------------------------------------------------------------
#' 
#' #' @export
#' #' @noRd
#' #' @method filter_all egor
#' filter_all.egor <- function(.tbl, .vars_predicate, .preserve = FALSE) {
#'   result <- filter_all(.tbl[[attr(.tbl, "active")]], .vars_predicate, .preserve)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method filter_at egor
#' filter_at.egor <- function(.tbl, .vars, .vars_predicate, .preserve = FALSE) {
#'   result <- filter_at(.tbl[[attr(.tbl, "active")]], .vars, .vars_predicate, .preserve = FALSE)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method filter_if egor
#' filter_if.egor <- function(.tbl, .predicate, .vars_predicate, .preserve = FALSE) {
#'   result <- filter_if(.tbl[[attr(.tbl, "active")]], .predicate, .vars_predicate, .preserve)
#'   return_egor_with_result(.tbl, result)
#' }


# mutate_ -----------------------------------------------------------------

#' #' @export
#' #' @noRd
#' #' @method mutate_all egor
#' mutate_all.egor <- function(.tbl, .funs, ...) {
#'   result <- mutate_all(.tbl[[attr(.tbl, "active")]], .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method mutate_at egor
#' mutate_at.egor <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
#'   result <- mutate_at(.tbl[[attr(.tbl, "active")]], .vars, .funs, ..., .cols = NULL)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method mutate_if egor
#' mutate_if.egor <- function(.tbl, .predicate, .funs, ...) {
#'   result <- mutate_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method transmute_all egor
#' transmute_all.egor <- function(.tbl, .funs, ...) {
#'   result <- transmute_all(.tbl[[attr(.tbl, "active")]], .funs, ...)
#'   result <- bind_IDs_if_missing(.data, result)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method transmute_at egor
#' transmute_at.egor <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
#'   result <- transmute_at(.tbl[[attr(.tbl, "active")]], .vars, .funs, ..., .cols = NULL)
#'   result <- bind_IDs_if_missing(.data, result)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method transmute_if egor
#' transmute_if.egor <- function(.tbl, .predicate, .funs, ...) {
#'   result <- transmute_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs, ...)
#'   result <- bind_IDs_if_missing(.data, result)
#'   return_egor_with_result(.tbl, result)
#' }


# arrange_ ----------------------------------------------------------------

#' #' @export
#' #' @noRd
#' #' @method arrange_all egor
#' arrange_all.egor <- function(.tbl, .funs = list(), ..., .by_group = FALSE) {
#'   result <- arrange_all(.tbl[[attr(.tbl, "active")]], .funs = list(), ..., .by_group = FALSE)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method arrange_at egor
#' arrange_at.egor <- function(.tbl, .vars, .funs = list(), ..., .by_group = FALSE) {
#'   result <- arrange_at(.tbl[[attr(.tbl, "active")]], .vars, .funs = list(), ..., .by_group = FALSE)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method arrange_if egor
#' arrange_if.egor <- function(.tbl, .predicate, .funs = list(), ..., .by_group = FALSE) {
#'   result <- arrange_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs = list(), ..., .by_group = FALSE)
#'   return_egor_with_result(.tbl, result)
#' }


# summarise_ ----------------------------------------------------------------

#' #' @export
#' #' @noRd
#' #' @method summarise_all egor
#' summarise_all.egor <- function(.tbl, .funs, ...) {
#'   result <- summarise_all(.tbl[[attr(.tbl, "active")]], .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method summarise_at egor
#' summarise_at.egor <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
#'   result <- summarise_at(.tbl[[attr(.tbl, "active")]], .vars, .funs, ..., .cols = NULL)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method summarise_if egor
#' summarise_if.egor <- function(.tbl, .predicate, .funs, ...) {
#'   result <- summarise_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method summarize_all egor
#' summarize_all.egor <- function(.tbl, .funs, ...) {
#'   result <- summarize_all(.tbl[[attr(.tbl, "active")]], .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method summarize_at egor
#' summarize_at.egor <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
#'   result <- summarize_at(.tbl[[attr(.tbl, "active")]], .vars, .funs, ..., .cols = NULL)
#'   return_egor_with_result(.tbl, result)
#' }
#' 
#' #' @export
#' #' @noRd
#' #' @method summarize_if egor
#' summarize_if.egor <- function(.tbl, .predicate, .funs, ...) {
#'   result <- summarize_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }

# group_by_ group variants ------------------------------------------------

#' #' @export
#' #' @noRd
#' #' @method group_by_all egor
#' group_by_all.egor <- function(.tbl, .funs, ...) {
#'   result <- group_by_all(.tbl[[attr(.tbl, "active")]], .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method group_by_at egor
#' group_by_at.egor <- function(.tbl, .vars, .funs, ...) {
#'   result <- group_by_at(.tbl[[attr(.tbl, "active")]], .vars, .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }

#' #' @export
#' #' @noRd
#' #' @method group_by_if egor
#' group_by_if.egor <- function(.tbl, .vars, .funs, ...) {
#'   result <- group_by_if(.tbl[[attr(.tbl, "active")]], .vars, .funs, ...)
#'   return_egor_with_result(.tbl, result)
#' }

#' @export
#' @noRd
#' @method group_by_drop_default egor
group_by_drop_default.egor <- function(.tbl) {
  group_by_drop_default(.tbl[[attr(.tbl, "active")]])
}

#' @export
#' @noRd
#' @method group_indices egor
group_indices.egor <- function(.data, ...) {
  result <- group_indices(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}

#' @export
#' @noRd
#' @method group_keys egor
group_keys.egor <- function(.tbl, ...) {
  result <- group_keys(.tbl[[attr(.tbl, "active")]], ...)
  return_egor_with_result(.tbl, result)
}

#' @export
#' @noRd
#' @method group_split egor
group_split.egor <- function(.tbl, ...) {
  result <- group_split(.tbl[[attr(.tbl, "active")]], ...)
  return_egor_with_result(.tbl, result)
}

#' #' @export
#' #' @noRd
#' #' @method group_map egor
#' group_map.egor <- function(.tbl, .f, ...) {
#'   result <- group_map(.tbl[[attr(.tbl, "active")]], .f, ...)
#'   return_egor_with_result(.tbl, result)
#' }

#' @export
#' @noRd
#' @method group_modify egor
group_modify.egor <- function(.tbl, .f, ...) {
  result <- group_modify(.tbl[[attr(.tbl, "active")]], .f, ...)
  return_egor_with_result(.tbl, result)
}

#' #' @export
#' #' @noRd
#' #' @method group_walk egor
#' group_walk.egor <- function(.tbl, .f, ...) {
#'   result <- group_walk(.tbl[[attr(.tbl, "active")]], .f, ...)
#'   return_egor_with_result(.tbl, result)
#' }

#' @export
#' @noRd
#' @method group_nest egor
group_nest.egor <- function(.tbl, ...) {
  result <- group_nest(.tbl[[attr(.tbl, "active")]], ...)
  return_egor_with_result(.tbl, result)
}

#' @export
#' @noRd
#' @method group_data egor
group_data.egor <- function(.data) {
  result <- group_data(.data[[attr(.data, "active")]])
  return_egor_with_result(.data, result)
}

#' #' @export
#' #' @noRd
#' #' @method group_rows egor
#' group_rows.egor <- function(.data) {
#'   result <- group_rows(.data[[attr(.data, "active")]])
#'   return_egor_with_result(.data, result)
#' }

#' @export
#' @noRd
#' @method group_size egor
group_size.egor <- function(x) {
  result <- group_size(x[[attr(x, "active")]])
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method n_groups egor
n_groups.egor <- function(x) {
  result <- n_groups(x[[attr(x, "active")]])
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method group_trim egor
group_trim.egor <- function(.tbl, .drop = group_by_drop_default(.tbl)) {
  result <- group_trim(.tbl[[attr(.tbl, "active")]], .drop = group_by_drop_default(.tbl))
  return_egor_with_result(.tbl, result)
}

#' @export
#' @noRd
#' @method groups egor
groups.egor <- function(x) {
  result <- groups(x[[attr(x, "active")]])
  return_egor_with_result(x, result)
}

#' @export
#' @noRd
#' @method group_vars egor
group_vars.egor <- function(x) {
  group_vars(x[[attr(x, "active")]])
}



# bind --------------------------------------------------------------------


# bind_cols/bind_rows don't seem to be generics

#' Append rows/columns to ego, alter or aatie data
#'
#' These work like dplyr's bind_cols() and bind_rows(). The first
#' argument has to be an egor object. Additional rows/columns are added bottom/RHS
#' of the active data level (ego, alter, aatie).
#' 
#' @template egor_param
#' @param ... Data frames to combine.
#' @param .id Data frame identifier.
#' @name append_egor
NULL

#' @rdname append_egor
#' @export
append_rows <- function(.egor, ..., .id = NULL) {
  result <- bind_rows(.egor[[attr(.egor, "active")]], .id)
  return_egor_with_result(.egor, result)
}

#' @export
#' @rdname append_egor
append_cols <- function(.egor, ...) {
  result <- bind_cols(.egor[[attr(.egor, "active")]], ...)
  return_egor_with_result(.egor, result)
}

# distinct ----------------------------------------------------------------

#' @export
#' @noRd
#' @method distinct_all egor
distinct_all.egor <- function(.tbl, .funs = list(), ..., .keep_all = FALSE) {
  result <- distinct_all(.tbl[[attr(.tbl, "active")]], .funs = list(), ..., .keep_all = FALSE)
  return_egor_with_result(.tbl, result)
}

#' @export
#' @noRd
#' @method distinct_at egor
distinct_at.egor <- function(.tbl, .vars, .funs = list(), ..., .keep_all = FALSE) {
  result <- distinct_at(.tbl[[attr(.tbl, "active")]], .vars, .funs = list(), ..., .keep_all = FALSE)
  return_egor_with_result(.tbl, result)
}

#' @export
#' @noRd
#' @method distinct_if egor
distinct_if.egor <- function(.tbl, .predicate, .funs = list(), ..., .keep_all = FALSE) {
  result <- distinct_if(.tbl[[attr(.tbl, "active")]], .predicate, .funs = list(), ..., .keep_all = FALSE)
  return_egor_with_result(.tbl, result)
}

# do  ---------------------------------------------------------------------

#' @export
#' @noRd
#' @method do egor
do.egor <- function(.data, ...) {
  result <- do(.data[[attr(.data, "active")]], ...)
  return_egor_with_result(.data, result)
}

# explain -----------------------------------------------------------------

#' @export
#' @noRd
#' @method explain egor
explain.egor <- function(x, ...) {
  explain(x[[attr(x, "active")]], ...)
}

# pull --------------------------------------------------------------------

#' @export
#' @noRd
#' @method pull egor
pull.egor <- function(.data, var = -1) {
  pull(.data[[attr(.data, "active")]], var)
}

# rowwise -----------------------------------------------------------------

# Not a generic :(

# sample_n sample_frac ----------------------------------------------------

#' @export
#' @noRd
#' @method sample_n egor
sample_n.egor <- function(tbl, size, replace = FALSE, weight = NULL, .env = NULL, ...) {
  result <- sample_n(tbl[[attr(tbl, "active")]], size, replace = FALSE, weight = NULL, .env = NULL, ...)
  return_egor_with_result(tbl, result) 
}
#' @export
#' @noRd
#' @method sample_frac egor
sample_frac.egor <- function(tbl, size, replace = FALSE, weight = NULL, .env = NULL, ...) {
  result <- sample_frac(tbl[[attr(tbl, "active")]], size, replace = FALSE, weight = NULL, .env = NULL, ...)
  return_egor_with_result(tbl, result) 
}

# top_frac top_n ----------------------------------------------------------

#' #' @export
#' #' @noRd
#' #' @method top_n egor
#' top_n.egor <- function(x, n, wt) {
#'   result <- top_n(x[[attr(x, "active")]], n, wt)
#'   return_egor_with_result(x, result) 
#' }

#' #' @export
#' #' @noRd
#' #' @method top_frac egor
#' top_frac.egor <- function(x, n, wt) {
#'   result <- top_frac(x[[attr(x, "active")]], n, wt)
#'   return_egor_with_result(x, result) 
#' }

# Set operations intersect x---------------------------------------------

# This could be improved to check what y is and in case it is another egor object,
# select the same data level and operate on those

#' @export
#' @noRd
#' @method intersect egor
intersect.egor <- function(x, y, ...) {
  result <- intersect(x[[attr(x, "active")]], y, ...)
  result <- bind_IDs_if_missing(x, result)
  return_egor_with_result(x, result) 
}

#' @export
#' @noRd
#' @method union egor
union.egor <- function(x, y, ...) {
  result <- union(x[[attr(x, "active")]], y, ...)
  result <- bind_IDs_if_missing(x, result)
  return_egor_with_result(x, result) 
}

#' @export
#' @noRd
#' @method union_all egor
union_all.egor <- function(x, y, ...) {
  result <- union_all(x[[attr(x, "active")]], y, ...)
  result <- bind_IDs_if_missing(x, result)
  return_egor_with_result(x, result) 
}

#' @export
#' @noRd
#' @method setdiff egor
setdiff.egor <- function(x, y, ...) {
  result <- setdiff(x[[attr(x, "active")]], y, ...)
  result <- bind_IDs_if_missing(x, result)
  return_egor_with_result(x, result) 
}

#' @export
#' @noRd
#' @method setequal egor
setequal.egor <- function(x, y, ...) {
  result <- setequal(x[[attr(x, "active")]], y, ...)
  result <- bind_IDs_if_missing(x, result)
  return_egor_with_result(x, result) 
}
