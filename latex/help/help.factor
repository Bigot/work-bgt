! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.encodings.ascii io.encodings.binary
io.files io.files.temp io.directories html.streams 
html.elements help kernel
assocs sequences make words accessors arrays help.topics vocabs
tools.vocabs tools.vocabs.browser namespaces prettyprint io
io.styles
vocabs.loader serialize fry memoize unicode.case math.order
help.html latex combinators continuations

sorting debugger latex.streams ;
IN: latex.help

GENERIC: topic>filename* ( topic -- name prefix )

M: word topic>filename*
    dup vocabulary>> [
        [ name>> ] [ vocabulary>> ] bi 2array "word"
    ] [ drop f f ] if ;

M: link topic>filename* 
    name>> dup [ "article" ] [ topic>filename* ] if ;
M: word-link topic>filename* name>> topic>filename* ;
M: vocab-spec topic>filename* vocab-name "vocab" ;
M: vocab-tag topic>filename* name>> "tag" ;
M: vocab-author topic>filename* name>> "author" ;
M: f topic>filename* drop \ f topic>filename* ;

: topic>latex-filename ( topic -- filename )
    topic>filename* dup [
        [
            % "-" %
            dup array?
            [ [ escape-filename ] map "," join ]
            [ escape-filename ]
            if % ".tex" %
        ] "" make
    ] [ 2drop f ] if ;

! M: topic browser-link-href topic>latex-filename ;

: all-vocabs-really ( -- seq )
    #! Hack.
    all-vocabs values concat
    vocabs [ find-vocab-root not ] filter [ vocab ] map append ;

: all-topics ( -- topics )
    [
        articles get keys [ >link ] map %
        all-words [ >link ] map %
        all-authors [ <vocab-author> ] map %
        all-tags [ <vocab-tag> ] map %
        all-vocabs-really %
    ] { } make ;

: serialize-index ( index file -- )
    [ [ [ topic>latex-filename ] dip ] 
        { } assoc-map-as object>bytes ] dip
    binary set-file-contents ;

: generate-indices ( -- )
    articles get keys [ [ >link ] [ article-title ] bi ] 
        { } map>assoc "articles.idx" serialize-index
    all-words [ dup name>> ] 
        { } map>assoc "words.idx" serialize-index
    all-vocabs-really [ dup vocab-name ] 
        { } map>assoc "vocabs.idx" serialize-index ;


: help>latex ( vocab -- )
     dup topic>latex-filename ! ".tex" append 
     utf8 
    [ dup article-title 
      drop
      [ help ]  with-latex-writer
    ] with-file-writer ;

: generate-latex-files ( -- )
    all-topics [ '[ _ help>latex ] try ] each 
;

: generate-latex-doc ( -- )
    "docs" temp-file
    [ make-directories ]
    [
        [
            generate-indices
            generate-latex-files
        ] with-directory
    ] bi ;

MEMO: load-index ( name -- index )
    binary file-contents bytes>object ;

TUPLE: result title href ;

: offline-apropos ( string index -- results )
    load-index swap >lower
    '[ [ drop _ ] dip >lower subseq? ] assoc-filter
    [ swap result boa ] { } assoc>map
    [ [ title>> ] compare ] sort ;

: article-apropos ( string -- results )
    "articles.idx" offline-apropos ;

: word-apropos ( string -- results )
    "words.idx" offline-apropos ;

: vocab-apropos ( string -- results )
    "vocabs.idx" offline-apropos ;

: word-help>latex ( word -- )
    dup ?word-name ".tex" append utf8 
    [ [ help ] with-simple-latex-page
    ] with-file-writer ;


: vocab>latex ( name -- )
    dup ".tex" append utf8 [ [ 
        [ "title" $tex-capsule ]
        [ vocab-authors [ 
            "" swap [ ", " append ] [ append ] interleave  
            "author" $tex-capsule ] when* 
            "maketitle" $tex-cmd
            ]
        [ >vocab-link ] tri
        { 
        [ [ help ] [ drop ] recover ]
!        [ vocab-name  ] 
        [ vocab-help [ "pagebreak" $tex-cmd help ] when* ]
        [ vocab-words values [ "pagebreak" $tex-cmd help ] each ]
        } cleave
    ] with-simple-latex-page ] with-file-writer ;



: cookbook>latex ( -- )
"cookbook.tex" utf8 [ [ 
    { 
    "cookbook" "cookbook-syntax" 
    "cookbook-colon-defs" 
    "cookbook-combinators" 
    "cookbook-variables" 
    "cookbook-vocabs" 
    "cookbook-io" 
    "cookbook-application"  
    "cookbook-scripts" 
    "cookbook-compiler" 
    "cookbook-philosophy"
    "cookbook-pitfalls" 
    "cookbook-next"
    } [ help ] each 
] with-simple-latex-page ] with-file-writer

;


