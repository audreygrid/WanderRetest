

repeat
	task.wait()
until game.Loaded


--			variables

local plr = game.Players.LocalPlayer
repeat
	task.wait()
until plr.Character
local Plr = plr.Character
local Mouse = plr:GetMouse()

local RunService = game:GetService("RunService");
local UIS = game:GetService("UserInputService") 

local ev = game.ReplicatedStorage.Events;
local an = game.ReplicatedStorage.Animations;
local fn = game.ReplicatedStorage.FightAnimations;


local _DMG = 30;
local Db = true

local DASH_FORCE = 60 
local DASH_TIME = .4

local Dash_Direction="Forward";
local CarryUI;
local Execute;


--			animation variables

local Fighting_Animations 
Fighting_Animations = {
	Block=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Block),
	Parry=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Parry),
	BlockBreak=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.BlockBreak),
	Punch1=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Punch1),
	Punch2=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Punch2),
	Punch3=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Punch3),
	Punch4=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Punch4),
	Punch5=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Punch5),
	Crit=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(fn.Crit),
}; 

local Player_Animations  = {
	DoubleJump=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an["Double Jump"]),
	DashForward=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.DashF),
	DashBackward=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.DashB),
	DashRight=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.DashR),
	DashLeft=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.DashL),
	Run=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.Run),
	Crawl=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.Crawl),
	Carry1=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.Carry1),
	Carry2=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.Carry2),
	Execute=Plr:WaitForChild("Humanoid").Animator:LoadAnimation(an.Execute),
}; 

local m1s:{AnimationTrack}= {
	m1=Fighting_Animations.Punch1,
	m2=Fighting_Animations.Punch2,
	m3=Fighting_Animations.Punch3,
	m4=Fighting_Animations.Punch4,
	m5=Fighting_Animations.Punch5,
}
local Sounds = {
	--Combat M1s
	Swing1= 121712091891914,
	Swing2= 98260221164932,
	Swing3= 93477814070039,
	Swing4= 85875358751445,
	Swing5= 94070752004758,

	--Heavy attack
	M2=19190263297033,

	GuardBreak= 109111353552666,

	Hit1= 78255028864574,
	Hit2= 108031936906697,
	Hit3= 111188275088361,
	Hit4= 77914687738372,
	M2Hi= 71198382132155,

	--Movement
	Dash= 124722097333039,

	Gri= 86320241851494, 

}

--utility functions
local function SendSound(sound)
	ev.Sound:FireServer(sound)
end

local Disable = function(at, state)
	ev.ChangeAttribute:FireServer(at, state)
end

--movement functions 
function Dash()
	if not Plr:GetAttribute("CanDash") then return end
	SendSound(Sounds.Dash)

	-- Cooldown
	Disable("CanDash", false)
	task.delay(1, function()
		Disable("CanDash", true)
	end)

	local character = Plr
	local hrp = character:WaitForChild("HumanoidRootPart")
	local _humanoid = character:WaitForChild("Humanoid")
	local camera = workspace.CurrentCamera

	local dashDirection
	local animationTrack

	-- Get directions from camera CFrame
	local camCF = camera.CFrame
	local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
	local camRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

	-- Choose direction relative to camera
	if Dash_Direction == "Forward" then
		dashDirection = camLook
		animationTrack = Player_Animations.DashForward
	elseif Dash_Direction == "Backward" then
		dashDirection = -camLook
		animationTrack = Player_Animations.DashBackward
	elseif Dash_Direction == "Right" then
		dashDirection = camRight
		animationTrack = Player_Animations.DashRight
	elseif Dash_Direction == "Left" then
		dashDirection = -camRight
		animationTrack = Player_Animations.DashLeft
	else
		return
	end

	-- Play animation fast
	animationTrack:Play(0.2, 1, 1.6)

	-- Lock rotation using AlignOrientation
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Responsiveness = 200
	alignOrientation.RigidityEnabled = true
	alignOrientation.CFrame = CFrame.lookAt(Vector3.zero, dashDirection)
	alignOrientation.MaxTorque = math.huge

	local lockAttachment = Instance.new("Attachment")
	lockAttachment.Name = "DashRotationAttachment"
	lockAttachment.Parent = hrp

	alignOrientation.Attachment0 = lockAttachment
	alignOrientation.Parent = hrp

	-- Dash with LinearVelocity
	local dashAttachment = Instance.new("Attachment")
	dashAttachment.Name = "DashAttachment"
	dashAttachment.Parent = hrp

	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = dashAttachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VectorVelocity = dashDirection * DASH_FORCE
	velocity.MaxForce = math.huge
	velocity.Parent = hrp

	-- Cleanup
	task.delay(DASH_TIME, function()
		if velocity then velocity:Destroy() end
		if dashAttachment then dashAttachment:Destroy() end
		if lockAttachment then lockAttachment:Destroy() end
		if alignOrientation then alignOrientation:Destroy() end
		hrp.AssemblyAngularVelocity = Vector3.zero
	end)
end

function DJ()
	if not Plr:GetAttribute("CanDJ") then return end
	ev.ChangeAttribute:FireServer("CanDJ", false)
	Player_Animations.DoubleJump:Play();
	spawn(function()
		repeat
			task.wait()
		until Plr.Humanoid:GetState() == Enum.HumanoidStateType.Landed
		print("DOne");
		ev.ChangeAttribute:FireServer("CanDJ", true);
	end)

	local Con
	Con = Player_Animations.DoubleJump:GetMarkerReachedSignal("Go"):Connect(function()
		Plr.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		Con:Disconnect();

	end)


end


spawn(function()
	ev.Attribute:FireServer()
end)


--m1s and m2s



local currentPunch = 1
local isPunching = false 
local waitTime = .2
local Size = Vector3.new(4, 5.5, 2.6)
print("Got here")

--m1s
Mouse.Button1Down:Connect(function()
	if not Plr:GetAttribute("CanPunch") then return end
	if isPunching then return end
	Disable("CanPunch", false)
	Disable("Punching", true)
	SendSound(Sounds["Swing"..tostring(currentPunch)])
	task.delay(waitTime, function()
		Disable("CanPunch", true)
		Disable("Punching", false)
		currentPunch += 1
		if currentPunch > 5 then currentPunch = 1 end
		isPunching = false
	end)

	isPunching = true
	local currentm1 = m1s["m"..currentPunch] -- FIXED HERE ( no it's not. and chat gpt is fucking useless )~ Ike
	currentm1:Play(0.4, 1, 1.4)
	if currentPunch == 5 then
		waitTime = 1;
	else
		waitTime = currentm1.Length/1.4;
	end
	local markerConn
	markerConn = currentm1:GetMarkerReachedSignal("Go"):Connect(function()
		markerConn:Disconnect()
		local CF = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.4)
		ev.Attack:FireServer(CF, Size, currentPunch)
	end)
end)
--m2s
Mouse.Button2Down:Connect(function()
	if not Plr:GetAttribute("CanCrit") then return end
	if not Db then return end

	Db = false

	task.delay(2, function()
		Db = true
	end)
	Disable("CanCrit", false)

	SendSound(Sounds.M2)
	task.delay(2, function()
		Disable("CanCrit", true)   
	end)

	if isPunching then return end

	isPunching = true
	local currentm1 = Fighting_Animations.Crit
	currentm1:Play(0.4, 1, 1.4)
	local markerConn
	markerConn = currentm1:GetMarkerReachedSignal("Go"):Connect(function()
		markerConn:Disconnect()
		local CF = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.4)
		local Size = Vector3.new(4, 5.5, 2.6)

		ev.CriticalAttack:FireServer(CF, Size, 30)
		isPunching = false -- FIXED here
	end) 
end)

UIS.InputBegan:Connect(function(i,g)
	if g then return end
	if not (i.KeyCode == Enum.KeyCode.R) then return end
	if not Plr:GetAttribute("CanCrit") then return end
	if not Db then return end

	Db = false

	task.delay(2, function()
		Db = true
	end)
	Disable("CanCrit", false)

	SendSound(Sounds.M2)
	task.delay(2, function()
		Disable("CanCrit", true)   
	end)

	if isPunching then return end

	isPunching = true
	local currentm1 = Fighting_Animations.Crit
	currentm1:Play(0.4, 1, 1.4)
	local markerConn
	markerConn = currentm1:GetMarkerReachedSignal("Go"):Connect(function()
		markerConn:Disconnect()
		local CF = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.4)
		local Size = Vector3.new(4, 5.5, 2.6)

		ev.CriticalAttack:FireServer(CF, Size, 30)
		isPunching = false -- FIXED here
	end) 
end) 

--Block
--block enable
local blockHeld = false

UIS.InputBegan:Connect(function(input, gameProcessed)
	print(input.KeyCode)
	if gameProcessed or input.KeyCode ~= Enum.KeyCode.F then return end
	print("BLOCK ACTIVE")
	if not Plr:GetAttribute("CanBlock") then return end
	if Plr:GetAttribute("Blocking") then return end
	print("BLOCK RUNNING")
	blockHeld = true

	-- Begin Parry
	Disable("CanBlock", false)
	Disable("CanParry", false)
	Disable("Parrying", true)

	Fighting_Animations.Parry:Play()

	task.delay(0.5, function()
		-- End Parry
		Disable("Parrying", false)

		if not blockHeld then return end -- If player released F early, don't continue

		-- Begin Block
		Disable("Blocking", true)
		Fighting_Animations.Block:Play()
		Plr.Humanoid.WalkSpeed = 0
		Plr.Humanoid.JumpPower = 0
	end)
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		blockHeld = false

		-- Stop block animation if it was playing
		Fighting_Animations.Block:Stop()

		-- Reset states and attributes
		Plr.Humanoid.WalkSpeed = 16
		Plr.Humanoid.JumpPower = 50

		Disable("CanBlock", true)
		Disable("CanParry", true)
		Disable("Blocking", false)
		Disable("Parrying", false)
	end
end)

--events
--Yeah yeah I misspelt break, stfu
ev.BlockBrake.OnClientEvent:Connect(function()

	Fighting_Animations.Block:Stop();
	Fighting_Animations.BlockBreak:Play()

	SendSound(Sounds.M2Hi)
	SendSound(Sounds.GuardBreak)
end)

--Dash
pcall(function()
	
	UIS.InputBegan:Connect(function(i,g)

		if g then return end;

		if i.KeyCode == Enum.KeyCode.W then

			Dash_Direction = "Forward";
		elseif i.KeyCode == Enum.KeyCode.S then

			Dash_Direction = "Backward";
		elseif i.KeyCode == Enum.KeyCode.A then

			Dash_Direction = "Left";
		elseif i.KeyCode == Enum.KeyCode.D then

			Dash_Direction = "Right";
		end
	end)

	UIS.InputEnded:Connect(function(i,g)

		if g then return end;

		if i.KeyCode == Enum.KeyCode.S then

			if not UIS:IsKeyDown("A") and not UIS:IsKeyDown("D") then

				Dash_Direction = "Forward";
			end
		elseif i.KeyCode == Enum.KeyCode.A then

			if not UIS:IsKeyDown("S") and not UIS:IsKeyDown("D") then

				Dash_Direction = "Forward";
			end
		elseif i.KeyCode == Enum.KeyCode.D then

			if not UIS:IsKeyDown("S") and not UIS:IsKeyDown("A") then

				Dash_Direction = "Forward";
			end
		end
	end)


	--			Dash
	UIS.InputBegan:Connect(function(i,g)

		if g then return end

		if i.KeyCode == Enum.KeyCode.Q then

			Dash()
		elseif i.KeyCode == Enum.KeyCode.Space then

			if Plr.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				DJ() 
			end
		end
	end)

end)

Plr.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	print(Plr.Humanoid.Health)
	if Plr.Humanoid.Health <= 15 then 
		Disable("Downed", true)
	else
		Disable("Downed", false)
		ev.RemoveCarry:FireServer()
	end
end)

--Downed
Plr.Humanoid:GetAttributeChangedSignal("Downed"):Connect(function()
	
	if Plr:GetAttribute("Downed") then
		
		if not Player_Animations.Crawl.IsPlaying and not Plr:GetAttribute("BeingCarried") then

			Player_Animations.Crawl:Play()
			
			ev.Carriate:FireServer()
			ev.Exate:FireServer()
		end
	else
		
		if Player_Animations.Carry2.IsPlaying then Player_Animations.Carry2:Stop() end
		if Player_Animations.Crawl.IsPlaying then Player_Animations.Crawl:Stop() end
		print("Up") 
	end
end)


--Carry and Execute 
ev.Carriate.OnClientEvent:Connect(function(player)
	if player == plr then return end
	if Plr:GetAttribute("Downed") then return end
	local character = workspace:WaitForChild(player.Name)
	if character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Carry") then return end -- prevent duplicates
	if CarryUI then CarryUI:Destroy() end
	local prompt = Instance.new("ProximityPrompt")
	local c
	c = character:GetAttributeChangedSignal("Downed"):Connect(function() -- FIXED typo here
		if character:GetAttribute("Downed") == false then -- FIXED typo here
			c:Disconnect()
			if CarryUI then CarryUI:Destroy() end
			if Execute then Execute:Destroy() end
		end
	end)
	CarryUI = prompt
	prompt.Name = "Carry"
	prompt.ActionText = "Carry"
	prompt.MaxActivationDistance = 50
	prompt.HoldDuration = 1
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	prompt.Enabled = true
	prompt.Parent = character.HumanoidRootPart
	prompt.RequiresLineOfSight = false

	prompt.Triggered:Connect(function()
		if Plr:GetAttribute("Downed") then
			prompt.ActionText = "yeah nice try buddy, get up first.";
			task.delay(2, function()
				prompt.ActionText = "Carry.";
			end)
			return
		else
			Disable("Carrying", true)
			ev.Carry:FireServer(character)
		end
	end)
end)

ev.RemoveCarry.OnClientEvent:Connect(function()
	if CarryUI and CarryUI.Parent then
		CarryUI:Destroy()
		CarryUI = nil
	end
end)

-- Execute prompt
ev.Exate.OnClientEvent:Connect(function(player)
	if player == plr then return end
	if Plr:GetAttribute("Downed") then return end

	local character = workspace:WaitForChild(player.Name)
	if character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Execute") then return end -- prevent duplicates

	local prompt = Instance.new("ProximityPrompt") 
	if Execute then Execute:Destroy() end
	Execute = prompt
	prompt.Name = "Execute"
	prompt.ActionText = "Execute"
	prompt.MaxActivationDistance = 50
	prompt.HoldDuration = 0
	prompt.KeyboardKeyCode = Enum.KeyCode.B
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	prompt.UIOffset = Vector2.new(200, 0)
	prompt.Enabled = true
	prompt.Parent = character.HumanoidRootPart
	prompt.RequiresLineOfSight = false


	prompt.Triggered:Connect(function()
		if Plr:GetAttribute("Downed") then

			prompt.ActionText = "yeah nice try buddy, get up first."; 
			task.delay(2, function() 
				prompt.ActionText = "Execute."; 
			end)
			return
		end

		print("Execute Triggered")
		Player_Animations.Execute:Play()

		task.spawn(function()
			Disable("CanDJ", false)
			Disable("CanDash", false)
			Disable("CanPunch", false)
			Disable("Blocking", false)
			task.wait(Player_Animations.Execute.Length)
			Disable("CanDJ", true)
			Disable("CanDash", true)
			Disable("CanPunch", true)
		end)

		Player_Animations.Execute:GetMarkerReachedSignal("Go"):Connect(function()
			print("Executing")
			SendSound(Sounds.Gri)
			ev.Execute:FireServer(character)
		end)
	end)
end)

ev.RemoveExe.OnClientEvent:Connect(function()
	if Execute and Execute.Parent then
		Execute:Destroy()
		Execute = nil
	end
end) 

--carry, being carried
Plr:GetAttributeChangedSignal("BeingCarried"):Connect(function()
	if Plr:GetAttribute("BeingCarried") then 
		--if Player_Animations.Crawl.IsPlaying then return end
		Player_Animations.Crawl:Stop()
		Player_Animations.Carry2:Play() 
	else
		--if not Player_Animations.Carry2.IsPlaying then return end
		Player_Animations.Carry2:Stop()
		if Plr:GetAttribute("Downed") then
			Player_Animations.Crawl:Play()
		end
	end 
end)

Plr:GetAttributeChangedSignal("Carrying"):Connect(function()
	if Plr:GetAttribute("Carrying") then 
		if Player_Animations.Carry1.IsPlaying then return end
		Player_Animations.Carry1:Play()
	else 
		if not Player_Animations.Carry1.IsPlaying then return end
		Player_Animations.Carry1:Stop()
	end
end)

--Running



local function updateRunAnimation()
	local moveMag = Plr.Humanoid.MoveDirection.Magnitude
	local isRunning = Plr:GetAttribute("Running")

	if isRunning and moveMag > 0 then
		if not Player_Animations.Run.IsPlaying then
			print("Playing run animation")
			Player_Animations.Run:Play()
			Plr.Humanoid.WalkSpeed = 32;
		end
	else
		if Player_Animations.Run.IsPlaying then
			print("Stopping run animation")
			Player_Animations.Run:Stop()
			Plr.Humanoid.WalkSpeed = 16;
		end
	end
end

RunService.RenderStepped:Connect(function()
	updateRunAnimation()
end)


Plr:GetAttributeChangedSignal("Running"):Connect(function()
	print("Running state changed:", Plr:GetAttribute("Running"))
	updateRunAnimation()
end)

UIS.InputBegan:Connect(function(i, g)
	if i.KeyCode == Enum.KeyCode.LeftControl and Plr:GetAttribute("CanRun") then 
		
		if Plr:GetAttribute("CanRun") then
			Disable("CanRun", false)
			if Plr:GetAttribute("Running") then
				
				Disable("Running", false)
			else
				Disable("Running", true)
			end
			task.delay(0.5, function()
				Disable("CanRun", true)
			end)
		end 
 
	end
end)

