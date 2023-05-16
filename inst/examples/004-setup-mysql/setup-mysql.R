library(rlogin)

db <- connect_mysql()
setup_db_schema(db, interactive = FALSE)
create_dummy_user(db)
db <- pool::poolClose(db)
rm(db)
