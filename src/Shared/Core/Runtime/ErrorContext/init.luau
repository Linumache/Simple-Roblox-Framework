--[=[
    @class ErrorContext
]=]

local Types = require("./Types")

local ErrorContext = {}
ErrorContext.__index = ErrorContext

--[=[
    @within ErrorContext
    @param Name string
    @param ErrorMessage string
    @param StackTraceLevel number
    @return ErrorContext
]=]
--[=[
    @within ErrorContext
    @prop Name string
]=]
--[=[
    @within ErrorContext
    @prop ErrorMessage string
]=]
--[=[
    @within ErrorContext
    @prop StackTrace string
]=]
function ErrorContext.new(Name: string, ErrorMessage: string, StackTraceLevel: number)
    local self = setmetatable({
        Name = Name,
        ErrorMessage = ErrorMessage,
        StackTrace = debug.traceback(ErrorMessage, StackTraceLevel + 1),
    }, ErrorContext) :: Types.ErrorContext
    return self
end

--[=[
    @method PrintError
    @within ErrorContext
]=]
function ErrorContext.PrintError(self: Types.ErrorContext)
    task.spawn(error, `App "{self.Name}" failed to run. Most recent stack trace:\n{self.StackTrace}`, 0)
end

return ErrorContext
