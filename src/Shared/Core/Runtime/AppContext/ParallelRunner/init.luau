--[=[
    @class ParallelRunner
]=]

local RunService = game:GetService("RunService")

local Nevermore = require("../../../Packages/Nevermore")
local NevermoreTypes = require("../../../Packages/Nevermore/NevermoreTypes")
local ParallelThreadPool = require("@self/ParallelThreadPool")
local RuntimeTypes = require("../RuntimeTypes")

local Maid = Nevermore("Maid") :: NevermoreTypes.MaidModule
local Signal = Nevermore("Signal") :: NevermoreTypes.SignalModule

local ParallelRunner = {}
ParallelRunner.__index = ParallelRunner

local RunnerScript = if RunService:IsServer()
    then script.RunnerScript.ParallelRunnerServer
    else script.RunnerScript.ParallelRunnerClient

local ActorRoot = if RunService:IsServer() then game:GetService("ServerStorage") else game:GetService("ReplicatedFirst")

local ActorPlace = ActorRoot:FindFirstChild("ParallelThreads") :: Folder
if not ActorPlace then
    ActorPlace = Instance.new("Folder", ActorRoot)
    ActorPlace.Name = "ParallelThreads"
end

--[=[
    @within ParallelRunner
    @param TaskScheduler TaskScheduler
    @param ThreadPoolSize number?
    @return ParallelRunner
]=]
--[=[
    @within ParallelRunner
    @prop _Pool ParallelThreadPool
    @private
]=]
--[=[
    @within ParallelRunner
    @prop _Maid Maid
    @private
]=]
--[=[
    @within ParallelRunner
    @prop _Scheduler TaskScheduler
    @private
]=]
function ParallelRunner.new(TaskScheduler: RuntimeTypes.TaskScheduler, ThreadPoolSize: number?)
    local self = setmetatable({
        _Pool = ParallelThreadPool.new(ThreadPoolSize, RunnerScript, ActorPlace),
        _Maid = Maid.new(),
        _Scheduler = TaskScheduler,
    }, ParallelRunner) :: RuntimeTypes.ParallelRunner
    return self
end

--[=[
    @method Run<A..., R...>
    @within ParallelRunner
    @param JobModule ModuleScript
    @param TimeBudget number?
    @param ... A...
    @return Signal<boolean, R...>
]=]
function ParallelRunner.Run<A..., R...>(self: RuntimeTypes.ParallelRunner, JobModule: ModuleScript, TimeBudget: number?, ...: A...)
    local Maid = self._Maid

    local Thread, Identity = self._Pool:Borrow()
    local Signal = Signal.new()
    local SignalTaskId = Maid:GiveTask(Signal)

    self._Scheduler:Spawn(function(...)
        Thread:EnsureReady()
        Thread:SendMessage("RunParallelJob", JobModule, Identity, TimeBudget, ...)

        local ConnectionTaskId
        ConnectionTaskId = Maid:GiveTask(Thread:OnJobFinished(Identity, function(Succeeded: boolean, ...: R...)
            self._Pool:Return(Thread)
            Signal:Fire(Succeeded, ...)
            Signal:DisconnectAll()

            self._Maid._tasks[SignalTaskId] = nil
            self._Maid._tasks[ConnectionTaskId] = nil
        end))
    end, ...)

    return Signal
end

--[=[
    @method RunAsync<A..., R...>
    @within ParallelRunner
    @param JobModule ModuleScript
    @param TimeBudget number?
    @param ... A...
    @return boolean
    @return R...
    @yields
]=]
function ParallelRunner.RunAsync<A..., R...>(self: RuntimeTypes.ParallelRunner, JobModule: ModuleScript, TimeBudget: number?, ...: A...)
    local Thread, Identity = self._Pool:Borrow()

    Thread:EnsureReady()
    Thread:SendMessage("RunParallelJob", JobModule, Identity, TimeBudget, ...)

    local MainThread = coroutine.running()
    local TaskId
    TaskId = self._Maid:GiveTask(Thread:OnJobFinished(Identity, function(Succeeded: boolean, ...: R...)
        self._Pool:Return(Thread)
        task.spawn(MainThread, Succeeded, ...)

        self._Maid._tasks[TaskId] = nil
    end))

    return self._Scheduler:RunTracked(coroutine.yield)
end

--[=[
   @method FillPool
   @within ParallelRunner
]=]
function ParallelRunner.FillPool(self: RuntimeTypes.ParallelRunner) self._Pool:Fill() end

--[=[
   @method SetPoolSize
   @param NewSize number
   @within ParallelRunner
]=]
function ParallelRunner.SetPoolSize(self: RuntimeTypes.ParallelRunner, NewSize: number) self._Pool:Resize(NewSize) end

--[=[
    @method GetPoolSize
    @within ParallelRunner
    @return number
]=]
function ParallelRunner.GetPoolSize(self: RuntimeTypes.ParallelRunner) return self._Pool._Size end

--[=[
    @method Destroy
    @within ParallelRunner
]=]
function ParallelRunner.Destroy(self: RuntimeTypes.ParallelRunner)
    self._Pool:Destroy()
    self._Maid:Destroy()
end

return ParallelRunner
