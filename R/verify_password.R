#' Verify Password
#'
#' Function to verify hashed password.
#'
#' @param db Database connection object
#' @param input_username User inputted user name.
#' @param input_password User inputted password.
#'
#' @return Logical value of TRUE or FALSE depending on whether the password is verified.
#' @export
#'
#' @examples
#' \dontrun{
#' verify_password(db, input$username, input$password)
#' }
verify_password <- function(db, input_username, input_password)
  {

  password_hash <- db |>
    dplyr::tbl("auth_users") |>
    dplyr::filter(.data$username == input_username) |>
    dplyr::pull(.data$passwordhash)

  if(length(password_hash)==0) return(FALSE)

  password_hash <- password_hash[1]
  sodium::password_verify(password_hash, input_password)
}
