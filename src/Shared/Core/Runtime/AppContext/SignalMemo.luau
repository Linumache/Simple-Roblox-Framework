--[=[
    @class SignalMemo
]=]

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local Types = require("../Types")

local Signal = Nevermore("Signal") :: NevermoreTypes.SignalModule

local SignalMemo = {}
SignalMemo.__index = SignalMemo

--[=[
    @within SignalMemo
    @return SignalMemo
]=]
--[=[
    @within SignalMemo
    @prop _Signals setmetatable<{ [RBXScriptSignal]: Signal }, { __mode: "k" }>
    @private
]=]
--[=[
    @within SignalMemo
    @prop _Connections setmetatable<{ [RBXScriptSignal]: RBXScriptConnection }, { __mode: "k" }>
    @private
]=]
--[=[
    @within SignalMemo
    @prop _ParallelSignals setmetatable<{ [RBXScriptSignal]: Signal }, { __mode: "k" }>
    @private
]=]
--[=[
    @within SignalMemo
    @prop _ParallelConnections setmetatable<{ [RBXScriptSignal]: RBXScriptConnection }, { __status: "k" }>
    @private
]=]
function SignalMemo.new()
    local self = setmetatable({
        _Signals = setmetatable({}, { __mode = "k" }),
        _Connections = setmetatable({}, { __mode = "k" }),
        _ParallelSignals = setmetatable({}, { __mode = "k" }),
        _ParallelConnections = setmetatable({}, { __mode = "k" }),
    }, SignalMemo) :: Types.SignalMemo
    return self
end

--[=[
    @method From
    @within SignalMemo
    @param RBXScriptSignal RBXScriptSignal
    @return Signal
]=]
function SignalMemo.From(self: Types.SignalMemo, RBXScriptSignal: RBXScriptSignal)
    local Signals = self._Signals
    local Existing = Signals[RBXScriptSignal]
    if Existing then return Existing end

    local NewSignal: NevermoreTypes.Signal
    self._Connections[RBXScriptSignal] = RBXScriptSignal:Connect(function(...) NewSignal:Fire(...) end)
    NewSignal = Signal.new()
    Signals[RBXScriptSignal] = NewSignal
    return NewSignal
end

--[=[
    @method FromParallel
    @within SignalMemo
    @param RBXScriptSignal RBXScriptSignal
    @return Signal
]=]
function SignalMemo.FromParallel(self: Types.SignalMemo, RBXScriptSignal: RBXScriptSignal)
    local Signals = self._ParallelSignals
    local Existing = Signals[RBXScriptSignal]
    if Existing then return Existing end

    local NewSignal: NevermoreTypes.Signal
    self._ParallelConnections[RBXScriptSignal] = RBXScriptSignal:ConnectParallel(function(...) NewSignal:Fire(...) end)
    NewSignal = Signal.new()
    Signals[RBXScriptSignal] = NewSignal
    return NewSignal
end

local function DisconnectSignals(Signals: { [RBXScriptSignal]: NevermoreTypes.Signal })
    for Index, Signal in Signals do
        Signal:Destroy()
        Signals[Index] = nil
    end
end

local function DisconnectConnections(Connections: { [RBXScriptSignal]: RBXScriptConnection })
    for Index, Connection in Connections do
        Connection:Disconnect()
        Connections[Index] = nil
    end
end

--[=[
    @method Destroy
    @within SignalMemo
]=]
function SignalMemo.Destroy(self: Types.SignalMemo)
    DisconnectSignals(self._Signals)
    DisconnectSignals(self._ParallelSignals)
    DisconnectConnections(self._Connections)
    DisconnectConnections(self._ParallelConnections)
end

return SignalMemo
