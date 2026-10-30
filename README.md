# fnm.fish
Improved hooks for fnm for Fish shell, only calling fnm when changes are detected.

## Installation

Install with [Fisher][]:

```console
fisher install martonperei/fnm.fish
```

[fisher]: https://github.com/jorgebucaran/fisher

The plugin runs `fnm env --corepack-enabled --resolve-engines --version-file-strategy=recursive`
itself when fish starts, so `config.fish` needs no `fnm env` line. It runs it then rather than on
the first prompt so that node's folder is on PATH before a direnv hook first loads an `.envrc`:
direnv undoes an `.envrc` by putting PATH back as it was before the load, which would drop a folder
added after it.

## Differences from `fnm env --use-on-cd`

- Keeps track of the currently loaded node version file, and only calls fnm when necessary.
  Even though fnm is very fast, the shell is still faster to check for files.
- Respects `--resolve-engines`
- Remembers the version file it found for each folder it searched, so a `cd` reuses the
  search for the folders above instead of repeating it.
- Calls `fnm use` on first prompt instead of shell initialization.
