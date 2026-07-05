-- MM2V.luau
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Murder Mystery II UI",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Murder Mystery 2 UI",
   LoadingSubtitle = "by ボルテックス",
   ShowText = "MM2V", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MM2ScriptVortexHub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", 
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})


local GeneralTab = Window:CreateTab("General", 4483362458)
local CharacterTab = Window:CreateTab("Character", 16346990319)
local OTScripts = Window:CreateTab("Other Scripts", 11570895459)
local MiscTab = Window:CreateTab("Miscellaneous", 12111879608)
-------------------------------------------

local RoleColorPallete = {
	["Innocent"] = Color3.fromRGB(0, 255, 0);
	["Sheriff"] = Color3.fromRGB(0, 0, 128);
	["Murderer"] = Color3.fromRGB(255, 0, 0);
	["GunDrop"] = Color3.fromRGB(0, 255, 255);
}

local InternalContent = {
	["BoolClass"] = {
		["AutoHighlights"] = {
			["Innocent"] = false,
			["Sheriff"] = false,
			["Murderer"] = false,
			["GunDrop"] = false,
		},
		["Automatic"] = {
			["KillAura"] = false,
            ["AutoGunGrab"] = false,
			["Tracers"] = false,
			["CoinFarm"] = false,
			["SilentAim"] = false,
		},
	},
	["NumberClass"] = {
		["Players"] = {
			["Hitbox"] = 1,
			["KillAuraHitbox"] = 1,
			["SilentAimPredictionTime"] = 0.01,
		},
		["ClientMod"] = {
			["WalkSpeed"] = 16,
			["JumpPower"] = 50,
			["HipHeight"] = 1.9,
		}
	},
	["TableClass"] = {
		["PlayersInGame"] = {},
		["XrayItems"] = {},
		["CameraTypes"] = {"Orbital", "Custom", "Scriptable", "Fixed", "Attach"},
		["CurrentThemes"] = {"DarkTheme", "LightTheme", "BloodTheme", "Ocean", "GrapeTheme", "Synapse", "Serpent", "Midnight"}
	},
	["ThemeClass"] = {}
}

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))


------------------------------------------
local function analyzePlayers()
	local sheriff, murderer, innocents = nil, nil, {}

	for _, plr in pairs(Players:GetPlayers()) do
		if not plr:FindFirstAncestorOfClass("Backpack") then
			plr:WaitForChild("Backpack")
		end
		if not sheriff and (plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun"))) then
			sheriff = plr
		elseif not murderer and (plr.Backpack:FindFirstChild("Knife") or (plr.Character and plr.Character:FindFirstChild("Knife"))) then
			murderer = plr
		else
			if plr == Players.LocalPlayer then continue end
			if not murderer then continue end
			if plr.Character and plr.Character.PrimaryPart and murderer and murderer.Character then
				table.insert(innocents, plr)
			end
		end
	end

	return sheriff, murderer, innocents
end

local function HighlightPlayer(Role, player)
	if player.Name == "GunDrop" then
		if not player:FindFirstChild("Highlight") then
			local newHL = Instance.new("Highlight", player)
			newHL.FillColor = RoleColorPallete[Role]

			return newHL
		end
	end
	if player and player:IsA("Player") and player.Character then
		if not player.Character:FindFirstChild("Highlight") then
			local newHL = Instance.new("Highlight", player.Character)
			newHL.FillColor = RoleColorPallete[Role]

			return newHL
		else
			local HL = player.Character:FindFirstChild("Highlight")
			if not HL then return end
			HL.FillColor = RoleColorPallete[Role]
		end
	end
end

local function getGunDrop()
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:GetAttribute("MapID") then
			if v:FindFirstChild("GunDrop") then
				return v.GunDrop
			end
		end
	end
end


local function RemoveHighlight(HL)
	if HL then
		HL:Destroy()
	end
end

local function SetInternalConfig(Class, Section, ConfigName, newValue)
	InternalContent[Class][Section][ConfigName] = newValue
end

local function GetInternalConfig(Class, Section, ConfigName)
	local location = InternalContent

	if Class then
		location = InternalContent[Class]
	end
	if Section then
		location = InternalContent[Class][Section]
	end
	if ConfigName then
		location = InternalContent[Class][Section][ConfigName]
	end

	return location
end


local GeneralSection = GeneralTab:CreateSection("Stadistics")
local CommonScripts = OTScripts:CreateSection("Common Scripts")

local CurrentSheriff = GeneralTab:CreateLabel("Sheriff: Nobody", 17118409442, Color3.fromRGB(0, 0, 128), true)
local CurrentMurderer = GeneralTab:CreateLabel("Murderer: Nobody", 6187718252, Color3.fromRGB(200, 0, 0), true)
local GunDroppedLabel = GeneralTab:CreateLabel("Gun Dropped: false", 13148110878, Color3.fromRGB(150, 150, 0), true)
local InnocentCount = GeneralTab:CreateLabel("Innocent Count: null", 9726104962, Color3.fromRGB(0, 128, 0), true)
local ServerPlayerCount = GeneralTab:CreateLabel("Server Player Count: null", 16377232199, Color3.fromRGB(125, 0, 0), true)

GeneralTab:CreateDivider("Toggles")
GeneralTab:CreateSection("General")

-- Sheriff Highlight
GeneralTab:CreateToggle({
   Name = "AutoHighlight Sheriff",
   CurrentValue = false,
   Flag = "SheriffHighlight",
   Callback = function(Enabled)
		SetInternalConfig("BoolClass", "AutoHighlights", "Sheriff", Enabled)
   end,
})

-- Murderer
GeneralTab:CreateToggle({
   Name = "AutoHighlight Murderer",
   CurrentValue = false,
   Flag = "MurdererHighlight",
   Callback = function(Enabled)
		SetInternalConfig("BoolClass", "AutoHighlights", "Murderer", Enabled)
   end,
})

-- Innocents
GeneralTab:CreateToggle({
   Name = "AutoHighlight Innocents",
   CurrentValue = false,
   Flag = "InnocentHighlight",
   Callback = function(Enabled)
		SetInternalConfig("BoolClass", "AutoHighlights", "Innocent", Enabled)
   end,
})

-- Gun Drop
GeneralTab:CreateToggle({
   Name = "AutoHighlight Gun Drop",
   CurrentValue = false,
   Flag = "AutoHighlightGunDrop",
   Callback = function(Enabled)
		SetInternalConfig("BoolClass", "AutoHighlights", "GunDrop", Enabled)
   end,
})
GeneralTab:CreateToggle({
   Name = "Auto Gun Grab",
   CurrentValue = false,
   Flag = "AutoGunGrab",
   Callback = function(state)
		SetInternalConfig("BoolClass", "Automatic", "AutoGunGrab", state)
   end,
})

local XrayItems = InternalContent["TableClass"]["XrayItems"]

-- Xray
GeneralTab:CreateToggle({
   Name = "Xray",
   CurrentValue = false,
   Flag = "XrayToggle",
   Callback = function(state)
	if state then
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Parent.Name ~= "HumanoidRootPart" then
				if not XrayItems[v] then
					XrayItems[v] = v.Transparency
					v.Transparency = 0.9
				end
			end
		end
	else
		for obj, originalTransparency in pairs(XrayItems) do
			if obj and obj:IsDescendantOf(workspace) then
				obj.Transparency = originalTransparency
			end
		end
		table.clear(XrayItems)
	end
   end,
})


-- Coin Farm
GeneralTab:CreateToggle({
   Name = "Coin Farm",
   CurrentValue = false,
   Flag = "CoinFarmToggle",
   Callback = function(state)
		SetInternalConfig("BoolClass", "Automatic", "CoinFarm", state)
   end,
})

local function GrabGun()
    local gunDrop = getGunDrop()
		local character = Players.LocalPlayer.Character

		if not character then return end
		if not gunDrop then return end
		if not character.PrimaryPart then
			Rayfield:Notify({
   				Title = "Error while grabbing gun.",
   				Content = "The function ('Grab Gun') has not detected a root part to use. This may be caused by another exploit you are using.",
 				Duration = 6.5,
   				Image = 16933997761,
			})
			return
		end

	repeat 
		if character and not character.PrimaryPart then return end
		
		gunDrop.CFrame = character.PrimaryPart.CFrame

		task.wait(0.01)
	until Players.LocalPlayer.Backpack:FindFirstChild("Gun")
end

GeneralTab:CreateButton({
   Name = "Grab Gun",
   Callback = function()
        GrabGun()
   end,
})

GeneralTab:CreateDivider("Murderer Functions")

local MurdererFunctionsSection = GeneralTab:CreateSection("Murderer Functions")
GeneralTab:CreateButton({
   Name = "Kill All",
   Callback = function()
	local character = Players.LocalPlayer.Character
	if not character then return end	

	local knife = Players.LocalPlayer.Backpack:FindFirstChild("Knife") or Players.LocalPlayer.Character:FindFirstChild("Knife")
	if knife == nil then return end
	
	if knife.Parent.Name == "Backpack" then
		knife.Parent = Players.LocalPlayer.Character
	end

	local selfRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character.PrimaryPart or nil
	if not selfRoot then return end

	local T_Remote = knife.Events:FindFirstChild("KnifeStabbed")

	for _, player in Players:GetPlayers() do
		if not player.Character then continue end
		if not player.Character.PrimaryPart then continue end

		local targetRoot = player.Character.PrimaryPart
		targetRoot.CFrame = selfRoot.CFrame * CFrame.new(0, 0, -3)
		
		task.delay(0.3, function()
			T_Remote:FireServer("Slash")
		end)
	end
   end,
})

GeneralTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAuraToggle",
   Callback = function(state)
		SetInternalConfig("BoolClass", "Automatic", "KillAura", state)
   end,
})

GeneralTab:CreateSlider({
   Name = "Kill Aura Hitbox",
   Range = {4, 125},
   Increment = 2,
   Suffix = "Aura Studs",
   CurrentValue = 4,
   Flag = "KillAuraHitboxFlag",
   Callback = function(Value)
	  SetInternalConfig("NumberClass", "Players", "KillAuraHitbox", Value)
   end,
})

local SharedFunctions = GeneralTab:CreateSection("Shared Functions")

GeneralTab:CreateToggle({
   Name = "Silent Aim (Experimental)",
   CurrentValue = false,
   Flag = "SilentAimFlag",
   Callback = function(state)
		SetInternalConfig("BoolClass", "Automatic", "SilentAim", state)
   end,
})
GeneralTab:CreateSlider({
   Name = "Silent Aim Movement Prediction Time",
   Range = {0.01, 1.15},
   Increment = 0.01,
   Suffix = "Prediction Time",
   CurrentValue = 0.15,
   Flag = "SAPT",
   Callback = function(Value)
	  SetInternalConfig("NumberClass", "Players", "SilentAimPredictionTime", Value)
   end,
})


local HumanoidSection = CharacterTab:CreateSection("Humanoid Properties")

CharacterTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSliderFlag",
   Callback = function(newSpeed)
	  SetInternalConfig("NumberClass", "ClientMod", "WalkSpeed", newSpeed)
   end,
})

CharacterTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JPSliderFlag",
   Callback = function(newJP)
	  SetInternalConfig("NumberClass", "ClientMod", "JumpPower", newJP)
   end,
})

CharacterTab:CreateSlider({
   Name = "Hip Height",
   Range = {1.9, 10},
   Increment = 1,
   Suffix = "Height",
   CurrentValue = 1.9,
   Flag = "HHSlider",
   Callback = function(Value)
	  SetInternalConfig("NumberClass", "ClientMod", "HipHeight", Value)
   end,
})

CharacterTab:CreateDivider()

local CameraSection = CharacterTab:CreateSection("Camera Properties")

CharacterTab:CreateSlider({
   Name = "Field Of View",
   Range = {70, 120},
   Increment = 1,
   Suffix = "Field Of View",
   CurrentValue = 70,
   Flag = "FOV_Slider",
   Callback = function(Value)
	  game:GetService("Workspace").CurrentCamera.FieldOfView = Value

   end,
})

CharacterTab:CreateDivider()

OTScripts:CreateButton({
   Name = "Load Infinite Yield",
   Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

OTScripts:CreateButton({
   Name = "Load Vynixu's MM2 GUI (OLD)",
   Callback = function()
		loadstring(game:GetObjects("rbxassetid://4001118261")[1].Source)()
   end,
})

OTScripts:CreateSection("Debugging Exploits")

OTScripts:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
   end,
})

OTScripts:CreateButton({
   Name = "Remote Spy",
   Callback = function()
		local failureData = {
			reason = "",
			hasError = false,
		}

		if typeof(hookmetamethod) ~= "function" then
			failureData.hasError = true
			failureData.reason = "Your exploit does not support hookmetamethod."
		end

		if typeof(getnamecallmethod) ~= "function" then
			failureData.hasError = true
			failureData.reason = "Your exploit does not support getnamecallmethod."
		end

		if failureData.hasError then
			Rayfield:Notify({
   		Title = "Unable to execute Remote Spy.",
   		Content = failureData.reason,
   		Duration = 6.5,
  		 Image = 5107154082,
		})
		failureData.hasError = false
		return
		end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
   end,
})
OTScripts:CreateButton({
   Name = "Audio Logger",
   Callback = function()
		local failureData = {
			reason = "",
			hasError = false,
		}

		if failureData.hasError then
			Rayfield:Notify({
   		Title = "Unable to execute Audio Logger.",
   		Content = failureData.reason,
   		Duration = 6.5,
  		 Image = 5107154082,
		})
		failureData.hasError = false
		return
		end
		loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
   end,
})

local WeaponServiceModule = cloneref(game:GetService("ReplicatedStorage").ClientServices.WeaponService)
local WeaponService = require(WeaponServiceModule)
local lp = Players.LocalPlayer

task.spawn(function()
    getgenv()._silentAimTarget = nil
    while true do
    
        local target = nil
        
        for _, plr in next, Players:GetPlayers() do
            if plr == lp then continue end
        
          local backpack = plr.Backpack
            local char = plr.Character
        
            if backpack and backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife")) then
                target = plr
                getgenv().silentAimTarget = target
                break
            elseif backpack and backpack:FindFirstChild("Gun") or (char and char:FindFirstChild("Gun")) then
                target = plr
                getgenv().silentAimTarget = target
            end
        end

        task.wait(1)
    end
end)

local old_GetMouseTargetCFrame = nil;
local old_GetMouseTargetCFrame;
old_GetMouseTargetCFrame = hookfunction(WeaponService.GetMouseTargetCFrame, function()
    if not GetInternalConfig("BoolClass", "Automatic", "SilentAim") then
        return old_GetMouseTargetCFrame()
    end
    
    local target = getgenv().silentAimTarget

    if not target then
        return old_GetMouseTargetCFrame()
    end
    
    if not target.Character then
        return old_GetMouseTargetCFrame()
    end
    
    local part = target.Character:FindFirstChild("Head")
    if not part then
        return old_GetMouseTargetCFrame()
    end
    
    if not part:IsA("BasePart") then
        return old_GetMouseTargetCFrame()
    end
    
    local velocity = part.AssemblyLinearVelocity
    local predictedPos = part.Position + (velocity * GetInternalConfig("NumberClass", "Players", "SilentAimPredictionTime"))
    
    return CFrame.new(predictedPos)
end)

-------------------------------------

game:GetService("RunService").RenderStepped:Connect(function()
	local sheriff, murderer, innocents = analyzePlayers()
	local gunDrop = getGunDrop()
	TracerLines = {}

	if not GetInternalConfig("BoolClass", "Automatic", "Tracers") then
		for _, tracer in pairs(TracerLines) do
			tracer:Remove()
		end
	end

	-- Sheriff
	if sheriff and sheriff.Character then
		CurrentSheriff:Set("Sheriff: " .. sheriff.Name)
		if GetInternalConfig("BoolClass", "AutoHighlights", "Sheriff") then
			HighlightPlayer("Sheriff", sheriff)
		else
			RemoveHighlight(sheriff.Character:FindFirstChild("Highlight"))
		end
	else
		CurrentSheriff:Set("Sheriff: Nobody")
	end

	-- Murderer
	if murderer and murderer.Character then
		CurrentMurderer:Set("Murderer: " .. murderer.Name)
		if GetInternalConfig("BoolClass", "AutoHighlights", "Murderer") then
			HighlightPlayer("Murderer", murderer)
		else
			RemoveHighlight(murderer.Character:FindFirstChild("Highlight"))
		end
	else
		CurrentMurderer:Set("Murderer: Nobody")
	end

	InnocentCount:Set("Innocent Count: ".. tostring(#innocents))
	ServerPlayerCount:Set("Server Player Count: "..#Players:GetPlayers())

	-- Innocents
	for _, plr in pairs(innocents) do
		if plr.Character then
			if GetInternalConfig("BoolClass", "AutoHighlights", "Innocent") then
				HighlightPlayer("Innocent", plr)
			else
				RemoveHighlight(plr.Character:FindFirstChild("Highlight"))
			end
		end
	end

	if gunDrop then
        if GetInternalConfig("BoolClass", "Automatic", "AutoGunGrab") == true then
            GrabGun()
        end
		GunDroppedLabel:Set("Gun Dropped: true")
	else
		GunDroppedLabel:Set("Gun Dropped: false")
	end

	if gunDrop then
		if InternalContent["BoolClass"]["AutoHighlights"].GunDrop then
			HighlightPlayer("GunDrop", gunDrop)
		else
			RemoveHighlight(gunDrop:FindFirstChild("Highlight"))
        end
	end

	if Players.LocalPlayer.Character then
		if Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			Players.LocalPlayer.Character.Humanoid.WalkSpeed = GetInternalConfig("NumberClass", "ClientMod", "WalkSpeed")
			Players.LocalPlayer.Character.Humanoid.JumpPower = GetInternalConfig("NumberClass", "ClientMod", "JumpPower")
			Players.LocalPlayer.Character.Humanoid.HipHeight = GetInternalConfig("NumberClass", "ClientMod", "HipHeight")
		end
	end

	if GetInternalConfig("BoolClass", "Automatic", "KillAura") == true then
		local knife = Players.LocalPlayer.Backpack:FindFirstChild("Knife") or Players.LocalPlayer.Character:FindFirstChild("Knife")
		if knife == nil then return end
		if not Players.LocalPlayer.Character:FindFirstChild(knife.Name) then
			return
		end

		for _, v in pairs(Players:GetPlayers()) do
			if v.Name == Players.LocalPlayer.Name then continue end

			if v.Character and Players.LocalPlayer.Character then
				if v.Character:FindFirstChild("HumanoidRootPart") then
					if Players.LocalPlayer.Character and Players.LocalPlayer.Character.PrimaryPart  then
						local root = v.Character:FindFirstChild("HumanoidRootPart")
						local selfChar = Players.LocalPlayer.Character

						local dist = (selfChar.PrimaryPart.Position - root.Position).Magnitude

						if dist <= GetInternalConfig("NumberClass", "Players", "KillAuraHitbox") then
							root.CFrame = selfChar.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
							task.delay(0.3, function()
								knife.Events.KnifeStabbed:FireServer("Slash")
							end)
						end
					end
				end
			end
		end
	end
end)

spawn(function()
	while wait(1) do
		if GetInternalConfig("BoolClass", "Automatic", "CoinFarm") == true then
			local function getMap()
	for _, mod in pairs(workspace:GetChildren()) do
		if mod:IsA("Model") and mod:GetAttribute("MapID") then
			return mod
		end
	end
end

local collected = 0

if getMap() ~= nil then
	for _, coin in pairs(getMap():GetDescendants()) do
				if tostring(coin):lower() ~= "coin_server" then continue end
					local character = Players.LocalPlayer.Character

					if not character then
						return
					end

					if not character.PrimaryPart then
						return
					end
					if coin and coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Transparency ~= 0 then
						continue
					end
					
						collected += 1

						if character:FindFirstChild("Humanoid") then
							if character.Humanoid.Health < 1 then
								collected = 0
								break
							end
						end

						if collected >= 50 then
							collected = 0
							break
						end

						local sheriff, murderer, innocent = analyzePlayers()

						if not murderer then
							break
						end

						if getMap() == nil then collected = 0 break end
						if character.Humanoid.Health < 1 then break end
						if not GetInternalConfig("BoolClass", "Automatic", "CoinFarm") then break end

						game:GetService("TweenService"):Create(character.PrimaryPart, 
							TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
							{CFrame = coin.CFrame}
						):Play()

					task.wait(6)
				end
			end
		end
	end
end) 
