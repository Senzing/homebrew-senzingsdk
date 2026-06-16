# Changelog

All notable changes to this project will be documented in this file.

The changelog format is based on [Keep a Changelog] and [CommonMark].
This project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- The `update-cask-version.yaml` workflow now validates the dispatched version and also accepts the hyphen-before-build format (e.g. `4.3.2-26162`), normalizing it to the canonical dot form (`4.3.2.26162`).

### Fixed

- The `update-cask-version.yaml` workflow now creates signed (verified) commits via the GitHub API instead of unsigned local commits.

## [0.1.0] - 2026-05-28

### Changed in 0.1.0

- Install the Senzing SDK from the `.pkg` artifact instead of the `.dmg`. The resulting Caskroom layout and `/opt/homebrew/opt/senzing` symlink are unchanged from previous releases.
- `update-cask-version.yaml` workflow now fetches and hashes the `.pkg` rather than the `.dmg` on automated version bumps.

### Added to 0.1.0

- `depends_on macos: :ventura` (minimum macOS 13) and `depends_on arch: :arm64` (Apple Silicon only). Existing installs on Intel or pre-Ventura systems will be blocked from upgrading.
- `container type: :naked` so Homebrew stages the `.pkg` as a single file rather than running the macOS installer.

### Fixed in 0.1.0

- `uninstall_postflight` no longer removes `/opt/homebrew/opt/senzing` during `brew upgrade --cask senzingsdk`. The symlink is now removed only when it still points at the version being uninstalled, so the new install's symlink survives the old version's teardown.

## [0.0.0] - 2026-02-25

### Added to 0.0.0

- Initial items

[CommonMark]: https://commonmark.org/
[Keep a Changelog]: https://keepachangelog.com/
[Semantic Versioning]: https://semver.org/
