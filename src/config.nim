import os
import parsecfg
import uri

type ZwsApiConfig = object
  url*: Uri
  token*: string

type ZwsShortenedConfig = object
  baseUrl*: Uri

type ZwsConfig* = object
  api*: ZwsApiConfig
  shortened*: ZwsShortenedConfig

let configPath* = getConfigDir() / "zws.ini"

let configExists* = configPath.fileExists()

var userConfig*: Config = if configExists: configPath.loadConfig() else: newConfig()

const defaultApiUrl = "https://api.zws.im"
let apiUrl = userConfig.getSectionValue("Api", "url", defaultApiUrl)

var cfg* = ZwsConfig(
  api: ZwsApiConfig(
    url: apiUrl.parseUri(),
    token: userConfig.getSectionValue("Api", "token")
  ),
  shortened: ZwsShortenedConfig(
    baseUrl: userConfig.getSectionValue("Shortened", "baseUrl", if apiUrl ==
        defaultApiUrl: "https://zws.im" else: apiUrl).parseUri()
  )
)
