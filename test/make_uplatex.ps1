$arguments = (
    "-e",
    "`$latex=q/uplatex %O -kanji=utf8 -no-guess-input-enc -synctex=1 -interaction=nonstopmode -file-line-error %S/",
    "-e",
    "`$bibtex=q/uplatex %O %B/",
    "-e",
    "`$biber=q/biber %O --bblencoding=utf8 u -U --output_safechars %B/",
    "-e",
    "`$makeindex=q/upmendex %O -o %D %S/",
    "-e",
    "`$dvipdf=q/dvipdfmx -v %O -o %D %S/",
    "-norc",
    "-pdfdvi",
    $Args[0]
)

latexmk -latex=uplatex -g $arguments
