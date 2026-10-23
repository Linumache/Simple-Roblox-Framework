--[=[
    @class ThreadProxy
]=]

local RuntimeTypes = require("../../RuntimeTypes")

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
    }, ThreadProxy) :: RuntimeTypes.ThreadProxy
    return self
end

--[=[
    @method Cancel
    @within ThreadProxy
]=]
function ThreadProxy.Cancel(self: RuntimeTypes.ThreadProxy)
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
function ThreadProxy.Resume(self: RuntimeTypes.ThreadProxy, ...: any) return coroutine.resume(self._Thread, ...) end

--[=[
    @method Status
    @within ThreadProxy
    @return "dead" | "normal" | "running" | "suspended"
]=]
function ThreadProxy.Status(self: RuntimeTypes.ThreadProxy) return coroutine.status(self._Thread) end

--[=[
    @method Unwrap
    @within ThreadProxy
    @return thread
]=]
function ThreadProxy.Unwrap(self: RuntimeTypes.ThreadProxy) return self._Thread end

--[=[
    @method Destroy
    @within ThreadProxy
    Alias for `ThreadProxy.Cancel`
]=]
ThreadProxy.Destroy = ThreadProxy.Cancel

return ThreadProxy
