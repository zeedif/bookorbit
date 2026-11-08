local fallback = setmetatable({ current_lang = "en_US" }, {
    __call = function(_, text) return "fallback:" .. text end,
})
fallback.ngettext = function(singular, plural, count) return count == 1 and singular or plural end
fallback.pgettext = function(context, text) return context .. ":" .. text end
package.loaded["gettext"] = fallback
package.path = "koreader-plugin/bookorbit.koplugin/?.lua;" .. package.path
local _ = require("bookorbit_gettext")

assert(_("Read") == "fallback:Read")
assert(not package.loaded["bookorbit_l10n_es"])
assert(_.ngettext("%1 book", "%1 books", 2) == "%1 books")
assert(_.pgettext("action", "Read") == "action:Read")

for index, language in ipairs({ "es", "es_ES", "es-MX", "es_AR.UTF-8", "ES:en" }) do
    fallback.current_lang = language
    assert(_("Read") == "Leído", language)
    assert(_.pgettext("action", "Read") == "Leer", language)
    assert(_.pgettext("sort", "Read") == "Última lectura", language)
    assert(_.pgettext("author-filter", "Read") == "Leídos", language)
    assert(_.pgettext("month-day", "%1 %2") == "%2 %1", language)
    assert(_.ngettext("%1 book", "%1 books", 1) == "%1 libro", language)
    assert(_.ngettext("%1 book", "%1 books", 0) == "%1 libros", language)
    assert(_.ngettext("%1 book", "%1 books", 25) == "%1 libros", language)
    assert(_("Jan") == "ene.", language)
    assert(_("Spanish") == "español", language)
end

assert(_("Missing message") == "fallback:Missing message")
assert(_.pgettext("missing", "Missing message") == "missing:Missing message")
assert(_.ngettext("One missing", "Many missing", 2) == "Many missing")

for index, language in ipairs({ "fr", "en", "C", "estonian", "esperanto", "esoteric" }) do
    fallback.current_lang = language
    assert(_("Read") == "fallback:Read", language)
end
assert(fallback.translation == nil)
assert(fallback.current_lang == "esoteric")
print("bookorbit_gettext_test.lua: ok")
