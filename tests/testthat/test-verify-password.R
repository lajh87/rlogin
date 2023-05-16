test_that("Verify Password", {

  db <- connect_sqlite()
  setup_db_schema(db, interactive = FALSE)
  create_dummy_user(db)

  input <- list(
    username = "testuser",
    password = "Password1!"
  )

  expect_true(verify_password(db, input$username, input$password))

  pool::poolClose(db)
})
