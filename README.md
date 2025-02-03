import base64

local args = {
    [1] = "Currency",
    [2] = 1000000000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))
encoded_script = base64.b64encode(script).decode()
print(encoded_script)
