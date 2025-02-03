local args = {
    [1] = "Currency",
    [2] = 9999999999999999999999
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))

