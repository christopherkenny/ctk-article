// better way to avoid escape characters, rather than doing a regex for \\@
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// ctk-article definition starts here
// everything above is inserted by Quarto

#let ctk-article(
  title: none,
  subtitle: none,
  runningtitle: none,
  authors: none,
  date: none,
  abstract: none,
  thanks: none,
  keywords: none,
  cols: 1,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  mathfont: "New Computer Modern Math",
  codefont: "DejaVu Sans Mono",
  sectionnumbering: "1.1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  linestretch: 1,
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
    first-line-indent: 1em,
    leading: linestretch * 0.65em
  )
  // Font stuff
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize
  )
  show math.equation: set text(font: mathfont)
  show raw: set text(font: codefont)

  set heading(numbering: sectionnumbering)

  // metadata
  set document(
    title: title,
    author: to-string(runningauth),
    date: auto,
    keywords: keywords.join(", ")
  )

  // show rules
  // show figure.where(kind: "quarto-float-fig"): set figure.caption(position: top)

  show link: this => {
    if type(this.dest) != label {
      text(this, fill: rgb("#800000"))
    } else {
      text(this, fill: rgb("#0000CC"))
    }
  }

  show ref: this => {
    text(this, fill: rgb("#640872"))
  }

  // start article content
  if title != none {
    align(center)[
      #block(inset: 2em)[
        #text(weight: "bold", size: 30pt)[
          #title #if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }
        ]
        #if subtitle != none {
          linebreak()
          text(subtitle, size: 24pt, weight: "semibold")
        }
      ]
    ]
  }

// author spacing based on Quarto ieee licenced CC0 1.0 Universal
// https://github.com/quarto-ext/typst-templates/blob/main/ieee/_extensions/ieee/typst-template.typ
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
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
            \ #link("mailto:" + to-string(author.email))
            ]
      }))
    )

    v(20pt, weak: true)
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

#let appendix(body) = {
  set heading(
    numbering: "A.1",
    supplement: [Appendix]
    )
  set figure(
    numbering: (..nums) => {
      "A" + numbering("1", ..nums.pos())
    },
    supplement: [Appendix Figure]
  )
  counter(heading).update(0)
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)

  body
}
#set table(
  inset: 6pt,
  stroke: none
)
