! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING:  namespaces colors vocabs help.stylesheet io io.styles ;
IN: latex.stylesheet


SYMBOL: $tex@
SYMBOL: $tex-short 
SYMBOL: $tex-old
SYMBOL: $tex-hide-block
SYMBOL: $tex-hide-span
SYMBOL: $tex-plain-block
SYMBOL: $tex-plain-span
SYMBOL: $tex-plain-cell
SYMBOL: $tex-nlb
SYMBOL: $tex-nla

: stylesheet 

H{ 
{ default-span-style  H{ } }
{ default-block-style H{ } }
{ link-style          H{ } }
{ emphasis-style      H{ { $tex@ "emph" }
                         { $tex-short t } } }
{ strong-style        H{ } }
    ! { $tex@ "strong" } } }
{ title-style         H{ { $tex-short t }
                         { $tex@ "section*" }
                         { $tex-plain-span t } } }
{ help-path-style     H{ { $tex@ "footnote" }
                         { $tex-short t } 
                         { $tex-hide-block t } } }
{ heading-style       H{ { $tex@ "subsection*" }
                         { $tex-short t } } }
{ subsection-style    H{ { $tex@ "subsubsection*" }
                         { $tex-short t } } }
{ snippet-style       H{ { $tex@ "factor-snippet" } } }
{ code-style          H{ { $tex@ "factor-code" } } }
{ input-style         H{ { $tex@ "factor-input" } } }
{ url-style           H{ } }
    ! H{ { $tex@ "factor-url" } } }
{ warning-style       H{ { $tex@ "warning" } } }
                         { table-content-style H{ } }
{ table-style         H{ { $tex@ "table-style" } } }
{ list-style          H{ { $tex@ "factor-list" } } }
{ bullet              ">" }
}
;

: latex-header ( -- )
    "\\documentclass[11pt,twoside,a4paper]{article}\n" write 
    "\\usepackage{longtable}\n" write
    "\\setlength{\\parskip}{0.5ex}\n" write
    "\\setlength{\\parindent}{0ex}\n" write
    "\\newenvironment{factor-code}{\\begin{itemize}\\begin{code}}{\n\\end{code}\\end{itemize}}\n" write
    "\\newenvironment{factor-snippet}{\\ttfamily}{}\n" write
    "\\newenvironment{factor-input}{\\textbf}{}\n" write
!    "\\newcommand{factor-input}[1]{\\textbf{#1}}\n" write
    "\\newenvironment{factor-link}{\\textbf}{}\n" write
    "\n\\begin{document}\n" write
;

: latex-footer ( -- )
     "\\end{document}\n" write
;
