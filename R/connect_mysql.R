#' Title
#'
#' @param dbname 
#' @param host 
#' @param port 
#' @param user 
#' @param password 
#'
#' @return
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

