denpnapi = RegisterMod("dentpack",1)

local Level = Game():GetLevel()

local Codes = REPENTANCE and {
	include("enemies_main"),
	include("projsmain"),
	include("effectsmain")
} or {
	require("enemies_main"),
	require("projsmain"),
	require("effectsmain")
}

----------------------------
--custom functions
----------------------------
function SpawnGroundParticle(big, spawner, num, speed, snd, shakeframe)
	local Room = Game():GetRoom()
	local sound = SFXManager()

	if snd >= 3 then
		sound:Play(52, 1, 0, false, 1)
	elseif snd == 2 then
		sound:Play(48, 1, 0, false, 1)
	elseif snd == 1 then
		if Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 13 then
			sound:Play(77, 1, 0, false, 1)
		else
			sound:Play(138, 1, 0, false, 1)
		end
	end

	if shakeframe > 0 then
		Game():ShakeScreen(shakeframe)
	end

	if Room:GetBackdropType() == 1 or Room:GetBackdropType() == 4 or Room:GetBackdropType() == 5 or Room:GetBackdropType() == 8
	or Room:GetBackdropType() == 18 or Room:GetBackdropType() == 23 or Room:GetBackdropType() == 25 or Room:GetBackdropType() == 26 then
		if big then
			Game():SpawnParticles(spawner.Position, 4, num, speed, Color(1,1,1,1,0,0,0), -4)
		else
			Game():SpawnParticles(spawner.Position, 35, num, speed, Color(0.4,0.3,0.3,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 2 or Room:GetBackdropType() == 17 or (Room:GetBackdropType() >= 19 and Room:GetBackdropType() <= 22) or Room:GetBackdropType() == 28 then
		Game():SpawnParticles(spawner.Position, 27, num, speed, Color(1,1,1,1,0,0,0), -2)
	elseif Room:GetBackdropType() == 3 then
		Game():SpawnParticles(spawner.Position, 27, num, speed, Color(1,0.8,0.8,1,0,0,0), -2)
	elseif Room:GetBackdropType() == 6 then
		if big then
			Game():SpawnParticles(spawner.Position, 4, num, speed, Color(0,0.6,0.8,1,0,0,0), -4)
		else
			Game():SpawnParticles(spawner.Position, 35, num, speed, Color(0.3,0.3,0.4,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 or Room:GetBackdropType() == 16 then
		Game():SpawnParticles(spawner.Position, 4, num, speed, Color(0.45,0.55,0.6,1,0,0,0), -2)
	elseif Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 12 then
		if num == 1 then
			Game():SpawnParticles(spawner.Position, 5, 1, speed, Color(1,1,1,1,0,0,0), -2)
		else
			Game():SpawnParticles(spawner.Position, 5, num-1, speed, Color(1,1,1,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 13 then
		if num == 1 then
			Game():SpawnParticles(spawner.Position, 5, 1, speed, Color(0.6,0.6,1,1,0,0,0), -2)
		else
			Game():SpawnParticles(spawner.Position, 5, num-1, speed, Color(0.6,0.6,1,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 15 then
		if big then
			Game():SpawnParticles(spawner.Position, 4, num, speed, Color(0.35,0.7,1,1,0,0,0), -2)
		else
			Game():SpawnParticles(spawner.Position, 35, num, speed, Color(0.25,0.35,0.45,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 24 then
		if big then
			Game():SpawnParticles(spawner.Position, 4, num, speed, Color(1,0,0,1,0,0,0), -2)
		else
			Game():SpawnParticles(spawner.Position, 35, num, speed, Color(1,0,0,1,0,0,0), -2)
		end
	elseif Room:GetBackdropType() == 27 then
		if big then
			Game():SpawnParticles(spawner.Position, 4, num, speed, Color(0.5,0.5,0.7,1,0,0,0), -2)
		else
			Game():SpawnParticles(spawner.Position, 35, num, speed, Color(0.5,0.5,0.7,1,0,0,0), -2)
		end
	end
end

-------------------------------------------------

  function denpnapi:hit(entity,amount,damageflag,source,num)
	local player = Game():GetPlayer(1)
	local rng = entity:GetDropRNG()

	if (entity:IsBoss() and source.Type == 1000 and source.Variant == Isaac.GetEntityVariantByName("Giant Red Laser From Above"))
	or (entity.Type == 554 and entity.Variant == Isaac.GetEntityVariantByName("Memories III") and entity.SubType == 1) then
		return false
	end

	if entity.Type == 557 and (entity.Variant == Isaac.GetEntityVariantByName("Pupula Projectile") or entity.Variant == Isaac.GetEntityVariantByName("Pupula Tear Projectile")) then
		if damageflag == 1<<2 or damageflag == 1<<3 then -- explosion
			entity:Die()
		else
			if source.Type == 8 then
				entity.HitPoints = entity.HitPoints + amount
				entity.Velocity = entity.Velocity + Vector.FromAngle((entity.Position-source.Position):GetAngleDegrees()):
				Resized(amount*0.08)
			else
				return false
			end
		end
	elseif entity.Type == 85 and entity.Variant == Isaac.GetEntityVariantByName("Hush Spider") then
		if entity.FrameCount <= 250 and amount > 1.5 and entity:IsVulnerableEnemy() then
			entity.HitPoints = entity.HitPoints + amount - 1.5
		end
	end
  end

  function denpnapi:ModAnim(player)
		local pdata = player:GetData()
		if pdata.playmodanim then
			if pdata.playmodanim > 0 and pdata.playmodanim <= 4 and (pdata.playmodanim ~= pdata.playingmodanim) then
				local playeranim = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Player Mod Anim"), pdata.playmodanim, player.Position, Vector(0,0), player)
				playeranim.Parent = player
				pdata.playingmodanim = pdata.playmodanim
			end
		end
  end

  denpnapi:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, denpnapi.ModAnim)
  denpnapi:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, denpnapi.hit)

  function denpnapi:Others()
		local Entities = Isaac:GetRoomEntities()
		local sound = SFXManager()

		for k, v in pairs(Entities) do
			if v.Type == 7 then
				if v.Variant == 1 and v.Size >= 80 and v.SpawnerType ~= 406 then
					if v:GetSprite():GetFilename() ~= "gfx/giant red laser.anm2" then
						v:GetSprite():Load("gfx/giant red laser.anm2", true)
						v:GetSprite():Play("LargeRedLaser", true)
					end

					if v.FrameCount <= 2 and v.SpawnerType ~= 407 then
						sound:Stop(5)
						sound:Play(239, 1, 0, false, 1)
					end
				end
			end
		end
  end

  denpnapi:AddCallback(ModCallbacks.MC_POST_UPDATE, denpnapi.Others)
