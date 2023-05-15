#' Connect SQLite
#'
#' Connect to a temporary SQLite database stored in memory
#'
#' @return A SQLite database connection object
#' @export
#'
#' @examples connect_sqlite()
connect_sqlite <- function(){
  pool::dbPool(RSQLite::SQLite())
}
