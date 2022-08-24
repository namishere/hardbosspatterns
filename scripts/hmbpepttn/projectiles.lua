local snd = SFXManager()
local Level = Game():GetLevel()

----------------------------
--Projctiles
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.CURVE2) then
		local data = p:GetData()

		if not data.Curve then
			data.Curve = 5000 -- > 0 = Right, < 0 = Left
		end

		if p.FrameCount % 30 == 0 then
			data.Curve = math.random(0, 1) == 1 and 5000 or -5000
		end

		p.Velocity = Vector.FromAngle(p.Velocity:GetAngleDegrees() + p.CurvingStrength * data.Curve):Resized(p.Velocity:Length())
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.NOFALL) then
		p.FallingSpeed = 0
		p.FallingAccel = 0
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and p:GetData().ChangeHMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT)
	and p.FrameCount == p.ChangeTimeout and p:GetData().HMBPEntsBFlags ~= p:GetData().ChangeHMBPEntsBFlags then
		p:GetData().HMBPEntsBFlags = p:GetData().ChangeHMBPEntsBFlags
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.SMART2) then
		local pd = p:GetData()
		local pl = Game():GetPlayer(1)
		p:SetColor(Color(1,1,1,5,0,0,0), 99999, 0, false, false)
		if not pd.smart2 then
			pd.smart2 = true
			pd.homingtime = 20
		end
		pd.homingtime = pd.homingtime - 1
		if pd.homingtime > 0 then
			initspeed = p.Velocity
			p.Velocity = (initspeed * 0.9) + Vector.FromAngle
			((pl.Position - p.Position):GetAngleDegrees()):Resized(p.HomingStrength*3)
		end
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.GRAVITY_VERT) then
		local Room = Game():GetRoom()
		local pd = p:GetData()
		local ge = Room:GetGridEntity(Room:GetGridIndex(p.Position + Vector(0,p.Velocity.Y)))

		if not pd.gravity then
			if p.Velocity.Y > 0 then
				pd.gravity = 1
			else
				pd.gravity = -1
			end
		end

		p.Velocity = Vector(p.Velocity.X, p.Velocity.Y + (pd.gravity * 0.15))

		if ge and ((ge:GetType() > 1 and ge:GetType() < 7) or (ge:GetType() > 10 and ge:GetType() < 16) or ge:GetType() >= 21) then
			if p.Velocity.Y > 9 then
				p.Velocity = Vector(p.Velocity.X, -9)
			elseif p.Velocity.Y < -9 then
				p.Velocity = Vector(p.Velocity.X, 9)
			else
				p.Velocity = Vector(p.Velocity.X, -p.Velocity.Y)
			end
		end
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.TURN_RIGHTANGLE) then
		if p.FrameCount % 35 == 0 and p.FrameCount > 0 then
			p.Velocity = Vector.FromAngle((p.Velocity):GetAngleDegrees()+(math.random(-1,1)*90)):Resized(p.Velocity:Length())
		end
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.BURST_BLOODVESSEL) then
		local d = p:GetData()
		if not d.burstcount then
			d.burstcount = 0
		end
		if p.FrameCount > 25 + math.random(0, 20) and d.burstcount < 6 then
			d.GAD = math.floor(p.Velocity:GetAngleDegrees())
			for i=0, 1 do
				local prj = Isaac.Spawn(9, p.Variant, 0, p.Position, Vector.FromAngle((p.Velocity:GetAngleDegrees()
				+(((d.GAD % 17)+1)*5)*((d.GAD % 2)-((d.GAD % 2)-1))*i)):Resized(p.Velocity:Length()), p):ToProjectile()
				prj:AddProjectileFlags(1 << 18+i | 1 << 32)
				prj.CurvingStrength = (d.GAD % 10)/1000
				prj.ChangeFlags = 0
				prj:GetData().HMBPEntsBFlags = HMBPEnts.ProjFlags.BURST_BLOODVESSEL
				prj.ChangeTimeout = ((d.GAD % 3)*5)+20
				prj.Height = p.Height
				prj.FallingSpeed = p.FallingSpeed
				prj.FallingAccel = p.FallingAccel
				prj:GetData().burstcount = d.burstcount + 1
				if p.Scale > 1 then
					prj.Scale = p.Scale * 0.9
				else
					prj.Scale = prj.Scale
				end
			end
			snd:Play(30, 1, 0, false, 1)
			p:Die()
		end
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ntt)
	if ntt.Type == 9 and ntt:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(ntt:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.LEAVES_ACID) then
		local creep = Isaac.Spawn(1000, 22, 0, ntt.Position, Vector(0,0), ntt)
		creep.SpriteScale = Vector(2, 2)

		if ntt.Variant == 4 then
			local DIV = REPENTANCE and 255 or 1

			creep.Color = Color(1, 1, 1, 1, 19 / DIV, 208 / DIV, 255 / DIV)
		end

		creep:Update()
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.WAVE) then
		local pd = p:GetData()
		if not pd.sine then
			pd.sine = 0
			end
		if not pd.back then
			pd.sine = pd.sine + 0.08
		else
			pd.sine = pd.sine - 0.2
		end
		if pd.sine >= 0.8 then
			pd.back = true
		elseif pd.sine <= -2 then
			pd.back = false
		end
		p.Position = p.Position + Vector.FromAngle(p.Velocity:GetAngleDegrees())
		:Resized(p.Velocity:Length()*pd.sine)
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	if p:GetData().HMBPEntsBFlags and HMBPEnts.HasBit(p:GetData().HMBPEntsBFlags, HMBPEnts.ProjFlags.BLACKCIRCLE) then
		local Room = Game():GetRoom()

		if Room:GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 then
			p:SetColor(Color(0, 0, 0, 1, 45 / (REPENTANCE and 255 or 1), 0, 0), 99999, 0, false, false)
		else
			p:SetColor(Color(0,0,0,1,0,0,0), 99999, 0, false, false)
		end

		if p:IsDead() then
			p:Remove()
			local bcircle = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Black Circle Warn"), 0, p.Position, Vector(0,0), p):ToEffect()
			bcircle.Scale = p.Scale * 0.5
		end
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	local pspr = p:GetSprite()
	local Room = Game():GetRoom()

	if Room:GetBackdropType() == 3 then
		p:SetColor(Color(0.6,0.35,0.35,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 6 then
		p:SetColor(Color(0.3,0.45,0.5,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 or Room:GetBackdropType() == 16 then
		p:SetColor(Color(0.3,0.3,0.3,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 12 then
		p:SetColor(Color(0.75,0.25,0.25,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 13 then
		p:SetColor(Color(0.5,0.6,1,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 15 then
		p:SetColor(Color(0.35,0.45,0.55,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 24 then
		p:SetColor(Color(0.9,0,0,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 27 then
		p:SetColor(Color(0.5,0.6,1,1,0,0,0), 99999, 0, false, false)
	else
		p:SetColor(Color(0.75,0.6,0.6,1,0,0,0), 99999, 0, false, false)
	end

	p.SpriteScale = Vector(p.Scale,p.Scale)

	if p.FrameCount >= 1 and not pspr:IsPlaying("Move") then
		pspr:Play("Move", true)
	end
end, 999)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	local pspr = p:GetSprite()
	local pd = p:GetData()

	pd.anino = math.ceil((p.Scale/(1/3))+2.000001)

	if not pspr:IsPlaying("RegularTear"..pd.anino) then
		pspr:Play("RegularTear"..pd.anino, true)
	end

	--[[if p.ProjectileFlags ~= 1 << 1 and (p.Height >= -5 or (p:CollidesWithGrid() and p.Height >= -50)) then
		--SFXManager():Play(258, 1, 0, false, 1)
		local bpoof = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Bullet Poof(Delirium)"), 0, p.Position, Vector(0,0), p)
		bpoof:GetSprite().Offset = Vector(0, p.Height)
		bpoof.SpriteScale = Vector(p.Scale, p.Scale)
		bpoof:SetColor(p:GetColor(), 99999, 0, false, false)
	end]]
end, Isaac.GetEntityVariantByName("Delirium Projectile"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ntt)
	if ntt.Variant == Isaac.GetEntityVariantByName("Delirium Projectile") and ntt:ToProjectile().ProjectileFlags ~= 1 << 1 then
		local p = ntt:ToProjectile()

		SFXManager():Play(150, 1, 0, false, 1)

		local bpoof = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Bullet Poof(Delirium)"), 0, p.Position, Vector(0,0), p)
		bpoof:GetSprite().Offset = Vector(0, p.Height)
		bpoof.SpriteScale = Vector(p.Scale, p.Scale)
		bpoof.Color = p:GetColor()
	end
end, 9)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
	local pspr = p:GetSprite()
	local pd = p:GetData()

	if not pspr:IsPlaying("Move") then
		pspr:Play("Move", true)
	end

	p:SetSize(40, Vector(1, 0.5),0)
	p.SpriteRotation = p.Velocity:GetAngleDegrees()
	p.SpriteOffset = Vector(0, -10)

	for k, v in pairs(Isaac:GetRoomEntities()) do
		if p.SpawnerType == 396 and v:IsVulnerableEnemy() and not v:IsBoss() and v.Position:Distance(p.Position) <= p.Size+v.Size then
			v:Kill()
		end
	end
end, Isaac.GetEntityVariantByName("Knife Projectile"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, e)
	if e:ToProjectile().ProjectileFlags ~= 1 << 1 and (e.Variant == 999 or e.Variant == Isaac.GetEntityVariantByName("Knife Projectile")) then
		local p = e:ToProjectile()
		if e.Variant == 999 then
			Game():SpawnParticles(p.Position, 35, 8, 5, Color(p:GetColor().R*0.7,p:GetColor().G*0.7,p:GetColor().B*0.7,1,0,0,0), p.Height)
		elseif e.Variant == Isaac.GetEntityVariantByName("Knife Projectile") then
			snd:Play(138, 1, 0, false, 1)
			local impact = Isaac.Spawn(1000, 97, 0, p.Position, Vector(0,0), p)
			impact.SpriteScale = Vector(p.Scale, p.Scale)
			Game():SpawnParticles(p.Position+Vector.FromAngle(p.SpriteRotation):Resized(-40), 27, 10, 3, Color(1,1,1,1,0,0,0), p.Height)
			Game():SpawnParticles(p.Position+Vector.FromAngle(p.SpriteRotation):Resized(40), 35, 20, 6, Color(0.7,0.7,0.7,1,0,0,0), p.Height)
		end
	end
end, 9)
