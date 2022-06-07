local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui;

local Terrain = workspace.Terrain;

local Remotes = ReplicatedStorage.Remotes

local TakeItem = Remotes.TakeItem;
local MergeItem = Remotes.MergeItem
local UseItem = Remotes.UseItem

local Mergers = Terrain.Mergers;

local function GetMerger()
    for Index, Value in pairs(Mergers:GetChildren()) do
        local Attributes = Value:GetAttributes();
        
        if Attributes["Owner"] then
            if Attributes["Owner"] == LocalPlayer.UserId then
                return Value;
            end
        end
    end
end

local LocalMerger = GetMerger()
local Items = LocalMerger.Items;
local Requesters = LocalMerger.Requesters;

local function GetGenerator()
    local Gen = nil;
    
    for Index, Value in pairs(Items:GetChildren()) do
        local Part = Value:FindFirstChild("Part")
        
        if Part then
            if Part.Material == Enum.Material.Neon then
                Gen = Value
                
                break
            end
        end
    end
    
    return Gen
end

local TiersVerification = {
  --[[  ["Tier1"] = function(Part)
        return Part.Color == Color3.fromRGB(165, 0, 0);
    end;
    ["Tier2"] = function(Part)
        return Part.Color == Color3.fromRGB(165, 96, 26);
    end;
    ["Tier3"] = function(Part) 
        return Part.Color == Color3.fromRGB(194, 182, 49);
    end;
    ["Tier4"] = function(Part)
        return Part.Color == Color3.fromRGB(97, 165, 68)
    end;
    ["Tier5"] = function(Part)
        return Part.Color == Color3.fromRGB(66, 165, 157)
    end;
    ["Tier6"] = function(Part)
        return Part.Color == Color3.fromRGB(58, 74, 165);
    end;
    ["Tier7"] = function(Part)
        return Part.Color == Color3.fromRGB(129, 43, 165);
    end;
    ["Tier8"] = function(Part)
        return Part.Color == Color3.fromRGB(0, 0, 0)
    end]]
}

local function MapTiers()
    for Index, Value in pairs(ReplicatedStorage.Items.Materials.Part:GetChildren()) do
        local Part = Value:FindFirstChild("Part")
        
        if Part then
            TiersVerification["Tier"..tostring(Value.Name)] = function(_Part)
                return _Part.Color == Part.Color;
            end
        end
    end
end
MapTiers()

local function GetType(Part)
    for Index, Func in pairs(TiersVerification) do
        if Func(Part) then
            return Index, Func
        end
    end
end

local function ParseTiles()
    local Tiers = {}
    
    for Index, Model in pairs(Items:GetChildren()) do
        local Part = Model:FindFirstChild("Part");
        
        if Part then
            for Index, VerificationFunc in pairs(TiersVerification) do
                if VerificationFunc(Part) then
                    if not Tiers[Index] then
                        Tiers[Index] = {}
                    end
                    
                    table.insert(Tiers[Index], Model)
                end
            end
        end
    end
    
    return Tiers
end

local function MergeItems(Tiles)
    for TileType, Table in pairs(Tiles) do
        if #Table % 2 ~= 0 then
            Table[#Table] = nil;
        end
        local Ignore = {}
        
        for Index, Tile in pairs(Table) do
            if Ignore[Index] then
                continue
            end
            
            local Split = Tile.Name:split(":")
            local NextSplit = Table[Index + 1].Name:split(":")
            print(NextSplit.Name)
            Ignore[Index + 1] = true
            
            TakeItem:FireServer(tonumber(Split[1]), tonumber(Split[2]))
            MergeItem:FireServer(tonumber(NextSplit[1]), tonumber(NextSplit[2]))
        end
    end
end

local function GenerateItems(Amount)
    Amount = Amount or 9
    local Generator = GetGenerator();
    local SplitName = Generator.Name:split(":")
    
    for i = 1,Amount*Amount do
        wait()
        UseItem:FireServer(SplitName[1], SplitName[2])
    end
end

local function ParseTasks()
    local Floaters = PlayerGui:FindFirstChild("Floaters")
    
    local Tasks = {}
    
    if Floaters then
        for Index, Value in pairs (Floaters:GetChildren()) do
            if Value.Name == "Task" then
                local Wants = Value:FindFirstChild("Wants")
                
                if Wants then
                    Tasks[Value] = {}
                    
                    for Index, Task in pairs(Wants:GetChildren()) do
                        if Task.Name == "TaskItem" then
                            local Model = Task:FindFirstChildOfClass("Model")
                            
                            if Model then
                                local Part = Model:FindFirstChild("Part")
                                
                                if Part then
                                    Tasks[Value][Task] = {
                                        Type = GetType(Part);
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return Tasks
end

local function FireAllRequesters()
    for Index, Value in pairs(Requesters:GetDescendants()) do
        if Value:IsA("TouchTransmitter") then
            LocalPlayer.Character:PivotTo(Value.Parent:GetPivot())  -- couldn't figure out what ui corresponds to which touchtransmitter + too lazy will fix later
            wait(0.8)
        end
    end
end

local function FinishTasks()
    for TaskHoldersObj, TaskHolders in pairs(ParseTasks()) do
        for TaskObj, Task in pairs(TaskHolders) do
            local Type = Task.Type;
            
            for Index, Value in pairs(Items:GetChildren()) do
                if TiersVerification[Type](Value.Part) then
                    local Split = Value.Name:split(":")
                    
                    TakeItem:FireServer(tonumber(Split[1]), tonumber(Split[2]))
                    FireAllRequesters()
                    break
                end
            end
        end
    end
end

shared.looped = true;

while shared.looped do
    GenerateItems()
    FinishTasks()
    MergeItems(ParseTiles())
    wait()
end

