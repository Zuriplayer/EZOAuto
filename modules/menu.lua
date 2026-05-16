-- Panel de opciones de LibAddonMenu.
EZOAuto_Menu = EZOAuto_Menu or {}
local MENU = EZOAuto_Menu

local ADDON_NAME = "EZOAuto"
local DISPLAY_NAME = "E|cB040FFZ|rOAuto"

local function WarnForcedLanguage()
    if EZOAuto and type(EZOAuto.Print) == "function" then
        EZOAuto.Print(GetString(EZOA_MSG_LANGUAGE_FORCED_WARNING))
    end
end

local function GetOptions()
    local EZOA = EZOAuto
    local options = {
        { type = "header", name = GetString(EZOA_OPTION_GENERAL) },
        {
            type          = "dropdown",
            name          = GetString(EZOA_OPTION_LANGUAGE),
            choices       = { GetString(EZOA_OPTION_LANGUAGE_AUTO), "English", "Español" },
            choicesValues = { "auto", "en", "es" },
            getFunc       = function() return EZOA.sv.general.language or "auto" end,
            setFunc       = function(value)
                value = tostring(value or "auto")
                EZOA.sv.general.language = value
                if EZOAuto_Lang and EZOAuto_Lang.Apply then
                    EZOAuto_Lang.Apply(value)
                end
                if EZOA.IsForcedLanguage and EZOA.IsForcedLanguage(value) then
                    WarnForcedLanguage()
                end
            end,
            default = (EZOA.GetDefaultLanguage and EZOA.GetDefaultLanguage()) or "auto",
            width   = "half",
            tooltip = GetString(EZOA_OPTION_LANGUAGE_TOOLTIP),
        },

        { type = "header", name = GetString(EZOA_OPTION_AUTOMATION) },
        { type = "description", text = GetString(EZOA_OPTION_AUTOMATION_NOTE), width = "full" },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_SELL_ORNATE),
            tooltip = GetString(EZOA_OPTION_SELL_ORNATE_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.sellOrnateAtMerchant == true end,
            setFunc = function(value) EZOA.sv.automation.sellOrnateAtMerchant = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_SELL_TREASURES),
            tooltip = GetString(EZOA_OPTION_SELL_TREASURES_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.sellTreasuresAtMerchant == true end,
            setFunc = function(value) EZOA.sv.automation.sellTreasuresAtMerchant = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_SELL_TRASH),
            tooltip = GetString(EZOA_OPTION_SELL_TRASH_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.sellTrashAtMerchant == true end,
            setFunc = function(value) EZOA.sv.automation.sellTrashAtMerchant = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_REPAIR_EQUIPPED),
            tooltip = GetString(EZOA_OPTION_REPAIR_EQUIPPED_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.repairEquippedAtMerchant == true end,
            setFunc = function(value) EZOA.sv.automation.repairEquippedAtMerchant = value == true end,
            disabled = function() return EZOA.sv.automation.repairEquippedAndInventoryAtMerchant == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_REPAIR_EQUIPPED_AND_INVENTORY),
            tooltip = GetString(EZOA_OPTION_REPAIR_EQUIPPED_AND_INVENTORY_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.repairEquippedAndInventoryAtMerchant == true end,
            setFunc = function(value)
                value = value == true
                EZOA.sv.automation.repairEquippedAndInventoryAtMerchant = value
                if value then
                    EZOA.sv.automation.repairEquippedAtMerchant = false
                end
            end,
            default = false,
            width   = "full",
        },

        { type = "header", name = GetString(EZOA_OPTION_DEBUG) },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DEBUG_MODE),
            tooltip = GetString(EZOA_OPTION_DEBUG_MODE_TOOLTIP),
            getFunc = function()
                return EZOA.IsDebugModeEnabled and EZOA.IsDebugModeEnabled() == true
            end,
            setFunc = function(value)
                if EZOA.SetDebugModeEnabled then
                    EZOA.SetDebugModeEnabled(value)
                end
            end,
            default = false,
            width   = "full",
        },
    }

    return options
end

function MENU.Init()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type                = "panel",
        name                = ADDON_NAME,
        displayName         = DISPLAY_NAME,
        author              = "@Zuriplayer",
        version             = EZOAuto.ADDON_VERSION,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local panel = LAM:RegisterAddonPanel("EZOAuto_Panel", panelData)
    EZOAuto._lamPanel = panel
    _G.EZOAuto_Panel = panel

    LAM:RegisterOptionControls("EZOAuto_Panel", GetOptions())
end
