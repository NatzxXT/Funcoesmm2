-- ==========================================
-- REPOSITÓRIO B: MÓDULOS DO JOGO (Funcoes.lua)
-- ==========================================

-- 1. Espera o HUD do Repositório A carregar
repeat task.wait() until getgenv().YARHM and getgenv().YARHM_FUNCTIONS

-- 2. O TRUQUE: Criamos um 'script' falso que aponta para o Menu do Repositório A
local script = { Parent = getgenv().YARHM }

-- 3. Puxa as funções do menu
local fu = getgenv().YARHM_FUNCTIONS

-- ==========================================
-- COLE AS ROTINAS A PARTIR DAQUI:
-- ==========================================

local function JWXW_routine() -- StarterGui.YARHM.Universal
    local script = { Parent = getgenv().YARHM }
    -- CORREÇÃO PARA EXECUTORES QUE NÃO TÊM 'require'
    local req = require or function() return nil end
    local require = function(obj)
        local routine = routine_module_scripts and routine_module_scripts[obj]
        if routine then return routine() end
        return req(obj)
    end

    -- © Aetherion 2026

	local module = {}
	module["gameId"] = 0
	if (module["gameId"] ~= game.GameId) and module["gameId"] ~= 0 then
		script.Enabled = true
	end
	
	local ts = game:GetService("TweenService")
	local uis = game:GetService("UserInputService")
	local rs = game:GetService("RunService")
	local https = game:GetService("HttpService")
	local Players = game:GetService("Players")
	
	local fu = require(script.Parent.FUNCTIONS)
	local theme = require(script.Parent.Theme)
	local espind = require(script.Parent.ESPIndicator)
	local flyutility = require(script.Parent.FlyUtility)
	local PointSave = require(script.Parent.PointSave)
	
	local loopfovandws = false
	local ctrlclicktp = false
	local ws = 16
	local fov = 70
	
	local hidden = false
	
	local YARHMPointSave = PointSave.new("YARHM")
	
	function splitString(str,delim)
		local broken = {}
		if delim == nil then delim = "," end
		for w in string.gmatch(str,"[^"..delim.."]+") do
			table.insert(broken,w)
		end
		return broken
	end
	
	function toTokens(str)
		local tokens = {}
		for op,name in string.gmatch(str,"([+-])([^+-]+)") do
			table.insert(tokens,{Operator = op,Name = name})
		end
		return tokens
	end
	
	function onlyIncludeInTable(tab,matches)
		local matchTable = {}
		local resultTable = {}
		for i,v in pairs(matches) do matchTable[v.Name] = true end
		for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
		return resultTable
	end
	
	function removeTableMatches(tab,matches)
		local matchTable = {}
		local resultTable = {}
		for i,v in pairs(matches) do matchTable[v.Name] = true end
		for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
		return resultTable
	end
	
	function getPlayersByName(Name)
		local Name,Len,Found = string.lower(Name),#Name,{}
		for _,v in pairs(Players:GetPlayers()) do
			if Name:sub(0,1) == '@' then
				if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
					table.insert(Found,v)
				end
			else
				if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
					table.insert(Found,v)
				end
			end
		end
		return Found
	end
	
	function getPlayer(list,speaker)
		if list == nil then return {speaker.Name} end
		local nameList = splitString(list,",")
		local foundList = {}
		for _,name in pairs(nameList) do
			if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
			local tokens = toTokens(name)
			local initialPlayers = Players:GetPlayers()
			for i,v in pairs(tokens) do
				if v.Operator == "+" then
					local tokenContent = v.Name
					local foundCase = false
					if not foundCase then initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent)) end
				else
					local tokenContent = v.Name
					local foundCase = false
					if not foundCase then initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent)) end
				end
			end
			for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
		end
		local foundNames = {}
		for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end
		return foundNames[1]
	end
	
	task.spawn(function()
		rs.RenderStepped:Connect(function()
			if loopfovandws then
				workspace.CurrentCamera.FieldOfView = fov
				if game.Players.LocalPlayer.Character then
					if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
						game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = ws
					end
				end
			end
		end)
	end)
	
	uis.InputBegan:Connect(function(inp, proc)
		if proc then return end
		if uis:IsKeyDown(Enum.KeyCode.LeftControl) and inp.KeyCode == Enum.KeyCode.Y and hidden then
			hidden = false
			ts:Create(script.Parent.Menu.UIScale, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 1}):Play()
		end
	end)
	
	local function getPlayerMouse()
		local player = game:GetService("Players").LocalPlayer
		if player then return player:GetMouse() end
		return nil
	end
	
	local function getRayHitPosition()
		local mouse = getPlayerMouse()
		if not mouse then return nil end
		local camera = workspace.CurrentCamera
		local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
		local part, position = workspace:FindPartOnRay(ray, game:GetService("Players").LocalPlayer.Character)
		if part then return position else return nil end
	end
	
	uis.InputBegan:Connect(function(inp, proc)
		if proc then return end
		if uis:IsKeyDown(Enum.KeyCode.LeftControl) and inp.UserInputType == Enum.UserInputType.MouseButton1 and ctrlclicktp then
			local ray = getRayHitPosition()
			if not ray then fu.notification("Couldn't find a place to teleport to.") return end
			game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(ray)
		end
	end)
	
	if uis.AccelerometerEnabled then
		uis.DeviceAccelerationChanged:Connect(function(acc)
			if hidden and acc.Position.Magnitude > 28 then
				hidden = false
				ts:Create(script.Parent.Menu.UIScale, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end 
		end)
	end
	
	module["Name"] = "Universal"
	
	local ts = game:GetService("TweenService")
	
	table.insert(module, {
		Type = "Text",
		Args = {"<font color='#FFFF00'>Another great script</font> by YARHM developers below!"}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"AFEM Max - The best AI-powered emote script!", function()
			loadstring(game:HttpGet("https://yarhm.mhi.im/scr?channel=afemmax"))()
			fu.notification("AFEM has been executed.")
		end,}
	})
	
	table.insert(module, {
		Type = "Text",
		Args = {"---"}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Join our Discord", function(Self)
			if setclipboard then setclipboard("https://discord.gg/2jbYxvDkxr") end
			fu.notification('Discord link has been copied to clipboard!')
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Fly"} })
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"OP Fly", function(Self, state)
			if state then flyutility:Start(Players.LocalPlayer.Character)
			else flyutility:Stop(Players.LocalPlayer.Character) end
		end}
	})
	
	table.insert(module, {
		Type = "Range",
		Args = {"Fly speed", 50, 350, 10, function(Self, spd)
			flyutility:SetMaxSpeed(spd)
		end}
	})
	
	local infJump = false
	local infJumpConnection = nil
	local landedConnection = nil
	local infJumps = 0
	local infJumpDeb = false
	local infJumpOnlyTwo = false
	local landed = true
	
	local function setupHumanoid(humanoid)
		if landedConnection then landedConnection:Disconnect() end
		landedConnection = humanoid.StateChanged:Connect(function(_, n)
			if n == Enum.HumanoidStateType.Landed or n == Enum.HumanoidStateType.Running then
				landed = true
				infJumps = 0
			end
		end)
	end
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Jumping"} })
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Infinite jump", function(Self, state)
			infJump = state
			if state then
				local char = game.Players.LocalPlayer.Character
				if char and char:FindFirstChildWhichIsA("Humanoid") then
					setupHumanoid(char:FindFirstChildWhichIsA("Humanoid"))
				end
				infJumpConnection = uis.JumpRequest:Connect(function()
					local character = game.Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
					if not humanoid then return end
					if infJumpOnlyTwo and infJumps >= 2 and not landed then return end
					if not infJumpDeb then
						infJumpDeb = true
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						infJumps += 1
						landed = false
						task.wait(.1)
						infJumpDeb = false
					end
				end)
			else
				if infJumpConnection then infJumpConnection:Disconnect() end
				if landedConnection then landedConnection:Disconnect() end
				infJumps = 0
				landed = true
			end
		end}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Limit infinite jump to 2 jumps only", function(Self, state)
			infJumpOnlyTwo = state
			infJumps = 0 
		end}
	})
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Hitbox mod"} })
	
	local aggressiveExp = false
	local hitboxExp = 1
	table.insert(module, {
		Type = "Input",
		Args = {"Hitbox expander", "Expand everyone's hitbox", function(Self, ToExpand)
			hitboxExp = ToExpand
			local players = game:GetService("Players"):GetPlayers()
			for i,v in ipairs(players) do
				if v ~= game.Players.LocalPlayer and v.Character:FindFirstChild('HumanoidRootPart') then
					local sizeArg = tonumber(ToExpand)
					local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
					if aggressiveExp then
						for _, part in ipairs(v.Character:GetChildren()) do
							if part:IsA("BasePart") then
								if not ToExpand or sizeArg == 1 then
									part.Size = Vector3.new(2,1,1)
									part.Transparency = 0.2
								else
									part.Size = Size
									part.Transparency = 0.2
								end
							end
						end
					else
						local Root = v.Character:FindFirstChild('HumanoidRootPart')
						if Root:IsA("BasePart") then
							if not ToExpand or sizeArg == 1 then
								Root.Size = Vector3.new(2,1,1)
								Root.Transparency = 0.2
							else
								Root.Size = Size
								Root.Transparency = 0.2
							end
							Root.CanCollide = false
						end
					end
				end
			end
			fu.notification("Hitboxes expanded.")
		end,}
	})
	
	local loopHitBoxExp
	table.insert(module, {
		Type = "Toggle",
		Args = {"Loop hitbox expansion", function(Self, state)
			if state then
				loopHitBoxExp = rs.Heartbeat:Connect(function()
					local players = game:GetService("Players"):GetPlayers()
					for i,v in ipairs(players) do
						if v ~= game.Players.LocalPlayer and v.Character:FindFirstChild('HumanoidRootPart') then
							local sizeArg = tonumber(hitboxExp)
							local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
							local Root = v.Character:FindFirstChild('HumanoidRootPart')
							if aggressiveExp then
								for _, part in ipairs(v.Character:GetChildren()) do
									if part:IsA("BasePart") then
										if not hitboxExp or sizeArg == 1 then
											part.Size = Vector3.new(2,1,1)
											part.Transparency = 0.2
										else
											part.Size = Size
											part.Transparency = 0.2
										end
									end
								end
							else
								local Root = v.Character:FindFirstChild('HumanoidRootPart')
								if Root:IsA("BasePart") then
									if not hitboxExp or sizeArg == 1 then
										Root.Size = Vector3.new(2,1,1)
										Root.Transparency = 0.2
									else
										Root.Size = Size
										Root.Transparency = 0.2
									end
									Root.CanCollide = false
								end
							end
						end
					end
				end)
			else
				loopHitBoxExp:Disconnect()
			end
		end,}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Aggressive hitbox expasion (all parts)", function(Self, state)
			aggressiveExp = state
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Speed and view"} })
	
	table.insert(module, {
		Type = "Input",
		Args = {"Walkspeed", "Set speed", function(Self, speed)
			local lp = game:GetService("Players").LocalPlayer
			local char = lp.Character
			if not char then fu.notification("No character!") return end
			local hu = char:FindFirstChildOfClass("Humanoid")
			if not hu then fu.notification("No humanoid on your character..?") return end
			hu.WalkSpeed = tonumber(speed) or 16
			fu.notification("Walkspeed set.")
			ws = tonumber(speed) or 16
		end,}
	})
	
	local walkspeedInDeCrement = 2
	table.insert(module, {
		Type = "Button",
		Args = {"Increase walkspeed", function(Self)
			local lp = game:GetService("Players").LocalPlayer
			local char = lp.Character
			if not char then fu.notification("No character!") return end
			local hu = char:FindFirstChildOfClass("Humanoid")
			if not hu then fu.notification("No humanoid on your character..?") return end
			ws = ws + walkspeedInDeCrement
			hu.WalkSpeed = hu.WalkSpeed + walkspeedInDeCrement
			fu.notification("Walkspeed is now ".. hu.WalkSpeed)
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Decrease walkspeed", function(Self)
			local lp = game:GetService("Players").LocalPlayer
			local char = lp.Character
			if not char then fu.notification("No character!") return end
			local hu = char:FindFirstChildOfClass("Humanoid")
			if not hu then fu.notification("No humanoid on your character..?") return end
			ws = ws - walkspeedInDeCrement
			hu.WalkSpeed = hu.WalkSpeed - walkspeedInDeCrement
			fu.notification("Walkspeed is now ".. hu.WalkSpeed)
		end,}
	})
	
	table.insert(module, {
		Type = "Input",
		Args = {"Walkspeed increment (How big each increase/decrease is)", "Set", function(Self, input)
			walkspeedInDeCrement = tonumber(input) or 2
			if not tonumber(input) then fu.notification("Not a number. Setting to default (2).") end
			fu.notification("Set walkspeed increment to ".. walkspeedInDeCrement)
		end,}
	})
	
	table.insert(module, {
		Type = "Input",
		Args = {"FOV change", "Set FOV", function(Self, tofov)
			if not tonumber(tofov) then fu.notification("Not a number. Setting to default.") end
			ts:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {FieldOfView = tonumber(tofov) or 70}):Play()
			fov = tonumber(tofov) or 70
		end,}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Loop walkspeed and FOV", function(Self, state)
			loopfovandws = state
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Teleports"} })
	
	if uis.KeyboardEnabled and uis.MouseEnabled then
		table.insert(module, {
			Type = "Toggle",
			Args = {"CTRL+Click Teleport", function(Self, state)
				ctrlclicktp = state
			end,}
		})
	end
	
	local function gotoPlayer(targetPlayerName)
		local targetPlayer = Players:FindFirstChild(getPlayer(targetPlayerName, game.Players.LocalPlayer))
		if targetPlayer then
			local character = targetPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local targetPosition = character.HumanoidRootPart.Position
				local playerCharacter = Players.LocalPlayer.Character
				if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
					playerCharacter.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
				end
			end
		else print("Player '" .. targetPlayerName .. "' not found.") end
	end
	
	table.insert(module, {
		Type = "Input",
		Args = {"Enter player's name", "Teleport", function(Self, text) gotoPlayer(text) end}
	})
	
	local spectateLoop = nil
	table.insert(module, {
		Type = "Button",
		Args = {"Spectate players", function(Self)
			local listofplayers = game.Players:GetPlayers()
			local currentlyViewing = 1
			local currentPlayer = listofplayers[currentlyViewing]
			if not currentPlayer then return end
			workspace.CurrentCamera.CameraSubject = currentPlayer.Character.Humanoid
			spectateLoop = task.spawn(function()
				while true do
					fu.dialog("Spectating...", "Now spectating: " .. workspace.CurrentCamera.CameraSubject.Parent.Name, {"Previous", "Stop", "Next"})
					local action = fu.waitfordialog()
					if action == "Stop" then
						fu.closedialog()
						workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
						task.cancel(spectateLoop)
						break
					elseif action == "Next" then
						currentlyViewing = currentlyViewing + 1
						if currentlyViewing > #listofplayers then currentlyViewing = 1 end
						currentPlayer = listofplayers[currentlyViewing]
						if not currentPlayer then return end
						workspace.CurrentCamera.CameraSubject = currentPlayer.Character.Humanoid
					elseif action == "Previous" then
						currentlyViewing = currentlyViewing - 1
						if currentlyViewing < 1 then currentlyViewing = #listofplayers end
						currentPlayer = listofplayers[currentlyViewing]
						if not currentPlayer then return end
						workspace.CurrentCamera.CameraSubject = currentPlayer.Character.Humanoid
					end
				end
			end)
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {""} })
	table.insert(module, { Type = "Text", Args = {"Aim locking"} })
	
	local aimlockrscon
	local target
	
	table.insert(module, {
		Type = "Input",
		Args = {"Target player", "Set target", function(Self, input)
			if not Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer)) then
				fu.notification("Player not found.")
				return
			end
			fu.notification("Target is set to " .. Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer)).Name)
			target = Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer))
		end,}
	})
	
	local aimlock = false
	local cam = workspace.CurrentCamera
	table.insert(module, {
		Type = "Button",
		Args = {"Aim lock", function(Self)
			if aimlock then return end
			if aimlockrscon then aimlockrscon:Disconnect() end
			if not target then fu.notification("Set a target first.") return end
			aimlockrscon = rs.RenderStepped:Connect(function()
				if not target then fu.notification("No valid target.") aimlockrscon:Disconnect() return end
				if not target.Character then return end
				if not target.Character:FindFirstChild("HumanoidRootPart") then return end
				cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character:FindFirstChild("HumanoidRootPart").Position)
			end)
			aimlock = true
			fu.notification("Aim lock is now on.")
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Unaim lock", function(Self)
			if not aimlock then return end
			aimlock = false
			if aimlockrscon then aimlockrscon:Disconnect() end
			fu.notification("Aim lock is now off.")
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {"Fling"} })
	
	local playerToFling
	table.insert(module, {
		Type = "Input",
		Args = {"Target fling player", "Set target", function(Self, input)
			if not Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer)) then
				fu.notification("Player not found.")
				return
			end
			fu.notification("Target is set to " .. Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer)).Name)
			playerToFling = Players:FindFirstChild(getPlayer(input, game.Players.LocalPlayer))
		end,}
	})
	
	local antiFling = false
	table.insert(module, {
		Type = "ButtonGrid",
		Args = {1, {
			Fling = function(Self)
				if not playerToFling then
					fu.notification("You need to target a player to fling.")
					return
				end
				if not Players:FindFirstChild(playerToFling.Name) then
					fu.notification("You need to target a player to fling.")
					return
				end
				if antiFling then
					fu.notification("Turn off anti-fling to use fling.")
					return
				end
				local player = game.Players.LocalPlayer
				local mouse = player:GetMouse()
				local Targets = {playerToFling}
				local Players = game:GetService("Players")
				local Player = Players.LocalPlayer
				local AllBool = false
				local SkidFling = function(TargetPlayer)
					local Character = Player.Character
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
					local RootPart = Humanoid and Humanoid.RootPart
					local TCharacter = TargetPlayer.Character
					local THumanoid
					local TRootPart
					local THead
					local Accessory
					local Handle
					if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
					if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
					if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
					if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
					if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
					if Character and Humanoid and RootPart then
						if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
						if THead then
							if THead.Velocity.Magnitude > 500 then
								fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
								if fu.waitfordialog() == "No" then return fu.closedialog() end
								fu.closedialog()
							end
						elseif not THead and Handle then
							if Handle.Velocity.Magnitude > 500 then
								fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
								if fu.waitfordialog() == "No" then return fu.closedialog() end
								fu.closedialog()
							end
						end
						if THead then workspace.CurrentCamera.CameraSubject = THead
						elseif not THead and Handle then workspace.CurrentCamera.CameraSubject = Handle
						elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
						if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
						local FPos = function(BasePart, Pos, Ang)
							RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
							Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
							RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
							RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
						end
						local SFBasePart = function(BasePart)
							local TimeToWait = 2
							local Time = tick()
							local Angle = 0
							repeat
								if RootPart and THumanoid then
									if BasePart.Velocity.Magnitude < 50 then
										Angle = Angle + 100
										FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
									else
										FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
										task.wait()
										FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
										task.wait()
									end
								else break end
							until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or TargetPlayer.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
						end
						workspace.FallenPartsDestroyHeight = 0/0
						local BV = Instance.new("BodyVelocity")
						BV.Name = "EpixVel"
						BV.Parent = RootPart
						BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
						BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
						if TRootPart and THead then
							if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
						elseif TRootPart and not THead then SFBasePart(TRootPart)
						elseif not TRootPart and THead then SFBasePart(THead)
						elseif not TRootPart and not THead and Accessory and Handle then SFBasePart(Handle)
						else fu.notification("Can't find a proper part of target player to fling.") end
						BV:Destroy()
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
						workspace.CurrentCamera.CameraSubject = Humanoid
						repeat
							RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
							Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
							Humanoid:ChangeState("GettingUp")
							table.foreach(Character:GetChildren(), function(_, x)
								if x:IsA("BasePart") then
									x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
								end
							end)
							task.wait()
						until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
						workspace.FallenPartsDestroyHeight = getgenv().FPDH
					else fu.notification("No valid character of said target player. May have died.") end
				end
				SkidFling(Targets[1])
			end,
		}}
	})
	
	local antiFlingLastPos = Vector3.zero
	local flingNeutralizerCon
	local flingDetectionCon
	local detectedPlayers = {}
	table.insert(module, {
		Type = "Toggle",
		Args = {"Anti-fling", function(Self, state)
			antiFling = state
			if state then
				fu.notification("Anti-fling activated.")
				flingDetectionCon = rs.Heartbeat:Connect(function()
					for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
						if pl.Character:IsDescendantOf(workspace) then
							if pl.Character.PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or pl.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
								if not detectedPlayers[pl.Name] then
									fu.notification("A flinger has been detected with the name " .. pl.Name .. "!")
									detectedPlayers[pl.Name] = true
								end
								for _, p in ipairs(pl.Character:GetDescendants()) do
									if p:IsA("BasePart") then
										p.CanCollide = false
										p.AssemblyAngularVelocity = Vector3.zero
										p.AssemblyLinearVelocity = Vector3.zero
										p.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)
									end
								end
							end
						end
					end
				end)
				flingNeutralizerCon = rs.Heartbeat:Connect(function()
					if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart then
						if game.Players.LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or game.Players.LocalPlayer.Character.PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
							fu.notification("You were flung. Neutralizing velocity!")
							game.Players.LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
							game.Players.LocalPlayer.Character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
							if antiFlingLastPos ~= Vector3.zero then
								game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(antiFlingLastPos)
							end
						else
							antiFlingLastPos = game.Players.LocalPlayer.Character.PrimaryPart.Position
						end
					end
				end)
			else
				flingDetectionCon:Disconnect()
				flingNeutralizerCon:Disconnect()
				detectedPlayers = {}
				fu.notification("Anti-fling deactivated.")
			end
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {"Miscellaneous"} })
	
	table.insert(module, {
		Type = "Button",
		Args = {"Anti AFK detection", function(Self)
			local pl = game.Players.LocalPlayer
			if getconnections then
				for _, connection in pairs(getconnections(pl.Idled)) do
					if connection["Disable"] then connection["Disable"](connection)
					elseif connection["Disconnect"] then connection["Disconnect"](connection) end
				end
			else
				pl.Idled:Connect(function()
					game:GetService("VirtualUser"):CaptureController()
					game:GetService("VirtualUser"):ClickButton2(Vector2.new())
				end)
			end
		end,}
	})
	
	pcall(function()
		if game:GetService("CoreGui"):FindFirstChild("DeltaIcon") then
			table.insert(module, {
				Type = "Toggle",
				Args = {"Hide Delta Icon", function(Self, state)
					game:GetService("CoreGui"):FindFirstChild("DeltaIcon").Enabled = state
				end,}
			})
		end
	end)
	
	table.insert(module, {
		Type = "Button",
		Args = {"Hide YARHM", function(Self)
			if uis.KeyboardEnabled then
				ts:Create(script.Parent.Menu.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 0}):Play()
				hidden=true
				fu.notification("Press CTRL+SHIFT+Y to bring back the menu.")
			elseif uis.AccelerometerEnabled then
				ts:Create(script.Parent.Menu.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 0}):Play()
				hidden=true
				fu.notification("Shake your device to bring back the menu.")
			else
				fu.notification("Can't hide YARHM!")
			end
		end,}
	)
	
	table.insert(module, {
		Type = "Button",
		Args = {"FPS Boost", function(Self)
			fu.dialog("FPS boosting", "FPS boosting can have unpredictable effects. You may instead lag more using this!", {"FPS boost anyway", "Nevermind"})
			local result = fu.waitfordialog()
			fu.closedialog()
			if result == "FPS boost anyway" then
				local Terrain = workspace:FindFirstChildOfClass('Terrain')
				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
				Terrain.WaterTransparency = 0
				game.Lighting.GlobalShadows = false
				game.Lighting.FogEnd = 9e9
				pcall(function() settings().Rendering.QualityLevel = 1 end)
				for i,v in pairs(game:GetDescendants()) do
					if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
						v.Material = "Plastic"
						v.Reflectance = 0
					elseif v:IsA("Decal") then v.Transparency = 1
					elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
					elseif v:IsA("Explosion") then v.BlastPressure = 1; v.BlastRadius = 1 end
				end
				for i,v in pairs(game.Lighting:GetDescendants()) do
					if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
						v.Enabled = false
					end
				end
				workspace.DescendantAdded:Connect(function(child)
					task.spawn(function()
						if child:IsA('ForceField') then rs.Heartbeat:Wait(); child:Destroy()
						elseif child:IsA('Sparkles') then rs.Heartbeat:Wait(); child:Destroy()
						elseif child:IsA('Smoke') or child:IsA('Fire') then rs.Heartbeat:Wait(); child:Destroy() end
					end)
				end)
			end
		end,}
	})
	
	local rsloopconnectionfling
	local clip = true
	local nocliploop
	
	table.insert(module, {
		Type = "ButtonGrid",
		Args = {2, {
			Noclip = function()
				clip = false
				nocliploop = rs.Stepped:Connect(function()
					if clip == false and game.Players.LocalPlayer.Character ~= nil then
						for _, child in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
							if child:IsA("BasePart") and child.CanCollide == true then child.CanCollide = false end
						end
					end
				end)
			end,
			Reclip = function()
				if clip then return end
				clip = true
				nocliploop:Disconnect()
				fu.notification("Reclipping may need you to reset your character.")
			end,
		}}})
	
	table.insert(module, { Type = "Text", Args = {"Other"} })
	
	table.insert(module, {
		Type = "Button",
		Args = {"Get ping", function(Self)
			fu.notification(game.Players.LocalPlayer:GetNetworkPing() * 1000)
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Open developer console (debugging)", function(Self)
			game.StarterGui:SetCore("DevConsoleVisible", true)
		end}
	)
	
	function themeSerialize(data)
		local function s(v)
			local t = typeof(v)
			if t == "number" or t == "string" or t == "boolean" then return v
			elseif t == "Color3" then return {__type="Color3", r=math.floor(v.R*255+0.5), g=math.floor(v.G*255+0.5), b=math.floor(v.B*255+0.5)}
			elseif t == "EnumItem" then return {__type="EnumItem", enumType=v.EnumType.Name, name=v.Name}
			elseif t == "ColorSequence" then
				local kp = {}
				for _, k in ipairs(v.Keypoints) do
					table.insert(kp, {t=k.Time, v={r=math.floor(k.Value.R*255+0.5), g=math.floor(k.Value.G*255+0.5), b=math.floor(k.Value.B*255+0.5)}})
				end
				return {__type="ColorSequence", keypoints=kp}
			elseif t == "table" then
				local out = {}
				for k, val in pairs(v) do if k ~= "font" then out[k] = s(val) end end
				return out
			else error("Unsupported type: " .. t) end
		end
		return s(data)
	end
	
	function themeDeserialize(data)
		local function d(v)
			if typeof(v) ~= "table" then return v end
			if v.__type == "Color3" then return Color3.fromRGB(v.r, v.g, v.b)
			elseif v.__type == "EnumItem" then local e = Enum[v.enumType]; return e and e[v.name] or nil
			elseif v.__type == "ColorSequence" then
				local kps = {}
				for _, k in ipairs(v.keypoints) do
					table.insert(kps, ColorSequenceKeypoint.new(k.t, Color3.fromRGB(k.v.r, k.v.g, k.v.b)))
				end
				return ColorSequence.new(kps)
			else
				local out = {}
				for k, val in pairs(v) do out[k] = d(val) end
				return out
			end
		end
		return d(data)
	end
	
	table.insert(module, { Type = "Text", Args = {"Theme"} })
	
	local function loadThemeFromSave(last)
		if not last then task.wait(1) else task.wait(0.2) end
		if YARHMPointSave:get("YARHMGlobal_themeCode") then
			local themeObjectImport = themeDeserialize(https:JSONDecode(fu.from_base64(YARHMPointSave:get("YARHMGlobal_themeCode"))))
			theme:setColorTable(themeObjectImport)
			theme:init(getgenv().YARHM)
			fu.setTheme(themeObjectImport)
			fu.refreshlist()
			fu.refresharea()
			if not last then loadThemeFromSave(true) end
		end
	end
	
	table.insert(module, {
		Type = "Input",
		Args = {"Theme code", "Apply", function(obj, value)
			local themeObjectImport = themeDeserialize(https:JSONDecode(fu.from_base64(value)))
			theme:setColorTable(themeObjectImport)
			theme:init(getgenv().YARHM)
			fu.setTheme(themeObjectImport)
			fu.refreshlist()
			fu.refresharea()
			fu.notification("Successfully applied theme!")
			YARHMPointSave:set("YARHMGlobal_themeCode", value)
		end}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Reload theme", function()
			theme:init(getgenv().YARHM)
			fu.refreshlist()
			fu.refresharea()
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Delete theme from save", function()
			YARHMPointSave:remove("YARHMGlobal_themeCode")
			fu.notification("Theme will not be restored on the next executes.")
		end,}
	})
	
	task.spawn(loadThemeFromSave)
	
	repeat task.wait() until getgenv().Modules
	getgenv().Modules[1] = module
end

local function XEEC_routine() -- StarterGui.YARHM.Murder Mystery 2
    local script = { Parent = getgenv().YARHM }
    local req = require or function() return nil end
    local require = function(obj)
        local routine = routine_module_scripts and routine_module_scripts[obj]
        if routine then
            return routine()
        end
        return req(obj)
    end

    -- © Aetherion 2026

	local module = {}
	module["gameId"] = 0
	
	local fu = require(getgenv().YARHM.FUNCTIONS)
	local espindc = require(script.Parent.ESPIndicator)
	
	local espcontainer = espindc.new({ArrowEdgePadding = 50, ArrowShowDistanceText = false,})
	
	local playerESP = false
	local sheriffAimbot = false
	local coinAutoCollect = false
	local autoShooting = false
	local shootOffset = 2.8
	local offsetToPingMult = 1
	
	local predictionAIEngine = false
	local predictionOngoing = false
	
	local predictionCooldown = false
	
	local gunDropTakeExp = false
	
	local gunDropESP
	
	local trapDetection = false
	
	local autoGetDroppedGun = false
	local simulateKnifeThrow = false
	
	local localplayer = game:GetService("Players").LocalPlayer
	
	local playerData = {}
	
	local phs = game:GetService("PathfindingService")
	local ts = game:GetService("TweenService")
	local rs = game:GetService("RunService")
	
	local claimedCoins = {}
	
	local function findMurderer()
		for _, i in ipairs(game.Players:GetPlayers()) do
			if i.Backpack:FindFirstChild("Knife") then
				return i
			end
		end
		for _, i in ipairs(game.Players:GetPlayers()) do
			if not i.Character then continue end
			if i.Character:FindFirstChild("Knife") then
				return i
			end
		end
		if playerData then
			for player, data in playerData do
				if data.Role == "Murderer" then
					if game.Players:FindFirstChild(player) then
						return game.Players:FindFirstChild(player)
					end
				end
			end
		end
		return nil
	end
	
	local function findSheriff()
		for _, i in ipairs(game.Players:GetPlayers()) do
			if i.Backpack:FindFirstChild("Gun") then
				return i
			end
		end
		for _, i in ipairs(game.Players:GetPlayers()) do
			if not i.Character then continue end
			if i.Character:FindFirstChild("Gun") then
				return i
			end
		end
		if playerData then
			for player, data in playerData do
				if data.Role == "Sheriff" then
					if game.Players:FindFirstChild(player) then
						return game.Players:FindFirstChild(player)
					end
				end
			end
		end
		return nil
	end
	
	local function findSheriffThatsNotMe()
		for _, i in ipairs(game.Players:GetPlayers()) do
			if i == localplayer then continue end
			if i.Backpack:FindFirstChild("Gun") then
				return i
			end
		end
		for _, i in ipairs(game.Players:GetPlayers()) do
			if i == localplayer then continue end
			if not i.Character then continue end
			if i.Character:FindFirstChild("Gun") then
				return i
			end
		end
		if playerData then
			for player, data in playerData do
				if data.Role == "Sheriff" then
					if game.Players:FindFirstChild(player) then
						if game.Players:FindFirstChild(player) == localplayer then continue end
						return game.Players:FindFirstChild(player)
					end
				end
			end
		end
		return nil
	end
	
	local hideMeEsp = false
	function reloadESP()
		if not playerESP then return end
		espcontainer:RemoveGroup("players")
		local listplayers = game.Players:GetChildren()
		for _, player in ipairs(listplayers) do
			if player == localplayer and hideMeEsp then continue end
			if player.Character ~= nil then
				local character = player.Character
				if true then
					task.spawn(function()
						if player == findMurderer() then
							espcontainer:Add(character, {
								AccentColor = Color3.new(1, 0, 0.0156863),
								ArrowShow = true,
								ArrowMinDistance = 999999,
								ArrowSize = UDim2.new(0,40,0,40),
								LabelText = "Murderer",
								ShowLabel = true,
								GroupName = "players"
							})
						elseif player == findSheriff() then
							espcontainer:Add(character, {
								AccentColor = Color3.new(0, 0.6, 1),
								ArrowShow = false,
								ShowLabel = false,
								GroupName = "players"
							})
						else
							espcontainer:Add(character, {
								AccentColor = Color3.new(0, 1, 0.0313725),
								ArrowShow = false,
								ShowLabel = false,
								GroupName = "players"
							})
						end
					end)
				end
			end
		end
	end
	
	if not game.ReplicatedStorage:WaitForChild("Remotes", 5) then
		fu.dialog("Not MM2", "Looks like this game isn't MM2. Do you want to load the module anyway?", {"Load", "No"})
		if fu.waitfordialog() == "No" then
			fu.closedialog()
			fu.notification("MM2 will not be loaded until you rejoin.", Color3.fromRGB(255, 0, 0), "x")
			return
		end	
		fu.closedialog()
	else
		game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged", 5).OnClientEvent:Connect(function(data)
			playerData = data
			if playerESP then
				reloadESP()
			end
		end)
	end
	
	local onTesting = game.GameId == 119460199
	
	local Players = game:GetService("Players")
	local playerToExamineIsSpamJumping = false
	
	local function findNearestPlayer()
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local nearestPlayer = nil
		local shortestDistance = math.huge
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then 
				local localRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
				local otherRootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if localRootPart and otherRootPart then
					local distance = (localRootPart.Position - otherRootPart.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						nearestPlayer = player
					end
				end
			end
		end
		return nearestPlayer
	end
	
	function miniFling(playerToFling)
		local a=game.Players.LocalPlayer;local b=a:GetMouse()local c={playerToFling}local d=game:GetService("Players")local e=d.LocalPlayer;local f=false;local g=function(h)local i=e.Character;local j=i and i:FindFirstChildOfClass("Humanoid")local k=j and j.RootPart;local l=h.Character;local m;local n;local o;local p;local q;if l:FindFirstChildOfClass("Humanoid")then m=l:FindFirstChildOfClass("Humanoid")end;if m and m.RootPart then n=m.RootPart end;if l:FindFirstChild("Head")then o=l.Head end;if l:FindFirstChildOfClass("Accessory")then p=l:FindFirstChildOfClass("Accessory")end;if p and p:FindFirstChild("Handle")then q=p.Handle end;if i and j and k then if k.Velocity.Magnitude<50 then getgenv().OldPos=k.CFrame end;if m and m.Sit and not f then end;if o then if o.Velocity.Magnitude>500 then fu.dialog("Player flung","Player is already flung. Fling again?",{"Fling again","No"})if fu.waitfordialog()=="No"then return fu.closedialog()end;fu.closedialog()end elseif not o and q then if q.Velocity.Magnitude>500 then fu.dialog("Player flung","Player is already flung. Fling again?",{"Fling again","No"})if fu.waitfordialog()=="No"then return fu.closedialog()end;fu.closedialog()end end;if o then workspace.CurrentCamera.CameraSubject=o elseif not o and q then workspace.CurrentCamera.CameraSubject=q elseif m and n then workspace.CurrentCamera.CameraSubject=m end;if not l:FindFirstChildWhichIsA("BasePart")then return end;local r=function(s,t,u)k.CFrame=CFrame.new(s.Position)*t*u;i:SetPrimaryPartCFrame(CFrame.new(s.Position)*t*u)k.Velocity=Vector3.new(9e7,9e7*10,9e7)k.RotVelocity=Vector3.new(9e8,9e8,9e8)end;local v=function(s)local w=2;local x=tick()local y=0;repeat if k and m then if s.Velocity.Magnitude<50 then y=y+100;r(s,CFrame.new(0,1.5,0)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,-1.5,0)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(2.25,1.5,-2.25)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(-2.25,-1.5,2.25)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,1.5,0)+m.MoveDirection,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,-1.5,0)+m.MoveDirection,CFrame.Angles(math.rad(y),0,0))task.wait()else r(s,CFrame.new(0,1.5,m.WalkSpeed),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,-m.WalkSpeed),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,1.5,m.WalkSpeed),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,1.5,n.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,-n.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,1.5,n.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))task.wait()end else break end until s.Velocity.Magnitude>500 or s.Parent~=h.Character or h.Parent~=d or h.Character~=l or m.Sit or j.Health<=0 or tick()>x+w end;workspace.FallenPartsDestroyHeight=0/0;local z=Instance.new("BodyVelocity")z.Name="EpixVel"z.Parent=k;z.Velocity=Vector3.new(9e8,9e8,9e8)z.MaxForce=Vector3.new(1/0,1/0,1/0)j:SetStateEnabled(Enum.HumanoidStateType.Seated,false)if n and o then if(n.CFrame.p-o.CFrame.p).Magnitude>5 then v(o)else v(n)end elseif n and not o then v(n)elseif not n and o then v(o)elseif not n and not o and p and q then v(q)else fu.notification("Can't find a proper part of target player to fling.")end;z:Destroy()j:SetStateEnabled(Enum.HumanoidStateType.Seated,true);repeat k.CFrame=getgenv().OldPos*CFrame.new(0,.5,0)i:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0))j:ChangeState("GettingUp")table.foreach(i:GetChildren(),function(A,B)if B:IsA("BasePart")then B.Velocity,B.RotVelocity=Vector3.new(),Vector3.new()end end)task.wait()until(k.Position-getgenv().OldPos.p).Magnitude<25;workspace.FallenPartsDestroyHeight=getgenv().FPDH else fu.notification("No valid character of said target player. May have died.")end end;g(c[1])
	end
	
	function getMap()
		for _, o in ipairs(workspace:GetChildren()) do
			if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
				return o
			end
		end
		return nil
	end
	
	module["Name"] = "Murder Mystery 2"
	
	workspace.ChildAdded:Connect(function(ch)
		if ch == getMap() and playerESP then
			fu.notification("Map has loaded, waiting for roles...")
			repeat
				task.wait(1)
			until findMurderer()
			fu.notification("Player ESP reloaded.")
		end
	end)
	
	workspace.ChildRemoved:Connect(function(ch)
		if ch == getMap() and playerESP then
			fu.notification("Game ended, removing Player ESPs.")
			playerData = {}
			espcontainer:ClearAllGroups()
		end
	end)
	
	workspace.DescendantAdded:Connect(function(ch)
		if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
			ch.Transparency = 0
			espcontainer:Add(ch, {
				AccentColor = Color3.new(1, 0, 0.0156863),
				ArrowShow = false,
				ShowLabel = true,
				LabelText = "Trap",
				GroupName = "trap"
			})
			fu.notification("Murderer has placed a trap!")
		end
		if gunDropESP and ch.Name == "GunDrop" then
			espcontainer:Add(ch, {
				AccentColor = Color3.new(0.952941, 1, 0.0745098),
				ArrowShow = true,
				ArrowMinDistance = 999999,
				ArrowSize = UDim2.new(0,40,0,40),
				LabelText = "Dropped gun!",
				ShowLabel = true,
				GroupName = "gun"
			})
			fu.notification("Gun has been dropped! Find a yellow highlight.")
			if autoGetDroppedGun then
				fu.notification("Auto get dropped gun - Cooling down...")
				task.wait(1)
				if gunDropTakeExp then
					local character = localplayer.Character or localplayer.CharacterAdded:Wait()
					local rootPart = character:FindFirstChild("HumanoidRootPart")
					local gunDrop = getMap():FindFirstChild("GunDrop")
					if gunDrop and rootPart then
						local touchPart = gunDrop:FindFirstChild("Handle") or gunDrop
						gunDrop:PivotTo(rootPart.CFrame)
						firetouchinterest(rootPart, touchPart, 0)
						task.wait()
						firetouchinterest(rootPart, touchPart, 1)
					end
					return
				end
				if not getMap():FindFirstChild("GunDrop") then fu.notification("No dropped gun to be teleported to.") return end
				local previousPosition = localplayer.Character:GetPivot()
				localplayer.Character:MoveTo(getMap():FindFirstChild("GunDrop").Position)
				localplayer.Backpack.ChildAdded:Wait()
				localplayer.Character:PivotTo(previousPosition)
			end
		end
	end)
	
	workspace.DescendantRemoving:Connect(function(ch)
		if gunDropESP and ch.Name == "GunDrop" then
			espcontainer:RemoveGroup("gun")
			fu.notification("Someone has took the dropped gun.")
			task.wait(1)
			fu.notification("The hero is " .. findSheriff().DisplayName .. ".")
			reloadESP()
		end
	end)
	
	function getClosestModelToPlayer(player, models)
		local closestModel = nil
		local closestDistance = math.huge 
		local playerPosition = player.Character.HumanoidRootPart.Position
		for _, model in ipairs(models) do
			local modelPosition = model:GetPivot().Position
			local distance = (modelPosition - playerPosition).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestModel = model
			end
		end
		local returningResult = {closestModel, closestDistance}
		setmetatable(returningResult, {
			__tostring = function(t) return closestModel end,
		})
		return returningResult
	end
	
	task.spawn(
		function()
			while task.wait(0.1) do
				if not coinAutoCollect then continue end
				if getMap() then
					if getMap():FindFirstChild("CoinContainer") and #getMap():FindFirstChild("CoinContainer"):GetChildren() > 1 then
						local closestCoin = getClosestModelToPlayer(localplayer, getMap():FindFirstChild("CoinContainer"):GetChildren())
						if closestCoin then
							if not localplayer.Character:FindFirstChild("HumanoidRootPart") then continue end
							local distance = (localplayer.Character:FindFirstChild("HumanoidRootPart").Position - closestCoin:GetPivot().Position).Magnitude
							local toclosestcoin = ts:Create(localplayer.Character:FindFirstChild("HumanoidRootPart"), TweenInfo.new(distance*0.05, Enum.EasingStyle.Linear), {
								CFrame = closestCoin:GetPivot()
							})
							toclosestcoin:Play()
							toclosestcoin.Completed:Wait()
							task.wait(0.1)
							closestCoin:Destroy()
							claimedCoins[closestCoin] = true
						end
					end
				end
			end
		end
	)
	
	local function getPredictedPosition(player, shootOffset)
		local usingBasicPred = not predictionAIEngine
		if predictionOngoing then
			fu.notification("Cancelling AI prediction, using basic prediction.")
			usingBasicPred = true
		end
		local ogplayer = player
		pcall(function()
			player = player.Character
			if not player.Character then fu.notification("No murderer to predict position.") return end
		end)
		local playerHRP = player:FindFirstChild("UpperTorso")
		local playerHum = player:FindFirstChild("Humanoid")
		if not playerHRP or not playerHum then
			return Vector3.new(0,0,0), "Could not find the player's HumanoidRootPart."
		end
		local playerPosition = playerHRP.Position
		if predictionAIEngine and not usingBasicPred and not predictionCooldown and getgenv().YARHMNetwork_predictPos then
			if (playerPosition - localplayer.Character:FindFirstChild("UpperTorso").Position).Magnitude > 20 then
				fu.notification("Calculating trajectory...")
				predictionCooldown = true
				predictionOngoing = true
				local predictedPosition = getgenv().YARHMNetwork_predictPos(ogplayer)
				predictionOngoing = false
				task.spawn(function()
					task.wait(5)
					predictionCooldown = false
				end)
				return predictedPosition
			else
				fu.notification("Murderer is too close for trajectory prediction. Reverting to basic prediction.")
			end
		elseif predictionAIEngine and not getgenv().YARHMNetwork.predictPos then
			fu.notification("YARHM AI Engine is not available. Reverting to basic prediction.")	
		end
		local velocity = Vector3.new()
		velocity = playerHRP.AssemblyLinearVelocity
		local playerMoveDirection = playerHum.MoveDirection
		local playerLookVec = playerHRP.CFrame.LookVector
		local yVelFactor = velocity.Y > 0 and -1 or 0.5
		local predictedPosition
		predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) +playerMoveDirection * shootOffset
		predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
		return predictedPosition
	end
	
	task.spawn(function()
		while task.wait(1) do
			if findSheriff() == localplayer and autoShooting then
				fu.notification("Auto-shooting started.")
				repeat
					task.wait(0.1)
					local murderer = findMurderer()
					if not murderer then fu.notification("No murderer.") continue end
					local murdererPosition = murderer.Character.HumanoidRootPart.Position
					local characterRootPart = localplayer.Character.HumanoidRootPart
					local rayDirection = murdererPosition - characterRootPart.Position
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = {localplayer.Character}
					local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
					if not hit or hit.Instance.Parent == murderer.Character then
						fu.notification("Auto-shooting!")
						if not localplayer.Character:FindFirstChild("Gun") then
							local hum = localplayer.Character:FindFirstChild("Humanoid")
							if localplayer.Backpack:FindFirstChild("Gun") then
								localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
							else
								fu.notification("You don't have the gun..?")
								return
							end
						end
						local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
						if not murdererHRP then
							fu.notification("Could not find the murderer's HumanoidRootPart.")
							return
						end
						local predictedPosition = getPredictedPosition(murderer, shootOffset)
						local args = {
							[1] = 1,
							[2] = predictedPosition,
							[3] = "AH2"
						}
						localplayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
					end
				until findSheriff() ~= localplayer or not autoShooting
			end
		end
	end)
	
	table.insert(module, { Type = "Text", Args = {"ESPs"} })
	
	table.insert(module, {
		Type = "ButtonGrid",
		Toggleable = true,
		Args = {2, {
			Players = function()
				if playerESP then
					playerESP = false
					espcontainer:RemoveGroup("players")
				else
					playerESP = true
					if not findMurderer() or not findSheriff() then
						fu.notification("No roles yet. Waiting for roles...")
						repeat
							task.wait(1)
						until findSheriff() or findMurderer()
					end
					reloadESP()
				end
			end,
			Dropped_Gun = function()
				if gunDropESP then
					gunDropESP = false
					espcontainer:RemoveGroup("gun")
				else
					gunDropESP = true
					if not getMap() then return end
					if getMap():FindFirstChild("GunDrop") then
						espcontainer:Add(getMap():FindFirstChild("GunDrop"), {
							AccentColor = Color3.new(0.952941, 1, 0.0745098),
							ArrowShow = true,
							ArrowMinDistance = 999999,
							ArrowSize = UDim2.new(0,40,0,40),
							LabelText = "Dropped gun!",
							ShowLabel = true,
							GroupName = "gun"
						})
						fu.notification("Gun has been dropped! Find a yellow highlight.")
					end
				end
			end,
			Traps = function()
				if trapDetection then
					trapDetection = false
					espcontainer:RemoveGroup("trap")
				else
					trapDetection = true
					for _, v in ipairs(workspace:GetDescendants()) do
						if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
							v.Transparency = 0
							espcontainer:Add(v, {
								AccentColor = Color3.new(1, 0, 0),
								ArrowShow = false,
								ShowLabel = true,
								LabelText = "Trap",
								GroupName = "trap"
							})
						end
					end
				end
			end,
		}}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Hide my own ESP", function(Self, state)
			hideMeEsp = state
			reloadESP()
		end,}
	})
	table.insert(module, { Type = "Text", Args = {"Tools"} })
	
	local instakillshoot = false
	table.insert(module, {
		Type = "Button",
		Args = {"Shoot murderer", function(Self)
			if findSheriff() ~= localplayer then 
				fu.notification("You're not sheriff/hero.") 
				return 
			end
			local murderer = findMurderer() or findSheriffThatsNotMe()
			if not murderer then
				fu.notification("No murderer (or sheriff) to shoot.")
				return
			end
			if not localplayer.Character:FindFirstChild("Gun") then
				local hum = localplayer.Character:FindFirstChild("Humanoid")
				if localplayer.Backpack:FindFirstChild("Gun") then
					hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
				else
					fu.notification("You don't have the gun..?")
					return
				end
			end
			local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
			if not murdererHRP then
				fu.notification("Could not find the murderer's HumanoidRootPart.")
				return
			end
			local predictedPosition = getPredictedPosition(murderer, shootOffset)
			local args
			if instakillshoot then
				args = {
					CFrame.new(murdererHRP.Position + Vector3.new(0,1,0)),
					CFrame.new(murdererHRP.Position)
				}
			else
				args = {
					CFrame.new(localplayer.Character.RightHand.Position),
					CFrame.new(predictedPosition)
				}
			end
			localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
		end,}
	})
	
	local spawnAtPlayer = false
	local loopThrow = false
	local function knifeThrow(silent)
		if findMurderer() ~= localplayer then 
			if silent then return end
			fu.notification("You're not murderer.") 
			return 
		end
		if not localplayer.Character:FindFirstChild("Knife") then
			local hum = localplayer.Character:FindFirstChild("Humanoid")
			if localplayer.Backpack:FindFirstChild("Knife") then
				hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
			else
				if silent then return end
				fu.notification("You don't have the knife..?")
				return
			end
		end
		local NearestPlayer = findNearestPlayer()
		if not NearestPlayer or not NearestPlayer.Character then
			if silent then return end
			fu.notification("Can't find a player!?")
			return
		end
		local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not nearestHRP then
			if silent then return end
			fu.notification("Can't find the player's pivot.")
		end
		local argsThrowRemote = {
			CFrame.new(localplayer.Character.RightHand.Position),
			CFrame.new(getPredictedPosition(NearestPlayer, shootOffset + 1)),
		}
		if spawnAtPlayer then
			argsThrowRemote[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5))
		end
		localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(argsThrowRemote))
	end
	
	task.spawn(function()
		while task.wait(1.5) do
			if loopThrow then
				knifeThrow(true)
			end
		end
	end)
	
	table.insert(module, {
		Type = "Button",
		Args = {"Knife throw to closest", function()
			knifeThrow()
		end}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Auto knife throw", function(Self, tog)
			loopThrow = tog
		end}
	})
	
	table.insert(module, {
		Type = "Input",
		Args = {"Shoot position offset", "Set", function(Self, text)
			if not tonumber(text) then fu.notification("Not a valid number.") return end
			if tonumber(text) > 5 then fu.notification("An offset with a multiplier of 5 might not at all shoot the murderer!") end
			if tonumber(text) < 0 then fu.notification("An offset with a negative multiplier will make a shot BEHIND the murderer's walk direction.") end
			shootOffset = tonumber(text)
			fu.notification("Offset has been set.")
		end,}
	})
	
	table.insert(module, {
		Type = "Input",
		Args = {"Offset-to-ping multiplier", "Set", function(Self, text)
			if not tonumber(text) then fu.notification("Not a valid number.") return end
			offsetToPingMult = tonumber(text)
			fu.notification("Offset has been set.")
		end,}
	})
	
	table.insert(module, {
		Type = "Text",
		Args = {"Shoot offset re-aims the gun/knife shoot/throw to the character's predicted position. Recommended is 2.8"}
	})
	
	local function secondsToMinutes(seconds)
		if seconds == -1 then return "" end
		local minutes = math.floor(seconds / 60)
		local remainingSeconds = seconds % 60
		return string.format("%dm %ds", minutes, remainingSeconds)
	end
	local timertask = nil
	local timertext = nil
	table.insert(module, {
		Type = "Toggle",
		Args = {"Round timer", function(Self, state)
			if state then
				timertext = Instance.new("TextLabel")
				timertext.Parent = script.Parent
				timertext.BackgroundTransparency = 1
				timertext.TextColor3 = Color3.fromRGB(255, 255, 255)
				timertext.TextScaled = true
				timertext.AnchorPoint = Vector2.new(0.5, 0.5)
				timertext.Position = UDim2.fromScale(0.5, 0.15)
				timertext.Size = UDim2.fromOffset(200, 35)
				timertext.Font = Enum.Font.Montserrat
				timertask = task.spawn(function()
					while task.wait(0.5) do
						local timeLeft = game.Workspace:FindFirstChild("RoundTimerPart"):GetAttribute("Time")
						timertext.Text = secondsToMinutes(timeLeft)
					end
				end)
			else
				if timertext then timertext:Destroy() end
				task.cancel(timertask)
			end
		end,}
	})
	
	table.insert(module, {Type="Text", Args={""}})
	table.insert(module, { Type = "Text", Args = {"<font color='#FF0000'>Detectables</font>"} })
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Instakill murderer as sheriff", function(Self, tog)
			instakillshoot = tog
		end}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Spawn knife throw near player", function(Self, tog)
			spawnAtPlayer = tog
		end}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Send Sheriff and Murderer names into chat", function(Self)
			local textchannels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
			for _, textchannel in ipairs(textchannels) do
				if textchannel.Name == "RBXSystem" then continue end
				local murd = findMurderer()
				local sher = findSheriff()
				local murdName = "-"
				local sherName = "-"
				if murd then murdName = murd.Name end
				if sher then sherName = sher.Name end
				local message = string.format([[Murderer: %s |
		Sheriff: %s |
		<<YARHM>>]], murdName, sherName)
				textchannel:SendAsync(message)
			end
		end,}
	})
	
	table.insert(module, {
		Type = "ButtonGrid",
		Args = {2, {
			Teleport_to_lobby = function(Self)
				local lobby = workspace:FindFirstChild("Lobby") 
				if lobby then
					localplayer.Character:MoveTo(lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation").Position)
				end
			end,
			Teleport_to_map = function(Self)
				local spawnsFolder = getMap():FindFirstChild("Spawns")
				if spawnsFolder then
					local spawns = spawnsFolder:GetChildren()
					local randomSpawn = spawns[math.random(1, #spawns)]
					localplayer.Character:MoveTo(randomSpawn.Position)
				else
					fu.notification("No map to teleport to.")
				end
			end,
		}}
	}) 
	
	table.insert(module, {
		Type = "ButtonGrid",
		Args = {2, {
			Fling_Sheriff = function()
				if not findSheriff() then
					fu.notification("No sheriff/hero to fling.")
					return
				end
				miniFling(findSheriff())
			end,
			Fling_Murderer = function()
				if not findMurderer() then
					fu.notification("No murderer to fling.")
					return
				end
				miniFling(findMurderer())
			end,
		}}
	})
	
	table.insert(module, {
		Type = "ButtonGrid",
		Args = {2, {
			Copy_murderer_username = function()
				if not findMurderer() then
					fu.notification("No murderer to copy.")
					return
				end
				if setclipboard then setclipboard(findMurderer().Name) end
				fu.notification("Copied to clipboard.")
			end,
			Copy_sheriff_username = function()
				if not findSheriff() then
					fu.notification("No sheriff/hero to copy.")
					return
				end
				if setclipboard then setclipboard(findSheriff().Name) end
				fu.notification("Copied to clipboard.")
			end,
		}}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Teleport to dropped gun", function(Self)
			if gunDropTakeExp then
				local character = localplayer.Character or localplayer.CharacterAdded:Wait()
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				local gunDrop = getMap():FindFirstChild("GunDrop")
				if gunDrop and rootPart then
					local touchPart = gunDrop:FindFirstChild("Handle") or gunDrop
					gunDrop:PivotTo(rootPart.CFrame)
					firetouchinterest(rootPart, touchPart, 0)
					task.wait()
					firetouchinterest(rootPart, touchPart, 1)
				end
				return
			end
			if not getMap():FindFirstChild("GunDrop") then fu.notification("No dropped gun to be teleported to.") return end
			local previousPosition = localplayer.Character:GetPivot()
			localplayer.Character:PivotTo(getMap():FindFirstChild("GunDrop"):GetPivot())
			localplayer.Backpack.ChildAdded:Wait()
			localplayer.Character:PivotTo(previousPosition)
		end,}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Automatically get gun on drop", function(Self, state)
			autoGetDroppedGun = state
		end,}
	})
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Experimental dropped gun take", function(Self, state)
			gunDropTakeExp = state
		end,}
	})
	
	local ignoreknifethrow = false
	game.Workspace.ChildAdded:Connect(function(chi)
		if chi.Name == "ThrowingKnife" and ignoreknifethrow then
			chi:Destroy()
		end
	end)
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Ignore knife throws (doesn't work)", function(Self, state)
			ignoreknifethrow = state
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"God mode (Very, VERY UNSTABLE)", function(Self)
			local Cam = workspace.CurrentCamera
			local Pos, Char = Cam.CFrame, localplayer.Character
			local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
			local nHuman = Human.Clone(Human)
			nHuman.Parent, localplayer.Character = Char, nil
			nHuman.SetStateEnabled(nHuman, 15, false)
			nHuman.SetStateEnabled(nHuman, 1, false)
			nHuman.SetStateEnabled(nHuman, 0, false)
			nHuman.BreakJointsOnDeath, Human = true, Human.Destroy(Human)
			localplayer.Character, Cam.CameraSubject, Cam.CFrame = Char, nHuman, wait() and Pos
			nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			local Script = Char.FindFirstChild(Char, "Animate")
			if Script then
				Script.Disabled = true
				wait()
				Script.Disabled = false
			end
			nHuman.Health = nHuman.MaxHealth
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Kill closest player as murderer", function()
			if findMurderer() ~= localplayer then fu.notification("You're not murderer.") return end
			if not localplayer.Character:FindFirstChild("Knife") then
				local hum = localplayer.Character:FindFirstChild("Humanoid")
				if localplayer.Backpack:FindFirstChild("Knife") then
					localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
				else
					fu.notification("You don't have the knife..?")
					return
				end
			end
			local NearestPlayer = findNearestPlayer()
			if not NearestPlayer or not NearestPlayer.Character then
				fu.notification("Can't find a player!?")
				return
			end
			local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not nearestHRP then
				fu.notification("Can't find the player's pivot.")
			end
			if not localplayer.Character:FindFirstChild("HumanoidRootPart") then fu.notification("You're not a valid character.") return end
			if not simulateKnifeThrow then
				nearestHRP.Anchored = true
				nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
				task.wait(0.1)
				local args = { [1] = "Slash" }
				localplayer.Character.Knife.Stab:FireServer(unpack(args))
				return
			else
				local lpknife = localplayer.Character:FindFirstChild("Knife")
				if not lpknife then return end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {localplayer.Character}
				local rayResult = workspace:Raycast(lpknife:GetPivot().Position, (nearestHRP.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Unit * 350, raycastParams)
				local toThrow = nearestHRP.Position
				local args = { [1] = lpknife:GetPivot(), [2] = toThrow }
				localplayer.Character.Knife.Throw:FireServer(unpack(args))
				return
			end
		end,}
	})
	
	local killAuraCon = nil
	
	table.insert(module, {
		Type = "Toggle",
		Args = {"Murderer kill aura", function(Self, state)
			if state then
				if killAuraCon then killAuraCon:Disconnect() end
			else
				killAuraCon = game:GetService("RunService").Heartbeat:Connect(function()
					for _, player in ipairs(game.Players:GetPlayers()) do
						if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
							local hrp = player.Character:FindFirstChild("HumanoidRootPart")
							if (hrp.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 7 then
								hrp.Anchored = true
								hrp.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
								task.wait(0.1)
								local args = { [1] = "Slash" }
								localplayer.Character.Knife.Stab:FireServer(unpack(args))
								return	
							end
						end
					end
				end)
			end
		end,}
	})
	
	table.insert(module, {
		Type = "Button",
		Args = {"Kill EVERYONE as murderer", function()
			if findMurderer() ~= localplayer then fu.notification("You're not murderer.") return end
			if not localplayer.Character:FindFirstChild("Knife") then
				local hum = localplayer.Character:FindFirstChild("Humanoid")
				if localplayer.Backpack:FindFirstChild("Knife") then
					localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
				else
					fu.notification("You don't have the knife..?")
					return
				end
			end
			for _, player in ipairs(game.Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
					player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
					player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1 
				end	
			end
			local args = { [1] = "Slash" }
			localplayer.Character.Knife.Stab:FireServer(unpack(args))
		end,}
	})
	
	table.insert(module, { Type = "Text", Args = {"Fun"} })
	
	table.insert(module, {
		Type = "Button",
		Args = {"Hold everyone hostage", function()
			if findMurderer() ~= localplayer then fu.notification("You're not murderer. This'll only be useful if you're the murderer.") return end
			for _, player in ipairs(game.Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
					player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
					player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
				end	
			end
			fu.notification("Placed every single player in a single point. Kill everyone at once once you decide to.")
		end,}
	})
	
	repeat task.wait() until getgenv().Modules
	getgenv().Modules[3] = module
	fu.refreshlist()
end

local function UPQDPIR_routine() -- StarterGui.YARHM.AdLoader
    local script = { Parent = getgenv().YARHM }
    local req = require or function() return nil end
    local require = function(obj)
        local routine = routine_module_scripts and routine_module_scripts[obj]
        if routine then
            return routine()
        end
        return req(obj)
    end

    -- © Aetherion 2026

	task.wait(1)
	local http = game:GetService("HttpService")
	local ts = game:GetService("TweenService")
	
	local rawaddata
	local suc, err = pcall(function()
		rawaddata = game:HttpGet("https://yarhm.com/adCampaign/get")
	end)
	if not suc then
		warn("YARHM AD ERROR: " .. err)
		script:Destroy()
		return
	end
	
	getgenv().YARHMADMETADATA = http:JSONDecode(rawaddata)
	local addata = getgenv().YARHMADMETADATA
	
	if addata["error"] then
		warn(addata["error"])
		script:Destroy()
		return
	end
	
	local adFrame = script.Parent.Menu.Ad
	
	if addata["image"] then
		writefile("YARHM/adcache/sidescreen.png", game:HttpGet("https://yarhm.com" .. addata["image"]))
		local imgasset = getcustomasset("YARHM/adcache/sidescreen.png")
		adFrame.Image.Image = imgasset
	end
	
	adFrame.Metadata.TextLabel.Text = addata["title"]
	adFrame.Metadata.CTA.Text = addata["ctaButton"]
	
	local clickedBefore = false
	
	adFrame.Metadata.CTA.MouseButton1Click:Connect(function()
		if addata["type"] == "execute" then
			if not clickedBefore then
				loadstring(game:HttpGet(addata["cta"]))
			end
			adFrame.Metadata.CTA.Text = "Script ran!"
		else
			setclipboard(addata["cta"])
			adFrame.Metadata.CTA.Text = "Link copied to clipboard!"
		end
		if not clickedBefore then
			game:HttpPost("https://yarhm.com/adCampaign/" .. addata["id"] .. "/click", "{}", "application/json")
		end
		clickedBefore = true	
	end)
	
	task.spawn(function()
		task.wait(addata["duration"])
		game:HttpPost("https://yarhm.com/adCampaign/" .. addata["id"] .. "/impression", "{}", "application/json")
	end)
	
	ts:Create(adFrame, TweenInfo.new(0.5), {
		GroupTransparency = 0	
	}):Play()
	adFrame.Metadata.TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	adFrame.Metadata.CTA.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	
	adFrame.Interactable = true
end

-- ==========================================
-- EXECUÇÃO DOS MÓDULOS
-- ==========================================
coroutine.wrap(JWXW_routine)()
coroutine.wrap(XEEC_routine)()
coroutine.wrap(UPQDPIR_routine)()

print("✅ [YARHM] Módulos do jogo (MM2, Universal) carregados com sucesso!")
