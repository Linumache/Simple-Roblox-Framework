# Simple-Roblox-Framework

Yet another simple and flexible framework template for Roblox games and projects that provides essential lifecycle management and miscellaneous utilities, built on and designed to work with [NevermoreEngine](https://github.com/Quenty/NevermoreEngine).

**&gt; [View the documentation site](https://Linumache.github.io/Simple-Roblox-Framework) &lt;**

## Setup

### Create a Project Using This Template

1. Go to [the github page](https://github.com/Linumache/Simple-Roblox-Framework) of this repository.
2. Click `Use this template` > `Create a new repository`.
3. Replace the word `Simple-Roblox-Framework` in `default.project.json` and `package.json` with your project name.

### Install Dependencies

1. Install [pnpm](https://pnpm.io/installation) version >= `10.x`.
2. Install the latest version of [foreman](https://github.com/Roblox/foreman#installation).
4. Run `pnpm i`, and ignore the error `ERR_PNPM_IGNORED_BUILDS` if encountered.
5. Run `foreman install`.

### Configure Rojo Auto-startup (Optional)

1. Open the workspace in vscode.
2. Use `Ctrl+Shift+P` to open the command palette.
3. Select `Tasks: Manage Automatic Tasks` > `Allow Automatic Tasks`.

## Usage

### API Types

- [**Runtime**](/src/Shared/Core/Runtime/Types.luau)
- [**Logger**](/src/Shared/Core/Logger/Types.luau)

### Adding an App

1. Navigate to `src/{Server|Client}/Apps`.
2. Create a new folder with the name of your app.
3. Create an `init.luau` file in the folder.
4. Update the file to return an `AppManifest`, which looks like:
```lua
{
    Name: string, -- does not have to be unique
    Run: (Context: AppContext) -> (), -- non-yielding
    OnCrash: ((Context: ErrorContext) -> ())?,
    Priority: number?, -- larger = run earlier
    Disabled: boolean?,
}
```
(refers to [src/Shared/Core/Runtime/Types.luau#L128](/src/Shared/Core/Runtime/Types.luau#L128))

## Examples

### A Minimal App

```lua
local AppBuilder = require("@game/ReplicatedStorage/src/Modules/App/AppBuilder")

return AppBuilder.new()
```

### Built-in Example App

```lua
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
```
(refers to [src/Server/Apps/Example/init.luau](/src/Server/Apps/Example/init.luau))

### Built-in ConsoleLogging App

```lua
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
```
(refers to [src/Server/Apps/ConsoleLogging/init.luau](/src/Server/Apps/ConsoleLogging/init.luau))

### Using Nevermore Packages

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
