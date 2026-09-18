# cession

Find the terminal tab your Claude Code session is waiting in, and jump to it.

macOS menu bar app. Ghostty first, more terminals behind one adapter.

> **Status: early development.** The design is settled and implementation has
> started, but there is no working build yet. Nothing here is installable today.
> Watch the repository if you want to know when it is.

## Why

Terminal windows pile up and you lose track of which tab is running what. Worse,
a Claude Code session can sit blocked on an approval for twenty minutes without
you noticing. `cession` puts every terminal window and tab in one palette, marks
the tabs holding a Claude Code session, and tells you which ones are waiting on you.

## How it works

`cession` reads the session files Claude Code already writes to
`~/.claude/sessions/`. **It does not install hooks and does not modify your
`settings.json`.** Live sessions are confirmed with `ps`, so a force-killed
session never lingers in the list.

Mapping a session to a tab is the hard part. Ghostty does not expose the pid or
tty of a surface, so `cession` writes a short-lived OSC title marker to the
session's tty, reads it back over AppleScript to learn which surface it belongs
to, and restores the original title.

## Supported terminals

| Terminal | Status |
|---|---|
| Ghostty | In progress |
| Terminal.app | Planned |
| iTerm2 | Planned |
| WezTerm | Planned |
| kitty | Planned |

Adding one means implementing `TerminalControlling` (three methods) in a new
target. `CessionCore` never imports an adapter, so a new terminal cannot leak its
quirks into the core.

## Planned behaviour

Sessions are grouped `running`, `waiting`, `idle`. The menu bar badge counts only
`waiting` sessions, the ones blocked on your input, so a number on the badge always
means something needs you.

| Key | Action |
|---|---|
| `⌃⇧H` | Open or close the palette (configurable from the menu bar) |
| `↑` `↓` | Move selection |
| `↵` | Jump to the selected tab |
| `⌘1`-`⌘9` | Jump to one of the first nine rows |
| `Esc` | Close |

Shell tabs are listed too, collapsed by default. Type to search and they expand.

## Requirements

- macOS 14 or later
- Ghostty 1.3.1 or later
- Claude Code 2.1.x (verified against 2.1.273)

## Install

No release yet. See [Building](#building) if you want to follow along from source.

## Building

Requires a Swift 6.4 toolchain. Xcode is not needed.

```
brew install swiftly
swiftly init
git clone https://github.com/0omin/cession.git
cd cession
swift test
```

## Known limitations

- Sessions inside tmux or over ssh will appear in the list but cannot be jumped
  to, because their tty is not the terminal's own pty.
- Hotkey conflicts cannot be detected. Carbon reports success even when another
  app already owns the combination, so after changing it you have to press it to
  confirm it works.
- `cession` reads an internal Claude Code file that is not a public API. If the
  format changes, session status degrades to `unknown` while the tab list keeps
  working.

## License

MIT. See [LICENSE](LICENSE).

Not affiliated with Anthropic. Claude and Claude Code are trademarks of Anthropic.
