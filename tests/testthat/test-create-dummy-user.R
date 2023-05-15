test_that("Create Dummy Users Works", {
  create_dummy_user()
  db <- connect_mysql()
  tbl_rows <- db |> dplyr::tbl("auth_users") |>
    dplyr::filter(username == "testuser") |>
    dplyr::collect()
  DBI::dbDisconnect(db)
  expect_true(nrow(tbl_rows)>0)
})
