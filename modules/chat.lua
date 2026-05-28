-- Pequenas tareas automaticas del chat.
EZOAuto_Chat = EZOAuto_Chat or {}

local CHAT = EZOAuto_Chat
local EZOA = EZOAuto

local EVENT_PREFIX = "EZOAuto_Chat"
local SWITCH_RETRY_DELAY_MS = 300
local MAX_SWITCH_RETRIES = 10

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
        return false
    end
    if not IsGrouped() then
        return false
    end

    local chatSystem = _G.CHAT_SYSTEM
    if not (chatSystem and type(chatSystem.SetChannel) == "function") then
        DebugLog("Group chat switch skipped: CHAT_SYSTEM:SetChannel is missing.")
        return false
    end

    local ok, errorMessage = pcall(function()
        chatSystem:SetChannel(CHAT_CHANNEL_PARTY)
    end)
    if ok then
        DebugLog("Group chat channel selected: " .. tostring(reason) .. ".")
        return true
    else
        DebugLog("Group chat switch failed: " .. tostring(errorMessage) .. ".")
        return false
    end
end

local function SwitchIfJustGrouped(reason, attempt)
    if not IsEnabled() then return end
    attempt = tonumber(attempt) or 1
    zo_callLater(function()
        local grouped = IsGrouped()
        if grouped and CHAT.wasGrouped ~= true then
            if not SwitchToGroupChat(reason) and attempt < MAX_SWITCH_RETRIES then
                SwitchIfJustGrouped(reason, attempt + 1)
                return
            end
        elseif not grouped and attempt < MAX_SWITCH_RETRIES then
            SwitchIfJustGrouped(reason, attempt + 1)
            return
        end
        CHAT.wasGrouped = grouped
    end, SWITCH_RETRY_DELAY_MS)
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

local function OnGroupMemberLeft()
    zo_callLater(function()
        CHAT.wasGrouped = IsGrouped()
    end, SWITCH_RETRY_DELAY_MS)
end

function CHAT.Init()
    CHAT.wasGrouped = IsGrouped()
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_UPDATE, OnGroupUpdate)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    zo_callLater(function()
        if IsGrouped() then
            SwitchToGroupChat("already grouped")
        end
        CHAT.wasGrouped = IsGrouped()
    end, 1000)
end
