#let titled-raw-block(body, filename: none) = {
  if (filename != none) {
    block(
      inset: 0em,
      fill: luma(200),
      radius: 8pt,
      outset: 0.75em,
      width: 100%,
      spacing: 2em,
      [
      #text(font: "DejaVu Sans Mono")[#filename]
      #block(
        fill: luma(230),
        inset: 0em,
        above: 1.2em,
        outset: 0.75em,
        radius: (bottom-left: 8pt, bottom-right: 8pt),
        width: 100%,
        body
      )
    ]
    )
  } else {
    body
  }
}

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

#let orcid_svg = str(
  "<?xml version=\"1.0\" encoding=\"utf-8\"?>
  <!-- Generator: Adobe Illustrator 19.1.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
  <svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
    viewBox=\"0 0 256 256\" style=\"enable-background:new 0 0 256 256;\" xml:space=\"preserve\">
  <style type=\"text/css\">
    .st0{fill:#A6CE39;}
    .st1{fill:#FFFFFF;}
  </style>
  <path class=\"st0\" d=\"M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z\"/>
  <g>
    <path class=\"st1\" d=\"M86.3,186.2H70.9V79.1h15.4v48.4V186.2z\"/>
    <path class=\"st1\" d=\"M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5
      c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z\"/>
    <path class=\"st1\" d=\"M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1
      C84.2,46.7,88.7,51.3,88.7,56.8z\"/>
  </g>
  </svg>"
)

// ctk-article definition starts here
// everything above is inserted by Quarto

#let ctk-article(
  title: none,
  subtitle: none,
  runningtitle: none,
  //runningauth: none,
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
  sectionnumbering: "1.1.",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  linestretch: 1,
  linkcolor: "#800000",
  title-page: false,
  blind: false,
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
    header: locate( // TODO: must be updated for typst >= 0.13
      loc => {
      let pg = counter(page).at(loc).first()
        if pg == 1 {
          return
        } else if (calc.odd(pg)) [
            #align(right, runningtitle)
          ] else [
            #if blind [
              #align(right)[
                #text(runningtitle)
              ]
            ] else [
              #align(left)[
                #text(runningauth)
              ]
            ]
          ]
          v(-8pt)
          line(length: 100%)
      }
    )
  )

  set page(
    numbering: none
    ) if title-page

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


  show figure.caption: it => [
    #v(-1em)
    #align(left)[
      #block(inset: 1em)[
        #text(weight: "bold")[
          #it.supplement
          #context it.counter.display(it.numbering)
        ]
        #it.separator
        #it.body
      ]
    ]
  ]


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

  set footnote.entry(indent: 0em, gap: 0.75em)

  show link: this => {
    if type(this.dest) != label {
      text(this, fill: rgb(linkcolor.replace("\\#", "#")))
    } else {
      text(this, fill: rgb("#0000CC"))
    }
  }

  show ref: this => {
    text(this, fill: rgb("#640872"))
  }

  show cite.where(form: "prose"): this => {
    text(this, fill: rgb("#640872"))
  }

  set list(indent: 2em)
  set enum(indent: 2em)

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
          text(subtitle, size: 18pt, weight: "semibold")
        }
      ]
    ]
  }


// author spacing based on Quarto ieee licenced CC0 1.0 Universal
// https://github.com/quarto-ext/typst-templates/blob/main/ieee/_extensions/ieee/typst-template.typ
  if not blind {
    for i in range(calc.ceil(authors.len() / 3)) {
      let end = calc.min((i + 1) * 3, authors.len())
      let slice = authors.slice(i * 3, end)
      grid(
        columns: slice.len() * (1fr,),
        gutter: 12pt,
        ..slice.map(author => align(center, {
              text(weight: "bold", author.name)
              if "orcid" in author [
                #link("https://orcid.org/" + author.orcid)[
                  #box(height: 9pt, image.decode(orcid_svg))
                ]
              ]
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
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    align(center)[#block(width: 85%)[
      #set par(
        justify: true,
        first-line-indent: 0em,
        leading: linestretch * 0.65em * .85
      )
      *Abstract* \
      #align(left)[#abstract]
    ]]
  }

  if keywords != none {
    align(left)[#block(inset: 1em)[
      *Keywords*: #keywords.join(" • ")
    ]]
  }

  if title-page {
    // set page(numbering: none)
    // pagebreak()
    counter(page).update(n => n - 1)
  }
  set page(numbering: "1",
        header: locate(
      loc => {
      let pg = counter(page).at(loc).first()
        if (calc.odd(pg)) [
          #align(right, runningtitle)
        ] else [
          #if blind [
            #align(right, runningtitle)
          ] else [
            #align(left, runningauth)
          ]
        ]
      }
    )) if title-page


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
    numbering: "A.1.",
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
