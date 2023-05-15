#' Verify Password
#'
#' Function to verify hashed password.
#'
#' @param input_username User inputted user name.
#' @param input_password User inputted password.
#' @inheritParams connect_mysql
#'
#' @return Logical value of TRUE or FALSE depending on whether the password is verified.
#' @export
#'
#' @examples
#' \dontrun{
#' verify_password()
#' }
verify_password <- function(
    input_username = input$username,
    input_password = input$password,
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD")
    ){

  db <- connect_mysql(dbname, host, port, user, password)

  password_hash <- db |>
    dplyr::tbl("auth_users") |>
    dplyr::filter(username == input_username) |>
    dplyr::pull(passwordhash)

  DBI::dbDisconnect(db)

  if(length(password_hash)==0) return(FALSE)

  password_hash <- password_hash[1]
  sodium::password_verify(password_hash, input_password)
}
