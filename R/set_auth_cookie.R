set_auth_cookie <- function(db, userid){
  selector <- sodium::random(6) |> sodium::bin2hex()
  validator <- sodium::random(32) |> sodium::bin2hex()
  token <- paste(selector, validator, sep  = ":")

  hashed_validator <- sodium::hex2bin(validator) |>
    sodium::sha256() |>
    sodium::bin2hex()

  cookies::set_cookie(
    cookie_name = "auth_token",
    cookie_value = token
  )

  expires <- Sys.Date() + 90
  id <- db |> dplyr::tbl("auth_tokens") |> dplyr::collect() |> nrow() + 1


  q <- glue::glue(
    "INSERT INTO auth_tokens(id, selector, hashedValidator, userid, expires) ",
    "VALUE(id, {selector}, {hashed_validator}, {userid}, {expires}); "
  )

  DBI::dbExecute(db, q)

  }
