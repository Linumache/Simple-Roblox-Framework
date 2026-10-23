--[=[
    @class Runtime
    @external Maid https://quenty.github.io/NevermoreEngine/api/Maid
    @external Signal https://quenty.github.io/NevermoreEngine/api/Signal
    @external Observable https://quenty.github.io/NevermoreEngine/api/Observable
    @external Subscription https://quenty.github.io/NevermoreEngine/api/Subscription
    @external ServiceBag https://quenty.github.io/NevermoreEngine/api/ServiceBag
]=]

local AppContext = require("@self/AppContext")
local ErrorContext = require("@self/ErrorContext")
local RuntimeTypes = require("@self/RuntimeTypes")

--[=[
    @within Runtime
    @prop Version { Major: number, Minor: number, Patch: number }
    @tag global
    @readonly
]=]
local Runtime = {
    Version = table.freeze({
        Major = 2,
        Minor = 1,
        Patch = 0,
    }),
}

--[=[
    @within Runtime
    @param AppManifest AppManifest
    @return boolean
    @return AppContext | ErrorContext
]=]
function Runtime.Launch(
    AppManifest: RuntimeTypes.AppManifest
): (boolean, RuntimeTypes.AppContext | RuntimeTypes.ErrorContext)
    local Name = AppManifest.Name
    if type(Name) ~= "string" then error("[Runtime] - Launch: bad manifest field `Name`", 0) end
    local Run = AppManifest.Run
    if type(Run) ~= "function" then error("[Runtime] - Launch: bad manifest field `Run`", 0) end

    local AppContext = AppContext.new(Name)
    if AppManifest.Disabled then return true, AppContext end

    local Succeeded, _ErrorContext: RuntimeTypes.ErrorContext

    local Thread = task.spawn(function()
        Succeeded, _ErrorContext = xpcall(Run :: any, function(Error: string)
            pcall(AppContext.Destroy, AppContext)

            local ErrorContext = ErrorContext.new(Name, Error, 2)
            local OnCrash = AppManifest.OnCrash
            if OnCrash then
                local Thread = task.spawn(OnCrash, ErrorContext)
                if coroutine.status(Thread) ~= "dead" then task.cancel(Thread) end
            else
                ErrorContext:PrintError()
            end

            return ErrorContext
        end, AppContext)
    end)

    if coroutine.status(Thread) ~= "dead" then
        task.cancel(Thread)
        pcall(AppContext.Destroy, AppContext)
        error("[Runtime] - Launch: `AppManifest.Run` should not yield", 0)
    end

    if Succeeded then return true, AppContext end
    return false, _ErrorContext
end

--[=[
    @within Runtime
    @param Apps { any | Instance | AppManifest }
    @return { AppContext }
    @return { ErrorContext }
    @return number -- detected manifest count
]=]
function Runtime.LaunchBatch(Apps: { any | Instance | RuntimeTypes.AppManifest })
    local AppContexts: { RuntimeTypes.AppContext } = {}
    local ErrorContexts: { RuntimeTypes.ErrorContext } = {}

    local AppManifests: { RuntimeTypes.AppManifest } = {}

    for _, App in Apps do
        if type(App) ~= "table" then
            if not App:IsA("ModuleScript") then continue end

            local RequireSucceeded, AppManifest = pcall(require, App)
            if not RequireSucceeded then
                warn(`[Runtime] - LaunchBatch: error requiring app '{App:GetFullName()}': {AppManifest}`)
                continue
            elseif type(AppManifest) ~= "table" then
                warn(`[Runtime] - LaunchBatch: malformed app manifest at '{App:GetFullName()}'`)
                continue
            end

            App = AppManifest
        end

        AppManifests[#AppManifests + 1] = App
    end

    table.sort(
        AppManifests :: any,
        function(A: RuntimeTypes.AppManifest, B: RuntimeTypes.AppManifest) return (A.Priority or 0) > (B.Priority or 0) end
    )

    for _, AppManifest in AppManifests do
        local LaunchSucceeded, RunSucceeded, Context = pcall(Runtime.Launch, AppManifest)
        if not LaunchSucceeded then
            warn(`[Runtime] - LaunchBatch: error launching app '{AppManifest.Name}': {RunSucceeded}`)
            continue
        end

        if RunSucceeded then
            AppContexts[#AppContexts + 1] = Context
        else
            ErrorContexts[#ErrorContexts + 1] = Context
        end
    end

    return AppContexts, ErrorContexts, #AppManifests
end

--[=[
    @within Runtime
    @param SelfAppContext AppContext
    @param SubAppManifest AppManifest
    @return boolean
    @return AppContext | ErrorContext
]=]
function Runtime.LaunchSubApp(SelfAppContext: RuntimeTypes.AppContext, SubAppManifest: RuntimeTypes.AppManifest)
    local Succeeded, SubContext = Runtime.Launch(SubAppManifest)
    if Succeeded then SelfAppContext.Maid:GiveTask(SubContext) end
    return Succeeded, SubContext
end

return Runtime
