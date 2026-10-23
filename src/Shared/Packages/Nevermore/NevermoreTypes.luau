export type MaidTask = (() -> ()) | Instance | thread | any | RBXScriptConnection | nil

export type Maid = typeof(setmetatable(
    {} :: {
        Add: <T>(self: Maid, task: T) -> T,
        GiveTask: (self: Maid, task: MaidTask) -> number,
        GivePromise: <T>(self: Maid, promise: T) -> T,
        DoCleaning: (self: Maid) -> (),
        Destroy: (self: Maid) -> (),
        _tasks: { [any]: MaidTask },
        [string | number | MaidTask]: any,
    },
    {} :: {
        __index: {
            ClassName: "Maid",
            new: () -> Maid,
            isMaid: (value: any) -> boolean,
            Add: <T>(self: Maid, task: T) -> T,
            GiveTask: (self: Maid, task: MaidTask) -> number,
            GivePromise: (self: Maid, promise: any) -> any,
            DoCleaning: (self: Maid) -> (),
            Destroy: (self: Maid) -> (),
            [any]: any,
        },
    }
))

export type SignalHandler = (...any) -> ()

export type Connection<T...> = typeof(setmetatable(
    {} :: {
        _memoryCategory: string,
        _signal: Signal<T...>?,
        _fn: SignalHandler?,
    },
    {} :: {
        __index: {
            ClassName: "Connection",
            new: (signal: Signal<T...>, fn: SignalHandler) -> Connection<T...>,
            IsConnected: (self: Connection<T...>) -> boolean,
            Disconnect: (self: Connection<T...>) -> (),
            Destroy: (self: Connection<T...>) -> (),
        },
    }
))

export type Signal<T... = ...any> = typeof(setmetatable(
    {} :: {
        _handlerListHead: Connection<T...> | false,
    },
    {} :: {
        __index: {
            ClassName: "Signal",
            new: () -> Signal<T...>,
            isSignal: (value: any) -> boolean,
            Connect: (self: Signal<T...>, fn: SignalHandler) -> Connection<T...>,
            GetConnectionCount: (self: Signal<T...>) -> number,
            DisconnectAll: (self: Signal<T...>) -> (),
            Fire: (self: Signal<T...>, T...) -> (),
            Wait: (self: Signal<T...>) -> T...,
            Once: (self: Signal<T...>, fn: SignalHandler) -> Connection<T...>,
            Destroy: (self: Signal<T...>) -> (),
        },
    }
))

export type OnSubscribe<T...> = (subscription: Subscription<T...>) -> MaidTask

export type Transformer = (observable: Observable<...any>) -> ObservableAny

export type ObservableAny = typeof(setmetatable(
    {} :: {
        _source: string?,
        _onSubscribe: OnSubscribe<any?>?,
    },
    {} :: {
        __index: {
            ClassName: "Observable",
            new: (onSubscribe: OnSubscribe<any?>) -> ObservableAny,
            isObservable: (value: any) -> boolean,
            Pipe: (self: ObservableAny, transformers: Transformer) -> ObservableAny,
            Subscribe: (
                self: ObservableAny,
                fireCallback: FireCallback<any?>?,
                failCallback: FailCallback?,
                completeCallback: CompleteCallback?
            ) -> Subscription<any?>,
        },
    }
))

export type Observable<T... = ...any> = typeof(setmetatable(
    {} :: {
        _source: string?,
        _onSubscribe: OnSubscribe<T...>?,
    },
    {} :: {
        __index: {
            ClassName: "Observable",
            new: (onSubscribe: OnSubscribe<T...>) -> Observable<T...>,
            isObservable: (value: any) -> boolean,
            Pipe: (self: Observable<T...>, transformers: Transformer) -> ObservableAny,
            Subscribe: (
                self: Observable<T...>,
                fireCallback: FireCallback<T...>?,
                failCallback: FailCallback?,
                completeCallback: CompleteCallback?
            ) -> Subscription<T...>,
        },
    }
))

export type SubscriptionState = "pending" | "failed" | "complete" | "cancelled"

export type FireCallback<T...> = (T...) -> ()
export type CompleteCallback = () -> ()
export type FailCallback = (...any) -> ()

export type Subscription<T... = ...any> = typeof(setmetatable(
    {} :: {
        _state: SubscriptionState,
        _cleanupTask: MaidTask?,
        _fireCallback: FireCallback<T...>?,
        _failCallback: FailCallback?,
        _completeCallback: CompleteCallback?,
        _fireCountAfterDeath: number?,
        _source: string?,
        _observableSource: string?,
    },
    {} :: {
        __index: {
            ClassName: "Subscription",
            new: (
                fireCallback: FireCallback<T...>?,
                failCallback: FailCallback?,
                completeCallback: CompleteCallback?,
                observableSource: string?
            ) -> Subscription<T...>,
            Fire: (self: Subscription<T...>, ...any) -> (),
            Fail: (self: Subscription<T...>, ...any) -> (),
            GetFireFailComplete: (self: Subscription<T...>) -> (FireCallback<T...>, FailCallback, CompleteCallback),
            GetFailComplete: (self: Subscription<T...>) -> (FailCallback, CompleteCallback),
            Complete: (self: Subscription<T...>, ...any) -> (),
            IsPending: (self: Subscription<T...>) -> boolean,
            _assignCleanup: (self: Subscription<T...>, cleanupTask: MaidTask) -> (),
            _doCleanup: (self: Subscription<T...>) -> (),
            Destroy: (self: Subscription<T...>) -> (),
            Disconnect: (self: Subscription<T...>) -> (),
        },
    }
))

export type BaseObject = typeof(setmetatable(
    {} :: {
        _obj: Instance?,
        _maid: Maid,
    },
    {} :: {
        __index: {
            ClassName: "BaseObject",
            new: (obj: Instance?) -> BaseObject,
            Destroy: (self: BaseObject) -> (),
        },
    }
))

export type ServiceBag =
    typeof(setmetatable(
        {} :: {
            _services: { [any]: any },
            _parentProvider: ServiceBag?,
            _serviceTypesToInitializeSet: { [any]: true }?,
            _initializedServiceTypeSet: { [any]: true },
            _initializedServiceTypeList: { any },
            _serviceTypesToStartSet: { [any]: true }?,

            _initRunAllowed: boolean,
            _destructing: boolean,
            _serviceInitLogger: ServiceInitLogger,
            _serviceStartLogger: ServiceInitLogger,

            _destroyingSignal: Signal,
        },
        {} :: {
            __index: {
                ClassName: "ServiceBag",
                new: (parentProvider: ServiceBag?) -> ServiceBag,
                isServiceBag: (value: any) -> boolean,
                PrintInitialization: (self: ServiceBag) -> (),
                GetService: <T>(self: ServiceBag, serviceType: T) -> T,
                HasService: <T>(self: ServiceBag, serviceType: T) -> boolean,
                Init: (self: ServiceBag) -> (),
                Start: (self: ServiceBag) -> (),
                _getServiceName: (self: ServiceBag, serviceType: any) -> string,
                IsStarted: (self: ServiceBag) -> boolean,
                CreateScope: (self: ServiceBag) -> ServiceBag,
                _addServiceType: <T>(self: ServiceBag, serviceType: T) -> (),
                _ensureInitialization: <T>(self: ServiceBag, serviceType: T) -> (),
                _initService: (self: ServiceBag, serviceType: any) -> (),
                Destroy: (self: ServiceBag) -> (),
                _destructServices: (self: ServiceBag) -> (),
                _destructService: (self: ServiceBag, serviceType: any, service: any) -> (),
            },
        }
    ))
    & BaseObject

type LogEntry = {
    name: string,
    children: { LogEntry },
    log: string?,
}

export type ServiceInitLogger = typeof(setmetatable(
    {} :: {
        _action: string,
        _rootNode: LogEntry,
        _stack: { LogEntry },
        _totalTimeUsed: number,
        _initIndent: number,
        _totalServices: number,
    },
    {} :: {
        __index: {
            ClassName: "ServiceInitLogger",
            new: (action: string) -> ServiceInitLogger,
            StartInitClock: (self: ServiceInitLogger, serviceName: string) -> () -> (),
            Print: (self: ServiceInitLogger) -> (),
        },
    }
))

export type MaidModule = typeof(require("@game/ServerScriptService/node_modules/@quenty/maid/Shared/Maid"))
export type SignalModule = typeof(require("@game/ServerScriptService/node_modules/@quenty/signal/Shared/Signal"))
export type ObservableModule = typeof(require("@game/ServerScriptService/node_modules/@quenty/rx/Shared/Observable"))
export type SubscriptionModule =
    typeof(require("@game/ServerScriptService/node_modules/@quenty/rx/Shared/Subscription"))
export type RxModule = typeof(require("@game/ServerScriptService/node_modules/@quenty/rx/Shared/Rx"))
export type ServiceBagModule = typeof(require(
    "@game/ServerScriptService/node_modules/@quenty/servicebag/Shared/ServiceBag"
))

return nil
