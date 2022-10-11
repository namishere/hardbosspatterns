bpattern = RegisterMod("HMBP", 1)

HMBP = {
	--[[HasBit = function(value, find)
		local Found
		local v = value

		for i=62, 0, -1 do
			if v >= 1 << i then
				if 1 << i == 1 << find then
					Found = true
					break
				end
				v = v-(1 << i)
			end
		end

		if Found then
			return true
		end
	end,]]

	SpawnLaserWarn = function(P, To, A, C, Pr, Os, SS, Ls, E)
	--(Vector(float X, float Y) Position, int Timeout, float Angle, color Color, entity Parent, Vector Offset, Vector(float X, float Y) SpriteScale, int Lifespan, entity Entity)--
	--Sprite Scale and Entity parameter doesn't work with ab+
		if REPENTANCE then
			local LaserWarn = Isaac.Spawn(1000, 198, 0, P, Vector(0, 0), E):ToEffect() --Generic Tracer
			LaserWarn.Timeout = To
			LaserWarn.LifeSpan = Ls
			LaserWarn:GetSprite().Scale = SS
			LaserWarn.TargetPosition = Vector.FromAngle(A)
			LaserWarn.Color = C
			LaserWarn.Parent = Pr
			LaserWarn:Update()
		else
			local LaserWarn = EntityLaser.ShootAngle(7, P, A, To, Os, Pr) --Tractor Beam
			LaserWarn.SubType = 555
			LaserWarn:GetData().TracerScale = SS
			LaserWarn:GetData().CAlpha = C.A
			LaserWarn.Color = Color(C.R, C.G, C.B, 0, C.RO, C.GO, C.BO)
		end
	end,

	Codes = REPENTANCE and {include("boss"), include("boss2"), include("others")} or {require "boss", require "boss2", require "others"},
}

bpattern.sounds = {
		TVnoise = Isaac.GetSoundIdByName("TV Noise"),
		AngerScream = Isaac.GetSoundIdByName("Anger Scream")
    }

----------------------------

  --bpattern:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, low)
  --nspr = npc:GetSprite()

	--if collider:IsVulnerableEnemy() then
		--if npc.Type == 274 then
			--if npc.Variant > 0 and npc.Velocity:Length() >= 10
			--and collider.Type ~= 274 then
			--	collider:TakeDamage(20, 0, EntityRef(npc), 5)
			--end
		--elseif npc.Type == 399 then
			--if npc.Velocity:Length() >= 5 then
			--	collider:TakeDamage(25, 0, EntityRef(npc), 5)
			--end
		--elseif npc.Type == 70 and npc.Variant == 70 then
			--if nspr:GetFrame() > 20 then
			--	collider:TakeDamage(1.5, 0, EntityRef(npc), 1)
			--end
		--end
	--end

  --end)

  function bpattern:hit(entity,amount,damageflag,source,num)

	local enspr = entity:GetSprite()
	local edata = entity:GetData()
	local Entities = Isaac:GetRoomEntities()
	local player = Game():GetPlayer(1)
	local rng = entity:GetDropRNG()

	if Game().Difficulty % 2 == 1 then
		if (damageflag == 1<<2 and (entity.Type == 273 and source.Type == 9)) or (damageflag == 1<<2 and (entity.Type == 406 and source.Type == 9))
		or (entity.Type == 406 and (source.Type == 406 or (source.Type == 100 and source.Variant == 368))) or (entity.Type == 407 and source.Type == 506
		and source.Variant < 2) or (entity.Type == 412 and (source.Type == 1000 and source.Variant == 19 and source.SubType == 1)) then
			return false
		end
		if entity.Type == 45 and entity.Variant == 0 then
			if enspr:IsPlaying("EyeAttack") and enspr:GetFrame() <= 61 then
				edata.eyeHp = edata.eyeHp - amount
			end
		elseif entity.Type == 273 and entity.Variant == 0 then
			if amount >= 50000 and entity.HitPoints/entity.MaxHitPoints < 0.5 then
				edata.planc = true
			end
		elseif entity.Type == 275 and entity.Variant == 0 then
			if not edata.summonpattern
			and (amount >= entity.MaxHitPoints * 0.5
			or entity.HitPoints/entity.MaxHitPoints <= 0.5) then
				entity.HitPoints = entity.MaxHitPoints * 0.5
				return false
			end
		end
	end
	if (entity.Type == 102 and entity.Variant <= 1 and entity:ToNPC().State == 155) or entity.Type == 184 or (entity.Type == 102 and (not entity.Visible
	or (enspr:IsPlaying("4FBAttackStart") and entity.EntityCollisionClass == 0) or enspr:IsPlaying("4Evolve")))
	or (entity.Type == 275 and enspr:IsPlaying("Up")) or (entity.Type == 407 and enspr:IsFinished("DissapearLong")) or (entity.Type == 407 and edata.breathhold) then
		return false
	end
	if entity.Type == 406 and entity.Variant == 1 then
		if Game().Difficulty % 2 == 1 then
			if entity:ToNPC().State == 22 then
				edata.tripgauge = edata.tripgauge + amount
			end
		end
		if entity.EntityCollisionClass == 0 then
			return false
		end
	end
	if entity.Type == 412 and Game().Difficulty % 2 == 1 then
		if DlrCopiedPlrForm[2] and math.random(1,5) == 1 and #Isaac.FindByType(300, -1, -1, true, true) <= 6 then
			if denpnapi then
				local spore = Isaac.Spawn(9, 10, 999, entity.Position,
				Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(10,40)*0.1), entity):ToProjectile()
				spore.FallingSpeed = -math.random(17,80) * 0.1
				spore.Scale = math.random(10,20) * 0.1
				spore.Acceleration = 0.94
			else
				local spore = Isaac.Spawn(9, 0, 999, entity.Position,
				Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(10,40)*0.1), entity):ToProjectile()
				spore.FallingSpeed = -math.random(17,80) * 0.1
				spore.Scale = math.random(10,20) * 0.1
				spore.Acceleration = 0.94
				spore:SetColor(Color(1,1,1,5,0,0,0), 99999, 0, false, false)
			end
		end
		if DlrCopiedPlrForm[9] and math.random(1,3) == 1 and #Isaac.FindByType(217, 1, 412, true, true) <= 8 then
			local corn = Isaac.Spawn(217, 1, 412, entity.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(40,100)*0.1), entity)
			corn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			corn:GetSprite():Load("gfx/dip_corn_dlrform.anm2", true)
		end
	end

  end

  bpattern:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, bpattern.hit)

  function bpattern:Mom(mom)
	if Game().Difficulty % 2 == 1 and not mom:GetData().isdelirium then
		if mom.Variant == 0 then
			if HMBPENTS then
				mom:Morph(396, 0, mom.SubType, -1)
			end
		elseif mom.Variant == 10 then
			if HMBPENTS then
				mom:Morph(396, 10, mom.SubType, -1)
			end
		end
	end
  end

 function bpattern:Spider(enemy)
	if enemy.FrameCount == 1 and denpnapi then
		if enemy.SpawnerType == 608 then
			enemy:Morph(85, Isaac.GetEntityVariantByName("Hush Spider"), 0, -1)
		end
    end
  end

  function bpattern:GrdGaper(enemy)
	if Game().Difficulty == 3 and denpnapi then
		if math.random(0,7) == 1 and enemy.FrameCount == 0 then
			enemy:Morph(208, Isaac.GetEntityVariantByName("Greed Fatty"), 0, -1)
			enemy.HitPoints = enemy.MaxHitPoints
		end
	end
  end

  function bpattern:Bboil(enemy)
	if enemy.FrameCount == 1 and math.random(0,2) == 1 and denpnapi and enemy.SpawnerType == 407 then
		if Game().Difficulty % 2 == 1 then
			enemy:Morph(554, Isaac.GetEntityVariantByName("Hushling"), 0, -1)
			enemy.HitPoints = enemy.MaxHitPoints
		end
    end
  end

  --function bpattern:Dlr(boss)

  --end

bpattern:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, l) --Tractor Beam(Laserwarn)
	if l.SubType == 555 and l:GetData().CAlpha and l.FrameCount < 24 then
		local C = l.Color

		l.Color = Color(C.R, C.G, C.B, l:GetData().CAlpha * (l.FrameCount / 23), C.RO, C.GO, C.BO)
	end
end, 7)

  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Mom, 45)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Spider, 85)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Bboil, 298)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.GrdGaper, 299)
  --bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Dlr, 412)

bpattern:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	DlrHasExist = false
	DPhase = 5
	DlrHPIncrease = 0

    if #Isaac.FindByType(412, -1, -1, false, false) > 0 then
		AdultForm = false
		eye = 0
		wig = false
		StAttackReady = 0
    end
end)

local function warn()
	if (not denpnapi or not HMBPENTS)
	and (Game():GetFrameCount() <= 700 or Isaac.GetFrameCount() <= 700) then
		Isaac.RenderScaledText("!!Dot MOD Entity Pack or HMBP Entity Partition is not enabled!!", 120, 50, 0.5, 0.5, 255, 255, 255, 0.5)
		Isaac.RenderScaledText("Bosses's Some MOD additional Attacks or Phases will be omitted.", 120, 60, 0.5, 0.5, 255, 255, 255, 0.5)
	end
end

bpattern:AddCallback(ModCallbacks.MC_POST_RENDER, warn)
