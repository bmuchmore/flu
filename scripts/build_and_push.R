## https://popgen.nescent.org/CONTRIBUTING_WITH_GIT2R.html
library(git2r)

# system(
#   'echo brian | sudo -S echo GITHUB_PAT="4de08ff7a956625cb232c57477358a6b9a0d93cc"',
#   intern = FALSE,
#   ignore.stdout = FALSE,
#   ignore.stderr = FALSE,
#   wait = TRUE,
#   input = NULL,
#   timeout = 0
# )

repo <- repository(path = "/home/brian/Desktop/flu", discover = TRUE)
remote_add(repo, name = "upstream", url = "https://github.com/bmuchmore/flu.git")
remotes(repo)
checkout(repo, "master")
fetch(repo, name = "upstream")
merge(repo, "upstream/master")
add(repo, "*")
status(repo)
commit(repo, ".", session = TRUE)







cred <- cred_token()
push(repo, credentials = cred)