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


create_dummy_user <- function(
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD")
){

  db <- connect_mysql( dbname, host, port, user, password)

  tmp <- data.frame(userid = 1,
             username = "lajh87@me.com",
             passwordhash = sodium::password_store("Pushkin"),
             stringsAsFactors = FALSE)

  passwordhash <- sodium::password_store("Pushkin")
  q <- glue::glue("
  INSERT INTO auth_users
  VALUES (1, 'lajh87', '{passwordhash}');
  ")

  DBI::dbExecute(db, q)
  DBI::dbDisconnect(db)

}
