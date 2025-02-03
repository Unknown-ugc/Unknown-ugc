local args = {
    [1] = "Currency",
    [2] = 999999999
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))

