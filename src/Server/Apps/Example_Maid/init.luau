local Players = game:GetService("Players")

local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

local function Main(Context: AppBuilder.AppContext)
    local PlayersMaid = Context:MakeMaid()
    PlayersMaid:GiveTask(
        Players.PlayerAdded:Connect(function(Player) print("[Example_Maid] - PlayerAdded:", Player) end)
    )
    PlayersMaid:GiveTask(
        Players.PlayerRemoving:Connect(function(Player) print("[Example_Maid] - PlayerRemoving:", Player) end)
    )
    print("[Example_Maid] - Monitoring players...")
    Context.Maid:GiveTask(function() print("[Example_Maid] - App is shutting down...") end)
end

return AppBuilder.new():WithName("Example_Maid"):WithRun(Main):WithPriority(5)
