local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

local function Main(Context: AppBuilder.AppContext)
    local function PrintResult(...) print("[Example_Parallel] - Job result:", ...) end

    local function RunParallelAsync() PrintResult(Context.Parallel:RunAsync(script.Job, nil, "one", "two")) end
    local function RunParallel() Context.Parallel:Run(script.Job, nil, "one", "two"):Once(PrintResult) end

    print("[Example_Parallel] - Running jobs in 2.1s...")
    Context.Scheduler:Delay(2.1, function()
        Context.Scheduler:Spawn(RunParallelAsync)
        Context.Scheduler:Spawn(RunParallelAsync)
        Context.Scheduler:Spawn(RunParallel)
        Context.Scheduler:Spawn(RunParallel)
    end)
    Context.Parallel:FillPool()
    Context.Parallel:SetPoolSize(8)
    print("[Example_Parallel] - ParallThreadPool size:", Context.Parallel:GetPoolSize())
end

return AppBuilder.new():WithName("Example_Parallel"):WithRun(Main):WithPriority(4)
