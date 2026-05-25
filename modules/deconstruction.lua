-- Primera fase de deconstruccion: mirar y contar, sin tocar objetos.
EZOAuto_Deconstruction = EZOAuto_Deconstruction or {}

local DECON = EZOAuto_Deconstruction
local EZOA = EZOAuto

local EVENT_PREFIX = "EZOAuto_Deconstruction"
local SCAN_DELAY_MS = 700
local CRAFTING_TYPE_RETRY_MS = 200
local MAX_CRAFTING_TYPE_RETRIES = 3
local hooksInstalled = {}
local InstallHooks
local ScheduleCurrentEnchantingPreview

local function DebugLog(message)
    if EZOA and type(EZOA.DebugLog) == "function" then
        EZOA.DebugLog(message)
    end
end

local function AddCount(container, key, amount)
    if not container or key == nil then return end
    key = tostring(key)
    container[key] = (container[key] or 0) + (amount or 1)
end

local function FormatCounts(container)
    local parts = {}
    if container then
        local keys = {}
        for key in pairs(container) do
            keys[#keys + 1] = key
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            local value = tonumber(container[key]) or 0
            if value > 0 then
                parts[#parts + 1] = key .. "=" .. tostring(value)
            end
        end
    end
    if #parts == 0 then return "none" end
    return table.concat(parts, ", ")
end

local function GetAutomation()
    return EZOA and EZOA.sv and EZOA.sv.automation
end

local function IsPreviewEnabled()
    local automation = GetAutomation()
    return automation and automation.previewDeconstructionAtStation == true
end

local function IsUniversalDeconstructor(craftingMode)
    if type(ZO_Smithing_IsUniversalDeconstructionCraftingMode) ~= "function" then
        return false
    end

    local ok, isUniversal = pcall(ZO_Smithing_IsUniversalDeconstructionCraftingMode, craftingMode)
    return ok and isUniversal == true
end

local function GetStationName(craftingType)
    if CRAFTING_TYPE_BLACKSMITHING ~= nil and craftingType == CRAFTING_TYPE_BLACKSMITHING then
        return "blacksmithing"
    end
    if CRAFTING_TYPE_CLOTHIER ~= nil and craftingType == CRAFTING_TYPE_CLOTHIER then
        return "clothing"
    end
    if CRAFTING_TYPE_WOODWORKING ~= nil and craftingType == CRAFTING_TYPE_WOODWORKING then
        return "woodworking"
    end
    if CRAFTING_TYPE_JEWELRYCRAFTING ~= nil and craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        return "jewelry crafting"
    end
    if CRAFTING_TYPE_ENCHANTING ~= nil and craftingType == CRAFTING_TYPE_ENCHANTING then
        return "enchanting"
    end
    return "crafting type " .. tostring(craftingType)
end

local function IsKnownDeconstructionCraft(craftingType)
    return (CRAFTING_TYPE_BLACKSMITHING ~= nil and craftingType == CRAFTING_TYPE_BLACKSMITHING)
        or (CRAFTING_TYPE_CLOTHIER ~= nil and craftingType == CRAFTING_TYPE_CLOTHIER)
        or (CRAFTING_TYPE_WOODWORKING ~= nil and craftingType == CRAFTING_TYPE_WOODWORKING)
        or (CRAFTING_TYPE_JEWELRYCRAFTING ~= nil and craftingType == CRAFTING_TYPE_JEWELRYCRAFTING)
        or (CRAFTING_TYPE_ENCHANTING ~= nil and craftingType == CRAFTING_TYPE_ENCHANTING)
end

local function GetCurrentCraftingType()
    if IsKnownDeconstructionCraft(DECON.currentCraftingType) then
        return DECON.currentCraftingType
    end

    if type(GetCraftingInteractionType) == "function" then
        local ok, craftingType = pcall(GetCraftingInteractionType)
        if ok and IsKnownDeconstructionCraft(craftingType) then
            DECON.currentCraftingType = craftingType
            return craftingType
        end
    end

    return nil
end

local function IsOrnateTrait(trait)
    if trait == nil then return false end
    return (ITEM_TRAIT_TYPE_ARMOR_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE)
        or (ITEM_TRAIT_TYPE_WEAPON_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE)
        or (ITEM_TRAIT_TYPE_JEWELRY_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE)
end

local function GetItemTypeSafe(bagId, slotIndex)
    if type(GetItemType) == "function" then
        return GetItemType(bagId, slotIndex)
    end
    if type(GetItemLink) == "function" and type(GetItemLinkItemType) == "function" then
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        if type(link) == "string" and link ~= "" then
            return GetItemLinkItemType(link)
        end
    end
    return nil
end

local function GetEquipmentTypeSafe(bagId, slotIndex)
    if type(GetItemEquipmentType) == "function" then
        return GetItemEquipmentType(bagId, slotIndex)
    end
    if type(GetItemLink) == "function" and type(GetItemLinkEquipType) == "function" then
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        if type(link) == "string" and link ~= "" then
            return GetItemLinkEquipType(link)
        end
    end
    return nil
end

local function IsStolen(bagId, slotIndex)
    if type(IsItemStolen) == "function" then
        return IsItemStolen(bagId, slotIndex) == true
    end
    if type(GetItemLink) == "function" and type(IsItemLinkStolen) == "function" then
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        return IsItemLinkStolen(link) == true
    end
    return false
end

local function GetProtectionReason(bagId, slotIndex)
    if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) then
        return "player locked"
    end
    if type(IsItemProtected) == "function" and IsItemProtected(bagId, slotIndex) then
        return "protected"
    end
    if type(IsItemInArmory) == "function" and IsItemInArmory(bagId, slotIndex) then
        return "armory"
    end
    if type(GetItemActorCategory) == "function"
        and GAMEPLAY_ACTOR_CATEGORY_COMPANION ~= nil
        and GetItemActorCategory(bagId, slotIndex) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then
        return "companion"
    end
    return nil
end

local function IsPlayerCrafted(bagId, slotIndex)
    if type(GetItemLink) == "function" and type(IsItemLinkCrafted) == "function" then
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        if type(link) == "string" and link ~= "" then
            return IsItemLinkCrafted(link) == true, nil
        end
    end

    if type(GetItemCreatorName) == "function" then
        local creatorName = GetItemCreatorName(bagId, slotIndex)
        return type(creatorName) == "string" and creatorName ~= "", nil
    end

    return nil, "crafted api missing"
end

local function IsGlyph(itemType)
    return (ITEMTYPE_GLYPH_ARMOR ~= nil and itemType == ITEMTYPE_GLYPH_ARMOR)
        or (ITEMTYPE_GLYPH_WEAPON ~= nil and itemType == ITEMTYPE_GLYPH_WEAPON)
        or (ITEMTYPE_GLYPH_JEWELRY ~= nil and itemType == ITEMTYPE_GLYPH_JEWELRY)
end

local function IsJewelry(bagId, slotIndex)
    local equipmentType = GetEquipmentTypeSafe(bagId, slotIndex)
    return (EQUIP_TYPE_RING ~= nil and equipmentType == EQUIP_TYPE_RING)
        or (EQUIP_TYPE_NECK ~= nil and equipmentType == EQUIP_TYPE_NECK)
end

local function GetCategory(bagId, slotIndex)
    local itemType = GetItemTypeSafe(bagId, slotIndex)
    if itemType == nil then return nil, "type api missing" end
    if IsGlyph(itemType) then return "glyphs", nil end
    if ITEMTYPE_WEAPON ~= nil and itemType == ITEMTYPE_WEAPON then return "weapons", nil end
    if ITEMTYPE_ARMOR ~= nil and itemType == ITEMTYPE_ARMOR then
        if IsJewelry(bagId, slotIndex) then
            return "jewelry", nil
        end
        return "armor", nil
    end
    return nil, "not selected type"
end

local function IsCategoryEnabled(category)
    local automation = GetAutomation()
    if not automation then return false end
    if category == "weapons" then return automation.deconstructWeapons == true end
    if category == "armor" then return automation.deconstructArmor == true end
    if category == "jewelry" then return automation.deconstructJewelry == true end
    if category == "glyphs" then return automation.deconstructGlyphs == true end
    return false
end

local function IsDeconstructable(bagId, slotIndex, craftingTypes)
    if type(CanItemBeDeconstructed) ~= "function" then
        return nil, "deconstruct api missing"
    end

    if craftingTypes then
        for _, craftingType in ipairs(craftingTypes) do
            local ok, canDeconstruct = pcall(CanItemBeDeconstructed, bagId, slotIndex, craftingType)
            if ok and canDeconstruct == true then
                return true, nil
            end
        end
        return false, "not deconstructable"
    end

    for craftingType = 1, 7 do
        local ok, canDeconstruct = pcall(CanItemBeDeconstructed, bagId, slotIndex, craftingType)
        if ok and canDeconstruct == true then
            return true, nil
        end
    end
    return false, "not deconstructable"
end

local function GetBagLabel(bagId)
    if bagId == BAG_BACKPACK then return "inventory" end
    if bagId == BAG_BANK then return "bank" end
    if BAG_SUBSCRIBER_BANK ~= nil and bagId == BAG_SUBSCRIBER_BANK then return "subscriber bank" end
    return tostring(bagId)
end

local function AddBag(bags, seen, bagId)
    if bagId == nil or seen[bagId] then return end
    seen[bagId] = true
    bags[#bags + 1] = bagId
end

local function BuildBagList()
    local automation = GetAutomation()
    local bags = {}
    local seen = {}

    if automation and automation.deconstructIncludeInventory == true then
        AddBag(bags, seen, BAG_BACKPACK)
    end
    if automation and automation.deconstructIncludeBank == true then
        AddBag(bags, seen, BAG_BANK)
        AddBag(bags, seen, BAG_SUBSCRIBER_BANK)
    end

    return bags
end

local function NewStats(station, craftingTypes)
    return {
        station = station,
        craftingTypes = craftingTypes,
        scanned = 0,
        eligible = 0,
        eligibleByCategory = {},
        eligibleByBag = {},
        skipped = {},
    }
end

local function AddCandidateIfSafe(bagId, slotIndex, stats)
    if type(HasItemInSlot) == "function" and not HasItemInSlot(bagId, slotIndex) then
        return
    end

    stats.scanned = stats.scanned + 1

    local protectionReason = GetProtectionReason(bagId, slotIndex)
    if protectionReason then
        AddCount(stats.skipped, protectionReason)
        return
    end

    if IsStolen(bagId, slotIndex) then
        AddCount(stats.skipped, "stolen")
        return
    end

    if type(GetItemQuality) ~= "function" then
        AddCount(stats.skipped, "quality api missing")
        return
    end
    local quality = GetItemQuality(bagId, slotIndex)
    if ITEM_QUALITY_LEGENDARY ~= nil and quality == ITEM_QUALITY_LEGENDARY then
        AddCount(stats.skipped, "legendary")
        return
    end

    local category, categoryReason = GetCategory(bagId, slotIndex)
    if not category then
        AddCount(stats.skipped, categoryReason)
        return
    end
    if not IsCategoryEnabled(category) then
        AddCount(stats.skipped, "category disabled")
        return
    end

    if category ~= "glyphs" then
        if type(GetItemTrait) ~= "function" then
            AddCount(stats.skipped, "trait api missing")
            return
        end
        if IsOrnateTrait(GetItemTrait(bagId, slotIndex)) then
            AddCount(stats.skipped, "ornate")
            return
        end
    end

    local crafted, craftedReason = IsPlayerCrafted(bagId, slotIndex)
    if craftedReason then
        AddCount(stats.skipped, craftedReason)
        return
    end
    if crafted == true then
        AddCount(stats.skipped, "player crafted")
        return
    end

    local canDeconstruct, deconstructReason = IsDeconstructable(bagId, slotIndex, stats.craftingTypes)
    if canDeconstruct ~= true then
        AddCount(stats.skipped, deconstructReason)
        return
    end

    stats.eligible = stats.eligible + 1
    AddCount(stats.eligibleByCategory, category)
    AddCount(stats.eligibleByBag, GetBagLabel(bagId))
end

local function ScanBag(bagId, stats)
    if bagId == nil then return end

    if type(ZO_IterateBagSlots) == "function" then
        for slotIndex in ZO_IterateBagSlots(bagId) do
            AddCandidateIfSafe(bagId, slotIndex, stats)
        end
        return
    end

    if type(GetBagSize) ~= "function" then
        AddCount(stats.skipped, "bag api missing")
        return
    end

    local bagSize = tonumber(GetBagSize(bagId)) or 0
    for slotIndex = 0, bagSize - 1 do
        AddCandidateIfSafe(bagId, slotIndex, stats)
    end
end

local function DebugPreviewSummary(stats)
    if not stats then return end
    DebugLog("Deconstruction preview: station=" .. tostring(stats.station)
        .. ", scanned=" .. tostring(stats.scanned)
        .. ", eligible=" .. tostring(stats.eligible)
        .. " (" .. FormatCounts(stats.eligibleByCategory) .. ")"
        .. ", bags=" .. FormatCounts(stats.eligibleByBag)
        .. ", skipped=" .. FormatCounts(stats.skipped) .. ".")
end

local function RunPreview(station, craftingTypes)
    if not IsPreviewEnabled() then return end
    if type(IsPlayerInCombat) == "function" and IsPlayerInCombat() then
        DebugLog("Deconstruction preview skipped: player is in combat.")
        return
    end

    local bags = BuildBagList()
    if #bags == 0 then
        DebugLog("Deconstruction preview skipped: no bags selected.")
        return
    end

    local stats = NewStats(station, craftingTypes)
    for _, bagId in ipairs(bags) do
        ScanBag(bagId, stats)
    end
    DebugPreviewSummary(stats)
end

local function SchedulePreview(station, craftingTypes)
    if not IsPreviewEnabled() then return end

    DECON.atStation = true
    DECON.scanSequence = (DECON.scanSequence or 0) + 1
    local scanSequence = DECON.scanSequence
    zo_callLater(function()
        if DECON.atStation and DECON.scanSequence == scanSequence then
            RunPreview(station, craftingTypes)
        end
    end, SCAN_DELAY_MS)
end

local function ScheduleNormalStationPreview(source, retryCount)
    if not IsPreviewEnabled() then return end
    local craftingType = GetCurrentCraftingType()
    if not IsKnownDeconstructionCraft(craftingType) then
        retryCount = tonumber(retryCount) or 0
        if retryCount < MAX_CRAFTING_TYPE_RETRIES then
            zo_callLater(function()
                ScheduleNormalStationPreview(source, retryCount + 1)
            end, CRAFTING_TYPE_RETRY_MS)
            return
        end

        DebugLog("Deconstruction preview skipped: unknown crafting type from " .. tostring(source) .. ".")
        return
    end

    SchedulePreview(GetStationName(craftingType), { craftingType })
end

local function OnCraftingStationInteract(_, craftingType, _, craftingMode)
    if not IsPreviewEnabled() then return end

    DECON.currentCraftingType = craftingType
    InstallHooks()
    if IsUniversalDeconstructor(craftingMode) then
        SchedulePreview("universal", nil)
    elseif CRAFTING_TYPE_ENCHANTING ~= nil and craftingType == CRAFTING_TYPE_ENCHANTING then
        zo_callLater(function()
            ScheduleCurrentEnchantingPreview("keyboard enchanting current")
        end, CRAFTING_TYPE_RETRY_MS)
    end
end

local function OnEndCraftingStationInteract()
    DECON.atStation = false
    DECON.currentCraftingType = nil
    DECON.scanSequence = (DECON.scanSequence or 0) + 1
end

local function StopPreviewForModeChange()
    DECON.atStation = false
    DECON.scanSequence = (DECON.scanSequence or 0) + 1
end

local function HookOnce(key, object, methodName, callback)
    if hooksInstalled[key] then return end
    if type(ZO_PreHook) ~= "function" then
        DebugLog("Deconstruction preview hooks unavailable: ZO_PreHook is missing.")
        return
    end
    if not object or type(object[methodName]) ~= "function" then
        return
    end

    ZO_PreHook(object, methodName, callback)
    hooksInstalled[key] = true
end

local function PostHookOnce(key, object, methodName, callback)
    if hooksInstalled[key] then return end
    if type(SecurePostHook) ~= "function" then
        return
    end
    if not object or type(object[methodName]) ~= "function" then
        return
    end

    SecurePostHook(object, methodName, callback)
    hooksInstalled[key] = true
end

local function IsEnchantingExtractionMode()
    if ENCHANTING_MODE_EXTRACTION == nil then return false end

    local enchanting = _G.ENCHANTING
    if enchanting and type(enchanting.GetEnchantingMode) == "function" then
        local ok, mode = pcall(function()
            return enchanting:GetEnchantingMode()
        end)
        if ok and mode == ENCHANTING_MODE_EXTRACTION then
            return true
        end
    end

    local gamepadEnchanting = _G.GAMEPAD_ENCHANTING
    if gamepadEnchanting and type(gamepadEnchanting.GetEnchantingMode) == "function" then
        local ok, mode = pcall(function()
            return gamepadEnchanting:GetEnchantingMode()
        end)
        if ok and mode == ENCHANTING_MODE_EXTRACTION then
            return true
        end
    end

    return false
end

function ScheduleCurrentEnchantingPreview(source)
    if IsEnchantingExtractionMode() then
        ScheduleNormalStationPreview(source)
    end
end

local function InstallKeyboardHooks()
    HookOnce("keyboard_smithing_mode", _G.SMITHING, "SetMode", function(_, mode)
        if SMITHING_MODE_DECONSTRUCTION ~= nil and mode == SMITHING_MODE_DECONSTRUCTION then
            ScheduleNormalStationPreview("keyboard smithing")
        else
            StopPreviewForModeChange()
        end
    end)

    local enchanting = _G.ENCHANTING
    HookOnce("keyboard_enchanting_mode", enchanting and enchanting.inventory, "ChangeMode", function(_, mode)
        if ENCHANTING_MODE_EXTRACTION ~= nil and mode == ENCHANTING_MODE_EXTRACTION then
            ScheduleNormalStationPreview("keyboard enchanting")
        else
            StopPreviewForModeChange()
        end
    end)

    PostHookOnce("keyboard_enchanting_mode_updated", _G.ZO_Enchanting, "OnModeUpdated", function()
        ScheduleCurrentEnchantingPreview("keyboard enchanting mode updated")
    end)
end

local function InstallGamepadHooks()
    HookOnce("gamepad_smithing_mode", _G.SMITHING_GAMEPAD, "SetMode", function(_, mode)
        if SMITHING_MODE_DECONSTRUCTION ~= nil and mode == SMITHING_MODE_DECONSTRUCTION then
            ScheduleNormalStationPreview("gamepad smithing")
        else
            StopPreviewForModeChange()
        end
    end)

    HookOnce("gamepad_enchanting_mode", _G.GAMEPAD_ENCHANTING, "SetEnchantingMode", function(_, mode)
        if ENCHANTING_MODE_EXTRACTION ~= nil and mode == ENCHANTING_MODE_EXTRACTION then
            ScheduleNormalStationPreview("gamepad enchanting")
        else
            StopPreviewForModeChange()
        end
    end)
end

function InstallHooks()
    InstallKeyboardHooks()
    InstallGamepadHooks()
end

function DECON.Init()
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_CRAFTING_STATION_INTERACT, OnCraftingStationInteract)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_END_CRAFTING_STATION_INTERACT, OnEndCraftingStationInteract)
    InstallHooks()
end
