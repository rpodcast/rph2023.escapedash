# ensure .Renviron has the proper environment variables set up
library(DBI)
library(RPostgres)
library(dplyr)

devtools::load_all()

# production mode (use hosted PostgreSQL on Digital Ocean)
Sys.setenv(R_CONFIG_ACTIVE = "production")

db_type <- get_golem_config("db_type")

# docker container postgres db
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv(glue::glue("PG_{db_type}_HOST")),
  dbname = Sys.getenv(glue::glue("PG_{db_type}_DB")),
  port = Sys.getenv(glue::glue("PG_{db_type}_PORT")),
  user = Sys.getenv(glue::glue("PG_{db_type}_USER")),
  password = Sys.getenv(glue::glue("PG_{db_type}_PASS"))
)

user_df_db <- DBI::dbReadTable(con, "userdata")
