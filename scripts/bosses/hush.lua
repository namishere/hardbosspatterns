local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--Add Boss Pattern:Hush
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

	local data = boss:GetData()
	data.NumSpit = 0
	data.hand = false
	data.breathhold = false
	data.FAW = ""
	data.handatck = false
	data.random = rng:Random(0,90)
	data.VesselSpawn = false
end, 407)

function HMBP:Hush(boss)
	if boss.Variant == 0 and game.Difficulty % 2 == 1 then

		local sprhs = boss:GetSprite()
		local target = boss:GetPlayerTarget()
		local data = boss:GetData()
		local angle = (target.Position - boss.Position):GetAngleDegrees()
		local Room = game:GetRoom()

		if not data.NumSpit then
			data.NumSpit = 0
		end

		if boss.State == 150 then
			if sprhs:IsPlaying("DissapearLong") then
				if sprhs:GetFrame() >= 8 then
					if sprhs:GetFrame() == 11 then
						boss:PlaySound(314, 1, 0, false, 1)
						game:ShakeScreen(10)
						boss.EntityCollisionClass = 0
						boss:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
						boss.DepthOffset = -100
					end
				end
			elseif sprhs:IsPlaying("Appear") then
				if sprhs:GetFrame() == 70 then
					boss.EntityCollisionClass = 4
					boss:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
					boss.DepthOffset = 0
				end
			end
			if sprhs:IsFinished("DissapearLong") then
				sprhs:Play("Appear", true)
				boss.Position = Room:GetCenterPos()
				boss.TargetPosition = boss.Position
				boss.EntityCollisionClass = 1
			elseif sprhs:IsFinished("Appear") then
				boss.State = 229
				sprhs:Play("Puffed2", true)
				boss.StateFrame = 0
				boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
		elseif boss.State == 152 then
			if sprhs:IsPlaying("HandsOut") and sprhs:GetFrame() == 44 then
				data.hand = true
				game:ShakeScreen(15)
				boss:PlaySound(182, 0.85, 0, false, 1)
				for i=0, 1 do
					local hand = Isaac.Spawn(506, i, 0, boss.Position+Vector(150-i*300,100), Vector(0,0), boss)
					hand.Parent = boss
				end
			end
			if sprhs:IsFinished("HandsOut") then
				boss.State = 3
				sprhs:Play("Wiggle", true)
				boss:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
				boss.StateFrame = 50
			end
		elseif boss.State == 229 then
			boss.StateFrame = boss.StateFrame + 1
			if sprhs:IsPlaying("Puffed2") and sprhs:GetFrame() == 12 then
				boss:PlaySound(425, 1, 0, false, 0.7)
				data.breathhold = true
			end
			if sprhs:IsPlaying("Puffed2Loop") then
				if boss.StateFrame == 46 then
					local bvessel = game:Spawn(608, 0, Vector(Room:GetCenterPos().X*0.5,Room:GetCenterPos().Y), Vector(0,0), boss, 0, 1)
					bvessel.SpawnerEntity = boss
				elseif boss.StateFrame == 53 then
					local bvessel2 = game:Spawn(608, 0, Vector(Room:GetCenterPos().X*1.5,Room:GetCenterPos().Y), Vector(0,0), boss, 1, 2)
					bvessel2.SpawnerEntity = boss
				elseif boss.StateFrame == 60 then
					local bvessel3 = game:Spawn(608, 0, Vector(Room:GetCenterPos().X,Room:GetCenterPos().Y*0.73), Vector(0,0), boss, 2, 3)
					bvessel3.SpawnerEntity = boss
				elseif boss.StateFrame == 67 then
					local bvessel4 = game:Spawn(608, 0, Vector(Room:GetCenterPos().X,Room:GetCenterPos().Y*1.27), Vector(0,0), boss, 3, 4)
					bvessel4.SpawnerEntity = boss
				end
				if boss.StateFrame >= 146 then
					sprhs:Play("BVesselBurst", true)
				end
			elseif sprhs:IsPlaying("PantLoop") then
				if sprhs:GetFrame() == 55 then
					boss:PlaySound(14, 1, 0, false, 0.7)
				end
				if boss.StateFrame >= 700 then
					sprhs:Play("PantEnd", true)
				end
			end
			if boss.StateFrame % 50 == 0 and boss.StateFrame >= 160 and boss.StateFrame < 400 and denpnapi then
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Hushling"), 0, Isaac.GetRandomPosition(1), Vector(0,0), boss)
				boss:PlaySound(423, 0.45, 0, false, math.random(15,20) * 0.1)
			end
			if sprhs:IsPlaying("Puffed2Loop3") and boss.StateFrame >= 400 then
				sprhs:Play("Pant", true)
				boss:PlaySound(422, 1, 0, false, 1.5)
				data.breathhold = false
				boss:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
			if sprhs:IsFinished("Puffed2") then
				sprhs:Play("Puffed2Loop", true)
			elseif sprhs:IsFinished("BVesselBurst") then
				sprhs:Play("Puffed2Loop3", true)
			elseif sprhs:IsFinished("Pant") then
				sprhs:Play("PantLoop", true)
			elseif sprhs:IsFinished("PantEnd") then
				boss.State = 3
				sprhs:Play("Wiggle", true)
				boss.StateFrame = 30
			end
		elseif boss.State == 301 then
			boss.ProjectileCooldown = boss.ProjectileCooldown + 1
			if sprhs:IsFinished("FaceVanishFromDown") then
				sprhs:Play("FaceAppear"..data.FAW, true)
			end
			if data.FAW == "LD" then
				direction = 135
				bltpos = boss.Position + Vector(-50,0)
				bltpos2 = boss.Position + Vector(0,-13)
				bltpos3 = boss.Position + Vector(-74,-57)
			elseif data.FAW == "RD" then
				direction = 45
				bltpos = boss.Position + Vector(50,0)
				bltpos2 = boss.Position + Vector(74,-57)
				bltpos3 = boss.Position + Vector(0,-13)
			end
			if sprhs:IsFinished("FaceAppear"..data.FAW) then
				sprhs:Play("AttackLoop"..data.FAW, true)
				boss.ProjectileCooldown = 0
				boss.I2 = boss.I2 - 1
			end
			if boss.ProjectileCooldown == 32 then
				if sprhs:IsPlaying("AttackLoop"..data.FAW) then
					sprhs:Play("AttackReady"..data.FAW, true)
				end
			elseif boss.ProjectileCooldown == 149 then
				sprhs:Play("FaceVanish"..data.FAW, true)
			end
			if sprhs:IsFinished("AttackReady"..data.FAW) then
				sprhs:Play("AttackLoop"..data.FAW.."2", true)
				boss:PlaySound(422, 1, 0, false, 1)
			end
			if sprhs:IsPlaying("AttackLoop"..data.FAW)
			or sprhs:IsPlaying("AttackReady"..data.FAW)
			or sprhs:IsPlaying("AttackLoop"..data.FAW.."2") then
				if boss.FrameCount % 10 == 0 and not sprhs:IsPlaying("AttackLoop"..data.FAW.."2") then
					local Eye = HMBP.ProjectileParams()
					Eye.FallingAccelModifier = -0.165
					Eye.FallingSpeedModifier = 0
					Eye.HeightModifier = -6
					Eye.BulletFlags = ProjectileFlags.CONTINUUM
					Eye.Scale = 1.5
					Eye.Color = Color(0.3,0,0.5,1,0,0,0)
					Eye.Variant = REPENTANCE and 6 or 0
					HMBP.FireProjectile(boss, bltpos2, Vector.FromAngle(direction - (35 - boss.FrameCount % 50) * 2):Resized(7), 0, Eye)
					HMBP.FireProjectile(boss, bltpos3, Vector.FromAngle(direction + (35 - boss.FrameCount % 50) * 2):Resized(7), 0, Eye)
				end
				if sprhs:IsPlaying("AttackLoop"..data.FAW.."2")
				and boss.ProjectileCooldown <= 139 then
					local Mouth = HMBP.ProjectileParams()
					Mouth.FallingAccelModifier = -0.17
					Mouth.FallingSpeedModifier = 0
					if math.random(1,6) == 1 then
						Mouth.BulletFlags = 1 << 5 | ProjectileFlags.CONTINUUM
					elseif math.random(1,6) == 2 then
						Mouth.BulletFlags = 1 << 22 | ProjectileFlags.CONTINUUM
					else
						Mouth.BulletFlags = ProjectileFlags.CONTINUUM
					end
					Mouth.HeightModifier = -math.random(65,140) * 0.1
					Mouth.Scale = 1.5
					Mouth.Variant = REPENTANCE and 6 or 0
					Mouth.Color = Color(0.3,0,0.5,1,0,0,0)
					boss:FireProjectiles(bltpos + Vector.FromAngle(direction-90):Resized(math.random(-35,35)),
					Vector.FromAngle(direction):Resized(20), 0, Mouth)
				end
			end
			if sprhs:IsFinished("FaceVanish"..data.FAW) then
				if boss.I2 <= 0 then
					sprhs:Play("FaceAppearDown", true)
				else
					if data.FAW == "LD" then
						data.FAW = "RD"
					elseif data.FAW == "RD" then
						data.FAW = "LD"
					end
					sprhs:Play("FaceAppear"..data.FAW, true)
				end
			end
			if sprhs:IsFinished("FaceAppearDown")then
				boss.StateFrame = 150
			end
		elseif boss.State == 350 then
			if boss.StateFrame > 1 then
				data.handatck = true
			else
				data.handatck = false
			end
			if sprhs:IsFinished("Puffed") then
				sprhs:Play("OpenMouth2", true)
			end
			if sprhs:IsPlaying("OpenMouth2") and sprhs:GetFrame() == 4 then
				boss:PlaySound(421, 1, 0, false, 1)
				boss:PlaySound(423, 1, 0, false, 1)
				local bloodshot = EntityLaser.ShootAngle(REPENTANCE and 6 or 1, boss.Position+Vector(0,5), 90, boss.StateFrame, Vector(0,-40), boss)
				bloodshot.Size = REPENTANCE and bloodshot.Size or 80

				if HMBPENTS then
					bloodshot:GetData().lflag = 1
					bloodshot:GetData().pvl = 6.5
					bloodshot:GetData().pdensity = 16
				end

				local bloodshot2 = EntityLaser.ShootAngle(1, Vector(boss.Position.X,705), 0, boss.StateFrame, Vector(0,0), boss)
				bloodshot2.DisableFollowParent = true
				bloodshot2:SetActiveRotation(50, -45, -0.16, false)
				local bloodshot3 = EntityLaser.ShootAngle(1, Vector(boss.Position.X,705), 180, boss.StateFrame, Vector(0,0), boss)
				bloodshot3.DisableFollowParent = true
				bloodshot3:SetActiveRotation(50, 45, 0.16, false)
			end
			if sprhs:IsFinished("OpenMouth2") then
				sprhs:Play("OpenMouth2Loop", true)
			end
			if sprhs:IsPlaying("OpenMouth2Loop") then
				boss.Velocity = Vector(0,-0.95)
				boss.StateFrame = boss.StateFrame - 1
				if (HMBPENTS and boss.FrameCount % 25 == 0) or (not HMBPENTS and boss.FrameCount % 10 == 0) then
					data.random = math.random(0,90)
					local eye = HMBP.ProjectileParams()
					eye.FallingAccelModifier = -0.17
					eye.HeightModifier = -7
					eye.Color = Color(0.85,0.85,1.5,1,0,0,0)
					if not HMBPENTS then
						eye.BulletFlags = 1 << 5
					end
					for i=0, 324, 36 do
						boss:FireProjectiles(boss.Position+Vector(0,5), Vector.FromAngle(i+angle):Resized(6.5), 0, eye)
					end
				end
				if boss.StateFrame <= 0 then
					sprhs:Play("CloseMouth2", true)
				end
			end
		elseif boss.State == 600 then
			if sprhs:IsPlaying("FaceAppearDown") or not data.FAW then
				data.FAW = "Down"
			elseif sprhs:IsPlaying("FaceAppearLeft") then
				data.FAW = "Left"
			elseif sprhs:IsPlaying("FaceAppearRight") then
				data.FAW = "Right"
			elseif sprhs:IsPlaying("FaceAppearUp") then
				data.FAW = "Up"
			end

			if boss.HitPoints / boss.MaxHitPoints <= 0.8 then
				if sprhs:IsPlaying("FaceAppear"..data.FAW) and sprhs:GetFrame() == 12
				and math.random(1,2) == 1 then
					boss.State = 601
					boss.I2 = math.random(0,299)
					boss.StateFrame = math.random(200,350)
					sprhs:Play("AttackLoop"..data.FAW, true)
				end
			end
		elseif boss.State == 601 then
			boss.StateFrame = boss.StateFrame - 1
			if data.FAW == "Down" then
				bltpos = boss.Position + Vector(46,-60)
				bltpos2 = boss.Position + Vector(-56,-59)
				bltpos3 = boss.Position + Vector(0,-35)
				direction = 90
			elseif data.FAW == "Left" then
				bltpos = boss.Position + Vector(-24,9)
				bltpos2 = boss.Position + Vector(-55,-72)
				bltpos3 = boss.Position + Vector(-78,-20)
				direction = 180
			elseif data.FAW == "Right" then
				bltpos = boss.Position + Vector(52,-76)
				bltpos2 = boss.Position + Vector(28,7)
				bltpos3 = boss.Position + Vector(80,-31)
				direction = 0
			elseif data.FAW == "Up" then
				bltpos = boss.Position + Vector(-55,-45)
				bltpos2 = boss.Position + Vector(51,-46)
				bltpos3 = boss.Position + Vector(0,-70)
				direction = 270
			end
			if boss.StateFrame > 20 then
				if boss.I2 % 4 <= 2 then
					local C1 = REPENTANCE and (70 / 255) or 70
					local C2 = REPENTANCE and {20 / 255, 50 / 255} or {20, 50}

					local eye1 = HMBP.ProjectileParams()
					eye1.HeightModifier = -10
					eye1.Variant = 6
					eye1.FallingSpeedModifier = 0
					eye1.FallingAccelModifier = -0.17
					if boss.I2 % 4 == 0 and boss.StateFrame % 3 == 0 then
						eye1.BulletFlags = 1 << 21
						eye1.Color = Color(1,1,1,1,C1,C1,0)
						boss:FireProjectiles(bltpos,
						Vector.FromAngle(direction-(boss.FrameCount*6)):Resized(3), 0, eye1)
					elseif boss.I2 % 4 == 1 and boss.StateFrame % 30 == 0 then
						eye1.Color = Color(1,1,1,1,C1,C1,0)
						for i=0, 340, 20 do
							boss:FireProjectiles(bltpos, Vector.FromAngle((target.Position - bltpos):GetAngleDegrees()+i):Resized(5), 0, eye1)
						end
					elseif boss.I2 % 4 == 2 and boss.StateFrame % 70 <= 10 and boss.StateFrame % 2 == 0 and HMBPENTS then
						local params = HMBPEnts.ProjParams()
						params.HeightModifier = -10
						params.FallingSpeedModifier = 0
						params.FallingAccelModifier = -0.17
						params.BulletFlags = 1 << 27 | 1 << 32
						params.Acceleration = 0.96
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
						params.ChangeTimeout = 75
						params.ChangeFlags = 0
						params.HomingStrength = 0.55
						params.Color = Color(1, 1, 1, 1, C2[1], C2[2], C2[1])
						HMBPEnts.FireProjectile(boss, 6, bltpos, Vector.FromAngle(angle):Resized(6.5), params)
					end
				end
				if boss.I2 % 40 >= 10 then
					local C1 = REPENTANCE and (70 / 255) or 70
					local C2 = REPENTANCE and {20 / 255, 50 / 255} or {20, 50}

					local eye2 = HMBP.ProjectileParams()
					eye2.HeightModifier = -10
					eye2.Variant = 6
					eye2.FallingSpeedModifier = 0
					eye2.FallingAccelModifier = -0.17
					if boss.I2 % 40 >= 30 then
						if boss.StateFrame % 3 == 0 then
							eye2.BulletFlags = 1 << 21
							eye2.Color = Color(1,1,1,1,C1,C1,0)
							boss:FireProjectiles(bltpos2,
							Vector.FromAngle(direction+(boss.FrameCount*6)):Resized(3), 0, eye2)
						end
					elseif boss.I2 % 40 >= 20 then
						if boss.StateFrame % 13 == 0 then
							eye2.Color = Color(1,1,1,1,0,0,C1)
							boss:FireProjectiles(bltpos2,
							Vector.FromAngle((target.Position - bltpos2):GetAngleDegrees()):Resized(7.5), 0, eye2)
						end
					elseif boss.I2 % 40 >= 10 then
						if boss.FrameCount % 70 <= 30 and boss.StateFrame % 2 == 0 then
							eye2.Color = Color(1,1,1,1,C2[1], C2[2], C2[1])
							boss:FireProjectiles(bltpos2,
							Vector.FromAngle(direction + (boss.FrameCount % 70)*6):Resized(7), 0, eye2)
						end
					end
				end
				local mouth = HMBP.ProjectileParams()
				mouth.Variant = 6
				mouth.HeightModifier = -3.5
				mouth.FallingSpeedModifier = 0
				mouth.FallingAccelModifier = -0.17
				if boss.I2 >= 200 then
					if boss.StateFrame % 30 == 0 then
						mouth.Color = Color(1,1,1,1,0,0,REPENTANCE and 70 / 255)
						boss:FireProjectiles(bltpos3,
						Vector.FromAngle((target.Position - bltpos3):GetAngleDegrees()):Resized(7), 5, mouth)
					end
				elseif boss.I2 >= 100 then
					if boss.StateFrame % 5 == 0 then
						local Div = REPENTANCE and 255 or 1

						mouth.Color = Color(1,1,1,1,70 / Div,35 / Div,0)
						for i=-15, 15, 30 do
							boss:FireProjectiles(bltpos3,
							Vector.FromAngle((target.Position - bltpos3):GetAngleDegrees()+i):Resized(13), 0, mouth)
						end
					end
				else
					if boss.StateFrame % 45 == 0 then
						local Div = REPENTANCE and 255 or 1

						mouth.BulletFlags = 1 << math.random(11, 12)
						mouth.TargetPosition = bltpos3
						mouth.Color = Color(1, 1, 1, 1, 70 / Div, 35 / Div, 0)

						for i=0, 355, 5 do
							if not ((i >= 0 and i <= 25) or (i >= 180 and i <= 205)) and math.random(1,2) ~= 1 then
								boss:FireProjectiles(bltpos3, Vector.FromAngle(angle+i):Resized(5.3), 0, mouth)
							end
						end
					end
				end
			end
			if boss.StateFrame <= 0 then
				if sprhs:IsPlaying("AttackLoop"..data.FAW) then
					sprhs:Play("FaceVanishFrom"..data.FAW, true)
				end
				if sprhs:IsFinished("FaceAppearDown") then
					sprhs:Play("Wiggle", true)
					boss.State = 3
				end
			end
			if sprhs:IsFinished("FaceVanishFrom"..data.FAW) then
				sprhs:Play("FaceAppearDown", true)
			end
		elseif boss.State == 666 then
			if sprhs:GetFrame() == 12 and HMBPENTS then
				boss:PlaySound(421, 1, 0, false, 1)
				local params = HMBPEnts.ProjParams()
				params.FallingAccelModifier = -0.09
				params.HMBPBulletFlags = HMBPEnts.ProjFlags.BURST_BLOODVESSEL
				params.Scale = 2

				for i=15, 330, 45 do
					HMBPEnts.FireProjectile(boss, 0, boss.Position + Vector.FromAngle(i):Resized(100), Vector.FromAngle(i):Resized(4.3), params)
				end
			end
			if sprhs:IsFinished("Spit") then
				sprhs:Play("Wiggle", true)
				boss.State = 3
				boss.StateFrame = 50
			end
		end

		if boss.State ~= 229 then
			data.breathhold = false
		end

		if boss.HitPoints / boss.MaxHitPoints <= 0.2 and HMBPENTS then
			if sprhs:IsPlaying("Wiggle") and not data.isdelirium and not data.hand then
				boss.State = 152
				sprhs:Play("HandsOut", true)
				boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
		end
		if boss.HitPoints / boss.MaxHitPoints <= 0.3 and sprhs:GetFrame() == 1
		and ((sprhs:IsPlaying("OpenMouth") and math.random(1,3) == 1)
		or (sprhs:IsPlaying("LaserStart") and math.random(1,2) == 1)) and not data.handatck then
			sprhs:Play("Puffed", true)
			boss.State = 350
			boss.StateFrame = math.random(450,500)
		end
		if boss.HitPoints / boss.MaxHitPoints <= 0.4 and boss.State == 3 and not data.VesselSpawn then
			if Room:GetCenterPos():Distance(boss.Position) < 60 then
				sprhs:SetFrame("Appear", 78)
			else
				sprhs:Play("DissapearLong", true)
			end
			boss.State = 150
			data.VesselSpawn = true
		end
		if boss.HitPoints / boss.MaxHitPoints <= 0.5 then
			if boss.State == 300 and sprhs:IsPlaying("FaceVanishFromDown") then
				boss.State = 301
				boss.I2 = math.random(2,5)
				boss.ProjectileCooldown = 0
				if math.random(1,2) == 1 then data.FAW = "LD" else data.FAW = "RD" end
			end
		end

		if boss.HitPoints / boss.MaxHitPoints <= 0.6 and (sprhs:IsPlaying("Tell1") or sprhs:IsPlaying("OpenMouth"))
		and sprhs:GetFrame() == 1 and math.random(1, 2) == 1 and data.NumSpit < 2 then
			sprhs:Play("Spit", true)
			boss.State = 666
		end

		if sprhs:GetFrame() == 1 and boss.State > 7 then
			if sprhs:IsPlaying("Spit") then
				data.NumSpit = data.NumSpit + 1
			else
				data.NumSpit = 0
			end
		end

		if (boss.State == 301 and sprhs:IsFinished("FaceAppearDown")) or sprhs:IsFinished("CloseMouth2") then
			sprhs:Play("Wiggle", true)
			boss.State = 3
			boss.StateFrame = 50
			boss.TargetPosition = boss.Position
		end

	end
end


HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Hush, 407)
