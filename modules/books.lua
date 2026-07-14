-- Automatizacion prudente para cerrar libros al abrirlos.
EZOAuto_Books = EZOAuto_Books or {}
local BOOKS = EZOAuto_Books

local EVENT_NAMESPACE = "EZOAuto_Books"
local CLOSE_DELAY_MS = 50
local REOPEN_WINDOW_MS = 3000

local lastClosedBookKey = nil
local lastClosedAt = 0
local pendingCloseGeneration = 0

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

local function GetBookKey(title, bookId)
    if bookId ~= nil and bookId ~= 0 then return tostring(bookId) end
    if title and title ~= "" then return tostring(title) end
    return GetCurrentBookKey()
end

local function GetNowMilliseconds()
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(GetGameTimeMilliseconds()) or 0
    end
    return 0
end

local function CancelPendingClose()
    pendingCloseGeneration = pendingCloseGeneration + 1
end

local function ShouldLeaveRepeatedBookOpen(bookKey, now)
    if not bookKey or lastClosedBookKey ~= bookKey then return false end
    if now <= 0 or lastClosedAt <= 0 or now - lastClosedAt > REOPEN_WINDOW_MS then return false end

    lastClosedBookKey = nil
    lastClosedAt = 0
    return true
end

local function CloseBookWhenReady(generation, bookKey)
    if generation ~= pendingCloseGeneration or not IsEnabled() then return end
    if not (SCENE_MANAGER and type(SCENE_MANAGER.ShowBaseScene) == "function") then
        DebugLog("Auto-close books skipped: scene manager is unavailable.")
        return
    end

    SCENE_MANAGER:ShowBaseScene()
    lastClosedBookKey = bookKey
    lastClosedAt = GetNowMilliseconds()
    DebugLog("Book closed automatically.")
end

local function OnShowBook(_, title, _body, _medium, _showTitle, bookId)
    if not IsEnabled() then return end

    local bookKey = GetBookKey(title, bookId)
    if ShouldLeaveRepeatedBookOpen(bookKey, GetNowMilliseconds()) then
        DebugLog("Repeated book left open for reading.")
        return
    end

    CancelPendingClose()
    local generation = pendingCloseGeneration
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            CloseBookWhenReady(generation, bookKey)
        end, CLOSE_DELAY_MS)
    else
        CloseBookWhenReady(generation, bookKey)
    end
end

local function OnHideBook()
    CancelPendingClose()
end

function BOOKS.RefreshRegistration()
    CancelPendingClose()

    if EVENT_SHOW_BOOK ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SHOW_BOOK)
    end
    if EVENT_HIDE_BOOK ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_HIDE_BOOK)
    end

    if not IsEnabled() then return end
    if EVENT_SHOW_BOOK == nil or EVENT_HIDE_BOOK == nil then
        DebugLog("Auto-close books disabled: required book events are missing.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SHOW_BOOK, OnShowBook)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HIDE_BOOK, OnHideBook)
    DebugLog("Auto-close books event registered.")
end

function BOOKS.Init()
    BOOKS.RefreshRegistration()
end
