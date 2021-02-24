# zws-im/cli

A command line interface for [ZWS][zws] instances.

## Usage

```sh
zws [options] url
```

| Flags             | Description                   |
| ----------------- | ----------------------------- |
| `-h`, `--help`    | Print help and exit.          |
| `-v`, `--version` | Print version and exit.       |
| `--json`          | Output JSON.                  |
| `--no-input`      | Disable reading from `stdin`. |

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

| Key       | Description                                  | Default          |
| --------- | -------------------------------------------- | ---------------- |
| `baseUrl` | The URL shortened IDs should be appended to. | `https://zws.im` |

## Docker

An official Docker image is published [on Docker Hub as `zwsim/cli`](https://hub.docker.com/repository/docker/zwsim/cli/general).

```sh
docker run zwsim/cli [options] url
```

[zws]: https://github.com/zws-im/zws
