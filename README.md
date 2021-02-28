# zws-im/cli

A command line interface for [ZWS][zws] instances.

## Usage

```sh
zws [options] [url]
zws [options] shorten [url]
zws [options] stats [url]
```

| Flags             | Description                   |
| ----------------- | ----------------------------- |
| `-h`, `--help`    | Print help and exit.          |
| `-v`, `--version` | Print version and exit.       |
| `--json`          | Output JSON.                  |
| `--plain`         | Output without formatting.    |
| `--no-input`      | Disable reading from `stdin`. |

## Subcommands

### `shorten` (default)

Shortens the provided URL.

```sh
zws [options] [url]
zws [options] shorten [url]
```

If no URL is provided and `--no-input` is not provided and the terminal is not a TTY it will be read from `stdin`.

### `stats`

View total statistics for the configured ZWS instance.

```sh
zws [options] stats
```

### `stats <url>`

View usage statistics for a shortened URL.

```sh
zws [options] stats <url>
```

## Config

The config is stored as `zws.ini` in [the config directory of the current user for applications](https://nim-lang.org/docs/os.html#getConfigDir) as [the Nim configuration file format](https://nim-lang.org/docs/parsecfg.html).

### Full example

```ini
[Api]
url = "https://api.example.com"
token = "YTdaKVdfGPxdkKaayRwaVHvLXtVkPdPz"

[Shortened]
baseUrl = "https://example.com"
```

### `Api`

| Key     | Description                                                                                          | Default              |
| ------- | ---------------------------------------------------------------------------------------------------- | -------------------- |
| `url`   | The URL of the [ZWS instance][zws].                                                                  | `https://api.zws.im` |
| `token` | The API token to use in requests. Only required for custom instances with authentication configured. |                      |

### `Shortened`

| Key       | Description                                  | Default                                                                           |
| --------- | -------------------------------------------- | --------------------------------------------------------------------------------- |
| `baseUrl` | The URL shortened IDs should be appended to. | `https://zws.im` if `Api.url` is set to default, otherwise the value of `Api.url` |

## Docker

An official Docker image is published [on Docker Hub as `zwsim/cli`](https://hub.docker.com/repository/docker/zwsim/cli/general).

```sh
docker run zwsim/cli [options] url
```

[zws]: https://github.com/zws-im/zws
