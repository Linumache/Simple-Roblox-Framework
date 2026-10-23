--[=[
    @class ValueStore
]=]

--!optimize 2

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local RuntimeTypes = require("../RuntimeTypes")

local Rx = Nevermore("Rx") :: NevermoreTypes.RxModule
local Signal = Nevermore("Signal") :: NevermoreTypes.SignalModule

local ValueStore = {}
ValueStore.__index = ValueStore

--[=[
    @within ValueStore
    @return ValueStore
]=]
--[=[
    @within ValueStore
    @prop _Entries { [string]: Value }
    @private
]=]
--[=[
    @within ValueStore
    @prop _Scopes { [ValueScope]: { [string]: Value } }
    @private
]=]
--[=[
    @within ValueStore
    @prop _Observables { [string]: Observable<any?> }
    @private
]=]
--[=[
    @within ValueStore
    @prop _Signals { [string]: Signal }
    @private
]=]
--[=[
    @within ValueStore
    @prop _GlobalObservable Observable<{ [string]: any }>?
    @private
]=]
--[=[
    @within ValueStore
    @prop _GlobalEntries { [string]: any }?
    @private
]=]
--[=[
    @within ValueStore
    @prop _GlobalSignal Signal?
    @private
]=]
function ValueStore.new()
    local self = setmetatable({
        _Entries = {},
        _Scopes = {},
        _Observables = {},
        _Signals = {},
        _GlobalObservable = nil,
        _GlobalEntries = nil,
        _GlobalSignal = nil,
    }, ValueStore) :: RuntimeTypes.ValueStore
    return self
end

local function FireSignal(self: RuntimeTypes.ValueStore, Name: string, Value: any?)
    local Signal = self._Signals[Name]
    if Signal then Signal:Fire(Value) end

    local GlobalEntries = self._GlobalEntries
    if GlobalEntries then
        GlobalEntries[Name] = Value
        local GlobalSignal = self._GlobalSignal
        if GlobalSignal then GlobalSignal:Fire(GlobalEntries) end
    end
end

local function CheckFireSignal(self: RuntimeTypes.ValueStore, Name: string, Value: any?, OldValue: any?)
    if Value == OldValue and (type(Value) ~= "table" or table.isfrozen(Value)) then return end
    FireSignal(self, Name, Value)
end

local function GetEntry(self: RuntimeTypes.ValueStore, Name: string): RuntimeTypes.StoreEntry?
    return self._Entries[Name]
end

local function GetScopeStore(self: RuntimeTypes.ValueStore, Scope: RuntimeTypes.ValueScope)
    local Store = self._Scopes[Scope]
    if Store then return Store end

    Store = {}
    self._Scopes[Scope] = Store
    return Store
end

local function CreateEntry(self: RuntimeTypes.ValueStore, Scope: RuntimeTypes.ValueScope, Name: string, Value: any?)
    local StoreEntry: RuntimeTypes.StoreEntry = {
        Scope = Scope,
        Value = Value,
    }
    self._Entries[Name] = StoreEntry

    local ScopeStore = GetScopeStore(self, Scope)
    ScopeStore[Name] = StoreEntry
    FireSignal(self, Name, Value)

    return StoreEntry
end

--[=[
    @method Add
    @within ValueStore
    @param Scope ValueScope
    @param Name string
    @param Value any?
    Create an entry for a value if it doesn't exist.
]=]
function ValueStore.Add(self: RuntimeTypes.ValueStore, Scope: RuntimeTypes.ValueScope, Name: string, Value: any?)
    if not GetEntry(self, Name) then CreateEntry(self, Scope, Name, Value) end
end

--[=[
    @method Set
    @within ValueStore
    @param Name string
    @param Value any
    Set an entry's value, or create one if it doesn't exist.
]=]
function ValueStore.Set(self: RuntimeTypes.ValueStore, Scope: RuntimeTypes.ValueScope, Name: string, Value: any)
    local Entry = GetEntry(self, Name) or CreateEntry(self, Scope, Name, Value)

    local OldValue = Entry.Value
    Entry.Value = Value
    CheckFireSignal(self, Name, Value, OldValue)
end

--[=[
    @method Has
    @within ValueStore
    @param Name string
    @return boolean
]=]
function ValueStore.Has(self: RuntimeTypes.ValueStore, Name: string) return GetEntry(self, Name) ~= nil end

--[=[ 
   @method Get
   @within ValueStore
   @param Name string
   @return any
]=]
function ValueStore.Get(self: RuntimeTypes.ValueStore, Name: string)
    local Entry = GetEntry(self, Name)
    if Entry then return Entry.Value end
    return nil
end

--[=[
    @method Remove
    @within ValueStore
    @param Name string
]=]
function ValueStore.Remove(self: RuntimeTypes.ValueStore, Name: string)
    local Entry = GetEntry(self, Name)
    if not Entry then return end

    local ScopeEntries = self._Scopes[Entry.Scope]
    if ScopeEntries then ScopeEntries[Name] = nil end

    self._Entries[Name] = nil
    CheckFireSignal(self, Name, nil, Entry.Value)
end

--[=[
    @method RemoveScope
    @within ValueStore
    @param Scope ValueScope
]=]
function ValueStore.RemoveScope(self: RuntimeTypes.ValueStore, Scope: RuntimeTypes.ValueScope)
    local Scopes = self._Scopes
    local ScopeEntries = Scopes[Scope]
    if not ScopeEntries then return end

    Scopes[Scope] = nil
    local Entries = self._Entries
    for Name in ScopeEntries do
        Entries[Name] = nil
    end

    for Name, Entry in ScopeEntries do
        CheckFireSignal(self, Name, nil, Entry.Value)
    end
end

local function GetObservable(self: RuntimeTypes.ValueStore, Name: string)
    local Observables = self._Observables
    local Observable = Observables[Name]
    if Observable then return Observable end

    local Signal = Signal.new()
    self._Signals[Name] = Signal

    Observable = (Rx.fromSignal(Signal) :: any):Pipe({
        Rx.start(function()
            local Entry = GetEntry(self, Name)
            return if Entry then Entry.Value else nil
        end),
    }) :: NevermoreTypes.Observable<any?>
    Observables[Name] = Observable
    return Observable
end

local function CreateGlobalEntries(self: RuntimeTypes.ValueStore)
    local GlobalEntries = {}
    for ValueName, Entry in self._Entries do
        GlobalEntries[ValueName] = Entry.Value
    end
    self._GlobalEntries = GlobalEntries
    return GlobalEntries
end

local function GetGlobalEntries(self: RuntimeTypes.ValueStore) return self._GlobalEntries or CreateGlobalEntries(self) end

local function GetGlobalObservable(self: RuntimeTypes.ValueStore)
    local GlobalObservable = self._GlobalObservable
    if GlobalObservable then return GlobalObservable end

    local Signal = Signal.new()
    self._GlobalSignal = Signal

    GlobalObservable = (Rx.fromSignal(Signal) :: any):Pipe({
        Rx.start(function() return GetGlobalEntries(self) end),
    }) :: NevermoreTypes.Observable<{ [string]: any }>
    self._GlobalObservable = GlobalObservable
    CreateGlobalEntries(self)
    return GlobalObservable
end

--[=[
    @method GetObservable
    @within ValueStore
    @param Name string
    @return Observable<any?>
]=]
ValueStore.GetObservable = GetObservable

--[=[
    @method GetGlobalObservable
    @within ValueStore
    @return Observable<{ [string]: any }>
    :::warning
    The global state table is shared and is not cloned.
    By using the observable, you should've known what you're doing.
    :::
]=]
ValueStore.GetGlobalObservable = GetGlobalObservable

--[=[
    @method GetGlobalEntries
    @within ValueStore
    @return { [string]: any }
    :::warning
    The global state table is shared and is not cloned.
    By using the returned table, you should've known what you're doing.
    :::
]=]
ValueStore.GetGlobalEntries = GetGlobalEntries

--[=[
    @method Observe
    @within ValueStore
    @param Name string
    @param Callback (Value: any?) -> ()
    @return Subscription<any?>
]=]
function ValueStore.Observe(
    self: RuntimeTypes.ValueStore,
    Name: string,
    Callback: (Value: any?) -> ()
): NevermoreTypes.Subscription<any?>
    return GetObservable(self, Name):Subscribe(Callback)
end

--[=[
    @method ObserveGlobal
    @within ValueStore
    @param Callback (Entries: { [string]: any }) -> ()
    @return Subscription<{ [string]: any }>
    :::warning
    The global state table is shared and is not cloned.
    By using the observable, you should've known what you're doing.
    :::
]=]
function ValueStore.ObserveGlobal(
    self: RuntimeTypes.ValueStore,
    Callback: (Entries: { [string]: any }) -> ()
): NevermoreTypes.Subscription<{ [string]: any }>
    return GetGlobalObservable(self):Subscribe(Callback)
end

--[=[
    @method Destroy
    @within ValueStore
]=]
function ValueStore.Destroy(self: RuntimeTypes.ValueStore)
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
        self._GlobalEntries = nil
    end

    table.clear(self._Entries)
    table.clear(self._Scopes)
    table.clear(self._Observables)
end

return ValueStore
