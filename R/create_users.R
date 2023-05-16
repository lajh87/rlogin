#' Create a dummy user
#'
#' Create dummy user
#'
#' @param db Database connection object.
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#' db <- connect_sqlite()
#' setup_db_schema(db)
#' create_dummy_user(db)
#' }
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
