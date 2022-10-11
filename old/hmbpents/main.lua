HMBPENTS = RegisterMod("HMBPEntPartition",1)

local Level = Game():GetLevel()

HMBPEnts = {
	Codes = REPENTANCE and {
		include("bossmain"),
		include("effects"),
		include("projectiles"),
		include("other_entities")
	} or {
		require("bossmain"),
		require("effects"),
		require("projectiles"),
		require("other_entities")
	},
	--require "rooms"

	HasBit = function (value, find)
		local Found
		local v = value

		for i=62, 0, -1 do
			if v >= 1<<i then
				if 1<<i == find then
					Found = true
					break
				end

				v = v-(1<<i)
			end
		end

		if Found then
			return true
		end
	end,

	--[[LaserFlag = {
	},]]

	ProjFlags = {
		BLACKCIRCLE = 1,
		WAVE = 1 << 1,
		LEAVES_ACID = 1 << 2,
		BURST_BLOODVESSEL = 1 << 3,
		TURN_RIGHTANGLE = 1 << 4,
		CURVE2 = 1 << 5,
		GRAVITY_VERT = 1 << 6,
		SMART2 = 1 << 7,
		CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT = 1 << 8,
		NOFALL = 1 << 9
	},

	musics = {
		MomLastDitch = Isaac.GetMusicIdByName("Mom's Last Ditch")
	},
}

function HMBPEnts.FireProjectile(entity, Variant, Position, Velocity, PParams)
	local HasCharm = entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and ProjectileFlags.HIT_ENEMIES or 0
	--Returns HIT_ENEMIES for ProjectileFlags if entity has CHARM flag or 0 if not.
	local HasFriendly = entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and ProjectileFlags.CANT_HIT_PLAYER or 0
	--Returns CANT_HIT_PLAYER for ProjectileFlags if entity has FRIENDLY flag or 0 if not.

	local proj = Isaac.Spawn(9, Variant, 0, Position, Velocity, entity):ToProjectile()
	proj.Acceleration = PParams.Acceleration
	proj.ChangeFlags = PParams.ChangeFlags
	proj.ChangeVelocity = PParams.ChangeVelocity
	proj.ChangeTimeout = PParams.ChangeTimeout
	proj.Color = PParams.Color
	proj.CurvingStrength = PParams.CurvingStrength
	proj.DepthOffset = PParams.DepthOffset
	proj.FallingAccel = PParams.FallingAccelModifier
	proj.FallingSpeed = PParams.FallingSpeedModifier
	proj:GetData().HMBPEntsBFlags = PParams.HMBPBulletFlags
	proj:GetData().ChangeHMBPEntsBFlags = PParams.ChangeHMBPEntsBFlags
	proj.Height = -23 + PParams.HeightModifier
	proj.HomingStrength = PParams.HomingStrength
	proj.Parent = PParams.Parent and PParams.Parent or (entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and entity or nil)
	proj.ProjectileFlags = HasCharm | HasFriendly | PParams.BulletFlags
	proj.Scale = PParams.Scale
	proj.WiggleFrameOffset = PParams.WiggleFrameOffset
	--proj:GetData().PlanetStartAngle = PParams.PlanetStartAngle
end

function HMBPEnts.ProjParams()
	return {
		HeightModifier = 0,
		FallingSpeedModifier = 0,
		FallingAccelModifier = 0,
		HomingStrength = 1,
		CurvingStrength = 0.006,
		Acceleration = 1,
		WiggleFrameOffset = 0,
		ChangeFlags = 0,
		ChangeHMBPEntsBFlags = 0,
		ChangeVelocity = 0,
		ChangeTimeout = 0,
		Scale = 1,
		BulletFlags = 0,
		HMBPBulletFlags = 0,
		DepthOffset = 0,
		--PlanetStartAngle = 0,
		--NumChildProj = 0, --Number of child projectiles to be spawned. Uses at SATURNUS projectile flag.
		Parent = nil,
		Color = Color(1, 1, 1, 1, 0, 0, 0)
	}
end

---------------------------------
--HMBPENTS:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, cld, low)
  --local nspr = npc:GetSprite()
  --local ndata = npc:GetData()
  --local clspr = cld:GetSprite()
  --local angle = (cld.Position - npc.Position):GetAngleDegrees()
  --local angleinv = (npc.Position - cld.Position):GetAngleDegrees()

  --end)

function HMBPENTS.NoDlrForm(e)
	HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
        if DlrHasExist and npc.Variant == e.Variant and npc.SubType == e.SubType then
			npc:Morph(412, 0, 0, -1)
        end
    end, e.Type)
end

function HMBPENTS.IsInRoom(p,xsz,ysz)
	local Room = Game():GetRoom()
	if p.X >= Room:GetTopLeftPos().X+xsz and p.X <= Room:GetBottomRightPos().X-xsz
	and p.Y >= Room:GetTopLeftPos().Y+ysz and p.Y <= Room:GetBottomRightPos().Y-ysz then
		return true
	else
		return false
	end
end

function HMBPENTS.EnemyStopMove(e)
	if not e:GetData().StopMove then
		e:GetData().StopMove = true
	end
	HMBPENTS:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
		if npc:GetData().StopMove and npc.Variant == e.Variant and npc.SubType == e.SubType then
			return true
        end
    end, e.Type)
end

HMBPENTS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, p, amt, dmgflg, s, num)
	local snd = SFXManager()

	if s.Type == 396 and not snd:IsPlaying(84) then --Mom(HardMode)
		snd:Play(84, 1, 0, false, 1) --SOUND_MOM_VOX_EVILLAUGH
	end

	if s.Type == 555 and not snd:IsPlaying(86) and (s.Variant == Isaac.GetEntityVariantByName("Snapped Mom's Heart")
	or s.Variant == Isaac.GetEntityVariantByName("Snapped It Lives") or s.Variant == Isaac.GetEntityVariantByName("It Lives Head")) then --Snapped Womb Major Bosses
		snd:Play(86, 1, 0, false, 1) --SOUND_MOM_VOX_FILTERED_EVILLAUGH
	end
end, 1)

HMBPENTS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amt, dmgflg, s, num)
	local Entities = Isaac:GetRoomEntities()
	local player = Game():GetPlayer(1)
	local rng = e:GetDropRNG()
	local enspr = e:GetSprite()
	local edata = e:GetData()
	local snd = SFXManager()

	if (e.Type == 70 and s.Type == 70) or (e:IsBoss() and s.Type == 70 and dmgflg ~= 1<<2) or (e.Type == 273 and s.Type == 507)
	or (e.Type ==  396 and s.Type == 396 and s.Variant ~= 20) or (e.Type == 400 and (s.Type == 273 or s.Type == 555))
	or (e.Type == 400 and s.Type == 507) or (e.Type == 555 and e.Variant == 0 and (e.EntityCollisionClass == 0 or e:ToNPC().State == 28))
	or (e.Type == 406 and s.Type == 1000 and s.Variant == Isaac.GetEntityVariantByName("Ultra Greed Coin (Burst)"))
	or (e.Type == 506 and e.Variant <= 1 and (e.EntityCollisionClass == 0 or (s.Type == 506 and s.Variant <= 1))) or (e.Type == 400 and e.Variant == 1) then
		return false
	end

	if e.Variant == 0 then
		if e.Type == 396 then
			if enspr:IsPlaying("EyeAttack") and enspr:GetFrame() <= 61 then
				edata.eyeHp = edata.eyeHp - amt
			end
			if e:ToNPC().State == 10 then
				if e:ToNPC().StateFrame < 139 and (dmgflg == 1<<2 or dmgflg == 1<<3 or s.Type == 2 or s.Type == 9) then
					e:ToNPC():PlaySound(181, 1, 0, false, 1)
					enspr:Play("WigHit", true)
					e:ToNPC().StateFrame = 139
					for i=0, edata.numspider do
						if i > 0 then
							EntityNPC.ThrowSpider(e.Position, e,
							e.Position + Vector.FromAngle(enspr.Rotation+90+math.random(-80,80)):Resized(math.random(50,150)), false, -15)
						end
					end
				end
				return false
			elseif e:ToNPC().State == 15 then
				return false
			end
		elseif e.Type == 555 then
			if edata.sucking and (s.Type == 2 or s.Type == 9) then
				return false
			end
		end
	end

	if e.Type == 396 then
		if s.Type == 396 and s.Variant == 20 and dmgflg == 1<<2 then
			return false
		end
		if e.Variant == 20 and s.Type ~= 396 and s.Variant ~= 20 then
			if e.Parent then
				e.Parent:TakeDamage(amt, 0, EntityRef(e.Parent), 5)
			end
			if e.Child then
				e.Child:TakeDamage(amt, 0, EntityRef(e.Child), 5)
			end
		end
	elseif e.Type == 666 then
		if e.Variant == 666 and s.Type ~= 666 and s.Variant ~= 666 then
			return false
		end
		if e.Variant > 666 and e.Variant < 669 then
			if (s.Variant > 666 and s.Variant < 669) or (s.Type == 9 and dmgflg == 1<<2) then
				return false
			end
			if s.Type ~= 666 and s.Variant ~= 666 then
				e.Parent:TakeDamage(amt, 0, EntityRef(e.Parent), 5)
			end
		end
	end

	if amt >= 50000 and e.Type == 555 and e.Variant == 0 then
		e:GetData().planc = true
	end

	if e.Type == 399 or e.Type == 545 or (e.Type == 396 and e:GetSprite():IsPlaying("Hurt")) or (e.Type == 555 and not e.Visible and e:ToNPC().State == 21)
	or (e.Type == 396 and (e.EntityCollisionClass == 0 or e.FrameCount < 30)) then
		return false
	end

	if e.Type == 396 and math.random(1, 20) == 1 and not snd:IsPlaying(97) then
		snd:Play(97, 1, 0, false, 1) --SOUND_MOM_VOX_HURT
	end

	if e.Type == 555 and math.random(1, 20) == 1 and not snd:IsPlaying(87) and (e.Variant == Isaac.GetEntityVariantByName("Snapped Mom's Heart")
	or e.Variant == Isaac.GetEntityVariantByName("Snapped It Lives") or e.Variant == Isaac.GetEntityVariantByName("It Lives Head")) then
		snd:Play(87, 1, 0, false, 1) --SOUND_MOM_VOX_FILTERED_HURT
	end

	if e.Type == 400 and math.random(1, 8) == 1 then
		e:GetData().hurtattack = true
	end
end)

  function HMBPENTS:LambBody(boss)
	local Room = Game():GetRoom()
	if Game().Difficulty % 2 == 1 and (bpattern or hdlamb) and boss.Variant == 10 and not boss:GetData().isdelirium  and Level:GetStage() > 10 and Room:GetType() == 5 then
		boss:Morph(400, 0, 0, -1)
		boss.SpriteOffset = Vector(0,0)
		boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		for k, v in pairs(Isaac:GetRoomEntities()) do
			if v.Type == 273 and v.Variant == 0 then
				boss.Parent = v
				break
			end
		end
	end
  end

  function HMBPENTS:Others()
		local Entities = Isaac:GetRoomEntities()
		local Room = Game():GetRoom()
		local snd = SFXManager()
		for k, v in pairs(Entities) do
			if Game().Difficulty % 2 == 1 then
				if v.Type == 273 and v.Variant == 0 then
					if v.HitPoints <= 0 and v:GetSprite():IsPlaying("Death") and (bpattern or hdlamb) and not v:GetData().planc then
						v:GetSprite():Play("Breaking", true)
					end

					if v:GetSprite():IsPlaying("Breaking") then
						v.Velocity = Vector(0, 0)

						if v:GetSprite():GetFrame() == 5 or v:GetSprite():GetFrame() == 25 then
							Game():SpawnParticles(v.Position, 35, 7, 5, Color(1, 0.95, 0.9, 1, 0, 10 / (REPENTANCE and 255 or 1), 0), -24) --Tooth Particle
						end

						if v:GetSprite():GetFrame() == 5 then
							v:ToNPC():PlaySound(117, 1, 0, false, 1) --SOUND_MONSTER_ROAR_2
							v:ToNPC():PlaySound(137, 1, 0, false, 1.5) --SOUND_ROCK_CRUMBLE
						elseif v:GetSprite():GetFrame() == 25 then
							v:ToNPC():PlaySound(137, 1, 0, false, 1.65)
						elseif v:GetSprite():GetFrame() == 51 then
							local Div = REPENTANCE and 255 or 1

							v:ToNPC():PlaySound(141, 1, 0, false, 1) --SOUND_ROCKET_BLAST_DEATH
							Game():SpawnParticles(v.Position, 88, 5, 15, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -24) --Dark Ball Smoke Particle
							Game():SpawnParticles(v.Position, 35, 9, 7, Color(1, 0.95, 0.9, 1, 0, 10 / Div, 0), -24)

							for i=0,5 do
								Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Pieces of Lamb"), i, v.Position, Vector(0, 0), v)
							end

							v:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
							v:Remove()
							Isaac.Spawn(555, Isaac.GetEntityVariantByName("The Lamb II"), 0, v.Position, Vector(0, 0), v)
						end
					end
				end
			end

			if v.Type == 396 and v.Variant == 0 then
				if v.SubType > 10 and not v:GetData().EternalSpr then
					for i=0, 3 do
						v:GetSprite():ReplaceSpritesheet(i, "gfx/bosses/classic/boss_mom_eternal.png")
					end

					v:GetSprite():LoadGraphics()
					v:GetData().EternalSpr = true
				end
			elseif v.Type == 506 and v.Variant < 2 then
				if v:GetSprite():IsPlaying("Appear") then
					if v.FrameCount == 31 then
						v:ToNPC():PlaySound(314, 1, 0, false, 1) --SOUND_SKIN_PULL
						v.EntityCollisionClass = 0
					end
				end
				if v:GetSprite():IsFinished("Death") and v.Parent and not v.Parent:IsDead() then
					local hand = Isaac.Spawn(506, v.Variant, 0, v.Parent.Position+v:GetData().SpawnPos, Vector(0,0), v)
					hand.Parent = v.Parent
				end
			elseif v.Type == 555 then
				if v.Variant == 0 then
					if not v:GetData().planc and v:GetSprite():IsPlaying("Death") then
						v:GetSprite():Play("HeadDyingAttackStart", true)
						v.FlipX = false
						--snd:Play(141, 1, 0, false, 1)
						v:ToNPC().ProjectileCooldown = 0
					end
					if v:GetSprite():IsPlaying("HeadDyingAttackStart") then
						if v:GetSprite():GetFrame() == 31 then
							v:ToNPC():PlaySound(309 , 1, 0, false, 1) --SOUND_INHALE
						elseif v:GetSprite():GetFrame() == 33 then
							v:ToNPC():PlaySound(5, 1, 0, false, 1) --SOUND_BLOOD_LASER
							Game():ShakeScreen(7)
						elseif v:GetSprite():GetFrame() == 35 then
							v:GetSprite():Play("HeadDyingAttackLoop", true)
							Isaac.Spawn(1000, 759, 0, v.Position+Vector(0, 100), Vector(0, 0), v)

							for i=-80, 80, 160 do
								Isaac.Spawn(1000, 759, 0, v.Position+Vector(i, -80), Vector(0, 0), v)
							end
						end
					elseif v:GetSprite():IsPlaying("HeadDyingAttackLoop") then
						v:ToNPC().ProjectileCooldown = v:ToNPC().ProjectileCooldown + 1

						if v:ToNPC().ProjectileCooldown >= 250 then
							v:GetSprite():Play("HeadDyingAttackEnd", true)
						end
					elseif v:GetSprite():IsPlaying("HeadDyingAttackEnd") and v:GetSprite():GetFrame() == 39 then
						v:ToNPC():PlaySound(418, 1, 0, false, 1) --SOUND_THE_FORSAKEN_SCREAM
						v:ToNPC().State = 17
					end
				end
			elseif v.Type == 666 then
				if v.Variant > 666 and v.Variant < 669 and v.Parent then
					v.HitPoints = v.Parent.HitPoints
				end

				if (v.Variant > 665 and v.Variant < 669) and (v:GetSprite():IsPlaying("Death") or v:GetSprite():IsPlaying("Death2")) then
					if v:GetSprite():GetFrame() <= 20 then
						if v.Position.X > Room:GetCenterPos().X then
							v.Position = Vector(v.Position.X - (21 - v:GetSprite():GetFrame()) * 2, v.Position.Y)
						else
							v.Position = Vector(v.Position.X + (21 - v:GetSprite():GetFrame()) * 2, v.Position.Y)
						end
					end

					if v:GetSprite():GetFrame() == 206 then
						Game():ShakeScreen(10)
						v:ToNPC():PlaySound(246, 1, 0, false, 1) --SOUND_SATAN_STOMP
					end
				end

				if v:IsDead() then
					v:GetSprite().PlaybackSpeed = 1
				end

				if v.Variant == 668 and v:GetSprite():IsPlaying("Death") then
					v:GetSprite():Play("Death2", true)
				end
 			end
			if (v:IsVulnerableEnemy() or v:ToPlayer()) then
				if v:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then
					if v:ToPlayer() then
						v:ToPlayer().ControlsEnabled = false

						if not v:GetData().goldenfreeze then
							v:GetData().envibration = 15
							v:GetData().goldenfreeze = true
						end

						if v:GetData().envibration > 0 then
							v:GetData().envibration = v:GetData().envibration - 1
							if v:GetData().envibration / 4 > 4 then
								v.PositionOffset = Vector((1 - (math.random(-1, 0) * 2)) * 4,0)
							else
								v.PositionOffset = Vector((1 - (math.random(-1, 0) * 2)) * (v:GetData().envibration / 4),0)
							end
						end
					end
				else
					if v:GetData().goldenfreeze then
						v:GetData().goldenfreeze = false
						Game():SpawnParticles(v.Position, 95, 20, 7, Color(1.1, 1, 1, 1, 0, 0, 0), 0) --Diamond Particle
						snd:Play(427, 1, 0, false, 1) --SOUND_ULTRA_GREED_COIN_DESTROY

						if v:ToPlayer() then
							v:ToPlayer().ControlsEnabled = true
						end

						if denpnapi then
							Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Circular Impact"), 0, v.Position, Vector(0, 0), ev)
						end
					end
				end
			end
		end
  end

   HMBPENTS:AddCallback(ModCallbacks.MC_POST_UPDATE, HMBPENTS.Others)
   HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.LambBody, 273)

----------------------------
--Lasers
----------------------------
function HMBPENTS:Lasers(l)
	local data = l:GetData()
	if not data.pvl then
		data.pvl = 0
	elseif not data.MaxLength then
		data.MaxLength = 100
	elseif not data.LStretchStrength then
		data.LStretchStrength = 5
	end
	if data.lflag == 2 then
		if l.MaxDistance < data.MaxLength then
			l.MaxDistance = l.MaxDistance + data.LStretchStrength
		elseif l.MaxDistance >= data.MaxLength - data.LStretchStrength then
			l.MaxDistance = data.MaxLength
		end
	end
	if not data.pdensity or data.pdensity < 6 then
		data.pdensity = 6
	end
	if l.SpawnerType == 400 and l.Parent and l.Parent:GetSprite():GetFrame() >= 20
	and l.Variant == 3 then
		l.Timeout = 2
	end
end

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, e)
	e.CollisionDamage = 0
end, 38)

HMBPENTS:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, c)
	for k, v in pairs(Isaac:GetRoomEntities()) do
		if v.Type == 396 or (v.Type == 555 and (v.Variant == Isaac.GetEntityVariantByName("Snapped Mom's Heart") or Isaac.GetEntityVariantByName("Snapped It Lives")))
		or (v.Type == 666 and v.Variant == 666) then
			v:GetData().UsedBible = true

			if not (v.Type == 666 and v.Variant == 666) then
				v:Kill()
			end
		end
	end
end, 33)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local Level = Game():GetLevel()

	HMBPMom_Eye = 0
	HMBPMom_Hand = 0

	if HMBPEnts.KilledSnappedHeart and Level:GetRoomByIdx(Level:GetCurrentRoomIndex()).Data.Subtype == 89 then
		local Room = Game():GetRoom()

		HMBPEnts.FlySpawnCount = 32

		while HMBPEnts.FlySpawnCount > 0 do
			local PreSpawnPos = Room:GetRandomPosition(0)
			local GridEntity = Room:GetGridEntityFromPos(PreSpawnPos)

			if Room:GetGridPathFromPos(PreSpawnPos) < 900 and math.abs(PreSpawnPos.X - Room:GetCenterPos().X) < 180
			and (not GridEntity or (GridEntity and GridEntity:GetType() ~= GridEntityType.GRID_TRAPDOOR)) then
				if HMBPEnts.FlySpawnCount > 27 then
					Isaac.Spawn(13, 0, 0, PreSpawnPos, Vector(0, 0), nil) --Fly
				elseif HMBPEnts.FlySpawnCount > 20 then
					Isaac.Spawn(1000, 33, 0, PreSpawnPos, Vector(0, 0), nil) --Tint Fly
				else
					Isaac.Spawn(1000, 64, 0, PreSpawnPos, Vector(0, 0), nil) --Beetle
				end

				HMBPEnts.FlySpawnCount = HMBPEnts.FlySpawnCount - 1
			end
		end

		HMBPEnts.KilledSnappedHeart = false
	end
end)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, HMBPENTS.Lasers)
