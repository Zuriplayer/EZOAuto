-- Automatizacion prudente para cerrar libros al abrirlos.
EZOAuto_Books = EZOAuto_Books or {}
local BOOKS = EZOAuto_Books

local EVENT_NAMESPACE = "EZOAuto_Books"

local lastClosedBookKey = nil

local function DebugLog(message)
    if EZOAuto and EZOAuto.DebugLog then
        EZOAuto.DebugLog(message)
    end
end

local function IsEnabled()
    local automation = EZOAuto and EZOAuto.sv and EZOAuto.sv.automation
    return automation and automation.autoCloseBooks == true
end

local function GetCurrentBookKey()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then return nil end

    local ok, action, item = pcall(GetGameCameraInteractableActionInfo)
    if not ok then return nil end
    if item and item ~= "" then return tostring(item) end
    if action and action ~= "" then return tostring(action) end
    return nil
end

local function OnShowBook(_, inBook)
    if not IsEnabled() then return end
    if inBook == false then return end

    local bookKey = GetCurrentBookKey()
    if bookKey and lastClosedBookKey == bookKey then
        lastClosedBookKey = nil
        return
    end

    lastClosedBookKey = bookKey
    if SCENE_MANAGER and type(SCENE_MANAGER.ShowBaseScene) == "function" then
        SCENE_MANAGER:ShowBaseScene()
        DebugLog("Book closed automatically.")
    end
end

function BOOKS.RefreshRegistration()
    if EVENT_SHOW_BOOK ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SHOW_BOOK)
    end

    if not IsEnabled() then return end
    if EVENT_SHOW_BOOK == nil then
        DebugLog("Auto-close books disabled: EVENT_SHOW_BOOK is missing.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SHOW_BOOK, OnShowBook)
end

function BOOKS.Init()
    BOOKS.RefreshRegistration()
end
