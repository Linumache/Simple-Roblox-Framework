--[=[
    @class AppContext
]=]

local Nevermore = require("../../Packages/Nevermore")
local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")
local ParallelRunner = require("@self/ParallelRunner")
local TaskScheduler = require("@self/TaskScheduler")
local RuntimeTypes = require("./RuntimeTypes")
local ValueScope = require("@self/ValueStore/ValueScope")
local ValueStore = require("@self/ValueStore")

local Maid = Nevermore("Maid") :: NevermoreTypes.MaidModule
local ServiceBag = Nevermore("ServiceBag") :: NevermoreTypes.ServiceBagModule

local AppContext = {}
AppContext.__index = AppContext

local GLOBAL_STORE = ValueStore.new()

--[=[
    @within AppContext
    @prop Nevermore (ModuleName: string) -> any
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
    @prop Scheduler TaskScheduler
]=]
--[=[
    @within AppContext
    @prop Services ServiceBag
]=]
--[=[
    @within AppContext
    @prop Values ValueScope
]=]
--[=[
    @within AppContext
    @prop Parallel ParallelRunner
]=]
function AppContext.new(Name: string)
    local Maid = Maid.new()
    local Scheduler = TaskScheduler.new()
    local Parallel = ParallelRunner.new(Scheduler)
    local Values = ValueScope.new(GLOBAL_STORE)
    local Services = ServiceBag.new() :: NevermoreTypes.ServiceBag

    Maid:GiveTask(Scheduler)
    Maid:GiveTask(Parallel)
    Maid:GiveTask(Values)
    Maid:GiveTask(Services)

    local self = setmetatable({
        Name = Name,
        Maid = Maid,
        Scheduler = Scheduler,
        Parallel = Parallel,
        Values = Values,
        Services = Services,
    }, AppContext) :: RuntimeTypes.AppContext
    return self
end

--[=[
    @method MakeMaid
    @within AppContext
    @return Maid
]=]
function AppContext.MakeMaid(self: RuntimeTypes.AppContext)
    local Maid = Maid.new()
    self.Maid:GiveTask(Maid)
    return Maid
end

--[=[
    @method Destroy
    @within AppContext
]=]
function AppContext.Destroy(self: RuntimeTypes.AppContext) self.Maid:Destroy() end

return AppContext
