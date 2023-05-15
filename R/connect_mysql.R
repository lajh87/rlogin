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
#' db <- connect_mysql()
#' DBI::dbDisconnect(db)
#' rm(db)
connect_mysql <- function(
    dbname=Sys.getenv("MYSQL_ADDON_DB"),
    host=Sys.getenv("MYSQL_ADDON_HOST"),
    port=Sys.getenv("MYSQL_ADDON_PORT"),
    user=Sys.getenv("MYSQL_ADDON_USER"),
    password=Sys.getenv("MYSQL_ADDON_PASSWORD")
    ){

  DBI::dbConnect(
    RMySQL::MySQL(),
    dbname = dbname,
    host = host,
    port = as.numeric(port),
    user = user,
    password = password
  )
}

