-- Arranque principal del addon.
EZOAuto = EZOAuto or {}
local EZOA = EZOAuto

local ADDON_NAME = "EZOAuto"
local LANGUAGE_AUTO = "auto"
EZOA.runtime = EZOA.runtime or {}
EZOA.runtime.debugMode = EZOA.runtime.debugMode == true

local function Print(message)
    if LibChatMessage then
        LibChatMessage(ADDON_NAME, "EZOA"):Print(tostring(message))
    else
        d(tostring(message))
    end
end

EZOA.Print = Print

local function GetClientLanguage()
    if type(GetCVar) == "function" then
        local language = zo_strlower(tostring(GetCVar("Language.2") or ""))
        local prefix = language:sub(1, 2)
        if prefix == "es" then return "es" end
        if prefix == "en" then return "en" end
    end
    return "en"
end

function EZOA.GetDefaultLanguage()
    return LANGUAGE_AUTO
end

function EZOA.GetClientLanguage()
    return GetClientLanguage()
end

function EZOA.GetEffectiveLanguage(language)
    language = tostring(language or LANGUAGE_AUTO)
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function EZOA.IsForcedLanguage(language)
    language = tostring(language or LANGUAGE_AUTO)
    return language == "es" or language == "en"
end

function EZOA:Initialize()
    local world = GetWorldName()
    local defaults = {
        general = {
            language = LANGUAGE_AUTO,
            debugMode = false,
        },
        automation = {
            sellOrnateAtMerchant = false,
            sellTreasuresAtMerchant = false,
            sellTrashAtMerchant = false,
            repairEquippedAtMerchant = false,
            repairEquippedAndInventoryAtMerchant = false,
            switchToGroupChat = false,
            previewDeconstructionAtStation = false,
            queueDeconstructionAtStation = false,
            deconstructIncludeInventory = true,
            deconstructIncludeBank = false,
            deconstructWeapons = true,
            deconstructArmor = true,
            deconstructJewelry = true,
            deconstructGlyphs = true,
            hideGroupNameplatesInGroup = false,
            hideGroupNameplatesInCombat = false,
        },
        nameplates = {
            groupMemberNameplatesManaged = false,
            groupMemberNameplatesOriginal = nil,
            groupMemberHealthbarsManaged = false,
            groupMemberHealthbarsOriginal = nil,
        },
    }

    self.sv = ZO_SavedVars:NewCharacterIdSettings("EZOAuto_Saved", 1, world, defaults)
    self.runtime = self.runtime or {}
    self.runtime.debugMode = self.sv and self.sv.general and self.sv.general.debugMode == true

    if EZOAuto_Lang and EZOAuto_Lang.Apply then
        EZOAuto_Lang.Apply(self.sv.general.language or LANGUAGE_AUTO)
    end

    if self.DebugLog then
        self.DebugLog(GetString(EZOA_DEBUG_SAVED_VARIABLES_LOADED))
    end

    if EZOAuto_Menu and EZOAuto_Menu.Init then
        EZOAuto_Menu.Init()
    end

    if EZOAuto_Merchant and EZOAuto_Merchant.Init then
        EZOAuto_Merchant.Init()
    end

    if EZOAuto_Chat and EZOAuto_Chat.Init then
        EZOAuto_Chat.Init()
    end

    if EZOAuto_Nameplates and EZOAuto_Nameplates.Init then
        EZOAuto_Nameplates.Init()
    end

    if EZOAuto_Deconstruction and EZOAuto_Deconstruction.Init then
        EZOAuto_Deconstruction.Init()
    end

    Print(GetString(EZOA_MSG_INIT))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EZOAuto:Initialize()
end)
