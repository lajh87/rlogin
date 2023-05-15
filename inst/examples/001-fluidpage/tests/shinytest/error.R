app <- ShinyDriver$new("../../")
app$snapshotInit("error")

app$setInputs(`login-username` = "error")
app$setInputs(`login-password` = "error")
app$setInputs(`login-login` = "click")
app$snapshot()
