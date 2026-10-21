vim9script

# Wayland clipboard provider for Vim builds without +clipboard/+wayland_clipboard.
# Requires wl-clipboard (wl-copy, wl-paste) and a Wayland session.
# See :help clipboard-providers and :help wayland.

if !has('clipboard_provider') || empty($WAYLAND_DISPLAY)
  finish
endif

if !executable('wl-copy') || !executable('wl-paste')
  finish
endif

def Available(): bool
  return executable('wl-copy') && executable('wl-paste')
enddef

def Copy(reg: string, type: string, str: list<string>)
  var args = 'wl-copy'

  if reg == '*'
    args ..= ' -p'
  endif

  silent system(args, str)
enddef

def Paste(reg: string): tuple<string, list<string>>
  var args = "wl-paste --type 'text/plain;charset=utf-8'"

  if reg == '*'
    args ..= ' -p'
  endif

  silent return ('', systemlist(args))
enddef

v:clipproviders['wl_clipboard'] = {
  available: Available,
  copy: {
    '+': Copy,
    '*': Copy
  },
  paste: {
    '+': Paste,
    '*': Paste
  }
}

set clipmethod=wl_clipboard
set clipboard=unnamedplus
