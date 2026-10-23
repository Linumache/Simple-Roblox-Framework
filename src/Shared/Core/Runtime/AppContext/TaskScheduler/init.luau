--[=[
    @class TaskScheduler
]=]

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local ThreadProxy = require("@self/ThreadProxy")
local RuntimeTypes = require("../RuntimeTypes")

local Maid = Nevermore("Maid") :: NevermoreTypes.MaidModule

local TaskScheduler = {}
TaskScheduler.__index = TaskScheduler

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
    local Result = table.pack(pcall(Function :: any, ...))
    Maid._tasks[TaskId] = nil

    if not Result[1] then error(Result[2], 0) end
    return table.unpack(Result, 2, Result.n)
end

--[=[
    @within TaskScheduler
    @return TaskScheduler
]=]
--[=[
    @within TaskScheduler
    @prop _Maid Maid
    @private
]=]
function TaskScheduler.new()
    local self = setmetatable({
        _Maid = Maid.new(),
    }, TaskScheduler) :: RuntimeTypes.TaskScheduler
    return self
end

--[=[
    @method Spawn
    @within TaskScheduler
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function TaskScheduler.Spawn<A..., R...>(self: RuntimeTypes.TaskScheduler, Task: (A...) -> R..., ...: A...)
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
    @within TaskScheduler
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function TaskScheduler.Defer<A..., R...>(self: RuntimeTypes.TaskScheduler, Task: (A...) -> R..., ...: A...)
    local Maid = self._Maid

    local Context: Context = {}
    local Thread = task.defer(RunTask, Context, Maid, Task, ...)

    local TaskId = Maid:GiveTask(Thread)
    Context[1] = TaskId
    return ThreadProxy.new(Thread, function() Maid._tasks[TaskId] = nil end)
end

--[=[
    @method Delay
    @within TaskScheduler
    @param Time number?
    @param Task (A...) -> R...
    @param ... A...
    @return ThreadProxy
]=]
function TaskScheduler.Delay<A..., R...>(self: RuntimeTypes.TaskScheduler, Time: number?, Task: (A...) -> R..., ...: A...)
    local Maid = self._Maid

    local Context: Context = {}
    local Thread = task.delay(Time, RunTask, Context, Maid, Task, ...)

    local TaskId = Maid:GiveTask(Thread)
    Context[1] = TaskId
    return ThreadProxy.new(Thread, function() Maid._tasks[TaskId] = nil end)
end

--[=[ 
   @method RunTracked
   @within TaskScheduler
   @param Task (A...) -> R...
   @param ... A...
   @return R...
]=]
function TaskScheduler.RunTracked<A..., R...>(self: RuntimeTypes.TaskScheduler, Task: (A...) -> R..., ...: A...): R...
    return RunTracked(self._Maid, Task, ...)
end

--[=[
    @method Wait
    @within TaskScheduler
    @param Time number
    @return number
    @yields
]=]
function TaskScheduler.Wait<A..., R...>(self: RuntimeTypes.TaskScheduler, Time: number)
    local Maid = self._Maid
    return RunTracked(Maid, task.wait, Time)
end

--[=[
    @method Desynchronize
    @within TaskScheduler
    @yields
]=]
function TaskScheduler.Desynchronize(self: RuntimeTypes.TaskScheduler)
    local Maid = self._Maid
    RunTracked(Maid, task.desynchronize)
end

--[=[
    @method Synchronize
    @within TaskScheduler
    @yields
]=]
function TaskScheduler.Synchronize(self: RuntimeTypes.TaskScheduler)
    local Maid = self._Maid
    RunTracked(Maid, task.synchronize)
end

--[=[
    @method Destroy
    @within TaskScheduler
]=]
function TaskScheduler.Destroy(self: RuntimeTypes.TaskScheduler) self._Maid:Destroy() end

return TaskScheduler
