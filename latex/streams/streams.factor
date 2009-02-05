! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel assocs make io io.styles io.files 
io.streams.string accessors strings destructors namespaces 
sbufs prettyprint  combinators
help continuations math fry
latex.stylesheet vocabs.loader latex
;
IN: latex.streams

SYMBOL: stream-type
SYMBOL: tex-span
SYMBOL: tex-block
SYMBOL: tex-cell

TUPLE: latex-stream stream type ; 

: <latex-stream> ( stream -- latex-stream ) 
    f latex-stream boa ;

<PRIVATE
TUPLE: latex-sub-stream < latex-stream style parent ;

: new-latex-sub-stream ( style stream class -- stream )
    new
    512 <sbuf> >>stream
    swap >>parent
    swap >>style ; inline
 
: end-latex-sub-stream ( substream -- string style stream )
    [ stream>> >string ] [ style>> ] [ parent>> ] tri ;

: latex-plain ( string style -- ) 
  drop write ; inline

: latex-environment ( string style -- )
    $tex@ swap at swap 
    '[ _ write ] with-tex-environment ; inline

: latex-simple ( string style -- )
    $tex@ swap at $tex-cmd $tex-inbrace ; inline

: force-plain? ( style -- style ? )
    stream-type over at  
    tex-span = 
    [ $tex-plain-span ] [ f ] if
    over at  ;
: latex-remove-nl ( string style -- )
    drop [ 4 head* ] [ drop ] recover write ;

: latex-style ( string style -- )
    { 
        { [ $tex@ over at empty? ] [ latex-plain   ] }
 !       { [ stream-type over at "cell" = ] [ latex-plain ] }
        { [ force-plain?         ] [ latex-remove-nl   ] } 
        { [ $tex-short over at   ] [ latex-simple  ] }
        [ latex-environment ] 
    } cond
; inline

: latex-tag ( string style -- )
    stream-type over at tex-span =
    [ $tex-hide-span ] [ $tex-hide-block ] if
    over at  [ 2drop ] [ latex-style ] if
; inline

: style-type ( style stream -- style stream ) 
    [ type>> stream-type rot set-at ] 2keep ;

: format-latex ( string style stream -- )
    style-type stream>>  
    [ latex-tag ] with-output-stream* ;
 
TUPLE: latex-span-stream < latex-sub-stream ;
 
M: latex-sub-stream dispose
   dup type>> tex-cell = 
   [ drop  ] 
   [ end-latex-sub-stream format-latex ] if ;

PRIVATE>
! 
! Stream protocol
M: latex-stream stream-flush
    stream>> stream-flush ;
M: latex-stream stream-write1
    [ 1string ] dip stream-write ;
M: latex-stream stream-write
    [ $tex-escape-string ] dip 
    stream>> stream-write ;
M: latex-stream stream-format
    [ latex over at [ [ $tex-escape-string ] dip ] unless ] 
    dip format-latex ;
M: latex-stream stream-nl
!    dup type>> tex-block =
!    [ drop ] [  [ \\ ] with-output-stream*  ] if ;
    [ \\ ] with-output-stream*  ;
M: latex-stream make-span-stream
    latex-sub-stream new-latex-sub-stream tex-span >>type ;
M: latex-stream make-block-stream
    latex-sub-stream new-latex-sub-stream tex-block >>type ;
M: latex-stream make-cell-stream
    latex-sub-stream new-latex-sub-stream   tex-cell >>type ;

: latex-table-columns-declaration ( seq -- )
    "{" write
    first length
    {   { 1 [ "|p{12cm}|" write ] }
        { 2 [ "|p{6cm}|p{6cm}|"  write ] }
        { 3 [ "|p{4cm}|p{4cm}|p{4cm}|" write ] }
        [ 1+ [ "l" write ] [ drop "|" write ] interleave ]
    } case
    "}\n" write ;

: latex-write-table-tabular ( stream -- )
    "center" [ 
        "longtable" [
            dup latex-table-columns-declaration
            \hline [
                [ " & " write ]
                [ stream>> >string write ] 
                interleave \tabularnewline \hline
            ] each  
        ] with-tex-environment
    ] with-tex-environment ;

: latex-write-table-itemize ( stream -- )
    "itemize" [
        [ "item" $tex-cmd 
            second stream>> >string write
        ] each 
    ] with-tex-environment ;

M: latex-stream stream-write-table
    stream>> [
        $tex@ swap at "factor-list" =
        [ latex-write-table-itemize ] 
        [ latex-write-table-tabular ] if
    ] with-output-stream* ;
 
M: latex-stream dispose stream>> dispose ;

: with-latex-writer ( quot -- )
    [ print-topic ] help-hook set
     stylesheet clone [ 
     output-stream get <latex-stream> swap with-output-stream* 
     ] bind ; inline

: with-simple-latex-page ( quot -- )
    latex-header
    with-latex-writer
    latex-footer ;


