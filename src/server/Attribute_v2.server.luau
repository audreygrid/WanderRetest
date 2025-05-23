game.ReplicatedStorage.Events.Attribute.OnServerEvent:Connect(function(plr)
	local character = plr.Character or plr.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart"):SetNetworkOwner(plr)
	character.Humanoid.BreakJointsOnDeath = false

	-- Initial Attributes
	local defaultAttributes = {
		CanDJ = true, CanBlock = true, CanDash = true, CanParry = true,
		CanPunch = true, CanRun = true, CanCrit = true,
		Blocking = false, Stunned = false, Punching = false, Parrying = false,
		Running = false, Downed = false, RefillingPosture = false,
		BeingCarried = false, Carrying = false,
		Stamina = 100, Posture = 100
	}

	task.delay(4, function()
		
		character:SetAttribute("CanCrit", true)
	end)
	for attr, val in pairs(defaultAttributes) do
		character:SetAttribute(attr, val)
	end

	-- Guard table to prevent infinite loops
	local guard = {}

	local function SetAttributeSafe(name, value)
		if guard[name] then return end
		guard[name] = true
		character:SetAttribute(name, value)
		guard[name] = false
	end

	local function unbindAll()
        print("unbindAll")
		for _, attr in pairs({ "CanDJ", "CanBlock", "CanDash", "CanParry", "CanPunch", "CanRun", "CanCrit",
			"Blocking", "Punching", "Parrying", "Running" }) do
			SetAttributeSafe(attr, false)
		end
	end

	local function rebindAll()
        print("rebindAll")
		for _, attr in pairs({ "CanDJ", "CanBlock", "CanDash", "CanParry", "CanPunch", "CanRun", "CanCrit" }) do
			SetAttributeSafe(attr, true)
		end
	end

	local function unbindPunching()
        print("unbindPunching")
		for _, attr in pairs({ "CanPunch", "CanCrit", "Punching" }) do
			print("PUNCHING NO MORE")
			SetAttributeSafe(attr, false)
		end
	end

	local function rebindPunching()
        print("rebindPunching")
		for _, attr in pairs({ "CanPunch", "CanCrit" }) do
			SetAttributeSafe(attr, true)
		end
	end

	local function _unbindBlocking()
         print("unbindBlocking")
		for _, attr in pairs({ "CanBlock", "CanParry", "Blocking", "Parrying" }) do
			SetAttributeSafe(attr, false)
		end
	end

	local function _rebindBlocking()
        print("rebindBlocking")
		for _, attr in pairs({ "CanBlock", "CanParry" }) do
			SetAttributeSafe(attr, true)
		end
	end

	local function _rebindAllCombat()
        print("_rebindAllCombat")
		for _, attr in pairs({ "CanBlock", "CanParry", "CanPunch", "CanCrit" }) do
			SetAttributeSafe(attr, true)
		end
	end

	local function _unbindAllCombat()
        print("_unbindAllCombat")
		for _, attr in pairs({ "CanBlock", "CanParry", "CanPunch", "CanCrit",
			"Blocking", "Parrying", "Punching" }) do
			SetAttributeSafe(attr, false)
		end
	end
    task.wait(3)
	for name, _ in pairs(character:GetAttributes()) do
		character:GetAttributeChangedSignal(name):Connect(function()
			if guard[name] then return end
			local value = character:GetAttribute(name)
			print(name, value)

			if value == true then
                print("ITS FUCKING TRUE")
				if name == "Punching" then
					unbindPunching()
					character:SetAttribute("Running", false)
				elseif name == "Running" then
					_unbindBlocking()
				elseif name == "Blocking" then
					unbindPunching()
				elseif name == "Parrying" or name == "Stunned" or name == "Downed" or name == "BeingCarried" then
                    print(name)
					
					character.Humanoid.JumpPower = 0 
					if name  == "Downed" then
						character.Humanoid.WalkSpeed = 3
					else
						character.Humanoid.WalkSpeed = 0 
					end
					unbindAll()

					elseif name == "Carrying" then
					_unbindAllCombat()
				end
			else
				if name == "Punching" then
					print(name)
					rebindPunching()
				elseif name == "Running" then
					print(name)
					_unbindBlocking()
				elseif name == "Blocking" then
					print(name) 
					rebindPunching() 
                    rebindAll()
				elseif name == "Parrying" or name == "Stunned" or name == "Downed" or name == "BeingCarried" then
                    print(name)

					character.Humanoid.JumpPower = 60  
					character.Humanoid.WalkSpeed = 15 

					rebindAll()
				elseif name == "Carrying" then
					print(name)
					_rebindAllCombat()
				end
			end
		end)
	end
end)
