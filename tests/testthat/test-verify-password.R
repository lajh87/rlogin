test_that("Verify Password", {
  input <- list(
    username = "testuser",
    password = "Password1!"
  )

  expect_true(verify_password())
})
