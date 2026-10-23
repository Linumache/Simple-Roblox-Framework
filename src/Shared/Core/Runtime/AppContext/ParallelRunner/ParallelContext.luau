--[=[
    @class ParallelContext
]=]

local RuntimeConstants = require("../../RuntimeConstants")
local RuntimeTypes = require("../../RuntimeTypes")

local ParallelContext = {}
ParallelContext.__index = ParallelContext

local DefaultTimeBudget = RuntimeConstants.ParallelThreadContextDefaultTimeBudget

--[=[
    @within ParallelContext
    @param TimeBudget number?
    @return ParallelContext
]=]
--[=[
    @within ParallelContext
    @prop _Deadline number
    @private
]=]
--[=[
    @within ParallelContext
    @prop _TimeBudget number
    @private
]=]
function ParallelContext.new(TimeBudget: number?)
    TimeBudget = TimeBudget or DefaultTimeBudget

    local self = setmetatable({
        _Deadline = os.clock() + TimeBudget,
        _TimeBudget = TimeBudget,
    }, ParallelContext) :: RuntimeTypes.ParallelContext
    return self
end

--[=[
    @method YieldIfLate
    @within ParallelContext
    @yields
]=]
function ParallelContext.YieldIfLate(self: RuntimeTypes.ParallelContext)
    if os.clock() > self._Deadline then
        task.wait()
        self._Deadline = os.clock() + self._TimeBudget
    end
end

return ParallelContext
