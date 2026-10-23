local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")
local TestService = require("@self/TestService")

local function Main(Context: AppBuilder.AppContext)
    local TestService = Context.Services:GetService(TestService)
    Context.Services:Init()
    Context.Services:Start()
    print("[Example_Services] - TestService.Log10():", TestService.Log10())
end

return AppBuilder.new():WithName("Example_Services"):WithRun(Main):WithPriority(2)
