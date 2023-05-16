test_that("setup-schema works", {
  db <- connect_sqlite()
  setup_db_schema(db, interactive = FALSE)
  expect_true(all(c("auth_tokens", "auth_users") %in% DBI::dbListTables(db)))
  expect_true(nrow(DBI::dbGetQuery(db, "SELECT * FROM auth_tokens"))==0)
  expect_true(nrow(DBI::dbGetQuery(db, "SELECT * FROM auth_users"))==0)
  pool::poolClose(db)
})
