app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

app$setInputs(`login-username` = "testuser")
app$setInputs(`login-password` = "Password1!")
app$setInputs(`login-login` = "click")
app$snapshot()
