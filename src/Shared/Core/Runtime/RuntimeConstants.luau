--[=[
    @class RuntimeConstants
]=]

--[=[
    @within RuntimeConstants
    @interface Constants
    .ParallelThreadPoolDefaultSize 4
    .ParallelThreadContextDefaultTimeBudget 0.004
]=]
return table.freeze({
    ParallelThreadPoolDefaultSize = 4,
    ParallelThreadContextDefaultTimeBudget = 4 / 1000,
})
