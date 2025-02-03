local args = {
    [1] = "Currency",
    [2] = 10000000000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))
