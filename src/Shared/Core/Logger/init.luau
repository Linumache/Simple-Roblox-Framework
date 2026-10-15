--[=[
    @class Logger
]=]

--!optimize 2

local RunService = game:GetService("RunService")

local LogLevels = require("@self/LoggerLevels/LogLevels")
local LogLevelsMap = require("@self/LoggerLevels/LogLevelsMap")
local LoggerOutput = require("@self/LoggerOutput")
local Types = require("@self/Types")

local Logger = {}
Logger.__index = Logger

--[=[
    @within Logger
    @prop LogLevels LogLevels
    @tag global
]=]
Logger.LogLevels = LogLevels
--[=[
    @within Logger
    @prop LogLevelsMap LogLevelsMap
    @tag global
]=]
Logger.LogLevelsMap = LogLevelsMap

local DEFAULT_LOG_LEVEL = if RunService:IsStudio() then LogLevels.Debug else LogLevels.Info

local function ToNumberLogLevel(LogLevel: number | Types.LogLevelString)
    return if type(LogLevel) == "number" then LogLevel else LogLevels[LogLevel]
end

--[=[
    @within Logger
    @param LogLevel (number | LogLevelString)?
    @param MaxCount number?
    @return Logger
]=]
--[=[
    @within Logger
    @prop Output LoggerOutput
]=]
--[=[
    @within Logger
    @prop _LogLevel number
    @private
]=]
--[=[
    @within Logger
    @prop _Category string?
    @private
]=]
function Logger.new(LogLevel: (number | Types.LogLevelString)?, MaxCount: number?)
    local self = setmetatable({
        Output = LoggerOutput.new(MaxCount),
        _LogLevel = ToNumberLogLevel(LogLevel or DEFAULT_LOG_LEVEL),
        _Category = nil,
    }, Logger) :: Types.Logger
    return self
end

--[=[
    @method SetLogLevel
    @within Logger
    @param LogLevel (number | LogLevelString)
]=]
function Logger.SetLogLevel(self: Types.Logger, LogLevel: number | Types.LogLevelString)
    self._LogLevel = ToNumberLogLevel(LogLevel)
end

--[=[
    @method GetLogLevel
    @within Logger
    @return number
]=]
function Logger.GetLogLevel(self: Types.Logger) return self._LogLevel end

--[=[
    @method SetCategory
    @within Logger
    @param Category string?
]=]
function Logger.SetCategory(self: Types.Logger, Category: string?) self._Category = Category end

--[=[
    @method GetCategory
    @within Logger
    @return string?
]=]
function Logger.GetCategory(self: Types.Logger) return self._Category end

local function MakeLogFunction(TargetLogLevel: number)
    local function Log(self: Types.Logger, Message: string)
        if self._LogLevel > TargetLogLevel then return end
        local OutputMessage = `[{self._Category or debug.getmemorycategory()}] - {Message}`
        self.Output:Append(TargetLogLevel, OutputMessage)
    end
    return Log
end

local function FilterLogFunction(TargetLogLevel: number, Filter: (Message: string) -> string)
    local Log = MakeLogFunction(TargetLogLevel)
    local function FilterLog(self: Types.Logger, Message: string) Log(self, Filter(Message)) end
    return FilterLog
end

--[=[
    @method Trace
    @within Logger
    @param Message string
]=]
Logger.Trace = MakeLogFunction(LogLevels.Trace)
--[=[
    @method Debug
    @within Logger
    @param Message string
]=]
Logger.Debug = MakeLogFunction(LogLevels.Debug)
--[=[
    @method Info
    @within Logger
    @param Message string
]=]
Logger.Info = MakeLogFunction(LogLevels.Info)
--[=[
    @method Warn
    @within Logger
    @param Message string
]=]
Logger.Warn = MakeLogFunction(LogLevels.Warn)
--[=[
    @method Error
    @within Logger
    @param Message string
]=]
Logger.Error = FilterLogFunction(LogLevels.Error, function(Message) return debug.traceback(Message, 3) end)

return Logger
