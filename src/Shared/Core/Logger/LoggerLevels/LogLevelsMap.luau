local Types = require("../Types")

local LogLevelsMap: Types.LogLevelsMap = {
    "Trace",
    "Debug",
    "Info",
    "Warn",
    "Error",
}
return table.freeze(LogLevelsMap)
