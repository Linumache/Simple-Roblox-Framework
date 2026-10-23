--[=[
    @class RuntimeConstants
]=]

--[=[
    @within RuntimeConstants
    @prop ParallelThreadPoolDefaultSize number
    @tag global
    @readonly
]=]
--[=[
    @within RuntimeConstants
    @prop ParallelThreadContextDefaultTimeBudget number
    @tag global
    @readonly
]=]
return table.freeze({
    ParallelThreadPoolDefaultSize = 4,
    ParallelThreadContextDefaultTimeBudget = 4 / 1000,
})
