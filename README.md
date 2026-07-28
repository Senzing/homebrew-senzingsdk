# homebrew-senzingsdk

> [!WARNING]
> **Preview Release — Unsupported**
>
> This is a preview release. It is provided as-is with no warranty and is
> **not supported**.

## Synopsis

A [Homebrew tap](https://docs.brew.sh/Taps) to publish the Senzing SDK for macOS.

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)

## Install

Tap this repository and install the `senzingsdk` cask:

```sh
brew tap senzing/senzingsdk https://github.com/Senzing/homebrew-senzingsdk
brew install --cask senzingsdk
```

Installing the cask requires acceptance of the
[Senzing End User License Agreement](https://senzing.com/end-user-license-agreement).
You will be prompted interactively. To accept non-interactively (for example,
in a CI environment), set the following environment variable before running
`brew install`:

```sh
HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula brew install --cask senzingsdk
```

The cask declares dependencies on `sqlite` and `openssl@3`, which Homebrew will
install automatically if they are not already present.

## Configure your shell

After installation, add the following to your shell configuration
(`~/.zshrc` or `~/.bash_profile`):

```sh
export SENZING_ROOT="$(brew --prefix)/opt/senzing/er"
export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
export PATH="${SENZING_ROOT}/bin:$PATH"
```

Alternatively, source the setup script provided with the SDK:

```sh
source "$(brew --prefix)/opt/senzing/er/setupEnv"
```

Note that neither the exports above nor `setupEnv` set an engine
configuration — see the next section.

## Configure the Senzing engine

The SDK is initialized with an engine configuration string. Most examples and
POC tools read it from `SENZING_ENGINE_CONFIGURATION_JSON`:

```sh
export SENZING_ENGINE_CONFIGURATION_JSON='{
  "PIPELINE": {
    "CONFIGPATH": "'"$(brew --prefix)"'/opt/senzing/er/etc",
    "RESOURCEPATH": "'"$(brew --prefix)"'/opt/senzing/er/resources",
    "SUPPORTPATH": "'"$(brew --prefix)"'/opt/senzing/data"
  },
  "SQL": {
    "CONNECTION": "sqlite3://na:na@'"$(brew --prefix)"'/opt/senzing/er/var/sqldb/G2C.db"
  }
}'
```

**`SUPPORTPATH` is not under `SENZING_ROOT`.** `SENZING_ROOT` points at the
`er` directory, but the support data is `er`'s _sibling_:

```text
$(brew --prefix)/opt/senzing/
├── er/          <- SENZING_ROOT
│   ├── etc/         -> CONFIGPATH
│   └── resources/   -> RESOURCEPATH
└── data/        <- SUPPORTPATH (a sibling of er, not inside it)
```

`CONFIGPATH` and `RESOURCEPATH` are under `er`, so deriving them from
`${SENZING_ROOT}` is correct. `SUPPORTPATH` is the exception:
`${SENZING_ROOT}/data` resolves to `.../opt/senzing/er/data`, which does not
exist, and the engine then fails with `SENZ7426` on the first `SzEngine` or
`SzDiagnostic` call. See [docs/errors.md](docs/errors.md#senz7426).

## Upgrade

```sh
brew update
brew upgrade --cask senzingsdk
```

## Uninstall

```sh
brew uninstall --cask senzingsdk
brew untap senzing/senzingsdk
```
