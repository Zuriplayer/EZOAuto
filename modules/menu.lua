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

local function SetActivityFinderOption(key, value)
    EZOAuto.sv.automation[key] = value == true
    if EZOAuto_ActivityFinder and EZOAuto_ActivityFinder.RefreshRegistration then
        EZOAuto_ActivityFinder.RefreshRegistration()
    end
end

local function SetActivityFinderNumberOption(key, value)
    EZOAuto.sv.automation[key] = tonumber(value) or 0
    if EZOAuto_ActivityFinder and EZOAuto_ActivityFinder.RefreshRegistration then
        EZOAuto_ActivityFinder.RefreshRegistration()
    end
end

local function SetPetOption(key, value)
    EZOAuto.sv.automation[key] = value == true
    if EZOAuto_Pets and EZOAuto_Pets.RefreshRegistration then
        EZOAuto_Pets.RefreshRegistration()
    end
end

local function SetBookOption(key, value)
    EZOAuto.sv.automation[key] = value == true
    if EZOAuto_Books and EZOAuto_Books.RefreshRegistration then
        EZOAuto_Books.RefreshRegistration()
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
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_CHAT),
            tooltip = GetString(EZOA_OPTION_GROUP_CHAT_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.switchToGroupChat == true end,
            setFunc = function(value) EZOA.sv.automation.switchToGroupChat = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AUTO_DISMISS_PET_TRIAL),
            tooltip = GetString(EZOA_OPTION_AUTO_DISMISS_PET_TRIAL_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoDismissPetInTrial == true end,
            setFunc = function(value) SetPetOption("autoDismissPetInTrial", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AUTO_CLOSE_BOOKS),
            tooltip = GetString(EZOA_OPTION_AUTO_CLOSE_BOOKS_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoCloseBooks == true end,
            setFunc = function(value) SetBookOption("autoCloseBooks", value) end,
            default = false,
            width   = "full",
        },
        { type = "header", name = GetString(EZOA_OPTION_ACTIVITY_FINDER) },
        { type = "description", text = GetString(EZOA_OPTION_ACTIVITY_FINDER_NOTE), width = "full" },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_SOUND_ALERT),
            tooltip = GetString(EZOA_OPTION_AF_SOUND_ALERT_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.activityFinderSoundAlert == true end,
            setFunc = function(value) SetActivityFinderOption("activityFinderSoundAlert", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "slider",
            name    = GetString(EZOA_OPTION_AF_SOUND_REPEAT_SECONDS),
            tooltip = GetString(EZOA_OPTION_AF_SOUND_REPEAT_SECONDS_TOOLTIP),
            min     = 2,
            max     = 15,
            step    = 1,
            getFunc = function() return EZOA.sv.automation.activityFinderSoundRepeatSeconds or 2 end,
            setFunc = function(value) SetActivityFinderNumberOption("activityFinderSoundRepeatSeconds", value) end,
            disabled = function() return EZOA.sv.automation.activityFinderSoundAlert ~= true end,
            default = 2,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_DUNGEON),
            tooltip = GetString(EZOA_OPTION_AF_DUNGEON_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptDungeonFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptDungeonFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_VETERAN_DUNGEON),
            tooltip = GetString(EZOA_OPTION_AF_VETERAN_DUNGEON_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptVeteranDungeonFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptVeteranDungeonFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_BATTLEGROUND),
            tooltip = GetString(EZOA_OPTION_AF_BATTLEGROUND_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptBattlegroundFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptBattlegroundFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_TRIBUTE_CASUAL),
            tooltip = GetString(EZOA_OPTION_AF_TRIBUTE_CASUAL_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptTributeCasualFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptTributeCasualFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_TRIBUTE_COMPETITIVE),
            tooltip = GetString(EZOA_OPTION_AF_TRIBUTE_COMPETITIVE_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptTributeCompetitiveFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptTributeCompetitiveFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_TRIAL),
            tooltip = GetString(EZOA_OPTION_AF_TRIAL_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptTrialFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptTrialFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_ARENA),
            tooltip = GetString(EZOA_OPTION_AF_ARENA_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptArenaFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptArenaFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_ENDLESS_ARCHIVE),
            tooltip = GetString(EZOA_OPTION_AF_ENDLESS_ARCHIVE_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptEndlessArchiveFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptEndlessArchiveFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_HOME_TOURS),
            tooltip = GetString(EZOA_OPTION_AF_HOME_TOURS_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptHomeToursFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptHomeToursFinder", value) end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_AF_EXPLORATION),
            tooltip = GetString(EZOA_OPTION_AF_EXPLORATION_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.autoAcceptExplorationFinder == true end,
            setFunc = function(value) SetActivityFinderOption("autoAcceptExplorationFinder", value) end,
            default = false,
            width   = "full",
        },
        { type = "header", name = GetString(EZOA_OPTION_GROUP_VISIBILITY) },
        { type = "description", text = GetString(EZOA_OPTION_GROUP_VISIBILITY_NOTE), width = "full" },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_HIDE_GROUP_NAMES_GROUPED),
            tooltip = GetString(EZOA_OPTION_HIDE_GROUP_NAMES_GROUPED_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.hideGroupNameplatesInGroup == true end,
            setFunc = function(value)
                value = value == true
                EZOA.sv.automation.hideGroupNameplatesInGroup = value
                if value then
                    EZOA.sv.automation.hideGroupNameplatesInCombat = false
                end
                if EZOAuto_Nameplates and EZOAuto_Nameplates.Refresh then
                    EZOAuto_Nameplates.Refresh("settings changed")
                end
            end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_HIDE_GROUP_NAMES_COMBAT),
            tooltip = GetString(EZOA_OPTION_HIDE_GROUP_NAMES_COMBAT_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.hideGroupNameplatesInCombat == true end,
            setFunc = function(value)
                EZOA.sv.automation.hideGroupNameplatesInCombat = value == true
                if EZOAuto_Nameplates and EZOAuto_Nameplates.Refresh then
                    EZOAuto_Nameplates.Refresh("settings changed")
                end
            end,
            disabled = function() return EZOA.sv.automation.hideGroupNameplatesInGroup == true end,
            default = false,
            width   = "full",
        },
        { type = "header", name = GetString(EZOA_OPTION_DECONSTRUCTION) },
        { type = "description", text = GetString(EZOA_OPTION_DECONSTRUCTION_NOTE), width = "full" },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_PREVIEW),
            tooltip = GetString(EZOA_OPTION_DECON_PREVIEW_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.previewDeconstructionAtStation == true end,
            setFunc = function(value) EZOA.sv.automation.previewDeconstructionAtStation = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_QUEUE),
            tooltip = GetString(EZOA_OPTION_DECON_QUEUE_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.queueDeconstructionAtStation == true end,
            setFunc = function(value) EZOA.sv.automation.queueDeconstructionAtStation = value == true end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_INCLUDE_INVENTORY),
            tooltip = GetString(EZOA_OPTION_DECON_INCLUDE_INVENTORY_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructIncludeInventory == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructIncludeInventory = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_INCLUDE_BANK),
            tooltip = GetString(EZOA_OPTION_DECON_INCLUDE_BANK_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructIncludeBank == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructIncludeBank = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_WEAPONS),
            tooltip = GetString(EZOA_OPTION_DECON_WEAPONS_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructWeapons == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructWeapons = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_ARMOR),
            tooltip = GetString(EZOA_OPTION_DECON_ARMOR_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructArmor == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructArmor = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_JEWELRY),
            tooltip = GetString(EZOA_OPTION_DECON_JEWELRY_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructJewelry == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructJewelry = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_DECON_GLYPHS),
            tooltip = GetString(EZOA_OPTION_DECON_GLYPHS_TOOLTIP),
            getFunc = function() return EZOA.sv.automation.deconstructGlyphs == true end,
            setFunc = function(value) EZOA.sv.automation.deconstructGlyphs = value == true end,
            disabled = function()
                return EZOA.sv.automation.previewDeconstructionAtStation ~= true
                    and EZOA.sv.automation.queueDeconstructionAtStation ~= true
            end,
            default = true,
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
