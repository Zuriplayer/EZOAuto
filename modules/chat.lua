-- Pequenas tareas automaticas del chat.
EZOAuto_Chat = EZOAuto_Chat or {}

local CHAT = EZOAuto_Chat
local EZOA = EZOAuto

local EVENT_PREFIX = "EZOAuto_Chat"

local function DebugLog(message)
    if EZOA and type(EZOA.DebugLog) == "function" then
        EZOA.DebugLog(message)
    end
end

local function IsEnabled()
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    return automation and automation.switchToGroupChat == true
end

local function IsGrouped()
    if type(GetGroupSize) == "function" then
        return GetGroupSize() >= 2
    end
    return false
end

local function SwitchToGroupChat(reason)
    if not IsEnabled() then return end
    if CHAT_CHANNEL_PARTY == nil then
        DebugLog("Group chat switch skipped: CHAT_CHANNEL_PARTY is missing.")
        return
    end
    if not IsGrouped() then
        return
    end

    local chatSystem = _G.CHAT_SYSTEM
    if not (chatSystem and type(chatSystem.SetChannel) == "function") then
        DebugLog("Group chat switch skipped: CHAT_SYSTEM:SetChannel is missing.")
        return
    end

    local ok, errorMessage = pcall(function()
        chatSystem:SetChannel(CHAT_CHANNEL_PARTY)
    end)
    if ok then
        DebugLog("Group chat channel selected: " .. tostring(reason) .. ".")
    else
        DebugLog("Group chat switch failed: " .. tostring(errorMessage) .. ".")
    end
end

local function SwitchIfJustGrouped(reason)
    zo_callLater(function()
        local grouped = IsGrouped()
        if grouped and CHAT.wasGrouped ~= true then
            SwitchToGroupChat(reason)
        end
        CHAT.wasGrouped = grouped
    end, 500)
end

local function IsLocalPlayerJoin(characterName, isLocalPlayer)
    if isLocalPlayer == true then return true end
    if type(GetRawUnitName) == "function" and characterName ~= nil then
        return GetRawUnitName("player") == characterName
    end
    return false
end

local function OnGroupMemberJoined(_, characterName, _, isLocalPlayer)
    if IsLocalPlayerJoin(characterName, isLocalPlayer) then
        SwitchIfJustGrouped("player joined group")
    else
        SwitchIfJustGrouped("group formed")
    end
end

local function OnGroupUpdate()
    SwitchIfJustGrouped("group update")
end

function CHAT.Init()
    CHAT.wasGrouped = IsGrouped()
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_UPDATE, OnGroupUpdate)
    zo_callLater(function()
        if IsGrouped() then
            SwitchToGroupChat("already grouped")
        end
        CHAT.wasGrouped = IsGrouped()
    end, 1000)
end
