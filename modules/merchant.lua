-- Tareas automaticas al abrir un mercader.
EZOAuto_Merchant = EZOAuto_Merchant or {}

local MERCHANT = EZOAuto_Merchant
local EZOA = EZOAuto

local EVENT_PREFIX = "EZOAuto_Merchant"
local SELL_DELAY_MS = 80
local MAX_SALES_PER_OPEN = 98

local REPAIR_MODE_EQUIPPED = "equipped"
local REPAIR_MODE_ALL = "all"

local function DebugLog(message)
    if EZOA and type(EZOA.DebugLog) == "function" then
        EZOA.DebugLog(message)
    end
end

local function NewStats()
    return {
        scanned = 0,
        queued = 0,
        skipped = {},
        queuedByReason = {
            ornate = 0,
            treasure = 0,
            trash = 0,
        },
        soldByReason = {
            ornate = 0,
            treasure = 0,
            trash = 0,
        },
        failedRevalidation = 0,
        capped = false,
    }
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

local function DebugScanSummary(stats)
    if not stats then return end
    DebugLog("Merchant scan: scanned=" .. tostring(stats.scanned)
        .. ", queued=" .. tostring(stats.queued)
        .. " (" .. FormatCounts(stats.queuedByReason) .. ")"
        .. ", skipped=" .. FormatCounts(stats.skipped)
        .. (stats.capped and ", capped=yes" or "") .. ".")
end

local function DebugFinishSummary(runtime)
    if not runtime then return end
    local stats = runtime.stats
    if not stats then return end
    DebugLog("Merchant sale finished: sold=" .. tostring(runtime.soldStacks)
        .. " (" .. FormatCounts(stats.soldByReason) .. ")"
        .. ", revalidationFailed=" .. tostring(stats.failedRevalidation) .. ".")
end

local function IsAutomationEnabled()
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    if not automation then return false end
    return automation.sellOrnateAtMerchant == true
        or automation.sellTreasuresAtMerchant == true
        or automation.sellTrashAtMerchant == true
        or automation.repairEquippedAtMerchant == true
        or automation.repairEquippedAndInventoryAtMerchant == true
end

local function IsSellAutomationEnabled()
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    if not automation then return false end
    return automation.sellOrnateAtMerchant == true
        or automation.sellTreasuresAtMerchant == true
        or automation.sellTrashAtMerchant == true
end

local function GetRepairMode()
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    if not automation then return nil end
    if automation.repairEquippedAndInventoryAtMerchant == true then
        return REPAIR_MODE_ALL
    end
    if automation.repairEquippedAtMerchant == true then
        return REPAIR_MODE_EQUIPPED
    end
    return nil
end

local function IsNormalMerchantOpen()
    if type(GetInteractionType) == "function" and INTERACTION_VENDOR ~= nil then
        return GetInteractionType() == INTERACTION_VENDOR
    end
    return true
end

local function IsOrnateTrait(trait)
    if trait == nil then return false end
    return (ITEM_TRAIT_TYPE_ARMOR_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE)
        or (ITEM_TRAIT_TYPE_WEAPON_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE)
        or (ITEM_TRAIT_TYPE_JEWELRY_ORNATE ~= nil and trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE)
end

local function GetStackAndSellPrice(bagId, slotIndex)
    if type(GetItemInfo) ~= "function" then return 0, 0, false end
    local _, stackCount, sellPrice, _, locked = GetItemInfo(bagId, slotIndex)
    stackCount = tonumber(stackCount) or 0
    sellPrice = tonumber(sellPrice) or 0
    return stackCount, sellPrice, locked == true
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

local function GetUniqueIdString(bagId, slotIndex)
    if type(GetItemUniqueId) ~= "function" then return nil end
    local id = GetItemUniqueId(bagId, slotIndex)
    if id == nil then return nil end
    if type(Id64ToString) == "function" then
        local ok, value = pcall(Id64ToString, id)
        if ok and value ~= nil then return tostring(value) end
    end
    return tostring(id)
end

local function CallApi(functionName, ...)
    local fn = _G[functionName]
    if type(fn) == "function" then
        local ok, result = pcall(fn, ...)
        if ok then return true, result end
        DebugLog(functionName .. " failed: " .. tostring(result) .. ".")
    end

    if type(IsProtectedFunction) == "function" and type(CallSecureProtected) == "function" then
        local okProtected, isProtected = pcall(IsProtectedFunction, functionName)
        if okProtected and isProtected then
            local okSecure, resultSecure = pcall(CallSecureProtected, functionName, ...)
            if okSecure then return true, resultSecure end
            DebugLog(functionName .. " secure call failed: " .. tostring(resultSecure) .. ".")
        end
    end

    return false, nil
end

local function GetMoney()
    if type(GetCurrencyAmount) == "function" and CURT_MONEY ~= nil and CURRENCY_LOCATION_CHARACTER ~= nil then
        return tonumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)) or 0
    end
    if type(GetCurrentMoney) == "function" then
        return tonumber(GetCurrentMoney()) or 0
    end
    return 0
end

local function CanRepairAtCurrentMerchant()
    if type(CanStoreRepair) == "function" then
        return CanStoreRepair() == true
    end
    return type(RepairAll) == "function" or type(RepairItem) == "function"
end

local function IsRepairCandidate(bagId, slotIndex)
    if type(HasItemInSlot) == "function" and not HasItemInSlot(bagId, slotIndex) then
        return false, 0
    end
    if type(IsItemStolen) == "function" and IsItemStolen(bagId, slotIndex) then
        return false, 0
    end
    if type(GetItemCondition) == "function" and GetItemCondition(bagId, slotIndex) >= 100 then
        return false, 0
    end
    if type(GetItemRepairCost) ~= "function" then
        return false, 0
    end

    local repairCost = tonumber(GetItemRepairCost(bagId, slotIndex)) or 0
    return repairCost > 0, repairCost
end

local function AddRepairCandidatesFromBag(bagId, candidates)
    local totalCost = 0
    if type(ZO_IterateBagSlots) == "function" then
        for slotIndex in ZO_IterateBagSlots(bagId) do
            local repairable, repairCost = IsRepairCandidate(bagId, slotIndex)
            if repairable then
                candidates[#candidates + 1] = {
                    bagId = bagId,
                    slotIndex = slotIndex,
                    repairCost = repairCost,
                }
                totalCost = totalCost + repairCost
            end
        end
        return totalCost
    end

    if type(GetBagSize) ~= "function" then return 0 end
    local bagSize = tonumber(GetBagSize(bagId)) or 0
    for slotIndex = 0, bagSize - 1 do
        local repairable, repairCost = IsRepairCandidate(bagId, slotIndex)
        if repairable then
            candidates[#candidates + 1] = {
                bagId = bagId,
                slotIndex = slotIndex,
                repairCost = repairCost,
            }
            totalCost = totalCost + repairCost
        end
    end
    return totalCost
end

local function BuildRepairCandidates(mode)
    local candidates = {}
    local totalCost = AddRepairCandidatesFromBag(BAG_WORN, candidates)
    if mode == REPAIR_MODE_ALL then
        totalCost = totalCost + AddRepairCandidatesFromBag(BAG_BACKPACK, candidates)
    end
    return candidates, totalCost
end

local function RepairEquippedCandidates(candidates)
    if type(RepairItem) ~= "function" then
        DebugLog("Merchant repair unavailable: RepairItem is missing.")
        return false
    end

    for _, item in ipairs(candidates) do
        CallApi("RepairItem", item.bagId, item.slotIndex)
    end
    return true
end

local function RunRepairAutomation()
    local mode = GetRepairMode()
    if not mode then return end
    if not IsNormalMerchantOpen() then return end
    if not CanRepairAtCurrentMerchant() then
        DebugLog("Merchant repair skipped: this merchant cannot repair.")
        return
    end

    local candidates, totalCost = BuildRepairCandidates(mode)
    DebugLog("Merchant repair scan: mode=" .. tostring(mode)
        .. ", items=" .. tostring(#candidates)
        .. ", cost=" .. tostring(totalCost) .. ".")
    if #candidates == 0 then return end

    local moneyBefore = GetMoney()
    if totalCost > moneyBefore then
        if EZOA and type(EZOA.Print) == "function" then
            EZOA.Print(zo_strformat(GetString(EZOA_MSG_REPAIR_NOT_ENOUGH_GOLD), totalCost))
        end
        DebugLog("Merchant repair skipped: not enough gold.")
        return
    end

    local ok = false
    if mode == REPAIR_MODE_ALL and type(RepairAll) == "function" then
        ok = CallApi("RepairAll")
    else
        ok = RepairEquippedCandidates(candidates)
    end

    if ok and EZOA and type(EZOA.Print) == "function" then
        zo_callLater(function()
            local actualCost = moneyBefore - GetMoney()
            if actualCost < 0 then actualCost = totalCost end
            EZOA.Print(zo_strformat(GetString(EZOA_MSG_REPAIR_DONE), #candidates, actualCost))
            DebugLog("Merchant repair finished: items=" .. tostring(#candidates)
                .. ", cost=" .. tostring(actualCost) .. ".")
        end, 200)
    end
end

local function IsSkippedByProtection(bagId, slotIndex, locked)
    if locked then return true, "locked" end
    if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) then
        return true, "player locked"
    end
    if type(IsItemProtected) == "function" and IsItemProtected(bagId, slotIndex) then
        return true, "protected"
    end
    if type(IsItemInArmory) == "function" and IsItemInArmory(bagId, slotIndex) then
        return true, "armory"
    end
    if type(GetItemActorCategory) == "function"
        and GAMEPLAY_ACTOR_CATEGORY_COMPANION ~= nil
        and GetItemActorCategory(bagId, slotIndex) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then
        return true, "companion"
    end
    return false, nil
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

local function GetSellReason(bagId, slotIndex)
    local automation = EZOA and EZOA.sv and EZOA.sv.automation
    if not automation then return nil end

    if automation.sellOrnateAtMerchant == true and type(GetItemTrait) == "function" then
        if IsOrnateTrait(GetItemTrait(bagId, slotIndex)) then
            return "ornate"
        end
    end

    local itemType = GetItemTypeSafe(bagId, slotIndex)
    if automation.sellTreasuresAtMerchant == true
        and ITEMTYPE_TREASURE ~= nil
        and itemType == ITEMTYPE_TREASURE then
        return "treasure"
    end
    if automation.sellTrashAtMerchant == true
        and ITEMTYPE_TRASH ~= nil
        and itemType == ITEMTYPE_TRASH then
        return "trash"
    end

    return nil
end

local function GetCandidate(bagId, slotIndex, stats)
    if type(HasItemInSlot) == "function" and not HasItemInSlot(bagId, slotIndex) then
        return nil
    end

    local stackCount, sellPrice, locked = GetStackAndSellPrice(bagId, slotIndex)
    if stackCount <= 0 then return nil end
    if stats then stats.scanned = stats.scanned + 1 end
    if sellPrice <= 0 then
        AddCount(stats and stats.skipped, "no value")
        return nil
    end
    if IsStolen(bagId, slotIndex) then
        AddCount(stats and stats.skipped, "stolen")
        return nil
    end

    local skipped, reason = IsSkippedByProtection(bagId, slotIndex, locked)
    if skipped then
        AddCount(stats and stats.skipped, reason)
        return nil
    end

    local sellReason = GetSellReason(bagId, slotIndex)
    if not sellReason then return nil end

    return {
        bagId = bagId,
        slotIndex = slotIndex,
        stackCount = stackCount,
        sellPrice = sellPrice,
        uniqueId = GetUniqueIdString(bagId, slotIndex),
        reason = sellReason,
    }
end

local function BuildSellQueue()
    local queue = {}
    local stats = NewStats()
    if type(GetBagSize) ~= "function" then return queue, stats end

    local bagSize = tonumber(GetBagSize(BAG_BACKPACK)) or 0
    for slotIndex = 0, bagSize - 1 do
        local candidate = GetCandidate(BAG_BACKPACK, slotIndex, stats)
        if candidate then
            queue[#queue + 1] = candidate
            stats.queued = stats.queued + 1
            AddCount(stats.queuedByReason, candidate.reason)
            if #queue >= MAX_SALES_PER_OPEN then
                stats.capped = true
                break
            end
        end
    end
    return queue, stats
end

local function FinishQueue()
    local runtime = MERCHANT.runtime
    MERCHANT.runtime = nil
    DebugFinishSummary(runtime)
    local shouldRepair = not (runtime and runtime.cancelled)
    if not (runtime and runtime.soldStacks > 0 and EZOA and type(EZOA.Print) == "function") then
        if shouldRepair then
            RunRepairAutomation()
        end
        return
    end

    local soldStacks = runtime.soldStacks
    local goldEstimate = runtime.goldEstimate
    local moneyBefore = runtime.moneyBefore
    zo_callLater(function()
        local gold = goldEstimate
        if type(GetCurrentMoney) == "function" and moneyBefore ~= nil then
            local actualGold = (tonumber(GetCurrentMoney()) or moneyBefore) - moneyBefore
            if actualGold >= 0 then
                gold = actualGold
            end
        end
        EZOA.Print(zo_strformat(GetString(EZOA_MSG_SELL_DONE), soldStacks, gold))
    end, 200)
    if shouldRepair then
        zo_callLater(RunRepairAutomation, 300)
    end
end

local function SellNext()
    local runtime = MERCHANT.runtime
    if not runtime or runtime.cancelled then return end
    if not IsNormalMerchantOpen() then
        DebugLog("Merchant sale queue stopped: merchant is no longer open.")
        FinishQueue()
        return
    end
    if type(IsPlayerInCombat) == "function" and IsPlayerInCombat() then
        DebugLog("Merchant sale queue stopped: player entered combat.")
        FinishQueue()
        return
    end

    runtime.index = runtime.index + 1
    local item = runtime.queue[runtime.index]
    if not item then
        FinishQueue()
        return
    end

    local current = GetCandidate(item.bagId, item.slotIndex)
    if current
        and (item.uniqueId == nil or current.uniqueId == item.uniqueId)
        and current.reason == item.reason then
        local sold = CallApi("SellInventoryItem", item.bagId, item.slotIndex, current.stackCount)
        if sold then
            runtime.soldStacks = runtime.soldStacks + 1
            runtime.goldEstimate = runtime.goldEstimate + (current.sellPrice * current.stackCount)
            AddCount(runtime.stats and runtime.stats.soldByReason, item.reason)
        end
    else
        if runtime.stats then
            runtime.stats.failedRevalidation = runtime.stats.failedRevalidation + 1
        end
    end

    zo_callLater(SellNext, SELL_DELAY_MS)
end

local function OnOpenStore()
    if not IsAutomationEnabled() then return end
    if not IsNormalMerchantOpen() then
        DebugLog("Merchant actions skipped: interaction is not a normal vendor.")
        return
    end
    if type(IsPlayerInCombat) == "function" and IsPlayerInCombat() then
        if EZOA and type(EZOA.Print) == "function" then
            EZOA.Print(GetString(EZOA_MSG_SELL_SKIPPED_COMBAT))
        end
        return
    end

    if not IsSellAutomationEnabled() then
        RunRepairAutomation()
        return
    end
    if type(SellInventoryItem) ~= "function" then
        DebugLog("Merchant selling unavailable: SellInventoryItem is missing.")
        RunRepairAutomation()
        return
    end

    local queue, stats = BuildSellQueue()
    DebugScanSummary(stats)
    if #queue == 0 then
        RunRepairAutomation()
        return
    end

    MERCHANT.runtime = {
        queue = queue,
        index = 0,
        soldStacks = 0,
        goldEstimate = 0,
        moneyBefore = (type(GetCurrentMoney) == "function" and tonumber(GetCurrentMoney())) or nil,
        stats = stats,
    }
    zo_callLater(SellNext, SELL_DELAY_MS)
end

local function OnCloseStore()
    if MERCHANT.runtime then
        MERCHANT.runtime.cancelled = true
        FinishQueue()
    end
end

function MERCHANT.Init()
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_OPEN_STORE, OnOpenStore)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_CLOSE_STORE, OnCloseStore)
end
