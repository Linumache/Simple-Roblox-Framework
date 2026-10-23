local Players = game:GetService("Players")

local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

local function Main(Context: AppBuilder.AppContext)
    local LocalPlayer = Players.LocalPlayer
    Context.Maid:GiveTask(
        LocalPlayer.CharacterAdded:Connect(
            function(Character) print("[Example_Client] - CharacterAdded:", Character) end
        )
    )
    Context.Maid:GiveTask(
        LocalPlayer.CharacterRemoving:Connect(
            function(Character) print("[Example_Client] - CharacterRemoving:", Character) end
        )
    )
    print("[Example_Client] - Waiting for character to load...")
end

return AppBuilder.new():WithName("Example_Client"):WithRun(Main)
