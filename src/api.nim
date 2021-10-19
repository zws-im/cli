import httpclient
import options
import uri
import json
import strformat
import logging
import ./config

var http* = newHttpClient()

type ShortenedUrl* = object
  short*: string
  url*: Option[string]

type ApiError* = object
  statusCode*: 400 .. 599
  message*: string
  error*: string
  code*: Option[string]

type ApiException* = ref object of HttpRequestError
  body*: ApiError

proc `$`*(x: ApiError): string =
  let code = if x.code.isSome: fmt" [{x.code.get()}]" else: ""

  result = fmt"{x.statusCode} {x.error}{code}: {x.message}"

type InstanceStats*[T: string or Natural] = object
  urls*: T
  visits*: T
  version*: string

type UrlStats* = object
  url*: string
  visits*: seq[int]

proc tryParseJson(body: string): JsonNode =
  try:
    result = body.parseJson()
  except ValueError:
    error("The response was not valid JSON. Raw body: ", body)
    raise

proc printBadJson(body: JsonNode): void =
  error("The response JSON was in an invalid format. Parsed body: ", body.pretty())

proc handleApiError(body: JsonNode): void =
  try:
    let apiError = body.to(ApiError)

    var error = ApiException(body: apiError, msg: apiError.message)

    raise error
  except ValueError:
    printBadJson(body)
    raise

proc totalStats*(format: static bool = false): InstanceStats[string] or
    InstanceStats[Natural] =
  var route = cfg.api.url/"stats"

  when format:
    route.query = "format=true"

  let response = http.get($route)

  let body = response.body().tryParseJson()

  if response.status != $Http200:
    handleApiError(body)

  try:
    when format:
      result = body.to(InstanceStats[string])
    else:
      result = body.to(InstanceStats[Natural])
  except ValueError:
    printBadJson(body)
    raise

let baseUrlLength = ($cfg.shortened.baseUrl).len

proc stats*(shortenedUrl: Uri): UrlStats =
  let short = ($shortenedUrl)[baseUrlLength .. ^1]

  var route = cfg.api.url/short/"stats"

  let response = http.get($route)

  let body = response.body().tryParseJson()

  if response.status != $Http200:
    handleApiError(body)

  try:
    result = body.to(UrlStats)
  except ValueError:
    printBadJson(body)
    raise

proc shorten*(url: Uri): ShortenedUrl =
  let headers = newHttpHeaders({"Content-Type": "application/json"})

  if cfg.api.token != "":
    headers["Authorization"] = &"Bearer {cfg.api.token}"

  let response = http.request($cfg.api.url, HttpPost, $(%*{"url": $url}), headers)

  let body = response.body().tryParseJson()

  if response.status != $Http201:
    handleApiError(body)

  try:
    result = body.to(ShortenedUrl)
  except ValueError:
    printBadJson(body)
    raise
