# Tokyo Night

Tokyo Night color scheme for [spotatui](https://github.com/LargeModGames/spotatui).

## Install

```bash
spotatui plugin add JoseToitio/spotatui-tokyo-night
```

Or drop the `tokyo-night/` folder into `~/.config/spotatui/plugins/`.

Requires plugin API 6 (spotatui 0.39+).

## Colors

| Key | Hex |
|---|---|
| background | #1a1b26 |
| text | #ffffff |
| active / hovered | #7aa2f7 |
| selected | #7dcfff |
| header / banner | #bb9af7 |
| playbar_background | #292e42 |
| playbar_progress | #9ece6a |
| playbar_text / playbar_progress_text | #c0caf5 |
| highlighted_lyrics | #7dcfff |
| analysis_bar | #7aa2f7 |
| analysis_bar_text | #1a1b26 |
| error | #f7768e |
| hint / inactive | #565f89 |

Note: `selected` is a **foreground** color in spotatui — it styles the track title in
the playbar, list selections, and headings. Setting it to a dark background shade
makes the track name invisible.
