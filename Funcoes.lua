-- ==========================================
-- REPOSITÓRIO B: MÓDULOS DO JOGO (Funcoes.lua)
-- Versão sem 'require' - Apenas Módulo Universal
-- ==========================================

repeat task.wait() until getgenv().YARHM and getgenv().YARHM_FUNCTIONS

local script = { Parent = getgenv().YARHM }
local fu = getgenv().YARHM_FUNCTIONS

local function JWXW_routine() -- StarterGui.YARHM.Universal
    local script = { Parent = getgenv().YARHM }

    -- Tabelas vazias para substituir os módulos que exigiam 'require'
    local theme = { setColorTable = function() end, init = function() end }
    local flyutility = { Start = function() end, Stop = function() end, SetMaxSpeed = function() end }
    local PointSave = { new = function() return {get=function() return nil end, set=function() end, remove=function() end} end }

    local module = {}
    module["gameId"] = 0
    if (module["gameId"] ~= game.GameId) and module["gameId"] ~= 0 then
        script.Enabled = true
    end
    
    local ts = game:GetService("TweenService")
    local uis = game:GetService("UserInputService")
    local rs = game:GetService("RunService")
    local Players = game:GetService("Players")
    
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
        Args = {"OP Fly (Básico)", function(Self, state)
            if state then fu.notification("Fly module is not available in this version.") end
        end}
    })
    
    table.insert(module, { Type = "Text", Args = {""} })
    table.insert(module, { Type = "Text", Args = {"Jumping"} })
    
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
        Args = {"Walkspeed increment", "Set", function(Self, input)
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
    
    table.insert(module, { Type = "Text", Args = {""} })
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
    
    table.insert(module, {
        Type = "Button",
        Args = {"Open developer console (debugging)", function(Self)
            game.StarterGui:SetCore("DevConsoleVisible", true)
        end}
    )
    
    table.insert(module, { Type = "Text", Args = {""} })
    table.insert(module, { Type = "Text", Args = {"Theme"} })
    
    table.insert(module, {
        Type = "Input",
        Args = {"Theme code", "Apply", function(obj, value)
            fu.notification("Theme module is disabled in this version.")
        end}
    })
    
    table.insert(module, {
        Type = "Button",
        Args = {"Reload theme", function()
            fu.notification("Theme module is disabled in this version.")
        end,}
    })
    
    repeat task.wait() until getgenv().Modules
    getgenv().Modules[1] = module
end

-- Executa apenas o módulo Universal
coroutine.wrap(JWXW_routine)()

print("✅ [YARHM] Módulo Universal carregado com sucesso! (Sem erros de require)")
