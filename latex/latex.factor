USING: kernel syntax assocs make sequences io io.styles ;
IN: latex
: $tex-escape-char ( ch -- )
    dup H{
        { CHAR: $ "\\$" }
        { CHAR: & "\\&" }
        { CHAR: % "\\%" }
        { CHAR: # "\\#" }
        { CHAR: _ "\\_" }
        { CHAR: { "\\{" }
        { CHAR: } "\\}" }
        { CHAR: > "$>$" }
        { CHAR: < "$<$" }
        { CHAR: \n "\\\\ \n" }
    } at [ % ] [ , ] ?if ;

: $tex-escape-string ( string -- string )
    [ [ $tex-escape-char ] each ] "" make ;

SYMBOL: latex
: write-latex ( str -- ) H{ { latex t } } format ;
: \\ ( -- )      "\\\\ \n" write-latex ;
: \tabularnewline ( -- ) "\\tabularnewline\n" write-latex ;
: \hline ( -- )  "\\hline\n" write ;
: $tex-cmd  ( bal -- )        "\\" prepend write bl ;
: $tex-inbrace ( str -- )     
    "{" write-latex write "}" write-latex ;
: $tex-capsule ( str bal -- ) $tex-cmd $tex-inbrace ;

: with-tex-environment ( str quot -- )
    over
    [ "begin" $tex-capsule ]
    [ call ]
    [ "end" $tex-capsule ] tri*
; inline

! \input{subfile}

