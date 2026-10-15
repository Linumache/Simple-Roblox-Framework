local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

return AppBuilder.new()
    :WithName("Example")
    :WithRun(function(Context)
        local Logger = Context.Logger
        local Features = Context.Features

        Logger:Debug("Hello World!")
        Logger:Error("gg so ez \u{E000}\u{E000}\u{E000}")
        Features:SetFeatureEnabled("ConsoleLogging", false)
        Logger:Warn("meowing")
    end)
