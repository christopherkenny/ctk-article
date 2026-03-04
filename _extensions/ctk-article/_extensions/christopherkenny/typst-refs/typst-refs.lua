-- typst-refs.lua
-- Moves the Typst bibliography to the location of a {#refs} div.
--
-- By default, Quarto places the bibliography at the end of the document
-- for Typst output. This filter intercepts the document, replaces the
-- {#refs} div with a raw Typst #bibliography() call, and clears the
-- bibliography from the Pandoc metadata so the template does not also
-- inject one at the end.

-- Only activate for Typst output
if not quarto.doc.is_format("typst") then
  return {}
end

function Pandoc(doc)
  local meta = doc.meta

  -- Collect bibliography file(s) from metadata
  local bib_files = {}
  if meta.bibliography then
    local bib = meta.bibliography
    if type(bib) == "table" and bib.t == "MetaList" then
      for _, v in ipairs(bib) do
        local s = pandoc.utils.stringify(v)
        if s ~= "" then table.insert(bib_files, s) end
      end
    else
      local s = pandoc.utils.stringify(bib)
      if s ~= "" then table.insert(bib_files, s) end
    end
  end

  -- Nothing to do if no bibliography files are declared
  if #bib_files == 0 then
    return doc
  end

  -- Build the path argument for #bibliography()
  -- Single file: "file.bib"
  -- Multiple files: ("file1.bib", "file2.bib")
  local path_arg
  if #bib_files == 1 then
    path_arg = '"' .. bib_files[1] .. '"'
  else
    local quoted = {}
    for _, f in ipairs(bib_files) do
      table.insert(quoted, '"' .. f .. '"')
    end
    path_arg = '(' .. table.concat(quoted, ', ') .. ')'
  end

  -- Optionally include a style argument if csl or bibliographystyle is set.
  -- Note: the Quarto Typst template emits `#set bibliography(style: ...)` outside
  -- the $if(bibliography)$ block, so style is already handled for standard templates.
  -- We include it here as well for robustness (custom templates may differ).
  local style_arg = ""
  if meta.csl then
    local csl = pandoc.utils.stringify(meta.csl)
    if csl ~= "" then
      style_arg = ', style: "' .. csl .. '"'
    end
  elseif meta.bibliographystyle then
    local bstyle = pandoc.utils.stringify(meta.bibliographystyle)
    if bstyle ~= "" then
      style_arg = ', style: "' .. bstyle .. '"'
    end
  end

  -- Capture biblio-title if set. Some templates (e.g. harvard-diss) emit
  -- `#set bibliography(title: ...)` inside $if(bibliography)$, which we
  -- suppress by clearing meta.bibliography. We pass the title directly to
  -- #bibliography() so it is not lost.
  local title_arg = ""
  if meta['biblio-title'] then
    local t = pandoc.utils.stringify(meta['biblio-title'])
    if t ~= "" then
      title_arg = ', title: "' .. t .. '"'
    end
  end

  local bib_call = '#bibliography(' .. path_arg .. style_arg .. title_arg .. ')'

  -- Walk the top-level blocks and replace {#refs} divs with the Typst call
  local replaced = false
  local new_blocks = {}
  for _, block in ipairs(doc.blocks) do
    if block.t == "Div" and block.identifier == "refs" then
      table.insert(new_blocks, pandoc.RawBlock("typst", bib_call))
      replaced = true
    else
      table.insert(new_blocks, block)
    end
  end

  -- If there was no {#refs} div, leave the document untouched
  if not replaced then
    return doc
  end

  -- Remove bibliography from metadata so the Quarto/Pandoc Typst template
  -- does not also emit a #bibliography() call at the end of the document.
  -- Our raw block above takes its place.
  meta.bibliography = nil

  return pandoc.Pandoc(new_blocks, meta)
end
