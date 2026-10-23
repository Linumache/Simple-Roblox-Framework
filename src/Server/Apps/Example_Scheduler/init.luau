local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

local function Main(Context: AppBuilder.AppContext)
    Context.Scheduler:Spawn(function() print("[Example_Scheduler] - task.spawn") end)
    Context.Scheduler:Defer(function() print("[Example_Scheduler] - task.defer") end)
    Context.Scheduler:Delay(1, function() print("[Example_Scheduler] - task.delay(1)") end)
    Context.Scheduler:Spawn(function()
        Context.Scheduler:Wait(2)
        print("[Example_Scheduler] - task.wait(2)")
        Context.Maid:GiveTask(Instance.new("Fire", workspace))
    end)
    -- Context.Scheduler:Desynchronize()
    -- Context.Scheduler:Synchronize()
    Context.Scheduler:Spawn(function()
        Context.Scheduler:RunTracked(
            function() print("[Example_Scheduler] - RunTracked:", workspace:WaitForChild("Fire")) end
        )
    end)
end

return AppBuilder.new():WithName("Example_Scheduler"):WithRun(Main):WithPriority(3)
