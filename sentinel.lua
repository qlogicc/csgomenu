--[[
    SentinelUI v1.0.0
    CSGO-Style Roblox UI Library
    PC + Mobile responsive | loadstring compatible
    
    Usage:
        local SentinelUI = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
        local Window = SentinelUI:CreateWindow({ Title = "My Cheat", Subtitle = "v1.0" })
        local Tab = Window:AddTab({ Name = "Aimbot", Icon = "crosshair" })
        Tab:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) end })
]]

local SentinelUI = {}
SentinelUI.__index = SentinelUI

-- Services
local Players       = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local HttpService   = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Mobile detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Theme
local Theme = {
    Background      = Color3.fromRGB(14, 14, 14),
    Surface         = Color3.fromRGB(22, 22, 22),
    SurfaceAlt      = Color3.fromRGB(28, 28, 28),
    Border          = Color3.fromRGB(42, 42, 42),
    BorderActive    = Color3.fromRGB(255, 165, 0),
    Accent          = Color3.fromRGB(255, 165, 0),
    AccentDim       = Color3.fromRGB(180, 115, 0),
    TextPrimary     = Color3.fromRGB(230, 230, 230),
    TextSecondary   = Color3.fromRGB(140, 140, 140),
    TextDisabled    = Color3.fromRGB(70, 70, 70),
    Success         = Color3.fromRGB(80, 200, 120),
    Danger          = Color3.fromRGB(220, 60, 60),
    TabActive       = Color3.fromRGB(255, 165, 0),
    TabInactive     = Color3.fromRGB(100, 100, 100),
    SliderFill      = Color3.fromRGB(255, 165, 0),
    ToggleOn        = Color3.fromRGB(255, 165, 0),
    ToggleOff       = Color3.fromRGB(55, 55, 55),
    DropdownBg      = Color3.fromRGB(18, 18, 18),
    InputBg         = Color3.fromRGB(18, 18, 18),
    Shadow          = Color3.fromRGB(0, 0, 0),
}

-- Utility
local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function MakePadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top or 0)
    p.PaddingRight  = UDim.new(0, right or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left or 0)
    p.Parent = parent
    return p
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function MakeListLayout(parent, dir, padding, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, padding or 0)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function AutoSize(frame, layout)
    layout.Changed:Connect(function()
        frame.Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset,
            0, layout.AbsoluteContentSize.Y
        )
    end)
end

-- Icon system (text-based CSGO-style symbols, maps to emoji/unicode)
local Icons = {
    crosshair   = "✛",
    eye         = "◉",
    shield      = "⬡",
    gear        = "⚙",
    lightning   = "⚡",
    skull       = "☠",
    lock        = "🔒",
    unlock      = "🔓",
    arrow_up    = "▲",
    arrow_down  = "▼",
    arrow_right = "▶",
    check       = "✓",
    x           = "✕",
    plus        = "+",
    minus       = "−",
    dot         = "●",
    star        = "★",
    flag        = "⚑",
    radar       = "◎",
    target      = "⊕",
    knife       = "⚔",
    bomb        = "✦",
    info        = "ℹ",
    warn        = "⚠",
    user        = "◈",
    team        = "⊞",
    gun         = "◆",
    bullet      = "▸",
    misc        = "≡",
    home        = "⌂",
}

local function GetIcon(name)
    return Icons[name] or Icons.dot
end

-- Dragging
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    local con1, con2, con3

    con1 = handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    con2 = UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ScreenGui
local function GetScreenGui()
    local gui
    if RunService:IsStudio() then
        gui = Instance.new("ScreenGui")
        gui.Name = "SentinelUI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = LocalPlayer.PlayerGui
    else
        gui = Instance.new("ScreenGui")
        gui.Name = "SentinelUI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        pcall(function() gui.DisplayOrder = 999 end)
        gui.Parent = game:GetService("CoreGui")
    end
    return gui
end

-- ============================================================
-- WINDOW
-- ============================================================

function SentinelUI:CreateWindow(config)
    config = config or {}
    local Title    = config.Title    or "SentinelUI"
    local Subtitle = config.Subtitle or "v1.0"
    local Width    = IsMobile and 320 or 560
    local Height   = IsMobile and 480 or 420
    local KeyBind  = config.KeyBind  or Enum.KeyCode.Insert

    local ScreenGui = GetScreenGui()

    -- Watermark
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 220, 0, 28),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    MakeCorner(Watermark, 3)
    MakeStroke(Watermark, Theme.Border, 1)
    MakePadding(Watermark, 0, 10, 0, 10)
    local WatermarkLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⚡ " .. Title .. "  |  " .. Subtitle,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark,
    })

    -- Main window frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, Width, 0, Height),
        Position = UDim2.new(0.5, -(Width/2), 0.5, -(Height/2)),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    MakeCorner(MainFrame, 5)
    MakeStroke(MainFrame, Theme.Border, 1)

    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    MakeStroke(Header, Theme.Border, 1)

    -- Accent bar top
    local AccentBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Header,
    })

    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "⚡  " .. string.upper(Title),
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    local SubLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1,
        Text = Subtitle,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Header,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(180, 40, 40),
        Text = "✕",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = Header,
    })
    MakeCorner(CloseBtn, 3)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, Width, 0, 0) })
        task.wait(0.21)
        MainFrame.Visible = false
    end)

    -- Minimize button
    local MinBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -68, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Text = "−",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = Header,
    })
    MakeCorner(MinBtn, 3)
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, Width, 0, 42) })
        else
            Tween(MainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, Width, 0, Height) })
        end
    end)

    MakeDraggable(MainFrame, Header)

    -- Body (tabs left + content right)
    local Body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })

    -- Tab sidebar
    local TabSidebar = Create("Frame", {
        Name = "TabSidebar",
        Size = UDim2.new(0, IsMobile and 52 or 120, 1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = Body,
    })
    MakeStroke(TabSidebar, Theme.Border, 1)

    local TabList = Create("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = TabSidebar,
    })
    local TabListLayout = MakeListLayout(TabList, Enum.FillDirection.Vertical, 2)
    MakePadding(TabList, 6, 4, 6, 4)

    -- Content area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -(IsMobile and 52 or 120), 1, 0),
        Position = UDim2.new(0, IsMobile and 52 or 120, 0, 0),
        BackgroundColor3 = Theme.SurfaceAlt,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Body,
    })

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == KeyBind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Window object
    local Window = {
        _gui        = ScreenGui,
        _main       = MainFrame,
        _content    = ContentArea,
        _tabList    = TabList,
        _tabs       = {},
        _activeTab  = nil,
    }

    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Tab"
        local TabIcon = tabConfig.Icon or "dot"

        -- Tab button
        local TabBtn = Create("TextButton", {
            Name = "Tab_" .. TabName,
            Size = UDim2.new(1, 0, 0, IsMobile and 44 or 38),
            BackgroundColor3 = Theme.SurfaceAlt,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = self._tabList,
        })
        MakeCorner(TabBtn, 3)

        local TabIconLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, IsMobile and 20 or 18),
            Position = UDim2.new(0, 0, 0, IsMobile and 4 or 4),
            BackgroundTransparency = 1,
            Text = GetIcon(TabIcon),
            TextColor3 = Theme.TabInactive,
            TextSize = IsMobile and 16 or 14,
            Font = Enum.Font.Gotham,
            Parent = TabBtn,
        })
        local TabNameLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, IsMobile and 24 or 20),
            BackgroundTransparency = 1,
            Text = TabName,
            TextColor3 = Theme.TabInactive,
            TextSize = IsMobile and 9 or 10,
            Font = Enum.Font.GothamBold,
            Parent = TabBtn,
        })

        -- Active indicator bar
        local ActiveBar = Create("Frame", {
            Size = UDim2.new(0, 3, 0.7, 0),
            Position = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = TabBtn,
        })
        MakeCorner(ActiveBar, 2)

        -- Tab content page
        local TabPage = Create("ScrollingFrame", {
            Name = "Page_" .. TabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = self._content,
        })
        local PageLayout = MakeListLayout(TabPage, Enum.FillDirection.Vertical, 4)
        MakePadding(TabPage, 8, 8, 8, 8)
        PageLayout.Changed:Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 16)
        end)

        local function Activate()
            -- Deactivate all
            for _, t in ipairs(Window._tabs) do
                t._page.Visible = false
                t._icon.TextColor3 = Theme.TabInactive
                t._name.TextColor3 = Theme.TabInactive
                t._btn.BackgroundColor3 = Theme.SurfaceAlt
                t._bar.Visible = false
            end
            -- Activate this
            TabPage.Visible = true
            TabIconLabel.TextColor3 = Theme.Accent
            TabNameLabel.TextColor3 = Theme.Accent
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ActiveBar.Visible = true
            Window._activeTab = TabObj
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        local TabObj = {
            _btn  = TabBtn,
            _page = TabPage,
            _icon = TabIconLabel,
            _name = TabNameLabel,
            _bar  = ActiveBar,
            _layout = PageLayout,
            Activate = Activate,
        }

        table.insert(self._tabs, TabObj)

        -- Auto-activate first tab
        if #self._tabs == 1 then
            task.defer(Activate)
        end

        -- =============================================
        -- COMPONENT METHODS
        -- =============================================

        -- Section header
        function TabObj:AddSection(name)
            local Section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            local Line = Create("Frame", {
                Size = UDim2.new(0.4, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = Section,
            })
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -8, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text = string.upper(name),
                TextColor3 = Theme.TextSecondary,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section,
            })
            local Line2 = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = Section,
            })
            return Section
        end

        -- Toggle
        function TabObj:AddToggle(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Toggle"
            local Default  = cfg.Default  ~= nil and cfg.Default or false
            local Callback = cfg.Callback or function() end
            local Desc     = cfg.Desc

            local value = Default

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, Desc and 52 or 38),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(1, -52, 0, 18),
                Position = UDim2.new(0, 0, 0, Desc and 8 or 10),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Row,
            })

            if Desc then
                local DescLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -52, 0, 14),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = Desc,
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })
            end

            -- Toggle switch
            local SwitchBg = Create("Frame", {
                Size = UDim2.new(0, 36, 0, 20),
                Position = UDim2.new(1, -36, 0.5, -10),
                BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                Parent = Row,
            })
            MakeCorner(SwitchBg, 10)
            local SwitchKnob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                BorderSizePixel = 0,
                Parent = SwitchBg,
            })
            MakeCorner(SwitchKnob, 7)

            local function SetToggle(v)
                value = v
                Tween(SwitchBg, TweenInfo.new(0.15), {
                    BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff
                })
                Tween(SwitchKnob, TweenInfo.new(0.15), {
                    Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                })
                Callback(v)
            end

            Row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    SetToggle(not value)
                end
            end)

            local ToggleObj = {
                Set = function(self, v) SetToggle(v) end,
                Get = function(self) return value end,
            }
            return ToggleObj
        end

        -- Slider
        function TabObj:AddSlider(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Slider"
            local Min      = cfg.Min      or 0
            local Max      = cfg.Max      or 100
            local Default  = cfg.Default  or Min
            local Suffix   = cfg.Suffix   or ""
            local Callback = cfg.Callback or function() end

            local value = math.clamp(Default, Min, Max)

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 54),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local TopRow = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 0, 0, 10),
                BackgroundTransparency = 1,
                Parent = Row,
            })
            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TopRow,
            })
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(value) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = TopRow,
            })

            -- Track
            local Track = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 36),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = Row,
            })
            MakeCorner(Track, 3)

            local pct = (value - Min) / (Max - Min)
            local Fill = Create("Frame", {
                Size = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel = 0,
                Parent = Track,
            })
            MakeCorner(Fill, 3)

            local Thumb = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(pct, -6, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(230, 230, 230),
                BorderSizePixel = 0,
                Parent = Track,
            })
            MakeCorner(Thumb, 6)

            local dragging = false
            local function UpdateSlider(inputPos)
                local relX = math.clamp(inputPos.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local newPct = relX / Track.AbsoluteSize.X
                local newVal = math.floor(Min + (Max - Min) * newPct)
                value = math.clamp(newVal, Min, Max)
                local vPct = (value - Min) / (Max - Min)
                Tween(Fill, TweenInfo.new(0.05), { Size = UDim2.new(vPct, 0, 1, 0) })
                Tween(Thumb, TweenInfo.new(0.05), { Position = UDim2.new(vPct, -6, 0.5, -6) })
                ValueLabel.Text = tostring(value) .. Suffix
                Callback(value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    UpdateSlider(input.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local SliderObj = {
                Set = function(self, v)
                    value = math.clamp(v, Min, Max)
                    local vPct = (value - Min) / (Max - Min)
                    Tween(Fill, TweenInfo.new(0.1), { Size = UDim2.new(vPct, 0, 1, 0) })
                    Tween(Thumb, TweenInfo.new(0.1), { Position = UDim2.new(vPct, -6, 0.5, -6) })
                    ValueLabel.Text = tostring(value) .. Suffix
                    Callback(value)
                end,
                Get = function(self) return value end,
            }
            return SliderObj
        end

        -- Dropdown
        function TabObj:AddDropdown(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Dropdown"
            local Options  = cfg.Options  or {}
            local Default  = cfg.Default  or Options[1]
            local Callback = cfg.Callback or function() end

            local value = Default
            local open = false

            local Wrapper = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                Parent = TabPage,
            })
            MakeCorner(Wrapper, 4)
            MakeStroke(Wrapper, Theme.Border, 1)
            MakePadding(Wrapper, 0, 12, 0, 12)

            local Header2 = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Wrapper,
            })
            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header2,
            })
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(value or "Select..."),
                TextColor3 = Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Header2,
            })
            local Arrow = Create("TextLabel", {
                Size = UDim2.new(0, 16, 1, 0),
                Position = UDim2.new(1, -16, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextSecondary,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = Header2,
            })

            -- Dropdown list
            local DropList = Create("Frame", {
                Name = "DropList",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 10,
                Visible = false,
                Parent = Wrapper,
            })
            MakeCorner(DropList, 4)
            MakeStroke(DropList, Theme.Border, 1)
            local DropLayout = MakeListLayout(DropList, Enum.FillDirection.Vertical, 0)

            local function CloseDropdown()
                open = false
                Arrow.Text = "▼"
                Tween(DropList, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) })
                task.wait(0.16)
                DropList.Visible = false
            end

            local function OpenDropdown()
                open = true
                Arrow.Text = "▲"
                DropList.Visible = true
                local h = math.min(#Options * 28, 120)
                Tween(DropList, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, h) })
            end

            for _, opt in ipairs(Options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = tostring(opt),
                    TextColor3 = opt == value and Theme.Accent or Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    ZIndex = 11,
                    Parent = DropList,
                })
                MakePadding(OptBtn, 0, 0, 0, 10)
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.MouseButton1Click:Connect(function()
                    value = opt
                    ValueLabel.Text = tostring(opt)
                    Callback(opt)
                    for _, c in ipairs(DropList:GetChildren()) do
                        if c:IsA("TextButton") then
                            c.TextColor3 = c.Text == tostring(opt) and Theme.Accent or Theme.TextPrimary
                        end
                    end
                    CloseDropdown()
                end)
            end

            Header2.MouseButton1Click:Connect(function()
                if open then CloseDropdown() else OpenDropdown() end
            end)

            local DropObj = {
                Set = function(self, v)
                    value = v
                    ValueLabel.Text = tostring(v)
                    Callback(v)
                end,
                Get = function(self) return value end,
            }
            return DropObj
        end

        -- Button
        function TabObj:AddButton(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Button"
            local Callback = cfg.Callback or function() end
            local Desc     = cfg.Desc
            local Danger   = cfg.Danger   or false

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Danger and Theme.Danger or Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local Btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Row,
            })
            local BtnLabel = Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Danger and Theme.Danger or Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Btn,
            })
            local Arrow2 = Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                Text = "▶",
                TextColor3 = Danger and Theme.Danger or Theme.Accent,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = Btn,
            })

            Btn.MouseButton1Click:Connect(function()
                Tween(Row, TweenInfo.new(0.08), {
                    BackgroundColor3 = Danger and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(40, 35, 20)
                })
                task.wait(0.12)
                Tween(Row, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Surface })
                Callback()
            end)
        end

        -- TextInput
        function TabObj:AddInput(cfg)
            cfg = cfg or {}
            local Name        = cfg.Name        or "Input"
            local Placeholder = cfg.Placeholder or "Enter value..."
            local Default     = cfg.Default     or ""
            local Callback    = cfg.Callback    or function() end

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 54),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 0, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Row,
            })

            local InputBox = Create("TextBox", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel = 0,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = Theme.TextPrimary,
                PlaceholderColor3 = Theme.TextDisabled,
                TextSize = 12,
                Font = Enum.Font.Code,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = Row,
            })
            MakeCorner(InputBox, 3)
            MakePadding(InputBox, 0, 0, 0, 6)
            MakeStroke(InputBox, Theme.Border, 1)

            InputBox.Focused:Connect(function()
                Tween(InputBox, TweenInfo.new(0.1), { })
                MakeStroke(InputBox, Theme.Accent, 1)
            end)
            InputBox.FocusLost:Connect(function(enter)
                Callback(InputBox.Text, enter)
            end)

            local InputObj = {
                Set = function(self, v) InputBox.Text = v end,
                Get = function(self) return InputBox.Text end,
            }
            return InputObj
        end

        -- Keybind
        function TabObj:AddKeybind(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Keybind"
            local Default  = cfg.Default  or Enum.KeyCode.Unknown
            local Callback = cfg.Callback or function() end

            local value = Default
            local listening = false

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Row,
            })
            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0, 64, 0, 22),
                Position = UDim2.new(1, -64, 0.5, -11),
                BackgroundColor3 = Theme.SurfaceAlt,
                BorderSizePixel = 0,
                Text = value.Name,
                TextColor3 = Theme.Accent,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                Parent = Row,
            })
            MakeCorner(KeyBtn, 3)
            MakeStroke(KeyBtn, Theme.Border, 1)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Theme.TextSecondary
            end)
            UserInputService.InputBegan:Connect(function(input, processed)
                if listening and not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        value = input.KeyCode
                        listening = false
                        KeyBtn.Text = value.Name
                        KeyBtn.TextColor3 = Theme.Accent
                        Callback(value)
                    end
                end
            end)

            local KeyObj = {
                Set = function(self, k) value = k; KeyBtn.Text = k.Name end,
                Get = function(self) return value end,
            }
            return KeyObj
        end

        -- Color picker (basic swatch row)
        function TabObj:AddColorPicker(cfg)
            cfg = cfg or {}
            local Name     = cfg.Name     or "Color"
            local Default  = cfg.Default  or Color3.fromRGB(255, 165, 0)
            local Callback = cfg.Callback or function() end

            local value = Default

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
            MakeCorner(Row, 4)
            MakeStroke(Row, Theme.Border, 1)
            MakePadding(Row, 0, 12, 0, 12)

            local NameLabel = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Row,
            })

            -- Swatch
            local Swatch = Create("TextButton", {
                Size = UDim2.new(0, 36, 0, 20),
                Position = UDim2.new(1, -36, 0.5, -10),
                BackgroundColor3 = value,
                Text = "",
                Parent = Row,
            })
            MakeCorner(Swatch, 3)
            MakeStroke(Swatch, Theme.Border, 1)

            -- Quick presets on click
            local presets = {
                Color3.fromRGB(255, 165, 0),
                Color3.fromRGB(255, 60, 60),
                Color3.fromRGB(60, 200, 100),
                Color3.fromRGB(80, 160, 255),
                Color3.fromRGB(200, 80, 255),
                Color3.fromRGB(255, 255, 255),
            }
            local idx = 1
            Swatch.MouseButton1Click:Connect(function()
                idx = (idx % #presets) + 1
                value = presets[idx]
                Tween(Swatch, TweenInfo.new(0.1), { BackgroundColor3 = value })
                Callback(value)
            end)

            local ColorObj = {
                Set = function(self, c) value = c; Swatch.BackgroundColor3 = c end,
                Get = function(self) return value end,
            }
            return ColorObj
        end

        -- Label / info text
        function TabObj:AddLabel(cfg)
            cfg = cfg or {}
            local Text  = cfg.Text  or ""
            local Color = cfg.Color or Theme.TextSecondary
            local Icon2 = cfg.Icon

            local Row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabPage,
            })
            local Lbl = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = (Icon2 and (GetIcon(Icon2) .. "  ") or "") .. Text,
                TextColor3 = Color,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Row,
            })
            local LblObj = {
                Set = function(self, t) Lbl.Text = t end,
            }
            return LblObj
        end

        -- Separator line
        function TabObj:AddSeparator()
            local Sep = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = TabPage,
            })
        end

        -- Notification (static, top-right)
        function TabObj:Notify(cfg)
            cfg = cfg or {}
            local NTitle   = cfg.Title   or "Notice"
            local NDesc    = cfg.Desc    or ""
            local Duration = cfg.Duration or 3
            local NType    = cfg.Type    or "info" -- info | success | danger

            local colors = {
                info    = Theme.Accent,
                success = Theme.Success,
                danger  = Theme.Danger,
            }
            local icons2 = {
                info    = Icons.info,
                success = Icons.check,
                danger  = Icons.warn,
            }

            local NotifFrame = Create("Frame", {
                Size = UDim2.new(0, 240, 0, 56),
                Position = UDim2.new(1, 260, 1, -70),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Parent = ScreenGui,
            })
            MakeCorner(NotifFrame, 4)
            MakeStroke(NotifFrame, colors[NType] or Theme.Accent, 1)
            MakePadding(NotifFrame, 0, 12, 0, 12)

            local AccentStrip = Create("Frame", {
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = colors[NType] or Theme.Accent,
                BorderSizePixel = 0,
                Parent = NotifFrame,
            })

            local NTitleLbl = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text = (icons2[NType] or "") .. "  " .. NTitle,
                TextColor3 = colors[NType] or Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = NotifFrame,
            })
            local NDescLbl = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 14, 0, 28),
                BackgroundTransparency = 1,
                Text = NDesc,
                TextColor3 = Theme.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = NotifFrame,
            })

            -- Slide in
            Tween(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -252, 1, -70)
            })
            task.delay(Duration, function()
                Tween(NotifFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, 260, 1, -70) })
                task.wait(0.25)
                NotifFrame:Destroy()
            end)
        end

        return TabObj
    end

    return Window
end

return SentinelUI
