# Minimal Vim (not Neovim)

A compact, Vim-only configuration built around Vim 9.2. It uses no Lua, no
Treesitter, and no Neovim APIs. The live configuration is the real directory
`~/.config/vim`; on this machine `~/Workspace/vim` is a convenience symlink to
it.

The setup is deliberately small: nine plugins, the bundled `habamax`
colorscheme, a current-window dirvish directory buffer, fzf, a which-key leader
guide, Vim9 LSP, multiple cursors, save-time formatting, and an optional
Wayland clipboard provider.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Repository layout](#repository-layout)
- [Plugins](#plugins)
- [Key mappings](#key-mappings)
- [Multiple cursors](#multiple-cursors)
- [File explorer](#file-explorer)
- [which-key guide](#which-key-guide)
- [Formatting](#formatting)
- [Language server](#language-server)
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
- Nine plugins managed by vim-plug:
  - fzf and fzf.vim
  - vim-commentary
  - vim-surround
  - vim-eunuch
  - vim-dirvish
  - vim-visual-multi
  - yegappan/lsp
  - vim-which-key
- Vim9 LSP for Go (including `go.mod`) when `gopls` is installed.
- Multiple cursors through vim-visual-multi.
- Automatic formatting on save for LSP-backed filetypes and Prettier
  filetypes.
- fzf file, buffer, grep, and jumplist pickers.
- A current-window dirvish directory buffer with eunuch-backed file
  operations.
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

### Optional language server

Only `gopls` is configured, and it is registered only if found on `PATH`:

- `gopls` for Go and `go.mod`.

### Optional clipboard helper

- `wl-clipboard` (`wl-copy` and `wl-paste`) on a Wayland session.

A UTF-8 terminal is recommended. The configuration uses Unicode characters for
`listchars`, `fillchars`, and `showbreak`.

### Per-platform requirements

Exact install commands for each platform. The notes cover package-name
differences, builds older than Vim 9.2, and clipboard support.

#### macOS

```bash
brew install vim git fzf fd ripgrep gopls prettier
```

- Requires [Homebrew](https://brew.sh); install it first if `brew` is
  missing.
- The system `/usr/bin/vim` is older than 9.2; use the Homebrew build. It is
  a “huge” build with `+clipboard` and `+clipboard_provider`.
- `curl` ships with macOS. `git` also comes with the Xcode command-line
  tools (`xcode-select --install`).
- The bundled clipboard provider is Wayland-only and stays inactive here;
  `"+y` and `"+p` use the macOS clipboard directly.

#### Fedora

```bash
sudo dnf install vim-enhanced git curl fzf ripgrep fd-find wl-clipboard gopls
```

- `vim-enhanced` is Vim 9.2 with `+clipboard_provider`; `fd-find` provides
  the `fd` command.
- `prettier` is not packaged. Install it with npm or Bun. Fedora ships
  Node.js in versioned streams; `sudo dnf install nodejs22-npm-bin` provides
  `node` and `npm`, then `sudo npm install -g prettier`.

#### Debian and Ubuntu

```bash
sudo apt install vim git curl fzf ripgrep fd-find wl-clipboard gopls
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
```

- `fd-find` installs the binary as `fdfind`; the symlink provides the `fd`
  command that the configuration expects.
- `prettier` is not packaged. Install it with npm (`sudo apt install nodejs
  npm`, then `sudo npm install -g prettier`) or with Bun.
- Vim versions: Debian 14 (forky) and Ubuntu 26.10 ship 9.2. Debian 13
  (9.1.1230) and Ubuntu 26.04 (9.1.2141) ship 9.1, below the 9.2 baseline but
  new enough for the clipboard-provider API. Ubuntu 24.04 (9.1.0016)
  predates that API. On an older release, build Vim 9.2 from source
  (`--with-features=huge --enable-terminal`) if you need the exact baseline.

#### Arch Linux

```bash
sudo pacman -S vim git curl fzf ripgrep fd wl-clipboard gopls prettier
```

- The `vim` package is built without `+clipboard`. The bundled Wayland
  provider plus `wl-clipboard` supplies the clipboard; alternatively install
  `gvim`, which also provides the terminal `vim` and has `+clipboard`.

#### Fedora Silverblue and Kinoite

`git-core`, `curl`, and `wl-clipboard` are already in the base image. Layer
the remaining packages; the change applies after the reboot:

```bash
sudo rpm-ostree install vim-enhanced fzf ripgrep fd-find gopls
systemctl reboot
```

Alternatively, install everything in a toolbox:

```bash
toolbox create --container vim
toolbox enter vim
sudo dnf install vim-enhanced git curl fzf ripgrep fd-find gopls
```

The toolbox shares `$HOME`, so it uses the same configuration. `prettier` is
not packaged; install it with npm or Bun in the toolbox or on the host.

#### Windows

WSL2 is the supported route for this configuration. Install Ubuntu under
WSL (`wsl --install -d Ubuntu`), apply the
[Debian and Ubuntu](#debian-and-ubuntu) commands inside it, and use Windows
Terminal for UTF-8 and true-color support. `bootstrap.sh` and the XDG paths
then work as on Linux.

For native Windows, install the official Vim 9.2 build and the helper
commands with winget:

```powershell
winget install vim.vim
winget install Git.Git
winget install junegunn.fzf
winget install sharkdp.fd
winget install BurntSushi.ripgrep.MSVC
winget install OpenJS.NodeJS.LTS
npm install -g prettier
winget install GoLang.Go
go install golang.org/x/tools/gopls@latest
```

The official build is a “huge” build (`GUI=yes`, `VIMDLL=yes`) with
`+popupwin`, `+job`, `+channel`, `+timers`, `+terminal`, and the native
`+clipboard` feature in both `vim.exe` and `gvim.exe`. Run the `npm` and `go`
commands in a fresh PowerShell session, after the installers have updated
`PATH`. `go install` writes `gopls.exe` to `%USERPROFILE%\go\bin`; add that
directory to `PATH` as well. Native Vim reads `~/_vimrc` or `~/vimfiles`, not
`~/.config/vim`, so run this repository through WSL2.

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
5. Removes legacy netrw history (`.netrwhist`); dirvish replaces netrw.
6. Downloads vim-plug to `autoload/plug.vim` if it is missing.
7. Installs missing plugins and runs `:PlugClean!` in a headless Vim.

If the script is run from a checkout elsewhere and `~/.config/vim` already
exists as a real directory, the script refuses to replace it. Move that
directory aside, or make it a symlink to this checkout, before rerunning.

`bootstrap.sh` requires bash and a Unix-like environment. On Windows, run it
inside WSL2; see [Per-platform requirements](#per-platform-requirements).

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
│   │   ├── dirvish.vim      file operations in dirvish buffers
│   │   ├── gitcommit.vim    commit-message settings
│   │   ├── go.vim           Go tab display
│   │   └── markdown.vim     prose and spell settings
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
| `tpope/vim-eunuch` | `:Remove`, `:Rename`, `:Move`, `:Copy`, `:Mkdir` |
| `justinmk/vim-dirvish` | Directory buffers used by `<leader>e` |
| `mg979/vim-visual-multi` | Multiple cursors and multiple selections |
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
| `<leader>e` | Toggle the current-window dirvish directory buffer |
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

Inside a dirvish buffer, dirvish's buffer-local mappings take precedence over
the global window mappings. For example, `q` returns to the previous file,
`<CR>` opens the entry under the cursor, and `-` goes up one directory. The
file-operation mappings are listed under [File explorer](#file-explorer).

### LSP mappings

These mappings are buffer-local. They are installed for `go` and `gomod`
buffers, and are useful when `gopls` is registered and ready.

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

## Multiple cursors

Multiple cursors are provided by `mg979/vim-visual-multi`. It has no external
dependencies and uses its own default mappings rather than the `Space` leader.

A basic replacement workflow:

1. Put the cursor on a word in normal mode.
2. Press `<C-n>` to select the word and start visual-multi.
3. Press `<C-n>` again (or `n`) to add the next occurrence. Press `N` to search
   backwards.
4. Press `c` to change all selections, then type the replacement and press
   `<Esc>`.
5. Press `<Esc>` again if needed to leave visual-multi.

Common mappings:

| Key | Action |
|---|---|
| `<C-n>` | Select the word under the cursor; press again for the next occurrence |
| `<C-Down>` / `<C-Up>` | Add a cursor below / above |
| `n` / `N` | Next / previous occurrence |
| `q` / `Q` | Skip the current occurrence / remove the current cursor |
| `Tab` | Toggle cursor mode and extend (selection) mode |
| `i`, `a`, `I`, `A` | Enter insert mode at the cursors |
| `c`, `d`, `y` | Change, delete, or yank the selections in extend mode |
| `<Esc>` | Leave visual-multi |
| `\\A` | Select all occurrences of the current word |
| `\\<Space>` | Toggle visual-multi's buffer mappings |
| `:VMClear` | Clear all cursors and reset the session |

The `\\` prefix shown above is visual-multi's default leader, which is two
backslashes, not the `Space` leader. See `:help visual-multi` for the full
command set, including regex selection, alignment, and running commands at all
cursors.

Notes and limitations:

- `<C-n>` starts visual-multi only in normal mode. In insert mode it remains
  Vim's completion key.
- The plugin uses buffer-local mappings while active and warns if one of its
  mappings would overwrite an existing mapping. This configuration does not map
  `<C-n>`, `<C-Down>`, or `<C-Up>`, so the defaults are available.
- Multiple cursors are simulated. LSP operations such as rename, code actions,
  diagnostics, and formatting are still single-buffer/single-cursor concepts;
  completion is best-effort.
- Save-time formatting applies to the whole buffer. Finish the multiple-cursor
  edit and leave visual-multi before saving if formatting matters.
- In extend mode, `S` can surround the selections when vim-surround is active.
- The which-key popup covers `Space` leader mappings, so visual-multi's
  Ctrl-based keys are documented here instead.

## File explorer

Dirvish replaces netrw. `<leader>e` opens the current file's directory in the
current window; pressing it again in a dirvish buffer returns to the previous
file. `:Dirvish` opens the current file's directory, or the current working
directory for an unnamed buffer. `:Dirvish /path` opens a specific directory.

Netrw is disabled explicitly:

```vim
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:dirvish_mode = ':sort ,^.*[\/],'
```

The last setting sorts directories before files. Dirvish lists entries as full
paths, so the buffer name and the lines are directly usable with Vim's file
functions and `:Shdo`.

### Navigation

| Key | Action |
|---|---|
| `<CR>` | Open a file, or enter a directory |
| `o` | Open an entry in a horizontal split |
| `a` | Open an entry in a vertical split |
| `-` | Go to the parent directory |
| `~` | Go to the home directory |
| `q` / `gq` | Close the directory buffer and return to the previous file |
| `R` | Reload the listing |
| `K` | Show file information |
| `g?` | Open dirvish's mapping help |

Dirvish has no tree view; each directory is a normal buffer. `q` restores the
previous buffer, so `<leader>e` is a true toggle.

### File operations

Dirvish is intentionally read-only. These buffer-local mappings act on the
entry under the cursor:

| Key | Action |
|---|---|
| `<leader>n` | Create and edit a new file |
| `<leader>N` | Create a new directory |
| `<leader>r` | Rename the entry |
| `<leader>d` | Delete the entry (confirmation required) |
| `<leader>c` | Copy the entry (`:Shdo cp -r {}`) |
| `<leader>m` | Move the entry (`:Shdo mv {}`) |

`<leader>c` and `<leader>m` also work in visual mode for multiple entries.

Press `Space` in a dirvish buffer to show these mappings with descriptions in
the which-key guide.

Copy and move use dirvish's `:Shdo` helper, which opens a small temporary
script in a split. Add the destination path after the generated command, then
press `Z!` to run it. For example:

```sh
cp -r vimrc ~/.config/vim/vimrc.bak
```

`<leader>n`, `<leader>N`, `<leader>r`, and `<leader>d` use Vim's
`input()`/`confirm()` prompts; there is no separate file-manager window.

### Eunuch commands

[vim-eunuch](https://github.com/tpope/vim-eunuch) provides commands for the
file in the current buffer, not the dirvish cursor line:

| Command | Action |
|---|---|
| `:Remove` | Delete the current file from disk |
| `:Rename {name}` | Rename the current file |
| `:Move {dir}` | Move the current file |
| `:Copy {dir}` | Copy the current buffer to a new file |
| `:Mkdir [dir]` | Create a directory, defaulting to the current file's parent |

Use the dirvish mappings above when operating on an entry without opening it
first.

## which-key guide

The leader guide is provided by vim-which-key. Press `Space` and pause for
`timeoutlen` (500 ms); the popup lists the leader mappings and their
descriptions. A complete mapping such as `Space e` still executes immediately
if pressed quickly.

Descriptions come from `g:which_key_map` in `vimrc`. Filetype and plugin
buffers can add a buffer-local `b:which_key_map_overlay`; it is merged over the
global map whenever the guide opens.

```vim
let g:which_key_map = {
      \ 'e': 'directory buffer',
      \ 'f': 'find files',
      \ 'b': 'buffers',
      \ '/': 'live grep',
      \ 'j': 'jumplist',
      \ 'l': 'toggle whitespace',
      \ 'c': 'commentary',
      \ 'F': 'format buffer',
      \ }

" dirvish: after/ftplugin/dirvish.vim
let b:which_key_map_overlay = {
      \ 'n': 'new file',
      \ 'N': 'new directory',
      \ 'r': 'rename entry',
      \ 'd': 'delete entry',
      \ 'c': 'copy entry',
      \ 'm': 'move entry',
      \ }
```

This keeps the global descriptions outside dirvish while showing the
file-operation descriptions inside it.

The guide is positioned at the bottom right with two columns of horizontal
spacing. Buffer-local mappings such as the dirvish file operations and LSP
mappings are shown when those mappings are active.

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
| LSP | `go`, `gomod` | `:LspFormat` through `gopls` |
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
formatting depends on `gopls`.

### Adding or disabling formatters

- Add a filetype to `s:lsp_fts` if it is handled by a registered LSP server.
- Add a filetype to `s:prettier_fts` if Prettier handles it.
- To add a new LSP server, add it to `g:lsp_servers` and include its filetypes
  in `s:lsp_fts` and the `vimrc_lsp` autocommand if you want the LSP mappings.
- To disable automatic formatting, remove the `BufWritePre` autocommand that
  calls `s:autoformat()`.
- To keep trailing whitespace, remove the `BufWritePre` autocommand that calls
  `s:trim_trailing_whitespace()`.

## Language server

The LSP client is `yegappan/lsp`, configured through `g:lsp_servers`. It has
one configured server, `gopls`, which is registered only when its executable
is present on `PATH`.

| Server | Filetypes | Arguments | Initialization |
|---|---|---|---|
| `gopls` | `go`, `gomod` | `serve` | synchronous |

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
  only installed for `go` and `gomod` buffers.

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

### Installing wl-clipboard

Install the helper in the same environment or container where Vim runs:

```bash
sudo dnf install -y wl-clipboard     # Fedora
sudo apt install -y wl-clipboard     # Debian and Ubuntu
sudo pacman -S wl-clipboard          # Arch
```

On Fedora Silverblue, `wl-clipboard` is already in the base image. On other
distributions, install the equivalent package.

The provider is Wayland-only. On macOS and Windows, the builds described in
[Per-platform requirements](#per-platform-requirements) include the native
`+clipboard` feature; `set clipboard=unnamed` makes yank and delete use the
system clipboard there.

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

On macOS and Windows, the native `+clipboard` feature is used instead and
`v:clipmethod` stays `none` unless a provider is defined; check
`:echo has('clipboard')` there.

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
| Dirvish | Buffer-local file-operation mappings and which-key descriptions for the cursor entry |

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
| `g:loaded_netrw` / `g:loaded_netrwPlugin` | `1` | Disable netrw; dirvish handles directories |
| `g:dirvish_mode` | `':sort ,^.*[\/],'` | Sort directories before files |
| `g:lsp_options` | table | LSP completion, diagnostics, hover, signature options |
| `g:lsp_servers` | list | Configured LSP server(s) |
| `g:fzf_layout` | `{'down': '~40%'}` | fzf picker layout |
| `g:fzf_history_dir` | state path | fzf history |
| `$FZF_DEFAULT_COMMAND` | `fd ...` | Default file list |
| `&grepprg` | `rg ...` | `:grep` command |
| `g:which_key_map` | table | Base leader descriptions |
| `b:which_key_map_overlay` | table (buffer-local) | Per-buffer leader description overrides |
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

`bootstrap.sh` installs missing plugins and runs `:PlugClean!` to remove plugin
checkouts that are no longer in `vimrc`. It does not run `:PlugUpdate` or
install system packages such as `fd`, `rg`, `prettier`, or `gopls`.

Generated files are ignored by `.gitignore`:

- `autoload/plug.vim`
- `plugged/`
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
:LspShowAllServers
:LspServer
```

Make sure the buffer has the expected filetype:

```vim
:set filetype?
```

LSP mappings exist only in `go` and `gomod` buffers. If you add a server for
another filetype, add that filetype to `s:lsp_fts` and the `vimrc_lsp`
autocommand. Because initialization is synchronous, a slow `gopls` can delay
the first open of a Go file.

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

### Dirvish replaced my current window

This is expected. Dirvish is a directory buffer, not a sidebar. `<leader>e`
opens the current file's directory in the current window. Press `q` to return
to the previous file, `<CR>` to open an entry in place, `o` to open it in a
horizontal split, or `a` to open it in a vertical split.

Check the browsing root with:

```vim
:echo expand('%')
:echo getcwd()
```

`:Dirvish` with no argument uses the current buffer's directory, or the current
working directory for an unnamed buffer. `:Dirvish /path/to/dir` opens a
specific directory.

### Dirvish file operations are missing

The `<leader>` file-operation mappings are buffer-local to `dirvish` buffers.
Check the filetype and mappings:

```vim
:set filetype?
:verbose nmap <leader>n
:messages
```

If the filetype is not `dirvish`, the `after/ftplugin/dirvish.vim` mappings are
not loaded. Restart Vim, or run `:set filetype=dirvish` in the directory buffer
to trigger the ftplugin. For files you have already opened, use eunuch's
`:Remove`, `:Rename`, `:Move`, `:Copy`, or `:Mkdir` instead.

The descriptions shown in the `Space` guide come from the same buffer-local
overlay; `:echo get(b:, 'which_key_map_overlay', {})` should show it in a
dirvish buffer.

### which-key does not appear

- Make sure vim-which-key is installed (`:PlugStatus`).
- Pause longer than `timeoutlen` (500 ms) after pressing `Space`.
- Check `:echo exists(':WhichKey')`; it should return `2` inside the running
  Vim session.
- Restart Vim after plugin installation so the `VimEnter` setup can run.

Pressing a complete leader mapping quickly executes it without opening the
guide; that is expected.

### Multiple cursors do not start

- Ensure the plugin is loaded: `:echo exists('g:loaded_visual_multi')` should
  return `1`.
- Start from normal mode with the cursor on a word and press `<C-n>`. In insert
  mode `<C-n>` is Vim's completion key.
- Check `:PlugStatus` and `:messages`; restart Vim after installing the plugin.
- If a session is stuck or behaves unexpectedly, run `:VMClear` or press
  `<Esc>` to leave visual-multi.
- Check for mapping conflicts with `:verbose nmap <C-n>` and
  `:verbose nmap <C-Down>`.

## Known limitations

- This is a Vim configuration, not Neovim. There is no Lua configuration, no
  Treesitter, and no Neovim API usage.
- Go LSP formatting depends on `gopls` being ready. There is no automatic
  fallback to `gofmt` or another formatter.
- LSP snippets are disabled (`snippetSupport: v:false`).
- LSP server initialization is synchronous, so opening a large project can
  block briefly.
- Prettier is required for the listed web and prose filetypes; without it,
  those buffers are not formatted on save.
- The clipboard provider requires Wayland and `wl-clipboard`; there is no
  OSC 52 fallback.
- Multiple cursors are simulated by vim-visual-multi. LSP features and
  save-time formatting still operate at the single-buffer/single-cursor level.
- Dirvish is a directory buffer, not a tree or persistent sidebar. It replaces
  the current window, and its file operations act on the cursor line. Netrw is
  disabled, so netrw's remote URL editing and its file-manager UI are
  unavailable.
- fzf, `fd`, `rg`, Prettier, and `gopls` are external dependencies and are not
  installed by `bootstrap.sh`.
