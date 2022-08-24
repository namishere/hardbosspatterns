local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--Add Boss Pattern:Ultra Greedier
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 1 then
		local data = boss:GetData()
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		data.ChangedHP = false
		data.moveX = 0
		data.Sstomp = false
		data.tripgauge = 0
		data.firstcollide = false
		data.TwoPhase = false
		data.smash = false
	end
end, 406)


function HMBP:Ultigreedier(boss)
	if boss.Variant == 1 and denpnapi then
		local sprug2 = boss:GetSprite()
		local data = boss:GetData()
		local target = game:GetPlayer(1)
		local dist = target.Position:Distance(boss.Position)
		local Entities = Isaac:GetRoomEntities()
		local angle = (target.Position - boss.Position):GetAngleDegrees()
		local Room = game:GetRoom()
		boss:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)

		if sprug2:IsFinished("BreakFreeShort") or sprug2:IsFinished("BreakFreeLong") then
			data.ChangedHP = false
		end

		if boss.HitPoints / boss.MaxHitPoints <= 0.5 and not data.TwoPhase then
			sprug2:Play("Hurt", true)
			boss.State = 15
			data.TwoPhase = true
			boss:PlaySound(427, 1, 0, false, 2)
			boss.StateFrame = 35
			game:SpawnParticles(boss.Position, 98, 20, 10, Color(1.1,1,1,1,0,0,0), -50)
		end

		if data.TwoPhase and (boss.State == 3 or boss.State == 4) then
			if boss.FrameCount % 70 <= 7 and rng:Random(1,3) == 1 then
				data.smash = false
				if rng:Random(1,6) > 3 then
					if math.abs(boss.Position.Y-target.Position.Y) <= 120 then
						if boss.Position.X > target.Position.X then
							boss.FlipX = true
						else
							boss.FlipX = false
						end
						sprug2:Play("Punch", true)
						data.smash = false
						boss.State = 21
						boss:PlaySound(312, 0.65, 0, false, 0.6)
						data.firstcollide = false
					end
				elseif rng:Random(1,6) > 1 then
					sprug2:Play("SpinStart", true)
					boss.State = 11
					boss.StateFrame = rng:Random(160, 240)
					boss:PlaySound(433, 1, 0, false, 1)
				else
					if boss:GetAliveEnemyCount() <= 3 then
						sprug2:Play("Summon", true)
						boss.State = 10
						boss:PlaySound(433, 1, 0, false, 1)
						boss.StateFrame = 35
					end
				end
			end
			if rng:Random(1,3) == 1 and dist <= 200 and boss.FrameCount % 20 == 0 then
				sprug2:Play("SpinOnce", true)
				boss.State = 11
				boss:PlaySound(433, 1, 0, false, 1)
			elseif rng:Random(1,3) == 2 and boss.Position.Y <= 420
			and boss.Position.Y-target.Position.Y < -50 and math.abs(boss.Position.X-target.Position.X) <= 60 then
				sprug2:Play("DashStart", true)
				boss.State = 22
				boss:PlaySound(432, 1, 0, false, 1)
				data.tripgauge = 0
			end
		end

		if sprug2:IsPlaying("Smash") and data.TwoPhase then
			data.smash = true
		end

		if boss.State <= 4 and data.smash then
			data.smash = false
			boss.State = 720
			if boss.FlipX then
				boss.FlipX = false
			else
				boss.FlipX = true
			end
			sprug2:Play("Smash2", true)
		end

		if boss.State == 6 then
			if data.TwoPhase and sprug2:IsPlaying("JumpUp") then
				boss.State = 66
				boss.I1 = rng:RandomInt(3)
			end
		elseif boss.State == 10 then
			if sprug2:IsFinished("Hurt") or sprug2:IsFinished("Summon") then
				boss.Velocity = Vector.FromAngle(angle):Resized(2.5)
				if boss:GetAliveEnemyCount() <= 1 then
					boss.StateFrame = boss.StateFrame - 1
					if boss.StateFrame <= 0 then
						sprug2:Play("JumpDown", true)
						boss.State = 66
						boss.EntityCollisionClass = 0
					end
				end
			end
			if sprug2:IsPlaying("Summon") then
				if sprug2:GetFrame() == 78 then
					boss:PlaySound(48, 0.65, 0, false, 2)
				elseif sprug2:GetFrame() == 85 then
					boss:PlaySound(190, 0.5, 0, false, 1.5)
					boss.EntityCollisionClass = 0
				end
			elseif sprug2:IsPlaying("Hurt") then
				if sprug2:GetFrame() == 117 then
					boss:PlaySound(48, 0.65, 0, false, 2)
				elseif sprug2:GetFrame() == 124 then
					boss:PlaySound(190, 0.5, 0, false, 1.5)
					boss.EntityCollisionClass = 0
				end
			end
			boss.Velocity = boss.Velocity * 0.7
			sprug2.PlaybackSpeed = 1
		elseif boss.State == 11 then
			boss.StateFrame = boss.StateFrame - 1
			boss.ProjectileCooldown = boss.ProjectileCooldown - 1
			boss.Velocity = boss.Velocity * 0.9

			if sprug2:IsFinished("SpinOnce") or sprug2:IsFinished("SpinEnd") then
				boss.State = 3
				sound:Stop(440)
			end
			if sprug2:IsFinished("SpinStart") then
				sprug2:Play("SpinConstant", true)
				boss:AddVelocity(Vector.FromAngle(angle):Resized(1.3))
			end
			if sprug2:IsPlaying("SpinConstant") and boss.StateFrame <= 0 then
				sprug2:Play("SpinEnd", true)
				sound:Stop(440)
			end
			if sprug2:IsPlaying("SpinOnce") then
				if sprug2:GetFrame() == 5 then
					boss:PlaySound(440, 3, 0, true, 1)
				end
				if sprug2:GetFrame() >= 4 then
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.1
					params.Scale = 1.5
					params.Variant = 7
					params.BulletFlags = 2
					boss:FireProjectiles(boss.Position, Vector.FromAngle((sprug2:GetFrame()-5)*51.4):Resized(15), 0, params)
				end
			elseif sprug2:IsPlaying("SpinConstant") then
				boss:PlaySound(440, 1, 0, false, 1)
				if boss.FrameCount % 7 == 0 then
					local params = ProjectileParams()
					params.Variant = 7
					params.FallingAccelModifier = 0.1

					if rng:Random(1,5) < 3 then
						params.Scale = 1.5
						params.BulletFlags = 2
						params.FallingSpeedModifier = -rng:Random(6,16)*0.1
					else
						params.Scale = rng:Random(7,12)*0.1
						params.FallingSpeedModifier = -rng:Random(10,25)*0.1
					end

					boss:FireProjectiles(boss.Position, Vector.FromAngle(-30+(sprug2:GetFrame()-1)*-60):Resized(rng:Random(35,70)*0.1), 0, params)
				end

				if boss.ProjectileCooldown <= 0 then
					local AngleDiff = ((angle - boss.Velocity:GetAngleDegrees()) % 360) - math.floor(((angle - boss.Velocity:GetAngleDegrees()) % 360) / 180) * 360

					boss:AddVelocity(Vector.FromAngle(boss.Velocity:GetAngleDegrees() + AngleDiff / 3):Resized(1.3))
				end

				if boss:CollidesWithGrid() and boss.Velocity:Length() >= 3 then
					game:SpawnParticles(boss.Position, 95, 30, 10, Color(1.1,1,1,1,0,0,0), -50)
					boss.ProjectileCooldown = 7
					boss:PlaySound(48, 1, 0, false, 1)
					game:ShakeScreen(20)
					boss.Velocity = boss.Velocity * 2
				end
			end

			sprug2.PlaybackSpeed = 1
		elseif boss.State == 21 then
			if sprug2:IsPlaying("Punch") then
				if sprug2:GetFrame() == 22 then
					game:ShakeScreen(10)
					boss:PlaySound(182, 1, 0, false, 1)
					if boss.FlipX then
						data.moveX = -1
						boss.Velocity = Vector(-100, boss.Velocity.Y)
					else
						data.moveX = 1
						boss.Velocity = Vector(100, boss.Velocity.Y)
					end
				elseif sprug2:GetFrame() == 70 then
					--data.gentP = Room:GetGridEntity(Room:GetGridIndex(boss.Position+Vector((data.moveX*70),0)))
					boss:PlaySound(252, 1, 0, false, 0.4)
					boss:PlaySound(433, 1, 0, false, 1)
					game:ShakeScreen(10)
					game:SpawnParticles(boss.Position, 95, 20, 10, Color(1.1,1,1,1,0,0,0), -50)
				end
				if sprug2:GetFrame() >= 70 and sprug2:GetFrame() <= 75 then
					for i=(sprug2:GetFrame()-70)*52, 39+((sprug2:GetFrame()-70)*52), 13 do
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.1
						params.Scale = 1.5
						params.Variant = 7
						boss:FireProjectiles(boss.Position, Vector(Vector.FromAngle(i):Resized(14).X*data.moveX,
						Vector.FromAngle(i):Resized(14).Y), 0, params)
					end
				end
				if sprug2:GetFrame() >= 22 and sprug2:GetFrame() <= 69 then
					if boss.Velocity:Length() > 10 then
						if HMBPENTS then
							local aftimage = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Afterimage"), 0, boss.Position, Vector(0,0), boss)
							aftimage.FlipX = boss.FlipX
							aftimage:GetSprite():Load(sprug2:GetFilename(), true)
							aftimage:GetSprite():SetFrame("Punch", sprug2:GetFrame())
							aftimage.Color = boss.Color
						end
						game:BombDamage(boss.Position+Vector((data.moveX*130),0), 30, 20, true, boss, 0, 1<<2, false)
						game:SpawnParticles(boss.Position, 95, 3, 10, Color(1.1,1,1,1,0,0,0), -3)
						local params = ProjectileParams()
						params.FallingSpeedModifier = -rng:Random(45,60) * 0.1
						params.FallingAccelModifier = 0.3
						params.Scale = rng:Random(10,13) * 0.1
						params.Variant = 7
						boss:FireProjectiles(boss.Position, Vector(-data.moveX*rng:Random(3,5),rng:Random(-5,5)), 0, params)
					end
					if (not boss.FlipX and boss.Position.X >= Room:GetBottomRightPos().X-135) or (boss.FlipX and boss.Position.X <= 210) then
						if boss.FlipX then
							boss.Position = Vector(210, boss.Position.Y)
						else
							boss.Position = Vector(Room:GetBottomRightPos().X-135, boss.Position.Y)
						end
						if boss.Velocity:Length() > 7 and not data.firstcollide then
							boss:PlaySound(52, 1, 0, false, 1)
							data.firstcollide = true
							game:ShakeScreen(20)
							for i=0, rng:Random(9,17) do
								local params = ProjectileParams()
								params.FallingSpeedModifier = -rng:Random(75,125) * 0.1
								params.FallingAccelModifier = 0.45
								params.HeightModifier = -20
								params.Scale = rng:Random(10,15) * 0.1
								params.Variant = 7
								boss:FireProjectiles(boss.Position+Vector(115*data.moveX,0),
								Vector.FromAngle(rng:Random(-88,88)-90*(data.moveX+1)):Resized(rng:Random(5,15)), 0, params)
							end
						elseif boss.Velocity:Length() > 2 then
							boss:PlaySound(48, 1, 0, false, boss.Velocity:Length()/5)
						end
						boss.Velocity = Vector(0, boss.Velocity.Y)
					end
				end
			else
				boss.State = 3
			end
		elseif boss.State == 22 then
			if sprug2:IsPlaying("DashStart") and sprug2:GetFrame() == 23 then
				sprug2:Play("DashDown", true)
				boss.I1 = 1
			end
			if sprug2:IsFinished("DashStop") or sprug2:IsFinished("Trip") then
				boss.State = 3
				boss.I1 = 0
			end
			if boss.I1 == 1 then
				boss.Velocity = Vector(0,20)
			end
			if sprug2:IsEventTriggered("Stomp1") or sprug2:IsEventTriggered("Stomp2") then
				boss:PlaySound(48, 1, 0, false, 1)
			end
			if sprug2:IsPlaying("DashDown") then
				local Div = REPENTANCE and 255 or 1

				game:SpawnParticles(boss.Position, 88, 1, 8, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), 0)
				local params = ProjectileParams()
				params.HeightModifier = rng:Random(-70,5)
				params.FallingAccelModifier = -0.05
				params.Scale = rng:Random(8,12) * 0.1
				params.Variant = 7
				boss:FireProjectiles(boss.Position+Vector(rng:Random(-85,85),0), Vector.FromAngle(rng:Random(260,280)):Resized(rng:Random(0,20)*0.1), 0, params)
				if boss:CollidesWithGrid() then
					boss:PlaySound(52, 1, 0, false, 0.85)
					game:ShakeScreen(20)
					for i=180, 360, 15 do
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.165
						params.Scale = 2
						params.Variant = 7
						params.BulletFlags = 2
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(12), 0, params)
					end
					sprug2:Play("DashStop", true)
				end
				if data.tripgauge >= 25 then
					boss.I1 = 0
					sprug2:Play("Trip", true)
				end
			elseif sprug2:IsPlaying("Trip") then
				if sprug2:GetFrame() == 10 then
					game:SpawnParticles(boss.Position, 88, 1, 13, Color(1,1,1,1,135,126,90), 0)
					boss:PlaySound(52, 1, 0, false, 1)
					game:ShakeScreen(20)
					local params = ProjectileParams()
					params.Variant = 7
					for i=0, rng:Random(6,10) do
						params.FallingSpeedModifier = -rng:Random(35,65) * 0.1
						params.FallingAccelModifier = 0.3
						params.Scale = rng:Random(13,20) * 0.1
						boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(5,13)), 0, params)
					end
					for i=0, 324, 36 do
						params.FallingSpeedModifier = -3
						params.FallingAccelModifier = 0.1
						params.Scale = 2
						params.BulletFlags = 2
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(12), 0, params)
					end
				end
			end
		elseif boss.State == 66 then
			if sprug2:IsPlaying("JumpUp") then
				boss.Velocity = boss.Velocity * 0.7
			elseif sprug2:IsPlaying("JumpDown2") then
				boss.Velocity = boss.Velocity * 0.7
				if sprug2:GetFrame() == 30 and boss.I1 > 0 then
					sprug2:Play("JumpUp2", true)
					boss.I1 = boss.I1 - 1
				end
			end
			if sprug2:IsEventTriggered("Jump") then
				boss:PlaySound(14, 1, 0, false, 1)
				game:ShakeScreen(10)
				boss.EntityCollisionClass = 0
				boss.TargetPosition = target.Position
				game:SpawnParticles(boss.Position, 95, 20, 10, Color(1.1,1,1,1,0,0,0), -30)
			end
			if sprug2:IsFinished("JumpUp") or sprug2:IsFinished("JumpUp2") then
				boss.Velocity = Vector.FromAngle((boss.TargetPosition - boss.Position):GetAngleDegrees()):Resized(10)
				game:SpawnParticles(boss.Position, 95, 1, 1, Color(1.1,1,1,1,0,0,0), -500)
				if rng:Random(1,5) <= 2 then
					local params = ProjectileParams()
					params.HeightModifier = -500
					params.FallingAccelModifier = 1.2
					params.Scale = rng:Random(10,15) * 0.1
					params.Variant = 7
					params.BulletFlags = 2
					boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(5,20)*0.1), 0, params)
				end
				if boss.TargetPosition:Distance(boss.Position) <= 50 then
					sprug2:Play("JumpDown2", true)
				end
			end
			if sprug2:IsEventTriggered("Stomp") then
				boss:PlaySound(138, 1, 0, false, 1)
				game:SpawnParticles(boss.Position, 95, 30, 15, Color(1.1,1,1,1,0,0,0), -5)
				if sprug2:IsPlaying("JumpDown2") then
					boss:PlaySound(52, 1, 0, false, 1)
					if rng:Random(1,2) == 1 then
						if HMBPENTS then
							local cshock = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Coin Wave"), 0, boss.Position, Vector(0,0), boss)
							cshock.Parent = boss
						else
							local shockwave2 = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss):ToEffect()
							shockwave2.Parent = boss
							shockwave2.MaxRadius = 300
							shockwave2.Timeout = 100
						end
					else
						if HMBPENTS then
							for i=0,288,72 do
								local GCrkWave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Golden CrackWave"), 0, boss.Position, Vector(0,0), boss):ToEffect()
								GCrkWave.Parent = boss
								GCrkWave.Rotation = i
							end
						else
							for i=0, 270, 90 do
								local cwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss)
								cwave.Parent = boss
								cwave:ToEffect().Rotation = i
							end
						end
					end
				else
					for i=0, 270, 90 do
						local cwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss)
						cwave.Parent = boss
						cwave:ToEffect().Rotation = i
					end
				end
				game:ShakeScreen(20)
				boss.EntityCollisionClass = 4
			end
			if sprug2:IsFinished("JumpDown") or sprug2:IsFinished("JumpDown2") then
				boss.State = 3
			end
		elseif boss.State == 720 then
			if sprug2:IsPlaying("Smash2") then
				if sprug2:GetFrame() == 5 then
					boss:PlaySound(432, 1, 0, false, 1)
				elseif sprug2:GetFrame() == 32 then
					boss:PlaySound(138, 1, 0, false, 1)
					game:ShakeScreen(20)
					game:BombDamage(boss.Position+Vector(0,50), 40, 80, true, boss, 0, 1<<2, true)
					local explode = Isaac.Spawn(1000, 1, 0, boss.Position+Vector(0,50), Vector(0,0), boss)
					explode:SetColor(Color(2,2,1,1,0,0,0), 99999, 0, false, false)
					explode:GetSprite().Scale = Vector(2,2)
					if HMBPENTS then
						local GWaveRadi = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Golden Wave (Radial)"), 0, boss.Position+Vector(0,50), Vector(0,0), boss)
						GWaveRadi.Parent = boss
						GWaveRadi:ToEffect().MaxRadius = 700
						GWaveRadi:ToEffect().Timeout = 30
					else
						for i=0, rng:Random(6,10) do
							local params = ProjectileParams()
							params.FallingSpeedModifier = -rng:Random(35,65) * 0.1
							params.FallingAccelModifier = 0.3
							params.Scale = rng:Random(13,20) * 0.1
							params.Variant = 7
							params.BulletFlags = 2
							boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(5, 10)), 0, params)
						end
					end
				end
			else
				boss.State = 3
			end
		end

		if boss.State == 21 or boss.State == 22 or (boss.State == 66
		and sprug2:WasEventTriggered("Stomp")) or boss.State == 720 then
			boss.Velocity = boss.Velocity * 0.7
		end

		if (boss.State == 21 or boss.State == 22 or boss.State == 66) and sprug2.PlaybackSpeed < 1 then
			sprug2.PlaybackSpeed = 1
		end

		if not boss:Exists() then
			sound:Stop(440)
		end

		if sprug2:IsEventTriggered("Call") then
			boss:PlaySound(432, 1.5, 0, false, 1)
			boss.State = 10
		end

		if boss.State == 15 then
			boss.Velocity = boss.Velocity * 0.7
			sprug2.PlaybackSpeed = 1
		end

		if sprug2:IsEventTriggered("Cracking") then
			boss:PlaySound(427, 1, 0, false, 2)
			game:SpawnParticles(boss.Position, 95, 30, 10, Color(1.1,1,1,1,0,0,0), -50)
		end

		for k, v in pairs(Entities) do
			local dist3 = v.Position:Distance(boss.Position)

			if v.EntityCollisionClass > 0 and (v:ToPlayer() or v:IsVulnerableEnemy()) and v.Type ~= 406 and dist3 <= 110 + v.Size
			and (sprug2:IsPlaying("SpinOnce2") and sprug2:GetFrame() >= 5) then
				v.Velocity = Vector.FromAngle(angle + (boss.FlipX and 50 or -50)):Resized((110 + v.Size - dist) / 5)
				v:TakeDamage(v:ToPlayer() and 2 or 40, 0, EntityRef(boss), 5)
			end
		end

		if boss:IsDead() then
			data.smash = false
		end

	end
end

HMBP:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, boss, collider, low)
	local sprite = boss:GetSprite()

	if boss.Variant ~= 1 or not (collider:ToPlayer() or collider:IsVulnerableEnemy()) or not sprite:IsPlaying("SpinConstant") then return end

	collider.Velocity = Vector.FromAngle((collider.Position - boss.Position):GetAngleDegrees() + (boss.FlipX and 50 or -50)):Resized(100 / collider.Mass)

	if collider.Type ~= 406 then
		collider:TakeDamage(collider:ToPlayer() and 2 or 40, 0, EntityRef(boss), 5)
	end
end, 406)

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Ultigreedier, 406)
