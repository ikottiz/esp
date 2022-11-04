local runService = game:GetService('RunService')
local httpService = game:GetService('HttpService')
local userInputService = game:GetService('UserInputService')
local players = game:GetService('Players')
local player = players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local data = {
    ESP = false,
    Boxes = false,
    Tracers = false,
    Self = false,
    UI = true
}
do --script part
    function draw(type, properties)
        local drawing = Drawing.new(type)
        for i, v in next, properties do
            drawing[i] = v
        end
        return drawing
    end
    function round(vector)
        return Vector2.new(vector.x - vector.x % 1, vector.y - vector.y % 1)
    end
    --ui
    local function onInputBegan(input, _gameProcessed)
        if input.KeyCode == Enum.KeyCode.F1 then
            data.ESP = not data.ESP
        elseif input.KeyCode == Enum.KeyCode.F2 then
            data.Boxes = not data.Boxes
        elseif input.KeyCode == Enum.KeyCode.F3 then
            data.Tracers = not data.Tracers
        elseif input.KeyCode == Enum.KeyCode.F4 then
            data.Self = not data.Self
        elseif input.KeyCode == Enum.KeyCode.F5 then
            data.UI = not data.UI
        end
    end
    local uiObjects = {
        outline = draw("Square",{Size = Vector2.new(200,120),Position = Vector2.new(10,300),Filled = false,Color = Color3.fromRGB(176,50,176),ZIndex = 1,Visible = true,Thickness = 1}),
        frame = draw("Square",{Size = Vector2.new(198,118),Position = Vector2.new(11,301),Filled = true,Color = Color3.fromRGB(26,26,26),ZIndex = 2,Visible = true,Thickness = 0}),
        status = draw("Text",{Size = 23,Font = 1,Position = Vector2.new(18,300),Color = Color3.fromRGB(244,244,244),Center = false,Outline = true,ZIndex = 3,Visible = true}),
    }
    local name2 = httpService:GenerateGUID()
    userInputService.InputBegan:Connect(onInputBegan)
    runService:BindToRenderStep(name2, Enum.RenderPriority.Camera.Value, function()
        for i,v in next, uiObjects do
            if not data.UI then
                v.Visible = false
            else
                v.Visible = true
            end
        end
        uiObjects.status.Text = string.format('[F1]ESP: %s \n[F2]Boxes: %s \n[F3]Tracers: %s \n[F4]Self:%s \n[F5]UI: %s ',tostring(data.ESP),tostring(data.Boxes),tostring(data.Tracers),tostring(data.Self),tostring(data.UI))
    end)
    --esp
    local function esp(targetPlayer)
        local espObjects = {
            box = draw("Square", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, ZIndex = 1}),
            tracer = draw("Line", {Color = Color3.fromRGB(255, 255, 255), ZIndex = 1, Transparency = 0.5}),
            text = draw("Text", {Color = Color3.fromRGB(255, 255, 255), Center = true, Outline = true, ZIndex = 1, Size = 20}),
        }
        local name1 = httpService:GenerateGUID()
        runService:BindToRenderStep(name1, Enum.RenderPriority.Camera.Value, function()
            if data.ESP and (data.Self or targetPlayer ~= player) then
                local character = targetPlayer.Character
                if character then 
                    local humanoid, humanoidRootPart, head = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild('Head')
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local healthPercent = (humanoid.Health / humanoid.MaxHealth)
                        local screenPosition, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)

                        local orientation = humanoidRootPart.CFrame
                        local height = (camera.CFrame - camera.CFrame.Position) * Vector3.new(0, 2.75, 0)
                        local screenHeight = math.abs(camera:WorldToScreenPoint(orientation.Position + height).Y - camera:WorldToScreenPoint(orientation.Position - height).Y)
                        local boxSize = round(Vector2.new(screenHeight / 2, screenHeight))

                        espObjects.box.Size = boxSize
                        espObjects.box.Position = round(Vector2.new(screenPosition.X, screenPosition.Y) - (boxSize / 2))
                        espObjects.text.Font = 1
                        espObjects.text.Visible = onScreen
                        espObjects.text.Position = Vector2.new(((espObjects.box.Size.X / 2) + espObjects.box.Position.X), ((screenPosition.Y - espObjects.box.Size.Y / 2) - 18))
                        local distance = math.floor(player:DistanceFromCharacter(humanoidRootPart.Position))
                        espObjects.text.Text = targetPlayer.Name..("(%dm)"):format(distance)

                        if data.Tracers then
                            espObjects.tracer.From = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)
                            espObjects.tracer.To = Vector2.new(((espObjects.box.Size.X / 2) + espObjects.box.Position.X), (espObjects.box.Size.Y + espObjects.box.Position.Y))
                            espObjects.tracer.Visible = onScreen
                        else
                            espObjects.tracer.Visible = false
                        end

                        espObjects.box.Visible = onScreen and data.Boxes
                    else
                        runService:UnbindFromRenderStep(name1)

                        for index, object in next, espObjects do
                            object.Visible = false
                            object:Remove()
                            espObjects[index] = nil
                        end
                    end
                else 
                    runService:UnbindFromRenderStep(name1)
                    
                    for index, object in next, espObjects do
                        object.Visible = false
                        object:Remove()
                        espObjects[index] = nil
                    end
                end
            else 
                for index, object in next, espObjects do
                    object.Visible = false
                end
            end
        end)
    end
    for i,v in pairs(players:GetChildren()) do
        local targetPlayer = v
        local targetCharacter = v.Character

        if targetCharacter then 
            if targetCharacter:FindFirstChild("Humanoid") and targetCharacter:FindFirstChild("HumanoidRootPart") then 
                esp(v)
            end
        end

        targetPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("Humanoid")
            character:WaitForChild("HumanoidRootPart")
            esp(v)
        end)
    end
    players.ChildAdded:Connect(function(targetPlayer)
        targetPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("Humanoid")
            character:WaitForChild("HumanoidRootPart")
            esp(targetPlayer)
        end)
    end)
end