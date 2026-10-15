--[=[
    @class ThreadProxy
]=]

local Types = require("../Types")

local ThreadProxy = {}
ThreadProxy.__index = ThreadProxy

--[=[
    @within ThreadProxy
    @param Thread thread
    @param OnCancel (() -> ())?
    @return ThreadProxy
]=]
--[=[
    @within ThreadProxy
    @prop _Thread thread
    @private
]=]
--[=[
    @within ThreadProxy
    @prop _OnCancel (() -> ())?
    @private
]=]
function ThreadProxy.new(Thread: thread, OnCancel: (() -> ())?)
    local self = setmetatable({
        _Thread = Thread,
        _OnCancel = OnCancel,
    }, ThreadProxy) :: Types.ThreadProxy
    return self
end

--[=[
    @method Cancel
    @within ThreadProxy
]=]
function ThreadProxy.Cancel(self: Types.ThreadProxy)
    local Thread = self._Thread
    if coroutine.status(Thread) == "dead" then return end

    task.cancel(Thread)

    local OnCancel = self._OnCancel
    if OnCancel then OnCancel() end
end

--[=[
    @method Resume
    @within ThreadProxy
    @param ... any
    @return boolean
    @return ...any
]=]
function ThreadProxy.Resume(self: Types.ThreadProxy, ...: any) return coroutine.resume(self._Thread, ...) end

--[=[
    @method Status
    @within ThreadProxy
    @return "dead" | "normal" | "running" | "suspended"
]=]
function ThreadProxy.Status(self: Types.ThreadProxy) return coroutine.status(self._Thread) end

--[=[
    @method Unwrap
    @within ThreadProxy
    @return thread
]=]
function ThreadProxy.Unwrap(self: Types.ThreadProxy) return self._Thread end

return ThreadProxy
