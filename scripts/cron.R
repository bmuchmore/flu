library(cronR)

# cron_save(
#   file = "/home/brian/Desktop/cron_backup", 
#   overwrite = FALSE, 
#   user = "brian"
# )

system(
  "echo brian | sudo -S kill -9 $(cat /var/run/crond.pid)",
  intern = FALSE,
  ignore.stdout = FALSE,
  ignore.stderr = FALSE,
  wait = TRUE,
  input = NULL,
  timeout = 0
)
system(
  "echo brian | sudo -S cron start",
  intern = FALSE,
  ignore.stdout = FALSE,
  ignore.stderr = FALSE,
  wait = TRUE,
  input = NULL,
  timeout = 0
)

cron_ls()
pins_path <- "/home/brian/Desktop/flu/scripts/pins.R"
pins_cmd <- cron_rscript(
  rscript = pins_path, 
  rscript_log = sprintf("%s.log", tools::file_path_sans_ext(pins_path)), 
  rscript_args = "", 
  cmd = file.path(Sys.getenv("R_HOME"), "bin", "Rscript"),
  log_append = TRUE
  )
cron_add(
  command = pins_cmd, 
  frequency = "hourly", 
  # at, 
  # days_of_month, 
  # days_of_week,
  # months, 
  id = "flu_survey_pin",
  tags = c("pin", "flu"),
  description = "Flu survey pin.", 
  dry_run = FALSE, 
  user = "brian"
)
cron_ls()

# cron_clear(ask = FALSE, user = "brian")
















































