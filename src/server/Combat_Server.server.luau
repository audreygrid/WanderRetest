--variables
local events = game.ReplicatedStorage.Events

--events
--		cariate
events.Carriate.OnServerEvent:Connect(function(plr)

	local _Plr = plr.Character

	events.Carriate:FireAllClients(plr) 
end)

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

local function SendSound(Plr, sound)
	local S = Instance.new("Sound")
	S.Parent = Plr
	S.SoundId = "rbxassetid://"..tostring(sound)
	S.Playing = true
	game.Debris:AddItem(S,1)
end



events.RemoveCarry.OnServerEvent:Connect(function(plr)
    
    events.RemoveCarry:FireAllClients()
end)
--		carry
events.Carry.OnServerEvent:Connect(function(plr, char)
	events.RemoveCarry:FireAllClients()
	local Plr = plr.Character
	local PP = Plr.HumanoidRootPart:FindFirstChild("Carry")
	if PP then PP:Destroy() end;
	local CF;
	for i, v in pairs(char:GetChildren()) do
		
		if v:IsA("BasePart") then
			
			v.Massless = true
		end
	end
	local function CarryPlayer()
		local _Connection
		events.RemoveCarry:FireAllClients()
		events.RemoveExe:FireAllClients()
		CF = Plr.PrimaryPart.CFrame * CFrame.new(2,.5,0);
		char.HumanoidRootPart.CFrame = CF
		local Part = Instance.new("Part"); 
		Part.Anchored = false
		Part.Transparency=1
		Part.CanCollide = false
		Part.Parent = workspace
		Part.CFrame = CF
		local Weld = Instance.new("WeldConstraint", Plr.PrimaryPart)
		Weld.Part0 = Plr.PrimaryPart
		Weld.Part1 = Part
		local Weld1 = Instance.new("WeldConstraint", Part)
		Weld1.Part0 = Part
		Weld1.Part1 = char.HumanoidRootPart
		char:SetAttribute("BeingCarried", true)
		Plr:SetAttribute("Carrying", true)
		local c
		c = char:GetAttributeChangedSignal("Downed"):Connect(function()
			if char:GetAttribute("Downed") == false then
				char:SetAttribute("BeingCarried", false)
				Plr:SetAttribute("Carrying", false)
				Part:Destroy();
				Weld:Destroy();
				Weld1:Destroy();
				c:Disconnect(); 
				
				for i, v in pairs(char:GetChildren()) do

					if v:IsA("BasePart") then

						v.Massless = false
					end
				end
				print(Part, Weld, Weld1)

			end
		end)
	end
	CarryPlayer();
end)

--		exate
events.Exate.OnServerEvent:Connect(function(plr)

	local _Plr = plr.Character

	events.Exate:FireAllClients(plr)
end)
--		execute
events.Execute.OnServerEvent:Connect(function(plr, char)
	events.RemoveCarry:FireAllClients()
	events.RemoveExe:FireAllClients()
	local _Plr = plr.Character
	local PP = char.HumanoidRootPart:FindFirstChild("Execute")

	if PP then PP:Destroy() end;
	local _CF;
	local function ExecutePlayer()  
		char.Humanoid.Health = 0;
	end
	ExecutePlayer();
end)

--m1s
events.Attack.OnServerEvent:Connect(function(plr, CF, SI, index)
	

	print("server side")
 
	local function IsBehind(playerA, playerB)
		local charA = playerA
		local charB = playerB

		if not (charA and charB and charA:FindFirstChild("HumanoidRootPart") and charB:FindFirstChild("HumanoidRootPart")) then
			return false
		end

		local posA = charA.HumanoidRootPart.Position
		local posB = charB.HumanoidRootPart.Position
		local lookB = charB.HumanoidRootPart.CFrame.LookVector

		local toA = (posA - posB).Unit
		local dot = lookB:Dot(toA)

		-- dot < 0 means playerA is behind playerB
		return dot < -0.5 -- adjust threshold to control strictness
	end
	
	print("HitBOx")
	local Bounds = workspace:GetPartBoundsInBox(CF, SI)

	local hums = {}

	local function Stun(Par)
		print("Stunners")
		Par:SetAttribute("Stunned", true)
        task.wait(2)
        Par:SetAttribute("Stunned", false)
	end
	for i, part in pairs(Bounds) do
		local hum = part.Parent:FindFirstChild("Humanoid")
		
		if hum and  part.Parent ~= plr.Character then
			
			if not table.find(hums, hum) then
				
				
				table.insert(hums, hum)
				
				
				local behind = IsBehind(plr.Character,part.Parent)
				print(behind) 
				
				local target = part.Parent
				
				if not target:GetAttribute("Blocking") then
					
					print("not blocking")
					pcall(function()
						SendSound(target, Sounds["Hit"]..tostring(index))
					end)
					
					if target.Humanoid.Health >=15 then
						
						target.Humanoid:TakeDamage(14) 
					end
				elseif not target:GetAttribute("Parrying") then
					
					if behind then
						
						print("Block break")
						pcall(function()
							SendSound(target, Sounds["Hit"]..tostring(index))
						end)
						local player = game.Players:GetPlayerFromCharacter(target)
						events.BlockBrake:FireClient(player) 
						Stun(target)
					else
						
						if part.Parent:GetAttribute("Posture") >0 then
							
							part.Parent:SetAttribute("Posture", part.Parent:GetAttribute("Posture")-10) 
						else
							pcall(function()
								SendSound(target, Sounds["Hit"]..tostring(index))
							end)
							Stun(target)
						end
					end
					
				elseif target:GetAttribute("Parrying") then
					local H = Instance.new("Highlight")
					H.Parent= plr.Character
					H.FillColor = Color3.new(255,255,255)
					H.OutlineTransparency=  1
					game.Debris:AddItem(H,2)
					Stun(target)
					
				end
				 
			end
		end
	end
	--return hums
end)


events.CriticalAttack.OnServerEvent:Connect(function(plr, CF, SI, DMG)


	print("server side")

	local function IsBehind(playerA, playerB)
		local charA = playerA
		local charB = playerB

		if not (charA and charB and charA:FindFirstChild("HumanoidRootPart") and charB:FindFirstChild("HumanoidRootPart")) then
			return false
		end

		local posA = charA.HumanoidRootPart.Position
		local posB = charB.HumanoidRootPart.Position
		local lookB = charB.HumanoidRootPart.CFrame.LookVector

		local toA = (posA - posB).Unit
		local dot = lookB:Dot(toA)

		-- dot < 0 means playerA is behind playerB
		return dot < -0.5 -- adjust threshold to control strictness
	end

	print("HitBOx")
	local Bounds = workspace:GetPartBoundsInBox(CF, SI)

	local hums = {}

	local function Stun(Par)
		print("Stunners")
		Par:SetAttribute("Stunned", true)
	end
	for i, part in pairs(Bounds) do
		local hum = part.Parent:FindFirstChild("Humanoid")

		if hum and  part.Parent ~= plr.Character then

			if not table.find(hums, hum) then


				table.insert(hums, hum)


				local behind = IsBehind(plr.Character,part.Parent)
				print(behind) 

				local target = part.Parent

				if not target:GetAttribute("Blocking") then

					print("not blocking")

					if target.Humanoid.Health >=30 then

						target.Humanoid:TakeDamage(DMG) 
					end
				elseif not target:GetAttribute("Parrying") then

					part.Parent:SetAttribute("Posture",0) 

				elseif target:GetAttribute("Parrying") then
					local H = Instance.new("Highlight")
					H.Parent= plr.Character
					H.FillColor = Color3.new(255,255,255)
					H.OutlineTransparency=  1
					game.Debris:AddItem(H,2)
					Stun(target)

				end

			end
		end
	end
	--return hums
end)


game.ReplicatedStorage.Events.ChangeAttribute.OnServerEvent:Connect(function(plr, At, state)

	plr.Character:SetAttribute(At, state)
end)


events.Sound.OnServerEvent:Connect(function(plr, sound)
	
	local S = Instance.new("Sound")
	S.Parent = plr.Character
	S.SoundId = "rbxassetid://"..tostring(sound)
	S.Playing = true
	game.Debris:AddItem(S,1)
end)