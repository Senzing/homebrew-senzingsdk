# homebrew-senzingsdk errors

Errors commonly hit after installing the SDK via this tap, and what actually
causes them.

## SENZ7426

`EAS_ERR_XLITERATOR_FAILED` — a transliteration module could not be loaded.

```
SENZ7426|Transliteration failed: Could not load transliterator module:
thaiTransRules.sz - GODT031E .../opt/senzing/er/data/thaiTransRules.sz
```

Sometimes reported in its generic form:

```
SENZ7426|EAS_ERR_XLITERATOR_FAILED: Transliteration failed:
No transliteration rules found! Transliteration requires at least one module.
```

**Symptom shape.** `SzProduct` (version, license) works fine, so the install
appears healthy — but *every* call through `SzEngine` or `SzDiagnostic`
(`getEngine()`, `getDiagnostic()`, `addRecord()`) fails immediately.

**Cause.** `SUPPORTPATH` points at a directory with no transliteration modules,
almost always `.../opt/senzing/er/data`, which does not exist. The support data
is `er`'s **sibling**:

```
$(brew --prefix)/opt/senzing/
├── er/          <- SENZING_ROOT
│   ├── etc/         -> CONFIGPATH
│   └── resources/   -> RESOURCEPATH
└── data/        <- SUPPORTPATH  (address_datamodel, *TransRules.sz, nomicon)
```

Two things lead people to the wrong value:

1. **Deriving it from `SENZING_ROOT`.** `${SENZING_ROOT}/etc` and
   `${SENZING_ROOT}/resources` are correct, so `${SENZING_ROOT}/data` looks
   correct too — but `SENZING_ROOT` is the `er` directory, so it resolves to
   `er/data`.
2. **Copying it out of the SDK's own shipped config.**
   `er/etc/sz_engine_config.ini` and
   `er/resources/templates/sz_engine_config.ini` both ship
   `SUPPORTPATH=${INSTALLPATH}/senzing/er/data`. That value is wrong in the
   packages themselves — do not copy it.

**Fix.** Point `SUPPORTPATH` at the sibling `data` directory:

```sh
SUPPORTPATH="$(brew --prefix)/opt/senzing/data"
```

Confirm it is the right directory before suspecting anything else:

```sh
ls "$(brew --prefix)/opt/senzing/data"/*TransRules.sz
```

If that lists files, the path is correct.

**What not to do.** Do not copy or symlink `*TransRules.sz` files into
`er/data`, do not reinstall, and do not switch to Docker to work around this.
The support data ships complete; only the path is wrong. (Symlinking Senzing
libraries in particular causes further, harder-to-diagnose failures.)

**Affected versions.** The wrong `SUPPORTPATH` in the shipped `.ini` files is
present in at least `4.3.2.26162`, `4.3.3.26191` and `4.4.0.26206`, on both the
production and staging channels. The native macOS install works correctly once
`SUPPORTPATH` is set properly — verified end to end (`getEngine()` +
`addRecord()`) on Apple Silicon.
