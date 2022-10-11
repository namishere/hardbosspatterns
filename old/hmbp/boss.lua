local sound = SFXManager()
local Level = Game():GetLevel()

----------------------------
--add Boss Pattern:Mom
----------------------------
  function bpattern:Mom(mom)

	if mom.Variant == 0 and Game().Difficulty % 2 == 1 then

	local sprm = mom:GetSprite()
	local target = mom:GetPlayerTarget()
	local player = Game():GetNearestPlayer(mom.Position)
	local Entities = Isaac:GetRoomEntities()
	local data = mom:GetData()

	if not data.eyeHp then
		data.eyeHp = 15
		data.eyehurt = false
	end

	if mom.SubType == 33 and sprm:GetFilename() ~= "gfx/Mom_hard_eternal.anm2" then
		sprm:Load("gfx/Mom_hard_eternal.anm2", true)
		sprm:SetFrame("Eye", 64)
	end

	if sprm:IsPlaying("Eye") then
		if mom.SubType == 33 then
			sprm:Play("EyeAttackEternal",true)
		else
			sprm:Play("EyeAttack",true)
		end
		data.eyeHp = 15
	end

	if data.eyehurt then
		mom.State = 8
		mom.ProjectileCooldown = mom.ProjectileCooldown + 2
		mom:SetSpriteFrame("EyeHurt", mom.ProjectileCooldown)

		if mom.ProjectileCooldown == 38 then
			local ShootPos = mom.SubType == 2 and (target.Position - mom.Position):GetAngleDegrees() or (sprm.Rotation + 90)

			if HMBPEPTTN then
				local params = HMBPEnts.ProjParams()
				params.Height = 20
				params.FallingSpeedModifier = -math.random(25,75) * 0.1
				params.FallingAccelModifier = 0.5

				for i=0, math.random(6, 10) do
					if math.random(1, 3) == 1 and i >= 5 then
						params.Scale = 1.65
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.LEAVES_ACID
					else
						params.Scale = 0.7 + math.random(0, 2) * 0.3
						params.HMBPBulletFlags = 0
					end

					HMBPEnts.FireProjectile(mom, mom.SubType == 2 and 4 or 0, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
					Vector(math.random(45, 120) * 0.1, 0):Rotated(ShootAngle  + math.random(-30, 30)), params)
				end
			else
				local params = ProjectileParams()
				params.Height = 20
				params.FallingSpeedModifier = -math.random(25,75) * 0.1
				params.FallingAccelModifier = 0.5

				for i=0, math.random(8, 14) do
					params.Scale = 0.7 + math.random(0, 3) * 0.3
					params.Variant = mom.SubType == 2 and 4 or 0

					HMBPEnts.FireProjectile(mom, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
					Vector(math.random(45, 120) * 0.1, 0):Rotated(ShootAngle  + math.random(-30, 30)), 0, params)
				end
			end

			mom:PlaySound(153, 1, 0, false, 1)
		elseif mom.ProjectileCooldown == 57 then
			mom.EntityCollisionClass = 0
		elseif mom.ProjectileCooldown >= 61 then
			data.eyehurt = false
		end
	end

	if sprm:IsPlaying("EyeAttack") then
		if sprm:GetFrame() == 3 then
			mom.EntityCollisionClass = 4
		elseif sprm:GetFrame() == 41 and mom.SubType < 3 then
			local params = ProjectileParams()
			params.HeightModifier = 20
			params.FallingAccelModifier = -0.1
			if mom.SubType ~= 2 then
				params.Variant = 4
				mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
				Vector.FromAngle(sprm.Rotation+90):Resized(10), 1, params)
			else
				mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
				Vector.FromAngle((target.Position - mom.Position):GetAngleDegrees()):Resized(10), 1, params)
			end
			mom:PlaySound(153, 1, 0, false, 1)
		elseif sprm:GetFrame() == 45 and mom.SubType > 10 then
			for i=-15, 15, 30 do
				EntityLaser.ShootAngle(1, mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(16) + Vector(0,1)
				, sprm.Rotation + 90 + math.random(-10,10) + i, 27, Vector(0,-5), mom)
			end
		elseif sprm:GetFrame() == 62 then
			mom.EntityCollisionClass = 0
		end

		if data.eyeHp <= 0 then
			mom.ProjectileCooldown = 0
			data.eyeHp = math.max(15, 1*GetPlayerDps)
			mom:PlaySound(97, 1, 0, false, 1)
		end
	elseif sprm:IsPlaying("EyeAttackEternal") then
		if sprm:GetFrame() == 3 then
			mom.EntityCollisionClass = 4
		elseif sprm:GetFrame() == 64 then
			mom.EntityCollisionClass = 0
		end
	end

	if eye and eye < 0 then
		eye = 0
	end

  end
  end

----------------------------
--add Boss Pattern:Mom Stomp
----------------------------
function bpattern:Momf(mom)

	if mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp") and Game().Difficulty % 2 == 1 then

	local sprmf = mom:GetSprite()
	local target = mom:GetPlayerTarget()
	local player = Game():GetNearestPlayer(mom.Position)
	local data = mom:GetData()
	local Room = Game():GetRoom()
	local Entities = Isaac:GetRoomEntities()

	if data.isdelirium then
		if mom.State == 3 then
			if mom.FrameCount % 50 == 0 and mom.FrameCount >= 30 then
				mom:PlaySound(252, 1, 0, false, 1)
				if mom.SubType == 2 then
					Isaac.Spawn(70, 70, 1, Isaac.GetRandomPosition(0), Vector(0,0), mom)
				else
					Isaac.Spawn(70, 70, 0, player.Position, Vector(0,0), mom)
				end
			end
		end
	end

	if mom.SubType == 33 then
		if data.isdelirium then
			mom:SetColor(Color(1,1,1,1.5,0,0,0), 99999, 0, false, false)
		else
			if sprmf:GetFilename() ~= "gfx/Mom stomp_hard_eternal.anm2" then
				sprmf:Load("gfx/Mom stomp_hard_eternal.anm2", true)
			end
		end
	end

	if mom.State < 7 and mom.HitPoints/mom.MaxHitPoints <= 0.85 and math.random(1,3) ~= 1
	and mom.FrameCount % 200 == 0 then
		sprmf:Play("Stronger Stomp", true)
		mom:PlaySound(84, 1, 0, false, 1)
		mom.State = 8
	end

	if mom.State == 7 then
		if sprmf:IsPlaying("Stomp") and sprmf:GetFrame() == 1 and math.random(1,3) == 1
		and mom.HitPoints/mom.MaxHitPoints <= 0.5 then
			sprmf:Play("Stomp2", true)
		end
		if sprmf:IsPlaying("Stomp2") then
			if sprmf:GetFrame() == 28 then
				mom:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(20)
				Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
			elseif sprmf:GetFrame() == 67 then
				mom:PlaySound(93, 1.3, 0, false, 1.03)
			elseif sprmf:GetFrame() == 69 then
				Game():ShakeScreen(20)
				mom:PlaySound(138, 1, 0, false, 1)
				Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
				player:AnimatePitfallOut()
				player.ControlsEnabled = false
				player.Velocity = player.Velocity * 3
				for i=0, math.random(4,8) do
					Game():SpawnParticles(Isaac.GetRandomPosition(0), 35, 1, 0, Color(0.35,0.35,0.35,1,0,0,0), -1)
				end
			end
		end
	elseif mom.State == 8 then
		mom.Position = Room:GetCenterPos()
		if sprmf:GetFrame() == 58 then
			local Div = REPENTANCE and 255 or 1

			mom:PlaySound(52, 1, 0, false, 1)
			Game():ShakeScreen(20)
			Game():SpawnParticles(mom.Position, 88, 10, 20, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
			Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
			local shockwave1 = Isaac.Spawn(1000, 61, 0, mom.Position, Vector(0,0), mom)
			shockwave1.Parent = mom
			shockwave1:ToEffect().Timeout = 10
			shockwave1:ToEffect().MaxRadius = 90
			if mom.SubType > 10 then
				for i=20, 335, 45 do
					local shockwave2 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
					shockwave2.Parent = mom
					shockwave2:ToEffect().Timeout = 120
					shockwave2:ToEffect():SetRadii(6,6)
				end
			else
				for i=30, 330, 60 do
					if i == 30 or i == 150 or i == 210 or i == 330 then
						local shockwave3 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
						shockwave3.Parent = mom
						shockwave3:ToEffect().Timeout = 120
						shockwave3:ToEffect():SetRadii(6,6)
					end
				end
			end
		end
	end

	if (sprmf:IsFinished("Stronger Stomp") or sprmf:IsFinished("Stomp2")) and mom.State > 3 then
		mom.State = 3
	end

	if sprmf:IsPlaying("Stronger Stomp") and sprmf:IsPlaying("Stomp2") then
		if (sprmf:IsPlaying("Stronger Stomp") and sprmf:GetFrame() >= 58 and sprmf:GetFrame() <= 101)
		or (sprmf:IsPlaying("Stomp2") and ((sprmf:GetFrame() >= 28 and sprmf:GetFrame() <= 56) or (sprmf:GetFrame() >= 69 and sprmf:GetFrame() <= 97))) then
			mom.EntityCollisionClass = 4
		else
			mom.EntityCollisionClass = 0
		end
	end

	for k, v in pairs(Entities) do
		if v:IsVulnerableEnemy() then
			if sprmf:IsPlaying("Stomp2") and sprmf:GetFrame() == 69
			and not v:IsFlying() then
				v:AddFreeze(EntityRef(mom),30)
			end
		end
	end

  end
  end

----------------------------------------------
--add Boss Pattern:Womb chapter major bosses
----------------------------------------------
bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, boss)
  if Game().Difficulty % 2 == 1 then
	local sprite = boss:GetSprite()

	if boss.Variant == 10 then --Gut
		if not boss.Parent then return end

		local Heart = boss.Parent:ToNPC()
		local data = boss:GetData()
		local CR, CA, To = REPENTANCE and 0.6 or 1.2, REPENTANCE and 0.6 or 2, REPENTANCE and 30 or 20 --ColorRed, ColorAlpha, Timeout

		if not data.LaserAngle then
			data.LaserAngle = 90
		end

		if Heart.I1 == 5 then
			if sprite:IsFinished("HeartRetracted") then
				sprite:Play("Heartbeat1", true)
			end

			if Game():GetRoom():GetAliveEnemiesCount() - #Isaac.FindByType(78, -1, -1, true, true) > 0 and boss.FrameCount % 81 == 0 then
				if Heart.Variant == 1 then
					for i=-90, 90, 180 do
						HMBP.SpawnLaserWarn(Vector(boss.Position.X + i, 120), To, 90, Color(CR, 0, 0, CA, 0, 0, 0), Heart, Vector(0, -30), Vector(2, 1), 23, Heart)
					end
				else
					HMBP.SpawnLaserWarn(Vector(boss.Position.X - 90 + (boss.FrameCount % 2) * 180 , 120), To, 90, Color(CR, 0, 0, CA, 0, 0, 0), Heart, Vector(0, -30), Vector(2, 1), 23, Heart)
				end

				boss.ProjectileDelay = 30
			end
		elseif Heart.I1 == 50 then
			if Heart.State == 43 and Heart:GetSprite():IsPlaying("HeartHidingHeartbeat2") then
				if Heart.Variant == 1 then
					if boss.FrameCount % 21 == 0 and Heart.ProjectileCooldown > 40 then
						local params = ProjectileParams()
						params.Scale = 1.5
						params.FallingAccelModifier = -0.15

						for i=-60, 60, 30 do
							boss:FireProjectiles(Vector(boss.Position.X - 90 + (boss.FrameCount % 2) * 180, 150),
							Vector.FromAngle(i + 90 + (27.5 - (boss.FrameCount % 114) / 2) * (boss.FrameCount % 2 == 0 and -1 or 1)):Resized(4.5), 0, params)
						end
					end
				else
					if boss.FrameCount % 51 == 0 and Heart.ProjectileCooldown > 50 then
						local LaserPos = Vector(boss.Position.X - 90 + (boss.FrameCount % 2) * 180 , 120)
						data.LaserAngle = (boss:GetPlayerTarget().Position - LaserPos):GetAngleDegrees()
						HMBP.SpawnLaserWarn(LaserPos, To, math.min(math.max(3, data.LaserAngle), 177), Color(CR, 0, 0, CA, 0, 0, 0), Heart, Vector(0, 0), Vector(2, 1), 23, Heart)
						boss.ProjectileDelay = 30
					end
				end
			end
		end

		if Heart.State == 17 and Heart:GetSprite():IsEventTriggered("Burst") and HMBPENTS and not Heart:GetData().IsHMBPEtn then
			boss:Kill()
		end

		if boss.ProjectileDelay >= 0 then
			boss.ProjectileDelay = boss.ProjectileDelay - 1

			if boss.ProjectileDelay == 0 then
				if Heart.Variant == 1 then
					for i=-90, 90, 180 do
						EntityLaser.ShootAngle(1, Vector(boss.Position.X + i, 120), 90, 10, Vector(0, 0), Heart).CollisionDamage = 5.25
					end
				else
					if Heart.I1 == 50 then
						EntityLaser.ShootAngle(1, Vector(boss.Position.X + 90 - (boss.FrameCount % 2) * 180, 120), data.LaserAngle, 20, Vector(0, 0), Heart)
					else
						EntityLaser.ShootAngle(1, Vector(boss.Position.X + 90 - (boss.FrameCount % 2) * 180, 120), 90, 10, Vector(0, -30), Heart).CollisionDamage = 5.25
					end
				end
			end
		end
	else --Heart
		local target = boss:GetPlayerTarget()
		local rng = boss:GetDropRNG()
		local data = boss:GetData()
		local Room = Game():GetRoom()

		if not data.Rotation then
			data.Rotation = -1 + math.random(0, 1) * 2
		end

		if REPENTANCE and boss.SubType == 1 then --Rep route
			if boss.State == 8 and boss.HitPoints / boss.MaxHitPoints <= 0.2 and boss.StateFrame > 180 and (math.floor(boss.V1.Y) == 18 or math.floor(boss.V1.Y) > (data.IsHMBPEtn and 127 or 105)) then
				boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and math.random(128, 130) or math.random(106, 109))
				boss.StateFrame = -50
			end
		else --Normal route
			if not data.V1X then
				data.V1X = 0
			end

			if boss.I1 == 3 then --Phase 1-3
				if boss.HitPoints / boss.MaxHitPoints > 0.2 then
					if boss.State == 3 then
						if Isaac.CountEnemies() - #Isaac.FindByType(78, -1, -1, true, true) > 0 then
							if data.V1X > boss.V1.X and data.Attacking then
								boss.State = 8
								boss.V1 = Vector(boss.V1.X, math.random(1, 2) == 1 and math.random(90, 93) or math.random(0, 7))
							end
						else
							data.Attacking = false
						end
					elseif boss.State == 8 then
						if boss.StateFrame > 180 then
							boss.State = 3
							data.V1X = boss.V1.X - 75
						end
					end
				else
					if boss.State == 3 then
						if boss.ProjectileCooldown < 1 then
							boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and math.random(117, 119) or math.random(97, 99))
							boss.I1 = 50
							boss.State = 43
							boss:PlaySound(212, 1, 0, false, 1) --SOUND_HEARTIN
							boss.ProjectileCooldown = math.random(210, 270)
							sprite:Play("HeartRetracted", true)
						end
					elseif boss.State == 8 then
						if boss.StateFrame > 180 then
							boss.State = 3
							boss.ProjectileCooldown = 40
						end
					end
				end
			elseif boss.I1 == 4 then
				if boss.State == 3 and boss.ProjectileCooldown == 8 and math.random(1, 2) == 1 then
					boss.State = 8
					boss.StateFrame = 1
					boss.V1 = Vector(boss.V1.X, math.random(90, 91) + (boss.I2 - 1) * 2)
				end
			end

			if boss.State == 43 and boss.I1 == 50 then
				if sprite:IsPlaying("HeartHidingHeartbeat2") or (sprite:IsPlaying("HeartStomp") and not sprite:WasEventTriggered("Stomp")) or sprite:IsPlaying("HeartRetracted") then
					boss.EntityCollisionClass = 0
				end

				if boss.ProjectileCooldown < 1 and sprite:IsPlaying("HeartHidingHeartbeat2") then
					sprite:Play("HeartStomp", true)
					boss:PlaySound(90, 1, 0, false, 1) --SOUND_MOM_VOX_FILTERED_ISAAC
				end

				if sprite:IsPlaying("HeartStomp") then
					if sprite:IsEventTriggered("Stomp") then
						Game():ShakeScreen(20)
						boss:PlaySound(52, 1, 0, false, 1) --SOUND_HELLBOSS_GROUNDPOUND
						Game():BombDamage(boss.Position, 41, boss.Size * 1.1, false, boss, 0, 0, true)

						if REPENTANCE then
							Isaac.Spawn(1000, 16, 3, boss.Position, Vector(0, 0), boss) --Poof02(BloodCloud)
							Isaac.Spawn(1000, 16, 4, boss.Position + Vector(0, 1), Vector(0, 0), boss) --Poof02(CBlood)
						else
							Isaac.Spawn(1000, 2, 4, boss.Position + Vector(0, 0), Vector(0, 0), boss) --Blood Explosion
						end

						if not data.IsHMBPEtn then
							local params = ProjectileParams()
							params.BulletFlags = ProjectileFlags.EXPLODE
							params.Scale = 2
							params.FallingAccelModifier = -0.1

							for i=0, 330, 30 do
								boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(8), 0, params)
							end
						else
						end
					end
				end

				if sprite:IsFinished("HeartRetracted") then
					sprite:Play("HeartHidingHeartbeat2", true)
					boss.StateFrame = 0
				elseif sprite:IsFinished("HeartStomp") then
					boss.State = 8
					boss.StateFrame = 0
					boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and math.random(114, 116) or math.random(94, 96))
					data.Rotation = -1 + math.random(0, 1) * 2
				end
			end
		end

		if boss.State == 8 then
			local Pattern = math.floor(boss.V1.Y)
			local Harder = boss.I1 > 1 and 1 or 0
			local Rotation = 1 - (boss.FrameCount % 2) * 2
			local LAngle = boss.StateFrame % 2
			local Angle = (target.Position - boss.Position):GetAngleDegrees()
			local CR, CA, To = REPENTANCE and 0.6 or 1.2, REPENTANCE and 0.6 or 2, REPENTANCE and 30 or 20

			if Pattern == 90 then --Normal route phase 1-1 pattern 1
				if boss.FrameCount % 20 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES | ProjectileFlags.WIGGLE
					params.FallingAccelModifier = -0.15

					for i=0, 315, 45 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + data.Rotation * boss.FrameCount):Resized(4), 0, params)
					end
				end
			elseif Pattern == 91 then --Normal route phase 1-1 pattern 2
				if boss.FrameCount % 19 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingAccelModifier = -0.15

					for i=0, 320, 40 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + boss.FrameCount * 20):Resized(4.5), 0, params)
					end
				end
			elseif Pattern == 92 then --Normal route phase 1-2 pattern 1
				if boss.FrameCount % 17 == 0 then
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.Scale = 1.5
					params.FallingAccelModifier = -0.15

					for i=0, 270, 90 do
						for j=-3, 3, 2 do
							boss:FireProjectiles(boss.Position, Vector(4, j):Rotated(i + boss.FrameCount), 0, params)
						end
					end
				end
			elseif Pattern == 93 then --Normal route phase 1-2 pattern 2
				if boss.FrameCount % 3 == 0 then
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.Scale = 1.5
					params.FallingAccelModifier = -0.17
					boss:FireProjectiles(boss.Position, Vector.FromAngle(data.Rotation * (boss.FrameCount * 5)):Resized(5), 0, params)
					boss:FireProjectiles(boss.Position, Vector.FromAngle(-data.Rotation * (boss.FrameCount * 7)):Resized(7.5), 0, params)
				end
			elseif Pattern == 94 then --Normal route phase 1-3.5 pattern 1
				if boss.StateFrame == 0 then
					for i=45, 315, 90 do
						HMBP.SpawnLaserWarn(boss.Position, To, i, Color(CR, 0, 0, CA, 0, 0, 0), boss, Vector(0, -30), Vector(2, 1), 23, boss)
					end
				end

				if boss.StateFrame == 30 then
					for i=45, 315, 90 do
						EntityLaser.ShootAngle(1, boss.Position, i, 150, Vector(0, -30), boss):SetActiveRotation(25, 360 * Rotation, 2 * Rotation, false)
					end
				end
			elseif Pattern == 95 then --Normal route phase 1-3.5 pattern 2
				if boss.StateFrame % 89 == 0 and boss.StateFrame < 150 then
					for i=90 + LAngle * 90, 270 + LAngle * 90, 180 do
						HMBP.SpawnLaserWarn(boss.Position, To, i, Color(CR, 0, 0, CA, 0, 0, 0), boss, Vector(0, -30), Vector(2, 1), 23, boss)
					end
				end

				if boss.StateFrame % 89 == 30 then
					for i=90 - LAngle * 90, 270 - LAngle * 90, 180 do
						EntityLaser.ShootAngle(1, boss.Position, i, 90, Vector(0, -30), boss):SetActiveRotation(25, 360 * Rotation, 2.5 * Rotation, false)
					end
				end
			elseif Pattern == 96 then --Normal route phase 1-3.5 pattern 3
				if boss.StateFrame == 0 then
					HMBP.SpawnLaserWarn(boss.Position, To, 90 - data.Rotation * 90, Color(CR, 0, 0, CA, 0, 0, 0), boss, Vector(0, -30), Vector(2, 1), 23, boss)
				end

				if boss.StateFrame % 45 == 30 then
					EntityLaser.ShootAngle(1, boss.Position, 90 - data.Rotation * 90, 58, Vector(0, -30), boss):SetActiveRotation(25, 220 * Rotation, 3.7 * Rotation, false)
				end
			elseif Pattern == 100 then --Rep route phase 1-1 pattern 1
				if boss.StateFrame % (27 - Harder * 15) == 1 then
					local Space = 24 + Harder * 6
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.18

					for i=0, 360 - Space, Space do
						local Ellipse = Vector.FromAngle(i):GetAngleDegrees() * (3.14 / 180)
						boss:FireProjectiles(boss.Position, Vector(math.sin(Ellipse) * 6, math.cos(Ellipse) * 3):Rotated(Angle), 0, params)
					end
				end
			elseif Pattern == 101 then --Rep route phase 1-1 pattern 2
				if boss.StateFrame % (25 - Harder * 6) == 1 then
					local params = ProjectileParams()
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.18
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CURVE_LEFT
					params.ChangeFlags = ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CURVE_RIGHT
					params.Scale = 1.5
					params.ChangeTimeout = 30

					for i=0, 330, 30 do
						params.CurvingStrength = 0.009 * (15 - (i % 60)) / 15
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + boss.StateFrame * (3 + Harder * 4)):Resized(4), 0, params)
					end
				end
			elseif Pattern == 102 then --Rep route phase 1-1 pattern 3
				if boss.StateFrame % (28 - Harder * 5) == 1 then
					local params = ProjectileParams()
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.18

					for i=0, 1 do
						local MinMax = 0.8 - i * 0.6

						for j=0, 270, 90 do
							for k=-MinMax, MinMax, 0.4 do
								params.BulletFlags = ProjectileFlags.HIT_ENEMIES | (k == 0 and 0 or (k < 0 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT))
								params.CurvingStrength = math.abs(k / 150)
								params.Scale = 1.8 - math.abs(k) - i * 0.4
								boss:FireProjectiles(boss.Position, Vector.FromAngle(j + boss.StateFrame):Resized(5 - i * 1.5), 0, params)
							end
						end
					end
				end
			elseif Pattern == 103 then --Rep route phase 1-2 pattern 1
				if boss.StateFrame % 7 == 1 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | 1 << 12 - (boss.StateFrame % 2) --ORBIT_CCW / ORBIT_CW
					params.ChangeTimeout = 45
					params.TargetPosition = boss.Position
					params.ChangeFlags = ProjectileFlags.HIT_ENEMIES | 1 << 19 - (boss.StateFrame % 2)
					params.CurvingStrength = 0.017
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.176

					for i=0, 315, 45 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(6.5), 0, params)
					end
				end
			elseif Pattern == 104 then --Rep route phase 1-2 pattern 2
				if boss.StateFrame % 21 == 1 then
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2
					params.Scale = 1.5

					for i=0, 300, 60 do
						for j=0, 315, 45 do
							boss:FireProjectiles(boss.Position, Vector.FromAngle(i + ((boss.StateFrame % 2) * 30)):Resized(4) + Vector.FromAngle(j):Resized(0.7), 0, params)
						end
					end
				end
			elseif Pattern == 105 then --Rep route phase 1-2 pattern 3
				if boss.StateFrame % 3 == 1 then
					if not data.Angle then
						data.Angle = 0
						data.RotationLength = 1
						data.Rotation2 = 2
					end

					if data.RotationLength > 8 and data.Rotation2 > 0 then
						data.Rotation2 = -2
					end

					if data.RotationLength < -8 and data.Rotation2 < 0 then
						data.Rotation2 = 2
					end

					data.RotationLength = data.RotationLength + data.Rotation2
					data.Angle = data.Angle + data.RotationLength

					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2
					params.Scale = 1.5

					for i=22.5, 337.5, 45 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + data.Angle):Resized(8), 0, params)
					end

					if boss.StateFrame == 1 then
						data.Angle = nil
					end
				end
			elseif Pattern == 106 then --Rep route phase 1-3.5 pattern 1
				if boss.StateFrame >= 0 and boss.FrameCount % 10 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2

					for i=0, 180, 180 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + Angle):Resized(8), 0, params)
					end
				end
			elseif Pattern == 107 then --Rep route phase 1-3.5 pattern 2
				if boss.StateFrame >= 0 and boss.StateFrame % 8 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2

					for i=0, 240, 120 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + boss.StateFrame * 2 * data.Rotation):Resized(8), 0, params)
					end
				end
			elseif Pattern == 108 then --Rep route phase 1-3.5 pattern 3
				if boss.StateFrame >= 0 and boss.StateFrame % 9 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2

					for i=0, 270, 90 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + boss.StateFrame * 22.5):Resized(7), 0, params)
					end
				end
			elseif Pattern == 109 then --Rep route phase 1-3.5 pattern 4
				if boss.StateFrame >= 0 and boss.StateFrame % 17 == 0 then
					local params = ProjectileParams()
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.HIT_ENEMIES
					params.FallingSpeedModifier = 3
					params.FallingAccelModifier = -0.2

					for i=0, 315, 45 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i + boss.StateFrame):Resized(5), 0, params)
					end
				end
			end
		elseif boss.State == 43 then
			--Normal route phase 1-3.5 hiding pattern
			if boss.I1 == 50 and sprite:IsPlaying("HeartHidingHeartbeat2") and boss.ProjectileCooldown > 0 then
				local Pattern = math.floor(boss.V1.Y)
				local CR, CA, To = REPENTANCE and 0.6 or 1.2, REPENTANCE and 0.6 or 2, REPENTANCE and 30 or 20

				if boss.Variant == 1 then --It Lives
					if boss.ProjectileCooldown > 60 then
						if Pattern == 97 and boss.StateFrame % 39 == 0 then
							local LaserPos = Vector(boss.Position.X, 120)
							boss.V2 = Vector(boss.V2.X, (target.Position - LaserPos):GetAngleDegrees())

							HMBP.SpawnLaserWarn(LaserPos, To, math.min(math.max(3, boss.V2.Y), 177), Color(CR, 0, 0, CA, 0, 0, 0), boss, Vector(0, 0), Vector(2, 1), 23, boss)
						elseif Pattern == 98 and boss.StateFrame % 51 == 0 then
							boss.V2 = Vector(boss.V2.X, boss.StateFrame % 2 == 0 and 1 or 2)

							for i=50 / boss.V2.Y - 10, 115 + 25 * boss.V2.Y, 50 do
								HMBP.SpawnLaserWarn(Vector(boss.Position.X, 120), To, i, Color(CR, 0, 0, CA, 0, 0, 0), boss, Vector(0, 0), Vector(2, 1), 23, boss)
							end
						elseif Pattern == 99 and boss.StateFrame % 35 == 10 then
							local Rotation = boss.StateFrame % 2 == 0 and 1 or -1

							EntityLaser.ShootAngle(1, Vector(boss.Position.X, 120), 90 - Rotation * 87, 52, Vector(0, 0), boss):
							SetActiveRotation(15, 87 * Rotation, 1.65 * Rotation, false)
						end
					end

					if boss.ProjectileCooldown > 30 then
						if Pattern == 97 and boss.StateFrame % 39 == 30 then
							EntityLaser.ShootAngle(1, Vector(boss.Position.X, 120), boss.V2.Y, 15, Vector(0, 0), boss)
						elseif Pattern == 98 and boss.StateFrame % 51 == 30 then
							for i=50 / boss.V2.Y - 10, 115 + 25 * boss.V2.Y, 50 do
								EntityLaser.ShootAngle(1, Vector(boss.Position.X, 120), i, 10, Vector(0, 0), boss)
							end
						end
					end
				else --Mom's Heart
					if boss.ProjectileCooldown > 30 then
						if Pattern == 97 then
							if boss.FrameCount % 2 == 0 then
								local params = ProjectileParams()
								params.Scale = 1.5
								params.FallingAccelModifier = -0.13
								boss:FireProjectiles(Vector(boss.Position.X, 150), Vector.FromAngle((boss.FrameCount * 9) % 180):Resized(5), 0, params)
							end
						elseif Pattern == 98 then
							if boss.FrameCount % 20 == 0 and boss.ProjectileCooldown > 75 then
								local XVel = boss.FrameCount % 40 == 0 and 12.5 or 15

								for i=-XVel, XVel, 5 do
									local proj = Isaac.Spawn(9, 0, 0, Vector(boss.Position.X, 150), Vector(i, 0.5), boss):ToProjectile()
									proj:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT)
									proj.Scale = 1.5
									proj.FallingAccel = -0.11
									proj.Acceleration = 0.94
									proj.ChangeVelocity = 5
									proj.ChangeFlags = 0
									proj.ChangeTimeout = 50
									proj:GetData().ChangeAngleAfterTimeout = true
									proj:GetData().ChangeAngle = 90
								end
							end
						elseif Pattern == 99 then
							if boss.FrameCount % 30 > 14 and boss.FrameCount % 3 == 0 then
								for i=15, 165, 30 do
									local params = ProjectileParams()
									params.Scale = 1.5
									params.FallingAccelModifier = -0.13
									boss:FireProjectiles(Vector(boss.Position.X, 150), Vector.FromAngle(i):Resized(5), 0, params)
								end
							end
						end
					end
				end
			end
		end
	end

	if boss.Variant == 10 and boss.Parent.SubType == 666 + boss.Parent.Variant then --Mom's Guts
		boss.Position = Vector(boss.Parent.Position.X, boss.Position.Y)
	end

  end
end, 78)

bpattern:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, boss)
	local data = boss:GetData()

	if boss.State == 8 and boss.HitPoints / boss.MaxHitPoints > 0.2 and boss.StateFrame == 1 then
		if REPENTANCE and boss.SubType == 1 then
			if data.IsHMBPEtn then --Eternal mode
				if boss.I2 == 3 then
					boss.V1 = Vector(boss.V1.X, math.random(120, 127))
				else
					boss.V1 = Vector(boss.V1.X, math.random(120, 123) + (boss.I2 - 1) * 4)
				end
			else --None eternal mode
				if math.random(1, 7) < 4 then --Rep route
					if boss.I2 == 3 then
						boss.V1 = Vector(boss.V1.X, math.random(100, 105))
					else
						boss.V1 = Vector(boss.V1.X, math.random(100, 102) + (boss.I2 - 1) * 3)
					end
				end
			end
		else
			if not data.Attacking and boss.I2 == 3 then
				data.Attacking = true

				if data.IsHMBPEtn then --Eternal mode
					boss.V1 = Vector(boss.V1.X, math.random(120, 127))
				else --None eternal mode
					boss.V1 = Vector(boss.V1.X, math.random(1, 2) == 1 and math.random(0, 7) or math.random(90, 93))
				end
			end
		end
	end
end, 78)

--[[bpattern:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	local room = Game():GetRoom()
	local sprite = boss:GetSprite()

	if Game().Difficulty % 2 == 1 and (room:GetBossID() == 8 or room:GetBossID() == 25) and HMBPEternalMode then
		if boss.Variant ~= 10 then
		else
			for i=0, 1 do
				sprite:ReplaceSpritesheet(i, "gfx/bosses/eternal/boss_78_moms guts_eternal.png")
			end

			sprite:LoadGraphics()
		end
	end
end, 78)]]

bpattern:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, boss)
	if boss.State == 17 and boss:GetSprite():IsEventTriggered("Burst") and HMBPENTS then
		local data = boss:GetData()
		local sprite = boss:GetSprite()
		local Target = boss:GetPlayerTarget()

		boss:Morph(555, (boss.Variant == 1 and Isaac.GetEntityVariantByName("Snapped It Lives")) or Isaac.GetEntityVariantByName("Snapped Mom's Heart"), boss.SubType, -1)
		boss:PlaySound(28, 1, 0, false, 1) --DEATH_BURST_LARGE
		boss.HitPoints = boss.MaxHitPoints
		boss.EntityCollisionClass = 4 --ENTCOLL_ALL
		boss.GridCollisionClass = 3 --GRIDCOLL_WALLS
		boss.State = 8 --STATE_MOVE
		boss.I2 = 0
		boss:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

		if boss.Variant == Isaac.GetEntityVariantByName("Snapped Mom's Heart") then
			data.ShootCooldown = 0

			if boss.SubType == 1 and REPENTANCE and math.abs(boss.Position.Y - Target.Position.Y) > 50 then
				sprite:Play("Dash", true)
				boss.TargetPosition = Target.Position
				boss:PlaySound(213, 1, 0, false, 1) --HEARTOUT
			else
				sprite:Play("Charge", true)
				data.XDashVel = Target.Position.X > boss.Position.X and 18 or -18
				data.Charging = true
			end
		else
			sprite:Play("ChargeStart"..(Target.Position.X > boss.Position.X and "Right" or "Left"), true)
			data.Acceleration = true
			boss:PlaySound(313, 1, 0, false, 1) --MULTI_SCREAM
			data.XDashVel = Target.Position.X > boss.Position.X and 1 or -1
			data.Charging = true
		end

		Isaac.Spawn(1000, 2, 4, boss.Position + Vector(0, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -190) --Blood Explosion
		Game():SpawnParticles(boss.Position, 5, math.random(6, 9), 3.5, Color(1, 1, 1, 1, 0, 0, 0), -30) --Blood Particle(Flesh)
	end
end, 78)

bpattern:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, damageflag, source, num)
	local boss = entity:ToNPC()

	if boss.I1 == 60 or boss.I1 == 61 or boss.State == 17 then
		return false
	end

	if entity.Variant ~= 10 and Game().Difficulty % 2 == 1 and entity.HitPoints <= amount then
		if HMBPENTS then
			boss.State = 17
			entity.EntityCollisionClass = 0
			entity:GetSprite():Play("StringBurst", true)

			for k, v in pairs(Isaac.GetRoomEntities()) do
				if v:ToProjectile() then
					v:Die()
				end

				if v:ToLaser() and v.Parent and v.Parent.InitSeed == boss.InitSeed then
					v:ToLaser().Timeout = 1
				end

				if v:IsEnemy() and v.Type ~= entity.Type then
					v:Kill()
				end
			end

			return false
		else
			--print("HMBPENTS : false")
		end
	end
end, 78)
----------------------------
--add Boss Pattern:Satan
----------------------------
  function bpattern:Satan(boss)

	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then

	local sprst = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local Entities = Isaac:GetRoomEntities()
	local angle = (target.Position - boss.Position):GetAngleDegrees()
	local Room = Game():GetRoom()
	local rng = boss:GetDropRNG()

	if not data.creeptime then
		data.creeptime = 0
	end

	data.creeptime = data.creeptime - 1

	if boss.FrameCount >= 10 and (sprst:IsFinished("SmallIdle") or sprst:IsFinished("SmallAttack")) and boss:GetAliveEnemyCount() > #Isaac.FindByType(84, 0, -1, true, true)
	and boss.FrameCount % 220 == 0 then
		boss.State = 30

		if not sprst:IsPlaying("SmallAttack") then
			sprst:Play("SmallAttack", true)
		end
	end

	if boss.State == 30 and sprst:IsPlaying("SmallAttack") then
		if sprst:GetFrame() >= 24 and sprst:GetFrame() <= 27 then
			if sprst:GetFrame() == 24 then
				boss:PlaySound(245, 0.75, 0, false, 1)
			end
			local params = ProjectileParams()
			params.Scale = 1.5
			for i=0, 40, 20 do
				boss:FireProjectiles(boss.Position, Vector.FromAngle((((sprst:GetFrame()-24)*60)+i)-20)
				:Resized(9), 0, params)
			end
		end
	end

	if sprst:IsPlaying("Attack02") and boss.State == 9
	and sprst:GetFrame() == 1 and math.random(1,2) == 1 then
		sprst:Play("Attack04",true)
		boss.State = 29
	end

	if ((sprst:IsPlaying("Attack01") and boss.State == 8 and boss.StateFrame <= 1)
	or (sprst:IsPlaying("Attack03") and boss.State == 11)) and sprst:GetFrame() == 1
	and math.random(1,2) == 1 then
		if #Isaac.FindByType(1000, 22, -1, true, true) > 0 and math.random(1,2) == 1
		and data.creeptime > 0 and HMBPENTS then
			sprst:Play("Attack07",true)
			boss.State = 32
		else
			if math.random(1,2) == 1 and Room:GetAliveEnemiesCount() <= 2 then
				sprst:Play("Summon", true)
				boss.State = 12
			elseif math.random(1,2) == 2 and boss.HitPoints/boss.MaxHitPoints <= 0.66 and HMBPENTS and not data.isdelirium and data.creeptime <= 0 then
				sprst:Play("Attack06Start", true)
				boss.State = 31
			end
		end
	end

	if boss.FrameCount % 30 == 0 and boss.State == 4 and sprst:IsPlaying("Walk") and math.abs(target.Position.Y-boss.Position.Y) <= 60
	and math.abs(target.Position.X-boss.Position.X) >= 150  then
		boss.State = 28
		sprst:Play("Attack05Ready",true)
	end

	if sprst:IsPlaying("Attack04") then
		if sprst:GetFrame() == 17 then
			boss:PlaySound(52, 1.5, 0, false, 1)
			boss:PlaySound(245, 1, 0, false, 1)
			Game():ShakeScreen(20)
			local shockwave = Isaac.Spawn(1000, 67, 0, boss.Position, Vector(0,0), boss)
			shockwave.Parent = boss
		end
		if sprst:GetFrame() >= 17 and sprst:GetFrame() <= 23 then
			local params = ProjectileParams()
			params.FallingAccelModifier = 0.7
			params.HeightModifier = -300
			params.Scale = math.random(18,23) * 0.1
			if HMBPENTS then
				params.Variant = 9
			else
				params.Variant = 3
				params.Color = Color(0.6,0.8,1,1,0,0,0)
			end
			params.BulletFlags = 1 << 1 | 1 << 31 | 1 << 32
			params.ChangeTimeout = 5
			params.ChangeFlags = 1 << 1
			boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(0,0), 0, params)
		end
	end

	if sprst:IsFinished("Attack05Ready") then
		sprst:Play("Attack05Loop",true)
		boss:PlaySound(245, 1, 0, false, 1)
		boss.Velocity = Vector.FromAngle(angle):Resized(50)
		boss.StateFrame = 20
	end

	if sprst:IsPlaying("Attack05Loop") then
		boss.StateFrame = boss.StateFrame - 1
		if boss.StateFrame <= 0 then
			sprst:Play("Attack05End",true)
		end
	end

	if (sprst:IsFinished("Attack05End") and boss.State == 28) or (sprst:IsFinished("Summon") and boss.State == 12) or
	(sprst:IsFinished("Attack04") and boss.State == 29) or (sprst:IsFinished("Attack06End") and boss.State == 31) or (sprst:IsFinished("Attack07") and boss.State == 32) then
		sprst:Play("Walk",true)
		boss.State = 4
	end

	if sprst:IsPlaying("Summon") then
		if sprst:GetFrame() == 13 then
			boss:PlaySound(243, 1, 0, false, 1)
			Isaac.Spawn(259, 0, 0, boss.Position+Vector(50,0), Vector(0,0), boss)
		end
	end

	if boss.State == 31 then
		boss.StateFrame = boss.StateFrame - 1
		if sprst:IsPlaying("Attack06Start") then
			if sprst:GetFrame() > 9 then
				boss.Velocity = Vector.FromAngle((Vector(Room:GetTopLeftPos().X+10,Room:GetCenterPos().Y)-boss.Position):GetAngleDegrees())
				:Resized(Vector(Room:GetTopLeftPos().X+10,Room:GetCenterPos().Y):Distance(boss.Position)*0.125)
			end
			if sprst:GetFrame() == 10 then
				boss:PlaySound(246, 1, 0, false, 1)
				data.NoEntCollide = true
			elseif sprst:GetFrame() == 23 then
				boss:PlaySound(240, 1, 0, false, 1)
			elseif sprst:GetFrame() == 42 then
				boss:PlaySound(241, 1, 0, false, 1)
				boss.StateFrame = 105
				local laser = Isaac.Spawn(1000, 759, 1, boss.Position-Vector(0,0.5), Vector(0,0), boss):ToEffect()
				laser.Parent = boss
				laser.Timeout = 100
				laser:FollowParent(boss)
			end
		elseif sprst:IsPlaying("Attack06Loop") then
			boss.Velocity = (boss.Velocity * 0.97) + Vector.FromAngle(0):Resized(1.6)
			if boss.StateFrame > 10 then
				if boss.StateFrame % 13 == 0 then
					for i=0, 300, 60 do
						local params = ProjectileParams()
						params.HeightModifier = 5
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i+(boss.StateFrame % 2)*30):Resized(8), 0, params)
					end
				end
				if boss.StateFrame % 5 == 0 then
					local splat = Isaac.Spawn(1000, 22, 0, boss.Position+Vector(0,4-(boss.FrameCount % 2)*8), Vector(0,0), boss):ToEffect()
					splat.Timeout = 400 + boss.StateFrame
					splat.Rotation = 90 + ((boss.FrameCount % 2)*180)
				end
			end
			if boss.StateFrame <= 0 then
				sprst:Play("Attack06End", true)
				boss.Velocity = Vector(0,0)
				data.creeptime = 370
			end
		elseif sprst:IsPlaying("Attack06End") and sprst:GetFrame() == 11 then
			data.NoEntCollide = false
		end
		if sprst:IsFinished("Attack06Start") then
			sprst:Play("Attack06Loop", true)
		end
	elseif boss.State == 32 then
		if sprst:IsPlaying("Attack07") then
			if sprst:GetFrame() == 24 then
				for k, v in pairs(Entities) do
					if v.Type == 1000 and v.Variant == 22 then
						v:GetData().massingblood = true
					end
				end
			elseif sprst:GetFrame() == 28 then
				boss:PlaySound(239, 1, 0, false, 1)
			elseif sprst:GetFrame() == 60 then
				boss:PlaySound(245, 1, 0, false, 1)
				for k, v in pairs(Entities) do
					if v.Type == 9 and v.SpawnerType == 1000 and v:GetData().shootangle then
						v:ToProjectile().FallingAccel = 0.001
						v.Velocity = Vector.FromAngle(v:GetData().shootangle):Resized(13)
					end
				end
			end
		end
	end

	if sprst:IsPlaying("Death") and not REPENTANCE then
		if ((sprst:GetFrame() > 3 and sprst:GetFrame() < 11) or (sprst:GetFrame() > 16 and sprst:GetFrame() < 31)) and sprst:GetFrame() % 2 == 0 then
			boss:PlaySound(28, 1, 0, false, 1)
			local expl = Isaac.Spawn(1000, 2, 2, boss.Position+Vector(0,1), Vector(0,0), boss)
			if sprst:GetFrame() > 3 and sprst:GetFrame() < 11 then
				expl.PositionOffset = Vector(0,-77)+Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(1,60))
			else
				expl.PositionOffset = Vector(0,-55)+Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(1,60))
			end
		end
		if sprst:GetFrame() == 30 then
			boss:PlaySound(48, 0.7, 0, false, 0.7)
		end
	end

	if data.NoEntCollide then
		boss.EntityCollisionClass = 0
	end

	for k, v in pairs(Entities) do
		if v.Type == 7 and v.Variant == 1 and v.SpawnerType == 84
		and v.FrameCount == 0 and HMBPENTS then
			v:GetData().lflag = 1
			v:GetData().pvl = 7
			v:GetData().pdensity = 18
		end
	end

  end
  end

----------------------------
--add Boss Pattern:Satan Stomp
----------------------------
  function bpattern:SatanFoot(boss)

	if boss.Variant == 10 and Game().Difficulty % 2 == 1 then

	local sprstf = boss:GetSprite()
	local data = boss:GetData()

	if not StAttackReady then
		StAttackReady = 0
	end

	if boss.State < 8 then
		if boss.FrameCount % 60 == 0 and math.random(1,6) == 1 then
			for k, v in pairs(Isaac:GetRoomEntities()) do
				for i=0, 30 do
					data.NullsPosition = Isaac.GetRandomPosition(0)
					if v.Type == 1 and data.NullsPosition:Distance(v.Position) > 170 then
						Isaac.Spawn(252, 0, 0, data.NullsPosition, Vector(0,0), boss)
						break
					end
				end
			end
		end

		if sprstf:GetFrame() == 30 and math.random(1,3) == 1 and boss.FrameCount >= boss.StateFrame + 350 and HMBPENTS then
			StAttackReady = math.random(1,2)
		end

		if StAttackReady > 0 and sprstf:GetFrame() == 80 then
			boss.StateFrame = boss.FrameCount
			boss.State = 8
		end
	end
	if not boss:GetData().isdelirium then
		if boss.State == 8 then
			if boss.FrameCount == boss.StateFrame + 50 and #Isaac.FindByType(1000, 356, -1, true, true) < math.abs(StAttackReady-3) then
				local BigDownLaser = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Giant Red Laser From Above"), StAttackReady-1, Isaac.GetRandomPosition(0), Vector(0,0), boss):ToEffect()
				BigDownLaser.Timeout = 50-StAttackReady*23
				BigDownLaser.State = 4-StAttackReady*2
			end

			if boss.FrameCount >= boss.StateFrame + 200 then
				boss.State = 3
				StAttackReady = 0
			end
		end

		if boss:IsDead() then
			StAttackReady = 0
		end
	end

	if boss:IsDead() then
		boss:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)

		if HMBPENTS and #Isaac.FindByType(666, 666, 0, true, true) < 1 then
			local Room = Game():GetRoom()

			local satan666 = Isaac.Spawn(666, 666, 0, Room:GetCenterPos()+Vector(Room:GetCenterPos().X/4,0), Vector(0,0), boss)
			satan666:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			satan666.Parent = boss
		end
	end

  end
  end

----------------------------
--add Boss pattern:The Lamb
----------------------------
  function bpattern:Lamb(boss)

	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then

	local sprl = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local dist = target.Position:Distance(boss.Position)
	local rng = boss:GetDropRNG()
	local targetangle = (target.Position - boss.Position):GetAngleDegrees()
	local Room = Game():GetRoom()

	data.planc = false

	if boss.State ~= 4 then
		if sprl:GetFrame() == 1 then
			if sprl:IsPlaying("Charge") then
				if math.random(1,3) == 1 then
					if math.random(1,3) == 1 and boss.HitPoints / boss.MaxHitPoints <= 0.75 and HMBPENTS then
						sprl:Play("AttackReady", true)
						boss.State = 12
						boss.StateFrame = 138
					else
						sprl:Play("Charge3", true)
						boss.State = 11
					end
				end
			elseif sprl:IsPlaying("HeadCharge") then
				if math.random(1,3) == 1 then
					sprl:Play("HeadCharge2", true)
					boss.State = 11
					boss:PlaySound(312 , 1, 0, false, 1)
					if sound:IsPlaying(106) then
						sound:Stop(106)
					elseif sound:IsPlaying(108) then
						sound:Stop(108)
					end
				elseif math.random(1,3) == 2 then
					if denpnapi and Room:GetAliveEnemiesCount() > 5 then
						sprl:Play("HeadSummon", true)
						boss.State = 13
						if sound:IsPlaying(106) then
							sound:Stop(106)
						elseif sound:IsPlaying(108) then
							sound:Stop(108)
						end
					end
				else
					for k, v in pairs(Isaac.FindByType(400, 0, -1, true, true)) do
						if v.Parent and v.Parent.InitSeed == boss.InitSeed and math.random(0,2) == 1 and HMBPENTS and not data.isdelirium then
							sprl:Play("HeadAttackReady", true)
							boss.State = 12
							boss.StateFrame = 0
							boss.I2 = math.random(4,7)

							break
						end
					end
				end
			end
		end

		if sprl:IsFinished("Charge2") then
			sprl:Play("Blast", true)
			boss.I2 = 0
			boss.StateFrame = math.random(80,120)
		elseif sprl:IsFinished("Charge3") then
			sprl:Play("Swarm3", true)
		elseif sprl:IsFinished("HeadShoot2Start") then
			sprl:Play("HeadShoot2Loop", true)
		elseif sprl:IsFinished("Swarm3") or sprl:IsFinished("Blast") or sprl:IsFinished("HeadShoot3") then
			if boss.I1 == 1 then
				sprl:Play("Idle", true)
			else
				sprl:Play("HeadIdle", true)
			end
			boss.State = 4
		elseif sprl:IsFinished("HeadCharge2") then
			sprl:Play("HeadShoot3", true)
		end
	end

	if boss.State == 12 then
		if boss.I1 ~= 1 then
			boss.PositionOffset = Vector(0,
			boss.PositionOffset.Y-((boss.PositionOffset.Y+40)*0.15))
			boss.EntityCollisionClass = 0
		end
		if sprl:IsFinished("HeadAttackReady") then
			sprl:Play("HeadAttackReadyLoop", true)
		end
		if sprl:IsPlaying("AttackReady") then
			boss.Velocity = Vector(0,0)
		else
			if boss.I1 == 1 then
				boss.StateFrame = boss.StateFrame - 1
				if boss.StateFrame == 113 then
					sprl:Play("StompAttack", true)
				end
			else
				boss.StateFrame = boss.StateFrame + 1
				if boss.StateFrame == 50 or (boss.I2 > 0 and sprl:GetFrame() == 75 and boss.StateFrame > 50) then
					if boss.I2 % 2 == 1 then
						if math.random(1,2) == 1 then
							sprl:Play("HeadStompUp", true)
						else
							sprl:Play("HeadStompDown", true)
						end
					else
						sprl:Play("HeadStompHori", true)
						if math.random(0,1) == 1 then
							boss.FlipX = true
						else
							boss.FlipX = false
						end
					end
				end
			end
			boss.Velocity = Vector.FromAngle((Room:GetCenterPos() - boss.Position):GetAngleDegrees()):Resized(Room:GetCenterPos():Distance(boss.Position)*0.14)
		end
	elseif boss.State == 13 then
		boss.Velocity = Vector(0,0)
		if sprl:IsPlaying("HeadSummon") then
			if sprl:GetFrame() == 15 then
				boss:PlaySound(122 , 1, 0, false, 1)
			elseif sprl:GetFrame() == 32 then
				if denpnapi then
					boss:PlaySound(265 , 1, 0, false, 1)
					Isaac.Spawn(554, Isaac.GetEntityVariantByName("Little Fallen"), 0, boss.Position+Vector(0,50), Vector(0,0), boss)
				end
			end
		else
			sprl:Play("HeadIdle", true)
			boss.State = 4
			boss.StateFrame = math.random(90,140)
		end
	end

	if sprl:IsPlaying("HeadIdle") then
		boss.PositionOffset = Vector(0,
		boss.PositionOffset.Y-(boss.PositionOffset.Y*0.15))
	end

	if sprl:IsPlaying("StompAttack") then
		if sprl:GetFrame() == 1 then
			for i=-130, 130, 260 do
				Isaac.Spawn(507, 0, 0, boss.Position + Vector(0, 0), Vector(0, 0), boss)
			end
		elseif sprl:GetFrame() == 60 then
			for i=-170, 170, 340 do
				Isaac.Spawn(507, 0, 0, boss.Position + Vector(i, 0), Vector(0, 0), boss)
			end
		elseif sprl:GetFrame() == 22 or sprl:GetFrame() == 81 then
			boss:PlaySound(306 , 1.3, 0, false, 1)
		end
	elseif sprl:IsFinished("StompAttack") then
		sprl:Play("Idle", true)
		boss.State = 4
		boss.StateFrame = math.random(90,140)
	end

	if sprl:IsPlaying("HeadStompUp") or sprl:IsPlaying("HeadStompDown") or sprl:IsPlaying("HeadStompHori") then
		if sprl:GetFrame() == 1 then
			boss.I2 = boss.I2 - 1
			if sprl:IsPlaying("HeadStompDown") then
				Isaac.Spawn(507, 0, 1, boss.Position + Vector(0, 75), Vector(0, 0), boss)
			elseif sprl:IsPlaying("HeadStompUp") then
				Isaac.Spawn(507, 0, 1, boss.Position - Vector(0, 75), Vector(0, 0), boss)
			elseif sprl:IsPlaying("HeadStompHori") then
				if boss.FlipX then
					Isaac.Spawn(507, 0, 1, boss.Position - Vector(170, 0), Vector(0, 0), boss)
				else
					Isaac.Spawn(507, 0, 1, boss.Position + Vector(170, 0), Vector(0, 0), boss)
				end
			end
		end
		if sprl:GetFrame() == 36 then
			boss:PlaySound(306 , 1.3, 0, false, 1)
		end
	end

	if sprl:IsFinished("HeadStompUp") or sprl:IsFinished("HeadStompDown") or sprl:IsFinished("HeadStompHori") then
		sprl:Play("HeadIdle", true)
		boss.State = 4
		boss.StateFrame = math.random(90,140)
		boss.EntityCollisionClass = 4
	end

	if (sprl:IsPlaying("Swarm3") or sprl:IsPlaying("HeadShoot3")) and sprl:IsEventTriggered("Shoot2") then
		boss:PlaySound(305 , 1, 0, false, 1)
	elseif (sprl:IsPlaying("Swarm3") or sprl:IsPlaying("HeadShoot3")) and sprl:GetFrame() == 35 then
		boss.StateFrame = math.random(80,120)
	end

	if (sprl:IsPlaying("Swarm2Start") or sprl:IsPlaying("HeadShoot2Start")) and sprl:GetFrame() == 2 and math.random(1,5) <= 2 and boss.I2 ~= 0 then
		boss.I2 = 10
	elseif (sprl:IsPlaying("Swarm2End") or sprl:IsPlaying("HeadShoot2End")) and sprl:GetFrame() == 10 then
		boss.I2 = 0
	end

	if boss.I2 == 10 then
		if boss.FrameCount % 40 == 0 then
			boss:PlaySound(116 , 1, 0, false, 1)
		end
		if sprl:IsPlaying("Swarm2Loop") or sprl:IsPlaying("Swarm2Start") then
			if boss.FrameCount % 3 == 0 then
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.165
				params.HeightModifier = -5
				params.Scale = 2
				params.Color = Color(0.11,1.5,2,1,0,0,0)
				params.Acceleration = 0.8
				boss:FireProjectiles(boss.Position, Vector.FromAngle(boss.FrameCount * 16):Resized(3.75), 0, params)
			end
		elseif sprl:IsPlaying("HeadShoot2Start") or sprl:IsPlaying("HeadShoot2Loop") then
			if boss.FrameCount % 33 == 0 then
				local params = ProjectileParams()
				params.Scale = 2
				params.Color = Color(0.11,1.5,2,1,0,0,0)
				params.BulletFlags = 2
				boss:FireProjectiles(boss.Position, Vector.FromAngle(targetangle):Resized(10), 0, params)
			end
			if boss.FrameCount % 4 == 0 then
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.17
				params.Color = Color(0.11,1.5,2,1,0,0,0)
				for i=30, 330, 60 do
					boss:FireProjectiles(boss.Position, Vector.FromAngle(targetangle+i):Resized(15), 0, params)
				end
			end
		end
	end

	if sprl:IsPlaying("Swarm2End") and sprl:GetFrame() == 4 and boss.I2 == 10 and boss.I1 == 1 then
		sprl:Play("Charge2", true)
		boss:PlaySound(112 , 1, 0, false, 1)
		boss.I2 = 0

		for k, v in pairs(Isaac.FindByType(9, 0, 0, true, true)) do
			if v.SpawnerType == 273 and v.SpawnerVariant == 0 then
				v:ToProjectile():AddProjectileFlags(ProjectileFlags.ACCELERATE)
			end
		end
	end

	if sprl:IsPlaying("Death") then
		boss.I2 = 0
		data.skill = false
		data.angle = 0
	end

	if sprl:IsPlaying("Swarm3") then
		if sprl:GetFrame() == 4 then
			local flame = Isaac.Spawn(1000, 10, 0, boss.Position ,Vector(0,0), boss):ToEffect()
			flame.Parent = boss
			flame.Visible = false
			flame:FollowParent(boss)
			flame.PositionOffset = Vector(0,-29)
		elseif sprl:GetFrame() == 48 then
			boss.Child:Remove()
		end
		if boss.FrameCount % 3 == 0 then
			local params = ProjectileParams()
			params.FallingSpeedModifier = -50
			params.FallingAccelModifier = 2
			params.HeightModifier = -15
			params.Scale = math.random(10,20) * 0.1
			params.Color = Color(0.11,1.5,2,1,0,0,0)
			params.BulletFlags = 2
			if math.random(1,3) == 1 then
				boss:FireProjectiles(boss.Position, Vector.FromAngle(targetangle+math.random(-2,2)):Resized(dist*(20 * 0.0015)), 0, params)
			else
				boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(30,55)*0.1), 0, params)
			end
		end
	elseif sprl:IsPlaying("HeadShoot3") and boss.FrameCount % 2 == 0 then
		local params = ProjectileParams()
		params.GridCollision = false
		params.FallingSpeedModifier = -math.random(3,7)
		params.FallingAccelModifier = -0.1
		params.HeightModifier = -24
		params.Scale = math.random(10,20) * 0.1
		params.Color = Color(0.11,1.5,2,1,0,0,0)
		params.BulletFlags = ProjectileFlags.CONTINUUM
		boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(4,8)), 0, params)
	end

	if sprl:IsPlaying("Blast") then
		if sprl:IsEventTriggered("Shoot2") then
			boss:PlaySound(306, 1.3, 0, false, 1)
			data.DetonateDist = 0
		end

		if sprl:WasEventTriggered("Shoot2") and sprl:GetFrame() % 2 == 0 then
			data.DetonateDist = data.DetonateDist + 80

			for k, v in pairs(Isaac.FindByType(9, 0, 0, true, true)) do
				if v.SpawnerType == 273 and v.SpawnerVariant == 0 and v.Position:Distance(boss.Position) <= data.DetonateDist then
					v:ToProjectile():AddProjectileFlags(ProjectileFlags.EXPLODE)
					v:Die()
				end
			end
		end
	end

  end
  end

----------------------------
--Isaac And His Fate
----------------------------
  function bpattern:IsaacAndBlueBaby(isaac)

	local sprme = isaac:GetSprite()
	local target = isaac:GetPlayerTarget()
	local data = isaac:GetData()

	if Game().Difficulty % 2 == 1 then
		if sprme:IsPlaying("1Idle") and isaac.State == 8
		and math.random(1,3) == 1 then
			isaac.State = 20
			isaac.StateFrame = 70
		end

		if isaac.State == 20 then
			if sprme:IsPlaying("1Idle") then
				sprme:Play("1Attack2",true)
			elseif sprme:IsPlaying("1Attack2") then
				if sprme:GetFrame() == 56 then
					isaac:PlaySound(267, 1, 0, false, 1)
					if isaac.Variant == 0 then
						if HMBPENTS then
							local params = HMBPEnts.ProjParams()
							params.FallingAccelModifier = 0.5

							for i=0, math.random(7,10) do
								if i >= 7 then
									params.Scale = 1.5
									params.HMBPBulletFlags = HMBPEnts.ProjFlags.LEAVES_ACID
								else
									params.Scale = math.random(7, 13) * 0.1
								end

								params.FallingSpeedModifier = -math.random(130, 180) * 0.1
								HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(isaac:GetDropRNG():RandomInt(359)):Resized(math.random(10,70) * 0.1), params)
							end
						else
							local params = ProjectileParams()
							params.Variant = 4
							params.FallingAccelModifier = 0.5

							for i=0, math.random(7, 13) do
								params.Scale = 0.7 + math.random(0, 3) * 0.3
								params.FallingSpeedModifier = -math.random(130, 180) * 0.1
								isaac:FireProjectiles(isaac.Position, Vector.FromAngle(isaac:GetDropRNG():RandomInt(359)):Resized(math.random(10, 70) * 0.1), 0, params)
							end
						end
					elseif isaac.Variant == 1 then
						local params = ProjectileParams()
						params.Scale = 1.3
						params.BulletFlags = 1
						params.FallingAccelModifier = -0.05
						for i=0, 330, 30 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+
							(target.Position-isaac.Position):GetAngleDegrees()):Resized(10), 0, params)
						end
					elseif isaac.Variant == 2 then
						local params = ProjectileParams()
						params.Scale = 1.3
						params.Variant = 6
						params.FallingAccelModifier = -0.165
						params.BulletFlags = math.random(1, 2) == 1 and ProjectileFlags.ORBIT_CW or ProjectileFlags.ORBIT_CCW
						params.Color = Color(0.8, 0.8, 1.3, 1, 0, 0, 0)
						params.TargetPosition = isaac.Position

						for i=0, 340, 20 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(6), 0, params)
						end
					end
				end
			end
			if sprme:IsFinished("1Attack2") then
				sprme:SetFrame("1Attack", 15)
				isaac.State = 8
			end
		end
		if isaac.Variant < 2 and (isaac.State == 9 or isaac.State == 20 or isaac.State == 66)  then
			for k, v in pairs(Isaac.FindByType(9, -1, -1, true, true)) do
				if v.SpawnerType == 102 and v.FrameCount < 2 and v:ToProjectile().ProjectileFlags < 2 and v:ToProjectile().FallingAccel == 0
				and isaac.Position:Distance(v.Position) < 2 then
					v:Remove()
				end
			end
		end
	end

	if denpnapi then
		if sprme:IsEventTriggered("Feather") then
			Game():SpawnParticles(isaac.Position, Isaac.GetEntityVariantByName("Feather Particle"), math.random(6,13), 13, Color(1,1,1,1,0,0,0), -20)
		end

		if Game().Difficulty % 2 == 1 then
			if not data.finalform and isaac.HitPoints / isaac.MaxHitPoints <= 0.3
			and isaac.Variant <= 1 then
				data.finalform = true
				isaac.State = 155
				sprme:Play("4Evolve",true)
				isaac.FlipX = false
			end

			if data.finalform and isaac.State < 33 then
				isaac.Visible = true
				isaac.State = 155
				sprme:Play("4Evolve",true)
			end

			if isaac.State == 155 then
				if sprme:IsPlaying("4Evolve") then
					if sprme:GetFrame() == 24 then
						isaac:PlaySound(266, 1, 0, false, 1.05)
						if isaac.Variant == 1 then
							isaac.I1 = 2
						end
					end
				else
					isaac.State = 33
					isaac.TargetPosition = Isaac.GetRandomPosition(0)
				end
			end
		end
	end

	end

----------------------------
--add Boss Pattern:Isaac
----------------------------
  function bpattern:Isaac(isaac)

	if isaac.Variant == 0 and Game().Difficulty % 2 == 1 then

	local spri = isaac:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local target = isaac:GetPlayerTarget()
	local data = isaac:GetData()
	local Room = Game():GetRoom()

	if not data.door then
		if Room:GetRoomShape() >= 8 then
			data.door = 8
		elseif Room:GetRoomShape() >= 6 then
			data.door = 6
		elseif Room:GetRoomShape() >= 4 then
			data.door = 6
		else
			data.door = 4
		end
	end

	if ((spri:IsPlaying("2Idle") and isaac.State == 3) or (spri:IsPlaying("2Attack") and isaac.State == 8))
	and isaac.FrameCount % 90 == 0 and Room:GetAliveEnemiesCount() <= 3 and denpnapi then
		Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0,
		isaac.Position + Vector(math.random(10, 30), 0):Rotated((target.Position - isaac.Position):GetAngleDegrees()), Vector(0,0), isaac)
	end

	if spri:IsFinished("2Evolve") then
		data.i3 = math.random(4,7)
	end

	if isaac.State == 100 then
		if not spri:IsPlaying("4FBAttack4") then
			spri:Play("4FBAttack4",true)
		else
			if spri:GetFrame() == 17 then
				isaac:PlaySound(129, 1, 0, false, 1)
				local rlwv = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave (Radial)"), 0, isaac.Position, Vector(0,0), isaac):ToEffect()
				rlwv.Timeout = 150
				rlwv.Scale = 1.15
			elseif spri:GetFrame() == 51 then
				isaac.State = 33
				isaac.StateFrame = math.random(70,170)
			end
		end
	elseif isaac.State == 99 then
		isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
		if isaac.ProjectileCooldown == 200 then
			spri:Play("4FBAttack3Ready",true)
		elseif isaac.ProjectileCooldown == 134 then
			isaac:PlaySound(129, 1, 0, false, 1)
		elseif isaac.ProjectileCooldown == 30 then
			spri:Play("4FBAttack3End",true)
		elseif isaac.ProjectileCooldown <= 0 then
			isaac.State = 33
			isaac.StateFrame = math.random(70,170)
		end
		if spri:IsFinished("4FBAttack3Ready") then
			spri:Play("4FBAttack3Start",true)
		elseif spri:IsFinished("4FBAttack3Start") then
			spri:Play("4FBAttack3Loop2",true)
		end
		if isaac.ProjectileCooldown >= 50 and isaac.ProjectileCooldown <= 134 and isaac.ProjectileCooldown % 2 == 0 then
			isaac:PlaySound(267, 1, 0, false, 1)

			for i=0, 240, 120 do
				local Proj = Isaac.Spawn(557, Isaac.GetEntityVariantByName("Pupula Tear Projectile"), 0, isaac.Position, Vector.FromAngle(i+isaac.FrameCount*6):Resized(7), isaac)
				Proj:GetData().PNPCScale = 2.5
			end
		end
	elseif isaac.State == 88 then
		if spri:IsPlaying("4Appear") then
			isaac.Visible = true
			if spri:GetFrame() == 1 then
				isaac.I1 = isaac.I1 - 1
				isaac.Position = target.Position
			elseif spri:GetFrame() == 10 then
				isaac.EntityCollisionClass = 4
				isaac:PlaySound(52, 1, 0, false, 1)

				for i=0, 1 do
					local Start = i == 0 and 30 or 0

					for j=Start, 300 + Start, 60 do
						local lwavel = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 27 + i, isaac.Position + Vector.FromAngle(j):Resized(20), Vector(0,0), isaac)
						lwavel.Parent = isaac
						lwavel:ToEffect().Rotation = j
						lwavel:ToEffect().LifeSpan = 70
					end
				end
			end
		end
		if spri:IsFinished("4Appear") then
			if isaac.I1 > 0 then
				spri:Play("4FBAttack",true)
			else
				isaac.State = 33
				isaac.StateFrame = math.random(70,170)
			end
		end
		if spri:IsPlaying("4FBAttack") then
			if spri:GetFrame() >= 24 then
				isaac.Visible = false
				isaac.EntityCollisionClass = 0
			elseif spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
			end
		end
		if spri:IsFinished("4FBAttack") then
			spri:Play("4Appear",true)
			isaac:PlaySound(214, 1, 0, false, 1)
		end
	elseif isaac.State == 80 then
		isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
		if isaac.ProjectileCooldown <= 0 and spri:IsPlaying("4FBAttack2Loop") then
			spri:Play("4FBAttack2End",true)
		end
		if isaac.ProjectileCooldown > 0 and isaac.FrameCount % 5 == 0 then
			isaac:PlaySound(267, 0.65, 0, false, 1)

			local params = ProjectileParams()
			params.Variant = 4
			params.FallingSpeedModifier = 0

			if isaac.I1 == 1 then
				params.BulletFlags = ProjectileFlags.SAWTOOTH_WIGGLE
				params.FallingAccelModifier = -0.175
				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(7), 0, params)
				end
				if isaac.FrameCount % 2 == 0 then
					local params2 = ProjectileParams()
					params2.Variant = 4
					params2.FallingSpeedModifier = 0
					params2.FallingAccelModifier = -0.175
					for i=0, 315, 45 do
						isaac:FireProjectiles(isaac.Position,
						Vector.FromAngle(i+((isaac.FrameCount % 4)/2)*22.5):Resized(7), 0, params2)
					end
				end
			elseif isaac.I1 == 2 then
				params.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE
				params.CurvingStrength = 0.014
				params.FallingAccelModifier = -0.16
				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(9), 0, params)
				end
			elseif isaac.I1 == 3 then
				params.BulletFlags = 1 << (18 + isaac.FrameCount % 2) | ProjectileFlags.NO_WALL_COLLIDE
				| ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.ACCELERATE
				params.CurvingStrength = 0.014
				params.Acceleration = 0.98
				params.FallingAccelModifier = -0.165
				params.ChangeTimeout = 42
				params.ChangeFlags = 0

				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+isaac.ProjectileCooldown*3):Resized(15), 0, params)
				end
			end
		end
		if spri:IsPlaying("4FBAttack2Start") and spri:GetFrame() == 21 then
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac.ProjectileCooldown = math.random(20,50)
		end
		if spri:IsFinished("4FBAttack2Start") then
			spri:Play("4FBAttack2Loop",true)
		elseif spri:IsFinished("4FBAttack2End") then
			isaac.State = 33
			isaac.StateFrame = math.random(70,170)
		end
	elseif isaac.State == 33 then
		isaac.StateFrame = isaac.StateFrame - 1
		if not spri:IsPlaying("4Idle") then
			spri:Play("4Idle",true)
		end
		if ((data.isdelirium and isaac.FrameCount % 100 == 0) or (not data.isdelirium and isaac.FrameCount % 50 == 0)) and spri:IsPlaying("4Idle") then
			isaac:PlaySound(267, 0.65, 0, false, 1)
			local params = ProjectileParams()
			params.Scale = 1.3
			params.Variant = 4
			params.FallingSpeedModifier = 0
			params.FallingAccelModifier = -0.12
			for i=0, 330, 30 do
				isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(6), 0, params)
			end
		end
		if isaac.StateFrame <= 0 then
			if math.random(1,4) == 1 and not data.isdelirium then
				spri:Play("4FBAttack",true)
				isaac.State = 88
				isaac.I1 = math.random(1,3)
			elseif math.random(1,4) == 2 and denpnapi then
				isaac.State = 99
				isaac.ProjectileCooldown = 201
			elseif math.random(1,4) == 3 and HMBPENTS then
				isaac.State = 100
			else
				spri:Play("4FBAttack2Start",true)
				isaac.State = 80
				isaac.I1 = math.random(1,3)
				isaac.ProjectileCooldown = 0
			end
		end
		if isaac.TargetPosition:Distance(isaac.Position) <= 75 then
			isaac.TargetPosition = Isaac.GetRandomPosition(0)
		end
		if spri:IsPlaying("4Idle") then
			if data.isdelirium then
				data.vlength = 0.4
			else
				data.vlength = 0.9
			end
			isaac.Velocity = (isaac.Velocity * 0.9999) + Vector.FromAngle((isaac.TargetPosition - isaac.Position):GetAngleDegrees()):Resized(data.vlength)
		else
			isaac.Velocity = isaac.Velocity * 0.99
		end
	elseif isaac.State == 28 then
		if spri:IsPlaying("3FBAppear2") then
			if spri:GetFrame() == 1 then
				isaac:PlaySound(214, 1, 0, false, 1)
			elseif spri:GetFrame() == 26 then
				isaac:PlaySound(52, 1, 0, false, 1)
				for i = 0, 315, 45 do
					local lwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, isaac.Position + Vector.FromAngle(i):Resized(20), Vector(0,0), isaac)
					lwave.Parent = isaac
					lwave:ToEffect().Rotation = i
				end
			end
			if spri:GetFrame() <= 25 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end

		if spri:IsFinished("3FBAttack3") then
			spri:Play("3FBAppear2",true)
			isaac.Position = target.Position
		elseif spri:IsFinished("3FBAppear2") then
			isaac.State = 3
		end
	elseif isaac.State == 15 then
		isaac.StateFrame = isaac.StateFrame + 1
		if isaac.Velocity.X < 0 then
			isaac.FlipX = true
		else
			isaac.FlipX = false
		end
		if spri:IsFinished("3FBAttack6Ready") then
			isaac.StateFrame = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac.Velocity = Vector.FromAngle((target.Position-isaac.Position):GetAngleDegrees()):
			Resized(32)
		end
		if not spri:IsPlaying("3FBAttack6Ready") then
			if isaac.Velocity.Y < 0 then
				isaac:SetSpriteFrame("3FBAttack6Up", isaac.StateFrame+1)
			else
				isaac:SetSpriteFrame("3FBAttack6Down", isaac.StateFrame+1)
			end
			if isaac.FrameCount % 3 == 0 and isaac.StateFrame <= 15 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.Acceleration = 0.94
				for i=90, 130, 40 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()-i):Resized(13), 0, params)
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()+i):Resized(13), 0, params)
				end
			end
			if isaac.StateFrame >= 36 then
				isaac.FlipX = false
				if isaac.I1 <= 0 then
					spri:SetFrame("3FBAttack4End", 27)
					isaac.State = 8
				else
					isaac.I1 = isaac.I1 - 1
					spri:Play("3FBAttack6Ready",true)
				end
			end
		end
	elseif isaac.State == 12 then
		if spri:IsPlaying("3FBAttack3") then
			if spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
				isaac.I1 = 6
				for i=1, 3 do
					Isaac.Spawn(1000, 19, 999, Isaac.GetRandomPosition(0), Vector(0,0), isaac)
				end
			elseif spri:GetFrame() == 26 then
				isaac.Visible = false
			end
			if spri:GetFrame() >= 22 then
				isaac.EntityCollisionClass = 0
			end
		end
		if not isaac.Visible then
			if Room:GetAliveEnemiesCount() <= 4 and isaac.FrameCount % 30 == 0 then
				isaac.I1 = isaac.I1 - 1
				if isaac.I1 > 1 then
					Isaac.Spawn(1000, 19, 999, Isaac.GetRandomPosition(0), Vector(0,0), isaac)
				end
			end
			if isaac.I1 <= 0 and Room:GetAliveEnemiesCount() <= 1 then
				isaac.Visible = true
				isaac.State = 28
				spri:Play("3FBAppear2",true)
				isaac.Position = target.Position
			end
		end
		if spri:IsPlaying("3Summon") and spri:GetFrame() == 11 then
			isaac.I1 = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac:PlaySound(265, 1, 0, false, 1)

			if math.random(1, 2) == 2 and denpnapi then
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0, isaac.Position+Vector.FromAngle(90):Resized(40), Vector(0,0), isaac)
			else
				Isaac.Spawn(38, 1, 0, isaac.Position+Vector.FromAngle(90):Resized(40), Vector(0,0), isaac)
			end
		end
		if spri:IsFinished("3Summon") then
			spri:Play("3Idle",true)
			isaac.State = 3
		end
	elseif isaac.State == 10 then
		if spri:IsFinished("3FBAttack3") then
			if isaac.I1 > 0 then
				spri:Play("3Appear",true)
				data.i3 = math.random(0,7)
				data.dash = false
				if data.i3 == 0 then
					isaac.Position = Room:GetTopLeftPos()
				elseif data.i3 == 1 then
					isaac.Position = Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y)
				elseif data.i3 == 2 then
					isaac.Position = Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y)
				elseif data.i3 == 3 then
					isaac.Position = Room:GetBottomRightPos()
				else
					isaac.Position = Room:GetDoorSlotPosition(math.random(0,data.door))
					isaac.StateFrame = 55
				end
			else
				if HMBPENTS then
					isaac.State = 28
					isaac.EntityCollisionClass = 0
				else
					spri:Play("3Appear",true)
					isaac.Position = Isaac.GetRandomPosition(0)
				end
			end
		end
		if spri:IsFinished("3Appear") then
			if isaac.I1 > 0 then
				if data.i3 > 3 then
					spri:Play("3Idle",true)
					isaac.StateFrame = 50
				else
					spri:Play("3FBAttack6Ready",true)
				end
			else
				isaac.State = 3
			end
		end
		if data.i3 < 4 then
			isaac.StateFrame = isaac.StateFrame + 1
		if isaac.Velocity.X < 0 then
			isaac.FlipX = true
		else
			isaac.FlipX = false
		end
		if spri:IsFinished("3FBAttack6Ready") and not data.dash then
			isaac.StateFrame = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			data.dash = true
			if data.i3 == 0 then
				isaac.Velocity = Vector.FromAngle((Room:GetBottomRightPos()-isaac.Position)
				:GetAngleDegrees()):Resized(Room:GetBottomRightPos():Distance(isaac.Position)*0.11)
			elseif data.i3 == 1 then
				isaac.Velocity = Vector.FromAngle((Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y)-isaac.Position)
				:GetAngleDegrees()):Resized(Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y):Distance(isaac.Position)*0.11)
			elseif data.i3 == 2 then
				isaac.Velocity = Vector.FromAngle((Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y)-isaac.Position)
				:GetAngleDegrees()):Resized(Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y):Distance(isaac.Position)*0.11)
			elseif data.i3 == 3 then
				isaac.Velocity = Vector.FromAngle((Room:GetTopLeftPos()-isaac.Position)
				:GetAngleDegrees()):Resized(Room:GetTopLeftPos():Distance(isaac.Position)*0.11)
			end
		end
		if data.dash then
			if isaac.Velocity.Y < 0 then
				isaac:SetSpriteFrame("3FBAttack6Up", isaac.StateFrame+1)
			else
				isaac:SetSpriteFrame("3FBAttack6Down", isaac.StateFrame+1)
			end
			if isaac.FrameCount % 2 == 0 and isaac.StateFrame <= 20 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.Acceleration = 1.075
				params.FallingAccelModifier = -0.1
				for i=-90, 90, 180 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()+i):Resized(0.5), 0, params)
				end
			end
			if isaac.StateFrame >= 36 and not spri:IsPlaying("3FBAttack3") then
				isaac.FlipX = false
				isaac.I1 = isaac.I1 - 1
				data.i3 = 0
				spri:Play("3FBAttack3",true)
				data.dash = false
			end
		end
		else
		if spri:IsPlaying("3Idle") then
			isaac.StateFrame = isaac.StateFrame - 1
			if isaac.StateFrame > 0 then
				if isaac:HasEntityFlags(1<<9) then
					angle = angle + 3
				else
					angle = (target.Position - isaac.Position):GetAngleDegrees()
				end
			end
			isaac.Velocity = (isaac.Velocity * 0.9) + Vector.FromAngle(angle):Resized(2.05)
			if isaac.FrameCount % 8 == 0 and isaac.I1 > 0 then
				isaac:PlaySound(153, 1, 0, false, 1)
				local params = ProjectileParams()
				params.Scale = 1.5
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.BURST
				isaac:FireProjectiles(isaac.Position, Vector(0,0), 0, params)
			end
			if isaac.StateFrame <= 0 then
				isaac.I1 = isaac.I1 - 1
				spri:Play("3FBAttack3",true)
			end
		end
		end
	elseif isaac.State == 9 then
		if spri:IsPlaying("2Attack2") and spri:GetFrame() == 28 then
			for i=10, 280, 90 do
				local Laser = EntityLaser.ShootAngle(3, isaac.Position+Vector(0,1), i+(math.floor(data.i3/(10^((i-10)/90))) % 10)*7, 20, Vector(0,-20), isaac)
				Laser.CollisionDamage = 22.5
			end
		end
		if spri:IsFinished("2Attack2") then
			data.i3 = 0
			isaac.I1 = -1
			spri:SetFrame("2Attack", 29)
			isaac.State = 8
		end
		if spri:IsPlaying("3Appear") and not data.isdelirium and HMBPETNS then
			isaac.State = 28
			spri:Play("3FBAppear2",true)
			isaac.Position = target.Position
			isaac.EntityCollisionClass = 0
		end
		if spri:IsPlaying("3FBAttack3") and spri:GetFrame() == 1 then
			if math.random(1,3) == 1 then
				isaac.State = 10
				isaac.I1 = math.random(2, 4)
			elseif math.random(1,3) == 2 then
				isaac.State = 12
			end
		end
		if spri:IsPlaying("1Attack") then
			if data.i3 > 0 then
				if isaac.I1 == 1 then
					if (data.i3 < data.start and spri:GetFrame() == 5) or (data.i3 >= data.start and spri:GetFrame() == 9) then
						spri:Play("1Attack",true)
					end
				elseif isaac.I1 == 2 then
					if spri:GetFrame() == 12 then
						spri:Play("1Attack",true)
					end
				end
				if spri:GetFrame() == 1 then
					data.i3 = data.i3 - 1
				end
			end
			if data.i3 < data.start and spri:GetFrame() == 1 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4

				if isaac.I1 == 1 then
					if HMBPENTS then
						local params2 = HMBPEnts.ProjParams()
						params2.FallingSpeedModifier = -30
						params2.FallingAccelModifier = 1.2
						params2.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params2.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params2.ChangeTimeout = 28
						params2.ChangeFlags = 0
						params2.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.NOFALL
						params2.CurvingStrength = 0.016

						for i=0, 315, 45 do
							HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(i):Resized(13), params2)
						end
					else
						params.FallingSpeedModifier = -30
						params.FallingAccelModifier = 1.2
						params.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params.ChangeTimeout = 28
						params.ChangeFlags = 0
						params.CurvingStrength = 0.016

						for i=0, 315, 45 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(13), 0, params)
						end
					end
				elseif isaac.I1 == 2 then
					params.FallingSpeedModifier = -40
					params.FallingAccelModifier = 1
					params.BulletFlags = ProjectileFlags.ACCELERATE
					params.Acceleration = 0.945
					params.Scale = 1
					for i=-3.5, 3.5, 1 do
						isaac:FireProjectiles(isaac.Position, Vector(12*1.2,(i*1.2)*2), 0, params)
						isaac:FireProjectiles(isaac.Position, Vector(-12*1.2,(i*1.2)*2), 0, params)
					end
					for i=-6, 6, 1 do
						isaac:FireProjectiles(isaac.Position, Vector((i*1.2)*2,7*1.2), 0, params)
						isaac:FireProjectiles(isaac.Position, Vector((i*1.2)*2,-7*1.2), 0, params)
					end
				end
			end
		end
		if spri:IsFinished("1Attack") then
			isaac.State = 8
		end
	elseif isaac.State == 8 then
		if spri:IsPlaying("1Idle") and math.random(1,2) == 1 then
			isaac.State = 9
			spri:Play("1Attack",true)
			isaac.I1 = math.random(1, 2)
			data.i3 = isaac.I1 == 2 and math.random(3, 4) or  math.random(4, 7)
			data.start = data.i3 - 1
		end
		if spri:IsPlaying("2Attack") then
			if data.LsrReady and spri:GetFrame() == 1 then
				data.LsrReady = false
				spri:Play("2Attack2",true)
				isaac.State = 9
				data.i3 = 0
				for i=0, 3 do
					data.i3 = data.i3+math.random(0,9)*(10^i)
				end
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.HeightModifier = -12
				params.FallingAccelModifier = 0.1
				params.Acceleration = 0.9
				for i=10, 280, 90 do
					isaac:FireProjectiles(isaac.Position,
					Vector.FromAngle(i+(math.floor(data.i3/(10^((i-10)/90))) % 10)*7):Resized(10), 0, params)
				end
			end
			if isaac.I1 == 1 and spri:GetFrame() == 2 then
				data.LsrReady = true
			end
		end
		if spri:IsPlaying("3FBAttack4Start") and spri:GetFrame() == 1 then
			if math.random(1,3) == 2 and Room:GetAliveEnemiesCount() <= 2 and isaac.FrameCount % 100 <= 30 then
				spri:Play("3Summon",true)
				isaac.State = 12
			elseif math.random(1,3) == 3 then
				targetangle = (target.Position - isaac.Position):GetAngleDegrees()
				isaac.State = 15
				isaac.I1 = math.random(1,3)
				spri:Play("3FBAttack6Ready",true)
			end
		end
	elseif isaac.State == 0 then
		data.LsrReady = false
	end

	if isaac.State > 9 then
		if spri:IsPlaying("3Appear") then
			if spri:GetFrame() == 1 then
				isaac:PlaySound(214, 1, 0, false, 1)
			end
			if spri:GetFrame() <= 7 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end
		if spri:IsPlaying("3FBAttack3") then
			if spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
			end
			if spri:GetFrame() >= 22 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end
	end

  end
  end

bpattern:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft) --Crack The Sky
	if eft.SubType == 999 and eft.FrameCount == 18 and eft.SpawnerType == 102 then
		SFXManager():Play(265, 0.85, 0, false, 1)

		if math.random(1, 2) == 1 and denpnapi then
			Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0, eft.Position, Vector(0,0), eft) --Crying Gaper
		else
			Isaac.Spawn(38, 1, 0, eft.Position, Vector(0,0), eft) --Angelic Baby
		end
	end
end, 19)

----------------------------
--add Boss Pattern:???
----------------------------
  function bpattern:BBaby(isaac)

	if isaac.Variant == 1 and Game().Difficulty % 2 == 1 then

	local spr = isaac:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local target = isaac:GetPlayerTarget()
	local data = isaac:GetData()
	local rng = isaac:GetDropRNG()
	local angle = (target.Position - isaac.Position):GetAngleDegrees()
	local Room = Game():GetRoom()

	if isaac.State == 8 and spr:IsPlaying("1Idle") and math.random(1,2) == 1 then
		if denpnapi then
			spr:Play("1Attack",true)
			isaac.State = 9
			isaac.I1 = math.random(1,2)
			data.i3 = math.random(5,9)
			data.start = data.i3 - 1
		end
	end

	if not data.init then
		data.init = true
		data.Xsttpos = Vector(0,0)
		data.Ysttpos = Vector(0,0)
		data.intervalX = 0
		data.intervalY = 0
		data.lrtt = 0
		data.Xendpos = 0
		data.Yendpos = 0
	end

	if (spr:IsFinished("2Attack") and math.random(1,2) == 1) or (isaac.HitPoints/isaac.MaxHitPoints < 0.5 and isaac.FrameCount % 110 == 0) then
		local sucker = Isaac.Spawn(61, 0, 0, isaac.Position + Vector.FromAngle(math.random(0,360)):Resized(70), Vector(0,0), isaac)
		sucker:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end

	if spr:IsPlaying("4FBAttackStart") and spr:GetFrame() == 21 then
		isaac:PlaySound(215, 1, 0, false, 1)
		isaac.EntityCollisionClass = 0
	end

	if isaac.State == 157 then
		if spr:IsFinished("4FBAttackStart") then
			spr:Play("4Appear", true)
			isaac:PlaySound(214, 1, 0, false, 1)
			isaac.I1 = math.random(1,4)
			if isaac.I1 == 1 then
				isaac.Position = Vector(Room:GetCenterPos().X*(0.3+(math.random(0,1)*1.4)),
				Room:GetCenterPos().Y)
			else
				isaac.Position = Isaac.GetRandomPosition(0)
				for i=0, 3 do
					if Game():GetNearestPlayer(isaac.Position).Position:Distance(isaac.Position) <= 70 then
						isaac.Position = Isaac.GetRandomPosition(0)
					else
						break
					end
				end
			end
		elseif spr:IsFinished("4Appear") then
			if isaac.I1 == 1 then
				spr:Play("4FBAttack3", true)
				isaac.State = 99
			else
				if math.random(1,2) == 1 and isaac:GetAliveEnemyCount() <= 2 then
					spr:Play("4Summon", true)
					isaac.State = 120
				else
					spr:Play("4FBAttack2Start", true)
					isaac.I1 = math.random(1,4)
					isaac.State = 88
					data.pangle = angle
					if isaac.I1 == 4 and not data.isdelirium then
						local params = ProjectileParams()
						params.BulletFlags = ProjectileFlags.ACCELERATE
						params.FallingAccelModifier = 0.05
						params.Acceleration = 0.96
						params.HeightModifier = -20
						params.Variant = 4
						for i=0, 315, 45 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+angle):Resized(7), 0, params)
						end
					end
				end
			end
		end
		if spr:IsPlaying("4Appear") and spr:GetFrame() == 5 then
			isaac.EntityCollisionClass = 4
		end
	elseif isaac.State == 120 then
		if spr:IsPlaying("4Summon") and spr:GetFrame() == 24 then
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac:PlaySound(265, 1, 0, false, 1)
			for i=0, 270, 90 do
				Isaac.Spawn(26, Isaac.GetEntityVariantByName("Blue Maw"), 0, isaac.Position + Vector.FromAngle(i):Resized(40), Vector(0,0), isaac)
			end
		end
		if spr:IsFinished("4Summon") then
			spr:Play("4FBAttackStart", true)
			isaac.State = 157
		end
	elseif isaac.State == 99 then
		if spr:IsPlaying("4FBAttack3") then
			if spr:GetFrame() >= 32 and spr:GetFrame() <= 55 then
				if spr:GetFrame() == 32 then
					isaac:PlaySound(129, 1, 0, false, 1)
					if isaac.Position.X >= Room:GetCenterPos().X then
						isaac.FlipX = true
						isaac.Velocity = Vector(((Room:GetCenterPos().X*0.1)-isaac.Position.X)*0.1,0)
					else
						isaac.Velocity = Vector(57,0)
						isaac.Velocity = Vector(((Room:GetCenterPos().X*1.9)-isaac.Position.X)*0.1,0)
					end
				end
				if spr:GetFrame() % 4 == 1 then
					isaac:PlaySound(267, 0.65, 0, false, 1)
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.185
					params.BulletFlags = ProjectileFlags.ACCELERATE
					params.Acceleration = 1.07
					params.Variant = 4
					for i=45, 315, 90 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(0.1), 0, params)
					end
				end
			end
		end
		if spr:IsFinished("4FBAttack3") then
			spr:Play("4FBAttackStart", true)
			isaac.State = 157
			isaac.FlipX = false
		end
	elseif isaac.State == 88 then
		if spr:IsFinished("4FBAttack2Start") then
			spr:Play("4FBAttack2Loop", true)
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac.ProjectileCooldown = 0
			if isaac.I1 == 4 and not data.isdelirium then
				isaac.StateFrame = 70
				for i=0, 315, 45 do
					local tlaser = EntityLaser.ShootAngle(3, isaac.Position, i+data.pangle, 55, Vector(0,-20), isaac)
					if isaac.Position.X < target.Position.X then
						tlaser:SetActiveRotation(15, -45, -0.5, false)
					else
						tlaser:SetActiveRotation(15, 45, 0.5, false)
					end
				end
			else
				isaac.StateFrame = math.random(20,50)
			end
		elseif spr:IsFinished("4FBAttack2End") then
			isaac.State = 33
		end
		if spr:IsPlaying("4FBAttack2Loop") and isaac.StateFrame <= 0 then
			spr:Play("4FBAttack2End", true)
		end

		if isaac.StateFrame > 0 then
			isaac.StateFrame = isaac.StateFrame - 1
			isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1

			if isaac.ProjectileCooldown < 1 then
				isaac:PlaySound(267, 0.65, 0, false, 1)

				if isaac.I1 == 1 then
					isaac.ProjectileCooldown = 4
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.185
					params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
					| ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
					params.ChangeTimeout = 75
					params.ChangeFlags = 0
					params.ChangeVelocity = 7
					params.Acceleration = 0.9
					params.Variant = 4
					for i=0, 315, 45 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.StateFrame*5)):Resized(10), 0, params)
					end
				elseif isaac.I1 == 2 then
					isaac.ProjectileCooldown = 5

					if HMBPENTS then
						local params = HMBPEnts.ProjParams()
						params.FallingAccelModifier = -0.083
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params.ChangeTimeout = 75
						params.ChangeFlags = ProjectileFlags.NO_WALL_COLLIDE
						params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
						params.Acceleration = 0.9
						params.HomingStrength = 0.6
						params.Color = Color(1,1,1,5,0,0,0)
						HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(isaac.StateFrame * 10):Resized(10), params)
					else
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.083
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
						params.ChangeTimeout = 75
						params.ChangeFlags = ProjectileFlags.SMART | ProjectileFlags.NO_WALL_COLLIDE
						params.ChangeVelocity = 6
						params.Acceleration = 0.9
						params.HomingStrength = 0.6
						params.Variant = 4
						params.Color = Color(1,1,1,5,0,0,0)
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(isaac.StateFrame * 10):Resized(10), 0, params)
					end
				elseif isaac.I1 == 3 then
					isaac.ProjectileCooldown = 4
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.168
					params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
					| ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
					params.ChangeTimeout = 75
					params.ChangeFlags = ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
					params.ChangeVelocity = 6
					params.Acceleration = 0.95
					params.Variant = 4
					params.CurvingStrength = 0.005
					for i=0, 270, 90 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.StateFrame*13)):Resized(8), 0, params)
					end
				elseif isaac.I1 == 4 then
					if not data.isdelirium then
						isaac.ProjectileCooldown = 20
					else
						isaac.ProjectileCooldown = 10
					end

					local params = ProjectileParams()
					params.FallingAccelModifier = -0.175
					params.Variant = 4

					for i=0, 300, 60 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(5), 0, params)
					end
				end
			end
		end
	elseif isaac.State == 66 then
		if spr:IsPlaying("Jump") then
			if isaac.FrameCount % 2 == 0 then
				local Div = REPENTANCE and 255 or 1

				local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
				creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
				creep:ToEffect().Timeout = 70
				creep:Update()
			end
			isaac.Velocity = isaac.Velocity * 0.33
			if spr:GetFrame() == 16 then
				if target.Position:Distance(isaac.Position) < 240 then
					isaac.TargetPosition = target.Position
				else
					isaac.TargetPosition = isaac.Position + Vector.FromAngle(angle):Resized(240)
				end
			elseif spr:GetFrame() == 30 then
				local Div = REPENTANCE and 255 or 1

				isaac:PlaySound(69, 1, 0, false, 1)
				isaac:PlaySound(153, 1.3, 0, false, 1)
				local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
				creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
				creep.SpriteScale = Vector(3,3)
				creep:Update()
				local params = ProjectileParams()
				params.Variant = 4
				params.FallingAccelModifier = 0.2
				for i=0, math.random(6,9) do
					params.Scale = math.random(5, 13) * 0.1
					params.FallingSpeedModifier = -math.random(30, 120) * 0.1
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(40,85)*0.1), 0, params)
				end
			end
		end
		if spr:IsFinished("Jump") then
			isaac.State = 3
			isaac.Velocity = Vector(0,0)
		end
	elseif isaac.State == 33 then
		isaac.StateFrame = isaac.StateFrame - 1
		if not spr:IsPlaying("4Idle") then
			spr:Play("4Idle", true)
			if isaac.HitPoints/isaac.MaxHitPoints >= 0.19 then
				isaac.StateFrame = 80
			elseif isaac.HitPoints/isaac.MaxHitPoints >= 0.13 then
				isaac.StateFrame = 55
			else
				isaac.StateFrame = 35
			end
			if data.isdelirium then
				isaac.StateFrame = isaac.StateFrame * 2
			end
		end
		if isaac.StateFrame <= 0 and spr:IsPlaying("4Idle") then
			spr:Play("4FBAttackStart", true)
			isaac.State = 157
		end
	elseif isaac.State == 11 then
		isaac.StateFrame = isaac.StateFrame - 1
		isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
		if spr:IsFinished("3FBAttack4Start") then
			spr:Play("3FBAttack4Loop", true)
		elseif spr:IsFinished("3FBAttack4End") then
			spr:Play("Idle3", true)
			isaac.State = 8
		end
		if spr:IsPlaying("3FBAttack4Start") and spr:GetFrame() == 21 then
			isaac:PlaySound(129, 1, 0, false, 1)
			data.attacking = true
		elseif spr:IsPlaying("3FBAttack4Loop") and isaac.StateFrame <= 0 then
			spr:Play("3FBAttack4End", true)
			data.attacking = false
		end
		if data.attacking then
			if isaac.I1 == 1 then
				if isaac.ProjectileCooldown <= 0 then
					isaac.ProjectileCooldown = 8
				elseif isaac.ProjectileCooldown == 1 then
					local angle = rng:RandomInt(359)
					isaac:PlaySound(267, 0.65, 0, false, 1)
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.165
					params.Variant = 4

					for i=-5.75, 5.75, 11.5 do
						for j=0, 25, 5 do
							isaac:FireProjectiles(isaac.Position,Vector.FromAngle(j + angle):Resized(i), 0, params)
						end
					end
				end
			elseif isaac.I1 == 2 then
				if isaac.ProjectileCooldown <= 0 then
					isaac.ProjectileCooldown = 19
					isaac:PlaySound(267, 0.65, 0, false, 1)
					local params = ProjectileParams()
					params.BulletFlags = 1
					params.Scale = 1.5
					for i=0, 300, 60 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.FrameCount % 2)*45):Resized(9), 0, params)
					end
				end
			end
		end
	elseif isaac.State == 9 then
		if spr:IsPlaying("1Attack") then
			if data.i3 > 0 then
				if isaac.I1 == 1 then
					if (data.i3 < data.start and spr:GetFrame() == 3) or (data.i3 >= data.start and spr:GetFrame() == 6) then
						spr:Play("1Attack",true)
					end
				elseif isaac.I1 == 2 then
					if spr:GetFrame() == 8 then
						spr:Play("1Attack",true)
					end
				end
				if spr:GetFrame() == 1 then
					data.i3 = data.i3 - 1
				end
			end
			if data.i3 < data.start and spr:GetFrame() == 1 then
				isaac:PlaySound(267, 0.65, 0, false, 1)

				if isaac.I1 == 1 then
					local params = HMBPEnts.ProjParams()
					params.FallingSpeedModifier = -20
					params.FallingAccelModifier = 0.5
					params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
					params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
					params.ChangeTimeout = 20
					params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
					params.Scale = 1.3
					params.HomingStrength = 1.2
					params.Color = Color(1,1,1,5,0,0,0)
					HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle((target.Position - isaac.Position):GetAngleDegrees() + math.random(-20, 20)):Resized(-5), params)
				elseif isaac.I1 == 2 then
					local params = HMBPEnts.ProjParams()
					params.FallingAccelModifier = -0.1
					params.HMBPBulletFlags = HMBPEnts.ProjFlags.GRAVITY_VERT

					for i=-3, 3, 6 do
						HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector(i / math.random(1, 2), math.random(-20, 20) * 0.1), params)
					end
				end
			end
		end
		if spr:IsFinished("1Attack") then
			isaac.State = 8
		end
	elseif isaac.State == 8 then
		if spr:IsPlaying("3FBAttack4Start") and spr:GetFrame() == 1 then
			if math.random(1,4) == 1 and denpnapi then
				if Room:GetAliveEnemiesCount() <= 20 and isaac.FrameCount % 150 <= 50 then
					spr:Play("3Summon",true)
					isaac.State = 12
				end
			elseif math.random(1,4) == 2 and HMBPENTS then
				isaac.I1 = math.random(2,4)
				data.i3 = math.random(1,6)
				spr:Play("3FBAttack5w"..data.i3,true)
				isaac.State = 10
			elseif math.random(1,4) == 3 then
				isaac.State = 11
				isaac.StateFrame = math.random(50,100)
				isaac.I1 = math.random(1,2)
				isaac.ProjectileCooldown = 0
			end
		end
		if spr:IsPlaying("2Attack") then
			if spr:GetFrame() == 2 then
				if data.i3 == 1 then
					if isaac.I1 == 0 then
						isaac.I1 = 2
					elseif isaac.I1 == 1 then
						isaac.I1 = 3
						data.i3 = 0
					end
				else
					if isaac.I1 == 1 then
						data.i3 = 1
					end
				end
			elseif spr:GetFrame() == 8 then
				if isaac.I1 == 2 then
					if HMBPENTS then
						local params = HMBPEnts.ProjParams()
						params.FallingSpeedModifier = 0
						params.FallingAccelModifier = -0.135
						params.Scale = 1.5
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params.ChangeTimeout = 40
						params.ChangeFlags = ProjectileFlags.NO_WALL_COLLIDE
						params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
						params.Acceleration = 0.92
						params.Color = Color(1,1,1,5,0,0,0)

						for i=0, 300, 60 do
							HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(i):Resized(10), params)
						end
					else
						local params = ProjectileParams()
						params.FallingSpeedModifier = 0
						params.FallingAccelModifier = -0.135
						params.BulletFlags = 1
						params.Scale = 1.5
						params.Color = Color(1,1,1,5,0,0,0)

						for i=0, 300, 60 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(10), 0, params)
						end
					end
				elseif isaac.I1 == 3 then
					local params = ProjectileParams()
					params.Variant = 4
					params.BulletFlags = ProjectileFlags.BURST3
					params.FallingAccelModifier = -0.15
					params.Scale = 1.5

					for i=0, 270, 90 do
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(2), 0, params)
					end
				end
			end
		end
		if spr:IsFinished("2Attack") then
			if isaac.I1 == 3 then
				isaac.I1 = 1
			elseif isaac.I1 == 2 then
				isaac.I1 = 0
			end
		end
	elseif isaac.State == 3 then
		if spr:IsFinished("2Idle") then
			if isaac.FrameCount % 70 == 0 then
				local Div = REPENTANCE and 255 or 1

				local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
				creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
				creep:ToEffect().Timeout = 70
				creep:Update()
			end
			if isaac.FrameCount % 85 == 0 then
				spr:Play("Jump",true)
				isaac.State = 66
			end
		end
	end

	if isaac.State == 10 then
	if spr:GetFrame() == 1 then
		if data.i3 == 1 then
			data.intervalX = 120
			data.lrtt = 270
			if Room:GetRoomShape() >= 6 then
				data.Xendpos = 1080
			else
				data.Xendpos = 480
			end
			if (Room:GetRoomShape() >= 4 and Room:GetRoomShape() <= 6)
			or Room:GetRoomShape() >= 8 then
				data.Xsttpos = Vector(120,720)
			else
				data.Xsttpos = Vector(120,440)
			end
		elseif data.i3 == 2 then
			data.Xsttpos = Vector(80,120)
			data.intervalX = 120
			data.lrtt = 90
			if Room:GetRoomShape() >= 6 then
				data.Xendpos = 1120
			else
				data.Xendpos = 560
			end
		elseif data.i3 == 3 then
			data.Xsttpos = Vector(200,120)
			data.intervalX = 200
			data.intervalY = 200
			data.lrtt = 135
			if Room:GetRoomShape() >= 6 then
				data.Xendpos = 1000
				data.Ysttpos = Vector(1120,0)
				if Room:GetRoomShape() >= 8 then
					data.Yendpos = 600
				else
					data.Yendpos = 400
				end
			else
				data.Xendpos = 600
				data.Ysttpos = Vector(600,-80)
				if Room:GetRoomShape() >= 4 then
					data.Yendpos = 520
				else
					data.Yendpos = 320
				end
			end
		elseif data.i3 == 4 then
			data.Xsttpos = Vector(40,120)
			data.Ysttpos = Vector(40,240)
			data.intervalX = 200
			data.intervalY = 100
			data.lrtt = 45
			if Room:GetRoomShape() >= 6 then
				data.Xendpos = 1040
			else
				data.Xendpos = 440
			end
			if Room:GetRoomShape() == 4 or Room:GetRoomShape() == 5
			or Room:GetRoomShape() >= 8 then
				data.Yendpos = 540
			else
				data.Yendpos = 340
			end
		elseif data.i3 == 5 then
			data.intervalY = 120
			data.lrtt = 180
			if Room:GetRoomShape() <= 5 then
				data.Ysttpos = Vector(600,100)
			else
				data.YsttposX = Vector(1120,100)
			end
			if (Room:GetRoomShape() >= 4 and Room:GetRoomShape() <= 6)
			or Room:GetRoomShape() >= 8 then
				data.Yendpos = 700
			else
				data.Yendpos = 340
			end
		else
			data.Ysttpos = Vector(40,40)
			data.intervalY = 120
			data.lrtt = 0
			if (Room:GetRoomShape() == 4 or Room:GetRoomShape() == 5)
			or Room:GetRoomShape() >= 8 then
				data.Yendpos = 760
			else
				data.Yendpos = 400
			end
		end
		if data.i3 < 5 then
			for i=data.Xsttpos.X, data.Xendpos, data.intervalX do
				local light = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("HolyBeam Warn"), 0, Vector(i,data.Xsttpos.Y), Vector(0,0), isaac)
				light:ToEffect().Rotation = data.lrtt
				light.SpawnerEntity = isaac
			end
		end
		if data.i3 > 2 then
			for i=data.Ysttpos.Y, data.Yendpos, data.intervalY do
				if i >= data.Ysttpos.Y + data.intervalY then
					local light = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("HolyBeam Warn"), 0, Vector(data.Ysttpos.X,i), Vector(0,0), isaac)
					light:ToEffect().Rotation = data.lrtt
					light.SpawnerEntity = isaac
				end
			end
		end
	end

	if spr:IsFinished("3FBAttack5w"..data.i3) then
		isaac.I1 = isaac.I1 - 1
		if isaac.I1 <= 0 then
			isaac.State = 3
		end
		data.i4 = data.i3
		for i=1, 20 do
			data.i3 = math.random(1,6)
			if data.i3 ~= data.i4 then
				break
			end
		end
		spr:Play("3FBAttack5w"..data.i3, true)
	end
	end

	if spr:IsPlaying("3Summon") and spr:GetFrame() == 11 then
		isaac.I1 = 0
		isaac:PlaySound(129, 1, 0, false, 1)
		isaac:PlaySound(265, 1, 0, false, 1)

		for i=0, 90, 90 do
			Isaac.Spawn(26, Isaac.GetEntityVariantByName("Blue Maw"), 0, isaac.Position+Vector.FromAngle(45+i):Resized(70), Vector(0,0), isaac)
		end
	end

	if spr:IsFinished("3Summon") then
		isaac.State = 3
	end

  end
  end

  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Mom, 45)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Momf, 45)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Satan, 84)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.SatanFoot, 84)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Lamb, 273)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.IsaacAndBlueBaby, 102)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Isaac, 102)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.BBaby, 102)
