--[=[
    @class AppContext
]=]

local FeatureRegistry = require("@self/FeatureRegistry")
local Logger = require("../Logger")
local Nevermore = require("../../Packages/Nevermore")
local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")
local SignalMemo = require("@self/SignalMemo")
local ThreadScheduler = require("@self/ThreadScheduler")
local Types = require("./Types")

local Maid = Nevermore("Maid") :: NevermoreTypes.MaidModule
local ServiceBag = Nevermore("ServiceBag") :: NevermoreTypes.ServiceBagModule

local AppContext = {}
AppContext.__index = AppContext

--[=[
    @within AppContext
    @prop Features FeatureRegistry
    @tag global
]=]
AppContext.Features = FeatureRegistry.new()
--[=[
    @within AppContext
    @prop Logger Logger
    @tag global
]=]
AppContext.Logger = Logger.new()
--[=[
    @within AppContext
    @prop Nevermore (string) -> any
    @tag global
    Requires an installed Nevermore package module.
]=]
AppContext.Nevermore = Nevermore

--[=[
    @within AppContext
    @param Name string
    @return AppContext
]=]
--[=[
    @within AppContext
    @prop Name string
]=]
--[=[
    @within AppContext
    @prop Maid Maid
]=]
--[=[
    @within AppContext
    @prop RBXSignal SignalMemo
]=]
--[=[
    @within AppContext
    @prop Scheduler ThreadScheduler
]=]
--[=[
    @within AppContext
    @prop Services ServiceBag
]=]
function AppContext.new(Name: string)
    local Maid = Maid.new()
    local RBXSignal = SignalMemo.new()
    local Scheduler = ThreadScheduler.new()
    local Services = ServiceBag.new() :: NevermoreTypes.ServiceBag

    Maid:GiveTask(RBXSignal)
    Maid:GiveTask(Scheduler)
    Maid:GiveTask(Services)

    local self = setmetatable({
        Name = Name,
        Maid = Maid,
        RBXSignal = RBXSignal,
        Scheduler = Scheduler,
        Services = Services,
    }, AppContext) :: Types.AppContext
    return self
end

--[=[
    @method MakeMaid
    @within AppContext
    @return Maid
]=]
function AppContext.MakeMaid(self: Types.AppContext)
    local Maid = Maid.new()
    self.Maid:GiveTask(Maid)
    return Maid
end

--[=[
    @method Destroy
    @within AppContext
]=]
function AppContext.Destroy(self: Types.AppContext) self.Maid:Destroy() end

return AppContext
