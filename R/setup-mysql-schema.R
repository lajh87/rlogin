#' Setup db schema
#'
#' Create two tables in a MySQL database called auth_tokens, and auth_user
#'
#' @inheritParams connect_mysql
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#' setup_db_schema()
#' }
setup_db_schema <- function(
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD"),
    interactive = TRUE
    ){

  # Connect to database ----
  db <- connect_mysql( dbname, host, port, user, password)

  # If any auth tables exist require user confirms overwrite ----
  if(interactive){
    if(any(c("auth_tokens", "auth_users") %in% DBI::dbListTables(db))){
      user_input <- readline("Table exists, are you sure want to overwrite (y/n)  ")
      if(user_input != 'y') stop('Exiting since you did not press y')
    }
  }

  # Build User Table
  DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_users`;")
  users_q <- readLines(system.file("sql/create_auth_users.SQL", package = "rlogin")) |>
    paste(collapse = "\n")

  DBI::dbExecute(db, users_q)

  # Build Tokens Table
  DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_tokens`;")
  tokens_q <- readLines(system.file("sql/create_auth_tokens.SQL", package = "rlogin")) |>
    paste(collapse = "\n")

  DBI::dbExecute(db, tokens_q)

  # Disconnect
  DBI::dbDisconnect(db)
}

#' Create a dummy user
#'
#' Create dummy user
#'
#' @inheritParams connect_mysql
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#' create_dummy_user()
#' }
create_dummy_user <- function(
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD")
){

  db <- connect_mysql(dbname, host, port, user, password)

  username <- "testuser"
  passwordhash <- sodium::password_store("Password1!")

  q <- glue::glue("
  INSERT INTO auth_users(username, passwordhash)
  VALUES ('{username}', '{passwordhash}');
  ")

  DBI::dbExecute(db, q)
  DBI::dbDisconnect(db)

}
