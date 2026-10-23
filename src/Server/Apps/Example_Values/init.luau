local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

local function Main(Context: AppBuilder.AppContext)
    Context.Values:Observe(
        "TestMessage",
        function(Value) print("[Example_Values] - TestMessage changed to:", Value) end
    )
    Context.Values:Add("TestMessage", "this is an example, and it works!")
    Context.Values:Remove("TestMessage")
    Context.Values:Set("TestMessage", "this is the second example?")
end

return AppBuilder.new():WithName("Example_Values"):WithRun(Main):WithPriority(1)
