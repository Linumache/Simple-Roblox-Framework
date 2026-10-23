local RuntimeTypes = require("@game/ReplicatedStorage/src/Core/Runtime/RuntimeTypes")

return function(Context: RuntimeTypes.ParallelContext, ...)
    local Start = os.clock()
    print(...)
    while os.clock() - Start < 10 / 1000 do
    end
    return "parallel job succeeded!"
end
