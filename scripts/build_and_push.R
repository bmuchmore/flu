## https://popgen.nescent.org/CONTRIBUTING_WITH_GIT2R.html
## https://github.com/settings/tokens
library(git2r)

# system(
#   'echo brian | sudo -S echo ',
#   intern = FALSE,
#   ignore.stdout = FALSE,
#   ignore.stderr = FALSE,
#   wait = TRUE,
#   input = NULL,
#   timeout = 0
# )

rmarkdown::render("/home/brian/Desktop/flu/static/flu_dashboard.Rmd")

repo <- repository(path = "/home/brian/Desktop/flu", discover = TRUE)
remote_add(repo, name = "flu", url = "https://github.com/bmuchmore/flu.git")
remotes(repo)
checkout(repo, "master")
fetch(repo, name = "flu")
merge(repo, "flu/master")
git2r::add(repo, "*")
status(repo)
commit(repo, message = ".", all = TRUE, session = TRUE)
cred <- cred_token()
push(repo, credentials = cred)