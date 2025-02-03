while true do
wait()

local args = {
    [1] = "Currency",
    [2] = 500000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))
end
