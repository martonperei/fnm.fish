# fnm.fish
Improved hooks for fnm for Fish shell, only calling fnm when changes are detected.

## Installation

Install with [Fisher][]:

```console
fisher install martonperei/fnm.fish
```

[fisher]: https://github.com/jorgebucaran/fisher

Use `fnm env` as usual in `fish.config`:
```console
fnm env --shell fish | source
```

## Differences from `fnm env --use-on-cd`

- Keeps track of the currently loaded node version file, and only calls fnm when necessary.
  Even though fnm is very fast, the shell is still faster to check for files.
- Respects `--resolve-engines`
- Calls `fnm use` on first prompt instead of shell initialization.
