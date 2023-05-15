#' Setup db schema
#'
#' Create two tables in a MySQL database called auth_tokens, and auth_user
#'
#' @param db Database connection from \code{\link{connect_mysql}} or \code{\link{connect_sqlite}}.
#' @param interactive Boolean TRUE/FALSE variable. Specifies whether in interactive session.
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#' setup_db_schema()
#' }
setup_db_schema <- function(
    db,
    interactive = TRUE
    ){

  # If any auth tables exist require user confirms overwrite ----
  if(interactive){
    if(any(c("auth_tokens", "auth_users") %in% DBI::dbListTables(db))){
      user_input <- readline("Table exists, are you sure want to overwrite (y/n)  ")
      if(user_input != 'y') stop('Exiting since you did not press y')
    }
  }

  # Build User Table ----
  DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_users`;")
  users_q <- readLines(system.file("sql/create_auth_users.SQL", package = "rlogin")) |>
    paste(collapse = "\n")
  DBI::dbExecute(db, users_q)

  # Build Tokens Table ----
  DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_tokens`;")
  tokens_q <- readLines(system.file("sql/create_auth_tokens.SQL", package = "rlogin")) |>
    paste(collapse = "\n")

  DBI::dbExecute(db, tokens_q)
}


