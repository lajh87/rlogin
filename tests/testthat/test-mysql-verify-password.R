test_that("MySQL - Verify Password", {

  db <- connect_db("MySQL", setup = TRUE, testuser = TRUE)

  input <- list(
    username = "testuser",
    password = "Password1!"
  )

  expect_true(verify_password(db, input$username, input$password))

  pool::poolClose(db)
})
