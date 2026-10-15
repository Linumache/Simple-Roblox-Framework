--[=[
    @class LoggerOutput
]=]

--!optimize 2

local LogLevels = require("./LoggerLevels/LogLevels")
local Nevermore = require("../../Packages/Nevermore")
local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")
local RingBuffer = require("@self/RingBuffer")
local Types = require("./Types")

local Rx = Nevermore("Rx") :: NevermoreTypes.RxModule
local Signal = Nevermore("Signal") :: NevermoreTypes.SignalModule

local LoggerOutput = {}
LoggerOutput.__index = LoggerOutput

local DEFAULT_MAX_COUNT = 1000

local function CreateChannel(MaxCount: number)
    local Source = RingBuffer.new(MaxCount) :: Types.RingBuffer<string>
    local Signal = Signal.new()
    local Observable = Rx.fromSignal(Signal) :: NevermoreTypes.Observable<string>

    local OutputChannel: Types.LoggerOutputChannel = {
        Source = Source,
        Signal = Signal,
        Observable = Observable,
    }
    return OutputChannel
end

--[=[
    @within LoggerOutput
    @param MaxCount number?
    @return LoggerOutput
]=]
--[=[
    @within LoggerOutput
    @prop _Channels { [number]: LoggerOutputChannel }
    @private
]=]
function LoggerOutput.new(MaxCount: number?)
    MaxCount = MaxCount or DEFAULT_MAX_COUNT

    local self = setmetatable({
        _Channels = {
            [LogLevels.Trace] = CreateChannel(MaxCount),
            [LogLevels.Debug] = CreateChannel(MaxCount),
            [LogLevels.Info] = CreateChannel(MaxCount),
            [LogLevels.Warn] = CreateChannel(MaxCount),
            [LogLevels.Error] = CreateChannel(MaxCount),
        },
    }, LoggerOutput) :: Types.LoggerOutput
    return self
end

local function GetChannel(self: Types.LoggerOutput, LogLevel: number)
    return self._Channels[LogLevel] or error(`[LoggerOutput] - Invalid LogLevel {LogLevel}`, 2)
end

--[=[
    @method Append
    @within LoggerOutput
    @param LogLevel number
    @param Message string
]=]
function LoggerOutput.Append(self: Types.LoggerOutput, LogLevel: number, Message: string)
    local Channel = GetChannel(self, LogLevel)
    Channel.Source:Push(Message)
    Channel.Signal:Fire(Message)
end

--[=[
    @method SetMaxCount
    @within LoggerOutput
    @param LogLevel number
    @param MaxCount number
]=]
function LoggerOutput.SetMaxCount(self: Types.LoggerOutput, LogLevel: number, MaxCount: number)
    local Channel = GetChannel(self, LogLevel)
    Channel.Source:SetMaxSize(MaxCount)
end

--[=[
    @method Observe
    @within LoggerOutput
    @param LogLevel number
    @param Callback (Message: string) -> ()
    @return Subscription<string>
]=]
function LoggerOutput.Observe(self: Types.LoggerOutput, LogLevel: number, Callback: (Message: string) -> ())
    local Channel = GetChannel(self, LogLevel)
    return Channel.Observable:Subscribe(Callback)
end

--[=[
    @method Replay
    @within LoggerOutput
    @param LogLevel number
    @return { string }
]=]
function LoggerOutput.Replay(self: Types.LoggerOutput, LogLevel: number)
    local Channel = GetChannel(self, LogLevel)
    return Channel.Source:ToArray() :: { string }
end

--[=[
    @method GetLatest
    @within LoggerOutput
    @param LogLevel number
    @return string?
]=]
function LoggerOutput.GetLatest(self: Types.LoggerOutput, LogLevel: number)
    local Channel = GetChannel(self, LogLevel)
    return Channel.Source:Peek() :: string?
end

--[=[
    @method GetObservable
    @within LoggerOutput
    @param LogLevel number
    @return Observable
]=]
function LoggerOutput.GetObservable(self: Types.LoggerOutput, LogLevel: number)
    local Channel = GetChannel(self, LogLevel)
    return Channel.Observable
end

--[=[
    @method GetSource
    @within LoggerOutput
    @param LogLevel number
    @return RingBuffer<string>
]=]
function LoggerOutput.GetSource(self: Types.LoggerOutput, LogLevel: number)
    local Channel = GetChannel(self, LogLevel)
    return Channel.Source
end

return LoggerOutput
