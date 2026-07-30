# Tokyo Night

Tokyo Night color scheme for [spotatui](https://github.com/LargeModGames/spotatui), with the
upstream Night, Storm, and Moon variants.

## Install

```bash
spotatui plugin add JoseToitio/spotatui-tokyo-night
```

Or copy this repository into `~/.config/spotatui/plugins/spotatui-tokyo-night/`.

Requires plugin API 5 (spotatui 0.40.2+), for the persistent variant store.

## Switching variants

The plugin registers a `tokyo_night_cycle` command that rotates Night → Storm → Moon and
remembers your choice across restarts. Bind it to a key of your choosing in
`~/.config/spotatui/config.yml`:

```yaml
plugin_commands:
  tokyo_night_cycle: "ctrl-t"
```

Night is the default until you cycle away from it.

## Colors

Palette values are the upstream [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
ones. Night is Storm with the backgrounds darkened, which is how upstream defines it too.

| spotatui field | tokyonight key | Night | Storm | Moon |
|---|---|---|---|---|
| `background`, `playbar_background` | `bg` | #1a1b26 | #24283b | #222436 |
| `playbar_text`, `playbar_progress_text` | `fg` | #c0caf5 | #c0caf5 | #c8d3f5 |
| `active`, `hovered`, `analysis_bar` | `blue` | #7aa2f7 | #7aa2f7 | #82aaff |
| `selected`, `highlighted_lyrics` | `cyan` | #7dcfff | #7dcfff | #86e1fc |
| `header`, `banner` | `magenta` | #bb9af7 | #bb9af7 | #c099ff |
| `playbar_progress` | `green` | #9ece6a | #9ece6a | #c3e88d |
| `error_text`, `error_border` | `red` | #f7768e | #f7768e | #ff757f |
| `hint`, `inactive` | `comment` | #565f89 | #565f89 | #636da6 |
| `analysis_bar_text` | `bg` | #1a1b26 | #24283b | #222436 |
| `text` | — | #ffffff | #ffffff | #ffffff |

`text` is deliberately pure white instead of the palette's `fg`. It is the primary body
foreground, and the extra contrast against these backgrounds reads better than #c0caf5 does.

`playbar_background` deliberately matches `background` rather than using the palette's lighter
`bg_highlight`, so the playbar reads as part of the window instead of as a separate panel.

Two notes on how spotatui reads these fields:

- `selected` is a **foreground** color — it styles the track title in the playbar, list
  selections, and headings. Setting it to a dark background shade makes the track name invisible.
- `analysis_bar` and `analysis_bar_text` cannot be set from `config.yml` at all; they are only
  reachable through a plugin's `set_theme`.

Theme overrides are runtime-only and are never written back to `config.yml`. That is why the
plugin re-applies on every `start` event.

## Tokyo Night Day

Not included. Upstream generates the Day palette by inverting and blending the dark one at
runtime rather than listing hex values, so there is no authoritative table to port. A light
variant also needs its own foreground/background reasoning rather than the same key mapping —
see the `selected` note above.
