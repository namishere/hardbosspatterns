local sound = SFXManager()
local Level = Game():GetLevel()

----------------------------
--Projectile:Pupula
----------------------------
  denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, p)
  if p.Variant == Isaac.GetEntityVariantByName("Pupula Projectile") or p.Variant == Isaac.GetEntityVariantByName("Pupula Tear Projectile") then
  	local sprppl = p:GetSprite()
	local data = p:GetData()

	--V1.X:Replace EntityProjectile class's FallingSpeed.
	--V1.Y:Replace EntityProjectile class's FallingAccel.
	--PositionOffset.Y:Replace EntityProjectile class's Height.

	if (p.V1.Y >= 0 and p.V1.X < 0) or (p.V1.Y <= 0 and p.V1.X > 0) then
		p.V1 = Vector(p.V1.X * 0.9, p.V1.Y)
	end

	if (p.V1.Y >= 0 and p.V1.X < p.V1.Y * 10) or (p.V1.Y <= 0 and p.V1.X > p.V1.Y * 10) then
		p.V1 = Vector(p.V1.X + p.V1.Y, p.V1.Y)
	end

	data.anino = math.min(math.ceil((data.PNPCScale / (1 / 3)) + 2), 13)
	p.PositionOffset = Vector(p.PositionOffset.X, p.PositionOffset.Y+p.V1.X)
	p.SpriteRotation = p.Velocity:GetAngleDegrees()

	if p.MaxHitPoints ~= data.PNPCScale * 7.5 then
		p.HitPoints = (p.HitPoints / p.MaxHitPoints) * (7.5*data.PNPCScale)
		p.MaxHitPoints = 7.5 * data.PNPCScale
	end

	if p.Size ~= data.PNPCScale*5 then
		p.Size = data.PNPCScale*5
	end

	if data.anino > 12 then
		p.Scale = data.PNPCScale / (10/3)
	else
		if p.Scale ~= 1 then p.Scale = 1 end
	end

	if not sprppl:IsPlaying("RegularTear"..data.anino) then
		sprppl:Play("RegularTear"..data.anino, true)
	end

	if p:CollidesWithGrid() or p:IsDead() or p.PositionOffset.Y >= 0 then
		data.burst = true

		if p.PositionOffset.Y < 0 then
			data.collision = true
		else
			p.PositionOffset = Vector(p.PositionOffset.X, 0)
		end
	end

	if data.burst then
		p:Remove()

		if data.collision then
			p:PlaySound(150, 1, 0, false, 1) --TEARIMPACTS
		else
			p:PlaySound(258, 1, 0, false, 1) --SPLATTER
		end

		local bpoof = Isaac.Spawn(1000, math.random(12,13), 0, p.Position, Vector(0,0), p)
		bpoof:GetSprite().Offset = Vector(p.PositionOffset.X, p.PositionOffset.Y*0.65)
		bpoof:GetSprite().Scale = Vector(data.PNPCScale, data.PNPCScale)
	end
  end
end, 557)

denpnapi:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, p)
	if p.Variant == Isaac.GetEntityVariantByName("Pupula Projectile") or p.Variant == Isaac.GetEntityVariantByName("Pupula Tear Projectile") then
		p.PositionOffset = Vector(0,-20)
		p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		p:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_HIDE_HP_BAR)
		p.EntityCollisionClass = 2
		p.GridCollisionClass = 6
		p.SizeMulti = Vector(0.5, 1)
		p.V1 = Vector(-0.5, 0.1)
		p:GetData().PNPCScale = 1
	end
end, 557)

denpnapi:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,p,amount,damageflag,source,num)
	if p.Variant == Isaac.GetEntityVariantByName("Pupula Projectile") or p.Variant == Isaac.GetEntityVariantByName("Pupula Tear Projectile") then
		if damageflag == DamageFlag.DAMAGE_EXPLOSION or amount >= p.HitPoints then
			p:GetData().burst = true
			return false
		end
	end
end, 557)

denpnapi:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, low)
	if npc.Variant == Isaac.GetEntityVariantByName("Pupula Projectile") or npc.Variant == Isaac.GetEntityVariantByName("Pupula Tear Projectile") then
		if collider.Type <= 2 or (collider.Type == 3 and
		(collider.Variant == 3 or collider.Variant == 17 or (collider.Variant >= 30
		and collider.Variant <= 35) or collider.Variant == 42 or (collider.Variant >= 44
		and collider.Variant <= 47) or collider.Variant == 50 or collider.Variant == 51
		or collider.Variant == 60 or collider.Variant == 62 or collider.Variant == 65
		or collider.Variant == 67 or collider.Variant == 68 or (collider.Variant >= 69
		and collider.Variant <= 72) or collider.Variant == 75 or (collider.Variant >= 83
		and collider.Variant <= 85) or (collider.Variant == 87 and collider:ToFamiliar().State == 1)
		or collider.Variant == 95 or collider.Variant == 98 or collider.Variant == 103
		or collider.Variant == 104 or collider.Variant == 107 or collider.Variant == 116
		or collider.Variant == 121)) then
			if collider.Type == 2 then
				if collider:ToTear().TearFlags < TearFlags.TEAR_PIERCING then
					collider:Die()
				end
				npc.Velocity = Vector(npc.Velocity.X+collider.Velocity.X*(collider:ToTear().BaseDamage*0.045),
				npc.Velocity.Y+collider.Velocity.Y*(collider:ToTear().BaseDamage*0.045))
			else
				npc:GetData().Poof = true
			end
		end
	end
  end, 557)

----------------------------
--Projectiles
----------------------------
function denpnapi:proj(p)
	if p.SpawnerType == 1000 and p.SpawnerVariant == 354 and p.FrameCount == 1 then
		local Room = Game():GetRoom()
		if Room:GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 then
			p:SetColor(Color(0,0,0,1,60,0,0), 99999, 0, false, false)
		else
			p:SetColor(Color(0,0,0,1,0,0,0), 99999, 0, false, false)
		end
	end
end

  function denpnapi:stoneproj(p)
	local pspr = p:GetSprite()
	local Room = Game():GetRoom()
	if Room:GetBackdropType() == 3 then
		p:SetColor(Color(0.6,0.35,0.35,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 6 then
		p:SetColor(Color(0.3,0.45,0.5,1,0,0,0), 99999, 0, false, false)
	elseif Room:GetBackdropType() == 7 or Room:GetBackdropType() == 9
	or Room:GetBackdropType() == 14 or Room:GetBackdropType() == 16 then
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
	if p.ProjectileFlags ~= 1 << 1 and p:IsDead() then
		Game():SpawnParticles(p.Position, 35, 8, 5, Color(p:GetColor().R*0.7,p:GetColor().G*0.7,p:GetColor().B*0.7,1,0,0,0), p.Height)
	end
  end

function denpnapi:others(p)
	if p.SpawnerType == 554 and p.SpawnerVariant == Isaac.GetEntityVariantByName("Hushling") and p:IsDead() then
		p.Velocity = Vector(7, 0)
	end
end

  denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, denpnapi.PplaProj, 552)
  denpnapi:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, denpnapi.proj)
  --denpnapi:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, denpnapi.stoneproj, 9)
  denpnapi:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, denpnapi.others)
