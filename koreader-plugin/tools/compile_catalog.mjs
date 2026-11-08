import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

export function parseCatalog(text) {
  const entries = []
  let entry = { strings: {} }
  let field
  const finish = () => {
    if (entry.msgid && !entry.fuzzy) {
      if (!Object.hasOwn(entry.strings, '0') || Object.values(entry.strings).some((value) => !value)) {
        throw new Error(`Empty translation: ${entry.msgid}`)
      }
      if (entry.msgid_plural && !Object.hasOwn(entry.strings, '1')) {
        throw new Error(`Missing Spanish plural: ${entry.msgid}`)
      }
      entries.push(entry)
    }
    entry = { strings: {} }
    field = undefined
  }
  for (const line of text.replace(/^\uFEFF/, '').split(/\r?\n/)) {
    if (!line.trim()) {
      finish()
      continue
    }
    if (line.startsWith('#')) {
      if (/^#,.*\bfuzzy\b/.test(line)) entry.fuzzy = true
      continue
    }
    const match = line.match(/^(msgctxt|msgid_plural|msgid|msgstr(?:\[(\d+)\])?)\s+(".*")$/)
    let value
    if (match) {
      field = match[1].startsWith('msgstr') ? ['strings', match[2] ?? '0'] : [match[1]]
      value = JSON.parse(match[3])
    } else if (line.startsWith('"') && field) {
      value = JSON.parse(line)
    } else {
      throw new Error(`Unsupported PO syntax: ${line}`)
    }
    const owner = field.length === 2 ? entry.strings : entry
    const key = field.at(-1)
    owner[key] = (owner[key] ?? '') + value
  }
  finish()
  return entries
}

export function compileCatalog(text) {
  const translation = new Map()
  const contexts = new Map()
  const quote = (value) => JSON.stringify(value)
  for (const entry of parseCatalog(text)) {
    const target = entry.msgctxt ? (contexts.get(entry.msgctxt) ?? new Map()) : translation
    if (entry.msgctxt) contexts.set(entry.msgctxt, target)
    if (target.has(entry.msgid)) throw new Error(`Duplicate message: ${entry.msgid}`)
    const value = entry.msgid_plural ? `{ [0] = ${quote(entry.strings[0])}, [1] = ${quote(entry.strings[1])} }` : quote(entry.strings[0])
    target.set(entry.msgid, value)
  }
  const rows = (entries, indent) => [...entries].map(([key, value]) => `${indent}[${quote(key)}] = ${value},`)
  return [
    '-- Generated from l10n/es.po with tools/compile_catalog.mjs.',
    'return {',
    '    translation = {',
    ...rows(translation, '        '),
    '    },',
    '    context = {',
    ...[...contexts].flatMap(([context, entries]) => [`        [${quote(context)}] = {`, ...rows(entries, '            '), '        },']),
    '    },',
    '}',
    '',
  ].join('\n')
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const plugin = path.resolve(import.meta.dirname, '../bookorbit.koplugin')
  const compiled = compileCatalog(fs.readFileSync(path.join(plugin, 'l10n/es.po'), 'utf8'))
  const target = path.join(plugin, 'bookorbit_l10n_es.lua')
  if (process.argv.includes('--check')) {
    if (fs.readFileSync(target, 'utf8') !== compiled) throw new Error('Spanish runtime catalog is stale')
  } else fs.writeFileSync(target, compiled)
}
