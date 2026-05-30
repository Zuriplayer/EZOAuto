-- Ajustes flotantes del grupo. Solo tocamos opciones reales de ESO y las restauramos.
EZOAuto_Nameplates = EZOAuto_Nameplates or {}

local NAMEPLATES = EZOAuto_Nameplates
local EZOA = EZOAuto

local EVENT_PREFIX = "EZOAuto_Nameplates"
local REFRESH_DELAY_MS = 300

local function DebugLog(message)
    if EZOA and type(EZOA.DebugLog) == "function" then
        EZOA.DebugLog(message)
    end
end

local function GetAutomation()
    return EZOA and EZOA.sv and EZOA.sv.automation
end

local function GetState()
    if not (EZOA and EZOA.sv) then return nil end
    EZOA.sv.nameplates = EZOA.sv.nameplates or {}
    return EZOA.sv.nameplates
end

local function IsGrouped()
    if type(GetGroupSize) == "function" then
        return GetGroupSize() >= 2
    end
    return false
end

local function IsInCombat()
    if type(IsUnitInCombat) == "function" then
        return IsUnitInCombat("player") == true
    end
    if type(IsPlayerInCombat) == "function" then
        return IsPlayerInCombat() == true
    end
    return false
end

local function IsApiReady()
    return type(GetSetting) == "function"
        and type(SetSetting) == "function"
        and SETTING_TYPE_NAMEPLATES ~= nil
        and NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES ~= nil
        and NAMEPLATE_CHOICE_NEVER ~= nil
end

local function IsHealthbarApiReady()
    return NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS ~= nil
end

local function ShouldHide()
    local automation = GetAutomation()
    if not automation or not IsGrouped() then return false end
    if automation.hideGroupNameplatesInGroup == true then return true end
    return automation.hideGroupNameplatesInCombat == true and IsInCombat()
end

local function GetCurrentGroupNameplateSetting()
    return GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES)
end

local function GetCurrentGroupHealthbarSetting()
    return GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
end

local function SetGroupNameplateSetting(value)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(value))
end

local function SetGroupHealthbarSetting(value)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(value))
end

local function HideGroupIndicators(reason)
    local state = GetState()
    if not state then return end
    local changed = false

    if state.groupMemberNameplatesManaged ~= true then
        state.groupMemberNameplatesOriginal = GetCurrentGroupNameplateSetting()
        state.groupMemberNameplatesManaged = true
        changed = true
    end
    if IsHealthbarApiReady() and state.groupMemberHealthbarsManaged ~= true then
        state.groupMemberHealthbarsOriginal = GetCurrentGroupHealthbarSetting()
        state.groupMemberHealthbarsManaged = true
        changed = true
    end

    SetGroupNameplateSetting(NAMEPLATE_CHOICE_NEVER)
    if IsHealthbarApiReady() then
        SetGroupHealthbarSetting(NAMEPLATE_CHOICE_NEVER)
    end
    if changed then
        DebugLog("Group nameplates and health bars hidden: " .. tostring(reason) .. ".")
    end
end

local function RestoreGroupIndicators(reason)
    local state = GetState()
    if not state then return end
    local changed = false

    if state.groupMemberNameplatesManaged == true then
        local original = state.groupMemberNameplatesOriginal
        if original ~= nil then
            SetGroupNameplateSetting(original)
        end

        state.groupMemberNameplatesManaged = false
        state.groupMemberNameplatesOriginal = nil
        changed = true
    end

    if IsHealthbarApiReady() and state.groupMemberHealthbarsManaged == true then
        local original = state.groupMemberHealthbarsOriginal
        if original ~= nil then
            SetGroupHealthbarSetting(original)
        end

        state.groupMemberHealthbarsManaged = false
        state.groupMemberHealthbarsOriginal = nil
        changed = true
    end

    if changed then
        DebugLog("Group nameplates and health bars restored: " .. tostring(reason) .. ".")
    end
end

function NAMEPLATES.Refresh(reason)
    if not IsApiReady() then
        DebugLog("Group nameplates skipped: nameplate setting API is missing.")
        return
    end

    if ShouldHide() then
        HideGroupIndicators(reason)
    else
        RestoreGroupIndicators(reason)
    end
end

local function RefreshSoon(reason)
    zo_callLater(function()
        NAMEPLATES.Refresh(reason)
    end, REFRESH_DELAY_MS)
end

local function OnGroupChanged()
    RefreshSoon("group changed")
end

local function OnCombatStateChanged(_, inCombat)
    RefreshSoon(inCombat and "combat started" or "combat ended")
end

local function OnPlayerActivated()
    RefreshSoon("player activated")
end

function NAMEPLATES.Init()
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_UPDATE, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    RefreshSoon("addon loaded")
end
