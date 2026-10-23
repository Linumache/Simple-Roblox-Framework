local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")

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
        Destroy: (self: ThreadProxy) -> (),
    },
}

export type ThreadProxy = setmetatable<ThreadProxyProps, ThreadProxyMeta>

export type ParallelJob = <A..., R...>(Context: ParallelContext, A...) -> R...

export type ParallelContextProps = {
    _Deadline: number,
    _TimeBudget: number,
}

export type ParallelContextMeta = {
    __index: {
        new: (TimeBudget: number?) -> ParallelContext,
        YieldIfLate: (self: ParallelContext) -> (),
    },
}

export type ParallelContext = setmetatable<ParallelContextProps, ParallelContextMeta>

export type ParallelThreadProps = {
    Actor: Actor,
    Finished: RBXScriptSignal,
    RefCount: number,
}

export type ParallelThreadMeta = {
    __index: {
        new: (RunnerScript: Script, ActorPlace: Instance) -> ParallelThread,
        EnsureReady: (self: ParallelThread) -> (),
        SendMessage: (self: ParallelThread, Topic: string, ...any) -> (),
        OnJobFinished: (
            self: ParallelThread,
            Identity: string,
            Callback: (Succeeded: boolean, ...any) -> ()
        ) -> RBXScriptConnection,
        Destroy: (self: ParallelThread) -> (),
    },
}

export type ParallelThread = setmetatable<ParallelThreadProps, ParallelThreadMeta>

export type ParallelThreadPoolProps = {
    _Pool: { ParallelThread },
    _OrphanedThreads: { [ParallelThread]: true },
    _Size: number,
    _RunnerScript: Script,
    _ActorPlace: Instance,
}

export type ParallelThreadPoolMeta = {
    __index: {
        new: (Size: number?, RunnerScript: Script, ActorPlace: Instance) -> ParallelThreadPool,
        Borrow: (self: ParallelThreadPool) -> (ParallelThread, string),
        Return: (self: ParallelThreadPool, Thread: ParallelThread) -> (),
        Resize: (self: ParallelThreadPool, NewSize: number) -> (),
        Fill: (self: ParallelThreadPool) -> (),
        Destroy: (self: ParallelThreadPool) -> (),
    },
}

export type ParallelThreadPool = setmetatable<ParallelThreadPoolProps, ParallelThreadPoolMeta>

export type ParallelRunnerProps = {
    _Pool: ParallelThreadPool,
    _Maid: NevermoreTypes.Maid,
    _Scheduler: TaskScheduler,
}

export type ParallelRunnerMeta = {
    __index: {
        new: (TaskScheduler: TaskScheduler, ThreadPoolSize: number?) -> ParallelRunner,
        Run: <A..., R...>(
            self: ParallelRunner,
            JobModule: ModuleScript,
            TimeBudget: number?,
            A...
        ) -> NevermoreTypes.Signal<boolean, R...>,
        RunAsync: <A..., R...>(
            self: ParallelRunner,
            JobModule: ModuleScript,
            TimeBudget: number?,
            A...
        ) -> (boolean, R...),
        FillPool: (self: ParallelRunner) -> (),
        SetPoolSize: (self: ParallelRunner, NewSize: number) -> (),
        GetPoolSize: (self: ParallelRunner) -> number,
        Destroy: (self: ParallelRunner) -> (),
    },
}

export type ParallelRunner = setmetatable<ParallelRunnerProps, ParallelRunnerMeta>

export type TaskSchedulerProps = {
    _Maid: NevermoreTypes.Maid,
}

export type TaskSchedulerMeta = {
    __index: {
        new: () -> TaskScheduler,
        Spawn: <A..., R...>(self: TaskScheduler, Task: (A...) -> R..., A...) -> ThreadProxy,
        Defer: <A..., R...>(self: TaskScheduler, Task: (A...) -> R..., A...) -> ThreadProxy,
        Delay: <A..., R...>(self: TaskScheduler, Time: number?, Task: (A...) -> R..., A...) -> ThreadProxy,
        RunTracked: <A..., R...>(self: TaskScheduler, Task: (A...) -> R..., A...) -> R...,
        Wait: (self: TaskScheduler, Time: number) -> number,
        Desynchronize: (self: TaskScheduler) -> (),
        Synchronize: (self: TaskScheduler) -> (),
        Destroy: (self: TaskScheduler) -> (),
    },
}

export type TaskScheduler = setmetatable<TaskSchedulerProps, TaskSchedulerMeta>

--[=[
    @within ValueStore
    @interface StoreEntry
    .Scope ValueScope
    .Value any
]=]
export type StoreEntry = {
    Scope: ValueScope,
    Value: any,
}

export type ValueStoreProps = {
    _Entries: { [string]: StoreEntry },
    _Scopes: { [ValueScope]: { [string]: StoreEntry } },
    _Observables: { [string]: NevermoreTypes.Observable<any?> },
    _Signals: { [string]: NevermoreTypes.Signal },
    _GlobalObservable: NevermoreTypes.Observable<{ [string]: any }>?,
    _GlobalEntries: { [string]: any }?,
    _GlobalSignal: NevermoreTypes.Signal?,
}

export type ValueStoreMeta = {
    __index: {
        new: () -> ValueStore,
        Add: (self: ValueStore, Scope: ValueScope, Name: string, Value: any?) -> (),
        Set: (self: ValueStore, Scope: ValueScope, Name: string, Value: any) -> (),
        Has: (self: ValueStore, Name: string) -> boolean,
        Get: (self: ValueStore, Name: string) -> any,
        Remove: (self: ValueStore, Name: string) -> (),
        RemoveScope: (self: ValueStore, Scope: ValueScope) -> (),
        GetObservable: (self: ValueStore, Name: string) -> NevermoreTypes.Observable<any?>,
        GetGlobalObservable: (self: ValueStore) -> NevermoreTypes.Observable<{ [string]: any }>,
        GetGlobalEntries: (self: ValueStore) -> { [string]: any },
        Observe: (
            self: ValueStore,
            Name: string,
            Callback: (Value: any?) -> ()
        ) -> NevermoreTypes.Subscription<any?>,
        ObserveGlobal: (
            self: ValueStore,
            Callback: (Entries: { [string]: any }) -> ()
        ) -> NevermoreTypes.Subscription<{ [string]: any }>,
        Destroy: (self: ValueStore) -> (),
    },
}

export type ValueStore = setmetatable<ValueStoreProps, ValueStoreMeta>

export type ValueScopeProps = {
    _Store: ValueStore,
}

export type ValueScopeMeta = {
    __index: {
        new: (Store: ValueStore) -> ValueScope,
        Add: (self: ValueScope, Name: string, Value: any?) -> (),
        Set: (self: ValueScope, Name: string, Value: any) -> (),
        Has: (self: ValueScope, Name: string) -> boolean,
        Get: (self: ValueScope, Name: string) -> any,
        Remove: (self: ValueScope, Name: string) -> (),
        GetObservable: (self: ValueScope, Name: string) -> NevermoreTypes.Observable<any?>,
        GetGlobalObservable: (self: ValueScope) -> NevermoreTypes.Observable<{ [string]: any }>,
        GetGlobalEntries: (self: ValueScope) -> { [string]: any },
        Observe: (self: ValueScope, Name: string, Callback: (Value: any?) -> ()) -> NevermoreTypes.Subscription<any?>,
        ObserveGlobal: (
            self: ValueScope,
            Callback: (Entries: { [string]: any }) -> ()
        ) -> NevermoreTypes.Subscription<{ [string]: any }>,
        Destroy: (self: ValueScope) -> (),
    },
}

export type ValueScope = setmetatable<ValueScopeProps, ValueScopeMeta>

export type AppContextProps = {
    Name: string,
    Maid: NevermoreTypes.Maid,
    Scheduler: TaskScheduler,
    Parallel: ParallelRunner,
    Values: ValueScope,
    Services: NevermoreTypes.ServiceBag,
}

export type AppContextMeta = {
    __index: {
        new: (Name: string) -> AppContext,
        MakeMaid: (self: AppContext) -> NevermoreTypes.Maid,
        Destroy: (self: AppContext) -> (),
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
