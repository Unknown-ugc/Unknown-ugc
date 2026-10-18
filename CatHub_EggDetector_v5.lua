-- Cat Hub | Egg Detector v5  (Luau)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)

-- ===== CONFIG =====
local API_BASE = "https://cat-hub-api.onrender.com"
-- the script tries these routes in order and remembers the first one that works
local ROUTES = { "/public-eggs?limit=50", "/eggs?limit=50", "/api/eggs?limit=50", "/live-eggs?limit=50" }
local DISCORD_LINK = "https://discord.gg/FJK6QzNnf7"
local REFRESH = 5
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ===== THEME =====
local C = {
    bg = Color3.fromRGB(10, 7, 18), side = Color3.fromRGB(15, 10, 26), card = Color3.fromRGB(23, 17, 38), card2 = Color3.fromRGB(32, 24, 52),
    p = Color3.fromRGB(168, 85, 247), c = Color3.fromRGB(34, 211, 238), pk = Color3.fromRGB(236, 72, 153),
    txt = Color3.fromRGB(245, 240, 255), sub = Color3.fromRGB(160, 150, 185), white = Color3.new(1, 1, 1),
    ok = Color3.fromRGB(74, 222, 128), warn = Color3.fromRGB(251, 191, 36), bad = Color3.fromRGB(239, 68, 68),
}
local RAR = {
    common = Color3.fromRGB(156, 163, 175), uncommon = Color3.fromRGB(74, 222, 128), rare = Color3.fromRGB(59, 130, 246),
    epic = Color3.fromRGB(168, 85, 247), legendary = Color3.fromRGB(245, 158, 11), mythic = Color3.fromRGB(239, 68, 68),
    cosmic = Color3.fromRGB(99, 102, 241), secret = Color3.fromRGB(236, 72, 153), eternal = Color3.fromRGB(20, 184, 166),
    divine = Color3.fromRGB(253, 224, 71),
}
local RAR_LIST = { "Any", "Secret", "Divine", "Eternal", "Cosmic", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }
local function rcol(r) return RAR[string.lower(tostring(r or ""))] or C.p end

-- ===== HELPERS =====
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function round(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, col, th, tr) return new("UIStroke", { Color = col, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o) end
local function grad(o, c1, c2, rot) return new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 0 }, o) end
local function tween(o, t, props) TS:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play() end
local function T(p, text, size, col, font, props)
    local l = new("TextLabel", { BackgroundTransparency = 1, Text = text, TextSize = size, TextColor3 = col, Font = font or Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }, p)
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end
local function B(p, text, size, bg, col, props, rad)
    local b = new("TextButton", { AutoButtonColor = false, BackgroundColor3 = bg, Text = text, TextSize = size, TextColor3 = col, Font = Enum.Font.GothamBold, BorderSizePixel = 0 }, p)
    for k, v in pairs(props or {}) do b[k] = v end
    round(b, rad or 8)
    return b
end
local function hover(b, base, over)
    b.MouseEnter:Connect(function() tween(b, .12, { BackgroundColor3 = over }) end)
    b.MouseLeave:Connect(function() tween(b, .12, { BackgroundColor3 = base }) end)
end
local function box(p, ph, props)
    local t = new("TextBox", { BackgroundColor3 = C.card, PlaceholderText = ph, PlaceholderColor3 = C.sub, Text = "", TextColor3 = C.txt, Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0 }, p)
    for k, v in pairs(props or {}) do t[k] = v end
    round(t, 8); stroke(t, C.p, 1, .6); new("UIPadding", { PaddingLeft = UDim.new(0, 12) }, t)
    return t
end
local function pulse(o) TS:Create(o, TweenInfo.new(.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = .65 }):Play() end
local function drag(handle, target)
    local dragging, startIn, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startIn = i.Position; startPos = target.Position; target:SetAttribute("moved", false)
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startIn
            if d.Magnitude > 6 then target:SetAttribute("moved", true) end
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
local function guiParent() return (gethui and gethui()) or LP:WaitForChild("PlayerGui") end

-- ===== DATA HELPERS =====
local MULT = { K = 1e3, M = 1e6, B = 1e9, T = 1e12 }
local function parseValue(s)
    if type(s) == "number" then return s end
    local n, u = tostring(s or ""):match("([%d%.]+)%s*([KMBTkmbt]?)")
    n = tonumber(n)
    if not n then return 0 end
    return n * (MULT[(u or ""):upper()] or 1)
end
local function parseKg(str)
    local s = string.lower(str or "")
    local n = tonumber(s:match("([%d%.]+)"))
    if not n then return 0 end
    if s:find("k") then n = n * 1000 end
    return n
end
local function compact(n)
    n = tonumber(n) or 0
    local function trim(v) local t = string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", ""); return t end
    local a = math.abs(n)
    if a >= 1e12 then return trim(n / 1e12) .. "T" end
    if a >= 1e9 then return trim(n / 1e9) .. "B" end
    if a >= 1e6 then return trim(n / 1e6) .. "M" end
    if a >= 1e3 then return trim(n / 1e3) .. "K" end
    return trim(n)
end
local function normImg(img)
    img = tostring(img or "")
    if img:match("^%d+$") then return "rbxassetid://" .. img end
    return img
end
local function pick(e, ...)
    for _, k in ipairs({ ... }) do if e[k] ~= nil and e[k] ~= "" then return e[k] end end
    return nil
end
local function normalize(e)
    if type(e) ~= "table" then return nil end
    local n = {}
    n.name = tostring(pick(e, "name", "eggName", "DisplayName", "title") or "Unknown Egg")
    n.rarity = tostring(pick(e, "rarity", "Rarity", "tier") or "Unknown")
    n.scale = tonumber(pick(e, "scale", "kg", "weight")) or 0
    n.sizeName = pick(e, "sizeName")
    n.serverId = pick(e, "serverId", "jobId", "gameInstanceId", "server_id")
    n.image = pick(e, "image", "icon", "Icon", "thumbnail")
    n.players = tonumber(pick(e, "players", "playerCount", "playing"))
    n.maxPlayers = tonumber(pick(e, "maxPlayers", "max"))
    n.valueNum = tonumber(pick(e, "valueNum", "earningRate")) or parseValue(e.value)
    n.value = e.value and tostring(e.value) or ("$" .. compact(n.valueNum) .. "/s")
    return n
end
local function extractList(d)
    if type(d) ~= "table" then return nil end
    if d[1] ~= nil or next(d) == nil then return d end
    for _, k in ipairs({ "eggs", "data", "items", "results", "records" }) do
        if type(d[k]) == "table" then return d[k] end
    end
    return nil
end

-- ===== LIVE EGG FETCH (with route fallback + exact error reason) =====
local activeRoute
local function pullEggs()
    if not requestFunc then return nil, "executor has no HTTP request function" end
    local routes = activeRoute and { activeRoute } or ROUTES
    local lastErr = "no response"
    for _, route in ipairs(routes) do
        local ok, res = pcall(requestFunc, { Url = API_BASE .. route, Method = "GET", Headers = { Accept = "application/json" } })
        if not ok then
            lastErr = "request failed: " .. tostring(res)
        elseif not res then
            lastErr = "empty response"
        else
            local code = tonumber(res.StatusCode) or 0
            if code >= 200 and code < 300 and res.Body then
                local okJ, dec = pcall(HttpService.JSONDecode, HttpService, res.Body)
                if okJ then
                    local list = extractList(dec)
                    if list then activeRoute = route; return list end
                    lastErr = "unexpected JSON shape"
                else
                    lastErr = "invalid JSON (server may be waking up)"
                end
            elseif code == 404 then
                lastErr = "HTTP 404 - route " .. route:match("^[^?]+") .. " not found on API"
            elseif code >= 500 or code == 0 then
                lastErr = "HTTP " .. code .. " - API is down or waking up, retrying"
            else
                lastErr = "HTTP " .. code
            end
        end
    end
    activeRoute = nil
    return nil, lastErr
end

local function joinServer(e)
    if not e.serverId then return false end
    pcall(function() if setclipboard then setclipboard("roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. e.serverId) end end)
    return (pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(e.serverId), LP) end))
end

-- ===== KEY GUI =====
local loadMainUI
local function showKeyGui()
    local g = new("ScreenGui", { Name = "CatHubKey", ResetOnSpawn = false, DisplayOrder = 999 }, guiParent())
    local f = new("Frame", { Size = UDim2.fromOffset(320, 300), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), BackgroundColor3 = C.white, BorderSizePixel = 0, Active = true }, g)
    round(f, 16); grad(f, Color3.fromRGB(30, 17, 52), Color3.fromRGB(9, 6, 15), 135)
    local st = stroke(f, C.white, 2)
    new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.p), ColorSequenceKeypoint.new(.5, C.c), ColorSequenceKeypoint.new(1, C.pk) }) }, st)
    drag(f, f)
    local t = T(f, "🐱 CAT HUB", 24, C.white, Enum.Font.GothamBlack, { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 18), TextXAlignment = Enum.TextXAlignment.Center })
    grad(t, C.p, C.c, 0)
    T(f, "ENTER YOUR KEY TO CONTINUE", 10, C.sub, Enum.Font.GothamBold, { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 50), TextXAlignment = Enum.TextXAlignment.Center })
    local input = box(f, "Enter key here...", { Size = UDim2.new(1, -40, 0, 38), Position = UDim2.fromOffset(20, 80) })
    local status = T(f, "", 10, C.bad, Enum.Font.Gotham, { Size = UDim2.new(1, -40, 0, 14), Position = UDim2.fromOffset(20, 122) })
    local submit = B(f, "Verify Key", 13, C.p, C.white, { Size = UDim2.new(1, -40, 0, 38), Position = UDim2.fromOffset(20, 144) }, 10)
    hover(submit, C.p, Color3.fromRGB(192, 132, 252))
    local dc = B(f, "💬  Copy Discord Invite", 12, Color3.fromRGB(88, 101, 242), C.white, { Size = UDim2.new(1, -40, 0, 38), Position = UDim2.fromOffset(20, 198) }, 10)
    dc.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(DISCORD_LINK) end)
        dc.Text = "✔  Copied!"; task.wait(2); dc.Text = "💬  Copy Discord Invite"
    end)
    T(f, "Cat Hub  •  Egg Detector v5", 9, C.sub, Enum.Font.Gotham, { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -26), TextXAlignment = Enum.TextXAlignment.Center })
    submit.MouseButton1Click:Connect(function()
        if input.Text == "CAT-HUB-2024" or input.Text == "FREE-CAT-SNIPER" then
            status.Text = "Key accepted! Loading..."; status.TextColor3 = C.ok
            task.wait(.8); g:Destroy(); loadMainUI()
        else
            status.Text = "Invalid key. Try again."; status.TextColor3 = C.bad; input.Text = ""
        end
    end)
end

-- ===== MAIN GUI =====
loadMainUI = function()
    local gui = new("ScreenGui", { Name = "CatHub", ResetOnSpawn = false, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, guiParent())
    local main = new("Frame", { Size = UDim2.fromOffset(750, 480), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), BackgroundColor3 = C.white, BorderSizePixel = 0, Active = true }, gui)
    round(main, 16); grad(main, Color3.fromRGB(28, 16, 50), Color3.fromRGB(8, 6, 14), 135)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
    local sc = new("UIScale", { Scale = math.min(1, math.max(280, vp.X - 20) / 750, math.max(240, vp.Y - 24) / 480) }, main)
    if IS_MOBILE then sc.Scale = math.min(sc.Scale, .9) end
    local ms = stroke(main, C.white, 2)
    local mg = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.p), ColorSequenceKeypoint.new(.5, C.c), ColorSequenceKeypoint.new(1, C.pk) }) }, ms)
    task.spawn(function() while gui.Parent do mg.Rotation = (mg.Rotation + 1.5) % 360; task.wait(.03) end end)

    -- header
    local head = new("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true }, main)
    drag(head, main)
    local logo = T(head, "🐱 CAT HUB", 20, C.white, Enum.Font.GothamBlack, { Position = UDim2.fromOffset(16, 6), Size = UDim2.fromOffset(200, 26) })
    grad(logo, C.p, C.c, 0)
    T(head, "EGG DETECTOR  •  v5", 9, C.sub, Enum.Font.GothamBold, { Position = UDim2.fromOffset(18, 30), Size = UDim2.fromOffset(200, 12) })
    local pillH = new("Frame", { Size = UDim2.fromOffset(104, 24), Position = UDim2.new(1, -190, 0, 12), BackgroundColor3 = C.card2, BorderSizePixel = 0 }, head)
    round(pillH, 12); local pillSt = stroke(pillH, C.warn, 1, .3)
    local hDot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(10, 8), BackgroundColor3 = C.warn, BorderSizePixel = 0 }, pillH); round(hDot, 4); pulse(hDot)
    local hTxt = T(pillH, "CONNECTING", 9, C.warn, Enum.Font.GothamBold, { Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -28, 1, 0) })
    local minBtn = B(head, "–", 16, C.card2, C.txt, { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -76, 0, 9) }, 9)
    local closeBtn = B(head, "✕", 13, C.card2, C.txt, { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0, 9) }, 9)
    hover(minBtn, C.card2, C.p); hover(closeBtn, C.card2, C.bad)

    local mini = new("ImageButton", { Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(24, 90), BackgroundColor3 = C.bg, Image = "rbxthumb://type=Asset&id=85043883236326&w=420&h=420", Visible = false, ZIndex = 40, Active = true }, gui)
    round(mini, 32); stroke(mini, C.p, 3); drag(mini, mini)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    minBtn.MouseButton1Click:Connect(function() main.Visible = false; mini.Visible = true end)
    mini.MouseButton1Click:Connect(function()
        if mini:GetAttribute("moved") then mini:SetAttribute("moved", false) return end
        mini.Visible = false; main.Visible = true
    end)

    -- sidebar
    local side = new("Frame", { Size = UDim2.new(0, 150, 1, -58), Position = UDim2.fromOffset(10, 52), BackgroundColor3 = C.side, BorderSizePixel = 0 }, main)
    round(side, 12); stroke(side, C.p, 1, .7)
    local tabs = {}
    local function mkTab(key, txt, y)
        local b = B(side, txt, 12, C.card2, C.sub, { Size = UDim2.new(1, -20, 0, 40), Position = UDim2.fromOffset(10, y), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }, 10)
        new("UIPadding", { PaddingLeft = UDim.new(0, 16) }, b)
        local bar = new("Frame", { Size = UDim2.new(0, 4, .6, 0), Position = UDim2.new(0, -10, .2, 0), BackgroundColor3 = C.pk, BorderSizePixel = 0, Visible = false }, b); round(bar, 2)
        tabs[key] = { b = b, bar = bar }
        return b
    end
    local tbHome, tbAuto, tbLive, tbServ = mkTab("Home", "🏠   Home", 12), mkTab("Auto", "⚡   Auto Join", 58), mkTab("Live", "🥚   Live Eggs", 104), mkTab("Serv", "🖥   Server", 150)
    local dcBtn = B(side, "💬  Discord", 11, Color3.fromRGB(88, 101, 242), C.white, { Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 1, -46) }, 10)
    dcBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(DISCORD_LINK) end)
        dcBtn.Text = "✔  Link copied"; task.wait(2); dcBtn.Text = "💬  Discord"
    end)

    -- pages
    local function mkPage()
        local f = new("Frame", { Size = UDim2.new(1, -180, 1, -58), Position = UDim2.fromOffset(170, 52), BackgroundColor3 = C.card, BorderSizePixel = 0, Visible = false, ClipsDescendants = true }, main)
        round(f, 12); stroke(f, C.p, 1, .7)
        return f
    end
    local function mkCard(p, y, h)
        local c = new("Frame", { Size = UDim2.new(1, -28, 0, h), Position = UDim2.fromOffset(14, y), BackgroundColor3 = C.card2, BorderSizePixel = 0 }, p)
        round(c, 10); stroke(c, C.p, 1, .75)
        return c
    end
    local fHome, fAuto, fLive, fServ = mkPage(), mkPage(), mkPage(), mkPage()
    local function scroller(p, pos, size)
        local s = new("ScrollingFrame", { Position = pos, Size = size, BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.p, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, p)
        new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, s)
        return s
    end

    -- HOME
    local hero = mkCard(fHome, 14, 88)
    local ht = T(hero, "Welcome to Cat Hub", 18, C.white, Enum.Font.GothamBlack, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 24) }); grad(ht, C.p, C.c, 0)
    T(hero, "Live egg discoveries, rarity tracking and value ranking — all in one place.", 11, C.sub, Enum.Font.Gotham, { Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -32, 0, 36), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })
    local statRow = new("Frame", { Size = UDim2.new(1, -28, 0, 78), Position = UDim2.fromOffset(14, 114), BackgroundTransparency = 1 }, fHome)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10) }, statRow)
    local function tile(cap)
        local t = new("Frame", { Size = UDim2.new(1 / 3, -7, 1, 0), BackgroundColor3 = C.card2, BorderSizePixel = 0 }, statRow)
        round(t, 10); stroke(t, C.p, 1, .75)
        local v = T(t, "—", 20, C.txt, Enum.Font.GothamBlack, { Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -28, 0, 28), TextTruncate = Enum.TextTruncate.AtEnd })
        T(t, cap, 9, C.sub, Enum.Font.GothamBold, { Position = UDim2.fromOffset(14, 46), Size = UDim2.new(1, -28, 0, 14) })
        return v
    end
    local statLive, statTop, statApi = tile("LIVE EGGS"), tile("TOP VALUE"), tile("API STATUS")
    local tips = mkCard(fHome, 204, 112)
    T(tips, "HOW IT WORKS", 11, C.c, Enum.Font.GothamBold, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 16) })
    T(tips, "1.  Open Live Eggs to watch detections in real time.\n2.  Pick a rarity + minimum KG in Auto Join.\n3.  Tap JOIN on any egg to jump into its server.", 11, C.sub, Enum.Font.Gotham, { Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -32, 0, 70), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })

    -- chips
    local function chipGroup(parent, items, default, onSel)
        local chips = {}
        local function sel(n)
            for k, b in pairs(chips) do
                local on = (k == n)
                tween(b, .12, { BackgroundColor3 = on and rcol(k ~= "Any" and k or nil) or C.card })
                b.TextColor3 = on and C.white or C.sub
            end
            onSel(n)
        end
        for _, n in ipairs(items) do
            local b = B(parent, n, 11, C.card, C.sub, { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26) }, 13)
            new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, b)
            chips[n] = b
            b.MouseButton1Click:Connect(function() sel(n) end)
        end
        return function() sel(default) end
    end

    -- AUTO JOIN
    local autoRarity, snipe = "Any", false
    local rcard = mkCard(fAuto, 14, 104)
    T(rcard, "TARGET RARITY", 11, C.c, Enum.Font.GothamBold, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 16) })
    local rchips = new("Frame", { Position = UDim2.fromOffset(16, 34), Size = UDim2.new(1, -32, 0, 62), BackgroundTransparency = 1 }, rcard)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 6) }, rchips)
    chipGroup(rchips, RAR_LIST, "Any", function(n) autoRarity = n end)()
    local kcard = mkCard(fAuto, 132, 76)
    T(kcard, "MINIMUM KG", 11, C.c, Enum.Font.GothamBold, { Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -32, 0, 16) })
    local kBox = box(kcard, "1000 or 1k", { Size = UDim2.new(1, -32, 0, 32), Position = UDim2.fromOffset(16, 32) })
    local tcard = mkCard(fAuto, 222, 76)
    T(tcard, "AUTO JOIN", 14, C.txt, Enum.Font.GothamBlack, { Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -100, 0, 20) })
    local autoStatus = T(tcard, "Auto join is off", 11, C.sub, Enum.Font.Gotham, { Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -100, 0, 28), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })
    local tgBtn = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(54, 28), AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -16, .5, 0), BackgroundColor3 = C.card, BorderSizePixel = 0 }, tcard)
    round(tgBtn, 14); local tgSt = stroke(tgBtn, C.sub, 2)
    local knob = new("Frame", { Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(4, 4), BackgroundColor3 = C.sub, BorderSizePixel = 0 }, tgBtn); round(knob, 10)
    local function setToggle(on)
        snipe = on
        tween(knob, .18, { Position = on and UDim2.fromOffset(30, 4) or UDim2.fromOffset(4, 4), BackgroundColor3 = on and C.ok or C.sub })
        tween(tgBtn, .18, { BackgroundColor3 = on and Color3.fromRGB(14, 60, 34) or C.card })
        tgSt.Color = on and C.ok or C.sub
        autoStatus.Text = on and "Watching the live feed for a match…" or "Auto join is off"
    end
    tgBtn.MouseButton1Click:Connect(function() setToggle(not snipe) end)

    -- LIVE
    local sBox = box(fLive, "Search by egg name...", { Size = UDim2.new(1, -128, 0, 34), Position = UDim2.fromOffset(14, 12) })
    local refBtn = B(fLive, "⟳  Refresh", 11, C.p, C.white, { Size = UDim2.fromOffset(92, 34), Position = UDim2.new(1, -106, 0, 12) }, 8)
    hover(refBtn, C.p, Color3.fromRGB(192, 132, 252))
    local chipScroll = new("ScrollingFrame", { Position = UDim2.fromOffset(14, 54), Size = UDim2.new(1, -28, 0, 30), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X }, fLive)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center }, chipScroll)
    local liveDot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(16, 98), BackgroundColor3 = C.warn, BorderSizePixel = 0 }, fLive); round(liveDot, 4); pulse(liveDot)
    local lTxt = T(fLive, "LIVE  •  CONNECTING", 10, C.warn, Enum.Font.GothamBold, { Position = UDim2.fromOffset(30, 90), Size = UDim2.new(1, -44, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd })
    local lScr = scroller(fLive, UDim2.fromOffset(14, 118), UDim2.new(1, -28, 1, -128))

    -- SERVER
    local sScr = scroller(fServ, UDim2.fromOffset(14, 14), UDim2.new(1, -28, 1, -28))

    -- row builder
    local function mkRow(e, parent, showJoin, isNew)
        local col = rcol(e.rarity)
        local r = new("Frame", { Size = UDim2.new(1, -6, 0, 62), BackgroundColor3 = C.card2, BorderSizePixel = 0 }, parent)
        round(r, 12)
        local st = stroke(r, col, 1, .55)
        if isNew then st.Thickness = 2; st.Transparency = 0; tween(st, 1.6, { Thickness = 1, Transparency = .55 }) end
        local bar = new("Frame", { Size = UDim2.new(0, 4, 1, -20), Position = UDim2.fromOffset(0, 10), BackgroundColor3 = col, BorderSizePixel = 0 }, r); round(bar, 2)
        local tileF = new("Frame", { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(12, 9), BackgroundColor3 = col, BackgroundTransparency = .82, BorderSizePixel = 0 }, r)
        round(tileF, 10); stroke(tileF, col, 1, .6)
        local imgId = normImg(e.image)
        if imgId ~= "" then
            new("ImageLabel", { Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 1, Image = imgId, ScaleType = Enum.ScaleType.Fit }, tileF)
        else
            T(tileF, "🥚", 24, C.white, Enum.Font.GothamBold, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
        end
        T(r, e.name, 14, C.txt, Enum.Font.GothamBold, { Position = UDim2.fromOffset(66, 8), Size = UDim2.new(1, showJoin and -230 or -150, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
        local line = new("Frame", { Position = UDim2.fromOffset(66, 32), Size = UDim2.new(1, showJoin and -230 or -150, 0, 18), BackgroundTransparency = 1 }, r)
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center }, line)
        local pill = T(line, string.upper(e.rarity), 9, C.white, Enum.Font.GothamBold, { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0, BackgroundColor3 = col, TextXAlignment = Enum.TextXAlignment.Center })
        round(pill, 8); new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, pill)
        local parts = {}
        if e.sizeName then table.insert(parts, tostring(e.sizeName)) elseif e.scale > 0 then table.insert(parts, compact(e.scale) .. " KG") end
        if e.players then table.insert(parts, "👥 " .. e.players .. (e.maxPlayers and ("/" .. e.maxPlayers) or "")) end
        if #parts > 0 then T(line, table.concat(parts, "  •  "), 10, C.sub, Enum.Font.GothamMedium, { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X }) end
        local v = T(r, e.value, 12, C.warn, Enum.Font.GothamBlack, { Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, showJoin and -84 or -14, .5, 0), BackgroundTransparency = .85, BackgroundColor3 = C.warn, TextXAlignment = Enum.TextXAlignment.Center })
        round(v, 12); new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, v)
        if showJoin then
            local j = B(r, "JOIN", 11, C.p, C.white, { Size = UDim2.fromOffset(62, 32), AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0) }, 9)
            hover(j, C.p, Color3.fromRGB(192, 132, 252))
            j.MouseButton1Click:Connect(function()
                j.Text = joinServer(e) and "…" or "N/A"; task.wait(1.2); j.Text = "JOIN"
            end)
        end
    end

    -- live state
    local cache, seen, firstDone = {}, {}, false
    local selectedRarity = "Any"
    local lastErr
    local function setStatus(txt, col)
        lTxt.Text = txt; lTxt.TextColor3 = col; liveDot.BackgroundColor3 = col
        hDot.BackgroundColor3 = col; pillSt.Color = col; hTxt.TextColor3 = col
        hTxt.Text = (col == C.ok) and "LIVE" or ((col == C.bad) and "OFFLINE" or "CONNECTING")
    end
    local function matches(e)
        local q = string.lower(sBox.Text or "")
        return (q == "" or string.find(string.lower(e.name), q, 1, true) ~= nil)
            and (selectedRarity == "Any" or string.lower(e.rarity) == string.lower(selectedRarity))
    end
    local function redraw()
        for _, c in ipairs(lScr:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        local shown = 0
        for _, e in ipairs(cache) do
            if matches(e) and shown < 60 then mkRow(e, lScr, true, e._new); shown += 1 end
            e._new = false
        end
        if shown == 0 then
            local empty = T(lScr, (#cache == 0) and ("No live eggs yet.\n" .. (lastErr and ("Reason: " .. lastErr) or "Waiting for the detector…")) or "No eggs match this search / filter.", 12, C.sub, Enum.Font.Gotham, { Size = UDim2.new(1, -6, 0, 60), BackgroundTransparency = 0, BackgroundColor3 = C.card2, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center })
            round(empty, 10)
        end
    end
    chipGroup(chipScroll, RAR_LIST, "Any", function(n) selectedRarity = n; redraw() end)()
    sBox:GetPropertyChangedSignal("Text"):Connect(redraw)

    -- server snapshot (unchanged logic)
    local Assets, Networking
    pcall(function() Assets = require(RS.Data.Assets); Networking = RS.Packages.Networking end)
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
                        local earning = (tonumber(e.EarningRate) or 0) * (s ^ 1.5)
                        table.insert(t, { name = tostring(e.DisplayName or rc.AssetCategory), rarity = e.Rarity and tostring(e.Rarity.DisplayName) or "Unknown", scale = s, valueNum = earning, value = "$" .. compact(earning) .. "/s", image = tostring(e.Icon or "") })
                    end
                end
            end
        end)
        table.sort(t, function(a, b) return a.valueNum > b.valueNum end)
        return t
    end
    local function refreshServ()
        for _, c in ipairs(sScr:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        local eggs = getMyEggs()
        for _, e in ipairs(eggs) do mkRow(e, sScr, false, false) end
        if #eggs == 0 then
            round(T(sScr, "No eggs found in this server snapshot.", 12, C.sub, Enum.Font.Gotham, { Size = UDim2.new(1, -6, 0, 52), BackgroundTransparency = 0, BackgroundColor3 = C.card2, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center }), 10)
        end
    end

    -- auto join check
    local function checkSnipe()
        if not snipe then return end
        local minKg = parseKg(kBox.Text)
        for _, e in ipairs(cache) do
            local okR = autoRarity == "Any" or string.lower(e.rarity) == string.lower(autoRarity)
            local okK = minKg == 0 or e.scale >= minKg
            if okR and okK and e.serverId and tostring(e.serverId) ~= game.JobId then
                setToggle(false)
                autoStatus.Text = "Found " .. e.name .. " — joining…"
                joinServer(e)
                return
            end
        end
    end

    -- fetch
    local fetching = false
    local function fetchLive(manual)
        if fetching then return end
        fetching = true
        local ok, err = pcall(function()
            if manual or #cache == 0 then setStatus("LIVE  •  connecting… (first load can take ~30s)", C.warn) end
            local list, e = pullEggs()
            if not list then
                lastErr = e
                setStatus("API ERROR  •  " .. tostring(e), C.bad)
                statApi.Text = "ERROR"; statApi.TextColor3 = C.bad
                redraw()
                return
            end
            lastErr = nil
            local out = {}
            for _, raw in ipairs(list) do
                local n = normalize(raw)
                if n then
                    local k = tostring(n.serverId or "") .. "|" .. n.name .. "|" .. tostring(n.valueNum)
                    n._new = firstDone and not seen[k]
                    seen[k] = true
                    table.insert(out, n)
                end
            end
            table.sort(out, function(a, b) return a.valueNum > b.valueNum end)
            cache = out; firstDone = true
            setStatus(("LIVE  •  %d eggs  •  updated %s"):format(#cache, os.date("%H:%M:%S")), C.ok)
            statLive.Text = tostring(#cache)
            statTop.Text = cache[1] and cache[1].value or "—"
            statApi.Text = "ONLINE"; statApi.TextColor3 = C.ok
            redraw()
            checkSnipe()
        end)
        if not ok then setStatus("SCRIPT ERROR  •  " .. tostring(err), C.bad) end
        fetching = false
    end
    refBtn.MouseButton1Click:Connect(function() task.spawn(fetchLive, true) end)

    -- tabs
    local pages = { Home = fHome, Auto = fAuto, Live = fLive, Serv = fServ }
    local function setTab(n)
        for k, p in pairs(pages) do p.Visible = (k == n) end
        for k, t in pairs(tabs) do
            local on = (k == n)
            tween(t.b, .15, { BackgroundTransparency = on and 0 or 1 })
            t.b.TextColor3 = on and C.txt or C.sub
            t.bar.Visible = on
        end
        if n == "Serv" then task.spawn(pcall, refreshServ) end
    end
    tbHome.MouseButton1Click:Connect(function() setTab("Home") end)
    tbAuto.MouseButton1Click:Connect(function() setTab("Auto") end)
    tbLive.MouseButton1Click:Connect(function() setTab("Live") end)
    tbServ.MouseButton1Click:Connect(function() setTab("Serv") end)
    setTab("Home")

    -- background poller (one request feeds Home, Live and Auto Join)
    task.spawn(function()
        while gui.Parent do
            fetchLive(false)
            if fServ.Visible then pcall(refreshServ) end
            task.wait(REFRESH)
        end
    end)
end

showKeyGui()
