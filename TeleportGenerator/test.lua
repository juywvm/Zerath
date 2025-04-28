local ZerathTPGen = {}

-- Cancel Current Teleport
function ZerathTPGen:CancelCurrentTP()
    if self.CurrentTeleport then
        self.CurrentTeleport:Cancel()
        warn("[ZerathTPGen]: Teleport cancelled successfully.")
    else
        warn("[ZerathTPGen]: No active teleport to cancel.")
    end
end

-- Teleport Fonksiyonu
function ZerathTPGen:Teleport(settings)
    -- Varsayılan Ayarlar
    local Method = settings.Method or "CFrame"
    local Type = settings.Type or "Normal"
    local Coordinates = settings.Coordinates or Vector3.new(0, 0, 0)
    local Delay = settings.Delay or 0
    local TweenStyle = settings.TweenStyle or "Linear"
    local CinematicMode = settings.CinematicMode or false

    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRoot = character:WaitForChild("HumanoidRootPart")

    -- Cancel Previous Teleport if Exists
    if self.CurrentTeleport then
        self.CurrentTeleport:Cancel()
    end

    -- Teleport Başlat
    self.CurrentTeleport = pcall(function()
        if Type == "Normal" then
            if Method == "CFrame" then
                humanoidRoot.CFrame = CFrame.new(Coordinates)
            elseif Method == "PivotTo" then
                humanoidRoot:PivotTo(Coordinates)
            elseif Method == "Tween" then
                -- Tween teleport ile animasyon
                local tweenInfo = TweenInfo.new(Delay, Enum.EasingStyle[TweenStyle], Enum.EasingDirection.Out, 0, false, 0)
                local tweenGoal = { CFrame = CFrame.new(Coordinates) }
                local tween = game:GetService("TweenService"):Create(humanoidRoot, tweenInfo, tweenGoal)
                tween:Play()
            elseif Method == "BodyPosition" then
                local bodyPosition = Instance.new("BodyPosition")
                bodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyPosition.Position = Coordinates
                bodyPosition.Parent = humanoidRoot
                task.delay(Delay, function()
                    bodyPosition:Destroy()
                end)
            elseif Method == "AlignPosition" then
                local alignPosition = Instance.new("AlignPosition")
                alignPosition.MaxForce = 1e6
                alignPosition.Position = Coordinates
                alignPosition.Parent = humanoidRoot
                task.delay(Delay, function()
                    alignPosition:Destroy()
                end)
            end
        elseif Type == "Underground" then
            -- Underground teleport
            humanoidRoot.CFrame = CFrame.new(Coordinates.X, Coordinates.Y - 5, Coordinates.Z)
            task.wait(1)
            humanoidRoot.CFrame = CFrame.new(Coordinates)
        elseif Type == "Air" then
            -- Air teleport
            humanoidRoot.CFrame = CFrame.new(Coordinates.X, Coordinates.Y + 5, Coordinates.Z)
            task.wait(1)
            humanoidRoot.CFrame = CFrame.new(Coordinates)
        end

        -- Cinematic Mode if enabled
        if CinematicMode then
            character.HumanoidRootPart.Transparency = 0.5
            task.delay(Delay, function()
                character.HumanoidRootPart.Transparency = 0
            end)
        end

        warn("[ZerathTPGen]: Teleport completed successfully.")
    end)

    if not self.CurrentTeleport then
        warn("[ZerathTPGen]: Error during teleport!")
    end
end

return ZerathTPGen
