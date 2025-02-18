test_that("custom scalar functions translated correctly", {
  local_con(simulate_oracle())

  expect_equal(translate_sql(as.character(x)), sql("CAST(`x` AS VARCHAR2(255))"))
  expect_equal(translate_sql(as.integer64(x)), sql("CAST(`x` AS NUMBER(19))"))
  expect_equal(translate_sql(as.double(x)),    sql("CAST(`x` AS NUMBER)"))
  expect_equal(translate_sql(as.Date(x)),    sql("DATE `x`"))
})

test_that("paste and paste0 translate correctly", {
  local_con(simulate_oracle())

  expect_equal(translate_sql(paste(x, y)), sql("`x` || ' ' || `y`"))
  expect_equal(translate_sql(paste0(x, y)), sql("`x` || `y`"))
  expect_equal(translate_sql(str_c(x, y)), sql("`x` || `y`"))
})

test_that("queries translate correctly", {
  mf <- lazy_frame(x = 1, con = simulate_oracle())
  expect_snapshot(mf %>% head())
})

test_that("queries do not use *", {
  lf <- lazy_frame(x = 1L, con = simulate_oracle())
  expect_equal(
    lf %>% mutate(y = x) %>% remote_query(),
    sql("SELECT `x`, `x` AS `y`\nFROM (`df`) ")
  )
})

test_that("`sql_query_upsert()` is correct", {
  df_y <- lazy_frame(
    a = 2:3, b = c(12L, 13L), c = -(2:3), d = c("y", "z"),
    con = simulate_oracle(),
    .name = "df_y"
  ) %>%
    mutate(c = c + 1)

  expect_snapshot(
    sql_query_upsert(
      con = simulate_oracle(),
      x_name = ident("df_x"),
      y = df_y,
      by = c("a", "b"),
      update_cols = c("c", "d"),
      returning_cols = c("a", b2 = "b"),
      method = "merge"
    )
  )
})

test_that("generates custom sql", {
  con <- simulate_oracle()

  expect_snapshot(sql_table_analyze(con, in_schema("schema", "tbl")))
  expect_snapshot(sql_query_explain(con, sql("SELECT * FROM foo")))

  lf <- lazy_frame(x = 1, con = con)
  expect_snapshot(left_join(lf, lf, by = "x", na_matches = "na"))

  expect_snapshot(sql_query_save(con, sql("SELECT * FROM foo"), in_schema("schema", "tbl")))
  expect_snapshot(sql_query_save(con, sql("SELECT * FROM foo"), in_schema("schema", "tbl"), temporary = FALSE))
})
