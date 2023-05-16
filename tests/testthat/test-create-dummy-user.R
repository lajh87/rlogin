test_that("Create Dummy Users Works", {

  db <- connect_sqlite()
  setup_db_schema(db)
  create_dummy_user(db)
  tbl_rows <- db |>
    dplyr::tbl("auth_users") |>
    dplyr::filter(username == "testuser") |>
    dplyr::collect()
  pool::poolClose(db)
  expect_true(nrow(tbl_rows)>0)
})
