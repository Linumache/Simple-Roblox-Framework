--[=[
    @class ValueScope
]=]

local RuntimeTypes = require("../../RuntimeTypes")

local ValueScope = {}
ValueScope.__index = ValueScope

--[=[
    @within ValueScope
    @param Store ValueStore
    @return ValueScope
]=]
--[=[
    @within ValueScope
    @prop _Store ValueStore
    @private
]=]
function ValueScope.new(Store: RuntimeTypes.ValueStore)
    local self = setmetatable({
        _Store = Store,
    }, ValueScope) :: RuntimeTypes.ValueScope
    return self
end

--[=[
    @method Add
    @within ValueScope
    @param Name string
    @param Value any?
    > Wrapper for `ValueStore.Add`.

    Create an entry for a value if it doesn't exist.
]=]
function ValueScope.Add(self: RuntimeTypes.ValueScope, Name: string, Value: any?) self._Store:Add(self, Name, Value) end

--[=[
    @method Set
    @within ValueScope
    @param Name string
    @param Value any
    > Wrapper for `ValueStore.Set`.

    Set an entry's value, or create one if it doesn't exist.
]=]
function ValueScope.Set(self: RuntimeTypes.ValueScope, Name: string, Value: any) self._Store:Set(self, Name, Value) end

--[=[
    @method Has
    @within ValueScope
    @param Name string
    @return boolean
    > Wrapper for `ValueStore.Has`.
]=]
function ValueScope.Has(self: RuntimeTypes.ValueScope, Name: string) return self._Store:Has(Name) end

--[=[ 
   @method Get
   @within ValueScope
   @param Name string
   @return any
   > Wrapper for `ValueStore.Get`.
]=]
function ValueScope.Get(self: RuntimeTypes.ValueScope, Name: string) return self._Store:Get(Name) end

--[=[
    @method Remove
    @within ValueScope
    @param Name string
    > Wrapper for `ValueStore.Remove`.
]=]
function ValueScope.Remove(self: RuntimeTypes.ValueScope, Name: string) self._Store:Remove(Name) end

--[=[
    @method GetObservable
    @within ValueScope
    @param Name string
    @return Observable<any?>
    > Wrapper for `ValueStore.GetObservable`.
]=]
function ValueScope.GetObservable(self: RuntimeTypes.ValueScope, Name: string) return self._Store:GetObservable(Name) end

--[=[
    @method GetGlobalObservable
    @within ValueScope
    @return Observable<{ [string]: any }>
    > Wrapper for `ValueStore.GetGlobalObservable`.
]=]
function ValueScope.GetGlobalObservable(self: RuntimeTypes.ValueScope) return self._Store:GetGlobalObservable() end

--[=[
    @method GetGlobalEntries
    @within ValueScope
    @return { [string]: any }
    > Wrapper for `ValueStore.GetGlobalEntries`.
]=]
function ValueScope.GetGlobalEntries(self: RuntimeTypes.ValueScope) return self._Store:GetGlobalEntries() end

--[=[
    @method Observe
    @within ValueScope
    @param Name string
    @param Callback (Value: any?) -> ()
    @return Subscription<any?>
    > Wrapper for `ValueStore.Observe`.
]=]
function ValueScope.Observe(self: RuntimeTypes.ValueScope, Name: string, Callback: (Value: any?) -> ())
    return self._Store:Observe(Name, Callback)
end

--[=[
    @method ObserveGlobal
    @within ValueScope
    @param Callback (Entries: { [string]: any }) -> ()
    @return Subscription<{ [string]: any }>
    > Wrapper for `ValueStore.ObserveGlobal`.
]=]
function ValueScope.ObserveGlobal(self: RuntimeTypes.ValueScope, Callback: (Entries: { [string]: any }) -> ())
    return self._Store:ObserveGlobal(Callback)
end

--[=[
    @method Destroy
    @within ValueScope
    > Wrapper for `ValueStore.RemoveScope`.
]=]
function ValueScope.Destroy(self: RuntimeTypes.ValueScope) self._Store:RemoveScope(self) end

return ValueScope
