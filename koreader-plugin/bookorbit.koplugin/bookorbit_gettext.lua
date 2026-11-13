--[[
Translations for the plugin's own strings.

KOReader's gettext only loads KOReader's catalog, so a plugin string is
translated only when KOReader happens to ship the same text. This module is a
drop-in for require("gettext"): it looks each string up in l10n/<lang>.po next
to the plugin and hands everything it does not know to KOReader's gettext.

The language is KOReader's interface language. A regional variant falls back
to its base language, so es_ES and es_MX both read l10n/es.po.
]]

local base = require("gettext")

local function baseField(name)
    if type(base) == "table" then return base[name] end
    return nil
end

local function pluginDir()
    local source = debug.getinfo(1, "S").source or ""
    return source:match("^@(.*)[/\\][^/\\]*$") or "."
end

local ESCAPES = { n = "\n", t = "\t", r = "\r", ['"'] = '"', ["\\"] = "\\" }

local function unquote(text)
    return (text:gsub("\\(.)", function(char) return ESCAPES[char] or char end))
end

-- Reads a PO file into { singles = { [key] = text }, plurals = { [key] = { [0] = ..., [1] = ... } } }.
-- A key is the msgid, prefixed by its msgctxt and "\4" when it has one.
local function parsePo(path)
    local file = io.open(path, "r")
    if not file then return nil end

    local catalog = { singles = {}, plurals = {} }
    local entry, field

    local function flush()
        if entry and entry.msgid and entry.msgid ~= "" and not entry.fuzzy then
            local key = entry.msgctxt and (entry.msgctxt .. "\4" .. entry.msgid) or entry.msgid
            if entry.msgid_plural then
                local forms, complete = {}, entry[0] ~= nil
                for index = 0, 5 do
                    if entry[index] == nil then break end
                    if entry[index] == "" then complete = false end
                    forms[index] = entry[index]
                end
                if complete then catalog.plurals[key] = forms end
            elseif entry.msgstr and entry.msgstr ~= "" then
                catalog.singles[key] = entry.msgstr
            end
        end
        entry, field = nil, nil
    end

    for line in file:lines() do
        line = line:gsub("\r$", "")
        local keyword, index, text = line:match('^(msg%a+_?%a*)%[?(%d?)%]?%s+"(.*)"%s*$')
        if line:match("^%s*$") then
            flush()
        elseif line:match("^#,.*fuzzy") then
            entry = entry or {}
            entry.fuzzy = true
        elseif line:sub(1, 1) == "#" then
            -- comment or reference
        elseif keyword then
            entry = entry or {}
            if keyword == "msgstr" and index ~= "" then
                field = tonumber(index)
            else
                field = keyword
            end
            entry[field] = unquote(text)
        elseif field and line:match('^"(.*)"%s*$') then
            entry[field] = entry[field] .. unquote(line:match('^"(.*)"%s*$'))
        end
    end
    flush()
    file:close()
    return catalog
end

local function loadCatalog()
    local lang = baseField("current_lang")
    if type(lang) ~= "string" or lang == "" or lang == "C" then return nil end
    lang = lang:gsub("%..*$", "")
    local dir = pluginDir() .. "/l10n/"
    local short = lang:match("^(%a+)")
    return parsePo(dir .. lang .. ".po") or (short and short ~= lang and parsePo(dir .. short .. ".po")) or nil
end

local catalog = loadCatalog()

local function pluralIndex(n)
    local getPlural = baseField("getPlural")
    if getPlural then return getPlural(n) end
    return n == 1 and 0 or 1
end

local GetText = {}

function GetText.ngettext(msgid, msgid_plural, n)
    local forms = catalog and catalog.plurals[msgid]
    local text = forms and forms[pluralIndex(n)]
    if text then return text end
    local fallback = baseField("ngettext")
    if fallback then return fallback(msgid, msgid_plural, n) end
    return n == 1 and msgid or msgid_plural
end

function GetText.pgettext(msgctxt, msgid)
    local text = catalog and catalog.singles[msgctxt .. "\4" .. msgid]
    if text then return text end
    local fallback = baseField("pgettext")
    if fallback then return fallback(msgctxt, msgid) end
    return msgid
end

function GetText.npgettext(msgctxt, msgid, msgid_plural, n)
    local forms = catalog and catalog.plurals[msgctxt .. "\4" .. msgid]
    local text = forms and forms[pluralIndex(n)]
    if text then return text end
    local fallback = baseField("npgettext")
    if fallback then return fallback(msgctxt, msgid, msgid_plural, n) end
    return n == 1 and msgid or msgid_plural
end

return setmetatable(GetText, {
    __call = function(_, msgid)
        local text = catalog and catalog.singles[msgid]
        if text then return text end
        return base(msgid)
    end,
    -- Anything else, such as current_lang, still comes from KOReader's gettext.
    __index = function(_, name) return baseField(name) end,
})
