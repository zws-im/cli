import strformat

const NimblePkgVersion {.strdefine.} = "Unknown"

proc help* =
  quit(&"""
Usage:
  zws [options] url
Options:
  -h, --help    print help and exit
  -v, --version print version and exit
  --json        output JSON
  --no-input    disable reading from stdin""", QuitSuccess)

proc version* =
  quit(NimblePkgVersion, QuitSuccess)
