--[=[
    @class AppBuilder
    Construct the AppManifest quickly using the fluent interface.
]=]

local Types = require("../../Core/Runtime/Types")

type Run = index<Types.AppManifest, "Run">
type OnCrash = index<Types.AppManifest, "OnCrash">

--[=[
    @within AppBuilder
    @type AppManifest AppManifest
]=]
export type AppManifest = Types.AppManifest
--[=[
    @within AppBuilder
    @type AppContext AppContext
]=]
export type AppContext = Types.AppContext

local AppBuilder = {}
AppBuilder.__index = AppBuilder

export type AppBuilder = typeof(AppBuilder.new())

--[=[
    @within AppBuilder
    @return AppBuilder
]=]
--[=[
    @within AppBuilder
    @prop Name string
]=]
--[=[
    @within AppBuilder
    @prop Run (Context: AppContext) -> ()
]=]
--[=[
    @within AppBuilder
    @prop OnCrash ((Context: ErrorContext) -> ())?
]=]
--[=[
    @within AppBuilder
    @prop Priority number?
]=]
--[=[
    @within AppBuilder
    @prop Disabled boolean?
]=]
function AppBuilder.new()
    local self = setmetatable({
        Name = "Unnamed App",
        Run = function() end :: Run,
        OnCrash = nil :: OnCrash,
        Priority = nil :: number?,
        Disabled = nil :: boolean?,
    }, AppBuilder)
    return self
end

--[=[
    @method WithName
    @within AppBuilder
    @param Name string
    @return AppBuilder
]=]
function AppBuilder.WithName(self: AppBuilder, Name: string)
    self.Name = Name
    return self
end

--[=[
    @method WithRun
    @within AppBuilder
    @param Run (Context: AppContext) -> ()
    @return AppBuilder
]=]
function AppBuilder.WithRun(self: AppBuilder, Run: Run)
    self.Run = Run
    return self
end

--[=[
    @method WithOnCrash
    @within AppBuilder
    @param OnCrash ((Context: ErrorContext) -> ())?
    @return AppBuilder
]=]
function AppBuilder.WithOnCrash(self: AppBuilder, OnCrash: OnCrash)
    self.OnCrash = OnCrash
    return self
end

--[=[
    @method WithPriority
    @within AppBuilder
    @param Priority number?
    @return AppBuilder
]=]
function AppBuilder.WithPriority(self: AppBuilder, Priority: number?)
    self.Priority = Priority
    return self
end

--[=[
    @method WithDisabled
    @within AppBuilder
    @param Disabled boolean?
    @return AppBuilder
]=]
function AppBuilder.WithDisabled(self: AppBuilder, Disabled: boolean?)
    self.Disabled = Disabled
    return self
end

return AppBuilder
