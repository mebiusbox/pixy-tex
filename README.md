# pixy-tex

docs で公開している PDF を生成する TeX 環境．
今は `luaLaTeX` + `TeXLive2024`．

## Quick Reference

| Command               | Arguments                      | Type | Description             |
| --------------------- | ------------------------------ | ---- | ----------------------- |
| `HRuleDots`           | `{text}`                       | Cmd  |                         |
| `HRuleLeader`         | `[margin]`                     | Cmd  |                         |
| `Rev`                 | `{denom}`                      | Cmd  |                         |
| `Drv`                 | `{num}{denom}`                 | Cmd  | Derivative              |
| `PDrv`                | `{num}{denom}`                 | Cmd  | Partial Derivative      |
| `DDrv`                | `{num}{denom}`                 | Cmd  | Deirvative (Delta)      |
| `PVec`                | `{vector}`                     | Env  | pmatrix                 |
| `BVec`                | `{vector}`                     | Env  | bmatrix                 |
| `PVecs`               | `{vector}`                     | Env  | pmatrix+scriptsize      |
| `BVecs`               | `{vector}`                     | Env  | bmatrix+scriptsize      |
| `PMat`                | `[opts]{matrix}`               | Env  | pmatrix[opts]           |
| `BMat`                | `[opts]{matrix}`               | Env  | bmatrix[opts]           |
| `DMat`                | `[opts]{matrix}`               | Env  | determinant             |
| `Inversion`           | `[opts]{vector}`               | Cmd  | mbox                    |
| `Vecbm`               | `[vector}`                     | Cmd  | mbox                    |
| `Table`               | `[opts]{colspec}`              | Env  | tabularray              |
| `Note`                | `[opts]{title}`                | Env  | tcolorbox               |
| `BracketBox`          | `[title]`                      | Env  | tcolorbox               |
| `Admonition`          | `[opts]{title}`                | Env  | tcolorbox               |
| `LabelItem`           | `[opts]{desc}{text}`           | Cmd  | item                    |
| `LabelText`           | `[opts]{desc}{text}`           | Cmd  | itemize                 |
| `Hl`                  | `{text}`                       | Cmd  | highlight               |
| `Em`                  | `{text}`                       | Cmd  | emphasize(color+bold)   |
| `EmLight`             | `{text}`                       | Cmd  | emphasize(color)        |
| `EmSub`               | `{text}`                       | Cmd  | emphasize(subcolor)     |
| `EmBox`               | `{text}`                       | Cmd  | emphasize(box)          |
| `EmSubBox`            | `{text}`                       | Cmd  | emphasize(box+subcolor) |
| `EmCode`              | `{text}`                       | Cmd  | code                    |
| `Inline`              | `{text}`                       | Cmd  | inline code (tcolorbox) |
| `RoundBox`            | `{color}`                      | Env  | tcolorbox               |
| `Code`                | `[listing opts]{opts}`         | Env  | tcblisting              |
| `NCode`               | `[listing opts]{opts}`         | Env  | tcblisting, linenumbers |
| `Source`              | `[listing opts]{opts}`         | Env  | tcblisting              |
| `NSource`             | `[listing opts]{opts}`         | Env  | tcblisting, linenumbers |
| `Pre`                 | `[listing opts]{opts}`         | Env  | tcblisting              |
| `Image`               | `[opts]{fig opts}{opts}{file}` | Cmd  | image                   |
| `Theorem`             | `[label]{title}`               | Env  |                         |
| `Memo`                | `[opts]{opts}`                 | Env  |                         |
| `ExprLine`            | `{math}{explain}`              | Cmd  |                         |
| `ExprBoxed`           | `{math}{explain}`              | Cmd  |                         |
| `ExprNote`            | `[color]{math}`                | Cmd  |                         |
| `RefLabelText`        | `{label}`                      | Cmd  |                         |
| `ExampleLabelText`    | `{label}`                      | Cmd  |                         |
| `ExampleSentence`     | `[offset]{text1}{text2}`       | Cmd  | minipage+itemize        |
| `ExampleSentenceItem` | `{text1}{text2}`               | Cmd  | itemize                 |
| `Rule`                | `[title]`                      | Env  | theorem                 |

### Table

```latex
\begin{Table}[
  colhdr,
  rowhdr,
  even
]{colspan}
...
\end{Table}
```

### Note

```latex
\begin{Note}[
  type=normal|left|invleft,
  colback=color,
  trans,
  sharp
]{title}
...
\end{Note}
```

### Admonition

```latex
\begin{Admonition}[
  type=note|info|warn|error
]{title}
...
\end{Admonition}
```

### LabelItem

```latex
\LabelItem[
  type=normal|main|accent|inv|invmain|invaccent|gray|blue|red|trans
]{description}{text}
```

### Image

```latex
\Image[
  size=w1|w2|w3|w4|w5|w6|w7|w8|w9|w0,
  frame,
  caption=...,
  label=...,
  center=yes|no,
]{figure options}{includegraphics options}{file}
```

### Memo

```latex
\begin{Memo}[
  width=<length>,
  offset=<length>,
  color=<color>
]{opts}
...
\end{Memo}
```

### Color Theme

| Name                | RGB           |
| ------------------- | ------------- |
| ColorThemeBack      | `255,255,255` |
| ColorThemeFore      | `77,77,77`    |
| ColorThemePrimary   | `0,113,188`   |
| ColorThemeSecondary | `255,80,80`   |
| ColorThemeSub1      | `242,242,242` |
| ColorThemeSub2      | `226,241,250` |
| ColorThemeSub3      | `255,234,234` |
| ColorThemeBlack     | `49,44,44`    |
| ColorThemeGraph     | `204,0,0`     |
| ColorThemeGraphSub  | `0,80,255`    |
