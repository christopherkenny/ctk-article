$if(citations)$
$if(csl)$

#set bibliography(style: "$csl$")
$elseif(bibliographystyle)$

#set bibliography(style: "$bibliographystyle$")
$endif$
$if(bibliography)$

#set par(
  first-line-indent: 0em,
  hanging-indent: 0em,
  leading: 0.65em
)

#bibliography($for(bibliography)$"$bibliography$"$sep$,$endfor$, title: "$biblio-title$")
$endif$
$endif$
