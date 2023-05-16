#' Set Authentication Cookie
#'
#' Set an authentication cookie and store values in database for lookup
#'
#' @param db Database connection
#' @param userid User id
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{set_auth_cookie(db, userid)}
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
    "INSERT INTO auth_tokens (id, selector, hashedValidator, userid, expires) ",
    "VALUES({id}, '{selector}', '{hashed_validator}', '{userid}', '{expires}'); "
  )

  DBI::dbExecute(db, q)

}

#' Get Authentication Token
#'
#' Get token and cross reference against stored data
#'
#' @param db Database connection object
#'
#' @return If authenticated then return verified userid
#' @export
#'
#' @examples \dontrun{get_auth_token(db)}
get_auth_token <- function(db, token){

  if(is.null(token)) return(NULL)

  token_split <- stringr::str_split(token, ":") |> unlist()
  selector_var <- token_split[1]
  validator_var <- token_split[2]

  hashed_validator_var <- sodium::hex2bin(validator_var) |>
    sodium::sha256() |>
    sodium::bin2hex()

  db_hashed_validator_var <- db |>
    dplyr::tbl("auth_tokens") |>
    dplyr::filter(.data$selector == selector_var) |>
    dplyr::pull(.data$hashedValidator)

  if(length(db_hashed_validator_var) ==0)
    return(NULL) #escape

  userid <- db |>
    dplyr::tbl("auth_tokens") |>
    dplyr::filter(.data$selector == selector_var) |>
    dplyr::pull(.data$userid)

  if(length(userid)==0)
    return(NULL)

  if(db_hashed_validator_var == hashed_validator_var){
    return(userid)
  } else{
    cookies::remove_cookie("auth_token")
    remove_token(db, token)
  }

}

remove_token <- function(db, token){
  if(is.null(token)) return(NULL)

  token_split <- stringr::str_split(token, ":") |> unlist()
  selector_var <- token_split[1]

  q <- glue::glue("DELETE FROM auth_tokens WHERE selector = '{selector_var}';")
  DBI::dbExecute(db, q)

}
