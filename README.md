# Neovim writing environment

A focused setup for Markdown, books, and long-form writing. Paragraphs stay on
one file line (`textwidth=0`) and wrap visually at word boundaries. Markdown
buffers automatically open Zen Mode and Limelight. Space is the leader key:
`<leader>f` means press Space, then `f`, in Normal mode.

## Setup

Keep this repository in one working directory and link `~/.config/nvim` to it.
For a fresh setup on either Mac, use the current account's home directory:

```sh
writer_repo="$HOME/code/github.com/Benni-Math/writer.nvim"
mkdir -p "$(dirname "$writer_repo")" "$HOME/.config"
git clone git@github.com:benni-arnarsson/writer.nvim.git "$writer_repo"
# Preserve an existing config first; do not overwrite an existing backup.
# mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup-YYYYMMDD-HHMMSS"
ln -s "$writer_repo" "$HOME/.config/nvim"
nvim
```

If the checkout already exists, skip cloning and link that checkout. On this Mac,
the old active checkout is preserved at a timestamped `~/.config/nvim.backup-*`
path. Its latest navigation changes and the previous keyboard improvements are
merged into the canonical checkout. A safety stash in that repo retains its
pre-unification working tree. Neither plugin data, sessions, undo, nor file marks
are moved by the config-directory change.

Lazy bootstraps itself and installs the configured plugins; run `:Lazy install`
if needed.
The checked-in `lazy-lock.json` pins plugin versions; `:Lazy restore` restores
those versions. New plugin installations require Git and network access.

The Mac profiles in writer.nix set `modules.programs.nvim.manageConfig = false`:
Nix installs Neovim and its tools; this checkout and Lazy own the config and
plugins. Linux keeps Home Manager's equivalent navigation configuration with
`manageConfig = true`. The standalone checkout has no runtime dependency on
writer.nix or rippling.nvim. Work navigation is unchanged by this unification.

Outside Nix, install `ripgrep` (`rg`) for Telescope's project grep, `yazi` for the
file manager, and Node.js/npm for the Markdown preview plugin's build. On macOS:

```sh
brew install neovim ripgrep yazi node
```

## Everyday shortcuts

| Keys / command | Action |
| --- | --- |
| Space `w` / Space `q` | Save / quit the window |
| Space Space | Switch to the previous file |
| Space `ff` / Space `fg` / Space `fw` | Find project files / project text / cursor word |
| Space `fb` / Space `fr` | Open buffers / recent project files |
| Space `f/` / Space `/` | Fuzzy search of current-buffer lines |
| Space `f.` / Space `fh` / Space `fc` | Resume search / help / commands |
| Space `fa` / Space `fm` | Toggle a project file mark / browse marks |
| Space `1` through Space `4` | Jump directly to marked project files |
| Space `jl` / Space `jw` | Label visible file-line starts / word starts |
| Space `jt` | Markdown heading table of contents |
| Space `e` / Space `E` | Yazi at the current file / working directory |
| Ctrl-Up | Resume Yazi |
| Space `mp` | Toggle Markdown browser preview |
| Space `z` | Toggle writing focus (Zen Mode and Limelight together) |
| Space `tt` | Open a terminal split |
| Ctrl-h/j/k/l | Move between windows |
| `jk` in Insert mode | Return to Normal mode |
| Esc twice in Terminal mode | Return to Normal mode |
| Esc in Normal mode | Clear search highlighting |
| `:WordCount` | Print the word count |
| `:Theme tokyonight`, `:Theme gruvbox`, `:Theme catppuccin` | Change theme |

Pause after Space or Space `f` to see WhichKey's available shortcuts. Old
Space `f` and Space `g` become Space `ff` and Space `fg`, matching the work search
menu. Space `/` remains a short alias for Space `f/`.

Project search and Grapple file marks use the nearest Git root, otherwise the
nearest book ancestor containing `metadata.yaml`, otherwise the working directory.
Recent-file search stays within that root. Hidden files are included, ignore
files are respected, and `.git` is excluded. Type to filter, use Ctrl-j/Ctrl-k to
select, and Enter to open; Esc closes the picker. Space `/` is useful when you
remember a few words from a paragraph anywhere in the document: its results are
file lines, so a whole single-line paragraph is one result.

Spelling, wrapping, and concealment apply to Markdown rather than code buffers.
Undo persists across restarts. Focus opens automatically for Markdown without
toggling off when another chapter opens; Space `z` toggles it manually. Theme
selection and standalone session restoration remain available.

## Moving through single-line paragraphs

Choose a motion based on what you can recognize: a nearby screen row, a word,
a phrase, a paragraph boundary, or a heading. You rarely need to count rows.

### Nearby wrapped text

In Markdown, uncounted `j` and `k` move down and up one **displayed row**, in
Normal and Visual mode. `3j` and `3k` still move three **file lines**; even `1j`
moves a file line. Other file types retain native `j`/`k` behavior. Operators
also retain native behavior: `dj` deletes file lines, not one wrapped row.

| Motion | Target |
| --- | --- |
| `gj` / `gk` | Down / up a displayed row; `3gj` moves three displayed rows |
| `g0` / `g^` / `g$` | Start / first nonblank / end of the displayed row |
| `0` / `^` / `$` | Start / first nonblank / end of the entire file line |
| `+` / `-` | Next / previous file line's first nonblank character |
| `gg` / `G` / `42G` | First / last / numbered file line |

For a paragraph spanning many rows, `$` can jump much farther than `g$`.
Wrapping changes what you see, not where newlines occur in the file.
See `:help gj`, `:help g0`, and `:help g$`.

### Words, punctuation, and sentences

Use `w`/`b` for the next/previous word start, `e` for a word end, and `ge` for
the previous word end. Counts work: `3w` skips three words. Uppercase `W`, `B`,
and `E` move through whitespace-separated WORDs, useful for URLs and Markdown
tokens that contain punctuation.

`f,` finds the next comma on the current file line; `t,` stops just before it.
`F` and `T` search backward. These cover the whole paragraph when it occupies
one file line, including its wrapped rows. Repeat with `;`, or reverse with
`,`. See `:help f` and `:help word`.

`)` and `(` move to the next and previous sentence boundary. Vim recognizes
sentence-ending `.`, `!`, or `?` followed by whitespace or the line ending,
with certain closing punctuation allowed. This is a punctuation heuristic:
abbreviations can produce unexpected stops. See `:help sentence`.

### Paragraphs and edits

`}` and `{` move forward/backward across paragraph boundaries, including the
empty separator lines. Use truly empty lines between paragraphs: lines
containing only spaces or tabs are not Vim paragraph boundaries. Adjacent
list items without empty lines may form one Vim paragraph.

Use `vip` to select the paragraph, `yip` to copy it, and `cip` to replace it.
`vap` includes surrounding separator space; `dap` removes a paragraph and
separator space. For sentence-sized edits, try `vis`, `yis`, or `cis`.
These text objects work independently of visual wrapping. See `:help ip`,
`:help ap`, and `:help is`.

### Jump directly to visible text

[vim-sneak](https://github.com/justinmk/vim-sneak) searches for exactly two
literal characters across file lines without pressing Enter:

| Keys | Action |
| --- | --- |
| `swo` | Jump forward to the next `wo` |
| `Swo` | Jump backward to the previous `wo` in Normal mode |
| `;` / `,` | Repeat the latest find/Sneak motion / reverse it |
| `3;` | Repeat three times |
| `s` then Enter | Repeat the last Sneak search, even after using `f`/`t` |
| Visual `swo` / `Zwo` | Extend selection forward / backward to `wo` |
| `dzwo` / `dZwo` | Delete up to `wo` forward / backward |
| `czwo` / `yzwo` | Change / yank up to `wo` |
| `.` | Repeat a Sneak edit, supported by vim-repeat |

Sneak uses case-sensitive matching here. `;`/`,` follow whichever motion you
used most recently, including native `f`/`t`. A count before Sneak itself
(`5swo`) restricts its column scope; it does **not** select the fifth match.
Sneak replaces native Normal-mode `s`/`S`; use `cl`/`cc` for those substitution
operations. See `:help sneak`.

[mini.jump2d](https://github.com/nvim-mini/mini.jump2d) offers a different
workflow: look at a target, press Space `jw` for word labels or Space `jl`
for file-line labels, then type the label at that target. If several targets
share a label, type it and follow the updated labels until one remains.
Esc cancels. Both shortcuts also work in Visual mode to extend a selection,
and target only the current window. Enter keeps its native behavior outside
an active label jump.

Line labels refer to **file lines**, not each wrapped screen row; a long
paragraph has one line start. Use word labels or `gj`/`gk` to reach positions
within it. Targets whose labels are outside the viewport or hidden by
concealment are better reached with Sneak or search. See `:help mini.jump2d`.

### Search farther away

Use `/distinctive phrase` then Enter for forward search, or `?phrase` for
backward search. `n` repeats in the search direction and `N` reverses it.
`*`/`#` search forward/backward for the word under the cursor. Search accepts
regular expressions; `/\Vliteral text` uses very-nomagic matching (backslashes
still have special meaning). Esc clears highlighting.

Space `/` lists fuzzy paragraph/line matches in this document, including
offscreen text. Space `fg` searches across project files; Space `ff` locates a
document by its name. See `:help /`, `:help star`, and
`:help telescope.builtin.current_buffer_fuzzy_find()`.

### Headings, bookmarks, and return trips

The already-installed [vim-markdown](https://github.com/preservim/vim-markdown)
provides heading navigation in Markdown buffers:

| Keys / command | Action |
| --- | --- |
| `]]` / `[[` | Next / previous heading |
| `][` / `[]` | Next / previous sibling heading |
| `]u` / `]h` | Parent / current heading |
| Space `jt` or `:Toc` | Open a navigable heading outline |

In the TOC location-list window, select a heading and press Enter to jump;
`:lclose` closes the outline. These shortcuts are plugin-provided Markdown
heading motions, rather than native Vim section motions.

Use Grapple for a chapter/outline/research shortlist: Space `fa` toggles the
current file, Space `fm` lists marks, and Space `1` through Space `4` jump directly.
Marks stay separate between books or repositories and persist across restarts.

Set a bookmark with `ma`, then return to its exact position with backtick
followed by `a`; `'a` returns to the line's first nonblank character. Uppercase
marks such as `mA` can identify locations across files. `Ctrl-o` returns to an
older jump and `Ctrl-i` moves forward again. Sneak adds its initial jump to
the jumplist, so `Ctrl-o` can return to where you began after a series of
Sneak repetitions. See `:help mark-motions` and `:help jumplist`.

### A practical example

Imagine this paragraph is one file line, wrapping over several screen rows:

```markdown
# Draft

The harbor was quiet. A wooden boat waited beside the old pier, while the morning light spread across the water. Nobody had noticed the unopened letter on the seat.

## The letter

The next paragraph begins here.
```

Starting at `The harbor`, type `swo` to reach `wooden`, then `swa` to reach
`waited`. Use `)` to move toward the next sentence, or Space `jw` and its label
to jump to `unopened`. Use `j` to move down one wrapped row, `g$` to reach that
row's end, or `$` to reach the end of the whole paragraph. `vip` selects the
paragraph; `]]` reaches the next heading. Space `/` plus `unopened letter`
finds this paragraph even when it is offscreen. `Ctrl-o` returns through
earlier jumps.

## Optional alternative

[flash.nvim](https://github.com/folke/flash.nvim) offers variable-length search
with labels and optional integration with `/` and character motions. It is
not installed: Sneak covers quick two-character jumps, mini.jump2d covers
visible labels, and Telescope covers document/project searches. If trying
Flash later, use separate keys and disable its character-motion overrides to
avoid collisions with this setup.

Reference: [Neovim motion documentation](https://neovim.io/doc/user/motion/).

## Verify an update

Run `:Lazy install`, `:Lazy restore`, and `:checkhealth`. Check Sneak, its operator
motions and dot-repeat; label jumps in Normal/Visual modes and their cancellation;
native Enter; wrapped `j/k`, counted movement, and operators on a long paragraph;
heading motions and the TOC; both buffer searches and root-aware project search.
Open another chapter to check focus stays open, then a code file to check prose
options and mappings do not leak. Test marks in two projects and restart to check
mark and undo persistence. Linux uses the same writing-navigation Lua module,
with plugins supplied by Home Manager instead of Lazy.
