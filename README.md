# ctk-article Format

The `ctk-article` Quarto template is a general purpose article template, designed for academic papers and preprints.

<!-- pdftools::pdf_convert('template.pdf', pages = 1) -->
![[template.qmd](template.qmd)](template_1.png)

## Installing

```bash
quarto use template christopherkenny/ctk-article
```
This will install the format extension and create an example qmd file
that you can use as a starting place for your document.

## Using `ctk-article`

This extension builds your Quarto documents using a Typst backend.
[Typst](https://github.com/typst/typst) is a newer (~5 years old), but relatively developed approach to typsetting technical documents.
This is substantially faster than LaTeX but is likely less familiar.
I recommend using Typst for social sciences, as it gives sufficient control over formatting while being far more intuitive than LaTeX (even as a decade+ regular user of LaTeX).
This template is what I am using for the job market in 2024.

By the beauty of Quarto, this should not change your experience in any meaningful negative ways.
You can use LaTeX equations, Quarto callouts, etc.
But, you may want to save any images as `.png` or `.svg` files as Typst's main drawback (right now) is the lack of `.pdf` image support.

This template has many custom options and optimizes for generic preprints.
Some options you can set:

- `title`: Your article's title
- `subtitle`: Your article's subtitle
- `running-title`: A short title to include in the article's header
- `author`: Author and affiliation information, following [Quarto's schema](https://quarto.org/docs/journals/authors.html).+
    - `orcid`: Ids are displayed as a green ORCIDiD logo link
    - `email`: Emails are listed as links under authors.
    - Departments, affiliation names, and locations are also listed in a compact fashion.
- `thanks`: Acknowledgements to add as a footnote to the first page.
- `keywords`: [An, array, of, keywords, to, list]
- `margins`: These default to a sensible 1in all-around margin
- `mainfont`: See the fonts discusison below
- `fontsize`: Set the default font size. Default is 11pt.
- `linestretch`: line spacing. In academic fashion, the default is `1` (single-spaced). I recommend `1.25`.
- `linkcolor`: Add a splash of colors to your link.
- `title-page`: Add a separate title page
- `blind`: Blinds the document, hiding the authors and running author information.
- `biblio-title`: Title for the reference section

While writing, you can also identify the start of the appendix.
This resets the counters and updates the "supplements" for figures, so the first appendix figure becomes "Figure A1" instead of continuing the count from the main paper. Simply add the `{.appendix}` tag to the first appendix section to start this switch, like so:

```md
## Some Title for First Appendix Section {.appendix}
```

### Fonts

By default, the `ctk-article` format uses the Spectral font. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Spectral).

To check that it is installed, run:

```
quarto typst fonts
```

If no font by the name "Spectral" is found, it falls back to Crimson Text. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Crimson+Text).

If no font by the names "Spectral", "Crimson Text", or "Crimson" is found, the template falls back to Linux Libertine.

This backup font of Crimson Text is chosen to look like [Cory McCartan's cmc-article](https://github.com/corymccartan/cmc-article) which uses Cochineal.

### Running Headers

Running titles and authors alternate on the left and right of the header.
The title is placed on the right-hand side of odd pages and the author on the left-hand side of even pages.
Nothing is added to the header on the first page of the document.

By default, the running title is taken as the title. To override this, provide a `running-title` metadata field in the YAML frontmatter.

The author running header is taken from the `author` metadata field. They are formatting according to the following pattern:

- One author: `Last-Name-1`
- Two authors: `Last-Name-1 and Last-Name-2`
- Three authors: `Last-Name-1, Last-Name-2, and Last-Name-3`
- Four authors: `Last-Name-1, Last-Name-2, Last-Name-3, and Last-Name-4`
- Five or more authors: `Last-Name-1 et al.`

## License

This template is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
