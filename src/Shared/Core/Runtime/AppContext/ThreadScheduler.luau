--[=[
    @class ThreadScheduler
]=]

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local ThreadProxy = require("./ThreadProxy")
local Types = require("../Types")

local Maid = Nevermore("Maid") :: NevermoreTypes.MaidModule

local ThreadScheduler = {}
ThreadScheduler.__index = ThreadScheduler

type ImmediateContext = typeof({
    [1] = true, -- NotCompleted
    [2] = 1 :: number?, -- TaskId
})

type Context = typeof({
    [1] = 1 :: number, -- TaskId
})

local function ImmediateRunTask<A..., R...>(Context: ImmediateContext, Maid: NevermoreTypes.Maid, Task: (A...) -> R..., ...: A...)
    local Succeeded, StackTrace = xpcall(Task :: any, debug.traceback :: any, ...)

    Context[1] = false
    local TaskId = Context[2]
    if TaskId then Maid._tasks[TaskId] = nil end

    if not Succeeded then task.spawn(error, StackTrace, 0) end
end

local function RunTask<A..., R...>(Context: Context, Maid: NevermoreTypes.Maid, Task: (A...) -> R..., ...: A...)
    local Succeeded, StackTrace = xpcall(Task :: any, debug.traceback :: any, ...)

    local TaskId = Context[1]
    Maid._tasks[TaskId] = nil

    if not Succeeded then task.spawn(error, StackTrace, 0) end
end

local function RunTracked<A..., R...>(Maid: NevermoreTypes.Maid, Function: (A...) -> R..., ...: A...): R...
    local TaskId = Maid:GiveTask(coroutine.running())
    local Succeeded, Result = pcall(Function :: any, ...)
    Maid._tasks[TaskId] = nil

    if not Succeeded then error(Result, 0) end
    return Result
end

--[=[
    @within ThreadScheduler
    @return ThreadScheduler
]=]
--[=[
    @within ThreadScheduler
    @prop _Maid Maid
    @private
]=]
function ThreadScheduler.new()
    local self = setmetatable({
        _Maid = Maid.new(),
    }, ThreadScheduler) :: Types.ThreadScheduler
    return self
end

--[=[
    @method Spawn
    @within ThreadScheduler
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function ThreadScheduler.Spawn<A..., R...>(self: Types.ThreadScheduler, Task: (A...) -> R..., ...: A...)
    local Maid = self._Maid

    local Context: ImmediateContext = { true }
    local Thread = task.spawn(ImmediateRunTask, Context, Maid, Task, ...)

    if Context[1] then
        local TaskId = Maid:GiveTask(Thread)
        Context[2] = TaskId
        return ThreadProxy.new(Thread, function() Maid._tasks[TaskId] = nil end)
    end

    return ThreadProxy.new(Thread)
end

--[=[
    @method Defer
    @within ThreadScheduler
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function ThreadScheduler.Defer<A..., R...>(self: Types.ThreadScheduler, Task: (A...) -> R..., ...: A...)
    local Maid = self._Maid

    local Context: Context = {}
    local Thread = task.defer(RunTask, Context, Maid, Task, ...)

    local TaskId = Maid:GiveTask(Thread)
    Context[1] = TaskId
    return ThreadProxy.new(Thread, function() Maid[TaskId] = nil end)
end

--[=[
    @method Delay
    @within ThreadScheduler
    @param Time number?
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function ThreadScheduler.Delay<A..., R...>(self: Types.ThreadScheduler, Time: number?, Task: (A...) -> R..., ...: A...)
    local Maid = self._Maid

    local Context: Context = {}
    local Thread = task.delay(Time, RunTask, Context, Maid, Task, ...)

    local TaskId = Maid:GiveTask(Thread)
    Context[1] = TaskId
    return ThreadProxy.new(Thread, function() Maid[TaskId] = nil end)
end

--[=[
    @method Wait
    @within ThreadScheduler
    @param Time number
    @return number
]=]
function ThreadScheduler.Wait<A..., R...>(self: Types.ThreadScheduler, Time: number)
    local Maid = self._Maid
    return RunTracked(Maid, task.wait, Time)
end

--[=[
    @method Desynchronize
    @within ThreadScheduler
]=]
function ThreadScheduler.Desynchronize(self: Types.ThreadScheduler)
    local Maid = self._Maid
    RunTracked(Maid, task.desynchronize)
end

--[=[
    @method Synchronize
    @within ThreadScheduler
]=]
function ThreadScheduler.Synchronize(self: Types.ThreadScheduler)
    local Maid = self._Maid
    RunTracked(Maid, task.synchronize)
end

--[=[
    @method Destroy
    @within ThreadScheduler
]=]
function ThreadScheduler.Destroy(self: Types.ThreadScheduler) self._Maid:Destroy() end

return ThreadScheduler
