-- Aceptacion opcional de invitaciones sociales de grupo.
EZOAuto_GroupInvites = EZOAuto_GroupInvites or {}

local INVITES = EZOAuto_GroupInvites
local EZOA = EZOAuto

local EVENT_NAMESPACE = "EZOAuto_GroupInvites"
local ACCEPT_DELAY_MS = 300

local pendingInviteGeneration = 0

local function DebugLog(message)
    if EZOA and type(EZOA.DebugLog) == "function" then
        EZOA.DebugLog(message)
    end
end

local function IsEnabled()
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    return automation and automation.autoAcceptGroupInvites == true
end

local function CancelPendingInvite()
    pendingInviteGeneration = pendingInviteGeneration + 1
end

local function NormalizeName(value)
    return tostring(value or "")
end

local function IsSamePendingInvite(inviterCharacterName, inviterDisplayName)
    if type(GetGroupInviteInfo) ~= "function" then return false end

    local ok, currentCharacterName, _, currentDisplayName = pcall(GetGroupInviteInfo)
    if not ok then return false end

    currentCharacterName = NormalizeName(currentCharacterName)
    currentDisplayName = NormalizeName(currentDisplayName)
    if currentCharacterName == "" and currentDisplayName == "" then return false end

    inviterCharacterName = NormalizeName(inviterCharacterName)
    inviterDisplayName = NormalizeName(inviterDisplayName)
    if inviterCharacterName ~= "" and currentCharacterName ~= inviterCharacterName then return false end
    if inviterDisplayName ~= "" and currentDisplayName ~= inviterDisplayName then return false end

    return true
end

local function AcceptPendingInvite(generation, inviterCharacterName, inviterDisplayName)
    if generation ~= pendingInviteGeneration or not IsEnabled() then return end
    if not IsSamePendingInvite(inviterCharacterName, inviterDisplayName) then
        DebugLog("Group invite auto accept skipped: the pending invitation changed or expired.")
        return
    end
    if type(AcceptGroupInvite) ~= "function" then
        DebugLog("Group invite auto accept disabled: AcceptGroupInvite is missing.")
        return
    end

    CancelPendingInvite()
    local ok, errorMessage = pcall(AcceptGroupInvite)
    if ok then
        DebugLog("Group invitation accepted from " .. NormalizeName(inviterDisplayName) .. ".")
    else
        DebugLog("Group invite auto accept failed: " .. tostring(errorMessage) .. ".")
    end
end

local function OnGroupInviteReceived(_, inviterCharacterName, inviterDisplayName)
    if not IsEnabled() then return end

    CancelPendingInvite()
    local generation = pendingInviteGeneration
    local function AcceptIfCurrent()
        AcceptPendingInvite(generation, inviterCharacterName, inviterDisplayName)
    end

    if type(zo_callLater) == "function" then
        zo_callLater(AcceptIfCurrent, ACCEPT_DELAY_MS)
    else
        AcceptIfCurrent()
    end
end

local function OnGroupInviteRemoved()
    CancelPendingInvite()
end

function INVITES.RefreshRegistration()
    CancelPendingInvite()

    if EVENT_GROUP_INVITE_RECEIVED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_INVITE_RECEIVED)
    end
    if EVENT_GROUP_INVITE_REMOVED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_INVITE_REMOVED)
    end

    if not IsEnabled() then return end
    if EVENT_GROUP_INVITE_RECEIVED == nil
        or EVENT_GROUP_INVITE_REMOVED == nil
        or type(GetGroupInviteInfo) ~= "function"
        or type(AcceptGroupInvite) ~= "function" then
        DebugLog("Group invite auto accept disabled: required API is missing.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_INVITE_RECEIVED, OnGroupInviteReceived)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_INVITE_REMOVED, OnGroupInviteRemoved)
end

function INVITES.Init()
    INVITES.RefreshRegistration()
end
