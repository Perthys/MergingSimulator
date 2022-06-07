local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Terrain = workspace.Terrain;

local Remotes = ReplicatedStorage.Remotes

local TakeItem = Remotes.TakeItem;
local MergeItem = Remotes.MergeItem
local UseItem = Remotes.UseItem

local Mergers = Terrain.Mergers;
local LocalMerger = Mergers:GetChildren()[1]
local Items = LocalMerger.Items

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
    ["Tier1"] = function(Part)
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
    end
}


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

GenerateItems()
MergeItems(ParseTiles())

