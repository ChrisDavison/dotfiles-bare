#!/usr/bin/env fish

function to_pdf_mobile
    set -l filename $argv
    set -l filename_out (noext $filename).pdf
    set -l base (noext $filename)
    set -l title (echo $base | sed 's/[^ _-]*/\u&/g' | sed 's/-/ /g')
    pandoc $filename --self-contained --standalone --template eisvogel -o $filename_out -V title=$title -V author="Chris Davison" -V titlepage=true --listings -V papersize:b6 -V geometry:margin=5mm
end
