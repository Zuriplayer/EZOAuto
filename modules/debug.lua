-- Registro de depuracion para EZOAuto.
-- Lo tecnico va al Debug Viewer; el chat queda para avisos utiles.
EZOAuto = EZOAuto or {}

local EZOA = EZOAuto
local ADDON_NAME = "EZOAuto"

local function GetLocalizedString(id, fallback)
    local stringId = _G[id]
    if stringId ~= nil and type(GetString) == "function" then
        return GetString(stringId)
    end
    return fallback
end

local function GetLogger()
    if EZOA._debugLoggerUnavailable == true then
        return nil
    end

    local lib = _G.LibDebugLogger
    if type(lib) ~= "function" and type(lib) ~= "table" then
        EZOA._debugLoggerUnavailable = true
        return nil
    end

    if EZOA._debugLogger ~= nil then
        return EZOA._debugLogger
    end

    local ok, logger = false, nil
    if type(lib) == "function" then
        ok, logger = pcall(lib, ADDON_NAME)
    end
    if (not ok or logger == nil) and type(lib) == "table" and type(lib.Create) == "function" then
        ok, logger = pcall(function()
            return lib:Create(ADDON_NAME)
        end)
        if not ok or logger == nil then
            ok, logger = pcall(lib.Create, ADDON_NAME)
        end
    end

    if ok and logger ~= nil then
        EZOA._debugLogger = logger
        EZOA._debugLoggerUnavailable = false
        return logger
    end

    EZOA._debugLoggerUnavailable = true
    return nil
end

function EZOA.IsDebugModeEnabled()
    return EZOA.runtime and EZOA.runtime.debugMode == true
end

function EZOA.SetDebugModeEnabled(enabled)
    EZOA.runtime = EZOA.runtime or {}
    enabled = enabled == true
    if not enabled then
        EZOA.DebugLog(GetLocalizedString("EZOA_DEBUG_MODE_DISABLED", "Debug mode disabled."))
    end
    EZOA.runtime.debugMode = enabled

    if EZOA.sv and EZOA.sv.general then
        EZOA.sv.general.debugMode = enabled
    end

    if enabled then
        EZOA.DebugLog(GetLocalizedString("EZOA_DEBUG_MODE_ENABLED", "Debug mode enabled."))
    end
end

function EZOA.DebugLog(message)
    if not EZOA.IsDebugModeEnabled() then
        return false
    end

    local lib = _G.LibDebugLogger
    local logger = GetLogger()
    if not logger then
        return false
    end

    if type(logger.SetMinLevelOverride) == "function" and type(lib) == "table" and lib.LOG_LEVEL_DEBUG ~= nil then
        pcall(function()
            logger:SetMinLevelOverride(lib.LOG_LEVEL_DEBUG)
        end)
    end
    if type(logger.SetLogTracesOverride) == "function" then
        pcall(function()
            logger:SetLogTracesOverride(false)
        end)
    end

    if type(logger.Debug) == "function" then
        local ok = pcall(function()
            logger:Debug(tostring(message))
        end)
        return ok == true
    end

    if type(logger.Log) == "function" and type(lib) == "table" and lib.LOG_LEVEL_DEBUG ~= nil then
        local ok = pcall(function()
            logger:Log(lib.LOG_LEVEL_DEBUG, tostring(message))
        end)
        return ok == true
    end

    return false
end

function EZOA.DebugPrint(message)
    return EZOA.DebugLog(message)
end
