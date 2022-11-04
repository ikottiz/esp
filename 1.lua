getgenv().data = {
    ESP = true,
    Boxes = false,
    Tracers = false,
    Self = false,
    UI = true
}
local runService = game:GetService('RunService')
local httpService = game:GetService('HttpService')
local userInputService = game:GetService('UserInputService')
local players = game:GetService('Players')
local player = players.LocalPlayer
local camera = game.Workspace.CurrentCamera
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
    local function onInputBegan(input)
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
    getgenv().uiObjects = {
        outline = draw("Square",{Size = Vector2.new(140,68),Position = Vector2.new(10,300),Filled = false,Color = Color3.fromRGB(176,50,176),ZIndex = 1,Visible = true,Thickness = 1}),
        frame = draw("Square",{Size = Vector2.new(138,66),Position = Vector2.new(11,301),Filled = true,Color = Color3.fromRGB(26,26,26),ZIndex = 2,Visible = true,Thickness = 0}),
        names = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(12,300),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
        status1 = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(75,300),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
        status2 = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(75,313),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
        status3 = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(75,325),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
        status4 = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(75,338),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
        status5 = draw("Text",{Size = 13,Font = 2,Position = Vector2.new(75,352),Color = Color3.fromRGB(233,233,233),ZIndex = 3,Visible = true}),
    }
    userInputService.InputBegan:Connect(onInputBegan)
    runService.RenderStepped:Connect(function()
        for _,v in next, uiObjects do
            if not data.UI then
                v.Visible = false
            else
                v.Visible = true
            end
        end
        uiObjects.names.Text = 'ESP:\nTracers:\nBoxes:\nSelf:\nUI:'
        --
        uiObjects.status1.Text = tostring(data.ESP)
        if data.ESP == true then
            uiObjects.status1.Color = Color3.fromRGB(0,200,0)
            uiObjects.outline.Color = Color3.fromRGB(0,200,0)
        elseif data.ESP == false then
            uiObjects.status1.Color = Color3.fromRGB(200,0,0)
            uiObjects.outline.Color = Color3.fromRGB(200,0,0)
        end
        --
        uiObjects.status2.Text = tostring(data.Boxes)
        if data.Boxes == true then
            uiObjects.status2.Color = Color3.fromRGB(0,200,0)
        elseif data.Boxes == false then
            uiObjects.status2.Color = Color3.fromRGB(200,0,0)
        end
        --
        uiObjects.status3.Text = tostring(data.Tracers)
        if data.Tracers == true then
            uiObjects.status3.Color = Color3.fromRGB(0,200,0)
        elseif data.Tracers == false then
            uiObjects.status3.Color = Color3.fromRGB(200,0,0)
        end
        --
        uiObjects.status4.Text = tostring(data.Self)
        if data.Self == true then
            uiObjects.status4.Color = Color3.fromRGB(0,200,0)
        elseif data.Self == false then
            uiObjects.status4.Color = Color3.fromRGB(200,0,0)
        end
        --
        uiObjects.status5.Text = tostring(data.UI)
        if data.UI == true then
            uiObjects.status5.Color = Color3.fromRGB(0,200,0)
        elseif data.UI == false then
            uiObjects.status5.Color = Color3.fromRGB(200,0,0)
        end
    end)
    --esp
    local function esp(targetPlayer)
        local espObjects = {
            box = draw("Square", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, ZIndex = 1,Transparency = 0.5}),
            tracer = draw("Line", {Color = Color3.fromRGB(255, 255, 255), ZIndex = 1, Transparency = 0.5}),
            text = draw("Text", {Color = Color3.fromRGB(255, 255, 255),Font = 2, Center = true, Outline = true, ZIndex = 1, Size = 13,Transparency = 0.75}),
        }
        runService.RenderStepped:Connect(function()
            if data.ESP and (data.Self or targetPlayer ~= player) then
                local character = targetPlayer.Character
                if character then 
                    local humanoid, humanoidRootPart= character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local screenPosition, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                        local orientation = humanoidRootPart.CFrame
                        local height = (camera.CFrame - camera.CFrame.Position) * Vector3.new(0, 2.75, 0)
                        local screenHeight = math.abs(camera:WorldToScreenPoint(orientation.Position + height).Y - camera:WorldToScreenPoint(orientation.Position - height).Y)
                        local boxSize = round(Vector2.new(screenHeight / 2, screenHeight))
                        local distance = math.floor(player:DistanceFromCharacter(humanoidRootPart.Position))

                        espObjects.box.Size = boxSize
                        espObjects.box.Position = round(Vector2.new(screenPosition.X, screenPosition.Y) - (boxSize / 2))
                        espObjects.text.Visible = onScreen
                        espObjects.text.Position = Vector2.new(((espObjects.box.Size.X / 2) + espObjects.box.Position.X), ((screenPosition.Y - espObjects.box.Size.Y / 2) - 18))
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
                        for index, object in next, espObjects do
                            object.Visible = false
                            object:Remove()
                            espObjects[index] = nil
                        end
                    end
                else
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
    for _,v in pairs(players:GetChildren()) do
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
