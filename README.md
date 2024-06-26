# ctk-article Format

## Installing

```bash
quarto use template christopherkenny/ctk-article
```

This will install the format extension and create an example qmd file
that you can use as a starting place for your document.

## Using

_TODO_: Describe how to use your format.

### Fonts

By default, the `ctk-article` format uses the Crimson Text font. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Crimson+Text).

To check that it is installed, run:

```
quarto typst fonts
```

If no font by the names "Crimson Text", "Crimson", or "Crimson Pro" is found, the template falls back to Linux Libertine.

This font is chosen to look like [Cory McCartan's cmc-article](https://github.com/corymccartan/cmc-article) which uses Cochineal.

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



