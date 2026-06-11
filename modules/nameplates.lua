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

local function IsPvEWorld()
    local checked = false

    if type(IsPlayerInAvAWorld) == "function" then
        checked = true
        local ok, isAvA = pcall(IsPlayerInAvAWorld)
        if ok and isAvA == true then return false end
    end

    if type(IsActiveWorldBattleground) == "function" then
        checked = true
        local ok, isBattleground = pcall(IsActiveWorldBattleground)
        if ok and isBattleground == true then return false end
    end

    return checked
end

local function ShouldHideGroupIndicators()
    local automation = GetAutomation()
    if not automation or not IsGrouped() then return false end
    if not IsPvEWorld() then return false end
    if automation.hideGroupNameplatesInGroup == true then return true end
    return automation.hideGroupNameplatesInCombat == true and IsInCombat()
end

function NAMEPLATES.NormalizeSettings()
    local automation = GetAutomation()
    if not automation then return end
    if automation.hideGroupNameplatesInGroup == true then
        automation.hideGroupNameplatesInCombat = false
    end
end

local function GetCurrentSetting(settingKey)
    return GetSetting(SETTING_TYPE_NAMEPLATES, settingKey)
end

local function SetNameplateSetting(settingKey, value)
    SetSetting(SETTING_TYPE_NAMEPLATES, settingKey, tostring(value))
end

local function HideManagedSetting(state, managedKey, originalKey, settingKey)
    if settingKey == nil then return false end

    local changed = false
    if state[managedKey] ~= true then
        state[originalKey] = GetCurrentSetting(settingKey)
        state[managedKey] = true
        changed = true
    end

    SetNameplateSetting(settingKey, NAMEPLATE_CHOICE_NEVER)
    return changed
end

local function RestoreManagedSetting(state, managedKey, originalKey, settingKey)
    if settingKey == nil or state[managedKey] ~= true then return false end

    local original = state[originalKey]
    if original ~= nil then
        SetNameplateSetting(settingKey, original)
    end

    state[managedKey] = false
    state[originalKey] = nil
    return true
end

local function ApplyManagedPair(reason, shouldHide, nameplateType, healthbarType, nameManagedKey, nameOriginalKey, healthManagedKey, healthOriginalKey, label)
    local state = GetState()
    if not state then return end
    local changed = false

    if shouldHide then
        changed = HideManagedSetting(state, nameManagedKey, nameOriginalKey, nameplateType) or changed
        changed = HideManagedSetting(state, healthManagedKey, healthOriginalKey, healthbarType) or changed
        if changed then
            DebugLog(label .. " hidden: " .. tostring(reason) .. ".")
        end
        return
    end

    changed = RestoreManagedSetting(state, nameManagedKey, nameOriginalKey, nameplateType) or changed
    changed = RestoreManagedSetting(state, healthManagedKey, healthOriginalKey, healthbarType) or changed
    if changed then
        DebugLog(label .. " restored: " .. tostring(reason) .. ".")
    end
end

local function ApplyGroupIndicators(reason)
    ApplyManagedPair(reason, ShouldHideGroupIndicators(),
        NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES,
        IsHealthbarApiReady() and NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS or nil,
        "groupMemberNameplatesManaged",
        "groupMemberNameplatesOriginal",
        "groupMemberHealthbarsManaged",
        "groupMemberHealthbarsOriginal",
        "Group nameplates and health bars")
end

local function RestoreLegacyPvPIndicators(reason)
    local state = GetState()
    if not state then return end
    local changed = false

    changed = RestoreManagedSetting(state,
        "pvpFriendlyPlayerNameplatesManaged",
        "pvpFriendlyPlayerNameplatesOriginal",
        NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES) or changed
    changed = RestoreManagedSetting(state,
        "pvpFriendlyPlayerHealthbarsManaged",
        "pvpFriendlyPlayerHealthbarsOriginal",
        NAMEPLATE_TYPE_FRIENDLY_PLAYER_HEALTHBARS) or changed
    changed = RestoreManagedSetting(state,
        "pvpEnemyPlayerNameplatesManaged",
        "pvpEnemyPlayerNameplatesOriginal",
        NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES) or changed
    changed = RestoreManagedSetting(state,
        "pvpEnemyPlayerHealthbarsManaged",
        "pvpEnemyPlayerHealthbarsOriginal",
        NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS) or changed

    if changed then
        DebugLog("Legacy PvP nameplate settings restored: " .. tostring(reason) .. ".")
    end
end

function NAMEPLATES.Refresh(reason)
    if not IsApiReady() then
        DebugLog("Group nameplates skipped: nameplate setting API is missing.")
        return
    end

    NAMEPLATES.NormalizeSettings()
    ApplyGroupIndicators(reason)
    RestoreLegacyPvPIndicators(reason)
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
