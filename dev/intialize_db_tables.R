# ensure .Renviron has the proper environment variables set up prior to executing the code below

# development mode (use local Docker PostgreSQL container)
#Sys.setenv(R_CONFIG_ACTIVE = "default")

# production mode (use hosted PostgreSQL on Digital Ocean)
Sys.setenv(R_CONFIG_ACTIVE = "production")

library(DBI)
library(RPostgres)
library(dplyr)

# load supporting database function script in the context of this application as a package (golem)
devtools::load_all()

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

if (db_type == "SERVER") {
  quiz_file <- "dev/prototyping/quiz_questions_prod.json"
  image_dir <- "dev/prototyping/images"
} else {
  quiz_file <- "inst/app/quizfiles/quiz_questions_dev.json"
  image_dir <- "inst/app/www/images"
}

import_quiz_data(con, quiz_file = quiz_file, image_dir = image_dir)
create_user_table(con)

DBI::dbDisconnect(con)
