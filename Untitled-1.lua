-- Pet Plant Manager GUI System for Roblox - Grow a Garden Game
-- Place this in StarterGui or StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local PET_DISTANCE = 8 -- How close pets stay to assigned plants
local UPDATE_INTERVAL = 0.5
local ANIMATION_TIME = 0.3

-- Data storage
local plantAssignments = {} -- [plant] = {pets = {}, position = Vector3}
local allPlants = {}
local allPets = {}
local lastUpdate = 0

-- GUI Creation
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetPlantManager"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Minimized Icon
    local iconFrame = Instance.new("ImageButton")
    iconFrame.Name = "MinimizedIcon"
    iconFrame.Size = UDim2.new(0, 60, 0, 60)
    iconFrame.Position = UDim2.new(0, 20, 0.5, -30)
    iconFrame.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    iconFrame.BorderSizePixel = 0
    iconFrame.Visible = false
    iconFrame.Parent = screenGui

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 30)
    iconCorner.Parent = iconFrame

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🌱"
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.SourceSansBold
    iconLabel.Parent = iconFrame

    -- Main Menu Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainMenu"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 12)
    titleFix.Position = UDim2.new(0, 0, 1, -12)
    titleFix.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Pet Plant Manager"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.new(0, 0, 0)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = titleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 15)
    minCorner.Parent = minimizeBtn

    -- Content Area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(34, 139, 34)
    contentFrame.Parent = mainFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame

    -- Refresh Button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Name = "RefreshButton"
    refreshBtn.Size = UDim2.new(1, 0, 0, 35)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Text = "🔄 Refresh Plants & Pets"
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.TextScaled = true
    refreshBtn.Font = Enum.Font.SourceSans
    refreshBtn.LayoutOrder = 1
    refreshBtn.Parent = contentFrame

    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 8)
    refreshCorner.Parent = refreshBtn

    return screenGui, mainFrame, iconFrame, contentFrame, refreshBtn, minimizeBtn
end

-- Enhanced Plant Detection (Grow a Garden Specific)
local function findAllPlants()
    allPlants = {}
    
    print("=== SEARCHING FOR GROW A GARDEN PLANTS ===")
    
    -- Search workspace for plants
    for _, obj in pairs(workspace:GetChildren()) do
        local objName = obj.Name:lower()
        print("Checking object:", obj.Name, "Type:", obj.ClassName)
        
        -- Grow a Garden specific plant names
        local isPlant = objName:find("honey") or 
                       objName:find("compressor") or 
                       objName:find("honeycomb") or
                       objName:find("plant") or 
                       objName:find("tree") or 
                       objName:find("flower") or 
                       objName:find("fruit") or 
                       objName:find("crop") or 
                       objName:find("farm") or
                       objName:find("garden") or
                       objName:find("seed") or
                       objName:find("growth")
        
        if isPlant then
            print("Found plant:", obj.Name)
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("UnionOperation") then
                table.insert(allPlants, obj)
                print("✅ Added plant:", obj.Name, "Type:", obj.ClassName)
            end
        end
    end
    
    print("=== PLANT SEARCH COMPLETE ===")
    print("Total plants found:", #allPlants)
end

-- Enhanced Pet Detection (Grow a Garden Specific)
local function findAllPets()
    allPets = {}
    
    print("=== SEARCHING FOR PETS (GROW A GARDEN) ===")
    print("Player name:", player.Name)
    
    -- Method 1: Search workspace directly
    for _, obj in pairs(workspace:GetChildren()) do
        local objName = obj.Name:lower()
        local isPet = false
        
        -- Pet detection patterns for Grow a Garden
        if objName:find("pet") then
            print("Found by 'pet' keyword:", obj.Name)
            isPet = true
        elseif objName:find("toucan") then
            print("Found by 'toucan' keyword:", obj.Name)
            isPet = true
        elseif objName:find("bird") then
            print("Found by 'bird' keyword:", obj.Name)
            isPet = true
        elseif objName:find(player.Name:lower()) then
            print("Found by player name:", obj.Name)
            isPet = true
        elseif objName:find("companion") then
            print("Found by 'companion' keyword:", obj.Name)
            isPet = true
        elseif objName:find("follower") then
            print("Found by 'follower' keyword:", obj.Name)
            isPet = true
        end
        
        -- Check for ownership
        if not isPet then
            local owner = obj:FindFirstChild("Owner")
            if owner then
                if (owner:IsA("StringValue") and owner.Value == player.Name) or
                   (owner:IsA("ObjectValue") and owner.Value == player) then
                    print("Found by Owner tag:", obj.Name)
                    isPet = true
                end
            end
        end
        
        if isPet and (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("UnionOperation")) then
            table.insert(allPets, obj)
            print("✅ Added pet:", obj.Name, "Type:", obj.ClassName)
        end
    end
    
    -- Method 2: Check common pet folder locations
    local petFolderNames = {
        "Pets",
        "PlayerPets", 
        player.Name .. "_Pets",
        player.Name .. "Pets",
        "Companions",
        "Followers"
    }
    
    for _, folderName in pairs(petFolderNames) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            print("Found pet folder:", folderName)
            for _, pet in pairs(folder:GetChildren()) do
                if not table.find(allPets, pet) then
                    table.insert(allPets, pet)
                    print("✅ Added pet from folder:", pet.Name)
                end
            end
        end
    end
    
    -- Method 3: Check ReplicatedStorage for pets
    local repStorage = game:GetService("ReplicatedStorage")
    if repStorage then
        for _, obj in pairs(repStorage:GetChildren()) do
            local objName = obj.Name:lower()
            if objName:find("pet") or objName:find("toucan") then
                print("Found pet in ReplicatedStorage:", obj.Name)
                if not table.find(allPets, obj) then
                    table.insert(allPets, obj)
                    print("✅ Added pet from ReplicatedStorage:", obj.Name)
                end
            end
        end
    end
    
    -- Method 4: Search for pets near player
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = player.Character.HumanoidRootPart.Position
        print("Searching for pets near player position...")
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj ~= player.Character then
                local objPos = nil
                
                if obj:IsA("Model") and obj.PrimaryPart then
                    objPos = obj.PrimaryPart.Position
                elseif obj:IsA("Part") then
                    objPos = obj.Position
                end
                
                if objPos and (objPos - playerPos).Magnitude <= 50 then
                    local objName = obj.Name:lower()
                    local couldBePet = objName:find("pet") or 
                                      objName:find("toucan") or 
                                      objName:find("bird") or 
                                      objName:find("companion") or
                                      objName:find(player.Name:lower()) or
                                      -- Check for models with humanoid (common for pets)
                                      (obj:IsA("Model") and obj:FindFirstChild("Humanoid"))
                    
                    if couldBePet and not table.find(allPets, obj) then
                        table.insert(allPets, obj)
                        print("✅ Added nearby potential pet:", obj.Name, "Distance:", math.floor((objPos - playerPos).Magnitude))
                    end
                end
            end
        end
    end
    
    -- Debug: Show all nearby objects if no pets found
    if #allPets == 0 then
        print("⚠️ NO PETS FOUND! Here are ALL objects near you:")
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = player.Character.HumanoidRootPart.Position
            local count = 0
            
            for _, obj in pairs(workspace:GetChildren()) do
                if count >= 20 then break end
                local objPos = nil
                
                if obj:IsA("Model") and obj.PrimaryPart then
                    objPos = obj.PrimaryPart.Position
                elseif obj:IsA("Part") then
                    objPos = obj.Position
                end
                
                if objPos and (objPos - playerPos).Magnitude <= 100 then
                    print(count + 1, "Name:", obj.Name, "Type:", obj.ClassName, "Distance:", math.floor((objPos - playerPos).Magnitude))
                    count = count + 1
                end
            end
        end
        
        print("=== FOLDER STRUCTURE DEBUG ===")
        print("Workspace children count:", #workspace:GetChildren())
        for i, obj in pairs(workspace:GetChildren()) do
            if i <= 10 then
                print(i, obj.Name, obj.ClassName)
            end
        end
    end
    
    print("=== PET SEARCH COMPLETE ===")
    print("Total pets found:", #allPets)
end

-- Create Plant Selection UI
local function createPlantCard(plant, contentFrame)
    local cardFrame = Instance.new("Frame")
    cardFrame.Name = "PlantCard_" .. plant.Name
    cardFrame.Size = UDim2.new(1, 0, 0, 120)
    cardFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cardFrame.BorderSizePixel = 0
    cardFrame.LayoutOrder = #contentFrame:GetChildren() + 1
    cardFrame.Parent = contentFrame

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = cardFrame

    -- Plant Info
    local plantName = Instance.new("TextLabel")
    plantName.Size = UDim2.new(0.6, 0, 0, 25)
    plantName.Position = UDim2.new(0, 10, 0, 5)
    plantName.BackgroundTransparency = 1
    plantName.Text = plant.Name
    plantName.TextColor3 = Color3.new(1, 1, 1)
    plantName.TextScaled = true
    plantName.Font = Enum.Font.SourceSansBold
    plantName.TextXAlignment = Enum.TextXAlignment.Left
    plantName.Parent = cardFrame

    -- Assigned Pets Count
    local petCount = Instance.new("TextLabel")
    petCount.Name = "PetCount"
    petCount.Size = UDim2.new(0.35, 0, 0, 20)
    petCount.Position = UDim2.new(0.6, 0, 0, 5)
    petCount.BackgroundTransparency = 1
    petCount.Text = "Pets: 0"
    petCount.TextColor3 = Color3.fromRGB(150, 150, 150)
    petCount.TextScaled = true
    petCount.Font = Enum.Font.SourceSans
    petCount.TextXAlignment = Enum.TextXAlignment.Right
    petCount.Parent = cardFrame

    -- Pet Selection Area
    local petArea = Instance.new("ScrollingFrame")
    petArea.Name = "PetArea"
    petArea.Size = UDim2.new(1, -20, 0, 60)
    petArea.Position = UDim2.new(0, 10, 0, 30)
    petArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    petArea.BorderSizePixel = 0
    petArea.ScrollBarThickness = 4
    petArea.ScrollingDirection = Enum.ScrollingDirection.X
    petArea.CanvasSize = UDim2.new(0, 0, 1, 0)
    petArea.Parent = cardFrame

    local petAreaCorner = Instance.new("UICorner")
    petAreaCorner.CornerRadius = UDim.new(0, 4)
    petAreaCorner.Parent = petArea

    local petLayout = Instance.new("UIListLayout")
    petLayout.FillDirection = Enum.FillDirection.Horizontal
    petLayout.SortOrder = Enum.SortOrder.LayoutOrder
    petLayout.Padding = UDim.new(0, 5)
    petLayout.Parent = petArea

    -- Add Pet Buttons
    local totalWidth = 0
    if #allPets > 0 then
        for i, pet in ipairs(allPets) do
            local petBtn = Instance.new("TextButton")
            petBtn.Name = "Pet_" .. pet.Name
            petBtn.Size = UDim2.new(0, 80, 1, -10)
            petBtn.Position = UDim2.new(0, 0, 0, 5)
            petBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            petBtn.BorderSizePixel = 0
            petBtn.Text = pet.Name:gsub(player.Name .. "_", "")
            petBtn.TextColor3 = Color3.new(1, 1, 1)
            petBtn.TextScaled = true
            petBtn.Font = Enum.Font.SourceSans
            petBtn.LayoutOrder = i
            petBtn.Parent = petArea

            local petBtnCorner = Instance.new("UICorner")
            petBtnCorner.CornerRadius = UDim.new(0, 4)
            petBtnCorner.Parent = petBtn

            totalWidth = totalWidth + 85

            -- Toggle pet assignment
            petBtn.MouseButton1Click:Connect(function()
                if not plantAssignments[plant] then
                    local plantPos = nil
                    if plant:IsA("Model") and plant.PrimaryPart then
                        plantPos = plant.PrimaryPart.Position
                    elseif plant:IsA("Part") then
                        plantPos = plant.Position
                    else
                        plantPos = Vector3.new(0, 0, 0)
                    end
                    plantAssignments[plant] = {pets = {}, position = plantPos}
                end

                local petList = plantAssignments[plant].pets
                local petIndex = table.find(petList, pet)

                if petIndex then
                    -- Remove pet
                    table.remove(petList, petIndex)
                    petBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    print("Removed", pet.Name, "from", plant.Name)
                else
                    -- Add pet
                    table.insert(petList, pet)
                    petBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
                    print("Assigned", pet.Name, "to", plant.Name)
                end

                -- Update pet count
                petCount.Text = "Pets: " .. #petList
            end)
        end
    else
        -- Show message when no pets available
        local noPetLabel = Instance.new("TextLabel")
        noPetLabel.Size = UDim2.new(1, -10, 1, -10)
        noPetLabel.Position = UDim2.new(0, 5, 0, 5)
        noPetLabel.BackgroundTransparency = 1
        noPetLabel.Text = "No pets found - check console"
        noPetLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
        noPetLabel.TextScaled = true
        noPetLabel.Font = Enum.Font.SourceSans
        noPetLabel.Parent = petArea
        totalWidth = 200
    end

    -- Update canvas size
    petArea.CanvasSize = UDim2.new(0, totalWidth, 1, 0)

    -- Control Buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, -20, 0, 25)
    controlFrame.Position = UDim2.new(0, 10, 1, -30)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = cardFrame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 60, 1, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    clearBtn.BorderSizePixel = 0
    clearBtn.Text = "Clear"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.SourceSans
    clearBtn.Parent = controlFrame

    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 4)
    clearCorner.Parent = clearBtn

    clearBtn.MouseButton1Click:Connect(function()
        local plantPos = nil
        if plant:IsA("Model") and plant.PrimaryPart then
            plantPos = plant.PrimaryPart.Position
        elseif plant:IsA("Part") then
            plantPos = plant.Position
        else
            plantPos = Vector3.new(0, 0, 0)
        end
        plantAssignments[plant] = {pets = {}, position = plantPos}
        petCount.Text = "Pets: 0"
        -- Reset all pet button colors
        for _, petBtn in pairs(petArea:GetChildren()) do
            if petBtn:IsA("TextButton") then
                petBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end
    end)
end

-- Pet Management System
local function managePetPositions(deltaTime)
    lastUpdate = lastUpdate + deltaTime
    
    if lastUpdate >= UPDATE_INTERVAL then
        lastUpdate = 0
        
        for plant, data in pairs(plantAssignments) do
            if plant.Parent then
                local plantPos = nil
                
                -- Get plant position
                if plant:IsA("Model") and plant.PrimaryPart then
                    plantPos = plant.PrimaryPart.Position
                elseif plant:IsA("Part") then
                    plantPos = plant.Position
                elseif plant:IsA("Model") then
                    for _, child in pairs(plant:GetChildren()) do
                        if child:IsA("Part") then
                            plantPos = child.Position
                            break
                        end
                    end
                end
                
                if plantPos then
                    data.position = plantPos
                    
                    for i, pet in ipairs(data.pets) do
                        if pet.Parent then
                            local petPart = nil
                            
                            -- Get pet's main part
                            if pet:IsA("Model") and pet.PrimaryPart then
                                petPart = pet.PrimaryPart
                            elseif pet:IsA("Part") then
                                petPart = pet
                            elseif pet:IsA("Model") then
                                petPart = pet:FindFirstChild("Torso") or 
                                         pet:FindFirstChild("HumanoidRootPart") or
                                         pet:FindFirstChild("Head") or
                                         pet:FindFirstChildOfClass("Part")
                            end
                            
                            if petPart then
                                -- Calculate target position around the plant
                                local angle = (i - 1) * (math.pi * 2) / #data.pets
                                local targetPos = plantPos + Vector3.new(
                                    math.cos(angle) * PET_DISTANCE,
                                    2,
                                    math.sin(angle) * PET_DISTANCE
                                )
                                
                                local currentPos = petPart.Position
                                local distance = (targetPos - currentPos).Magnitude
                                
                                -- Only move if pet is too far from target
                                if distance > 3 then
                                    print("Moving", pet.Name, "to", plant.Name, "position")
                                    
                                    -- Use CFrame for more reliable positioning
                                    local success, error = pcall(function()
                                        petPart.CFrame = CFrame.new(targetPos)
                                    end)
                                    
                                    if not success then
                                        -- Fallback to BodyPosition if CFrame fails
                                        local bodyPosition = petPart:FindFirstChild("BodyPosition")
                                        if not bodyPosition then
                                            bodyPosition = Instance.new("BodyPosition")
                                            bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
                                            bodyPosition.P = 3000
                                            bodyPosition.D = 500
                                            bodyPosition.Parent = petPart
                                        end
                                        
                                        bodyPosition.Position = targetPos
                                        
                                        -- Remove after short time
                                        game:GetService("Debris"):AddItem(bodyPosition, 2)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Main System
local function initializeSystem()
    local screenGui, mainFrame, iconFrame, contentFrame, refreshBtn, minimizeBtn = createMainGUI()
    
    -- Minimize/Maximize functionality
    local function minimizeMenu()
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
            iconFrame.Visible = true
        end)
    end
    
    local function maximizeMenu()
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        iconFrame.Visible = false
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 400, 0, 500)}
        )
        tween:Play()
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeMenu)
    iconFrame.MouseButton1Click:Connect(maximizeMenu)
    
    -- Refresh functionality
    local function refreshContent()
        print("🔄 REFRESH BUTTON CLICKED!")
        
        findAllPlants()
        findAllPets()
        
        -- Clear existing content
        for _, child in pairs(contentFrame:GetChildren()) do
            if child.Name:find("PlantCard_") or child.Name == "NoPlantMessage" or child.Name == "PetInfo" then
                child:Destroy()
            end
        end
        
        -- Create new plant cards
        if #allPlants > 0 then
            for i, plant in ipairs(allPlants) do
                print("Creating card for plant:", plant.Name, "(" .. i .. "/" .. #allPlants .. ")")
                createPlantCard(plant, contentFrame)
            end
        else
            -- Show a message when no plants found
            local noPlantLabel = Instance.new("TextLabel")
            noPlantLabel.Name = "NoPlantMessage"
            noPlantLabel.Size = UDim2.new(1, 0, 0, 60)
            noPlantLabel.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
            noPlantLabel.BorderSizePixel = 0
            noPlantLabel.Text = "No plants found!\nCheck console for debug info"
            noPlantLabel.TextColor3 = Color3.new(1, 1, 1)
            noPlantLabel.TextScaled = true
            noPlantLabel.Font = Enum.Font.SourceSans
            noPlantLabel.LayoutOrder = 2
            noPlantLabel.Parent = contentFrame
            
            local noPlantCorner = Instance.new("UICorner")
            noPlantCorner.CornerRadius = UDim.new(0, 8)
            noPlantCorner.Parent = noPlantLabel
        end
        
        -- Show summary
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "PetInfo"
        infoLabel.Size = UDim2.new(1, 0, 0, 30)
        infoLabel.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        infoLabel.BorderSizePixel = 0
        infoLabel.Text = "Found " .. #allPets .. " pets and " .. #allPlants .. " plants"
        infoLabel.TextColor3 = Color3.new(1,
