import os
import parsecfg
import rdstdin
import httpclient
import json
import terminal
import uri
import options
import parseopt
import strformat
import ./commands

var http = newHttpClient()

var apiUrl: Uri = "https://api.zws.im".parseUri()
var shortenedBaseUrl: Uri = "https://zws.im".parseUri()
var apiToken: string

let configPath = getConfigDir() / "zws.ini"

var url: Uri

var optParser = initOptParser(shortNoVal = {'h', 'v'}, longNoVal = @["help", "version", "json", "no-input"])

type OutputKind {.pure.} = enum
    OutputPlain, OutputJson

var outputKind = OutputPlain
var noInput = false

for kind, key, _ in optParser.getopt():
  case kind
  of cmdEnd: doAssert false
  of cmdShortOption, cmdLongOption:
    case key
    of $'h', "help":
      help()
    of $'v', "version":
      version()
    of "json":
      outputKind = OutputJson
    of "no-input":
      noInput = true
  of cmdArgument:
    if url != "".parseUri():
      quit("Too Many Arguments: Only one URL may be provided")

    url = key.parseUri()

if url == "".parseUri():
  if stdin.isatty() or noInput:
    help()
  else:
    url = readLineFromStdin("").parseUri()

if not url.isAbsolute():
  url.scheme = "https"

if configPath.fileExists():
  let config = configPath.loadConfig()

  let configApiUrl = config.getSectionValue("Api", "url")

  if configApiUrl != "":
    apiUrl = configApiUrl.parseUri()

  let configApiToken = config.getSectionValue("Api", "token")

  if configApiToken != "":
    apiToken = configApiToken

  let configShortenedBaseUrl = config.getSectionValue("Shortened", "baseUrl")

  if configShortenedBaseUrl != "":
    shortenedBaseUrl = configShortenedBaseUrl.parseUri()

let headers = newHttpHeaders({"Content-Type": "application/json"})

if apiToken != "":
  headers["Authorization"] = apiToken

let response = http.request($apiUrl, HttpPost, $(%*{"url": $url}), headers)

type ShortenedUrl = object
  short: string

type Error = object
  statusCode: 400 .. 599
  message: string
  error: string
  code: Option[string]

let body = response.body().parseJson()

if response.status != $Http201:
  let error = body.to(Error)

  let code = if error.code.isSome: fmt" [{error.code.get()}]" else: ""

  var message = fmt"{error.statusCode} {error.error}{code}: {error.message}"

  quit(message)

let shortened = body.to(ShortenedUrl)

let short = shortened.short

assert short != ""

shortenedBaseUrl.path.add(short)

let shortUrl = $shortenedBaseUrl

case outputKind:
of OutputPlain:
  echo shortUrl
of OutputJson:
  echo %*{"url": shortUrl}
