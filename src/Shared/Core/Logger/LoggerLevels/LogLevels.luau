local Types = require("../Types")

local LogLevels: Types.LogLevels = {
    Trace = 1,
    Debug = 2,
    Info = 3,
    Warn = 4,
    Error = 5,
}
return table.freeze(LogLevels)
