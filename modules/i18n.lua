-- Capa sencilla para elegir idioma sin complicar el addon.
EZOAuto_Lang = EZOAuto_Lang or {}

local function ApplyString(id, value, version)
    local stringId = _G[id]
    if stringId == nil then
        ZO_CreateStringId(id, value)
        stringId = _G[id]
    end

    if stringId ~= nil then
        SafeAddString(stringId, value, version)
    end
end

function EZOAuto_Lang.Apply(language)
    local effectiveLanguage = language
    if EZOAuto and type(EZOAuto.GetEffectiveLanguage) == "function" then
        effectiveLanguage = EZOAuto.GetEffectiveLanguage(language)
    end

    local source = (effectiveLanguage == "es" and EZOAUTO_STRINGS_ES) or EZOAUTO_STRINGS_EN
    if not source then return end

    EZOAuto_Lang._stringVersion = (tonumber(EZOAuto_Lang._stringVersion) or 0) + 1
    for key, value in pairs(source) do
        ApplyString(key, value, EZOAuto_Lang._stringVersion)
    end

    EZOAuto_Lang.current = (effectiveLanguage == "es") and "es" or "en"
    EZOAuto_Lang.configured = tostring(language or "auto")
end
