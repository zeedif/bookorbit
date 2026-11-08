import assert from 'node:assert/strict'
import test from 'node:test'
import { compileCatalog, parseCatalog } from './compile_catalog.mjs'

test('compile contextual messages, multiline strings and Spanish plurals', () => {
  const po = `msgid ""
msgstr ""
"Language: es\\n"

msgid "Read"
msgstr "Leído"

msgctxt "action"
msgid "Read"
msgstr "Leer"

msgid "%1 book"
msgid_plural "%1 books"
msgstr[0] "%1 libro"
msgstr[1] "%1 libros"

msgid "A note"
msgstr "Una nota: "
"\\"áéíóú\\"\\nSegunda línea."
`
  const entries = parseCatalog(po)
  assert.equal(entries.length, 4)
  assert.equal(entries[3].strings[0], 'Una nota: "áéíóú"\nSegunda línea.')
  const lua = compileCatalog(po)
  assert.ok(lua.includes('["Read"] = "Leído"'))
  assert.ok(lua.includes('["action"] = {\n            ["Read"] = "Leer"'))
  assert.ok(lua.includes('[0] = "%1 libro", [1] = "%1 libros"'))
})

test('reject incomplete plurals, empty translations and duplicates', () => {
  assert.throws(() => compileCatalog('msgid "a"\nmsgstr ""'), /Empty translation/)
  assert.throws(() => compileCatalog('msgid "a"\nmsgid_plural "b"\nmsgstr[0] "uno"'), /Missing Spanish plural/)
  assert.throws(() => compileCatalog('msgid "a"\nmsgstr "uno"\n\nmsgid "a"\nmsgstr "otro"'), /Duplicate message/)
})

test('leave fuzzy suggestions out of the runtime catalog', () => {
  assert.equal(parseCatalog('#, fuzzy\nmsgid "Read"\nmsgstr "Leer"').length, 0)
})
