local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIG
local PLANT_FOLDER = Workspace:WaitForChild("Plants")

-- RemoteEvent
local stickEvent = ReplicatedStorage:FindFirstChild("StickPetEvent")
if not stickEvent then
    stickEvent = Instance.new("RemoteEvent")
    stickEvent.Name   = "StickPetEvent"
    stickEvent.Parent = ReplicatedStorage
end

if RunService:IsServer() then
    -- inline PetLocker
    local PetLocker = { _locked = {} }
    function PetLocker:LockPet(petModel, targetCFrame)
        assert(petModel.PrimaryPart, "Pet must have PrimaryPart")
        if self._locked[petModel] then self:UnlockPet(petModel) end
        local root = petModel.PrimaryPart
        local worldAt = Instance.new("Attachment", Workspace)
        worldAt.WorldPosition    = targetCFrame.Position
        worldAt.WorldOrientation = targetCFrame - targetCFrame.Position
        local petAt = Instance.new("Attachment", root)
        local ap = Instance.new("AlignPosition", root)
        ap.Attachment0, ap.Attachment1 = petAt, worldAt
        ap.RigidityEnabled, ap.MaxForce, ap.Responsiveness = true, Vector3.new(1e5,1e5,1e5), 200
        local ao = Instance.new("AlignOrientation", root)
        ao.Attachment0, ao.Attachment1 = petAt, worldAt
        ao.RigidityEnabled, ao.MaxTorque, ao.Responsiveness = true, Vector3.new(1e4,1e4,1e4), 200
        self._locked[petModel] = { worldAt, petAt, ap, ao }
    end
    function PetLocker:UnlockPet(petModel)
        local t = self._locked[petModel]
        if not t then return end
        for _, o in ipairs(t) do if o and o.Parent then o:Destroy() end end
        self._locked[petModel] = nil
    end

    stickEvent.OnServerEvent:Connect(function(player, plant)
        if typeof(plant)~="Instance" or not plant:IsDescendantOf(Workspace) then return end
        local petModel = Workspace:FindFirstChild("Pets") and Workspace.Pets:FindFirstChild(player.Name)
        if not petModel then return end
        local anchor = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
        if not anchor then return end
        local yOffset = anchor.Size.Y/2 + petModel:GetExtentsSize().Y/2
        PetLocker:LockPet(petModel, anchor.CFrame * CFrame.new(0, yOffset, 0))
    end)
else
    -- CLIENT UI
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "PetStickGui"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 200, 0, 300)
    frame.Position = UDim2.new(0, 20, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0

    local list = Instance.new("UIListLayout", frame)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 4)

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Stick Pet to Plant"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local hideBtn = Instance.new("TextButton", header)
    hideBtn.Size = UDim2.new(0, 25, 0, 25)
    hideBtn.Position = UDim2.new(1, -30, 0, 2)
    hideBtn.Text = "—"
    hideBtn.Font = Enum.Font.Gotham
    hideBtn.TextSize = 18
    hideBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    hideBtn.TextColor3 = Color3.new(1,1,1)

    local openIcon = Instance.new("TextButton", gui)
    openIcon.Size = UDim2.new(0, 30, 0, 30)
    openIcon.Position = UDim2.new(0, 20, 0.5, -15)
    openIcon.Text = "☰"
    openIcon.Font = Enum.Font.GothamBold
    openIcon.TextSize = 20
    openIcon.BackgroundColor3 = Color3.fromRGB(30,30,30)
    openIcon.TextColor3 = Color3.new(1,1,1)
    openIcon.Visible = false

    hideBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        openIcon.Visible = true
    end)
    openIcon.MouseButton1Click:Connect(function()
        frame.Visible = true
        openIcon.Visible = false
    end)

    for _, plant in ipairs(PLANT_FOLDER:GetChildren()) do
        if plant:IsA("Model") then
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, 0)
            btn.Text = plant.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            btn.MouseButton1Click:Connect(function()
                stickEvent:FireServer(plant)
            end)
        end
    end
end
