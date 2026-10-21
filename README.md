# Minimal Vim (not Neovim)

A compact, Vim-only configuration built around Vim 9.2. It uses no Lua, no
Treesitter, and no Neovim APIs. The live configuration is the real directory
`~/.config/vim`; on this machine `~/Workspace/vim` is a convenience symlink to
it.

The setup is deliberately small: six plugins, the bundled `habamax` colorscheme,
a right-hand netrw tree, fzf, a which-key leader guide, Vim9 LSP, save-time
formatting, and an optional Wayland clipboard provider.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Repository layout](#repository-layout)
- [Plugins](#plugins)
- [Key mappings](#key-mappings)
- [File explorer](#file-explorer)
- [which-key guide](#which-key-guide)
- [Formatting](#formatting)
- [Language servers](#language-servers)
- [Clipboard](#clipboard)
- [fzf and search](#fzf-and-search)
- [Filetype settings](#filetype-settings)
- [Runtime state](#runtime-state)
- [Configuration reference](#configuration-reference)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Known limitations](#known-limitations)

## Features

- Vim 9.2+, with the bundled `habamax` colorscheme.
- Six plugins managed by vim-plug:
  - fzf and fzf.vim
  - vim-commentary
  - vim-surround
  - yegappan/lsp
  - vim-which-key
- Vim9 LSP for Go, Rust, and Lua when the corresponding server is installed.
- Automatic formatting on save for LSP-backed filetypes and Prettier
  filetypes.
- fzf file, buffer, grep, and jumplist pickers.
- A right-side netrw tree with expand/collapse and a custom `?` action sheet.
- Persistent undo, swap files, and Viminfo under `~/.local/state/vim`.
- Optional system clipboard support through `wl-clipboard` on Wayland.

## Requirements

### Vim

- **Vim 9.2 or newer.** The reference build is a Vim 9.2 “huge” build with
  `+popupwin`, `+job`, `+channel`, `+timers`, `+terminal`, and
  `+clipboard_provider`.
- Popup-window support is required by vim-which-key.
- Jobs, channels, and timers are required by the LSP client.
- The custom clipboard provider is used when Vim has `+clipboard_provider`.
  A build with native `+clipboard` or `+wayland_clipboard` does not need it.

### External commands

- `git` and `curl` for bootstrapping and plugin installation.
- `fzf` for all fuzzy pickers.
- `fd` for the default file finder.
- `rg` (ripgrep) for live grep and `:grep`.
- `prettier` for JavaScript, TypeScript, JSON, CSS, HTML, Markdown, and YAML
  formatting.

### Optional language servers

Only servers found on `PATH` are registered:

- `gopls` for Go and `go.mod`.
- `rust-analyzer` for Rust.
- `lua-language-server` for Lua.

### Optional clipboard helper

- `wl-clipboard` (`wl-copy` and `wl-paste`) on a Wayland session.

A UTF-8 terminal is recommended. The configuration uses Unicode characters for
`listchars`, `fillchars`, and `showbreak`.

## Installation

### From this checkout

If this directory is already `~/.config/vim`:

```bash
cd ~/.config/vim
./bootstrap.sh
```

If the checkout lives elsewhere, run the script from that checkout:

```bash
cd /path/to/your/vim-config
./bootstrap.sh
```

`bootstrap.sh`:

1. Verifies that the `vim` command is available.
2. Ensures `~/.config/vim` points at this checkout. It creates the symlink only
   when `~/.config/vim` does not already exist.
3. Warns if `~/.vimrc` or `~/.vim/vimrc` exists, because those files take
   precedence over `~/.config/vim/vimrc`.
4. Creates the runtime state directories under `~/.local/state/vim`.
5. Downloads vim-plug to `autoload/plug.vim` if it is missing.
6. Runs `:PlugInstall --sync` in a headless Vim.

If the script is run from a checkout elsewhere and `~/.config/vim` already
exists as a real directory, the script refuses to replace it. Move that
directory aside, or make it a symlink to this checkout, before rerunning.

### First start

Start Vim normally. Do not pass `-u`; Vim's normal XDG startup should load
`~/.config/vim/vimrc`:

```bash
vim
```

Verify the setup inside Vim:

```vim
:echo $MYVIMRC
:PlugStatus
:messages
:LspShowAllServers
:echo v:clipmethod
```

`$MYVIMRC` should be `/home/<you>/.config/vim/vimrc`. `v:clipmethod` is `none`
when the optional clipboard provider is not active.

If you change the `Plug` list in `vimrc`, run:

```vim
:PlugInstall
:PlugClean
```

## Repository layout

```text
~/.config/vim/
├── README.md
├── bootstrap.sh
├── vimrc
├── .gitignore
├── after/
│   ├── ftplugin/
│   │   ├── gitcommit.vim    commit-message settings
│   │   ├── go.vim           Go tab display
│   │   ├── markdown.vim     prose and spell settings
│   │   └── netrw.vim        netrw `?` action sheet
│   └── plugin/
│       └── clipboard.vim    Vim9 Wayland clipboard provider
├── autoload/
│   └── plug.vim             downloaded by bootstrap.sh, ignored by git
└── plugged/                 plugin checkouts, ignored by git
```

`~/Workspace/vim` is a convenience symlink to `~/.config/vim` on this machine.
Edit the real directory; the symlink is only an alternate path.

Runtime files are deliberately kept out of the repository:

```text
~/.local/state/vim/
├── undo/
├── swap/
├── backup/
├── fzf-history/
└── viminfo
```

## Plugins

| Plugin | Purpose |
|---|---|
| `junegunn/fzf` | fzf runtime used by fzf.vim |
| `junegunn/fzf.vim` | `:Files`, `:Buffers`, `:Rg`, `:Jumps` |
| `tpope/vim-commentary` | `gcc` / `gc` commenting |
| `tpope/vim-surround` | `ys`, `cs`, and `ds` surround operations |
| `yegappan/lsp` | Vim9 LSP client: completion, diagnostics, hover, rename, format |
| `liuchengxu/vim-which-key` | Popup leader-key guide |

vim-plug itself is not a `Plug` entry. It is the single file
`autoload/plug.vim`, downloaded by `bootstrap.sh`; both that file and the
`plugged/` directory are ignored by git.

## Key mappings

The leader and local leader are both `Space`.

### Global mappings

| Key | Action |
|---|---|
| `<Space>` (wait 500 ms) | Open the which-key leader guide |
| `<C-s>` | Save in normal, insert, and visual modes |
| `jk` | Leave insert mode |
| `<Esc>` | Clear search highlighting in normal mode |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move to the left / lower / upper / right window |
| `]b` / `[b` | Next / previous buffer |
| `<leader>e` | Toggle the right-hand netrw file explorer |
| `<leader>f` | Open the fzf file picker (`:Files`) |
| `<leader>b` | Open the fzf buffer picker (`:Buffers`) |
| `<leader>/` | Open the fzf live-grep picker (`:Rg`) |
| `<leader>j` | Open the fzf jumplist picker (`:Jumps`) |
| `<leader>l` | Toggle visible whitespace characters |
| `<leader>c` | Toggle a comment in normal or visual mode |
| `<leader>F` | Format the current buffer |
| `<Esc>` in a terminal | Leave terminal insert mode |

Unlisted built-in Vim behavior is unchanged.

Plugin defaults also apply:

- `gcc` comments a line and `gc` comments a visual selection.
- `ys`, `cs`, and `ds` add, change, and delete surroundings.

Inside a netrw buffer, netrw's buffer-local mappings take precedence over the
global window mappings. For example, `<C-l>` refreshes the listing instead of
moving to the right window.

### LSP mappings

These mappings are buffer-local. They are installed for `go`, `gomod`, `rust`,
and `lua` buffers, and are useful when the matching server is registered and
ready.

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Show hover information |
| `<leader>h` | Show hover information |
| `<leader>s` | Document symbols |
| `<leader>S` | Workspace symbol search |
| `<leader>d` | Show diagnostics |
| `<leader>a` | Code actions |
| `<leader>r` | Rename symbol |
| `]d` / `[d` | Next / previous diagnostic |

`K` overrides Vim's normal keyword-lookup command only in those LSP buffers.
In other filetypes it retains its standard behavior.

## File explorer

`<leader>e` runs `:Lexplore!` and toggles netrw on the right side. The relevant
settings are:

```vim
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 30
let g:netrw_browse_split = 0
let g:netrw_altv = 1
let g:netrw_chgwin = -1
```

- `g:netrw_liststyle = 3` enables tree listing.
- `g:netrw_winsize = 30` gives the explorer roughly 30% of the screen width.
- `g:netrw_chgwin = -1` makes files opened from the side explorer open in the
  main window instead of the explorer window.
- `g:netrw_banner = 0` hides the netrw banner.

### Tree behavior

Netrw's tree display always starts with a parent shortcut and then the current
directory root:

```text
../
vim/
| after/
| autoload/
| plugged/
| README.md
| bootstrap.sh
| vimrc
```

- `../` is the parent-directory shortcut, not the contents of the parent.
- The next line (`vim/` in this example) is the current directory as the tree
  root. This is why `vim .` from `~/.config/vim` shows `vim/` under `../`.
- Directory entries start collapsed. Press `<CR>` on a directory to expand it,
  and press `<CR>` again to collapse it.
- Press `<CR>` on a file to open it in the main window.

If the directory looks wrong, verify the actual browsing root:

```vim
:echo getcwd()
:echo b:netrw_curdir
:echo w:netrw_treetop
```

### Netrw actions

Press `?` inside the explorer for the compact action sheet, or `<F1>` for the
full netrw help. The quick sheet is also available as
`:NetrwCheatSheet`. Its popup closes with `?`, `q`, `<Esc>`, or `<CR>`.

| Key | Action |
|---|---|
| `<CR>` | Open a file, or expand/collapse a directory |
| `%` | Create a new file |
| `d` | Create a new directory |
| `D` | Delete the file or directory under the cursor |
| `R` | Rename the file or directory under the cursor |
| `mf` | Mark file(s) |
| `mt` | Set the target directory for copy/move |
| `mc` | Copy marked files to the target directory |
| `mm` | Move marked files to the target directory |
| `mu` | Unmark all files |
| `-` | Go to the parent directory |
| `<C-l>` | Refresh the listing |
| `?` | Show the quick action sheet |
| `<F1>` | Open full netrw help |

Netrw does not have a separate paste key. The workflow is target first, then
action:

1. Put the cursor on the destination directory and press `mt` to set it as the
   target, or browse into the destination and press `mt`.
2. Move to the source files and press `mf` to mark them.
3. Press `mc` to copy the marked files, or `mm` to move them.
4. Press `mu` to clear marks.

The custom `?` mapping is buffer-local to netrw, so normal `?` backward search
is unaffected elsewhere.

## which-key guide

The leader guide is provided by vim-which-key. Press `Space` and pause for
`timeoutlen` (500 ms); the popup lists the leader mappings and their
descriptions. A complete mapping such as `Space e` still executes immediately
if pressed quickly.

Descriptions come from `g:which_key_map` in `vimrc`:

```vim
let g:which_key_map = {
      \ 'e': 'file explorer (right)',
      \ 'f': 'find files',
      \ 'b': 'buffers',
      \ '/': 'live grep',
      \ 'j': 'jumplist',
      \ 'l': 'toggle whitespace',
      \ 'c': 'commentary',
      \ 'F': 'format buffer',
      \ }
```

The guide is positioned at the bottom right with two columns of horizontal
spacing. LSP buffer-local mappings are shown when those mappings are active.

Setup runs on `VimEnter`, after startup files and plugin initialization. If the
plugin is not installed or fails to load, the leader mappings still work; only
the popup guide is absent.

## Formatting

Formatting runs automatically before a modified buffer is written:

```vim
autocmd BufWritePre * call s:autoformat()
autocmd BufWritePre * call s:trim_trailing_whitespace()
```

The order matters: the formatter runs first, then trailing whitespace is
trimmed.

### Supported formatters

| Formatter | Filetypes | Mechanism |
|---|---|---|
| LSP | `go`, `gomod`, `rust`, `lua` | `:LspFormat` through the registered server |
| Prettier | `javascript`, `javascriptreact`, `typescript`, `typescriptreact`, `json`, `jsonc`, `css`, `scss`, `less`, `html`, `markdown`, `yaml` | `prettier --stdin-filepath <path>` |

### Behavior and limits

- Automatic formatting only runs when the buffer is modified, modifiable, and
  not binary.
- LSP formatting runs only if the LSP server is ready. If the server is still
  starting, the save continues without formatting; run `<leader>F` after the
  server is ready.
- Prettier formatting is skipped for unnamed buffers and files larger than
  5,000 lines. LSP formatting does not have the 5,000-line limit.
- If Prettier exits nonzero or produces no output, the buffer is left
  untouched and the save continues.
- Trailing whitespace is stripped on every save for modifiable, non-binary
  buffers, even when no formatter is configured for the filetype.
- Formatting is synchronous. Very large files can make the save pause.

### Formatting on demand

Use `<leader>F` or the `:Format` command. On-demand formatting reports a warning
when:

- the LSP server is not ready,
- Prettier fails, or
- no formatter is configured for the filetype.

There is no silent fallback from LSP formatting to an external formatter. Go
formatting depends on `gopls`; Rust formatting depends on `rust-analyzer`; Lua
formatting depends on `lua-language-server`.

### Adding or disabling formatters

- Add a filetype to `s:lsp_fts` if it is handled by a registered LSP server.
- Add a filetype to `s:prettier_fts` if Prettier handles it.
- To add a new LSP server, add it to `g:lsp_servers` and include its filetypes
  in `s:lsp_fts` and the `vimrc_lsp` autocommand if you want the LSP mappings.
- To disable automatic formatting, remove the `BufWritePre` autocommand that
  calls `s:autoformat()`.
- To keep trailing whitespace, remove the `BufWritePre` autocommand that calls
  `s:trim_trailing_whitespace()`.

## Language servers

The LSP client is `yegappan/lsp`, configured through `g:lsp_servers`. Only
servers whose executables are present on `PATH` are registered.

| Server | Filetypes | Arguments | Initialization |
|---|---|---|---|
| `gopls` | `go`, `gomod` | `serve` | synchronous |
| `rust-analyzer` | `rust` | none | synchronous |
| `lua-language-server` | `lua` | none | synchronous |

`syncInit: v:true` means server initialization is synchronous. Opening a
supported file can wait for the server to initialize.

### Client options

```vim
let g:lsp_options = {
      \ 'autoComplete': v:true,
      \ 'autoHighlightDiags': v:true,
      \ 'showInlayHints': v:true,
      \ 'showSignature': v:true,
      \ 'snippetSupport': v:false,
      \ 'hoverInPreview': v:false,
      \ 'showDiagWithVirtualText': v:false,
      \ 'showDiagOnStatusLine': v:false,
      \ 'completionMatcher': 'case',
      \ }
```

Notable consequences:

- Completion is automatic.
- Diagnostics are highlighted, but not shown as virtual text or in the
  statusline.
- Hover is shown in a regular window, not a preview window.
- Signature help is enabled.
- Snippets are disabled.
- Hover, rename, code action, diagnostics, symbols, and formatting mappings are
  only installed for `go`, `gomod`, `rust`, and `lua` buffers.

### Useful LSP commands

```vim
:LspShowAllServers      " registered servers
:LspServer              " status for the current buffer
:LspFormat              " format the current buffer
:LspHover               " hover information
:LspDiagShow            " diagnostics list
:LspDocumentSymbol      " document symbols
:LspSymbolSearch        " workspace symbols
:LspCodeAction          " code actions
:LspRename              " rename symbol
```

### Adding another server

For example, to add `clangd` for C and C++:

```vim
if executable('clangd')
  call add(g:lsp_servers, {
        \ 'name': 'clangd',
        \ 'filetype': ['c', 'cpp'],
        \ 'path': exepath('clangd'),
        \ 'args': [],
        \ 'syncInit': v:true,
        \ })
endif
```

Then add `c` and `cpp` to `s:lsp_fts` and to the `FileType` list in
`vimrc_lsp` if you want the LSP mappings. Restart Vim and check
`:LspShowAllServers`.

## Clipboard

The reference Vim build has `-clipboard` and `-wayland_clipboard`, but
`+clipboard_provider`. `after/plugin/clipboard.vim` registers a Vim9 clipboard
provider backed by `wl-copy` and `wl-paste`.

The provider is only activated when all of these are true:

- Vim has `+clipboard_provider`.
- `$WAYLAND_DISPLAY` is non-empty.
- Both `wl-copy` and `wl-paste` are executable.

When active, it sets:

```vim
set clipmethod=wl_clipboard
set clipboard=unnamedplus
```

Yanks and deletes then use the system clipboard. The `+` register uses the
normal clipboard; the `*` register uses the Wayland primary selection (`wl-copy
-p` / `wl-paste -p`). When the provider is unavailable, nothing is changed and
Vim's normal registers still work inside Vim.

### Installing on Fedora

Install the helper in the same environment or container where Vim runs:

```bash
sudo dnf install -y wl-clipboard
```

On other distributions, install the equivalent `wl-clipboard` package.

### Checking clipboard support

Restart Vim after installing the helper, then run:

```vim
:echo v:clipmethod
:echo executable('wl-copy')
:echo $WAYLAND_DISPLAY
```

Expected result:

- `v:clipmethod` is `wl_clipboard`.
- `executable('wl-copy')` is `1`.
- `$WAYLAND_DISPLAY` is non-empty.

If `v:clipmethod` is `none`, the provider is inactive. Common causes are a
missing `wl-clipboard` package, a non-Wayland session, or a container that does
not share the Wayland socket. There is no OSC 52 fallback configured; use a
terminal-side OSC 52 setup or a GUI Vim if you need clipboard support without
Wayland.

## fzf and search

fzf.vim provides these pickers:

| Command | Mapping | Purpose |
|---|---|---|
| `:Files` | `<leader>f` | Find files with fzf and `fd` |
| `:Buffers` | `<leader>b` | Switch between open buffers |
| `:Rg` | `<leader>/` | Live ripgrep search |
| `:Jumps` | `<leader>j` | Browse the jumplist |

The default file command is:

```vim
let $FZF_DEFAULT_COMMAND =
      \ 'fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude target --exclude dist --exclude .venv'
```

This includes hidden files, follows symlinks, and excludes the listed build and
dependency directories. fzf opens at the bottom of the screen at roughly 40%
height, and command history is stored under
`~/.local/state/vim/fzf-history`.

`grepprg` also uses ripgrep:

```vim
let &grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
set grepformat=%f:%l:%c:%m
```

`:grep` therefore works without an external grep wrapper, and results can be
browsed with `:copen`. `fd`, `rg`, and `fzf` must all be on `PATH`.

## Filetype settings

Global defaults are two-space indentation with spaces:

```vim
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
```

The following overrides are applied from `after/ftplugin/`:

| Filetype | Settings |
|---|---|
| Go | `tabstop=4` for display; Vim's runtime Go ftplugin keeps real tabs and sets the other indentation options |
| Markdown | `wrap`, `linebreak`, `breakindent`, `spell`, `textwidth=100`, two-space indentation |
| Git commit messages | `spell`, `textwidth=72` |
| Netrw | Buffer-local `?` quick action sheet and `:NetrwCheatSheet` |

`formatoptions` has `c`, `r`, and `o` removed globally and for every filetype,
so comments are not continued automatically and insert-mode Enter does not
continue comments. Core Vim editing behavior is otherwise untouched.

## Runtime state

| Path | Purpose |
|---|---|
| `~/.local/state/vim/undo/` | Persistent undo files |
| `~/.local/state/vim/swap/` | Swap files |
| `~/.local/state/vim/backup/` | Backup directory used by Vim's write-backup machinery |
| `~/.local/state/vim/fzf-history/` | fzf command history |
| `~/.local/state/vim/viminfo` | Viminfo file |

The undo, swap, backup, and fzf-history directories are created by `vimrc` and
by `bootstrap.sh`. `set nobackup` means persistent backup files are not kept;
`set writebackup` provides the temporary backup used during writes.
`set undofile` keeps undo history across sessions.

To reset all runtime state, quit Vim and remove the state directory. Vim and
`bootstrap.sh` recreate it as needed.

## Configuration reference

Most behavior is defined in `vimrc`. Important variables:

| Setting | Value | Effect |
|---|---|---|
| `mapleader` / `maplocalleader` | `Space` | Leader keys |
| `colorscheme` | `habamax` | Bundled colorscheme |
| `g:netrw_liststyle` | `3` | Tree listing |
| `g:netrw_winsize` | `30` | Explorer width percentage |
| `g:netrw_chgwin` | `-1` | Open selected files in the main window |
| `g:lsp_options` | table | LSP completion, diagnostics, hover, signature options |
| `g:lsp_servers` | list | Registered language servers |
| `g:fzf_layout` | `{'down': '~40%'}` | fzf picker layout |
| `g:fzf_history_dir` | state path | fzf history |
| `$FZF_DEFAULT_COMMAND` | `fd ...` | Default file list |
| `&grepprg` | `rg ...` | `:grep` command |
| `g:which_key_map` | table | Leader descriptions |
| `g:which_key_position` | `botright` | Guide position |
| `g:which_key_hspace` | `2` | Guide column spacing |

Plugin loading is guarded by the existence of
`~/.config/vim/autoload/plug.vim`. If that file is missing, the `Plug` block is
skipped; the rest of the configuration still loads. Run `bootstrap.sh` or
download vim-plug to enable the plugins.

There is no separate local configuration file and no Lua configuration. Edit
`vimrc` and the files under `after/` directly.

## Updating

Inside Vim:

```vim
:PlugUpdate
:PlugClean
```

`:PlugInstall` installs newly added plugins. `:PlugClean` removes plugins that
are no longer listed in `vimrc`. After updating, restart Vim and check
`:messages` for errors.

`bootstrap.sh` only installs missing plugins; it does not run `:PlugUpdate` or
`:PlugClean`. It also does not install system packages such as `fd`, `rg`,
`prettier`, or language servers.

Generated files are ignored by `.gitignore`:

- `autoload/plug.vim`
- `plugged/`
- `.netrwhist`
- `doc/tags`
- swap files and editor backup files

## Troubleshooting

### Vim is not loading this configuration

Check:

```vim
:echo $MYVIMRC
:scriptnames
:set runtimepath?
```

`$MYVIMRC` should point at `~/.config/vim/vimrc`. If it points elsewhere, check
for `~/.vimrc`, `~/.vim/vimrc`, and a `VIMINIT` environment variable; those take
precedence. `:scriptnames` confirms which files were sourced.
`:set runtimepath?` should include `~/.config/vim` and `~/.config/vim/after`.

### Plugins are missing

Run:

```vim
:PlugStatus
:PlugInstall
:messages
```

The plugin block is skipped entirely if `autoload/plug.vim` is absent. Run
`./bootstrap.sh` to download vim-plug and install plugins. vim-which-key setup
runs on `VimEnter`; restart Vim after installing or updating plugins.

### LSP is not working

Check the server executable and registration:

```vim
:echo executable('gopls')
:echo executable('rust-analyzer')
:echo executable('lua-language-server')
:LspShowAllServers
:LspServer
```

Make sure the buffer has the expected filetype:

```vim
:set filetype?
```

LSP mappings exist only in `go`, `gomod`, `rust`, and `lua` buffers. If you add
a server for another filetype, add that filetype to `s:lsp_fts` and the
`vimrc_lsp` autocommand. Because initialization is synchronous, a slow
`rust-analyzer` can delay the first open of a Rust file.

### Formatting did not run

- Automatic formatting only runs when the buffer is modified.
- Prettier formatting is skipped for unnamed files and files over 5,000 lines.
- LSP formatting waits for the server to be ready.
- `prettier` must be on `PATH`:

```vim
:echo executable('prettier')
```

Run `<leader>F` or `:Format` to force formatting and to see a warning when no
formatter is available. A formatter failure deliberately leaves the buffer
untouched and does not block the save.

### Clipboard does not work

Check:

```vim
:echo v:clipmethod
:echo executable('wl-copy')
:echo executable('wl-paste')
:echo $WAYLAND_DISPLAY
```

Install `wl-clipboard` in the same environment as Vim, ensure the Wayland
socket is available, then restart Vim. The provider is silently inactive if any
requirement is missing. There is no OSC 52 fallback in this configuration.

### fzf is empty or missing files

Check the required executables:

```vim
:echo executable('fzf')
:echo executable('fd')
:echo executable('rg')
```

`:Files` relies on `fd` through `$FZF_DEFAULT_COMMAND`; `:Rg` relies on `rg`.
Install missing tools or adjust the exclusions in `vimrc`. The commands run from
Vim's current working directory.

### The netrw tree looks like the wrong directory

The tree begins with `../` followed by the current directory root. This is
normal:

```text
../
project/
| src/
| README.md
```

`../` is the parent shortcut; `project/` is the current root. Check the actual
paths with:

```vim
:echo getcwd()
:echo b:netrw_curdir
:echo w:netrw_treetop
```

Press `<CR>` on a directory to expand or collapse it. Press `?` for the quick
action sheet and `<F1>` for full netrw help.

On some Vim 9.2 builds, the bundled netrw can leave a harmless
`E121: Undefined variable: s:netrwgray` value in `v:errmsg` while listing a
directory. It does not appear in `:messages` and does not affect browsing.

### which-key does not appear

- Make sure vim-which-key is installed (`:PlugStatus`).
- Pause longer than `timeoutlen` (500 ms) after pressing `Space`.
- Check `:echo exists(':WhichKey')`; it should return `2` inside the running
  Vim session.
- Restart Vim after plugin installation so the `VimEnter` setup can run.

Pressing a complete leader mapping quickly executes it without opening the
guide; that is expected.

## Known limitations

- This is a Vim configuration, not Neovim. There is no Lua configuration, no
  Treesitter, and no Neovim API usage.
- LSP formatting depends on the corresponding server being ready. There is no
  automatic fallback to `gofmt`, `rustfmt`, or another formatter.
- LSP snippets are disabled (`snippetSupport: v:false`).
- LSP server initialization is synchronous, so opening a large project can
  block briefly.
- Prettier is required for the listed web and prose filetypes; without it,
  those buffers are not formatted on save.
- The clipboard provider requires Wayland and `wl-clipboard`; there is no
  OSC 52 fallback.
- Netrw is Vim's built-in file browser. It does not provide icons, git status,
  or a separate file-manager UI; the `?` sheet is a small custom overlay.
- fzf, `fd`, `rg`, Prettier, and the language servers are external
  dependencies and are not installed by `bootstrap.sh`.
