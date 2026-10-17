-- language: Luau, file: cat_hub_part1.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local requestFunc = syn and syn.request or http and http.request or http_request or request

local WEBHOOK_PRIVATE = "https://discord.com/api/webhooks/1560925485653827644/Fzi4UpnEhPTa_mXrAmHlPUwMBtUgSWGEeP3GjrCJucjponSEtCulfKRkWjhqzDrjeX_k"
local DISCORD_LINK = "https://discord.gg/FJK6QzNnf7"
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local CYAN, BG, SIDEBAR, CONTENT, BOX_OUT, BOX_IN = Color3.fromRGB(0, 255, 255), Color3.fromRGB(8, 10, 14), Color3.fromRGB(12, 16, 22), Color3.fromRGB(14, 18, 26), Color3.fromRGB(20, 26, 36), Color3.fromRGB(26, 34, 46)
local TXT, TXT_SUB, GREEN, RED = Color3.fromRGB(240, 240, 240), Color3.fromRGB(150, 160, 175), Color3.fromRGB(0, 255, 100), Color3.fromRGB(200, 0, 0)
local BLURPLE = Color3.fromRGB(88, 101, 242)

local function showKeyGui()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "CatHubKey"; keyGui.ResetOnSpawn = false
    keyGui.Parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame", keyGui)
    frame.Size = UDim2.new(0, 300, 0, 240); frame.Position = UDim2.new(0.5, -150, 0.5, -120)
    frame.BackgroundColor3 = BG; frame.BorderSizePixel = 0; frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = CYAN; stroke.Thickness = 2

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30); title.Position = UDim2.new(0, 0, 0, 10); title.BackgroundTransparency = 1
    title.Text = "CAT HUB KEY"; title.TextColor3 = CYAN
    title.Font = Enum.Font.GothamBlack; title.TextSize = 16

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -30, 0, 32); input.Position = UDim2.new(0, 15, 0, 50)
    input.BackgroundColor3 = BOX_IN; input.PlaceholderText = "Enter key here..."
    input.TextColor3 = Color3.fromRGB(255, 255, 255); input.Font = Enum.Font.GothamBold; input.TextSize = 12
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -30, 0, 15); status.Position = UDim2.new(0, 15, 0, 85)
    status.BackgroundTransparency = 1; status.Text = ""; status.TextColor3 = RED
    status.Font = Enum.Font.Gotham; status.TextSize = 10; status.TextXAlignment = Enum.TextXAlignment.Left

    local submit = Instance.new("TextButton", frame)
    submit.Size = UDim2.new(1, -30, 0, 32); submit.Position = UDim2.new(0, 15, 0, 105)
    submit.BackgroundColor3 = CYAN; submit.Text = "Verify Key"
    submit.TextColor3 = Color3.fromRGB(0, 0, 0); submit.Font = Enum.Font.GothamBold; submit.TextSize = 12
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 4)

    local discordBtn = Instance.new("TextButton", frame)
    discordBtn.Size = UDim2.new(1, -30, 0, 40); discordBtn.Position = UDim2.new(0, 15, 0, 155)
    discordBtn.BackgroundColor3 = BLURPLE; discordBtn.Text = "  Join Discord Server"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255); discordBtn.Font = Enum.Font.GothamBold; discordBtn.TextSize = 12
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)
    
    local dImg = Instance.new("ImageLabel", discordBtn)
    dImg.Size = UDim2.new(0, 24, 0, 24); dImg.Position = UDim2.new(0, 8, 0.5, -12)
    dImg.BackgroundTransparency = 1
    dImg.Image = "rbxthumb://type=Asset&id=10367063084&w=420&h=420"
    dImg.Parent = discordBtn
    
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(DISCORD_LINK) end)
        discordBtn.Text = "  Copied Link!"; task.wait(2); discordBtn.Text = "  Join Discord Server"
    end)

    submit.MouseButton1Click:Connect(function()
        if input.Text == "CAT-HUB-2024" or input.Text == "FREE-CAT-SNIPER" then
            status.Text = "Key accepted! Loading..."; status.TextColor3 = GREEN
            task.wait(1); keyGui:Destroy(); loadMainUI() 
        else
            status.Text = "Invalid key. Try again."; input.Text = ""
        end
    end)
end

function loadMainUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CatHub"; gui.ResetOnSpawn = false; gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
    
    local scale = Instance.new("UIScale", gui)
    -- Fit the whole window inside the current screen instead of letting it clip.
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    scale.Scale = math.min(1, (viewport.X - 24) / 750, (viewport.Y - 40) / 480)
    if IS_MOBILE then scale.Scale = math.min(scale.Scale, 0.75) end

    local miniCircle = Instance.new("ImageButton", gui)
    miniCircle.Size = UDim2.new(0, 50, 0, 50); miniCircle.Position = UDim2.new(0, 50, 0, 50)
    miniCircle.BackgroundTransparency = 1; miniCircle.Image = "rbxthumb://type=Asset&id=85043883236326&w=420&h=420"
    miniCircle.Visible = false; miniCircle.Draggable = true; miniCircle.ZIndex = 40; miniCircle.Active = true
    Instance.new("UICorner", miniCircle).CornerRadius = UDim.new(1, 0)
    local circleStroke = Instance.new("UIStroke", miniCircle); circleStroke.Color = CYAN; circleStroke.Thickness = 2

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 750, 0, 480); main.AnchorPoint = Vector2.new(0.5, 0.5); main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = BG; main.Active = true; main.Draggable = true; main.ClipsDescendants = false; main.ZIndex = 1
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local mSt = Instance.new("UIStroke", main); mSt.Color = CYAN; mSt.Thickness = 2

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 25, 0, 25); closeBtn.Position = UDim2.new(1, -35, 0, 8)
    closeBtn.BackgroundColor3 = RED; closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12; closeBtn.ZIndex = 30; closeBtn.Active = true
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    local minBtn = Instance.new("TextButton", main)
    minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -65, 0, 8)
    minBtn.BackgroundColor3 = CYAN; minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 14; minBtn.ZIndex = 30; minBtn.Active = true
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    minBtn.MouseButton1Click:Connect(function() main.Visible = false; miniCircle.Visible = true end)
    miniCircle.MouseButton1Click:Connect(function() miniCircle.Visible = false; main.Visible = true end)

    local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 150, 1, 0); side.BackgroundColor3 = SIDEBAR; side.ZIndex = 5; side.Active = true
    Instance.new("UICorner", side).CornerRadius = UDim.new(0, 10)
    local vL = Instance.new("Frame", main); vL.Size = UDim2.new(0, 2, 1, -20); vL.Position = UDim2.new(0, 150, 0, 10); vL.BackgroundColor3 = CYAN; vL.BackgroundTransparency = 0.5

    local t1 = Instance.new("TextLabel", side); t1.Size = UDim2.new(1, 0, 0, 35); t1.Position = UDim2.new(0, 0, 0, 10); t1.BackgroundTransparency = 1; t1.Text = "CAT HUB"; t1.TextColor3 = CYAN; t1.Font = Enum.Font.GothamBlack; t1.TextSize = 20
    local t2 = Instance.new("TextLabel", side); t2.Size = UDim2.new(1, 0, 0, 15); t2.Position = UDim2.new(0, 0, 0, 35); t2.BackgroundTransparency = 1; t2.Text = "Egg Detector"; t2.TextColor3 = TXT_SUB; t2.Font = Enum.Font.Gotham; t2.TextSize = 10

    local aTab, aStr
    local function mkTab(txt, y)
        local b = Instance.new("TextButton", side); b.Size = UDim2.new(1, -20, 0, 36); b.Position = UDim2.new(0, 10, 0, y); b.ZIndex = 7; b.Active = true; b.BackgroundColor3 = CONTENT; b.Text = "   "..txt; b.TextColor3 = TXT_SUB; b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", b); s.Color = CYAN; s.Thickness = 2; s.Transparency = 1
        return b, s
    end
    local tbHome, stHome = mkTab("Home", 70)
    local tbAuto, stAuto = mkTab("Auto Join", 110)
    local tbLive, stLive = mkTab("Live Egg List", 150)
    local tbServ, stServ = mkTab("Server", 190)

-- HOME FRAME
local fHome = Instance.new("Frame", main); fHome.Size = UDim2.new(1, -170, 1, -20); fHome.Position = UDim2.new(0, 160, 0, 10); fHome.BackgroundColor3 = CONTENT; fHome.ZIndex = 2; fHome.ClipsDescendants = true
Instance.new("UICorner", fHome).CornerRadius = UDim.new(0, 8)
local function mkBox(prnt, t, d, y)
    local ob = Instance.new("Frame", prnt); ob.Size = UDim2.new(1, -30, 0, 70); ob.Position = UDim2.new(0, 15, 0, y); ob.ZIndex = 3; ob.BackgroundColor3 = BOX_OUT
    Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 6)
    local ib = Instance.new("Frame", ob); ib.Size = UDim2.new(1, -8, 1, -8); ib.Position = UDim2.new(0, 4, 0, 4); ib.BackgroundColor3 = BOX_IN
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 4)
    local tL = Instance.new("TextLabel", ib); tL.Size = UDim2.new(1, -16, 0, 15); tL.Position = UDim2.new(0, 8, 0, 6); tL.BackgroundTransparency = 1; tL.Text = t; tL.TextColor3 = CYAN; tL.Font = Enum.Font.GothamBold; tL.TextSize = 12; tL.TextXAlignment = Enum.TextXAlignment.Left
    local dL = Instance.new("TextLabel", ib); dL.Size = UDim2.new(1, -16, 0, 30); dL.Position = UDim2.new(0, 8, 0, 24); dL.BackgroundTransparency = 1; dL.Text = d; dL.TextColor3 = TXT_SUB; dL.Font = Enum.Font.Gotham; dL.TextSize = 10; dL.TextXAlignment = Enum.TextXAlignment.Left; dL.TextWrapped = true
end
mkBox(fHome, "WELCOME TO CAT HUB", "Detect all eggs across all servers using automated scanners.", 40)
mkBox(fHome, "AUTO JOIN", "Set Rarity and KG. When matched, it auto-teleports you.", 120)
mkBox(fHome, "LIVE EGG LIST", "Real-time detections synced with search and filter.", 200)
mkBox(fHome, "SERVER", "Shows all eggs in your current server, sorted by value.", 280)

-- AUTO JOIN FRAME
local fAuto = Instance.new("Frame", main); fAuto.Size = UDim2.new(1, -170, 1, -20); fAuto.Position = UDim2.new(0, 160, 0, 10); fAuto.BackgroundColor3 = CONTENT; fAuto.Visible = false; fAuto.ZIndex = 2; fAuto.ClipsDescendants = true
Instance.new("UICorner", fAuto).CornerRadius = UDim.new(0, 8)
local function mkLayerBox(prnt, y, h)
    local ob = Instance.new("Frame", prnt); ob.Size = UDim2.new(1, -30, 0, h); ob.Position = UDim2.new(0, 15, 0, y); ob.BackgroundColor3 = BOX_OUT
    Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 6)
    local ib = Instance.new("Frame", ob); ib.Size = UDim2.new(1, -8, 1, -8); ib.Position = UDim2.new(0, 4, 0, 4); ib.BackgroundColor3 = BOX_IN
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 4)
    return ib
end
local rIB = mkLayerBox(fAuto, 40, 70)
local rT = Instance.new("TextLabel", rIB); rT.Size = UDim2.new(1, -20, 0, 15); rT.Position = UDim2.new(0, 10, 0, 5); rT.BackgroundTransparency = 1; rT.Text = "TARGET RARITY"; rT.TextColor3 = CYAN; rT.Font = Enum.Font.GothamBold; rT.TextSize = 11; rT.TextXAlignment = Enum.TextXAlignment.Left
local rarities = {"Any", "Secret", "Divine", "Eternal", "Cosmic", "Mythic"}
local rIdx = 1
local rBtn = Instance.new("TextButton", rIB); rBtn.Size = UDim2.new(1, -20, 0, 28); rBtn.Position = UDim2.new(0, 10, 0, 25); rBtn.BackgroundColor3 = BG; rBtn.Text = "Any"; rBtn.TextColor3 = TXT; rBtn.Font = Enum.Font.Gotham; rBtn.TextSize = 11
Instance.new("UICorner", rBtn).CornerRadius = UDim.new(0, 4)
rBtn.MouseButton1Click:Connect(function() rIdx = rIdx + 1; if rIdx > #rarities then rIdx = 1 end; rBtn.Text = rarities[rIdx] end)

local kIB = mkLayerBox(fAuto, 120, 70)
local kT = Instance.new("TextLabel", kIB); kT.Size = UDim2.new(1, -20, 0, 15); kT.Position = UDim2.new(0, 10, 0, 5); kT.BackgroundTransparency = 1; kT.Text = "MINIMUM KG"; kT.TextColor3 = CYAN; kT.Font = Enum.Font.GothamBold; kT.TextSize = 11; kT.TextXAlignment = Enum.TextXAlignment.Left
local kBox = Instance.new("TextBox", kIB); kBox.Size = UDim2.new(1, -20, 0, 28); kBox.Position = UDim2.new(0, 10, 0, 25); kBox.BackgroundColor3 = BG; kBox.PlaceholderText = "1000 or 1k"; kBox.Text = ""; kBox.TextColor3 = TXT; kBox.Font = Enum.Font.Gotham; kBox.TextSize = 11
Instance.new("UICorner", kBox).CornerRadius = UDim.new(0, 4)

local tIB = mkLayerBox(fAuto, 200, 50)
local tLbl = Instance.new("TextLabel", tIB); tLbl.Size = UDim2.new(0.6, 0, 1, 0); tLbl.Position = UDim2.new(0, 15, 0, 0); tLbl.BackgroundTransparency = 1; tLbl.Text = "AUTO JOIN"; tLbl.TextColor3 = CYAN; tLbl.Font = Enum.Font.GothamBold; tLbl.TextSize = 12; tLbl.TextXAlignment = Enum.TextXAlignment.Left
local tgBtn = Instance.new("TextButton", tIB); tgBtn.Size = UDim2.new(0, 70, 0, 26); tgBtn.Position = UDim2.new(1, -85, 0.5, -13); tgBtn.BackgroundColor3 = BG; tgBtn.Text = "OFF"; tgBtn.TextColor3 = TXT_SUB; tgBtn.Font = Enum.Font.GothamBold; tgBtn.TextSize = 11
Instance.new("UICorner", tgBtn).CornerRadius = UDim.new(1, 0)
local tgSt = Instance.new("UIStroke", tgBtn); tgSt.Color = TXT_SUB; tgSt.Thickness = 2

-- LIVE FRAME
local fLive = Instance.new("Frame", main); fLive.Size = UDim2.new(1, -170, 1, -20); fLive.Position = UDim2.new(0, 160, 0, 10); fLive.BackgroundColor3 = CONTENT; fLive.Visible = false; fLive.ZIndex = 2; fLive.ClipsDescendants = true
Instance.new("UICorner", fLive).CornerRadius = UDim.new(0, 8)
local sBox = Instance.new("TextBox", fLive); sBox.Size = UDim2.new(0, 250, 0, 30); sBox.Position = UDim2.new(0, 15, 0, 10); sBox.BackgroundColor3 = BOX_IN; sBox.PlaceholderText = "Search egg..."; sBox.TextColor3 = TXT; sBox.Font = Enum.Font.Gotham; sBox.TextSize = 11
Instance.new("UICorner", sBox).CornerRadius = UDim.new(0, 4)
local fBtn = Instance.new("TextButton", fLive); fBtn.Size = UDim2.new(0, 100, 0, 30); fBtn.Position = UDim2.new(1, -115, 0, 10); fBtn.BackgroundColor3 = BOX_IN; fBtn.Text = "Rarity Filter"; fBtn.TextColor3 = CYAN; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 11
Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 4)
local glw = Instance.new("Frame", fLive); glw.Size = UDim2.new(0, 8, 0, 8); glw.Position = UDim2.new(0, 15, 0, 50); glw.BackgroundColor3 = GREEN; Instance.new("UICorner", glw).CornerRadius = UDim.new(1, 0)
local glwSt = Instance.new("UIStroke", glw); glwSt.Color = GREEN; glwSt.Thickness = 3; glwSt.Transparency = 0.5
local lTxt = Instance.new("TextLabel", fLive); lTxt.Size = UDim2.new(0, 100, 0, 15); lTxt.Position = UDim2.new(0, 28, 0, 46); lTxt.BackgroundTransparency = 1; lTxt.Text = "Egg Live"; lTxt.TextColor3 = GREEN; lTxt.Font = Enum.Font.GothamBold; lTxt.TextSize = 11; lTxt.TextXAlignment = Enum.TextXAlignment.Left
local lScr = Instance.new("ScrollingFrame", fLive); lScr.Size = UDim2.new(1, -30, 1, -75); lScr.Position = UDim2.new(0, 15, 0, 70); lScr.BackgroundTransparency = 1; lScr.CanvasSize = UDim2.new(0, 0, 0, 0); lScr.ScrollBarThickness = 3
local lLay = Instance.new("UIListLayout", lScr); lLay.Padding = UDim.new(0, 6)

-- SERVER FRAME
local fServ = Instance.new("Frame", main); fServ.Size = UDim2.new(1, -170, 1, -20); fServ.Position = UDim2.new(0, 160, 0, 10); fServ.BackgroundColor3 = CONTENT; fServ.Visible = false; fServ.ZIndex = 2; fServ.ClipsDescendants = true
Instance.new("UICorner", fServ).CornerRadius = UDim.new(0, 8)
local sScr = Instance.new("ScrollingFrame", fServ); sScr.Size = UDim2.new(1, -30, 1, -30); sScr.Position = UDim2.new(0, 15, 0, 15); sScr.BackgroundTransparency = 1; sScr.CanvasSize = UDim2.new(0, 0, 0, 0); sScr.ScrollBarThickness = 3
local sLay = Instance.new("UIListLayout", sScr); sLay.Padding = UDim.new(0, 6)

    -- LOGIC
    local Assets, Networking
    pcall(function() Assets = require(ReplicatedStorage.Data.Assets); Networking = ReplicatedStorage.Packages.Networking end)

    local function parseKg(str)
        local n = tonumber(string.lower(str):match("([%d%.]+)"))
        if not n then return 0 end
        if string.find(string.lower(str), "k") then return n * 1000 end
        return n
    end

    local function mkRow(egg, prnt, showJoin)
        local r = Instance.new("Frame", prnt); r.Size = UDim2.new(1, -10, 0, 55); r.BackgroundColor3 = BOX_IN
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 4)
        local i = Instance.new("ImageLabel", r); i.Size = UDim2.new(0, 40, 0, 40); i.Position = UDim2.new(0, 8, 0.5, -20); i.BackgroundTransparency = 1; i.Image = egg.image or ""
        local n = Instance.new("TextLabel", r); n.Size = UDim2.new(0, 200, 0, 15); n.Position = UDim2.new(0, 55, 0, 8); n.BackgroundTransparency = 1; n.Text = egg.name or "Unknown"; n.TextColor3 = TXT; n.Font = Enum.Font.GothamBold; n.TextSize = 11; n.TextXAlignment = Enum.TextXAlignment.Left
        local sb = Instance.new("TextLabel", r); sb.Size = UDim2.new(0, 200, 0, 12); sb.Position = UDim2.new(0, 55, 0, 25); sb.BackgroundTransparency = 1; sb.Text = string.format("%s • %s KG", egg.rarity or "Unk", tostring(math.floor(egg.scale or 0))); sb.TextColor3 = TXT_SUB; sb.Font = Enum.Font.Gotham; sb.TextSize = 9; sb.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", r); v.Size = UDim2.new(0, 80, 0, 15); v.Position = UDim2.new(1, -160, 0, 20); v.BackgroundTransparency = 1; v.Text = egg.value or "$0"; v.TextColor3 = GREEN; v.Font = Enum.Font.GothamBold; v.TextSize = 11; v.TextXAlignment = Enum.TextXAlignment.Right
        
        if showJoin then
            local j = Instance.new("TextButton", r); j.Size = UDim2.new(0, 60, 0, 24); j.Position = UDim2.new(1, -70, 0.5, -12); j.BackgroundColor3 = CYAN; j.Text = "JOIN"; j.TextColor3 = Color3.new(0,0,0); j.Font = Enum.Font.GothamBold; j.TextSize = 10
            Instance.new("UICorner", j).CornerRadius = UDim.new(0, 3)
            j.MouseButton1Click:Connect(function() pcall(function() setclipboard("roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. egg.serverId) end); j.Text = "OK!"; task.wait(1); j.Text = "JOIN" end)
        end
    end

    local function getMyEggs()
        local t = {}
        if not Networking or not Assets then return t end
        pcall(function()
            local res = Networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot"):InvokeServer()
            if res and res.Records then
                for _, rc in pairs(res.Records) do
                    local e = Assets.Directory[tostring(rc.AssetCategory)]
                    if e then
                        local s = tonumber(rc.AssetScale) or 1
                        table.insert(t, {name = e.DisplayName or rc.AssetCategory, rarity = e.Rarity and tostring(e.Rarity.DisplayName) or "Unk", scale = s, value = string.format("$%.1fM", ((tonumber(e.EarningRate) or 0) * (s ^ 1.5))/1e6), image = "rbxassetid://" .. tostring(e.Icon)})
                    end
                end
            end
        end)
        table.sort(t, function(a,b) return a.scale > b.scale end)
        return t
    end

    local function refreshServ()
        for _, c in ipairs(sScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for _, egg in ipairs(getMyEggs()) do mkRow(egg, sLay, false) end
    end

    local function fetchLive()
        for _, c in ipairs(lScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local ok, r = pcall(function() return requestFunc({ Url = WEBHOOK_PRIVATE .. "?limit=50", Method = "GET" }) end)
        if ok and r and r.Body then
            local dec = HttpService:JSONDecode(r.Body)
            if type(dec) == "table" then
                local eggs = {}
                for _, m in ipairs(dec) do if m.embeds and m.embeds[1] then local okL, l = pcall(function() return HttpService:JSONDecode(m.embeds[1].description) end); if okL and type(l) == "table" then for _, e in ipairs(l) do table.insert(eggs, e) end end end end
                table.sort(eggs, function(a,b) return (a.scale or 0) > (b.scale or 0) end)
                for _, egg in ipairs(eggs) do mkRow(egg, lLay, true) end
            end
        end
    end

    local snipe = false
    tgBtn.MouseButton1Click:Connect(function()
        if snipe then snipe = false; tgBtn.Text = "OFF"; tgBtn.TextColor3 = TXT_SUB; tgSt.Color = TXT_SUB; tgBtn.BackgroundColor3 = BG; return end
        snipe = true; tgBtn.Text = "ON"; tgBtn.TextColor3 = GREEN; tgSt.Color = GREEN; tgBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        local kgV = parseKg(kBox.Text); local rarT = rBtn.Text
        task.spawn(function()
            while snipe do
                task.wait(3)
                local ok, r = pcall(function() return requestFunc({ Url = WEBHOOK_PRIVATE .. "?limit=50", Method = "GET" }) end)
                if ok and r and r.Body then
                    local dec = HttpService:JSONDecode(r.Body)
                    if type(dec) == "table" then
                        local eggs = {}
                        for _, m in ipairs(dec) do if m.embeds and m.embeds[1] then local okL, l = pcall(function() return HttpService:JSONDecode(m.embeds[1].description) end); if okL and type(l) == "table" then for _, e in ipairs(l) do table.insert(eggs, e) end end end end
                        for _, e in ipairs(eggs) do
                            local mR = (rarT == "Any" or string.find(string.lower(e.rarity or ""), string.lower(rarT)))
                            local mK = false
                            if kgV == 0 then mK = true else local mag = 10 ^ math.floor(math.log10(kgV)); mK = ((e.scale or 0) >= kgV and (e.scale or 0) <= (math.floor(kgV / mag) + 1) * mag - 1) end
                            if mR and mK then
                                snipe = false; tgBtn.Text = "FOUND"; tgSt.Color = CYAN
                                pcall(function() setclipboard("roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. e.serverId) end)
                                task.wait(2); tgBtn.Text = "OFF"; tgBtn.TextColor3 = TXT_SUB; tgSt.Color = TXT_SUB; tgBtn.BackgroundColor3 = BG; break
                            end
                        end
                    end
                end
            end
        end)
    end)

    local function setTab(n, b, s)
        if aTab and aStr then aTab.BackgroundColor3 = CONTENT; aTab.TextColor3 = TXT_SUB; aStr.Transparency = 1 end
        if b and s then b.BackgroundColor3 = BOX_OUT; b.TextColor3 = CYAN; s.Transparency = 0; aTab = b; aStr = s end
        fHome.Visible = (n == "Home"); fAuto.Visible = (n == "Auto"); fLive.Visible = (n == "Live"); fServ.Visible = (n == "Serv")
        if n == "Serv" then pcall(refreshServ) end; if n == "Live" then pcall(fetchLive) end
    end

    tbHome.MouseButton1Click:Connect(function() setTab("Home", tbHome, stHome) end)
    tbAuto.MouseButton1Click:Connect(function() setTab("Auto", tbAuto, stAuto) end)
    tbLive.MouseButton1Click:Connect(function() setTab("Live", tbLive, stLive) end)
    tbServ.MouseButton1Click:Connect(function() setTab("Serv", tbServ, stServ) end)
    setTab("Home", tbHome, stHome)

    task.spawn(function() local lM = -1; while task.wait(1) do if fLive.Visible then local cM = tonumber(os.date("%M")); if cM % 5 == 0 and cM ~= lM then lM = cM; pcall(fetchLive) end end end end)
end

showKeyGui()