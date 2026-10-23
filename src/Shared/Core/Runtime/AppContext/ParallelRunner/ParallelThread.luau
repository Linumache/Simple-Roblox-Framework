--[=[
    @class ParallelThread
]=]

local RuntimeTypes = require("../../RuntimeTypes")

local ParallelThread = {}
ParallelThread.__index = ParallelThread

--[=[
    @within ParallelThread
    @param RunnerScript Script
    @param ActorPlace Instance
    @return ParallelThread
]=]
--[=[
    @within ParallelThread
    @prop Actor Actor
]=]
--[=[
    @within ParallelThread
    @prop Finished RBXScriptSignal
]=]
--[=[
    @within ParallelThread
    @prop RefCount number
]=]
function ParallelThread.new(RunnerScript: Script, ActorPlace: Instance)
    debug.profilebegin("ParallelThread.new")

    local Actor = Instance.new("Actor", ActorPlace)
    RunnerScript = RunnerScript:Clone()
    RunnerScript.Parent = Actor
    RunnerScript.Enabled = true

    local FinishedEvent = Instance.new("BindableEvent", Actor)
    FinishedEvent.Name = "Finished"

    debug.profileend()

    local self = setmetatable({
        RefCount = 0,
        Actor = Actor,
        Finished = FinishedEvent.Event,
    }, ParallelThread) :: RuntimeTypes.ParallelThread
    return self
end

--[=[
    @method EnsureReady
    @within ParallelThread
    @yields
]=]
function ParallelThread.EnsureReady(self: RuntimeTypes.ParallelThread)
    local Actor = self.Actor
    if not Actor:GetAttribute("IsReady") then Actor:GetAttributeChangedSignal("IsReady"):Wait() end
end

--[=[
   @method SendMessage
   @within ParallelThread
   @param Topic string
   @param ... any
]=]
function ParallelThread.SendMessage(self: RuntimeTypes.ParallelThread, Topic: string, ...: any)
    self.Actor:SendMessage(Topic, ...)
end

--[=[
    @method OnJobFinished
    @within ParallelThread
    @param Identity: string
    @param Callback (Succeeded: boolean, ...any) -> ()
    @return RBXScriptConnection
]=]
function ParallelThread.OnJobFinished(
    self: RuntimeTypes.ParallelThread,
    Identity: string,
    Callback: (Succeeded: boolean, ...any) -> ()
)
    local Connection: RBXScriptConnection
    Connection = self.Finished:Connect(function(FinishedIdentity: string, Succeeded: boolean, ...: any)
        if FinishedIdentity == Identity then
            Connection:Disconnect()
            Callback(Succeeded, ...)
        end
    end)
    return Connection
end

--[=[
    @method Destroy
    @within ParallelThread
]=]
function ParallelThread.Destroy(self: RuntimeTypes.ParallelThread) self.Actor:Destroy() end

return ParallelThread
