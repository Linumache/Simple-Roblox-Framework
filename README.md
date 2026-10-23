# Simple-Roblox-Framework

Yet another simple and flexible framework template for Roblox games and projects that provides essential lifecycle management, parallel support and miscellaneous utilities, built on and designed to work with [NevermoreEngine](https://github.com/Quenty/NevermoreEngine).

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

### [API List](https://Linumache.github.io/Simple-Roblox-Framework/api)

- **Core**
    - **[Runtime](/src/Shared/Core/Runtime/init.luau)**
        - **[AppContext](/src/Shared/Core/Runtime/AppContext/init.luau)**
            - **[ParallelRunner](/src/Shared/Core/Runtime/AppContext/ParallelRunner.luau)**
                - **[ParallelContext](/src/Shared/Core/Runtime/AppContext/ParallelRunner/ParallelContext.luau)**
                - **[ParallelThread](/src/Shared/Core/Runtime/AppContext/ParallelRunner/ParallelThread.luau)**
                - **[ParallelThreadPool](/src/Shared/Core/Runtime/AppContext/ParallelRunner/ParallelThreadPool.luau)**
            - **[TaskScheduler](/src/Shared/Core/Runtime/AppContext/TaskScheduler.luau)**
                - **[ThreadProxy](/src/Shared/Core/Runtime/AppContext/ThreadProxy.luau)**
            - **[ValueStore](/src/Shared/Core/Runtime/AppContext/ValueStore.luau)**
                - **[ValueScope](/src/Shared/Core/Runtime/AppContext/ValueScope.luau)**
        - **[ErrorContext](/src/Shared/Core/Runtime/ErrorContext/init.luau)**
        - **[RuntimeConstants](/src/Shared/Core/Runtime/RuntimeConstants.luau)**
- **Modules**
    - **App**
        - **[AppBuilder](/src/Shared/Modules/App/AppBuilder.luau)**
- **Packages**
    - **[Nevermore](/src/Shared/Packages/Nevermore/init.luau)**

### Adding an App

1. Navigate to `src/{Server|Client}/Apps`.
2. Create a new folder with the name of your app.
3. Create an `init.luau` file in the folder.
4. Update the file to return an [`AppManifest`](https://Linumache.github.io/Simple-Roblox-Framework/api/Runtime#AppManifest), which looks like:
```lua
{
    Name: string, -- does not have to be unique
    Run: (Context: AppContext) -> (), -- non-yielding
    OnCrash: ((Context: ErrorContext) -> ())?,
    Priority: number?, -- larger = run earlier
    Disabled: boolean?,
}
```

## Examples

See example apps at [Apps](/src/Server/Apps)
