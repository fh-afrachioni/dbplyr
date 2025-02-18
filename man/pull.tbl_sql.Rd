% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/verb-pull.R
\name{pull.tbl_sql}
\alias{pull.tbl_sql}
\title{Extract a single column}
\usage{
\method{pull}{tbl_sql}(.data, var = -1)
}
\arguments{
\item{.data}{A lazy data frame backed by a database query.}

\item{var}{A variable specified as:
\itemize{
\item a literal variable name
\item a positive integer, giving the position counting from the left
\item a negative integer, giving the position counting from the right.
}

The default returns the last column (on the assumption that's the
column you've created most recently).

This argument is taken by expression and supports
\link[rlang:topic-inject]{quasiquotation} (you can unquote column
names and column locations).}
}
\value{
A vector of data.
}
\description{
This is a method for the dplyr \code{\link[=pull]{pull()}} generic. It evaluates the query
retrieving just the specified column.
}
\examples{
library(dplyr, warn.conflicts = FALSE)

db <- memdb_frame(x = 1:5, y = 5:1)
db \%>\%
  mutate(z = x + y * 2) \%>\%
  pull()
}
