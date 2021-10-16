import uri
import json
import strutils
import strformat
import terminal
import options
import logging
import ./config
import ./api
import ./common

const NimblePkgVersion {.strdefine.} = "Unknown"

var logger = newConsoleLogger()
addHandler(logger)

proc normalizeUrl(url: string): Uri =
  result = url.parseUri()

  if not result.isAbsolute():
    result.scheme = "https"

proc writeHelp*(errorcode: int) =
  quit("""
Usage:
  zws [options] <url>
  zws [options] shorten <url>
  zws [options] stats [url]
Subcommands:
  shorten (default) shorten the provided URL
  stats             return stats for the provided URL, or total stats if not provided
Options:
  -h, --help        print help and exit
  -v, --version     print version and exit
  --json            output JSON
  --plain           output without formatting
  --no-input        disable reading from stdin""", errorcode)

proc writeVersion* =
  quit(NimblePkgVersion, QuitSuccess)

proc writeShortenUrl*(url: string, outputKind: OutputKind) =
  try:
    var shortened = url.normalizeUrl().shorten()

    if shortened.url.isNone:
      if stdin.isatty:
        warn("Usage of configuration option `Shortened.baseUrl` is deprecated")

      shortened.url = some($(cfg.shortened.baseUrl/shortened.short))

    if outputKind == OutputJson:
      quit($(%*shortened), QuitSuccess)
    else:
      quit(shortened.url.get, QuitSuccess)
  except ApiException as exception:
    if outputKind == OutputJson:
      quit($(%*exception.body), QuitFailure)
    else:
      quit($exception.body, QuitFailure)
  except:
    raise

proc writeStats*(outputKind: OutputKind) =
  case outputKind
  of OutputFormatted:
    let instanceStats = totalStats(true)

    quit(&"""
URLs shortened: {instanceStats.urls}
URLs visited: {instanceStats.visits}
API version: {instanceStats.version}""", QuitSuccess)
  of OutputPlain:
    let instanceStats = totalStats()

    quit(&"""
URLs shortened: {instanceStats.urls}
URLs visited: {instanceStats.visits}
API version: {instanceStats.version}""", QuitSuccess)
  of OutputJson:
    let instanceStats = totalStats()
    quit($(%*instanceStats), QuitSuccess)

proc writeStats*(url: string, outputKind: OutputKind) =
  try:
    var urlStats = url.normalizeUrl().stats()

    case outputKind
    of OutputPlain:
      quit(&"Visits: {urlStats.visits.len}", QuitSuccess)
    of OutputFormatted:
      quit(&"Visits: {($urlStats.visits.len).insertSep(',')}", QuitSuccess)
    of OutputJson:
      quit($(%*urlStats), QuitSuccess)
  except ApiException as exception:
    if outputKind == OutputJson:
      quit($(%*exception.body), QuitFailure)
    else:
      quit($exception.body, QuitFailure)
  except:
    raise
