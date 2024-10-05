--!native
--!optimize 2

if not ExecutorSupport then print("[mspaint] Loading stopped, please use the official loadstring for mspaint. (ERROR: ExecutorSupport == nil)") return end
if getgenv().mspaint_loaded then print("[mspaint] Loading stopped. (ERROR: Already loaded)") return end

--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Loading Wait \\--
if not game:IsLoaded() then game.Loaded:Wait() end
if Players.LocalPlayer and Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") and Players.LocalPlayer.PlayerGui.LoadingUI.Enabled then
    repeat task.wait() until not game.Players.LocalPlayer.PlayerGui.LoadingUI.Enabled
end

--// Variables \\--
local Script = {
    Binded = {}, -- ty geo for idea :smartindividual:
    Connections = {},
    FeatureConnections = {
        Character = {},
        Clip = {},
        Door = {},
        Humanoid = {},
        Player = {},
        RootPart = {},
    },

    ESPTable = {
        Chest = {},
        Door = {},
        Entity = {},
        SideEntity = {},
        Gold = {},
        Guiding = {},
        Item = {},
        Objective = {},
        Player = {},
        HidingSpot = {},
        None = {}
    },

    Functions = {
        Minecart = {},
        Notifs = {Linoria = {}, Doors = {}}
    },

    Lagback = {
        Detected = false,
        Threshold = 1,
        Anchors = 0,
        LastAnchored = 0,
        LastSpeed = 0,
        LastFlySpeed = 0,
    },

    Temp = {
        AnchorFinished = {},
        AutoWardrobeEntities = {},
        Bridges = {},
        FlyBody = nil,
        Guidance = {},
        PaintingDebounce = false,
        UsedBreakers = {},
    },

    FakeRevive = {
        Debounce = false,
        Enabled = false,
        Connections = {}
    }
}

local WhitelistConfig = {
    [45] = {firstKeep = 3, lastKeep = 2},
    [46] = {firstKeep = 2, lastKeep = 2},
    [47] = {firstKeep = 2, lastKeep = 2},
    [48] = {firstKeep = 2, lastKeep = 2},
    [49] = {firstKeep = 2, lastKeep = 4},
}

local SuffixPrefixes = {
    ["Backdoor"] = "",
    ["Ceiling"] = "",
    ["Moving"] = "",
    ["Ragdoll"] = "",
    ["Rig"] = "",
    ["Wall"] = "",
    ["Clock"] = " Clock",
    ["Key"] = " Key",
    ["Pack"] = " Pack",
    ["Pointer"] = " Pointer",
    ["Swarm"] = " Swarm",
}
local PrettyFloorName = {
    ["Fools"] = "Super Hard Mode",
}


local EntityTable = {
    ["Names"] = {"BackdoorRush", "BackdoorLookman", "RushMoving", "AmbushMoving", "Eyes", "JeffTheKiller", "A60", "A120"},
    ["SideNames"] = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"},
    ["ShortNames"] = {
        ["BackdoorRush"] = "Blitz",
        ["JeffTheKiller"] = "Jeff The Killer"
    },
    ["NotifyMessage"] = {
        ["GloombatSwarm"] = "Gloombats in next room!"
    },
    ["Avoid"] = {
        "RushMoving",
        "AmbushMoving"
    },
    ["NotifyReason"] = {
        ["A60"] = {
            ["Image"] = "12350986086",
        },
        ["A120"] = {
            ["Image"] = "12351008553",
        },
        ["BackdoorRush"] = {
            ["Image"] = "11102256553",
        },
        ["RushMoving"] = {
            ["Image"] = "11102256553",
        },
        ["AmbushMoving"] = {
            ["Image"] = "10938726652",
        },
        ["Eyes"] = {
            ["Image"] = "10865377903",
            ["Spawned"] = true
        },
        ["BackdoorLookman"] = {
            ["Image"] = "16764872677",
            ["Spawned"] = true
        },
        ["JeffTheKiller"] = {
            ["Image"] = "98993343",
            ["Spawned"] = true
        },
        ["GloombatSwarm"] = {
            ["Image"] = "79221203116470",
            ["Spawned"] = true
        }
    },
    ["NoCheck"] = {
        "Eyes",
        "BackdoorLookman",
        "JeffTheKiller"
    },
    ["InfCrucifixVelocity"] = {
        ["RushMoving"] = {
            threshold = 52,
            minDistance = 55,
        },
        ["RushNew"] = {
            threshold = 52,
            minDistance = 55,
        },    
        ["AmbushMoving"] = {
            threshold = 70,
            minDistance = 80,
        }
    },
    ["AutoWardrobe"] = {
        ["Entities"] = {
            "RushMoving",
            "AmbushMoving",
            "BackdoorRush",
            "A60",
            "A120",
        },
        ["Distance"] = {
            ["RushMoving"] = {
                Distance = 100,
                Loader = 175
            },
            ["BackdoorRush"] = {
                Distance = 100,
                Loader = 175
            },
    
            ["AmbushMoving"] = {
                Distance = 155,
                Loader = 200
            },
            ["A60"] = {
                Distance = 200,
                Loader = 200
            },
            ["A120"] = {
                Distance = 200,
                Loader = 200
            }
        }
    }
}

local HidingPlaceName = {
    ["Hotel"] = "Closet",
    ["Backdoor"] = "Closet",
    ["Fools"] = "Closet",

    ["Rooms"] = "Locker",
    ["Mines"] = "Locker"
}
local CutsceneExclude = {
    "FigureHotelChase",
    "Elevator1",
    "MinesFinale"
}
local SlotsName = {
    "Oval",
    "Square",
    "Tall",
    "Wide"
}

local PromptTable = {
    GamePrompts = {},

    Aura = {
        ["ActivateEventPrompt"] = false,
        ["AwesomePrompt"] = true,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = false,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = false,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = true,
        ["ValvePrompt"] = false,
        ["PropPrompt"] = true
    },
    AuraObjects = {
        "Lock",
        "Button"
    },

    Clip = {
        "AwesomePrompt",
        "FusesPrompt",
        "HerbPrompt",
        "HidePrompt",
        "LeverPrompt",
        "LootPrompt",
        "ModulePrompt",
        "Prompt",
        "PushPrompt",
        "SkullPrompt",
        "UnlockPrompt",
        "ValvePrompt"
    },
    ClipObjects = {
        "LeverForGate",
        "LiveBreakerPolePickup",
        "LiveHintBook",
        "Button",
    },

    Excluded = {
        Prompt = {
            "HintPrompt",
            "InteractPrompt"
        },

        Parent = {
            "KeyObtainFake",
            "Padlock"
        },

        ModelAncestor = {
            "DoorFake"
        }
    }
}

local RBXGeneral = TextChatService.TextChannels.RBXGeneral

--// Exploits Variables \\--
local fireTouch = firetouchinterest or firetouchtransmitter
local firePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _fireproximityprompt
local forceFirePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _forcefireproximityprompt
local isnetowner = ExecutorSupport["isnetworkowner"] and isnetworkowner or _isnetworkowner

--// Player Variables \\--
local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local playerScripts = localPlayer.PlayerScripts

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local alive = localPlayer:GetAttribute("Alive")
local humanoid: Humanoid
local rootPart: BasePart
local collision
local collisionClone
local velocityLimiter

--// DOORS Variables \\--
local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local latestRoom = gameData:WaitForChild("LatestRoom")

local liveModifiers = ReplicatedStorage:WaitForChild("LiveModifiers")

local isMines = floor.Value == "Mines"
local isRooms = floor.Value == "Rooms"
local isHotel = floor.Value == "Hotel"
local isBackdoor = floor.Value == "Backdoor"
local isFools = floor.Value == "Fools"

local floorReplicated = if not isFools then ReplicatedStorage:WaitForChild("FloorReplicated") else nil
local remotesFolder = if not isFools then ReplicatedStorage:WaitForChild("RemotesFolder") else ReplicatedStorage:WaitForChild("EntityInfo")

--// Player DOORS Variables \\--
local currentRoom = localPlayer:GetAttribute("CurrentRoom") or 0
local nextRoom = currentRoom + 1

local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = if ExecutorSupport["require"] then require(mainGame) else nil
local controlModule = if ExecutorSupport["require"] then require(playerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")) else nil

--// Other Variables \\--
local speedBypassing = false

local lastSpeed = 0
local bypassed = false

local MinecartPathNodeColor = {
    Disabled = nil,
    Red = Color3.new(1, 0, 0),
    Yellow = Color3.new(1, 1, 0),
    Purple = Color3.new(1, 0, 1),
    Green = Color3.new(0, 1, 0),
    Cyan = Color3.new(0, 1, 1),
    Orange = Color3.new(1, 0.5, 0),
    White = Color3.new(1, 1, 1),
}

local MinecartPathfind = {
    -- ground chase [41 to 44]
    -- minecart chase [45 to 49]
}

--// Types \\--
type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

type tPathfind = {
    esp: boolean,
    room_number: number, -- the room number
    real: table,
    fake: table,
    destroyed: boolean -- if the pathfind was destroyed for the Teleport
}

type tGroupTrack = {
    nodes: table,
    hasStart: boolean,
    hasEnd: boolean,
}

--// Library \\--
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MS-ESP/refs/heads/main/source.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Doors | Kurumi Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(510, 390),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})
local Tabs = {
    genaral = Window:AddTab({ Title = "Genaral", Icon = "rbxassetid://11433532654" }),
    Settings = Window:AddTab({ Title = "Setting", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "Kurumi Running Script.",
        SubContent = "", -- Optional
        Duration = 10 -- Set to nil to make the notification not disappear
    })

end

--// Captions \\--
local _mspaint_custom_captions = Instance.new("ScreenGui") do
    local Frame = Instance.new("Frame", _mspaint_custom_captions)
    local TextLabel = Instance.new("TextLabel", Frame)
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint", TextLabel)

    _mspaint_custom_captions.Parent = ReplicatedStorage
    _mspaint_custom_captions.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Library.MainColor
    Frame.BorderColor3 = Library.AccentColor
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0, 200, 0, 75)

    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.Code
    TextLabel.Text = ""
    TextLabel.TextColor3 = Library.FontColor
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    UITextSizeConstraint.MaxTextSize = 35

    function Script.Functions.Captions(caption: string)
        if _mspaint_custom_captions.Parent == ReplicatedStorage then _mspaint_custom_captions.Parent = gethui() or game:GetService("CoreGui") or playerGui end
        TextLabel.Text = caption
    end

    function Script.Functions.HideCaptions()
        _mspaint_custom_captions.Parent = ReplicatedStorage
    end
end

--// Functions \\--
getgenv()._internal_unload_mspaint = function()
    Library:Unload()
end

function Script.Functions.RandomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

function Script.Functions.EnforceTypes(args, template)
    args = type(args) == "table" and args or {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or (value ~= nil and type(argValue) ~= type(value)) then
            args[key] = value
        elseif type(value) == "table" then
            args[key] = Script.Functions.EnforceTypes(argValue, value)
        end
    end

    return args
end

function Script.Functions.UpdateRPC()
    if not getgenv().BloxstrapRPC then return end

    local roomNumberPrefix = "Room "
    local prettifiedRoomNumber = currentRoom

    if isBackdoor then
        prettifiedRoomNumber = -50 + currentRoom
    end

    if isMines then
        prettifiedRoomNumber += 100
    end

    prettifiedRoomNumber = tostring(prettifiedRoomNumber)

    if isRooms then
        roomNumberPrefix = "A-"
        prettifiedRoomNumber = string.format("%03d", prettifiedRoomNumber)
    end

    BloxstrapRPC.SetRichPresence({
        details = "Playing DOORS [ mspaint v2 ]",
        state = roomNumberPrefix .. prettifiedRoomNumber .. " (" .. (PrettyFloorName[floor.Value] and PrettyFloorName[floor.Value] or ("The " .. floor.Value) ) .. ")",
        largeImage = {
            hoverText = "Using mspaint v2"
        },
        smallImage = {
            assetId = 6925817108,
            hoverText = localPlayer.Name
        }
    })
end

--// Notification Functions \\--
do
    function Script.Functions.Warn(message: string)
        warn("WARN - mspaint:", message)
    end

    function Script.Functions.Notifs.Doors.Notify(unsafeOptions)
        assert(typeof(unsafeOptions) == "table", "Expected a table as options argument but got " .. typeof(unsafeOptions))
        if not mainUI then return end
        
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Title = "No Title",
            Description = "No Text",
            Reason = "",
            NotificationType = "NOTIFICATION",
            Image = "6023426923",
            Color = nil,
            Time = nil,
    
            TweenDuration = 0.8
        })
    
    
        local acheivement = mainUI.AchievementsHolder.Achievement:Clone()
        acheivement.Size = UDim2.new(0, 0, 0, 0)
        acheivement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
        acheivement.Name = "LiveAchievement"
        acheivement.Visible = true
    
        acheivement.Frame.TextLabel.Text = options.NotificationType
    
        if options.Color ~= nil then
            acheivement.Frame.TextLabel.TextColor3 = options.Color
            acheivement.Frame.UIStroke.Color = options.Color
            acheivement.Frame.Glow.ImageColor3 = options.Color
        end
        
        acheivement.Frame.Details.Desc.Text = tostring(options.Description)
        acheivement.Frame.Details.Title.Text = tostring(options.Title)
        acheivement.Frame.Details.Reason.Text = tostring(options.Reason or "")
    
        if options.Image:match("rbxthumb://") or options.Image:match("rbxassetid://") then
            acheivement.Frame.ImageLabel.Image = tostring(options.Image or "rbxassetid://0")
        else
            acheivement.Frame.ImageLabel.Image = "rbxassetid://" .. tostring(options.Image or "0")
        end
    
        acheivement.Parent = mainUI.AchievementsHolder
        acheivement.Sound.SoundId = "rbxassetid://10469938989"
    
        acheivement.Sound.Volume = 1
    
        if Toggles.NotifySound.Value then
            acheivement.Sound:Play()
        end
    
        task.spawn(function()
            acheivement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", options.TweenDuration, true)
        
            task.wait(0.8)
        
            acheivement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
        
            TweenService:Create(acheivement.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                ImageTransparency = 1
            }):Play()
        
            if options.Time ~= nil then
                if typeof(options.Time) == "number" then
                    task.wait(options.Time)
                elseif typeof(options.Time) == "Instance" then
                    options.Time.Destroying:Wait()
                end
            else
                task.wait(5)
            end
        
            acheivement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:Destroy()
        end)
    end
    
    function Script.Functions.Notifs.Doors.Warn(options)
        assert(typeof(options) == "table", "Expected a table as options argument but got " .. typeof(options))
    
        options["NotificationType"] = "WARNING"
        options["Color"] = Color3.new(1, 0, 0)
        options["TweenDuration"] = 0.3
    
        Script.Functions.Notifs.Doors.Notify(options)
    end
    
    function Script.Functions.Notifs.Linoria.Notify(unsafeOptions)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        Library:Notify(options.Description, options.Time or 5)
    
        if Toggles.NotifySound.Value then
            local sound = Instance.new("Sound", SoundService) do
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 2
                sound.PlayOnRemove = true
                sound:Destroy()
            end
        end
    end
    
    function Script.Functions.Notifs.Linoria.Log(unsafeOptions, condition: boolean | nil)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        if condition ~= nil and not condition then return end
        Library:Notify(options.Description, options.Time or 5)
    end
    
    function Script.Functions.Alert(options)
        repeat task.wait() until getgenv().mspaint_loaded
    
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and not options.Warning then
            Script.Functions.Notifs.Doors.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and options.Warning then
            options["Warning"] = nil
    
            Script.Functions.Notifs.Doors.Warn(options)
        end
    end
    
    function Script.Functions.Log(options, condition: boolean | nil)
        repeat task.wait() until getgenv().mspaint_loaded
        
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Log(options, condition)
        elseif Options.NotifyStyle.Value == "Doors" then
            if not condition and typeof(condition) == "boolean" then return end
    
            options["NotificationType"] = "LOGGING"
            options["Color"] = Color3.fromRGB(0, 102, 255)
    
            Script.Functions.Notifs.Doors.Notify(options)
        end
    end
end

--// Player Functions \\--
do
    function Script.Functions.DistanceFromCharacter(position: Instance | Vector3, getPositionFromCamera: boolean | nil)
        if not position then return 9e9 end
        if typeof(position) == "Instance" then
            position = position:GetPivot().Position
        end
    
        if getPositionFromCamera and (camera or workspace.CurrentCamera) then
            local cameraPosition = camera and camera.CFrame.Position or workspace.CurrentCamera.CFrame.Position
    
            return (cameraPosition - position).Magnitude
        end
    
        if rootPart then
            return (rootPart.Position - position).Magnitude
        elseif camera then
            return (camera.CFrame.Position - position).Magnitude
        end
    
        return 9e9
    end

    function Script.Functions.IsInViewOfPlayer(instance: Instance, range: number | nil, exclude: table | nil)
        if not instance then return false end
        if not collision then return false end
    
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
        local filter = exclude or {}
        table.insert(filter, character)
    
        raycastParams.FilterDescendantsInstances = filter
    
        local direction = (instance:GetPivot().Position - collision.Position).unit * (range or 9e9)
        local raycast = workspace:Raycast(collision.Position, direction, raycastParams)
    
        if raycast and raycast.Instance then
            if raycast.Instance:IsDescendantOf(instance) or raycast.Instance == instance then
                return true
            end
    
            return false
        end
    
        return false
    end
end

--// ESP Functions \\--
do
    function Script.Functions.ESP(args: ESP)
        if not args.Object then return Script.Functions.Warn("ESP Object is nil") end
    
        local ESPManager = {
            Object = args.Object,
            Text = args.Text or "No Text",
            Color = args.Color or Color3.new(),
            Offset = args.Offset or Vector3.zero,
            IsEntity = args.IsEntity or false,
            IsDoubleDoor = args.IsDoubleDoor or false,
            Type = args.Type or "None",
            OnDestroy = args.OnDestroy or nil,
    
            Invisible = false,
            Humanoid = nil
        }
    
        if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
            if ESPManager.Object.PrimaryPart.Transparency == 1 then
                ESPManager.Invisible = true
                ESPManager.Object.PrimaryPart.Transparency = 0.99
            end
    
            local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
            if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
            ESPManager.Humanoid = humanoid
        end
    
        local ESPInstance = ESPLibrary.ESP.Highlight({
            Name = ESPManager.Text,
            Model = ESPManager.Object,
            StudsOffset = ESPManager.Offset,
    
            FillColor = ESPManager.Color,
            OutlineColor = ESPManager.Color,
            TextColor = ESPManager.Color,
            TextSize = Options.ESPTextSize.Value or 16,

            FillTransparency = Options.ESPFillTransparency.Value,
            OutlineTransparency = Options.ESPOutlineTransparency.Value,
    
            Tracer = {
                Enabled = Toggles.ESPTracer.Value,
                From = Options.ESPTracerStart.Value,
                Color = ESPManager.Color
            },
    
            OnDestroy = ESPManager.OnDestroy or function()
                if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
                if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
            end
        })
    
        table.insert(Script.ESPTable[args.Type], ESPInstance)
    
        return ESPInstance
    end
    
    function Script.Functions.DoorESP(room)
        local door = room:WaitForChild("Door", 5)
    
        if door then
            local doorNumber = tonumber(room.Name) + 1
            if isMines then
                doorNumber += 100
            end
    
            local opened = door:GetAttribute("Opened")
            local locked = room:GetAttribute("RequiresKey")
    
            local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
            local doorIdx = Script.Functions.RandomString()
    
            local doorEsp = Script.Functions.ESP({
                Type = "Door",
                Object = door:WaitForChild("Door"),
                Text = string.format("Door %s %s", doorNumber, doorState),
                Color = Options.DoorEspColor.Value,
    
                OnDestroy = function()
                    if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
                end
            })
    
            Script.FeatureConnections.Door[doorIdx] = door:GetAttributeChangedSignal("Opened"):Connect(function()
                if doorEsp then doorEsp.SetText(string.format("Door %s [Opened]", doorNumber)) end
                if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
            end)
        end
    end 
    
    function Script.Functions.ObjectiveESP(child)
        -- Backdoor
        if child.Name == "TimerLever" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = string.format("Timer Lever [+%s]", child.TakeTimer.TextLabel.Text),
                Color = Options.ObjectiveEspColor.Value
            })
        -- Backdoor + Hotel
        elseif child.Name == "KeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Key",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Hotel
        elseif child.Name == "ElectricalKeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Electrical Key",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LeverForGate" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Lever",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveHintBook" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Book",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveBreakerPolePickup" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Breaker",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Mines
        elseif child.Name == "MinesGenerator" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Generator",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesGateButton" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Power Button",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "FuseObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Fuse",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesAnchor" then
            local sign = child:WaitForChild("Sign", 5)
    
            if sign and sign:FindFirstChild("TextLabel") then
                Script.Functions.ESP({
                    Type = "Objective",
                    Object = child,
                    Text = string.format("Anchor %s", sign.TextLabel.Text),
                    Color = Options.ObjectiveEspColor.Value
                })
            end
        elseif child.Name == "WaterPump" then
            local wheel = child:WaitForChild("Wheel", 5)
    
            if wheel then
                Script.Functions.ESP({
                    Type = "Objective",
                    Object = wheel,
                    Text = "Water Pump",
                    Color = Options.ObjectiveEspColor.Value
                })
            end
        end
    end
    
    function Script.Functions.EntityESP(entity)
        Script.Functions.ESP({
            Type = "Entity",
            Object = entity,
            Text = Script.Functions.GetShortName(entity.Name),
            Color = Options.EntityEspColor.Value,
            IsEntity = entity.Name ~= "JeffTheKiller",
        })
    end
    
    function Script.Functions.SideEntityESP(entity)
        if entity.Name == "Snare" and not entity:FindFirstChild("Hitbox") then return end
    
        Script.Functions.ESP({
            Type = "SideEntity",
            Object = entity,
            Text = Script.Functions.GetShortName(entity.Name),
            TextParent = entity.PrimaryPart,
            Color = Options.EntityEspColor.Value,
        })
    end
    
    function Script.Functions.ItemESP(item)
        Script.Functions.ESP({
            Type = "Item",
            Object = item,
            Text = Script.Functions.GetShortName(item.Name),
            Color = Options.ItemEspColor.Value
        })
    end
    
    function Script.Functions.ChestESP(chest)
        local text = chest.Name:gsub("Box", ""):gsub("_Vine", ""):gsub("_Small", "")
        local locked = chest:GetAttribute("Locked")
        local state = if locked then "[Locked]" else ""
    
        Script.Functions.ESP({
            Type = "Chest",
            Object = chest,
            Text = string.format("%s %s", text, state),
            Color = Options.ChestEspColor.Value
        })
    end
    
    function Script.Functions.PlayerESP(player: Player)
        if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end
    
        local playerEsp = Script.Functions.ESP({
            Type = "Player",
            Object = player.Character,
            Text = string.format("%s [%.1f]", player.DisplayName, humanoid.Health),
            TextParent = player.Character.PrimaryPart,
            Color = Options.PlayerEspColor.Value
        })
    
        Script.FeatureConnections.Player[player.Name] = player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth > 0 then
                playerEsp.SetText(string.format("%s [%.1f]", player.DisplayName, newHealth))
            else
                if Script.FeatureConnections.Player[player.Name] then Script.FeatureConnections.Player[player.Name]:Disconnect() end
                playerEsp.Destroy()
            end
        end)
    end
    
    function Script.Functions.HidingSpotESP(spot)
        Script.Functions.ESP({
            Type = "HidingSpot",
            Object = spot,
            Text = if spot:GetAttribute("LoadModule") == "Bed" then "Bed" else HidingPlaceName[floor.Value],
            Color = Options.HidingSpotEspColor.Value
        })
    end
    
    function Script.Functions.GoldESP(gold)
        Script.Functions.ESP({
            Type = "Gold",
            Object = gold,
            Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
            Color = Options.GoldEspColor.Value
        })
    end
    
    function Script.Functions.GuidingLightEsp(guidance)
        local part = guidance:Clone()
        part.Anchored = true
        part.Size = Vector3.new(3, 3, 3)
        part.Transparency = 0.5
        part.Name = "_Guidance"
    
        part:ClearAllChildren()
        part.Parent = Workspace
    
        Script.Temp.Guidance[guidance] = part
    
        local guidanceEsp = Script.Functions.ESP({
            Type = "Guiding",
            Object = part,
            Text = "Guidance",
            Color = Options.GuidingLightEspColor.Value
        })
    
        guidance.AncestryChanged:Connect(function()
            if not guidance:IsDescendantOf(workspace) then
                if Script.Temp.Guidance[guidance] then Script.Temp.Guidance[guidance] = nil end
                if part then part:Destroy() end
                if guidanceEsp then guidanceEsp.Destroy() end
            end
        end)
    end
end

--// Assets Functions \\--
do
    function Script.Functions.GetShortName(entityName: string)
        if EntityTable.ShortNames[entityName] then
            return EntityTable.ShortNames[entityName]
        end
    
        for suffix, fix in pairs(SuffixPrefixes) do
            entityName = entityName:gsub(suffix, fix)
        end
    
        return entityName
    end

    function Script.Functions.PromptCondition(prompt)
        local modelAncestor = prompt:FindFirstAncestorOfClass("Model")
        return 
            prompt:IsA("ProximityPrompt") and (
                not table.find(PromptTable.Excluded.Prompt, prompt.Name) 
                and not table.find(PromptTable.Excluded.Parent, prompt.Parent and prompt.Parent.Name or "") 
                and not (table.find(PromptTable.Excluded.ModelAncestor, modelAncestor and modelAncestor.Name or ""))
            )
    end

    function Script.Functions.ItemCondition(item)
        return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID")
    end

    function Script.Functions.ChildCheck(child)
        if Script.Functions.PromptCondition(child) then
            task.defer(function()
                if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
                if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
                if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
                if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end
            end)
    
            task.defer(function()
                child.MaxActivationDistance = child:GetAttribute("Distance") * Options.PromptReachMultiplier.Value
        
                if Toggles.InstaInteract.Value then
                    child.HoldDuration = 0
                end
        
                if Toggles.PromptClip.Value and Script.Functions.PromptCondition(child) then
                    child.RequiresLineOfSight = false
                end
            end)
    
            table.insert(PromptTable.GamePrompts, child)
        end
    
        if child:IsA("Model") then
            if child.Name == "ElevatorBreaker" and Toggles.AutoBreakerSolver.Value then
                Script.Functions.SolveBreakerBox(child)
            end
    
            if isMines and Toggles.TheMinesAnticheatBypass.Value and child.Name == "Ladder" then
                Script.Functions.ESP({
                    Type = "None",
                    Object = child,
                    Text = "Ladder",
                    Color = Color3.new(0, 0, 1)
                })
            end
    
            if child.Name == "Snare" and Toggles.AntiSnare.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            end
            if child.Name == "GiggleCeiling" and Toggles.AntiGiggle.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            end
            if (child:GetAttribute("LoadModule") == "DupeRoom" or child:GetAttribute("LoadModule") == "SpaceSideroom") and Toggles.AntiDupe.Value then
                Script.Functions.DisableDupe(child, true, child:GetAttribute("LoadModule") == "SpaceSideroom")
            end
    
            if (isHotel or isFools) and (child.Name == "ChandelierObstruction" or child.Name == "Seek_Arm") and Toggles.AntiSeekObstructions.Value then
                for i,v in pairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = false end
                end
            end
    
            if isFools then
                if Toggles.FigureGodmodeFools.Value and child.Name == "FigureRagdoll" then
                    for i, v in pairs(child:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if not v:GetAttribute("Clip") then v:SetAttribute("Clip", v.CanCollide) end
    
                            v.CanTouch = false
    
                            -- woudn't want figure to just dip into the ground
                            task.spawn(function()
                                repeat task.wait() until (latestRoom.Value == 50 or latestRoom.Value == 100)
                                task.wait(5)
                                v.CanCollide = false
                            end)
                        end
                    end
                end
            end
        elseif child:IsA("BasePart") then        
            if child.Name == "Egg" and Toggles.AntiGloomEgg.Value then
                child.CanTouch = false
            end
    
            if Toggles.AntiLag.Value then
                if not child:GetAttribute("Material") then child:SetAttribute("Material", child.Material) end
                if not child:GetAttribute("Reflectance") then child:SetAttribute("Reflectance", child.Reflectance) end
        
                child.Material = Enum.Material.Plastic
                child.Reflectance = 0
            end
    
            if isMines then
                if Toggles.AntiBridgeFall.Value and child.Name == "PlayerBarrier" and child.Size.Y == 2.75 and (child.Rotation.X == 0 or child.Rotation.X == 180) then
                    local clone = child:Clone()
                    clone.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
                    clone.Color = Color3.new(1, 1, 1)
                    clone.Name = "AntiBridge"
                    clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                    clone.Transparency = 0
                    clone.Parent = child.Parent
                    
                    table.insert(Script.Temp.Bridges, clone)
                end
            end
        elseif child:IsA("Decal") and Toggles.AntiLag.Value then
            if not child:GetAttribute("Transparency") then child:SetAttribute("Transparency", child.Transparency) end
    
            if not table.find(SlotsName, child.Name) then
                child.Transparency = 1
            end
        end
    end

    function Script.Functions.IsPromptInRange(prompt: ProximityPrompt)
        return Script.Functions.DistanceFromCharacter(prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent) <= prompt.MaxActivationDistance
    end
    
    function Script.Functions.GetNearestAssetWithCondition(condition: () -> ())
        local nearestDistance = math.huge
        local nearest
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if not room:FindFirstChild("Assets") then continue end
    
            for i, v in pairs(room.Assets:GetChildren()) do
                if condition(v) and Script.Functions.DistanceFromCharacter(v) < nearestDistance then
                    nearestDistance = Script.Functions.DistanceFromCharacter(v)
                    nearest = v
                end
            end
        end
    
        return nearest
    end

    function Script.Functions.GetAllPromptsWithCondition(condition)
        assert(typeof(condition) == "function", "Expected a function as condition argument but got " .. typeof(condition))
        
        local validPrompts = {}
        for _, prompt in pairs(PromptTable.GamePrompts) do
            if not prompt or not prompt:IsDescendantOf(workspace) then continue end
    
            local success, returnData = pcall(function()
                return condition(prompt)
            end)
    
            assert(success, "An error has occured while running condition function.\n" .. tostring(returnData))
            assert(typeof(returnData) == "boolean", "Expected condition function to return a boolean")
            
            if returnData then
                table.insert(validPrompts, prompt)
            end
        end
    
        return validPrompts
    end
    
    function Script.Functions.GetNearestPromptWithCondition(condition)
        local prompts = Script.Functions.GetAllPromptsWithCondition(condition)
    
        local nearestPrompt = nil
        local oldHighestDistance = math.huge
        for _, prompt in pairs(prompts) do
            local promptParent = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model")
    
            if promptParent and Script.Functions.DistanceFromCharacter(promptParent) < oldHighestDistance then
                nearestPrompt = prompt
                oldHighestDistance = Script.Functions.DistanceFromCharacter(promptParent)
            end
        end
    
        return nearestPrompt
    end
end

--// Entities Functions \\--
do
    function Script.Functions.DisableDupe(dupeRoom, value, isSpaceRoom)
        if isSpaceRoom then
            local collision = dupeRoom:WaitForChild("Collision", 5)
            
            if collision then
                collision.CanCollide = value
                collision.CanTouch = not value
            end
        else
            local doorFake = dupeRoom:WaitForChild("DoorFake", 5)
            
            if doorFake then
                doorFake:WaitForChild("Hidden", 5).CanTouch = not value
        
                local lock = doorFake:WaitForChild("Lock", 5)
                if lock and lock:FindFirstChild("UnlockPrompt") then
                    lock.UnlockPrompt.Enabled = not value
                end
            end
        end
    end

    function Script.Functions.DeleteSeek(collision: BasePart)
        if not rootPart then return end
    
        task.spawn(function()
            local attemps = 0
            repeat task.wait() attemps += 1 until collision.Parent or attemps > 200
            
            if collision:IsDescendantOf(workspace) and (collision.Parent and collision.Parent.Name == "TriggerEventCollision") then
                Script.Functions.Alert({
                    Title = "Delete Seek FE",
                    Description = "Deleting Seek trigger...",
                    Reason = "",
                })
    
                task.delay(4, function()
                    if collision:IsDescendantOf(workspace) then
                        Script.Functions.Alert({
                            Title = "Delete Seek FE",
                            Description = "Failed to delete Seek trigger!",
                            Reason = "",
                        })
                    end
                end)
                
                if fireTouch then
                    rootPart.Anchored = true
                    task.delay(0.25, function() rootPart.Anchored = false end)
    
                    repeat
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 1) end
                        task.wait()
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 0) end
                        task.wait()
                    until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                else
                    collision:PivotTo(CFrame.new(rootPart.Position))
                    rootPart.Anchored = true
                    repeat task.wait() until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                    rootPart.Anchored = false
                end
                
                if not collision:IsDescendantOf(workspace) then
                    Script.Functions.Log({
                        Title = "Delete Seek FE",
                        Description = "Deleted Seek trigger successfully!",
                    })
                end
            end
        end)
    end

    function Script.Functions.AvoidEntity(value: boolean, oldNoclip: boolean)
        if not rootPart or not collision then return end
    
        local lastCFrame = rootPart.CFrame
        task.wait()
        if value then
            Toggles.Noclip:SetValue(true)
            collision.Position += Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
        else
            collision.Position -= Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
            Toggles.Noclip:SetValue(oldNoclip or false)
        end
    end
end

--// Automatization Functions \\--
do
    function Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt: ProximityPrompt)
        if not workspace.CurrentRooms:FindFirstChild(currentRoom) then return {targetWardrobePrompt.Parent} end
    
        local ignore = { targetWardrobePrompt.Parent }
    
        if workspace.CurrentRooms[currentRoom]:FindFirstChild("Assets") then
            for _, asset in pairs(workspace.CurrentRooms[currentRoom].Assets:GetChildren()) do
                if asset.Name == "Pillar" then table.insert(ignore, asset) end
            end
        end
    
        return ignore
    end
    
    function Script.Functions.AutoWardrobe(child, index: number | nil) -- child = entity, ty upio
        if not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace) then
            index = index or table.find(Script.Temp.AutoWardrobeEntities, child)
            if index then
                table.remove(Script.Temp.AutoWardrobeEntities, index)
            end
    
            return
        end
    
        local NotifPrefix = "Auto " .. HidingPlaceName[floor.Value];
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Looking for a hiding place",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Looking for a hiding spot..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    
        local entityIndex = #Script.Temp.AutoWardrobeEntities + 1
        Script.Temp.AutoWardrobeEntities[entityIndex] = child
    
        -- Get wardrobe
        local distance = EntityTable.AutoWardrobe.Distance[child.Name].Distance;
        local targetWardrobeChecker = function(prompt)
            if not prompt.Parent then return false end
            if not prompt.Parent:FindFirstChild("HiddenPlayer") then return false end
            if prompt.Parent:FindFirstChild("Main") and prompt.Parent.Main:FindFirstChild("HideEntityOnSpot") then
                if prompt.Parent.Main.HideEntityOnSpot.Whispers.Playing == true then return false end -- Hide
            end
    
            return prompt.Name == "HidePrompt" and (prompt.Parent:GetAttribute("LoadModule") == "Wardrobe" or prompt.Parent:GetAttribute("LoadModule") == "Bed" or prompt.Parent.Name == "Rooms_Locker") and not prompt.Parent.HiddenPlayer.Value and (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance * Options.PromptReachMultiplier.Value)
        end
        local targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
        local getPrompt = function()
            if not targetWardrobePrompt or Script.Functions.DistanceFromCharacter(targetWardrobePrompt:FindFirstAncestorWhichIsA("Model"):GetPivot().Position) > 15 then
                repeat task.wait()
                    targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
                until targetWardrobePrompt ~= nil or character:GetAttribute("Hiding") or (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded
    
                if (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded then
                    return
                end
            end
        end
        getPrompt()
    
        -- Hide Checks
        if character:GetAttribute("Hiding") then return end
        if not Toggles.AutoWardrobe.Value or not alive or Library.Unloaded then return end  
    
        -- Hide
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Starting...",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Starting..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
        
        local exclusion = Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt)
        local atempts, maxAtempts = 0, 60
        local isSafeCheck = function(addMoreDist)
            local isSafe = true
            for _, entity in pairs(Script.Temp.AutoWardrobeEntities) do
                if isSafe == false then break end
    
                local distanceEntity = EntityTable.AutoWardrobe.Distance[child.Name].Distance;

                local entityDeleted = (entity == nil or entity.Parent == nil)
                local inView = Script.Functions.IsInViewOfPlayer(entity.PrimaryPart, distanceEntity + (addMoreDist == true and 15 or 0), exclusion)
                local isClose = Script.Functions.DistanceFromCharacter(entity:GetPivot().Position) < distanceEntity + (addMoreDist == true and 15 or 0);
    
                isSafe = entityDeleted == true and true or (inView == false and isClose == false);
                if isSafe == false then break end
            end
    
            return isSafe
        end
        local waitForSafeExit; waitForSafeExit = function()
            if child.Name == "A120" then
                repeat task.wait() until not child:IsDescendantOf(workspace) or (child.PrimaryPart and child.PrimaryPart.Position.Y < -10) or (not alive or not character:GetAttribute("Hiding"))
            else   
                local didPlayerSeeEntity = false
                task.spawn(function()
                    repeat task.wait()
                        if not alive or not child or not child:IsDescendantOf(workspace) then break end
    
                        if character:GetAttribute("Hiding") and Script.Functions.IsInViewOfPlayer(child.PrimaryPart, distance, exclusion) then
                            didPlayerSeeEntity = true
                            break
                        end
                    until false == true
                end)
    
                repeat task.wait(.15)
                    local isSafe = isSafeCheck()
                    if didPlayerSeeEntity == true and isSafe == true then
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Exiting the locker, entity is far away.",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is far away."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)
    
                        break
                    else
                        if isSafe == true and not child:IsDescendantOf(workspace) then 
                            task.spawn(function() 
                                Script.Functions.Log({
                                    Title = NotifPrefix,
                                    Description = "Exiting the locker, entity is deleted.",
                                    
                                    LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is deleted."
                                }, Toggles.AutoWardrobeNotif.Value)
                            end)
    
                            break 
                        end          
                    end
    
                    if not alive then  
                        if Toggles.AutoWardrobeNotif.Value then Script.Functions.Log("[" .. NotifPrefix .. "] Stopping (you died).") end             
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Stopping (you died)",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Stopping (you died)."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)

                        break 
                    end                             
                until false == true          
            end
    
            return true
        end
        local hide = function()
            if (character:GetAttribute("Hiding") and rootPart.Anchored) then return false end
    
            getPrompt()
            repeat task.wait()
                atempts += 1
    
                forceFirePrompt(targetWardrobePrompt)
            until atempts > maxAtempts or not alive or (character:GetAttribute("Hiding") and rootPart.Anchored)
    
            if atempts > maxAtempts or not alive then return false end
            return true
        end
    
        if child.Name == "AmbushMoving" then
            local LastPos = child:GetPivot().Position
            local IsMoving = false
            task.spawn(function()
                repeat task.wait(0.01)
                    local diff = (LastPos - child:GetPivot().Position) / 0.01
                    LastPos = child:GetPivot().Position
                    IsMoving = diff.Magnitude > 0
                until not child or not child:IsDescendantOf(workspace)
            end)
    
            repeat task.wait()
                task.spawn(function() 
                    Script.Functions.Log({
                        Title = NotifPrefix,
                        Description = "Waiting for Ambush to be close enough...",
        
                        LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for Ambush to be close enough...",
                    }, Toggles.AutoWardrobeNotif.Value)
                end)
    
                repeat task.wait() until (IsMoving == true and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) <= distance) or (not child or not child:IsDescendantOf(workspace))
                if not child or not child:IsDescendantOf(workspace) then break end
                
                local success = hide()
                if success then
                    task.spawn(function() 
                        Script.Functions.Log({
                            Title = NotifPrefix,
                            Description = "Waiting for it to be safe to exit...",
        
                            LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for it to be safe to exit...",
                        }, Toggles.AutoWardrobeNotif.Value)
                    end)
    
                    repeat task.wait() until (IsMoving == false and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) >= distance) or (not child or not child:IsDescendantOf(workspace));
                    if not child or not child:IsDescendantOf(workspace) then break end
    
                    remotesFolder.CamLock:FireServer()
                end
            until (not child or not child:IsDescendantOf(workspace)) or not alive
        else
            repeat task.wait() until isSafeCheck(true, true) == false
    
            repeat
                local success = hide()
                if success then
                    local finished = waitForSafeExit()
                    repeat task.wait() until finished == true        
                    remotesFolder.CamLock:FireServer()
                end
                
                task.wait()
            until isSafeCheck()
        end
    
        table.remove(Script.Temp.AutoWardrobeEntities, entityIndex)
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Finished.",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Finished.",
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    end

    --// Breakers \\--
    function Script.Functions.EnableBreaker(breaker, value)
        breaker:SetAttribute("Enabled", value)
    
        if value then
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = -0.2
            breaker.Light.Material = Enum.Material.Neon
            breaker.Light.Attachment.Spark:Emit(1)
            breaker.Sound.Pitch = 1.3
        else
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = 0.2
            breaker.Light.Material = Enum.Material.Glass
            breaker.Sound.Pitch = 1.2
        end
    
        breaker.Sound:Play()
    end

    function Script.Functions.SolveBreakerBox(breakerBox)
        if not breakerBox then return end
    
        local code = breakerBox:FindFirstChild("Code", true)
        local correct = breakerBox:FindFirstChild("Correct", true)
    
        repeat task.wait() until code.Text ~= "..." or not breakerBox:IsDescendantOf(workspace)
        if not breakerBox:IsDescendantOf(workspace) then return end
    
        Script.Functions.Alert({
            Title = "Auto Breaker Solver",
            Description = "Solving the breaker box...",
            Reason = ""
        })
    
        if Options.AutoBreakerSolverMethod.Value == "Legit" then
            Script.Temp.UsedBreakers = {}
            if Script.Connections["Reset"] then Script.Connections["Reset"]:Disconnect() end
            if Script.Connections["Code"] then Script.Connections["Code"]:Disconnect() end
    
            local breakers = {}
            for _, breaker in pairs(breakerBox:GetChildren()) do
                if breaker.Name == "BreakerSwitch" then
                    local id = string.format("%02d", breaker:GetAttribute("ID"))
                    breakers[id] = breaker
                end
            end
    
            if code:FindFirstChild("Frame") then
                Script.Functions.AutoBreaker(code, breakers)
    
                Script.Connections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                    if correct.Playing then table.clear(Script.Temp.UsedBreakers) end
                end)
    
                Script.Connections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                    task.delay(0.1, Script.Functions.AutoBreaker, code, breakers)
                end)
            end
        else
            repeat task.wait(0.1)
                remotesFolder.EBF:FireServer()
            until not workspace.CurrentRooms["100"]:FindFirstChild("DoorToBreakDown")
    
            Script.Functions.Alert({
                Title = "Auto Breaker Solver",
                Description = "The breaker box has been successfully solved.",
            })
        end
    end
    
    function Script.Functions.AutoBreaker(code, breakers)
        local newCode = code.Text
        if not tonumber(newCode) and newCode ~= "??" then return end
    
        local isEnabled = code.Frame.BackgroundTransparency == 0
    
        local breaker = breakers[newCode]
    
        if newCode == "??" and #Script.Temp.UsedBreakers == 9 then
            for i = 1, 10 do
                local id = string.format("%02d", i)
    
                if not table.find(Script.Temp.UsedBreakers, id) then
                    breaker = breakers[id]
                end
            end
        end
    
        if breaker then
            table.insert(Script.Temp.UsedBreakers, newCode)
            if breaker:GetAttribute("Enabled") ~= isEnabled then
                Script.Functions.EnableBreaker(breaker, isEnabled)
            end
        end
    end

    --// Padlocks \\--
    function Script.Functions.GetPadlockCode(paper: Tool)
        if paper:FindFirstChild("UI") then
            local code = {}
    
            for _, image: ImageLabel in pairs(paper.UI:GetChildren()) do
                if image:IsA("ImageLabel") and tonumber(image.Name) then
                    code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] = {tonumber(image.Name), "_"}
                end
            end
    
            for _, image: ImageLabel in pairs(playerGui.PermUI.Hints:GetChildren()) do
                if image.Name == "Icon" then
                    if code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] then
                        code[image.ImageRectOffset.X .. image.ImageRectOffset.Y][2] = image.TextLabel.Text
                    end
                end
            end
    
            local normalizedCode = {}
            for _, num in pairs(code) do
                normalizedCode[num[1]] = num[2]
            end
    
            return table.concat(normalizedCode)
        end
    
        return "_____"
    end
end

--// Minecarts \\--
do
    local function changeNodeColor(node: Model, color: Color3): Model
        if color == nil then
            node.Color = MinecartPathNodeColor.Yellow
            node.Transparency = 1
            node.Size = Vector3.new(1.0, 1.0, 1.0)
            return
        end
        node.Color = color
        node.Material = Enum.Material.Neon
        node.Transparency = 0
        node.Shape = Enum.PartType.Ball
        node.Size = Vector3.new(0.7, 0.7, 0.7)
        return node
    end
    
    local function tPathfindNew(n: number)
        local create: tPathfind = {
            esp = false,
            room_number = n,
            real = {},
            fake = {},
            destroyed = false
        }
        return create
    end
    
    local function tGroupTrackNew(startNode: Part | nil): tGroupTrack
        local create: tGroupTrack = {
            nodes = startNode and {startNode} or {},
            hasStart = false,
            hasEnd   = false,
        }
        return create
    end
    
    function Script.Functions.Minecart.Pathfind(room: Model, lastRoom: number)
        if not (lastRoom >= 40 and lastRoom <= 49) and not (lastRoom >= 95 and lastRoom <= 100) then return end
        
        local nodes = room:WaitForChild("RunnerNodes", 5.0) --well, skill issue ig
        if (nodes == nil) then return end
    
        nodes = nodes:GetChildren()
    
        local numOfNodes = #nodes
        if numOfNodes <= 1 then return end --This is literally impossible but... umm. acutally, yea why not.
    
        --[[
            Pathfind is a computational expensive process to make, 
            however we don't have node loops, 
            so we can ignore a few verifications.
            If you want to understand how this is working, search for "Pathfiding Algorithms"
    
            The shortest explanation i can give is that, this is a custom pathfinding to find "gaps" between
            nodes and creating "path" groups. With the groups estabilished we can make the correct validations.
        ]]
        --Distance weights [DO NOT EDIT, unless something breaks...]
        local _shortW = 4
        local _longW = 24
    
        local doorModel = room:WaitForChild("Door", 5) -- Will be used to find the correct last node.
    
        local _startNode = nodes[1]
        local _lastNode = nil --we need to find this node.
    
        local _gpID = 1
        local stackNode = {} --Group all track groups here.
        stackNode[_gpID] = tGroupTrackNew()
        
        --Ensure sort all nodes properly (reversed)
        table.sort(nodes, function(a, b)
            local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
            local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
            return tonumber(_Asub) > tonumber(_Bsub)
        end)
    
        local _last = 1
        for i= _last + 1, numOfNodes, 1 do
            local nodeA: Part = nodes[_last]
            local nodeB: Part = _lastNode and nodes[i] or doorModel
    
            local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude
    
            local isEndNode = distance <= _shortW
            local isNodeNear = (distance > _shortW and distance <= _longW)
    
            local _currNodeTask = "Track"
            if isNodeNear or isEndNode then
                if not _lastNode then -- this will only be true, once.
                    _currNodeTask = "End"
                    _lastNode = nodeA
                end
            else
                _currNodeTask = "Fake"
            end
    
            --check if group is diff, ignore "End" or "Start" tasks
            if (_currNodeTask == "Fake" or _currNodeTask == "End") and _lastNode then
                _gpID += 1
                stackNode[_gpID] = tGroupTrackNew()
                if _currNodeTask == "End" then
                    stackNode[_gpID].hasEnd = true
                end
            end
            table.insert(stackNode[_gpID].nodes, nodeA)
    
            _last = i
        end
        stackNode[_gpID].hasStart = true --after the reversed path finding, the last group has the start node.
        table.insert(stackNode[_gpID].nodes, _startNode)
        local hasMoreThanOneGroup = _gpID > 1
    
        local _closestNodes = {} --unwanted nodes if any
        local hasIncorrectPath = false -- if this is true, we're cooked. No path for you ):
        if hasMoreThanOneGroup then
            for _gpI, v: tGroupTrack in ipairs(stackNode) do
                _closestNodes[_gpI] = {}
                if _gpI <= 1 then continue end
    
                table.sort(v.nodes, function(a,b)
                    local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
                    local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
                    return tonumber(_Asub) < tonumber(_Bsub)
                end)
    
                local _gplast = 1
                local hasNodeJump = false
                for _gpS=_gplast+1, #v.nodes, 1 do
                    local nodeA: Part = v.nodes[_gplast]
                    local nodeB: Part = v.nodes[_gpS]
    
                    local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude
    
                    hasNodeJump = (distance >= _longW)
                    if not hasNodeJump then _gplast = _gpS continue end

                    local nodeSearchPath = nodeB
    
                    --Search again with the nodeSearchPath
                    local closestDistance = math.huge
    
                    local _gpFlast = #v.nodes
                    for i = _gpFlast - 1, 1, -1 do
                        local fnode = v.nodes[_gpFlast]
                        local Sdistance = (nodeSearchPath:GetPivot().Position - fnode:GetPivot().Position).Magnitude
                        _gpFlast = i
    
                        if Sdistance == 0.00 then continue end --node is self
    
                        if Sdistance <= closestDistance then
                            closestDistance = Sdistance
                            table.insert(_closestNodes[_gpI], fnode)
                            table.remove(v.nodes, _gpFlast + 1)
                            continue
                        end
                        break
                    end
    
                    local _FoundAmount = #_closestNodes[_gpI]
                    if _FoundAmount < 1 then 
                        hasIncorrectPath = true
                    end
                    break
                end
            end
        end
    
        if hasIncorrectPath then return end
    
        --finally, draw the correct path. gg
        local realNodes = {} --our precious nodes finally here :pray:
        local fakeNodes = {} --we hate you but ok
        for _gpFI, v: tGroupTrack in ipairs(stackNode) do
            local finalWrongNode = false
            if _gpFI == 1 and hasMoreThanOneGroup then
                finalWrongNode = true 
            end
    
            for _, vfinal in ipairs(v.nodes) do
                if finalWrongNode then
                    table.insert(fakeNodes, vfinal)
                    continue
                end
                table.insert(realNodes, vfinal)
            end
    
            --Draw wrong path calculated on DeepPath.
            for _, nfinal in ipairs(_closestNodes[_gpFI]) do
                table.insert(fakeNodes, nfinal)
            end
        end
    
        table.sort(realNodes, function(a, b)
            local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
            local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
            return tonumber(_Asub) < tonumber(_Bsub)
        end)
    
        --build pathfind
        local buildPathfind = tPathfindNew(lastRoom)
        buildPathfind.real = realNodes
        buildPathfind.fake = fakeNodes
        table.insert(MinecartPathfind, buildPathfind) --add to table
    
        Script.Functions.Minecart.DrawNodes()
    
        if Toggles.MinecartTeleport.Value and (lastRoom >= 45 and lastRoom <= 49) then
            Script.Functions.Minecart.NodeDestroy(tonumber(room.Name))
            Script.Functions.Minecart.Teleport(tonumber(room.Name))
        end
    end
    
    function Script.Functions.Minecart.NodeDestroy(roomNum: number)
        local roomConfig = WhitelistConfig[roomNum]
        if not roomConfig then return end
    
        local _firstKeep = roomConfig.firstKeep
        local _lastKeep  = roomConfig.lastKeep
    
        local realNodes = nil
        local fakeNodes = nil
        for _, path: tPathfind in ipairs(MinecartPathfind) do
            if path.room_number ~= roomNum then continue end
            if path.destroyed then continue end
    
            realNodes = path.real
            fakeNodes = path.fake
        end
    
        if realNodes then
            local _removeTotal = #realNodes - (_firstKeep + _lastKeep) --remove nodes that arent in the first or last
            for _ = 1, _removeTotal do
                local node = realNodes[_firstKeep + 1]
                node:Destroy()
                
                table.remove(realNodes, _firstKeep + 1)
            end
        else
            print("[NodeDestroy] Unable to destroy REAL nodes.")
        end
    
        if fakeNodes then
            --Destroy all the fake nodes
            for _, node in ipairs(fakeNodes) do
                node:Destroy()
            end
            fakeNodes = {} --if we now all the nodes will be destroyed then just make that.
        else
            print("[NodeDestroy] Unable to destroy FAKE nodes.")
        end
    
        print(string.format("[NodeDestroy] Task completed, remaining: Real nodes: %d | Fake nodes %s", #realNodes, #fakeNodes))
    end
    
    local isMinecartTeleporting = false --for debug purpouses.
    function Script.Functions.Minecart.Teleport(roomNum: number)
        if roomNum == 45 and not isMinecartTeleporting then
            isMinecartTeleporting = true
            task.spawn(function()
                local progressPart = Instance.new("Part", workspace) do
                    progressPart.Anchored = true
                    progressPart.CanCollide = false
                    progressPart.Name = "_internal_mspaint_minecart_teleport"
                    progressPart.Transparency = 1
                end
                Script.Functions.Alert({
                    Title = "Minecart Teleport",
                    Description = "Minecart teleport is ready! Waiting for the minecart...",
    
                    Time = progressPart
                })

                local minecartRig
                local minecartRoot
                repeat task.wait(0.1) 
                    minecartRig = camera:FindFirstChild("MinecartRig")
                    if not minecartRig then continue end
                    minecartRoot = minecartRig:FindFirstChild("Root")
                until minecartRig and minecartRoot

                if workspace:FindFirstChild("_internal_mspaint_minecart_teleport") then workspace:FindFirstChild("_internal_mspaint_minecart_teleport"):Destroy() end
                task.wait(3)

                for _, path: tPathfind in ipairs(MinecartPathfind) do
                    local roomOfThePath = path.room_number
    
                    if roomOfThePath >= 45 then -- ignore ground chase
                        local getLastNode = path.real[#path.real]
    
                        repeat 
                            task.wait()
                            minecartRoot.CFrame = getLastNode.CFrame
                        until workspace.CurrentRooms[tostring(currentRoom)]:WaitForChild("Door"):GetAttribute("Opened")
                        task.wait(2)
                        if currentRoom == 49 then break end
                    end
                end
            end)
        end
    end
    
    
    --If ESP Toggle is changed, you can call this function directly.
    function Script.Functions.Minecart.DrawNodes()
        local pathESP_enabled = Toggles.MinecartPathVisualiser.Value
        local espRealColor = pathESP_enabled and MinecartPathNodeColor.Green or MinecartPathNodeColor.Disabled
        
        for idx, path: tPathfind in ipairs(MinecartPathfind) do
            if path.esp and pathESP_enabled then continue end -- if status is unchanged.
    
            --[ESP] Draw the real path
            local realPath = path.real
            for _, _real in pairs(realPath) do
                changeNodeColor(_real, espRealColor)
            end
    
            path.esp = pathESP_enabled --update if path esp status was changed.
        end
    end
end

--// Connections Functions \\--
do
    function Script.Functions.CameraCheck(child)
        if child:IsA("BasePart") and child.Name == "Guidance" and Toggles.GuidingLightESP.Value then
            Script.Functions.GuidingLightEsp(child)
        end
    end

    function Script.Functions.SetupCameraConnection(camera)
        for _, child in pairs(camera:GetChildren()) do
            task.spawn(Script.Functions.CameraCheck, child)
        end
    
        Script.Connections["CameraChildAdded"] = camera.ChildAdded:Connect(function(child)
            task.spawn(Script.Functions.CameraCheck, child)
        end)
    end
    
    function Script.Functions.SetupCurrentRoomConnection(room)
        if Script.Connections["CurrentRoom"] then
            Script.Connections["CurrentRoom"]:Disconnect()
        end
    
        Script.Connections["CurrentRoom"] = room.DescendantAdded:Connect(function(child)
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(child) then
                Script.Functions.ItemESP(child)
            elseif Toggles.GoldESP.Value and child.Name == "GoldPile" then
                Script.Functions.GoldESP(child)
            end
        end)
    end
    
    function Script.Functions.SetupRoomConnection(room)
        for _, child in pairs(room:GetDescendants()) do
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.spawn(Script.Functions.ChildCheck, child)
        end
    
        Script.Connections[room.Name .. "DescendantAdded"] = room.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.delay(0.1, Script.Functions.ChildCheck, child)
        end)
    end
    
    function Script.Functions.SetupDropConnection(drop)
        if Toggles.ItemESP.Value then
            Script.Functions.ItemESP(drop)
        end
    
        task.spawn(function()
            local prompt = drop:WaitForChild("ModulePrompt", 3)
    
            if prompt then
                table.insert(PromptTable.GamePrompts, prompt)
            end
        end)
    end
    
    function Script.Functions.SetupCharacterConnection(newCharacter)
        character = newCharacter
        if character then
            if Toggles.EnableJump.Value then
                character:SetAttribute("CanJump", true)
            end
    
            for _, oldConnection in pairs(Script.FeatureConnections.Character) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Character["ChildAdded"] = character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Library Code",
                            Description = string.format("Library Code: %s", output),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["CanJump"] = character:GetAttributeChangedSignal("CanJump"):Connect(function()
                if not character:GetAttribute("CanJump") and Toggles.EnableJump.Value then
                    character:SetAttribute("CanJump", true)
                end
            end)
    
            Script.FeatureConnections.Character["Crouching"] = character:GetAttributeChangedSignal("Crouching"):Connect(function()
                if not character:GetAttribute("Crouching") and Toggles.AntiHearing.Value then
                    remotesFolder.Crouch:FireServer(true)
                end
            end)
    
            Script.FeatureConnections.Character["Hiding"] = character:GetAttributeChangedSignal("Hiding"):Connect(function()
                if not character:GetAttribute("Hiding") then return end
        
                if Toggles.TranslucentHidingSpot.Value then
                    for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                        if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end
        
                        if obj.Value == character then
                            task.spawn(function()
                                local affectedParts = {}
                                for _, part in pairs(obj.Parent:GetChildren()) do
                                    if not part:IsA("BasePart") or part.Name:match("Collision") then continue end
        
                                    part.Transparency = Options.HidingTransparency.Value
                                    table.insert(affectedParts, part)
                                end
        
                                repeat task.wait()
                                    for _, part in pairs(affectedParts) do
                                        task.wait()
                                        part.Transparency = Options.HidingTransparency.Value
                                    end
                                until not character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                                
                                for _, part in pairs(affectedParts) do
                                    part.Transparency = 0
                                end
                            end)
        
                            break
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["Oxygen"] = character:GetAttributeChangedSignal("Oxygen"):Connect(function()
                if character:GetAttribute("Oxygen") < 100 and Toggles.NotifyOxygen.Value then
                    if ExecutorSupport["firesignal"] then
                        firesignal(remotesFolder.Caption.OnClientEvent, string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    else
                        Script.Functions.Captions(string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    end
                end
            end)
        end
    
        humanoid = character:WaitForChild("Humanoid")
        if humanoid then
            for _, oldConnection in pairs(Script.FeatureConnections.Humanoid) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Humanoid["Move"] = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                if Toggles.FastClosetExit.Value and humanoid.MoveDirection.Magnitude > 0 and character:GetAttribute("Hiding") then
                    remotesFolder.CamLock:FireServer()
                end
            end)
    
            Script.FeatureConnections.Humanoid["Jump"] = humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                if not Toggles.SpeedBypass.Value and latestRoom.Value < 100 and not Script.FakeRevive.Enabled then
                    if humanoid.JumpHeight > 0 then
                        lastSpeed = Options.SpeedSlider.Value
                        Options.SpeedSlider:SetMax(3)
                    elseif lastSpeed > 0 then
                        Options.SpeedSlider:SetMax(7)
                        Options.SpeedSlider:SetValue(lastSpeed)
                        lastSpeed = 0
                    end
                end
            end)
    
            Script.FeatureConnections.Humanoid["Died"] = humanoid.Died:Connect(function()
                if collisionClone then
                    collisionClone:Destroy()
                end
    
                if velocityLimiter then
                    velocityLimiter:Destroy()
                end
            end)
    
            if isFools then
                local HoldingAnimation = Instance.new("Animation") do
                    HoldingAnimation.AnimationId = "rbxassetid://10479585177"
                    Script.Temp.ItemHoldTrack = humanoid:LoadAnimation(HoldingAnimation)
                end
    
                local ThrowAnimation = Instance.new("Animation") do
                    ThrowAnimation.AnimationId = "rbxassetid://10482563149"
                    Script.Temp.ItemThrowTrack = humanoid:LoadAnimation(ThrowAnimation)
                end
            end
        end
    
        rootPart = character:WaitForChild("HumanoidRootPart")
        if rootPart then
            local flyBody = Instance.new("BodyVelocity")
            flyBody.Velocity = Vector3.zero
            flyBody.MaxForce = Vector3.one * 9e9
    
            Script.Temp.FlyBody = flyBody
    
            if Toggles.NoAccel.Value then
                Script.Temp.NoAccelValue = rootPart.CustomPhysicalProperties.Density
                
                local existingProperties = rootPart.CustomPhysicalProperties
                rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
            end
    
            velocityLimiter = Instance.new("LinearVelocity", character)
            velocityLimiter.Enabled = false
            velocityLimiter.MaxForce = math.huge
            velocityLimiter.VectorVelocity = Vector3.new(0, 0, 0)
            velocityLimiter.RelativeTo = Enum.ActuatorRelativeTo.World
            velocityLimiter.Attachment0 = rootPart:WaitForChild("RootAttachment")
    
            Script.FeatureConnections.RootPart["Anchored"] = rootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
                local lastAnchoredDelta = os.time() - Script.Lagback.LastAnchored
    
                if rootPart.Anchored and Toggles.LagbackDetection.Value and Toggles.SpeedBypass.Value and not Script.Lagback.Detected then
                    Script.Lagback.Anchors += 1
                    Script.Lagback.LastAnchored = os.time()
    
                    if Script.Lagback.Anchors >= 2 and lastAnchoredDelta <= Script.Lagback.Threshold then
                        Script.Lagback.Detected = true
                        Script.Lagback.Anchors = 0
                        Script.Lagback.LastSpeed = Options.SpeedSlider.Value
                        Script.Lagback.LastFlySpeed = Options.FlySpeed.Value
    
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixing Lagback...",
                        })
                        Toggles.SpeedBypass:SetValue(false)
                        local cframeChanged = false
    
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
                        task.spawn(function() lastCheck = os.time(); rootPart:GetPropertyChangedSignal("CFrame"):Wait(); cframeChanged = true; end)
                        repeat task.wait() until cframeChanged or (os.time() - lastCheck) > 5
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
    
                        Toggles.SpeedBypass:SetValue(true)
                        Options.SpeedSlider:SetValue(Script.Lagback.LastSpeed)
                        Options.FlySpeed:SetValue(Script.Lagback.LastFlySpeed)
                        Script.Lagback.Detected = false
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixed Lagback!"
                        })
                    end
                end
            end)
        end
    
        collision = character:WaitForChild("Collision")
        if collision then
            if Toggles.UpsideDown.Value then
                collision.Rotation = Vector3.new(collision.Rotation.X, collision.Rotation.Y, -90)
            end
    
            collisionClone = collision:Clone()
            collisionClone.CanCollide = false
            collisionClone.Massless = true
            collisionClone.Name = "CollisionClone"
            if collisionClone:FindFirstChild("CollisionCrouch") then
                collisionClone.CollisionCrouch:Destroy()
            end
    
            collisionClone.Parent = character
        end
    
        if isMines then
            if character then
                Script.Connections["AnticheatBypassTheMines"] = character:GetAttributeChangedSignal("Climbing"):Connect(function()                                
                    if Toggles.TheMinesAnticheatBypass.Value and character:GetAttribute("Climbing") then
                        task.wait(1)
                        character:SetAttribute("Climbing", false)
        
                        bypassed = true
    
                        for _, ladderEsp in pairs(Script.ESPTable.None) do
                            ladderEsp.Destroy()
                        end
    
                        Options.SpeedSlider:SetMax(45)
                        Options.FlySpeed:SetMax(75)
    
                        Script.Functions.Alert({
                            Title = "Anticheat Bypass",
                            Description = "Bypassed the anticheat successfully!",
                            Reason = "This will only last until the next cutscene!",
    
                            LinoriaMessage = "Bypassed the anticheat successfully! This will only last until the next cutscene",
    
                            Time = 7
                        })
                        if workspace:FindFirstChild("_internal_mspaint_acbypassprogress") then workspace:FindFirstChild("_internal_mspaint_acbypassprogress"):Destroy() end
                    end
                end)
            end
    
            if humanoid then
                humanoid.MaxSlopeAngle = Options.MaxSlopeAngle.Value
            end
        end
    end
    
    function Script.Functions.SetupOtherPlayerConnection(player: Player)
        if player.Character then
            if Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player)
            end
        end
    
        Library:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
            task.delay(0.1, function()
                if Toggles.PlayerESP.Value then
                    Script.Functions.PlayerESP(player)
                end
            end)
    
            Script.Connections[player.Name .. "ChildAdded"] = newCharacter.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Padlock Code",
                            Description = string.format("Library Code: %s", output),
                            Reason = (tonumber(code) and "Solved the library padlock code" or "You are still missing some books"),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
        end))
    end
end











-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Notification",
    Content = "The script has been loaded.",
    Duration = 5
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()


--uitoggle

do
    local ToggleUI = game.CoreGui:FindFirstChild("MyToggle") 
    if ToggleUI then 
    ToggleUI:Destroy()
    end
end

local MyToggle = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

--Properties:

MyToggle.Name = "MyToggle"
MyToggle.Parent = game.CoreGui
MyToggle.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = MyToggle
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.156000003, 0, -0, 0)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Image = "rbxassetid://16731758728"
ImageButton.MouseButton1Click:Connect(function()
game.CoreGui:FindFirstChild("ScreenGui").Enabled = not game.CoreGui:FindFirstChild("ScreenGui").Enabled
end)


UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ImageButton
