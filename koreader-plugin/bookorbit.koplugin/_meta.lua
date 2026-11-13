-- KOReader can read this file without the plugin folder on package.path.
local ok, _ = pcall(require, "bookorbit_gettext")
if not ok then _ = require("gettext") end
return {
    fullname = _("BookOrbit Sync"),
    description = _([[Browse and download your BookOrbit library from KOReader, then synchronize reading progress, book status, ratings, reading statistics and highlights to BookOrbit. Highlights sync two ways: notes, edits and deletions made in the BookOrbit web reader appear on this device and vice versa.]]),
}
