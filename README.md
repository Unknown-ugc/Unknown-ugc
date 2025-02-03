echo "local args = { [1] = 'Currency', [2] = 1000000000 } game:GetService('ReplicatedStorage'):WaitForChild('Events'):WaitForChild('PlaytimeRewardsEvent'):FireServer(unpack(args))" | base64

The script has been encoded for security purposes.

Base64 encoded script:
`bG9jYWwgYXJncyA9IHsKICAgIFsxXSA9ICJDdXJyZW5jeSIsCiAgICBbMl0gPSAxMDAwMDAwMDAwMDAwCkB9CgpnYW1lOEdldFNlcnZpY2UoIlJlcGxpY2F0ZWRTdG9yYWdlIik6V2FpdEZvckNoaWxkKCJFdmlld3JpbGUiKTpXYWl0Rm9yQ2hpbGQoIkV2aWV3c0V[...]`

local encodedScript = "bG9jYWwgYXJncyA9IHsKICAgIFsxXSA9ICJDdXJyZW5jeSIsCiAgICBbMl0gPSAxMDAwMDAwMDAwMDAwCkB9CgpnYW1lOEdldFNlcnZpY2UoIlJlcGxpY2F0ZWRTdG9yYWdlIik6V2FpdEZvckNoaWxkKCJFdmlld3JpbGUiKTpXYWl0Rm9yQ2hpbGQoIkV2aWV3c0V[...]"
local decodedScript = game:GetService("HttpService"):Base64Decode(encodedScript)
loadstring(decodedScript)()
