% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplyr_methods.r
\name{append_egor}
\alias{append_egor}
\alias{append_rows}
\alias{append_cols}
\title{Append rows/columns to ego, alter or aatie data}
\usage{
append_rows(.egor, ..., .id = NULL)

append_cols(.egor, ...)
}
\arguments{
\item{.egor}{An \code{egor} object.}

\item{...}{Data frames to combine.}

\item{.id}{Data frame identifier.}
}
\description{
These work like dplyr's bind_cols() and bind_rows(). The first
argument has to be an egor object. Additional rows/columns are added bottom/RHS
of the active data level (ego, alter, aatie).
}
