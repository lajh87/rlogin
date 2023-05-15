test_that("setup-schema works", {
  setup_db_schema(interactive = FALSE)
  db <- connect_mysql()
  expect_true(all(c("auth_tokens", "auth_users") %in% DBI::dbListTables(db)))
  expect_true(nrow(DBI::dbGetQuery(db, "SELECT * FROM auth_tokens"))==0)
  expect_true(nrow(DBI::dbGetQuery(db, "SELECT * FROM auth_users"))==0)
  DBI::dbDisconnect(db)
})
