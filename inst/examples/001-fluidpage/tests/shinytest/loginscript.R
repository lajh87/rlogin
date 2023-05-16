app <- ShinyDriver$new("../../")
app$snapshotInit("loginscript")

app$setInputs(`login-username` = "testuser")
app$setInputs(`login-password` = "Password1!")
app$setInputs(`login-login` = "click")
# Input 'cookies' was set, but doesn't have an input binding.
app$snapshot()
