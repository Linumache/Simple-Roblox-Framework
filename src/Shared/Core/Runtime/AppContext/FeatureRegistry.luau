--[=[
    @class FeatureRegistry
]=]

--!optimize 2

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local Types = require("../Types")

local Rx = Nevermore("Rx") :: NevermoreTypes.RxModule
local Signal = Nevermore("Signal") :: NevermoreTypes.SignalModule

local FeatureRegistry = {}
FeatureRegistry.__index = FeatureRegistry

--[=[
    @within FeatureRegistry
    @return FeatureRegistry
]=]
--[=[
    @within FeatureRegistry
    @prop _States { [string]: boolean }
    @private
]=]
--[=[
    @within FeatureRegistry
    @prop _Observables { [string]: Observable<boolean> }
    @private
]=]
--[=[
    @within FeatureRegistry
    @prop _Signals { [string]: Signal }
    @private
]=]
--[=[
    @within FeatureRegistry
    @prop _GlobalObservable Observable<{ [string]: boolean }>?
    @private
]=]
--[=[
    @within FeatureRegistry
    @prop _GlobalSignal Signal?
    @private
]=]
function FeatureRegistry.new()
    local self = setmetatable({
        _States = {},
        _Observables = {},
        _Signals = {},
        _GlobalObservable = nil,
        _GlobalSignal = nil,
    }, FeatureRegistry) :: Types.FeatureRegistry
    return self
end

local function FireSignal(self: Types.FeatureRegistry, Name: string, Value: boolean)
    local Signal = self._Signals[Name]
    if Signal then Signal:Fire(Value) end
end

local function SetState(self: Types.FeatureRegistry, Name: string, Value: boolean)
    self._States[Name] = Value
    FireSignal(self, Name, Value)
end

local function GetState(self: Types.FeatureRegistry, Name: string) return self._States[Name] end

--[=[
    @method AddFeature
    @within FeatureRegistry
    @param Name string
    @param Enabled boolean? -- defaults to true
    Register a feature if it doesn't exist.
]=]
function FeatureRegistry.AddFeature(self: Types.FeatureRegistry, Name: string, Enabled: boolean?)
    if GetState(self, Name) ~= nil then return end
    SetState(self, Name, if Enabled == nil then true else not not Enabled)
end

--[=[
    @method SetFeatureEnabled
    @within FeatureRegistry
    @param Name string
    @param Enabled boolean
    Set a feature's state if it exists.
]=]
function FeatureRegistry.SetFeatureEnabled(self: Types.FeatureRegistry, Name: string, Enabled: boolean)
    if GetState(self, Name) == nil then return end
    SetState(self, Name, not not Enabled)
end

--[=[
    @method SetFeature
    @within FeatureRegistry
    @param Name string
    @param Enabled boolean
    Register and set a feature's state no matter if it exists.
]=]
function FeatureRegistry.SetFeature(self: Types.FeatureRegistry, Name: string, Enabled: boolean)
    SetState(self, Name, not not Enabled)
end

--[=[
    @method IsFeature
    @within FeatureRegistry
    @param Name string
    @return boolean
]=]
function FeatureRegistry.IsFeature(self: Types.FeatureRegistry, Name: string) return GetState(self, Name) ~= nil end

--[=[
    @method IsFeatureEnabled
    @within FeatureRegistry
    @param Name string
    @return boolean
]=]
function FeatureRegistry.IsFeatureEnabled(self: Types.FeatureRegistry, Name: string) return GetState(self, Name) == true end

local function GetObservable(self: Types.FeatureRegistry, Name: string)
    local Observables = self._Observables
    local Observable = Observables[Name]
    if Observable then return Observable end

    local Signal = Signal.new()
    self._Signals[Name] = Signal

    Observable = Rx.fromSignal(Signal) :: NevermoreTypes.Observable<boolean>
    Observables[Name] = Observable
    return Observable
end

local function GetGlobalObservable(self: Types.FeatureRegistry)
    local GlobalObservable = self._GlobalObservable
    if GlobalObservable then return GlobalObservable end

    local Signal = Signal.new()
    self._GlobalSignal = Signal

    GlobalObservable = Rx.fromSignal(Signal) :: NevermoreTypes.Observable<{ [string]: boolean }>
    self._GlobalObservable = GlobalObservable
    return GlobalObservable
end

--[=[
    @method GetObservable
    @within FeatureRegistry
    @param Name string
    @return Observable<boolean>
]=]
FeatureRegistry.GetObservable = GetObservable
--[=[
    @method GetGlobalObservable
    @within FeatureRegistry
    @return Observable<{ [string]: boolean }>
    :::warning
    The global state table is shared and is not cloned.
    By using the observable, you should've known what you're doing.
    :::
]=]
FeatureRegistry.GetGlobalObservable = GetGlobalObservable

--[=[
    @method Observe
    @within FeatureRegistry
    @param Name string
    @param Callback (Enabled: boolean) -> ()
    @return Subscription<boolean>
]=]
function FeatureRegistry.Observe(
    self: Types.FeatureRegistry,
    Name: string,
    Callback: (Enabled: boolean) -> ()
): NevermoreTypes.Subscription<boolean>
    return GetObservable(self, Name):Subscribe(Callback)
end

--[=[
    @method ObserveGlobal
    @within FeatureRegistry
    @param Callback (States: { [string]: boolean }) -> ()
    @return Subscription<{ [string]: boolean }>
    :::warning
    The global state table is shared and is not cloned.
    By using the observable, you should've known what you're doing.
    :::
]=]
function FeatureRegistry.ObserveGlobal(
    self: Types.FeatureRegistry,
    Callback: (States: { [string]: boolean }) -> ()
): NevermoreTypes.Subscription<{ [string]: boolean }>
    return GetGlobalObservable(self):Subscribe(Callback)
end

--[=[
    @method GetGlobalStates
    @within FeatureRegistry
    @return { [string]: boolean }
]=]
function FeatureRegistry.GetGlobalStates(self: Types.FeatureRegistry) return self._States end

--[=[
    @method Destroy
    @within FeatureRegistry
]=]
function FeatureRegistry.Destroy(self: Types.FeatureRegistry)
    table.clear(self._States)
    table.clear(self._Observables)

    local Signals = self._Signals
    for Index, Signal in Signals do
        Signal:Destroy()
        Signals[Index] = nil
    end

    local GlobalSignal = self._GlobalSignal
    if GlobalSignal then
        GlobalSignal:Destroy()
        self._GlobalSignal = nil
        self._GlobalObservable = nil
    end
end

return FeatureRegistry
