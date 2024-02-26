$list = @(
    ("\input{../pixylua_article_a4_10}", "main_article.tex", "article_a4_10.pdf"),
    ("\input{../pixylua_article_a4_10_two}", "main_article.tex", "article_a4_10_twocolumn.pdf"),
    ("\input{../pixylua_article_a4_11}", "main_article.tex", "article_a4_11.pdf"),
    ("\input{../pixylua_article_a4_11_two}", "main_article.tex", "article_a4_11_twocolumn.pdf"),
    ("\input{../pixylua_report_a4_10}", "main_report.tex", ""), # .aux, .toc の生成
    ("\input{../pixylua_report_a4_10}", "main_report.tex", "report_a4_10.pdf"),
    ("\input{../pixylua_report_a4_11}", "main_report.tex", "report_a4_11.pdf"),
    ("\input{../pixylua_report_a5_10}", "main_report.tex", "report_a5_10.pdf"),
    ("\input{../pixylua_report_a5_11}", "main_report.tex", "report_a5_11.pdf"),
    ("\input{../pixylua_book_a4_10}", "main_book.tex", "book_a4_10.pdf"),
    ("\input{../pixylua_book_a4_11}", "main_book.tex", "book_a4_11.pdf"),
    ("\input{../pixylua_book_a4_10}`n\def\pixybooktype{double}", "main_book.tex", "book_a4_10_double.pdf"),
    ("\input{../pixylua_book_a4_11}`n\def\pixybooktype{double}", "main_book.tex", "book_a4_11_double.pdf")
)
$tempfile = "temp.tex"
$defines = @"
`n\def\pixycodefont{IosevkaSS16}
\def\pixymathfont{STIX}
\def\pixysectionstyle{block}
\def\pixyjafont{DigiKyouka}
"@

if (Test-Path $tempfile) {
    latexmk -C $tempfile
    Remove-Item $tempfile
}
foreach ($_ in $list) {
    Write-Output $_[0] > $tempfile
    Write-Output $defines >> $tempfile
    Get-Content $_[1] >> $tempfile
    if ($_[2] -ne "") {
        latexmk -g $tempfile
        if (Test-Path $_[2]) {
            Remove-Item $_[2]
        }
        Rename-Item temp.pdf $_[2]
    } else {
        latexmk -gg $tempfile
    }
}
latexmk -C $tempfile
Remove-Item $tempfile
