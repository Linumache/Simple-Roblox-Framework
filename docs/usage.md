---
sidebar_position: 3
---

### [API Types](/api)

### Adding an App

1. Navigate to `src/{Server|Client}/Apps`.
2. Create a new folder with the name of your app.
3. Create an `init.luau` file in the folder.
4. Update the file to return an [`AppManifest`](/api/Runtime#AppManifest), which looks like:
```lua
{
    Name: string, -- does not have to be unique
    Run: (Context: AppContext) -> (), -- non-yielding
    OnCrash: ((Context: ErrorContext) -> ())?,
    Priority: number?, -- larger = run earlier
    Disabled: boolean?,
}
```
