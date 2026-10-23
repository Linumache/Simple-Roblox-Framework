local TestService = {}
TestService.ServiceName = "TestService"

function TestService.Init() TestService.Power = 1000 end

function TestService.Start() print("[Example_Services] - TestService started") end

function TestService.Log10() return math.log10(TestService.Power) end

return TestService
