local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

return AppBuilder.new()
    :WithName("ConsoleLogging")
    :WithRun(function(Context)
        local LoggerOutput = Context.Logger.Output
        local LogLevels = Context.Logger.LogLevels
        local LogLevelsMap = Context.Logger.LogLevelsMap
        local Maid = Context.Maid

        Context.Features:AddFeature("ConsoleLogging")

        local function MakeOutputFunction(LogLevel: number, Function: (Message: string) -> ())
            local Prefix = `[{LogLevelsMap[LogLevel]}] `

            local function Output(Message: string)
                if Context.Features:IsFeatureEnabled("ConsoleLogging") then pcall(Function, Prefix .. Message) end
            end
            return LogLevel, Output
        end

        Maid:GiveTask(LoggerOutput:Observe(MakeOutputFunction(LogLevels.Trace, print)))
        Maid:GiveTask(LoggerOutput:Observe(MakeOutputFunction(LogLevels.Debug, print)))
        Maid:GiveTask(LoggerOutput:Observe(MakeOutputFunction(LogLevels.Info, print)))
        Maid:GiveTask(LoggerOutput:Observe(MakeOutputFunction(LogLevels.Warn, warn)))
        Maid:GiveTask(
            LoggerOutput:Observe(
                MakeOutputFunction(LogLevels.Error, function(Message: string) task.spawn(error, Message, 0) end)
            )
        )
    end)
    :WithPriority(100)
