verify_pwd <- function(db, user_var, user_pw){
  db |>
    dplyr::tbl("user_pwd_auth") |>
    dplyr::filter(user = user_var) |>
    dplyr::pull(password_hash)

  sodium::password_verify(user_pw, password_hash)
}
