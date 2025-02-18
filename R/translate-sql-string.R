# R prefers to specify start / stop or start / end
# databases usually specify start / length
# https://www.postgresql.org/docs/current/functions-string.html
#' @export
#' @rdname sql_variant
sql_substr <- function(f = "SUBSTR") {
  function(x, start, stop) {
    start <- max(check_integer(start, "start"), 1L)
    stop <- max(check_integer(stop, "stop"), 1L)
    length <- max(stop - start + 1L, 0L)

    sql_call2(f, x, start, length)
  }
}

check_integer <- function(x, arg) {
  if (length(x) != 1 || !is.numeric(x)) {
    cli_abort("{.arg {arg}} must be a single number")
  }
  as.integer(x)
}

# str_sub(x, start, end) - start and end can be negative
# SUBSTR(string, start, length) - start can be negative

#' @export
#' @rdname sql_variant
sql_str_sub <- function(
                        subset_f = "SUBSTR",
                        length_f = "LENGTH",
                        optional_length = TRUE
  ) {
  function(string, start = 1L, end = -1L) {
    stopifnot(length(start) == 1L, length(end) == 1L)
    start <- check_integer(start, "start")
    end <- check_integer(end, "stop")

    start_sql <- start_pos(string, start, length_f)

    if (optional_length && end == -1L) {
      sql_call2(subset_f, string, start_sql)
    } else {
      if (end == 0L) {
        length_sql <- 0L
      } else if(start > 0 && end < 0) {
        n <- start - end - 2L
        if (n == 0) {
          length_sql <- sql_call2(length_f, string)
        } else {
          length_sql <- sql_expr(!!sql_call2(length_f, string) - !!n)
        }
      } else {
        length_sql <- pmax(end - start + 1L, 0L)
      }
      sql_call2(subset_f, string, start_sql, length_sql)
    }
  }
}

start_pos <- function(string, start, length_f) {
  if (start == -1) {
    sql_call2(length_f, string)
  } else if (start < 0) {
    sql_expr(!!sql_call2(length_f, string) - !!abs(start + 1L))
  } else {
    start
  }
}

sql_str_trim <- function(string, side = c("both", "left", "right")) {
  side <- match.arg(side)
  switch(side,
    left = sql_expr(ltrim(!!string)),
    right = sql_expr(rtrim(!!string)),
    both = sql_expr(ltrim(rtrim(!!string))),
  )
}
globalVariables(c("ltrim", "rtrim"))
