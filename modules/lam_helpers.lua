-- Shared LibAddonMenu helpers for EZOAuto.
EZOAuto_LAM = EZOAuto_LAM or {}

local LAM = EZOAuto_LAM
local INFO_HEADER_TEXTURE = "EsoUI/Art/Miscellaneous/help_icon.dds"

function LAM.CreateInfoHeader(name, tooltip)
    return {
        type = "header",
        name = zo_strformat(
            "<<1>> |cB040FF|t26:26:<<2>>:inheritcolor|t|r",
            tostring(name or ""),
            INFO_HEADER_TEXTURE
        ),
        tooltip = tooltip,
    }
end
