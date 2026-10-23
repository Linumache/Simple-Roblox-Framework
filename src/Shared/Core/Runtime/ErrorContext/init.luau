--[=[
    @class ErrorContext
]=]

local RuntimeTypes = require("./RuntimeTypes")

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
    }, ErrorContext) :: RuntimeTypes.ErrorContext
    return self
end

--[=[
    @method PrintError
    @within ErrorContext
]=]
function ErrorContext.PrintError(self: RuntimeTypes.ErrorContext)
    task.spawn(error, `[{self.Name}] - App has crashed! Most recent stack trace:\n{self.StackTrace}`, 0)
end

return ErrorContext
