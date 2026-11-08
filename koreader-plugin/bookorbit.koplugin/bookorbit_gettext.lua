local GetText = require("gettext")

local BookOrbitGetText = {}
local spanish

local function catalog()
    local language = type(GetText) == "table" and GetText.current_lang or ""
    if type(language) ~= "string" then return nil end
    language = language:lower()
    if language ~= "es" and not language:match("^es[_%-%.:@]") then return nil end
    if not spanish then spanish = require("bookorbit_l10n_es") end
    return spanish
end

local function translate(msgid)
    local messages = catalog()
    local value = messages and messages.translation[msgid]
    if type(value) == "table" then return value[0] end
    return value or GetText(msgid)
end

function BookOrbitGetText.ngettext(singular, plural, count)
    local messages = catalog()
    local value = messages and messages.translation[singular]
    if type(value) == "table" then return value[count == 1 and 0 or 1] end
    return GetText.ngettext(singular, plural, count)
end

function BookOrbitGetText.pgettext(context, msgid)
    local messages = catalog()
    local value = messages and messages.context[context] and messages.context[context][msgid]
    if value then return value end
    if type(GetText) == "table" and GetText.pgettext then return GetText.pgettext(context, msgid) end
    return GetText(msgid)
end

return setmetatable(BookOrbitGetText, {
    __call = function(_, msgid) return translate(msgid) end,
    __index = function(_, key) return GetText[key] end,
})
