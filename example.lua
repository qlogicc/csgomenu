local SentinelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qlogicc/csgomenu/refs/heads/main/sentinel.lua"))()

-- In production: replace with loadstring(game:HttpGet("..."))()
local SentinelUI = require(script.Parent.SentinelUI)

local Window = SentinelUI:CreateWindow({
    Title    = "SENTINEL",
    Subtitle = "v1.0.0 | build 240",
    KeyBind  = Enum.KeyCode.Insert,
})

-- ============================================================
-- TAB: AIMBOT
-- ============================================================
local AimbotTab = Window:AddTab({ Name = "Aimbot", Icon = "crosshair" })

AimbotTab:AddSection("GENERAL")

local aimbotEnabled = AimbotTab:AddToggle({
    Name     = "Enable Aimbot",
    Desc     = "Locks aim to nearest target",
    Default  = false,
    Callback = function(v)
        print("Aimbot:", v)
    end,
})

local triggerbot = AimbotTab:AddToggle({
    Name     = "Triggerbot",
    Desc     = "Auto-fires when on target",
    Default  = false,
    Callback = function(v)
        print("Triggerbot:", v)
    end,
})

local smoothing = AimbotTab:AddSlider({
    Name     = "Smoothing",
    Min      = 1,
    Max      = 100,
    Default  = 25,
    Suffix   = "%",
    Callback = function(v)
        print("Smoothing:", v)
    end,
})

local fov = AimbotTab:AddSlider({
    Name     = "FOV Radius",
    Min      = 10,
    Max      = 500,
    Default  = 150,
    Suffix   = "px",
    Callback = function(v)
        print("FOV:", v)
    end,
})

AimbotTab:AddSection("TARGETING")

local hitbox = AimbotTab:AddDropdown({
    Name    = "Hitbox",
    Options = { "Head", "Neck", "Torso", "Nearest" },
    Default = "Head",
    Callback = function(v)
        print("Hitbox:", v)
    end,
})

local teamCheck = AimbotTab:AddToggle({
    Name     = "Team Check",
    Default  = true,
    Callback = function(v) end,
})

local wallCheck = AimbotTab:AddToggle({
    Name     = "Wall Check",
    Default  = true,
    Callback = function(v) end,
})

AimbotTab:AddSection("KEYBINDS")

local aimbotKey = AimbotTab:AddKeybind({
    Name     = "Aimbot Key",
    Default  = Enum.KeyCode.Q,
    Callback = function(k)
        print("New aimbot key:", k)
    end,
})

-- ============================================================
-- TAB: ESP
-- ============================================================
local ESPTab = Window:AddTab({ Name = "ESP", Icon = "eye" })

ESPTab:AddSection("PLAYER ESP")

local espEnabled = ESPTab:AddToggle({
    Name     = "Enable ESP",
    Default  = false,
    Callback = function(v) print("ESP:", v) end,
})

local boxESP = ESPTab:AddToggle({
    Name     = "Boxes",
    Default  = true,
    Callback = function(v) end,
})

local skeletonESP = ESPTab:AddToggle({
    Name     = "Skeleton",
    Default  = false,
    Callback = function(v) end,
})

local healthBar = ESPTab:AddToggle({
    Name     = "Health Bar",
    Default  = true,
    Callback = function(v) end,
})

local nameESP = ESPTab:AddToggle({
    Name     = "Names",
    Default  = true,
    Callback = function(v) end,
})

local distESP = ESPTab:AddToggle({
    Name     = "Distance",
    Default  = true,
    Callback = function(v) end,
})

ESPTab:AddSection("COLORS")

local espColor = ESPTab:AddColorPicker({
    Name     = "ESP Color (Enemy)",
    Default  = Color3.fromRGB(255, 60, 60),
    Callback = function(c) end,
})

local espColorTeam = ESPTab:AddColorPicker({
    Name     = "ESP Color (Team)",
    Default  = Color3.fromRGB(60, 200, 100),
    Callback = function(c) end,
})

ESPTab:AddSection("WORLD")

local itemESP = ESPTab:AddToggle({
    Name     = "Item ESP",
    Default  = false,
    Callback = function(v) end,
})

local chamsEnabled = ESPTab:AddToggle({
    Name     = "Chams",
    Default  = false,
    Callback = function(v) end,
})

local chamStyle = ESPTab:AddDropdown({
    Name    = "Chams Style",
    Options = { "Flat", "Shiny", "Glass", "Neon" },
    Default = "Flat",
    Callback = function(v) end,
})

-- ============================================================
-- TAB: MISC
-- ============================================================
local MiscTab = Window:AddTab({ Name = "Misc", Icon = "misc" })

MiscTab:AddSection("MOVEMENT")

local bunnyHop = MiscTab:AddToggle({
    Name     = "Bunny Hop",
    Default  = false,
    Callback = function(v) end,
})

local speedMode = MiscTab:AddDropdown({
    Name    = "Speed Mode",
    Options = { "Off", "Walk", "Sprint", "Fly" },
    Default = "Off",
    Callback = function(v) end,
})

local speedMult = MiscTab:AddSlider({
    Name     = "Speed Multiplier",
    Min      = 1,
    Max      = 10,
    Default  = 1,
    Suffix   = "x",
    Callback = function(v) end,
})

local noclip = MiscTab:AddToggle({
    Name     = "Noclip",
    Default  = false,
    Callback = function(v) end,
})

MiscTab:AddSection("VISUAL")

local fovChanger = MiscTab:AddSlider({
    Name     = "FOV Changer",
    Min      = 70,
    Max      = 130,
    Default  = 90,
    Suffix   = "°",
    Callback = function(v)
        -- game.Workspace.CurrentCamera.FieldOfView = v
    end,
})

local crosshairToggle = MiscTab:AddToggle({
    Name     = "Custom Crosshair",
    Default  = false,
    Callback = function(v) end,
})

MiscTab:AddSection("UTILITY")

MiscTab:AddButton({
    Name     = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
    end,
})

MiscTab:AddButton({
    Name     = "Copy Player Info",
    Callback = function()
        local p = game:GetService("Players").LocalPlayer
        setclipboard("Name: " .. p.Name .. " | ID: " .. p.UserId)
    end,
})

MiscTab:AddButton({
    Name     = "Crash Server",
    Danger   = true,
    Callback = function()
        -- placeholder
    end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local SettingsTab = Window:AddTab({ Name = "Config", Icon = "gear" })

SettingsTab:AddSection("INTERFACE")

local uiScale = SettingsTab:AddSlider({
    Name     = "UI Scale",
    Min      = 80,
    Max      = 120,
    Default  = 100,
    Suffix   = "%",
    Callback = function(v) end,
})

local uiOpacity = SettingsTab:AddSlider({
    Name     = "UI Opacity",
    Min      = 40,
    Max      = 100,
    Default  = 95,
    Suffix   = "%",
    Callback = function(v) end,
})

SettingsTab:AddSection("CONFIG")

local configName = SettingsTab:AddInput({
    Name        = "Config Name",
    Placeholder = "default",
    Default     = "myconfig",
    Callback    = function(v) end,
})

SettingsTab:AddButton({
    Name     = "Save Config",
    Callback = function()
        -- writefile("sentinel_" .. configName:Get() .. ".json", ...)
        AimbotTab:Notify({
            Title    = "Config Saved",
            Desc     = "Saved as: " .. configName:Get(),
            Type     = "success",
            Duration = 3,
        })
    end,
})

SettingsTab:AddButton({
    Name     = "Load Config",
    Callback = function()
        AimbotTab:Notify({
            Title    = "Config Loaded",
            Desc     = "Loaded: " .. configName:Get(),
            Type     = "info",
            Duration = 3,
        })
    end,
})

SettingsTab:AddButton({
    Name     = "Reset to Default",
    Danger   = true,
    Callback = function()
        aimbotEnabled:Set(false)
        smoothing:Set(25)
        fov:Set(150)
        hitbox:Set("Head")
    end,
})

SettingsTab:AddSection("INFO")

SettingsTab:AddLabel({ Text = "SentinelUI v1.0.0", Icon = "lightning" })
SettingsTab:AddLabel({ Text = "github.com/yourusername/SentinelUI", Icon = "info" })
SettingsTab:AddSeparator()
SettingsTab:AddLabel({ Text = "Press INSERT to toggle visibility", Icon = "target" })

-- Boot notification
task.wait(0.5)
AimbotTab:Notify({
    Title    = "SENTINEL LOADED",
    Desc     = "Press INSERT to toggle",
    Type     = "success",
    Duration = 4,
})
