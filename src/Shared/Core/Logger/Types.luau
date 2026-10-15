local NevermoreTypes = require("../../Packages/Nevermore/NevermoreTypes")

--[=[
    @type LogLevelString "Trace" | "Debug" | "Info" | "Warn" | "Error"
    @within Logger
]=]
export type LogLevelString = "Trace" | "Debug" | "Info" | "Warn" | "Error"

--[=[
    @interface LogLevels
    @within Logger
    .Trace 1
    .Debug 2
    .Info 3
    .Warn 4
    .Error 5
]=]
export type LogLevels = { [LogLevelString]: number }

--[=[
    @interface LogLevelsMap
    @within Logger
    .1 "Trace"
    .2 "Debug"
    .3 "Info"
    .4 "Warn"
    .5 "Error"
]=]
export type LogLevelsMap = { [number]: LogLevelString }

export type LoggerProps = {
    Output: LoggerOutput,
    _LogLevel: number,
    _Category: string?,
}

export type LoggerMeta = {
    __index: {
        new: (LogLevel: (number | LogLevelString)?, MaxCount: number?) -> Logger,
        SetLogLevel: (self: Logger, LogLevel: number | LogLevelString) -> (),
        GetLogLevel: (self: Logger) -> number,
        SetCategory: (self: Logger, Category: string?) -> (),
        GetCategory: (self: Logger) -> string?,
        Trace: (self: Logger, Message: string) -> (),
        Debug: (self: Logger, Message: string) -> (),
        Info: (self: Logger, Message: string) -> (),
        Warn: (self: Logger, Message: string) -> (),
        Error: (self: Logger, Message: string) -> (),
        LogLevels: LogLevels,
        LogLevelsMap: LogLevelsMap,
    },
}

export type Logger = setmetatable<LoggerProps, LoggerMeta>

export type RingBufferProps<T> = {
    _Buffer: { T },
    _Count: number,
    _Head: number,
    _MaxSize: number,
    _Tail: number,
}

export type RingBufferMeta<T> = {
    __index: {
        new: (MaxSize: number) -> RingBuffer<T>,
        Push: (self: RingBuffer<T>, Value: T) -> (),
        Pop: (self: RingBuffer<T>) -> T?,
        PopTail: (self: RingBuffer<T>) -> T?,
        Peek: (self: RingBuffer<T>) -> T?,
        PeekHead: (self: RingBuffer<T>) -> T?,
        At: (self: RingBuffer<T>, Index: number) -> T?,
        AtHead: (self: RingBuffer<T>, Index: number) -> T?,
        SetMaxSize: (self: RingBuffer<T>, NewMaxSize: number) -> (),
        ToArray: (self: RingBuffer<T>) -> { T },
        Select: (self: RingBuffer<T>, Start: number, End: number) -> { T },
        SelectHead: (self: RingBuffer<T>, Start: number, End: number) -> { T },
        ForEachUnsafe: (self: RingBuffer<T>, Callback: (number, T) -> ()) -> (),
        IterateUnsafe: (self: RingBuffer<T>) -> ((RingBuffer<T>, number) -> (number, T), RingBuffer<T>, number),
        Clear: (self: RingBuffer<T>) -> (),
        Destroy: (self: RingBuffer<T>) -> (),
        GetMaxSize: (self: RingBuffer<T>) -> number,
        GetCount: (self: RingBuffer<T>) -> number,
        IsEmpty: (self: RingBuffer<T>) -> boolean,
        IsFull: (self: RingBuffer<T>) -> boolean,
    },
}

export type RingBuffer<T> = setmetatable<RingBufferProps<T>, RingBufferMeta<T>>

export type LoggerOutputProps = {
    _Channels: { [number]: LoggerOutputChannel },
}

export type LoggerOutputMeta = {
    __index: {
        new: (MaxCount: number?) -> LoggerOutput,
        Append: (self: LoggerOutput, LogLevel: number, Message: string) -> (),
        SetMaxCount: (self: LoggerOutput, LogLevel: number, MaxCount: number) -> (),
        Observe: (
            self: LoggerOutput,
            LogLevel: number,
            Callback: (Message: string) -> ()
        ) -> NevermoreTypes.Subscription<string>,
        Replay: (self: LoggerOutput, LogLevel: number) -> { string },
        GetLatest: (self: LoggerOutput, LogLevel: number) -> string?,
        GetObservable: (self: LoggerOutput, LogLevel: number) -> NevermoreTypes.Observable<string>,
        GetSource: (self: LoggerOutput, LogLevel: number) -> RingBuffer<string>,
    },
}

export type LoggerOutput = setmetatable<LoggerOutputProps, LoggerOutputMeta>

--[=[
    @interface LoggerOutputChannel
    @within Logger
    .Source RingBuffer<string>
    .Signal Signal
    .Observable Observable<string>
]=]
export type LoggerOutputChannel = {
    Source: RingBuffer<string>,
    Signal: NevermoreTypes.Signal,
    Observable: NevermoreTypes.Observable<string>,
}

return nil
