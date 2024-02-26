$targets = @(
    "sample_lualatex.tex",
    "sample_font.tex",
    "sample_info.tex",
    "sample_twocolumn.tex",
    "sample_tikz.tex"
)
foreach ($_ in $targets) {
    latexmk -C $_
    latexmk $_
    latexmk -c $_
}
