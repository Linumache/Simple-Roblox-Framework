local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")
local Types = require("../Logger/Types")

export type SignalMemoProps = {
    _Signals: setmetatable<{ [RBXScriptSignal]: NevermoreTypes.Signal }, { __mode: "k" }>,
    _Connections: setmetatable<{ [RBXScriptSignal]: RBXScriptConnection }, { __mode: "k" }>,
    _ParallelSignals: setmetatable<{ [RBXScriptSignal]: NevermoreTypes.Signal }, { __mode: "k" }>,
    _ParallelConnections: setmetatable<{ [RBXScriptSignal]: RBXScriptConnection }, { __mode: "k" }>,
}

export type SignalMemoMeta = {
    __index: {
        new: () -> SignalMemo,
        From: (self: SignalMemo, RBXScriptSignal: RBXScriptSignal) -> NevermoreTypes.Signal,
        FromParallel: (self: SignalMemo, RBXScriptSignal: RBXScriptSignal) -> NevermoreTypes.Signal,
        Destroy: (self: SignalMemo) -> (),
    },
}

export type SignalMemo = setmetatable<SignalMemoProps, SignalMemoMeta>

export type ThreadProxyProps = {
    _Thread: thread,
    _OnCancel: (() -> ())?,
}

export type ThreadProxyMeta = {
    __index: {
        new: (Thread: thread, OnCancel: (() -> ())?) -> ThreadProxy,
        Cancel: (self: ThreadProxy) -> (),
        Resume: <A..., R...>(self: ThreadProxy, A...) -> (boolean, R...),
        Status: (self: ThreadProxy) -> typeof(coroutine.status(coroutine.running())),
        Unwrap: (self: ThreadProxy) -> thread,
    },
}

export type ThreadProxy = setmetatable<ThreadProxyProps, ThreadProxyMeta>

export type ThreadSchedulerProps = {
    _Maid: NevermoreTypes.Maid,
}

export type ThreadSchedulerMeta = {
    __index: {
        new: () -> ThreadScheduler,
        Spawn: <A..., R...>(self: ThreadScheduler, Task: (A...) -> R..., A...) -> ThreadProxy,
        Defer: <A..., R...>(self: ThreadScheduler, Task: (A...) -> R..., A...) -> ThreadProxy,
        Delay: <A..., R...>(self: ThreadScheduler, Time: number?, Task: (A...) -> R..., A...) -> ThreadProxy,
        Wait: (self: ThreadScheduler, Time: number) -> number,
        Desynchronize: (self: ThreadScheduler) -> (),
        Synchronize: (self: ThreadScheduler) -> (),
        Destroy: (self: ThreadScheduler) -> (),
    },
}

export type ThreadScheduler = setmetatable<ThreadSchedulerProps, ThreadSchedulerMeta>

export type FeatureRegistryProps = {
    _States: { [string]: boolean },
    _Observables: { [string]: NevermoreTypes.Observable<boolean> },
    _Signals: { [string]: NevermoreTypes.Signal },
    _GlobalObservable: NevermoreTypes.Observable<{ [string]: boolean }>?,
    _GlobalSignal: NevermoreTypes.Signal?,
}

export type FeatureRegistryMeta = {
    __index: {
        new: () -> FeatureRegistry,
        AddFeature: (self: FeatureRegistry, Name: string, Enabled: boolean?) -> (),
        SetFeatureEnabled: (self: FeatureRegistry, Name: string, Enabled: boolean) -> (),
        SetFeature: (self: FeatureRegistry, Name: string, Enabled: boolean) -> (),
        IsFeature: (self: FeatureRegistry, Name: string) -> boolean,
        IsFeatureEnabled: (self: FeatureRegistry, Name: string) -> boolean,
        Observe: (
            self: FeatureRegistry,
            Name: string,
            Callback: (Enabled: boolean) -> ()
        ) -> NevermoreTypes.Subscription<boolean>,
        ObserveGlobal: (
            self: FeatureRegistry,
            Callback: (States: { [string]: boolean }) -> ()
        ) -> NevermoreTypes.Subscription<{ [string]: boolean }>,
        GetObservable: (self: FeatureRegistry, Name: string) -> NevermoreTypes.Observable<boolean>,
        GetGlobalObservable: (self: FeatureRegistry) -> NevermoreTypes.Observable<{ [string]: boolean }>,
        GetGlobalStates: (self: FeatureRegistry) -> { [string]: boolean },
        Destroy: (self: FeatureRegistry) -> (),
    },
}

export type FeatureRegistry = setmetatable<FeatureRegistryProps, FeatureRegistryMeta>

export type AppContextProps = {
    Name: string,
    Maid: NevermoreTypes.Maid,
    RBXSignal: SignalMemo,
    Scheduler: ThreadScheduler,
    Services: NevermoreTypes.ServiceBag,
}

export type AppContextMeta = {
    __index: {
        new: (Name: string) -> AppContext,
        MakeMaid: (self: AppContext) -> NevermoreTypes.Maid,
        Destroy: (self: AppContext) -> (),
        Features: FeatureRegistry,
        Logger: Types.Logger,
        Nevermore: (string) -> any,
    },
}

export type AppContext = setmetatable<AppContextProps, AppContextMeta>

export type ErrorContextProps = {
    Name: string,
    ErrorMessage: string,
    StackTrace: string,
}

export type ErrorContextMeta = {
    __index: {
        new: (Name: string, ErrorMessage: string, StackTraceLevel: number) -> ErrorContext,
        PrintError: (self: ErrorContext) -> (),
    },
}

export type ErrorContext = setmetatable<ErrorContextProps, ErrorContextMeta>

--[=[
    @interface AppManifest
    @within Runtime
    .Name string -- does not have to be unique
    .Run (Context: AppContext) -> () -- non-yielding
    .OnCrash ((Context: ErrorContext) -> ())?
    .Priority number? -- larger = run earlier. only works in `LaunchBatch`
    .Disabled boolean?
]=]
export type AppManifest = {
    Name: string,
    Run: (Context: AppContext) -> (),
    OnCrash: ((Context: ErrorContext) -> ())?,
    Priority: number?,
    Disabled: boolean?,
}

return nil
