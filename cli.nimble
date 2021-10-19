# Package

version       = "1.5.0"
author        = "Jonah Snider"
description   = "A CLI to interact with ZWS"
license       = "MIT"
srcDir        = "src"
bin           = @["cli"]
namedBin      = {"cli": "zws"}.toTable()

# Dependencies

requires "nim >= 1.4.2"

task dist, "Compile versions for release":
  exec "nimble c --out:zws-linux-amd64   -d:release --os:linux --cpu:amd64                          src/cli.nim"
  exec "nimble c --out:zws-linux-i386    -d:release --os:linux --cpu:i386 --passC:-m32 --passL:-m32 src/cli.nim"
  exec "nimble c --out:zws-windows-amd64 -d:release -d:mingw   --cpu:amd64                          src/cli.nim"
  exec "nimble c --out:zws-windows-i386  -d:release -d:mingw   --cpu:i386                           src/cli.nim"
