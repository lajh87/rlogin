test_that("Verify Password", {
  create_dummy_user()

  input <- list(
    username = "testuser",
    password = "Password1!"
  )

  expect_true(verify_password(input$username, input$password))
})
