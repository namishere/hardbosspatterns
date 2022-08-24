local sound = SFXManager()
local Level = Game():GetLevel()

function bpattern:Mushroom(enemy)
	if enemy.Variant == Isaac.GetEntityVariantByName("Mushroom")
	and enemy:GetSprite():GetFilename() == "gfx/mushroomman_dlrform.anm2" then
		local sprmsr = enemy:GetSprite()
		enemy.SplatColor = Color(1,1,1,1,255,255,255)
		if (sprmsr:IsPlaying("Reveal") or sprmsr:IsPlaying("Hide"))
		and sprmsr:GetFrame() == 4 then
			Game():SpawnParticles(enemy.Position+Vector(0,1), 111, 8, 5, Color(1,1,1,1,255,255,255), -23)
		end
	end
end

function bpattern:Others()
	local Entities = Isaac:GetRoomEntities()

	for k, v in pairs(Entities) do
		local enspr = v:GetSprite()
		if v.Type == 38 then
			if (v.FrameCount == 30 and v.SpawnerType == 102) or v.SpawnerType ~= 102 then
				v.CollisionDamage = 1
			end
		end
		if denpnapi then
			if v.Type == 102 and v.HitPoints <= 0 then
				if denpnapi then
					if (enspr:IsPlaying("Death") or enspr:IsPlaying("Death2")) and enspr:GetFrame() >= 20 and enspr:GetFrame() % 2 == 0 then
						Game():SpawnParticles(v.Position, Isaac.GetEntityVariantByName("Feather Particle"), math.random(3,7), 33 - enspr:GetFrame(),
						Color(1,1,1,1,0,0,0), (enspr:GetFrame()-20)*-50)
					end

					if (Game().Difficulty == 1 or Game().Difficulty == 3) and v.Variant <= 1 then
						if enspr:IsPlaying("Death") then
							enspr:SetLastFrame()
						elseif enspr:IsFinished("Death") then
							enspr:Play("Death2", true)
						end
					end
				end
			end
		end
	end
end

function bpattern:Others2()
	local Entities = Isaac:GetRoomEntities()
	for k, v in pairs(Entities) do
		local enspr = v:GetSprite()
		local npc = v:ToNPC()
		if v.Type == 217 and enspr:GetFilename() == "gfx/dip_corn_dlrform.anm2" then
			v.SplatColor = Color(1,1,1,1,255,255,255)
		end
	end
end

function bpattern:Others3()
	local Entities = Isaac:GetRoomEntities()
	for k, v in pairs(Entities) do
		local enspr = v:GetSprite()
		if #Isaac.FindByType(275, 0, 0, true, true) > 0 and v:IsVulnerableEnemy()
		and v.Type ~= 275 and v.Type ~= 399 then
			if v.Position.Y <= 340 + v.Size and v.Velocity.Y <= 0 then
				v.Velocity = Vector(v.Velocity.X,-v.Velocity.Y*0.5)
				v.Position = Vector(v.Position.X, 340 + v.Size)
			end
		end
	end
end

function bpattern:Lasers(l)
	local sprls = l:GetSprite()

	if ((not REPENTANCE and l.Variant == 1 and l.Size >= 80) or (REPENTANCE and l.Variant == 6)) then
		if l.SpawnerType == 406 then
			if math.random(1,2) == 1 and l.Timeout > 0 then
				local cproj = Isaac.Spawn(9, 7, 0, l.Position + Vector.FromAngle(l.Angle):Resized(l.LaserLength-80),
				Vector.FromAngle(l.Angle+math.random(0,180)+90):Resized(10), l):ToProjectile()
				cproj.FallingAccel = -0.09
			end
		else
			if not HMBPENTS then
				if sprls:GetFilename() ~= "gfx/giant red laser.anm2" then
					sprls:Load("gfx/giant red laser.anm2", true)
					sprls:Play("LargeRedLaser", true)
				end
				if l.FrameCount <= 2 and l.SpawnerType ~= 407 then
					sound:Stop(5)
					sound:Play(239, 1, 0, false, 1)
				end
			end
		end
	end
end

function bpattern:Effects(eft)
	if eft.Variant == 5 and eft.SpawnerType == 412 then
		eft:SetColor(Color(1,1,1,1,150,150,150), 99999, 0, false, false)
	elseif eft.Variant == 10 and eft.SpawnerType == 273 and eft.SpawnerVariant == 0 then
		if eft.Parent and not eft.Parent.Child then
			eft.Parent.Child = eft
		end
	end
end

  --function bpattern:GetShaderParams(shaderName)
	--return {
		--Strength = intensity,
		--Time = Isaac.GetFrameCount()
	--}
--end

bpattern:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function (_, p) --HMBP Projectile Flags
	if p:GetData().ChangeAngleAfterTimeout and p.FrameCount >= p.ChangeTimeout then
		p:GetData().ChangeAngleAfterTimeout = false
		p.Velocity = Vector.FromAngle(p:GetData().ChangeAngle):Resized(p.Velocity:Length())
	end
end)

function bpattern:projs(p)
	if p:IsDead() then
		if p.Variant == 4 and p.Velocity:Length() == 0
		and p.SpawnerType == 102 and p.SpawnerVariant == 0 then
			p.Velocity = Vector(8, 0)
			p.FallingAccel = -0.055
		end
		if p.SpawnerType == 412 then
			if p.SubType == 999 and DlrCopiedPlrForm[2] then
				sound:Play(265, 1, 0, false, 1)
				local mush = Isaac.Spawn(300, 0, 0, p.Position, Vector(0,0), p)
				mush:GetSprite():Load("gfx/mushroomman_dlrform.anm2", true)
				mush:GetSprite():Play("Hide", true)
			end
			if DlrCopiedPlrForm[0] and math.random(1,2) == 1
			and #Isaac.FindByType(18, -1, -1, true, true) <= 12 then
				local fly = Isaac.Spawn(18, 0, 0, p.Position, Vector(0,0), p)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
	end
	if p.Variant ~= 10 and #Isaac.FindByType(412, -1, -1, true, true) > 0
	and DlrCopiedPlrForm[5] and p.FrameCount == 1 then
		if math.random(1,3) == 1 then
			p:AddProjectileFlags(1 << 25+math.random(1,2)*5)
		else
			p:AddProjectileFlags(1 << math.random(21,23))
		end
	end
end

  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Mushroom, 300)
  bpattern:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, bpattern.Effects)
  bpattern:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, bpattern.projs)
  bpattern:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, bpattern.Lasers)
  bpattern:AddCallback(ModCallbacks.MC_POST_UPDATE, bpattern.Others)
  bpattern:AddCallback(ModCallbacks.MC_POST_UPDATE, bpattern.Others2)
  bpattern:AddCallback(ModCallbacks.MC_POST_UPDATE, bpattern.Others3)

 -- bpattern:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, bpattern.GetShaderParams)

--local function hallu()
	--Isaac.RenderScaledText("hallucination:"..Game():HasHallucination(), 150, 50, 0.5, 0.5, 255, 255, 255, 1)
--end

--bpattern:AddCallback(ModCallbacks.MC_POST_RENDER, hallu)
