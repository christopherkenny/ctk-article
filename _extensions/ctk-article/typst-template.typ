
// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates


#let ctk-article(
  title: none,
  runningtitle: none,
  authors: none,
  date: none,
  abstract: none,
  keywords: none,
  cols: 1,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {

  let runningauth = if authors == none {
    none
  } else if authors.len() == 2 {
    authors.map(author => author.last).join(" and ")
  } else if authors.len() < 5 {
    authors.map(author => author.last).join(", ", last: ", and ")
  } else {
    authors.first().last + " et al."
  }

  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    header: locate(
      loc => {
      let pg = counter(page).at(loc).first()
        if pg == 1 {
          return
        } else if (calc.odd(pg)) [
            #align(right, runningtitle)
          ] else [
            #align(left, runningauth)
          ]
      }
    )
  )
  set par(
    justify: true,
    first-line-indent: 1em
  )
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center, {
            text(weight: "bold", author.name)  
            if author.department != none [
            \ #author.department
            ]
            if author.university != none [
            \ #author.university
            ]
            if author.location != [] [
            \ #author.location
            ]
            if "email" in author [
            \ #link("mailto:" + author.email.replace("\\", ""))
            ]
      })
    )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    align(center)[#block(width: 80%)[
      *Abstract* \
      #align(left)[#abstract]
    ]]
  }

  if keywords != none {
    align(left)[#block(inset: 1em)[
      *Keywords*: #keywords.join(", ", last: ", and ")
    ]]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
