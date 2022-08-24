local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

--TODO:
--	Where did the code for eyeHp & eyehurt go???????
--	Extra stomp attack needs to be made solid

----------------------------
--add Boss Pattern:Womb chapter major bosses
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	local data = boss:GetData()
	if boss.Variant == 10 then --Gut
		data.LaserAngle = 90
	else
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)
		data.Rotation = -1 + rng:RandomInt(1) * 2
	end
end, 78)

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, boss)
	if game.Difficulty % 2 == 1 then
		local room = game:GetRoom()
		local sprite = boss:GetSprite()
		local data = boss:GetData()

		if boss.Variant == 10 then --Gut
			local Heart = boss.Parent:ToNPC()
			local CR, CA, To = REPENTANCE and 0.6 or 1.2, REPENTANCE and 0.6 or 2, REPENTANCE and 30 or 20 --ColorRed, ColorAlpha, Timeout

			if not data.LaserAngle then
				data.LaserAngle = 90
			end

			if Heart.I1 == 5 then
				if sprite:IsFinished("HeartRetracted") then
					sprite:Play("Heartbeat1", true)
				end

				if room:GetAliveEnemiesCount() - #Isaac.FindByType(78, -1, -1, true, true) > 0 and boss.FrameCount % 81 == 0 then
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
								boss:FireProjectiles(Vector(boss.Position.X - 90 + (boss.FrameCount % 2) * 180, 120),
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

			if REPENTANCE and boss.SubType == 1 then --Rep route
				if boss.State == 8 and boss.HitPoints / boss.MaxHitPoints <= 0.2 and boss.StateFrame > 180 and (math.floor(boss.V1.Y) == 18 or math.floor(boss.V1.Y) > (data.IsHMBPEtn and 127 or 105)) then
					boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and rng:Random(128, 130) or rng:Random(106, 109))
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
									boss.V1 = Vector(boss.V1.X, rng:Random(1, 3) == 1 and rng:Random()(90, 93) or rng:Random(0, 7))
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
								boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and rng:Random(117, 119) or rng:Random(97, 99))
								boss.I1 = 50
								boss.State = 43
								boss:PlaySound(212, 1, 0, false, 1) --SOUND_HEARTIN
								boss.ProjectileCooldown = rng:Random(210, 270)
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
					if boss.State == 3 and boss.ProjectileCooldown == 8 and rng:Random(1, 3) == 1 then
						boss.State = 8
						boss.StateFrame = 1
						boss.V1 = Vector(boss.V1.X, rng:Random(90, 91) + (boss.I2 - 1) * 2)
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
							game:ShakeScreen(20)
							boss:PlaySound(52, 1, 0, false, 1) --SOUND_HELLBOSS_GROUNDPOUND
							game:BombDamage(boss.Position, 41, boss.Size * 1.1, false, boss, 0, 0, true)

							Isaac.Spawn(1000, 16, 3, boss.Position, Vector(0, 0), boss) --Poof02(BloodCloud)
							Isaac.Spawn(1000, 16, 4, boss.Position + Vector(0, 1), Vector(0, 0), boss) --Poof02(CBlood)

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
						boss.V1 = Vector(boss.V1.X, data.IsHMBPEtn and rng:Random(114, 116) or rng:Random(94, 96))
						data.Rotation = -1 + rng:Random(0, 1) * 2
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

HMBP:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, boss)
	local data = boss:GetData()

	if boss.State == 8 and boss.HitPoints / boss.MaxHitPoints > 0.2 and boss.StateFrame == 1 then
		if REPENTANCE and boss.SubType == 1 then
			if data.IsHMBPEtn then --Eternal mode
				if boss.I2 == 3 then
					boss.V1 = Vector(boss.V1.X, rng:Random(120, 127))
				else
					boss.V1 = Vector(boss.V1.X, rng:Random(120, 123) + (boss.I2 - 1) * 4)
				end
			else --None eternal mode
				if rng:Random(1, 7) < 4 then --Rep route
					if boss.I2 == 3 then
						boss.V1 = Vector(boss.V1.X, rng:Random(100, 105))
					else
						boss.V1 = Vector(boss.V1.X, rng:Random(100, 102) + (boss.I2 - 1) * 3)
					end
				end
			end
		else
			if not data.Attacking and boss.I2 == 3 then
				data.Attacking = true

				if data.IsHMBPEtn then --Eternal mode
					boss.V1 = Vector(boss.V1.X, rng:Random(120, 127))
				else --None eternal mode
					boss.V1 = Vector(boss.V1.X, rng:Random(1, 3) == 1 and rng:Random(0, 7) or rng:Random(90, 93))
				end
			end
		end
	end
end, 78)

--[[HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	local sprite = boss:GetSprite()

	if game.Difficulty % 2 == 1 and (room:GetBossID() == 8 or room:GetBossID() == 25) and HMBPEternalMode then
		if boss.Variant ~= 10 then
		else
			for i=0, 1 do
				sprite:ReplaceSpritesheet(i, "gfx/bosses/eternal/boss_78_moms guts_eternal.png")
			end

			sprite:LoadGraphics()
		end
	end
end, 78)]]

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, boss)
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
		game:SpawnParticles(boss.Position, 5, rng:Random(6, 9), 3.5, Color(1, 1, 1, 1, 0, 0, 0)) --Blood Particle(Flesh)
	end
end, 78)

HMBP:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, damageflag, source, num)
	local boss = entity:ToNPC()

	if boss.I1 == 60 or boss.I1 == 61 or boss.State == 17 then
		return false
	end

	if entity.Variant ~= 10 and game.Difficulty % 2 == 1 and entity.HitPoints <= amount then
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
			print("HMBPENTS : false")
		end
	end
end, 78)

HMBP:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function (_, p)
	if p:GetData().ChangeAngleAfterTimeout and p.FrameCount >= p.ChangeTimeout then
		p:GetData().ChangeAngleAfterTimeout = false
		p.Velocity = Vector.FromAngle(p:GetData().ChangeAngle):Resized(p.Velocity:Length())
	end
end)
