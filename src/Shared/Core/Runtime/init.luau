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
local Types = require("@self/Types")

local Runtime = {}

--[=[
    @within Runtime
    @param AppManifest AppManifest
    @return boolean
    @return AppContext | ErrorContext
]=]
function Runtime.Launch(AppManifest: Types.AppManifest): (boolean, Types.AppContext | Types.ErrorContext)
    local Name = AppManifest.Name
    assert(type(Name) == "string", "[Runtime] - Launch: bad manifest field `Name`")
    local Run = AppManifest.Run
    assert(type(Run) == "function", "[Runtime] - Launch: bad manifest field `Run`")

    local AppContext = AppContext.new(Name)
    if AppManifest.Disabled then return true, AppContext end

    local Succeeded, _ErrorContext: Types.ErrorContext

    local Thread = task.spawn(function()
        Succeeded, _ErrorContext = xpcall(Run :: any, function(Error: string)
            pcall(AppContext.Destroy, AppContext)

            local ErrorContext = ErrorContext.new(Name, Error, 2)
            local OnCrash = AppManifest.OnCrash
            if OnCrash then
                pcall(OnCrash, ErrorContext)
            else
                ErrorContext:PrintError()
            end

            return ErrorContext
        end, AppContext)
    end)

    if coroutine.status(Thread) ~= "dead" then
        task.cancel(Thread)
        error("[Runtime] - Launch: `Run` should not yield")
    end

    if Succeeded then return true, AppContext end
    return false, _ErrorContext
end

--[=[
    @within Runtime
    @param Apps { Instance }
    @return { AppContext }
    @return { ErrorContext }
]=]
function Runtime.LaunchBatch(Apps: { Instance })
    local AppContexts: { Types.AppContext } = {}
    local ErrorContexts: { Types.ErrorContext } = {}

    local AppManifests: { Types.AppManifest } = {}

    for _, App in Apps do
        if not App:IsA("ModuleScript") then continue end

        local RequireSucceeded, AppManifest = pcall(require, App)
        if not RequireSucceeded then
            warn(`[Runtime] - LaunchBatch: error requiring app '{App:GetFullName()}': {AppManifest}`)
            continue
        elseif type(AppManifest) ~= "table" then
            warn(`[Runtime] - LaunchBatch: malformed app manifest at '{App:GetFullName()}'`)
            continue
        end

        AppManifests[#AppManifests + 1] = AppManifest
    end

    table.sort(
        AppManifests :: any,
        function(A: Types.AppManifest, B: Types.AppManifest) return (A.Priority or 0) > (B.Priority or 0) end
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

    return AppContexts, ErrorContexts
end

return Runtime
