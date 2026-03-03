# Helix Cheatsheet

## Custom Zed Bindings

### Panels
| Key | Action |
|-----|--------|
| `ctrl-]` | Project panel |
| `ctrl-}` | Git panel |
| `ctrl-\` | Agent panel |
| `ctrl-/` | Terminal |
| `ctrl-shift-h/j/k/l` | Navigate splits |

### Space Leader
| Key | Action |
|-----|--------|
| `space o` / `space O` | Recent project / Open folder |
| `space q` / `space Q` | Close tab / Close other tabs |
| `space x q` | Close all tabs |
| `space x f` | Format |
| `space x g` / `space x j` | lazygit / lazyjj |
| `space u i` / `space u w` | Toggle inlay hints / soft wrap |
| `space v b` | Git blame |
| `space v d` / `space v D` | Expand / collapse all diff hunks |
| `space v a` | Git diff (all changes) |
| `space v r` / `space v R` | Restore hunk / restore file |
| `space m p` / `space m P` | Markdown preview (side / inline) |
| `ctrl-l` | Inline AI assist |
| `alt-j` / `alt-k` | Move line down / up |

---

## Movement

| Key | Action |
|-----|--------|
| `h/j/k/l` | Left / down / up / right |
| `w` / `b` / `e` | Next word start / prev word start / word end |
| `W` / `B` / `E` | Same but WORD (whitespace-delimited) |
| `f<c>` / `t<c>` | Find char / find till char (forward) |
| `F<c>` / `T<c>` | Find char / find till char (backward) |
| `Alt-.` | Repeat last motion |
| `gg` | File start |
| `ge` | File end |
| `gh` / `gl` | Line start / line end |
| `gs` | First non-whitespace |
| `gt` / `gc` / `gb` | Window top / center / bottom |
| `gw` | Word-label jump (like EasyMotion) |
| `Ctrl-u` / `Ctrl-d` | Half page up / down |
| `Ctrl-b` / `Ctrl-f` | Page up / down |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward (jumplist) |

---

## Editing

| Key | Action |
|-----|--------|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at line start / end |
| `o` / `O` | Open line below / above |
| `d` | Delete selection |
| `c` | Change selection (delete + insert) |
| `x` | Select current line |
| `x d` | Delete line (vim `dd` equivalent) |
| `r<c>` | Replace selection with char |
| `R` | Replace with yanked text |
| `J` | Join lines |
| `>` / `<` | Indent / unindent |
| `~` | Toggle case |
| `Ctrl-a` / `Ctrl-x` | Increment / decrement number |
| `u` / `U` | Undo / redo |
| `.` | Repeat last insert |

### Delete word (insert mode)
| Key | Action |
|-----|--------|
| `Ctrl-w` | Delete word backward |
| `Alt-d` | Delete word forward |

---

## Selection & Multi-cursor

| Key | Action |
|-----|--------|
| `v` | Enter select mode (extend selections) |
| `x` | Select line, repeat to extend |
| `%` | Select entire file |
| `;` | Collapse selection to cursor |
| `C` | Copy selection to next line (add cursor below) |
| `Alt-C` | Copy selection to previous line (add cursor above) |
| `s` | Select regex matches in selection |
| `S` | Split selection on regex |
| `K` | Keep selections matching regex |
| `Alt-K` | Remove selections matching regex |
| `,` | Keep only primary selection |
| `&` | Align selections |

---

## Search

| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / previous match |
| `*` | Search word under cursor  |
| `Space /` | Global project search |
| `Space '` | Reopen last picker |

### Search and replace (no `:s` command)
1. `%` select all (or make a selection)
2. `s` select regex matches
3. `c` change all matches

---

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `Space k` | Hover docs |
| `Space s` | Document symbols |
| `Space S` | Workspace symbols |
| `Space a` | Code action |
| `Space r` | Rename symbol |
| `Space d` / `Space D` | Document / workspace diagnostics |
| `]d` / `[d` | Next / previous diagnostic |

---

## Surround & Match (`m` mode)

| Key | Action |
|-----|--------|
| `mm` | Jump to matching bracket |
| `ms<c>` | Surround selection with char |
| `mr<old><new>` | Replace surround |
| `md<c>` | Delete surround |
| `mi<obj>` | Select inside text object |
| `ma<obj>` | Select around text object |

### Text objects
`w` word, `p` paragraph, `f` function, `t` type/class, `a` argument,
`c` comment, `T` test, `m` closest pair, `( ) [ ] { } < > " ' \``

---

## Macros

| Key | Action |
|-----|--------|
| `Q` | Start/stop recording |
| `q` | Replay macro |

**Note:** Reversed from vim (`q` records, `@` plays).

---

## Tree-sitter Selection

| Key | Action |
|-----|--------|
| `Alt-o` | Expand selection (parent) |
| `Alt-i` | Shrink selection (child) |
| `Alt-p` / `Alt-n` | Previous / next sibling |

---

## Window Management

| Key | Action |
|-----|--------|
| `Ctrl-w s` | Horizontal split |
| `Ctrl-w v` | Vertical split |
| `Ctrl-w q` | Close split |

---

## Clipboard

| Key | Action |
|-----|--------|
| `y` / `p` / `P` | Yank / paste after / paste before (register) |
| `Space y` | Yank to system clipboard |
| `Space p` / `Space P` | Paste from system clipboard |

---

## Comments

| Key | Action |
|-----|--------|
| `Space c` | Toggle line comment |
| `Space C` | Toggle block comment |

---

## Buffers

| Key | Action |
|-----|--------|
| `Space f` | File picker |
| `Space b` | Buffer picker |
| `gn` / `gp` | Next / previous buffer |
| `ga` | Last accessed file |
