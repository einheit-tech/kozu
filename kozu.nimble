# Package
version = "0.1.0"
author = "Einheit Technologies"
description = "Pride of Kozu"
license = "Einheit Technologies License"
srcDir = "src"
bin = @["prideofkozu"]

# Dependencies
requires "nim == 1.6.6"
requires "https://github.com/avahe-kellenberger/shade"

task runr, "Runs the game":
  exec "nim r -d:release src/kozu.nim"

