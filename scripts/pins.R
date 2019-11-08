library(pins)

## https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line
board_register("github", repo = "bmuchmore/pins", token = "ed2ba6e03308da57c70d082596fade65d25b273e")

### flu ###
library(formr)
formr_connect(email = "bmuchmore@gmail.com", password = "dogsdogs" )
vtflusurvey_results <- formr_results("vtflusurvey")
vtprovidersurvey_results <- formr_results("vtprovidersurvey")
pin(vtflusurvey_results, name = "flu", description = "South End CHC flu data", board = "github")
pin(vtprovidersurvey_results, name = "flu", description = "South End CHC flu data", board = "github")
### flu ###



