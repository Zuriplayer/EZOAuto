-- Automatizacion prudente del Activity Finder.
EZOAuto_ActivityFinder = EZOAuto_ActivityFinder or {}
local FINDER = EZOAuto_ActivityFinder

local EVENT_NAMESPACE = "EZOAuto_ActivityFinder"
local SOUND_LOOP_NAMESPACE = EVENT_NAMESPACE .. "_SoundLoop"
local ACCEPT_DELAY_MS = 500
local DEFAULT_SOUND_REPEAT_SECONDS = 2

local activityToSettingKey = {}
local lastAcceptAt = 0

local function DebugLog(message)
    if EZOAuto and EZOAuto.DebugLog then
        EZOAuto.DebugLog(message)
    end
end

local function GetAutomation()
    return EZOAuto and EZOAuto.sv and EZOAuto.sv.automation
end

local function AddActivity(activityType, settingKey)
    if activityType ~= nil then
        activityToSettingKey[activityType] = settingKey
    end
end

local function BuildActivityMap()
    activityToSettingKey = {}

    AddActivity(LFG_ACTIVITY_DUNGEON, "autoAcceptDungeonFinder")
    AddActivity(LFG_ACTIVITY_MASTER_DUNGEON, "autoAcceptVeteranDungeonFinder")
    AddActivity(LFG_ACTIVITY_TRIAL, "autoAcceptTrialFinder")
    AddActivity(LFG_ACTIVITY_ARENA, "autoAcceptArenaFinder")
    AddActivity(LFG_ACTIVITY_ENDLESS_DUNGEON, "autoAcceptEndlessArchiveFinder")
    AddActivity(LFG_ACTIVITY_HOME_SHOW, "autoAcceptHomeToursFinder")
    AddActivity(LFG_ACTIVITY_EXPLORATION, "autoAcceptExplorationFinder")
    AddActivity(LFG_ACTIVITY_BATTLE_GROUND_CHAMPION, "autoAcceptBattlegroundFinder")
    AddActivity(LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION, "autoAcceptBattlegroundFinder")
    AddActivity(LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL, "autoAcceptBattlegroundFinder")
    AddActivity(LFG_ACTIVITY_TRIBUTE_CASUAL, "autoAcceptTributeCasualFinder")
    AddActivity(LFG_ACTIVITY_TRIBUTE_COMPETITIVE, "autoAcceptTributeCompetitiveFinder")
end

local function IsApiReady()
    return EVENT_ACTIVITY_FINDER_STATUS_UPDATE ~= nil
        and ACTIVITY_FINDER_STATUS_READY_CHECK ~= nil
        and type(GetLFGReadyCheckActivityType) == "function"
        and type(AcceptLFGReadyCheckNotification) == "function"
end

local function IsSoundAlertEnabled()
    local automation = GetAutomation()
    return automation and automation.activityFinderSoundAlert == true
end

local function GetSoundRepeatMs()
    local automation = GetAutomation()
    local seconds = automation and tonumber(automation.activityFinderSoundRepeatSeconds) or DEFAULT_SOUND_REPEAT_SECONDS
    seconds = zo_max(2, zo_min(15, seconds or DEFAULT_SOUND_REPEAT_SECONDS))
    return seconds * 1000
end

local function GetReadyCheckSound()
    if SOUNDS then
        return SOUNDS.LFG_SEARCH_FINISHED or SOUNDS.LFG_READY_CHECK
    end
    return nil
end

local function IsReadyCheckPending()
    if type(GetActivityFinderStatus) == "function" and GetActivityFinderStatus() ~= ACTIVITY_FINDER_STATUS_READY_CHECK then
        return false
    end
    if type(HasAcceptedLFGReadyCheck) == "function" and HasAcceptedLFGReadyCheck() then
        return false
    end
    if type(HasLFGReadyCheckNotification) == "function" and not HasLFGReadyCheckNotification() then
        return false
    end
    return true
end

local function StopSoundLoop()
    EVENT_MANAGER:UnregisterForUpdate(SOUND_LOOP_NAMESPACE)
end

local function PlayReadyCheckSound()
    if not IsReadyCheckPending() then
        StopSoundLoop()
        return
    end

    local sound = GetReadyCheckSound()
    if sound and type(PlaySound) == "function" then
        PlaySound(sound)
    end
end

local function StartSoundLoop()
    StopSoundLoop()
    if not IsSoundAlertEnabled() then return end
    if type(PlaySound) ~= "function" or not GetReadyCheckSound() then
        DebugLog("Activity Finder sound alert skipped: no ready-check sound is available.")
        return
    end

    EVENT_MANAGER:RegisterForUpdate(SOUND_LOOP_NAMESPACE, GetSoundRepeatMs(), PlayReadyCheckSound)
end

local function IsAnyAutoAcceptActivityEnabled()
    local automation = GetAutomation()
    if not automation then return false end

    for _, settingKey in pairs(activityToSettingKey) do
        if automation[settingKey] == true then
            return true
        end
    end

    return false
end

local function IsAnyFeatureEnabled()
    return IsAnyAutoAcceptActivityEnabled() or IsSoundAlertEnabled()
end

local function CanAcceptCurrentNotification(activityType)
    local automation = GetAutomation()
    if not automation then return false end

    local settingKey = activityToSettingKey[activityType]
    return settingKey ~= nil and automation[settingKey] == true
end

local function AcceptCurrentReadyCheck(activityType)
    if not CanAcceptCurrentNotification(activityType) then return end
    if type(HasLFGReadyCheckNotification) == "function" and not HasLFGReadyCheckNotification() then
        DebugLog("Activity Finder auto accept skipped: no LFG ready check notification.")
        return
    end

    local now = type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
    if now > 0 and lastAcceptAt > 0 and now - lastAcceptAt < 1000 then
        return
    end
    lastAcceptAt = now

    local ok = pcall(AcceptLFGReadyCheckNotification)
    if ok then
        DebugLog("Activity Finder ready check accepted: activityType=" .. tostring(activityType) .. ".")
    else
        DebugLog("Activity Finder auto accept failed: AcceptLFGReadyCheckNotification raised an error.")
    end
end

local function OnActivityFinderStatusUpdate(_, status)
    if status ~= ACTIVITY_FINDER_STATUS_READY_CHECK then
        StopSoundLoop()
        return
    end

    StartSoundLoop()

    local ok, activityType = pcall(GetLFGReadyCheckActivityType)
    if not ok then
        DebugLog("Activity Finder auto accept skipped: activity type unavailable.")
        return
    end

    if not CanAcceptCurrentNotification(activityType) then
        DebugLog("Activity Finder ready check ignored: activityType=" .. tostring(activityType) .. ".")
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            AcceptCurrentReadyCheck(activityType)
        end, ACCEPT_DELAY_MS)
    else
        AcceptCurrentReadyCheck(activityType)
    end
end

function FINDER.RefreshRegistration()
    StopSoundLoop()

    if EVENT_ACTIVITY_FINDER_STATUS_UPDATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
    end

    if not IsApiReady() then
        DebugLog("Activity Finder auto accept disabled: required API is missing.")
        return
    end

    if IsAnyFeatureEnabled() then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusUpdate)
    end
end

function FINDER.Init()
    BuildActivityMap()
    FINDER.RefreshRegistration()
end
