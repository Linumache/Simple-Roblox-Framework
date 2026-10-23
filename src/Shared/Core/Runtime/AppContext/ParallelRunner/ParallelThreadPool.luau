--[=[
    @class ParallelThreadPool
]=]

--!optimize 2

local RuntimeConstants = require("../../RuntimeConstants")
local ParallelThread = require("./ParallelThread")
local RuntimeTypes = require("../../RuntimeTypes")

local ParallelThreadPool = {}
ParallelThreadPool.__index = ParallelThreadPool

local DefaultThreadPoolSize = RuntimeConstants.ParallelThreadPoolDefaultSize

local function GetNewThread(self: RuntimeTypes.ParallelThreadPool)
    local Thread = ParallelThread.new(self._RunnerScript, self._ActorPlace)
    table.insert(self._Pool, Thread)
    return Thread
end

local function GetLeastBusyThread(self: RuntimeTypes.ParallelThreadPool): RuntimeTypes.ParallelThread?
    local Pool = self._Pool

    local LeastBusyThread = Pool[1]
    if not LeastBusyThread then return nil end
    local LeastRefCount = LeastBusyThread.RefCount

    for _, Thread in Pool do
        if Thread.RefCount < LeastRefCount then
            LeastBusyThread = Thread
            LeastRefCount = Thread.RefCount
        end
    end

    return LeastBusyThread
end

local function IdleToBusySorter(A: RuntimeTypes.ParallelThread, B: RuntimeTypes.ParallelThread) return A.RefCount < B.RefCount end

local function MakeIdentity() return tostring({}) .. os.clock() end

--[=[
    @within ParallelThreadPool
    @param Size number?
    @param RunnerScript Script
    @param ActorPlace Instance
    @return ParallelThreadPool
]=]
--[=[
    @within ParallelThreadPool
    @prop _Pool { ParallelThread }
    @private
]=]
--[=[
    @within ParallelThreadPool
    @prop _OrphanedThreads { ParallelThread }
    @private
]=]
--[=[
    @within ParallelThreadPool
    @prop _Size number
    @private
]=]
--[=[
    @within ParallelThreadPool
    @prop _RunnerScript Script
    @private
]=]
--[=[
    @within ParallelThreadPool
    @prop _ActorPlace Instance
    @private
]=]
function ParallelThreadPool.new(Size: number?, RunnerScript: Script, ActorPlace: Instance)
    local self = setmetatable({
        _Pool = {},
        _OrphanedThreads = {},
        _Size = Size or DefaultThreadPoolSize,
        _RunnerScript = RunnerScript,
        _ActorPlace = ActorPlace,
    }, ParallelThreadPool) :: RuntimeTypes.ParallelThreadPool
    return self
end

--[=[
    @method Borrow
    @within ParallelThreadPool
    @return ParallelThread
    @return string -- identity
]=]
function ParallelThreadPool.Borrow(self: RuntimeTypes.ParallelThreadPool)
    local PoolSize = #self._Pool

    local Thread
    if PoolSize >= self._Size then
        Thread = assert(GetLeastBusyThread(self), "[ParallelThreadPool] - Borrow: size is too small")
    else
        Thread = GetNewThread(self)
    end

    Thread.RefCount += 1
    return Thread, MakeIdentity()
end

--[=[
    @method Return
    @within ParallelThreadPool
    @param Thread ParallelThread
]=]
function ParallelThreadPool.Return(self: RuntimeTypes.ParallelThreadPool, Thread: RuntimeTypes.ParallelThread)
    local ThreadRefCount = math.max(Thread.RefCount - 1, 0)
    Thread.RefCount = ThreadRefCount

    if ThreadRefCount == 0 then
        local OrphanedThreads = self._OrphanedThreads
        if OrphanedThreads[Thread] then
            Thread.Actor:Destroy()
            OrphanedThreads[Thread] = nil
        end
    end
end

--[=[
    @method Resize
    @within ParallelThreadPool
    @param NewSize number
]=]
function ParallelThreadPool.Resize(self: RuntimeTypes.ParallelThreadPool, NewSize: number)
    self._Size = NewSize

    local Pool = self._Pool
    local PoolSize = #Pool

    if PoolSize - NewSize > 0 then
        table.sort(self._Pool, IdleToBusySorter)
        local OrphanedThreads = self._OrphanedThreads

        for Index = NewSize + 1, PoolSize do
            local Thread = Pool[Index]
            Pool[Index] = nil
            if Thread.RefCount == 0 then
                Thread.Actor:Destroy()
            else
                OrphanedThreads[Thread] = true
            end
        end
    end
end

--[=[
   @method Fill
   @within ParallelThreadPool
]=]
function ParallelThreadPool.Fill(self: RuntimeTypes.ParallelThreadPool)
    debug.profilebegin("ParallelThreadPool.Fill")
    for _ = #self._Pool + 1, self._Size do
        GetNewThread(self)
    end
    debug.profileend()
end

--[=[
   @method Destroy
   @within ParallelThreadPool
]=]
function ParallelThreadPool.Destroy(self: RuntimeTypes.ParallelThreadPool)
    local Pool = self._Pool
    for Index, Thread in Pool do
        Thread.Actor:Destroy()
        Pool[Index] = nil
    end

    local OrphanedThreads = self._OrphanedThreads
    for Thread in OrphanedThreads do
        Thread.Actor:Destroy()
        OrphanedThreads[Thread] = nil
    end
end

return ParallelThreadPool
