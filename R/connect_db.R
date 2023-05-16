#' Connect to database
#'
#' @param drv Database driver, either SQLite or MySQL
#' @param setup Setup database schema, TRUE/FALSE
#' @param testuser Create a test user, TRUE/FALSE
#' @param ... Other parameters passed to \code{\link{connect_mysql}}
#'
#' @return A database connection object
#' @export
#'
#' @examples \dontrun{
#' connect_db("MySQL", setup = FALSE, testuser = FALSE)
#' connect_db("SQLite", setup = TRUE, testuser = TRUE)
#' connect_db("MySQL", setup = TRUE, testuser = TRUE)
#' }
connect_db <- function(drv = c("MySQL", "SQLite"),
                       setup = FALSE,
                       testuser = FALSE,
                       ...){

  if(!(drv != "MySQL" | drv != "SQLite")) {
    stop("drv must be on of 'MySQL' or 'SQLite'")
  }

  connect <- function(type, ...){
    switch(
      type,
      MySQL = connect_mysql(...),
      SQLite = connect_sqlite()
      )
  }

  schema <- function(type){
    switch(
      type,
      users = system.file("sql/create_auth_users.SQL", package = "rlogin"),
      tokens = system.file("sql/create_auth_tokens.SQL", package = "rlogin")
    ) |>
      readLines() |>
      paste(collapse = "\n")
  }

  db <- connect(drv, ...)

  if(setup) {
    DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_users`;")
    DBI::dbExecute(db, "DROP TABLE IF EXISTS `auth_tokens`;")
    DBI::dbExecute(db, schema("users"))
    DBI::dbExecute(db, schema("tokens"))
    }

  if(testuser){
    create_dummy_user(db)
  }

  return(db)

}

#' Connect MySQL
#'
#' Connect to a MySQL database
#'
#' @param dbname Database name
#' @param host Database host
#' @param port Database post
#' @param user Database username
#' @param password Database password
#'
#' @return A database connection object
#' @export
#'
#' @examples
#' \dontrun{
#'   db <- connect_mysql()
#' }
connect_mysql <- function(
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD")
){

  pool::dbPool(
    RMySQL::MySQL(),
    dbname = dbname,
    host = host,
    port = as.numeric(port),
    user = user,
    password = password
  )
}

#' Connect SQLite
#'
#' Connect to a temporary SQLite database stored in memory
#'
#' @return A SQLite database connection object
#' @export
#'
#' @examples \dontrun{connect_sqlite()}
connect_sqlite <- function(){
  pool::dbPool(RSQLite::SQLite())
}

create_dummy_user <- function(db){

  userid <- nrow(DBI::dbGetQuery(db, "SELECT * FROM auth_users;"))+1
  username <- "testuser"
  passwordhash <- sodium::password_store("Password1!")

  q <- glue::glue("
  INSERT INTO auth_users(userid, username, passwordhash)
  VALUES ({userid}, '{username}', '{passwordhash}');
  ")

  DBI::dbExecute(db, q)

}
