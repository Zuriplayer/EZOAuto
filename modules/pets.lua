-- Automatizacion prudente para ocultar mascota cosmetica en trials.
EZOAuto_Pets = EZOAuto_Pets or {}
local PETS = EZOAuto_Pets

local EVENT_NAMESPACE = "EZOAuto_Pets"
local DISMISS_DELAY_MS = 2500

local TRIAL_ZONE_IDS = {
    [636] = true,  -- Hel Ra Citadel
    [638] = true,  -- Aetherian Archive
    [639] = true,  -- Sanctum Ophidia
    [725] = true,  -- Maw of Lorkhaj
    [975] = true,  -- Halls of Fabrication
    [1000] = true, -- Asylum Sanctorium
    [1051] = true, -- Cloudrest
    [1121] = true, -- Sunspire
    [1196] = true, -- Kyne's Aegis
    [1263] = true, -- Rockgrove
    [1344] = true, -- Dreadsail Reef
    [1427] = true, -- Sanity's Edge
    [1478] = true, -- Lucent Citadel
    [1548] = true, -- Ossein Cage
}

local lastDismissedZoneId = nil

local function DebugLog(message)
    if EZOAuto and EZOAuto.DebugLog then
        EZOAuto.DebugLog(message)
    end
end

local function IsEnabled()
    local automation = EZOAuto and EZOAuto.sv and EZOAuto.sv.automation
    return automation and automation.autoDismissPetInTrial == true
end

local function GetCurrentZoneId()
    if type(GetZoneId) ~= "function" or type(GetUnitZoneIndex) ~= "function" then return nil end

    local ok, zoneId = pcall(function()
        return GetZoneId(GetUnitZoneIndex("player"))
    end)
    if ok then return zoneId end
    return nil
end

local function IsInTrialZone(zoneId)
    return zoneId ~= nil and TRIAL_ZONE_IDS[zoneId] == true
end

local function DismissPetIfNeeded()
    if not IsEnabled() then return end
    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") then return end
    if type(GetActiveCollectibleByType) ~= "function"
        or type(UseCollectible) ~= "function"
        or COLLECTIBLE_CATEGORY_TYPE_VANITY_PET == nil then
        DebugLog("Auto-dismiss pet skipped: collectible API is missing.")
        return
    end

    local zoneId = GetCurrentZoneId()
    if not IsInTrialZone(zoneId) then
        lastDismissedZoneId = nil
        return
    end
    if lastDismissedZoneId == zoneId then return end

    local ok, collectibleId = pcall(GetActiveCollectibleByType, COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if not ok or not collectibleId or collectibleId == 0 then return end

    local used = pcall(UseCollectible, collectibleId)
    if used then
        lastDismissedZoneId = zoneId
        DebugLog("Vanity pet dismissed in trial zoneId=" .. tostring(zoneId) .. ".")
    else
        DebugLog("Auto-dismiss pet failed: UseCollectible raised an error.")
    end
end

local function OnPlayerActivated()
    if type(zo_callLater) == "function" then
        zo_callLater(DismissPetIfNeeded, DISMISS_DELAY_MS)
    else
        DismissPetIfNeeded()
    end
end

function PETS.RefreshRegistration()
    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    end

    if not IsEnabled() then return end
    if EVENT_PLAYER_ACTIVATED == nil then
        DebugLog("Auto-dismiss pet disabled: EVENT_PLAYER_ACTIVATED is missing.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

function PETS.Init()
    PETS.RefreshRegistration()
end
