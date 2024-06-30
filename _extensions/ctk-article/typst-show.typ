// start typst-show within ctk-article

#show: doc => ctk-article(
$if(title)$
  title: [$title$],
$endif$
$if(running-title)$
  runningtitle: [$running-title$],
$else$
$if(title)$
  runningtitle: [$title$],
$endif$
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      last: [$it.name.family$],
    $for(it.affiliations/first)$
    department: $if(it.department)$[$it.department$]$else$none$endif$,
    university: $if(it.name)$[$it.name$]$else$none$endif$,
    location: [$if(it.city)$$it.city$$if(it.country)$, $endif$$endif$$if(it.country)$$it.country$$endif$],
    $endfor$
    $if(it.email)$
      email: "$it.email$"
    $endif$
      ),
$endif$
$endfor$
    ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
$if(keywords)$
  keywords: ($for(keywords)$"$keywords$",$endfor$),
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ($for(mainfont)$"$mainfont$",$endfor$),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
$if(toc-indent)$
  toc_indent: $toc-indent$,
$endif$
  toc_depth: $toc-depth$,
  cols: $if(columns)$$columns$$else$1$endif$,
$if(linestretch)$
  linestretch: $linestretch$,
$endif$
  doc,
)
