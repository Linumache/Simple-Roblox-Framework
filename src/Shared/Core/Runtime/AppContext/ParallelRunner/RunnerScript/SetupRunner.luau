local ParallelContext = require("../ParallelContext")
local RuntimeTypes = require("../../../RuntimeTypes")

local function SetupRunner(script: Script)
    local Actor =
        assert(script:GetActor(), "[ParallelRunner] - Unexpected error: script is not a descendant of an actor")
    local FinishedEvent = assert(
        Actor:FindFirstChild("Finished") :: BindableEvent,
        "[ParallelRunner] - Unexpected error: no Finished event"
    )

    Actor:BindToMessage(
        "RunParallelJob",
        function<A..., R...>(JobModule: ModuleScript, Identity: string, TimeBudget: number?, ...: A...)
            local RequireSucceeded, Job: RuntimeTypes.ParallelJob = pcall(require, JobModule)
            if not RequireSucceeded then
                error(`[ParallelRunner] - Failed to require job module '{JobModule:GetFullName()}'`, 0)
            elseif type(Job) ~= "function" then
                FinishedEvent:Fire(Identity, false, "[ParallelRunner] - Job module does not export as a function")
                return
            end

            task.desynchronize()
            local Context = ParallelContext.new(TimeBudget)
            local Result = table.pack(pcall(Job, Context, ...))
            task.synchronize()

            FinishedEvent:Fire(Identity, table.unpack(Result, 1, Result.n))
        end
    )
    Actor:SetAttribute("IsReady", true)
end

return SetupRunner
