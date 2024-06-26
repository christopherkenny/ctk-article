// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}


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
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
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
          align(center)[
            #author.name \ 
            #if author.department != none [#author.department #linebreak()]
            #if author.university != none [#author.university #linebreak()]
            #if author.location != [] [#author.location #linebreak()]
            #author.email
          ]
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
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => ctk-article(
  title: [Untitled],
  authors: (
    ( name: [Author One],
        department: [Government],
    university: [An Organization],
    location: [],
          email: [email\@email.com] ),
    ( name: [Author Two],
        department: none,
    university: [Affiliation B],
    location: [],
          email: none ),
    ( name: [Author Three],
        department: none,
    university: none,
    location: [USA],
          email: [email2\@email.com] ),
    ( name: [Author Three],
        department: none,
    university: none,
    location: [New Row],
          email: [email3\@email.com] ),
    ),
  date: [June 26, 2024],
  abstract: [Abstracts can be included in documents in the YAML. The `ctk-article` format is a multipurpose article format that uses `Typst` in the backend.

],
  keywords: ("paper","abstract","typst",),
  font: ("Crimson","Crimson Text","Crimson Pro",),
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)


== Introduction
<introduction>
#emph[TODO] Create an example file that demonstrates the formatting and features of your format.

We can cite like normal @king1994designing.

== More Information
<more-information>
You can learn more about creating custom Typst templates here:

#link("https://quarto.org/docs/prerelease/1.4/typst.html#custom-formats")

= Lorem Ipsum
<lorem-ipsum>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse sem est, imperdiet ac commodo et, tempus eu nulla. Nullam dapibus lacinia nunc. Morbi in nisi in neque feugiat faucibus a ut quam. Suspendisse hendrerit et purus non vulputate. Donec tristique non odio ut dapibus. Aliquam vehicula ullamcorper nisl. Etiam eget consequat quam. Nulla purus elit, dictum ut nibh ac, consectetur posuere purus. Pellentesque gravida velit ut enim facilisis, vitae tempus odio cursus.

Ut quis justo eget magna luctus dictum. Aliquam tellus purus, bibendum quis orci et, fermentum facilisis velit. Sed tristique scelerisque nibh quis tempor. Fusce quis purus rhoncus, facilisis massa eu, commodo eros. Sed facilisis lobortis lorem, eget tincidunt lacus scelerisque in. Integer placerat sit amet mauris et tempus. Curabitur rhoncus arcu ornare sem mattis commodo vitae nec ligula. Duis lacinia purus tellus, id dapibus ante blandit non. Phasellus vel hendrerit nulla. Suspendisse commodo, tellus nec cursus sodales, quam risus consectetur est, sit amet facilisis augue ligula id metus. Sed sed dolor dictum, faucibus dolor at, varius felis. Vivamus ligula arcu, finibus vitae bibendum vitae, efficitur sit amet ligula. Cras eu vehicula mauris.

Vestibulum porta enim vitae justo auctor, id semper sapien finibus. Cras sodales quam nunc, in semper tellus sodales eu. Aenean ut fringilla diam. Maecenas in rutrum neque. Vivamus rhoncus, libero interdum fermentum tincidunt, lacus ipsum ultrices neque, ac varius lorem leo quis tortor. In mi purus, dapibus a arcu a, semper posuere orci. Nulla a dolor non augue semper lobortis. In hac habitasse platea dictumst. Maecenas imperdiet metus finibus semper rhoncus.

Quisque a interdum ligula. Aliquam sit amet metus eu tellus viverra sodales. Donec vitae ipsum urna. Morbi viverra aliquet tempor. Curabitur cursus at metus ornare placerat. Aliquam dapibus, est in porta condimentum, risus neque porta lorem, vitae maximus lacus nibh pharetra velit. Aenean ac posuere justo, luctus porttitor magna.

Donec nibh erat, ornare eleifend dictum vel, fringilla id elit. Mauris id eros a justo fringilla placerat. Nunc ligula sapien, sollicitudin ac tortor in, accumsan luctus quam. Nunc porttitor, sapien eu malesuada vehicula, risus libero convallis nunc, vel dapibus risus arcu eget ipsum. Nullam ornare enim et magna tempus, at rhoncus metus porta. Praesent tincidunt nec ante a vehicula. Nulla facilisi. Nulla eget aliquam sapien, eu condimentum augue.

= A List
<a-list>
- Item 1
- Item 2
- Item 3
  - a

= Including code
<including-code>
```r
plot(iris$Sepal.Length, iris$Sepal.Width)
```

#box(image("template_files/figure-typst/unnamed-chunk-1-1.svg"))

= Math works
<math-works>
You can use LaTeX math in Typst-powered Quarto documents:

$ 3 + 3 dot.op epsilon.alt $

Even better, you can use a Typst block to use the Typst syntax, allowing you to use both in one document:

$ A = pi r^2 $



#set bibliography(style: "chicago-author-date")

#bibliography("bibliography.bib")

