--[=[
    @class Nevermore
    This module is used to load Nevermore packages conveniently.

    You can access it through the app context:
    ```lua
    function(Context: AppContext)
        local Rx = Context.Nevermore("Rx")
        -- ...
    end
    ```
    or alternatively:
    ```lua
    local Nevermore = require("@game/ReplicatedStorage/src/Shared/Packages/Nevermore")

    local Rx = Nevermore("Rx")
    -- ...
    ```
]=]

--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local function GetNodeModules(IsServer: boolean): Instance
    return if IsServer then ServerScriptService.node_modules else ReplicatedStorage:WaitForChild("node_modules")
end

local function GetLoader(NodeModules: Instance) return (require)((NodeModules :: any)["@quenty"].loader) end

local NodeModules = GetNodeModules(RunService:IsServer())
local Loader = GetLoader(NodeModules)

return Loader.bootstrapGame(NodeModules) :: (string) -> any
