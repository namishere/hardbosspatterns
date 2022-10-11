local sound = SFXManager()
local Level = Game():GetLevel()

----------------------------
--add Boss Pattern:??? (Alt)
----------------------------
  function bpattern:HsBaby(boss)

	if boss.Variant == Isaac.GetEntityVariantByName("??? (Alt)")
	and Game().Difficulty % 2 == 1 then

	local sprbb = boss:GetSprite()
	local data = boss:GetData()
	local target = boss:GetPlayerTarget()
	local angle = (target.Position - boss.Position):GetAngleDegrees()

	if sprbb:GetFrame() == 1 and sprbb:IsPlaying("3FBAttack4Start") and boss.State == 8 and math.random(1,3) == 1 then
		boss.State = 10
		sprbb:Play("3FBAttack4Start", true)
		boss.StateFrame = math.random(50,150)
		boss.I1 = math.random(1,2)
		boss.ProjectileCooldown = 0
	end

	if not data.i3 then
		data.i3 = 0
	end

	if boss.State == 8 and sprbb:IsPlaying("2Attack") then
		if sprbb:GetFrame() == 2 then
			if data.i3 == 1 then
				if boss.I1 == 1 then
					boss.I1 = 2
					data.i3 = 0
				end
			else
				if boss.I1 == 0 then
					data.i3 = 1
				end
			end
		elseif sprbb:GetFrame() == 8 and boss.I1 == 2 then
			if HMBPENTS then
				local params = HMBPEnts.ProjParams()
				params.FallingAccelModifier = 0.15
				params.BulletFlags = ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
				params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
				params.ChangeFlags = 1 << 1
				params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
				params.Scale = 1.5
				params.Color = Color(1,1,1,5,0,0,0)
				params.HomingStrength = 0.75

				for i=0, 18, 6 do
					params.FallingSpeedModifier = -9 - i * 0.8
					params.ChangeTimeout = 20 + i * 2
					HMBPEnts.FireProjectile(boss, 4, boss.Position, Vector(0, 0), params)
				end
			else
				local params = ProjectileParams()
				params.FallingAccelModifier = 0.15
				params.BulletFlags = ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
				params.ChangeFlags = 1 | 1 << 1
				params.ChangeVelocity = 8
				params.Variant = 4
				params.Scale = 1.5
				params.Color = Color(1,1,1,5,0,0,0)
				params.HomingStrength = 0.75

				for i=0, 18, 6 do
					params.FallingSpeedModifier = -9 - i * 0.8
					params.ChangeTimeout = 20 + i * 2
					boss:FireProjectile(boss.Position, Vector(0, 0), 0, params)
				end
			end
		end
	end
	if boss.State == 10 then
		boss.StateFrame = boss.StateFrame - 1
		boss.ProjectileCooldown = boss.ProjectileCooldown - 1
		if sprbb:IsFinished("3FBAttack4Start") then
			sprbb:Play("3FBAttack4Loop", true)
		elseif sprbb:IsFinished("3FBAttack4End") then
			boss.State = 8
		end
		if sprbb:IsPlaying("3FBAttack4Start") and sprbb:GetFrame() == 21 then
			boss:PlaySound(129, 1, 0, false, 1)
			data.attacking = true
		elseif sprbb:IsPlaying("3FBAttack4Loop") and boss.StateFrame <= 0 then
			sprbb:Play("3FBAttack4End", true)
			data.attacking = false
		end
		if data.attacking then
			if boss.I1 == 1 then
				if boss.StateFrame % 2 == 0 then
					boss:PlaySound(267, 0.65, 0, false, 1)
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.165
					params.Variant = 4
					for i=0, 270, 90 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i+boss.StateFrame*4.3):Resized(6.5), 0, params)
					end
				end
			elseif boss.I1 == 2 then
				if boss.ProjectileCooldown <= 0 then
					boss.ProjectileCooldown = 13
					boss:PlaySound(267, 0.65, 0, false, 1)
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.1
					params.Variant = 4
					for i=-6, 12, 1.5 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(angle):Resized(i), 0, params)
						if i < 7 then
							boss:FireProjectiles(boss.Position, Vector.FromAngle(angle+90):Resized(i), 0, params)
						end
					end
				end
			end
		end
	end

  end
  end

----------------------------
--Add Boss Pattern:Mega Satan
----------------------------
  function bpattern:MSatan(boss)

	if boss.Variant == 0 then

	local sprms = boss:GetSprite()
	local target = Game():GetPlayer(1)
	local dist = target.Position:Distance(boss.Position)
	local data = boss:GetData()
	local angle = (target.Position - boss.Position):GetAngleDegrees()

	if boss.State == 13 and Game().Difficulty % 2 == 1 then
	if sprms:IsPlaying("Hide") then
		boss.I2 = 0
		boss.ProjectileCooldown = math.random(150,200)
	else
		if boss.I2 == 0 then
			boss.ProjectileCooldown = boss.ProjectileCooldown - 1
			if boss.ProjectileCooldown <= 0 then
				boss.StateFrame = 0
				if data.isdelirium then
					data.i3 = math.random(1,3)
					boss.I2 = math.random(1,2)
				else
					data.i3 = math.random(1,3)
					if #Isaac.FindByType(274, 1, -1, true, true) == 0
					and #Isaac.FindByType(274, 2, -1, true, true) == 0 then
						boss.I2 = 2
					else
						boss.I2 = math.random(2,3)
					end
				end
			end
		else
			boss.StateFrame = boss.StateFrame + 1
			if boss.I2 == 1 then
				if boss.StateFrame >= 94 then
					boss.I2 = 0
					boss.ProjectileCooldown = math.random(150,200)
				elseif boss.StateFrame >= 30 then
					boss:SetSpriteFrame("HidingShoot1", boss.StateFrame-29)
					if boss.StateFrame >= 35 and boss.StateFrame % 8 == 0 then
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.165
						params.HeightModifier = -7
						for i=210, 330, 14 do
							boss:FireProjectiles(Vector(boss.Position.X,690),
							Vector.FromAngle(i+((boss.FrameCount % 2)*7)):Resized(5.5), 0, params)
						end
					end
				else
					boss:SetSpriteFrame("HidingCharging", boss.StateFrame+1)
				end
				if boss.StateFrame == 35 then
					EntityLaser.ShootAngle(6, boss.Position + Vector(0, 1), 90, 50, Vector(0, -20), boss)
				elseif boss.StateFrame == 1 then
					boss:PlaySound(240, 1, 0, false, 1)
				end
			elseif boss.I2 == 2 then
				if boss.StateFrame >= 256 then
					boss.I2 = 0
					boss.ProjectileCooldown = math.random(150,200)
				elseif boss.StateFrame >= 250 then
					boss:SetSpriteFrame("HidingShoot2End", boss.StateFrame-249)
				elseif boss.StateFrame >= 35 then
					boss:SetSpriteFrame("HidingShoot2Loop", (boss.StateFrame % 9)+1)
					if boss.StateFrame % 40 == 0 then
						boss:PlaySound(245, 1, 0, false, 1)
						if data.i3 ~= 1 then
							data.angle = (target.Position - boss.Position):GetAngleDegrees()
						end
					end
					if data.i3 == 1 and boss.StateFrame % 41 == 0 then
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.16
						params.BulletFlags = ProjectileFlags.HIT_ENEMIES
						params.Scale = 2
						params.HeightModifier = -7
						for i=30-(boss.StateFrame % 2)*15, 150+(boss.StateFrame % 2)*15, 30 do
							boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(5), 0, params)
						end
					elseif data.i3 == 2 and boss.StateFrame % 40 <= 10 and boss.StateFrame % 2 == 0 then
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.065
						params.Scale = 2
						params.HeightModifier = -7
						boss:FireProjectiles(boss.Position, Vector.FromAngle(data.angle):Resized(11), 0, params)
					elseif data.i3 == 3 and boss.StateFrame % 30 == 0 then
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.15
						params.Scale = 2
						params.HeightModifier = -7
						for i=0, 340, 20 do
							boss:FireProjectiles(boss.Position, Vector.FromAngle(data.angle):Resized(5) + Vector.FromAngle(i):Resized(1), 0, params)
						end
					end
				elseif boss.StateFrame >= 30 then
					boss:SetSpriteFrame("HidingShoot2Start", boss.StateFrame-29)
				else
					boss:SetSpriteFrame("HidingCharging", boss.StateFrame+1)
				end
				if boss.StateFrame == 1 then
					boss:PlaySound(240, 1, 0, false, 1)
				end
			elseif boss.I2 == 3 then
				if boss.StateFrame <= 58 then
					boss:SetSpriteFrame("HidingSmash", boss.StateFrame)
				else
					boss.I2 = 0
					boss.ProjectileCooldown = math.random(150,200)
				end
				if boss.StateFrame == 1 then
					boss:PlaySound(239, 1, 0, false, 1)
				end
			end
		end
		if boss.I2 > 3 then
			boss.I2 = 0
			if data.isdelirium then
				boss.ProjectileCooldown = math.random(110,160)
			else
				boss.ProjectileCooldown = math.random(150,200)
			end
		end
	end
	end

	if Game().Difficulty % 2 == 1 then

	if sprms:IsEventTriggered("ShootStart") and math.random(1,5) <= 2 then
		boss.State = 10
		boss.I2 = math.random(1,3)
		boss.ProjectileCooldown = 0
	end

	if boss.State == 10 then
		boss.StateFrame = boss.StateFrame - 1
		if boss.I2 == 1 then
			boss.ProjectileCooldown = boss.ProjectileCooldown + 1
			if boss.ProjectileCooldown >= 20 then
				boss.ProjectileCooldown = 0
			end
			if sprms:IsFinished("Shoot2Start") then
				sprms:Play("Shoot2Loop", true)
				boss.StateFrame = 205
			end
			if boss.ProjectileCooldown == 1 then
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.1
				params.Scale = 2
				params.HeightModifier = -7
				for i=15, 1, -1 do
					boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10), Vector.FromAngle(angle):Resized(i), 0, params)
				end
			end
		elseif boss.I2 == 2 then
			if sprms:IsFinished("Shoot2Start") then
				sprms:Play("Shoot2Loop", true)
				boss.StateFrame = 240
			end
			if boss.StateFrame % 30 == 0 then
				data.random = math.random(4,14) * 10
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.155
				params.Scale = 1.8
				params.BulletFlags = ProjectileFlags.HIT_ENEMIES
				params.HeightModifier = -7

				for i=0, data.random-20, 5 do
					boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10), Vector.FromAngle(i):Resized(4), 0, params)
				end

				for i=180, data.random+20, -5 do
					boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10), Vector.FromAngle(i):Resized(4), 0, params)
				end
			end
		elseif boss.I2 == 3 then
			if sprms:IsFinished("Shoot2Start") then
				sprms:Play("Shoot2Loop", true)
				boss.StateFrame = 320
			end
			if boss.StateFrame % 2 == 0 then
				local params = ProjectileParams()
				params.Scale = 2
				params.FallingAccelModifier = -0.03
				params.HeightModifier = -7
				params.BulletFlags = ProjectileFlags.HIT_ENEMIES
				boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10),
				Vector.FromAngle(angle):Resized(dist*0.03), 0, params)

				if boss.StateFrame % 40 == 0 then
					for i=-20, 20, 40 do
						boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10), Vector.FromAngle(angle + i):Resized(dist*0.03), 0, params)
					end
				end
			end
		end
		if sprms:IsPlaying("Shoot2Loop") then
			if boss.StateFrame % 40 == 0 then
				boss:PlaySound(245, 1, 0, false, 1)
			end
			if boss.StateFrame <= 0 then
				sprms:Play("Shoot2End", true)
			end
		end
		if sprms:IsFinished("Shoot2End") then
			sprms:Play("Idle", true)
			boss.State = 3
		end
	end
	end

  end
  end

  function bpattern:MSHand(boss)

	if boss.Variant ~= 0 and Game().Difficulty % 2 == 1 and not boss:GetData().isdelirium then

	local sprshnd = boss:GetSprite()
	local target = Game():GetPlayer(1)
	local dist = target.Position:Distance(boss.Position)
	local data = boss:GetData()
	local Entities = Isaac:GetRoomEntities()
	--angle = (target.Position - boss.Position):GetAngleDegrees()

	if boss.State == 13 then
		if boss.Variant == 1 then
			data.tpos = Vector(203,370)
		else
			data.tpos = Vector(473,370)
		end
		if boss.I2 == 1 then
			boss.Velocity = Vector.FromAngle((data.tpos - boss.Position):GetAngleDegrees()):Resized(data.tpos:Distance(boss.Position)*0.1)
			boss.ProjectileCooldown = boss.ProjectileCooldown + 1
			boss:SetSpriteFrame("HidingSmash", boss.ProjectileCooldown + 1)
			if boss.ProjectileCooldown == 31 then
				boss:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(20)
				if #Isaac.FindByType(271, -1, -1, true, true) > 0 or #Isaac.FindByType(272, -1, -1, true, true) > 0 then
					for i=45, 135, 90 do
						local shockwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss):ToEffect()
						shockwave.Parent = boss
						shockwave.Rotation = i
					end
				else
					local shockwave = Isaac.Spawn(1000, 67, 0, boss.Position, Vector(0,0), boss)
					shockwave.Parent = boss
				end
			end
			if boss.ProjectileCooldown >= 31 and boss.ProjectileCooldown <= 54 then
				boss.EntityCollisionClass = 4
			end
		end
	elseif boss.State == 10 then
		boss.GridCollisionClass = 0
		if sprshnd:IsFinished("Charging2") then
			sprshnd:Play("Blast", true)
		end
		if sprshnd:IsPlaying("Blast") and sprshnd:GetFrame() == 6 then
			EntityLaser.ShootAngle(6, boss.Position, 90, 40, Vector(0,-40), boss)
		end
		if sprshnd:IsFinished("Blast") then
			boss.State = 3
		end
	end

	for k, v in pairs(Entities) do
		if v.Type == 274 then
		if v.Variant == 0 then
			if boss.State == 11 then
				if sprshnd:IsPlaying("Punch") then
					if sprshnd:GetFrame() == 1 then
						boss.TargetPosition = v.Position + Vector(120+((boss.Variant-2)*240),-20)
					elseif sprshnd:GetFrame() == 25 then
						boss.Velocity = Vector(2.4+((boss.Variant-2)*4.8),-3)
					elseif sprshnd:GetFrame() == 54 then
						boss.TargetPosition = v.Position + Vector(30+((boss.Variant-2)*60),20)
					end
					if sprshnd:GetFrame() > 27 and sprshnd:GetFrame() < 36 then
						if sprshnd:GetFrame() == 28 then
							boss:PlaySound(182, 1, 0, false, 1)
						end
						boss.TargetPosition = v.Position + Vector(0,300)
						boss.Velocity = Vector.FromAngle((boss.TargetPosition-boss.Position):GetAngleDegrees()):Resized(boss.TargetPosition:Distance(boss.Position)*0.3)
					end
					if sprshnd:GetFrame() == 65 then
						boss.TargetPosition = v.Position + Vector(120+((boss.Variant-2)*240),100)
					end
				else
					boss.State = 3
				end
			elseif boss.State == 10 then
				boss.TargetPosition = v.Position + Vector(boss.Variant == 1 and -240 or 240,80)
			end
			if v:ToNPC().State == 13 and v:ToNPC().I2 == 3 and boss.State == 13 then
				boss.I2 = 1
			else
				boss.I2 = 0
				boss.ProjectileCooldown = 0
			end
			if boss.I2 == 0 and boss.State == 13 and
			(v:GetSprite():IsPlaying("Hiding") or v:ToNPC().I2 > 0)
			and not sprshnd:IsPlaying("Hide") then
				sprshnd:Play("Hiding", true)
			end
			if v:ToNPC().State == 8 and v:GetSprite():IsPlaying("Charging")
			and boss.State == 3 then
				sprshnd:Play("Charging2", true)
				boss.State = 10
			end
			if v:ToNPC().State == 3 and boss.State == 3 and boss.TargetPosition:Distance(boss.Position) < 50
			and boss.FrameCount % 130 == 0 and data.canattack then
				if boss.Variant == 1 or (boss.Variant == 2 and #Isaac.FindByType(274, 1, -1, true, true) == 0) then
					boss.State = 11
					sprshnd:Play("Punch", true)
				end
			end
		elseif v.Variant == 1 then
			if v:ToNPC().State == 8 then
				if boss.Variant == 2 then
					data.canattack = false
					if boss.State == 11 then
						v:ToNPC().State = 3
					end
				end
			else
				if boss.Variant == 2 then
					data.canattack = true
				end
			end
		elseif v.Variant == 2 then
			if v:ToNPC().State == 8 then
				if boss.Variant == 1 then
					data.canattack = false
					if boss.State == 11 then
						v:ToNPC().State = 3
					end
				end
			else
				if boss.Variant == 1 then
					data.canattack = true
				end
			end
		end
		end
	end

  end
  end

----------------------------
--change Boss AI:Mega Satan 2
----------------------------
  function bpattern:MSatanS(boss)

	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then

	local sprss = boss:GetSprite()
	local data = boss:GetData()
	local Entities = Isaac:GetRoomEntities()
	boss.GridCollisionClass = 0

	if sprss:IsPlaying("Appear") and sprss:GetFrame() == 0 then
		if HMBPENTS then
			data.rhandcooldown = 0
			data.lhandcooldown = 0
			local rhand = Isaac.Spawn(399, 1, 0, boss.Position + Vector(-300,-5), Vector(0,0), boss)
			rhand.SpawnerEntity = boss
			local lhand = Isaac.Spawn(399, 2, 0, boss.Position + Vector(300,-5), Vector(0,0), boss)
			lhand.SpawnerEntity = boss
			data.handattacking = false
		end

		data.i4 = 0
	end

	if boss.HitPoints / boss.MaxHitPoints <= 0.66
	and boss.HitPoints / boss.MaxHitPoints > 0.325 then
		data.i3 = 2
	elseif boss.HitPoints / boss.MaxHitPoints <= 0.325 then
		data.i3 = 3
	else
		data.i3 = 1
	end

	--[[if boss.State == 3 and HMBPENTS then
		if #Isaac.FindByType(399, 1, -1, true, true) < 1 then
			if boss.FrameCount >= data.rhandcooldown + 100 then
				local rhand = Isaac.Spawn(399, 1, 1, boss.Position + Vector(-150,115), Vector(0,0), boss)
				rhand.SpawnerEntity = boss
			end
		elseif #Isaac.FindByType(399, 2, -1, true, true) < 1 then
			if boss.FrameCount >= data.lhandcooldown + 100 then
				local lhand = Isaac.Spawn(399, 2, 1, boss.Position + Vector(150,115), Vector(0,0), boss)
				lhand.SpawnerEntity = boss
			end
		end
	end]]

	if boss.HitPoints / boss.MaxHitPoints <= 0.5 and not data.summonpattern then
		boss.I2 = 0
		if boss.State == 3 then
			if sprss:GetFrame() >= 15 then
				boss.State = 12
				boss.I1 = 4
				data.summonpattern = true
				boss.StateFrame = -38
				boss:PlaySound(241, 1, 0, false, 1)
				sprss:Play("Up"..data.i3, true)
			end
		else
			boss:PlaySound(242, 1, 0, false, 1)
			boss.ProjectileCooldown = 0
			boss.State = 3
		end
	end

	if sprss:IsEventTriggered("ShootStart") and math.random(1,5) <= 2 then
		boss.State = 10

		if HMBPENTS then
			boss.I1 = math.random(1,3)
		else
			boss.I1 = 1 + (math.random(0, 1) * 2)
		end
	end

	if boss.State == 10 then
		if sprss:IsFinished("Shoot"..data.i3.."Start") then
			sprss:Play("Shoot"..data.i3.."Loop", true)
			if boss.I1 == 1 then
				boss.StateFrame = 245
			else
				boss.StateFrame = 325
			end
		end

		boss.StateFrame = boss.StateFrame - 1
		if boss.I1 == 1 then
			if boss.StateFrame % 10 == 0 then
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.14
				params.BulletFlags = ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
				params.ChangeFlags = ProjectileFlags.CURVE_LEFT
				params.Variant = 2
				params.ChangeTimeout = ((boss.FrameCount % 7)+1) * 10
				params.CurvingStrength = 0.007

				local params2 = ProjectileParams()
				params2.FallingAccelModifier = -0.165
				params2.BulletFlags = ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
				params2.ChangeFlags = ProjectileFlags.CURVE_RIGHT
				params2.Variant = 2
				params2.ChangeTimeout = ((boss.FrameCount % 7)+1) * 10
				params2.CurvingStrength = 0.007

				if not REPENTANCE then
					params.Color = Color(2,0.2,0.2,1,0,0,0)
					params2.Color = Color(2,0.2,0.2,1,0,0,0)
				end

				boss:FireProjectiles(Vector(boss.Position.X+5,boss.Position.Y+30), Vector.FromAngle(90):Resized(6), 0, params)
				boss:FireProjectiles(Vector(boss.Position.X+5,boss.Position.Y+30), Vector.FromAngle(60):Resized(4.6), 0, params)

				boss:FireProjectiles(Vector(boss.Position.X-5,boss.Position.Y+30), Vector.FromAngle(90):Resized(6), 0, params2)
				boss:FireProjectiles(Vector(boss.Position.X-5,boss.Position.Y+30), Vector.FromAngle(120):Resized(4.6), 0, params2)
			end
		elseif boss.I1 == 2 then
			if boss.StateFrame % 60 == 25 then
				data.i4 = math.abs(data.i4-1)
			end
			if boss.StateFrame % 60 <= 10 and boss.StateFrame % 5 == 0 then
				local params = HMBPEnts.ProjParams()
				params.FallingAccelModifier = -0.09
				params.HMBPBulletFlags = HMBPEnts.ProjFlags.WAVE
				params.Scale = 1.7

				if REPENTANCE then
					local ProjColor = Color.Default
					local Colorize = ProjColor:SetColorize(0.2, 0.5, 2, 1)

					params.Color = ProjColor
				else
					params.Color = Color(0.3, 0.3, 1, 1, 0, 0, 0)
				end

				for i=0, 180, 15 do
					HMBPEnts.FireProjectile(boss, 2, Vector(boss.Position.X, boss.Position.Y + 30), Vector.FromAngle(i + data.i4 * 7.5):Resized(7), params)
				end
			end
		elseif boss.I1 == 3 then
			if boss.StateFrame % 39 == 0 then
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.155
				params.BulletFlags = ProjectileFlags.CONTINUUM
				params.Scale = 2
				params.Color = Color(2,1,5,1,0,0,0)
				params.Variant = 4
				if boss.StateFrame % 2 == 0 then
					dirc = 1
				else
					dirc = -1
				end
				for i=0, 34, 3.4 do
					boss:FireProjectiles(Vector(boss.Position.X,boss.Position.Y+10), Vector(-17+i,4), 0, params)
				end
			end
		end
		if sprss:IsPlaying("Shoot"..data.i3.."Loop") then
			if boss.StateFrame % 40 == 0 then
				boss:PlaySound(245, 1, 0, false, 1)
			end
			if boss.StateFrame <= 0 then
				sprss:Play("Shoot"..data.i3.."End", true)
			end
		end
		if sprss:IsFinished("Shoot"..data.i3.."End") then
			sprss:Play("Idle"..data.i3, true)
			boss.State = 3
		end
	end

	if boss.State == 12 then
		boss.EntityCollisionClass = 0
		boss.StateFrame = boss.StateFrame + 1
		if boss.StateFrame == 1 then
			local satancircle = Isaac.Spawn(1000, 16, 0, Vector(320,520), Vector(0,0), boss)
			satancircle:GetSprite():Load("gfx/megasatancircle_glimmer.anm2", true)
			satancircle:GetSprite():Play("Blink", true)
			satancircle.DepthOffset = -100
		end
		if boss.StateFrame >= 50 and Isaac.CountBosses() <= 1 then
			if boss.I1 > 0 then
				if boss.StateFrame == 50 then
				boss.I1 = boss.I1 - 1
				boss:PlaySound(265, 1, 0, false, 1)
					if boss.I1 == 3 then
						Isaac.Spawn(404, 0, 0, Vector(280,520), Vector(0,0), boss)
						Isaac.Spawn(411, 0, 0, Vector(360,520), Vector(0,0), boss)
					elseif boss.I1 == 2 then
						Isaac.Spawn(69, 0, 0, Vector(280,520), Vector(0,0), boss)
						Isaac.Spawn(267, 0, 0, Vector(360,520), Vector(0,0), boss)
					elseif boss.I1 == 1 then
						Isaac.Spawn(69, 1, 0, Vector(280,520), Vector(0,0), boss)
						Isaac.Spawn(268, 0, 0, Vector(360,520), Vector(0,0), boss)
					else
						local ultipride = Isaac.Spawn(46, 2, 0, Vector(280,500), Vector(0,0), boss)
						ultipride.MaxHitPoints = ultipride.MaxHitPoints * 0.8
						local baby = Isaac.Spawn(38, 2, 0, Vector(320,540), Vector(0,0), boss)
						baby.MaxHitPoints = 133
						baby.HitPoints = 133
						Isaac.Spawn(81, 0, 0, Vector(360,500), Vector(0,0), boss)
					end
				end
				if Isaac.CountBosses() <= 1 then
					boss.StateFrame = 0
				end
			else
				if not data.handattacking and boss.I2 == 0 then
					sprss:Play("Down"..data.i3, true)
					boss.State = 15
					boss.StateFrame = 0
				end
			end
		end
		if boss.I2 >= 1 then
			boss.ProjectileCooldown = boss.ProjectileCooldown - 1
			if #Isaac.FindByType(1000, Isaac.GetEntityVariantByName("Mega Satan 2's Head (Side)"), -1, true, true) == 0 and boss.ProjectileCooldown >= 250 then
				local HeadPos = boss.I2 % 2 == 0 and Vector(0, 400) or Vector(600, 700)
				local efthead = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Mega Satan 2's Head (Side)"), boss.I2 % 2, HeadPos, Vector(0,0), boss):ToEffect()
				efthead.Timeout = boss.ProjectileCooldown - 24
				efthead.LifeSpan = data.i3
			end
			if boss.ProjectileCooldown <= 0 then
				boss.I2 = 0
				data.handattacking = false
			end
		end
	elseif boss.State == 15 then
		if sprss:IsFinished("Down"..data.i3) then
			boss.State = 3
		end
	else
		boss.EntityCollisionClass = 4
	end

	for k, v in pairs(Isaac.FindByType(9, 4, -1, true, true)) do
		if v.SpawnerType == 275 and v.SpawnerVariant == 0 and v.FrameCount == 20 then
			v.Velocity = Vector(5.5*dirc,4)
		end
	end

  end
  end

----------------------------
--Add Boss Pattern:Ultra Greed
----------------------------
  function bpattern:Ultigreed(boss)

	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then

	local sprug = boss:GetSprite()
	local data = boss:GetData()
	local target = Game():GetPlayer(1)
	local dist = target.Position:Distance(boss.Position)
	local Entities = Isaac:GetRoomEntities()
	local rng = boss:GetDropRNG()
	local angle = (target.Position - boss.Position):GetAngleDegrees()

	if sprug:IsFinished("Appearing") then
		data.ChangedHP = false
	end

	if boss.State == 3 or boss.State == 4 then
		if boss.HitPoints <= boss.MaxHitPoints/2 and not data.Phase2 then
			sprug:Load("gfx/406.000_ultragreed_angry.anm2", true)
			sprug:Play("Shocked", true)
			boss.State = 15
		end
	end

	if data.Phase2 and boss.I2 < 3 then
		boss.I2 = boss.I2 + 1
	end

	if boss.State == 9 then
		if sprug:IsPlaying("SpinOnce2") then
			if sprug:GetFrame() == 15 then
				boss:PlaySound(252, 1, 0, false, 0.4)
				data.attackcount = data.attackcount - 1
				boss.Velocity = Vector.FromAngle(angle):Resized(12+(boss.I2 / 2))
				if not boss.FlipX then
					boss.FlipX = true
				else
					boss.FlipX = false
				end
			elseif sprug:GetFrame() >= 15 and sprug:GetFrame() <= 21 then
				local params = ProjectileParams()
				params.Scale = 1.5
				params.Variant = 7
				params.FallingAccelModifier = -0.15
				if boss.FlipX then
					for i=0, 30, 30 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle((60*(sprug:GetFrame()-15))-i):Resized(10), 0, params)
					end
				else
					for i=0, 30, 30 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle((-60*(sprug:GetFrame()-15))+i):Resized(10), 0, params)
					end
				end
			end

			if sprug:GetFrame() >= 14 and sprug:GetFrame() <= 19 and boss.EntityCollisionClass > 0 then
				for k, v in pairs(Entities) do
					if (v:ToPlayer() or v:IsVulnerableEnemy()) and v.Type ~= 406 then
						local dist3 = v.Position:Distance(boss.Position)

						if dist3 <= 110 + v.Size then
							v.Velocity = Vector.FromAngle(angle + (boss.FlipX and 50 or -50)):Resized((110 + v.Size - dist) / 5)
							v:TakeDamage(v:ToPlayer() and 2 or 40, 0, EntityRef(boss), 5)
						end
					end
				end
			end
		end

		if sprug:IsFinished("SpinOnce2") then
			if data.attackcount > 0 then
				sprug:Play("SpinOnce2", true)
			else
				boss.State = 3
				boss.FlipX = false
			end
		end
	elseif boss.State == 10 then
		if sprug:IsFinished("JumpReady") then
			sprug:Play("Jump", true)
		end
		if sprug:IsPlaying("Jump") then
			if sprug:GetFrame() == 1 then
				Game():ShakeScreen(3)
				boss:PlaySound(14, 1, 0, false, 1)
				data.attackcount = data.attackcount - 1
				boss.Velocity = Vector.FromAngle(angle):Resized(dist*0.2)
			end

			if sprug:WasEventTriggered("Stomp") and not data.Land then
				local Div = REPENTANCE and 255 or 1

				boss:PlaySound(48, 1.5, 0, false, 1)
				Game():BombDamage(boss.Position, 40, 40, false, boss, 0, 1<<2, true)
				Game():ShakeScreen(20)
				Game():SpawnParticles(boss.Position, 88, 10, 20, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
				local params = ProjectileParams()
				params.Variant = 7
				for i=1, 11+(boss.I2*0.5) do
					params.Scale = math.random(13,20)*0.1
					params.FallingSpeedModifier = -math.random(15,65)*0.1
					params.FallingAccelModifier = 0.3
					boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(5,15)), 0, params)
				end
				if boss.Position.X > target.Position.X then
					boss.FlipX = true
				else
					boss.FlipX = false
				end

				data.Land = true
			end
			if data.attackcount > 0 and sprug:GetFrame() >= 34 then
				sprug:Play("Jump", true)
				data.Land = false
			end
		end
		if sprug:IsFinished("Jump") then
			boss.State = 3
		end
	elseif boss.State == 11 then
		if sprug:IsPlaying("BlastStart") and sprug:GetFrame() == 5 then
			boss:PlaySound(424, 1, 0, false, 1)
		end

		if sprug:IsEventTriggered("Blast") then
			local CoinLaser = EntityLaser.ShootAngle(REPENTANCE and 6 or 1, boss.Position+Vector(0,5), 90, boss.StateFrame, Vector(0,-50), boss)
			CoinLaser.Size = 80
			CoinLaser:GetSprite():Load("gfx/007.006_giant coin laser.anm2", true)
			CoinLaser:GetSprite():Play(REPENTANCE and "LargeCoinLaser" or "LargeRedLaser", true)

			if not REPENTANCE then
				local sound = SFXManager()

				boss:PlaySound(bpattern.sounds.AngerScream, 1.2, 0, false, 0.8)
				sound:Stop(5)
				sound:Play(239, 1, 0, false, 1)
				sound:Play(48, 0.75, 0, false, 0.5)
			end

			Game():ShakeScreen(10)
		end

		if sprug:IsFinished("BlastStart") then
			sprug:Play("BlastLoop", true)
		elseif sprug:IsFinished("BlastEnd") then
			boss.State = 3
		end

		if sprug:IsPlaying("BlastLoop") then
			boss.StateFrame = boss.StateFrame - 1
			boss:AddVelocity(Vector(0,-3))
			if boss.StateFrame <= 0 then
				sprug:Play("BlastEnd", true)
			end
		end
	elseif boss.State == 15 then
		if sprug:IsPlaying("Shocked") and sprug:GetFrame() == 43 then
			boss:PlaySound(bpattern.sounds.AngerScream, 1, 0, false, 1)
			data.Phase2 = true
			boss.I1 = 0
			Game():ShakeScreen(35)
		end
		if sprug:IsFinished("Shocked") then
			sprug:Play("Wrath", true)
			data.Stomped = false
			data.Stomped2 = false
		end
		if sprug:IsPlaying("Wrath") then
			if sprug:WasEventTriggered("Stomp2") and ((sprug:GetFrame() < 9 and not data.Stomped) or (sprug:GetFrame() >= 9 and not data.Stomped2)) then
				boss.I1 = boss.I1 + 1
				boss:PlaySound(48, 1.2, 0, false, 1)
				Game():ShakeScreen(15)
				local params = ProjectileParams()
				params.Variant = 7
				for i=0, math.random(1,3) do
					if i ~= 0 then
						if math.random(1,3) == 1 then
							params.Scale = 1.5
							params.BulletFlags = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
							params.ChangeTimeout = 10
							params.ChangeFlags = 2
						else
							params.Scale = 1
							params.BulletFlags = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
							params.ChangeTimeout = 10
							params.ChangeFlags = 0
						end
						params.FallingSpeedModifier = 0
						params.HeightModifier = -300
						params.FallingAccelModifier = 0.6
						boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(math.random(-10,10)*0.1,math.random(-10,10)*0.1), 0, params)
					end
				end

				if sprug:GetFrame() < 9 then
					data.Stomped = true
				else
					data.Stomped2 = true
				end
			end

			if sprug:GetFrame() >= 8 and boss.I1 < 17 then
				data.Stomped = false
				sprug:Play("Wrath", true)
			end
		end

		if sprug:IsFinished("Wrath") then
			sprug:Play("Idle", true)
			boss.StateFrame = 150
		end

		if sprug:IsPlaying("Idle") then
			boss.StateFrame = boss.StateFrame - 1

			if sprug:GetFrame() == 18 then
				boss:PlaySound(14, 1, 0, false, 0.7)
			end

			if boss.StateFrame <= 0 then
				boss.State = 3
			end
		end
		if sprug:IsFinished("JumpReady") then
			sprug:Play("LowJump", true)
		end
	elseif boss.State == 19 then
		if sprug:IsPlaying("SmashLeft") or sprug:IsPlaying("SmashRight") then
			if sprug:WasEventTriggered("Smash") and not data.SpawnedCoins then
				boss:PlaySound(48, 1.4, 0, false, 0.75)
				Game():ShakeScreen(20)

				if not HMBPENTS then
					data.CoinProjSpawnDelay = 20
					data.CoinProjSpawnPos = {}
				end

				for i=0, math.random(2, 4) * (HMBPENTS and 1 or 2) do
					if HMBPENTS then
						Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Ultra Greed Coin (Burst)"), 0, Isaac.GetRandomPosition(0), Vector(0,0), boss)
					else
						data.CoinProjSpawnPos[i] = Isaac.GetRandomPosition(0)
						Isaac.Spawn(1000, 15, 0, data.CoinProjSpawnPos[i], Vector(0,0), boss)
					end
				end

				data.SpawnedCoins = true
			end
		end

		if sprug:IsFinished("SmashLeft") or sprug:IsFinished("SmashRight") then
			data.attackcount = data.attackcount - 1

			if data.attackcount > 0 then
				if sprug:IsFinished("SmashLeft") then
					sprug:Play("SmashRight", true)
				elseif sprug:IsFinished("SmashRight") then
					sprug:Play("SmashLeft", true)
				end
			else
				sprug:Play("Idle", true)
				boss.State = 3
			end

			data.SpawnedCoins = false
		end
	elseif boss.State == 26 then
		if sprug:IsFinished("JumpReady") then
			sprug:Play("LowJump", true)
		end
		if sprug:WasEventTriggered("jump") and not data.Jumped then
			boss:PlaySound(14, 1, 0, false, 1)
			Game():ShakeScreen(10)
			boss.EntityCollisionClass = 0

			if sprug:IsPlaying("JumpUp") then
				boss.Velocity = Vector.FromAngle((target.Position-boss.Position):GetAngleDegrees()):Resized(target.Position:Distance(boss.Position)*0.06)
			elseif sprug:IsPlaying("LowJump") then
				boss.Velocity = Vector(0,-20)
			end

			data.Jumped = true
		end
		if sprug:IsFinished("JumpUp") then
			sprug:Play("JumpDown", true)
		end
		if sprug:WasEventTriggered("Stomp") and not data.Land then
			boss.EntityCollisionClass = 4

			if sprug:IsPlaying("JumpDown") then
				boss:PlaySound(138, 1, 0, false, 1)
				Game():BombDamage(boss.Position, 40, 40, false, boss, 0, 1<<2, true)
				local shockwave2 = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss):ToEffect()
				shockwave2.Parent = boss
				shockwave2.MaxRadius = 200
				shockwave2.Timeout = 36
				Game():ShakeScreen(20)
			elseif sprug:IsPlaying("LowJump") then
				boss:PlaySound(48, 1, 0, false, 1)
				Game():BombDamage(boss.Position, 10, 40, false, boss, 0, 1<<2, true)
				Game():ShakeScreen(10)
			end

			data.Land = true
		end

		if sprug:IsFinished("JumpDown") then
			boss.State = 3
		end

		if sprug:IsFinished("LowJump") then
			if boss.I1 == 1 then
				if math.random(1,2) == 1 then
					sprug:Play("SmashLeft", true)
				else
					sprug:Play("SmashRight", true)
				end
				boss.State = 19
				data.attackcount = math.random(4,6)+(boss.I2/3)
				boss:PlaySound(433, 1, 0, false, 1)
			elseif boss.I1 == 2 then
				boss.State = 11
				sprug:Play("BlastStart", true)
				boss.StateFrame = math.random(120,135)
			end
		end
	end

	if boss.State >= 9 and boss.EntityCollisionClass ~= 0 then
		if boss.State == 11 or boss.State == 19 then
			boss.Velocity = boss.Velocity * 0.1
		else
			boss.Velocity = boss.Velocity * 0.7
		end
	end

	if (sprug:IsFinished("BlastEnd") or sprug:IsFinished("SpinOnce2")
	or sprug:IsFinished("Jump")) and boss.State < 3 then
		sprug:Play("Idle", true)
		boss.State = 3
	end

	if sprug:IsEventTriggered("Jump") then
		boss.EntityCollisionClass = 0
	end
	if sprug:IsEventTriggered("Stomp") then
		boss.EntityCollisionClass = 4
	end

	if data.CoinProjSpawnDelay then
		if data.CoinProjSpawnDelay > 0 then
			data.CoinProjSpawnDelay = data.CoinProjSpawnDelay - 1
		else
			boss:PlaySound(138, 1, 0, false, 0.8)

			if data.CoinProjSpawnPos then
				for n, i in pairs(data.CoinProjSpawnPos) do
					Isaac.Spawn(1000, 97, 0, i, Vector(0,0), boss)

					local params = ProjectileParams()
					params.Variant = 7
					params.Scale = 1.5
					params.FallingSpeedModifier = -5
					params.FallingAccelModifier = 0.4
					params.BulletFlags = ProjectileFlags.EXPLODE
					boss:FireProjectiles(i, Vector(0,0), 0, params)
				end
			end

			data.CoinProjSpawnDelay = nil
		end
	end

	if data.Phase2 then
		if boss.State == 8 and sprug:IsPlaying("Tantrum") and (sprug:IsEventTriggered("Stomp1") or sprug:IsEventTriggered("Stomp2")) then
			local params = ProjectileParams()
			params.Variant = 7
			for i=0, math.random(0,2) do
				params.Scale = 1.5
				params.FallingSpeedModifier = 0
				params.HeightModifier = -300
				params.FallingAccelModifier = 0.6
				params.BulletFlags = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
				params.ChangeTimeout = 10
				params.ChangeFlags = 0
				boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(math.random(-10,10)*0.1,math.random(-10,10)*0.1), 0, params)
			end
		end

		if sprug:IsPlaying("SpinStart") and sprug:GetFrame() == 1 and math.random(1,3) == 1 then
			boss.State = 9
			sprug:Play("SpinOnce2", true)
			data.attackcount = math.random(3, 5) + math.floor(boss.I2 / 5)
		end

		if ((sprug:IsPlaying("ShootUp") or sprug:IsPlaying("ShootDown") or sprug:IsPlaying("ShootLeft") or sprug:IsPlaying("ShootRight"))
		and sprug:GetFrame() == 1) or (boss.State >= 3 and boss.State <= 4 and boss.FrameCount % 35 == 0) then
			if math.random(1,8) == 1 then
				boss.State = 10
				sprug:Play("JumpReady", true)
				data.attackcount = math.random(2, 4) + math.floor(boss.I2 / 5)
				data.Land = false
			elseif math.random(1,8) == 2 then
				boss.State = 26
				sprug:Play("JumpUp", true)
				data.attackcount = math.random(1, math.ceil(boss.I2 / 7))
				data.Jumped = false
				data.Land = false
			elseif math.random(1,8) == 3 and HMBPENTS then
				if math.random(1, 2) == 1 then
					sprug:Play("SmashLeft", true)
				else
					sprug:Play("SmashRight", true)
				end

				boss.State = 19
				data.attackcount = math.random(2, 4) + math.floor(boss.I2 / 5)
				boss:PlaySound(433, 1, 0, false, 1)
			elseif math.random(1,8) == 4 then
				if boss.Position.Y >= 600 then
					boss.I1 = 2
					sprug:Play("JumpReady", true)
					boss.State = 26
					data.Jumped = false
					data.Land = false
				else
					boss.State = 11
					sprug:Play("BlastStart", true)
					boss.StateFrame = math.random(120, 135)
				end
			end
		end
	end

  end
  end

----------------------------
--Add Boss Pattern:Ultra Greedier
----------------------------
  function bpattern:Ultigreedier(boss)

	if boss.Variant == 1 and denpnapi then

	local sprug2 = boss:GetSprite()
	local data = boss:GetData()
	local target = Game():GetPlayer(1)
	local dist = target.Position:Distance(boss.Position)
	local Entities = Isaac:GetRoomEntities()
	local rng = boss:GetDropRNG()
	local angle = (target.Position - boss.Position):GetAngleDegrees()
	local Room = Game():GetRoom()
	boss:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)

	if sprug2:IsFinished("BreakFreeShort") or sprug2:IsFinished("BreakFreeLong") then
		data.ChangedHP = false
	end

	if boss.State == 1 then
		data.moveX = 0
		data.Sstomp = false
		data.tripgauge = 0
		data.firstcollide = false
	end

	if boss.HitPoints / boss.MaxHitPoints <= 0.5 and not data.TwoPhase then
		sprug2:Play("Hurt", true)
		boss.State = 15
		data.TwoPhase = true
		boss:PlaySound(427, 1, 0, false, 2)
		boss.StateFrame = 35
		Game():SpawnParticles(boss.Position, 98, 20, 10, Color(1.1,1,1,1,0,0,0), -50)
	end

	if data.TwoPhase and (boss.State == 3 or boss.State == 4) then
		if boss.FrameCount % 70 <= 7 and math.random(1,3) == 1 then
			data.smash = false
			if math.random(1,6) > 3 then
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
			elseif math.random(1,6) > 1 then
				sprug2:Play("SpinStart", true)
				boss.State = 11
				boss.StateFrame = math.random(160, 240)
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
		if math.random(1,3) == 1 and dist <= 200 and boss.FrameCount % 20 == 0 then
			sprug2:Play("SpinOnce", true)
			boss.State = 11
			boss:PlaySound(433, 1, 0, false, 1)
		elseif math.random(1,3) == 2 and boss.Position.Y <= 420
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

				if math.random(1,5) < 3 then
					params.Scale = 1.5
					params.BulletFlags = 2
					params.FallingSpeedModifier = -math.random(6,16)*0.1
				else
					params.Scale = math.random(7,12)*0.1
					params.FallingSpeedModifier = -math.random(10,25)*0.1
				end

				boss:FireProjectiles(boss.Position, Vector.FromAngle(-30+(sprug2:GetFrame()-1)*-60):Resized(math.random(35,70)*0.1), 0, params)
			end

			if boss.ProjectileCooldown <= 0 then
				local AngleDiff = ((angle - boss.Velocity:GetAngleDegrees()) % 360) - math.floor(((angle - boss.Velocity:GetAngleDegrees()) % 360) / 180) * 360

				boss:AddVelocity(Vector.FromAngle(boss.Velocity:GetAngleDegrees() + AngleDiff / 3):Resized(1.3))
			end

			if boss:CollidesWithGrid() and boss.Velocity:Length() >= 3 then
				Game():SpawnParticles(boss.Position, 95, 30, 10, Color(1.1,1,1,1,0,0,0), -50)
				boss.ProjectileCooldown = 7
				boss:PlaySound(48, 1, 0, false, 1)
				Game():ShakeScreen(20)
				boss.Velocity = boss.Velocity * 2
			end
		end

		sprug2.PlaybackSpeed = 1
	elseif boss.State == 21 then
		if sprug2:IsPlaying("Punch") then
			if sprug2:GetFrame() == 22 then
				Game():ShakeScreen(10)
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
				Game():ShakeScreen(10)
				Game():SpawnParticles(boss.Position, 95, 20, 10, Color(1.1,1,1,1,0,0,0), -50)
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
					Game():BombDamage(boss.Position+Vector((data.moveX*130),0), 30, 20, true, boss, 0, 1<<2, false)
					Game():SpawnParticles(boss.Position, 95, 3, 10, Color(1.1,1,1,1,0,0,0), -3)
					local params = ProjectileParams()
					params.FallingSpeedModifier = -math.random(45,60) * 0.1
					params.FallingAccelModifier = 0.3
					params.Scale = math.random(10,13) * 0.1
					params.Variant = 7
					boss:FireProjectiles(boss.Position, Vector(-data.moveX*math.random(3,5),math.random(-5,5)), 0, params)
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
						Game():ShakeScreen(20)
						for i=0, math.random(9,17) do
							local params = ProjectileParams()
							params.FallingSpeedModifier = -math.random(75,125) * 0.1
							params.FallingAccelModifier = 0.45
							params.HeightModifier = -20
							params.Scale = math.random(10,15) * 0.1
							params.Variant = 7
							boss:FireProjectiles(boss.Position+Vector(115*data.moveX,0),
							Vector.FromAngle(math.random(-88,88)-90*(data.moveX+1)):Resized(math.random(5,15)), 0, params)
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

			Game():SpawnParticles(boss.Position, 88, 1, 8, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), 0)
			local params = ProjectileParams()
			params.HeightModifier = math.random(-70,5)
			params.FallingAccelModifier = -0.05
			params.Scale = math.random(8,12) * 0.1
			params.Variant = 7
			boss:FireProjectiles(boss.Position+Vector(math.random(-85,85),0), Vector.FromAngle(math.random(260,280)):Resized(math.random(0,20)*0.1), 0, params)
			if boss:CollidesWithGrid() then
				boss:PlaySound(52, 1, 0, false, 0.85)
				Game():ShakeScreen(20)
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
				Game():SpawnParticles(boss.Position, 88, 1, 13, Color(1,1,1,1,135,126,90), 0)
				boss:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(20)
				local params = ProjectileParams()
				params.Variant = 7
				for i=0, math.random(6,10) do
					params.FallingSpeedModifier = -math.random(35,65) * 0.1
					params.FallingAccelModifier = 0.3
					params.Scale = math.random(13,20) * 0.1
					boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(5,13)), 0, params)
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
			Game():ShakeScreen(10)
			boss.EntityCollisionClass = 0
			boss.TargetPosition = target.Position
			Game():SpawnParticles(boss.Position, 95, 20, 10, Color(1.1,1,1,1,0,0,0), -30)
		end
		if sprug2:IsFinished("JumpUp") or sprug2:IsFinished("JumpUp2") then
			boss.Velocity = Vector.FromAngle((boss.TargetPosition - boss.Position):GetAngleDegrees()):Resized(10)
			Game():SpawnParticles(boss.Position, 95, 1, 1, Color(1.1,1,1,1,0,0,0), -500)
			if math.random(1,5) <= 2 then
				local params = ProjectileParams()
				params.HeightModifier = -500
				params.FallingAccelModifier = 1.2
				params.Scale = math.random(10,15) * 0.1
				params.Variant = 7
				params.BulletFlags = 2
				boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(5,20)*0.1), 0, params)
			end
			if boss.TargetPosition:Distance(boss.Position) <= 50 then
				sprug2:Play("JumpDown2", true)
			end
		end
		if sprug2:IsEventTriggered("Stomp") then
			boss:PlaySound(138, 1, 0, false, 1)
			Game():SpawnParticles(boss.Position, 95, 30, 15, Color(1.1,1,1,1,0,0,0), -5)
			if sprug2:IsPlaying("JumpDown2") then
				boss:PlaySound(52, 1, 0, false, 1)
				if math.random(1,2) == 1 then
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
			Game():ShakeScreen(20)
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
				Game():ShakeScreen(20)
				Game():BombDamage(boss.Position+Vector(0,50), 40, 80, true, boss, 0, 1<<2, true)
				local explode = Isaac.Spawn(1000, 1, 0, boss.Position+Vector(0,50), Vector(0,0), boss)
				explode:SetColor(Color(2,2,1,1,0,0,0), 99999, 0, false, false)
				explode:GetSprite().Scale = Vector(2,2)
				if HMBPENTS then
					local GWaveRadi = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Golden Wave (Radial)"), 0, boss.Position+Vector(0,50), Vector(0,0), boss)
					GWaveRadi.Parent = boss
					GWaveRadi:ToEffect().MaxRadius = 700
					GWaveRadi:ToEffect().Timeout = 30
				else
					for i=0, math.random(6,10) do
						local params = ProjectileParams()
						params.FallingSpeedModifier = -math.random(35,65) * 0.1
						params.FallingAccelModifier = 0.3
						params.Scale = math.random(13,20) * 0.1
						params.Variant = 7
						params.BulletFlags = 2
						boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(5, 10)), 0, params)
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
		Game():SpawnParticles(boss.Position, 95, 30, 10, Color(1.1,1,1,1,0,0,0), -50)
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

bpattern:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, boss, collider, low)
	local sprite = boss:GetSprite()

	if boss.Variant ~= 1 or not (collider:ToPlayer() or collider:IsVulnerableEnemy()) or not sprite:IsPlaying("SpinConstant") then return end

	collider.Velocity = Vector.FromAngle((collider.Position - boss.Position):GetAngleDegrees() + (boss.FlipX and 50 or -50)):Resized(100 / collider.Mass)

	if collider.Type ~= 406 then
		collider:TakeDamage(collider:ToPlayer() and 2 or 40, 0, EntityRef(boss), 5)
	end
end, 406)

----------------------------
--Ultra Greed Door
----------------------------
  function bpattern:UtGreedDoor(door)

	if door.Type == 294 then

	local sprgdr = door:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local data = door:GetData()
	for k, v in pairs(Entities) do
		if v.Type == 406 and v.Variant == 1 then
			local greeddist = v.Position:Distance(door.Position)
			if v:GetSprite():IsEventTriggered("Call") then
				data.greedieropen = true
			end
			if door.State == 3 and data.greedieropen then
				door.State = 12
				door.StateFrame = 180
				for i=-15, 15, 30 do
					local bling = Isaac.Spawn(1000, 103, 0, door.Position + Vector.FromAngle(sprgdr.Rotation+90):Resized(1), Vector(0,0), door)
					bling.PositionOffset = Vector.FromAngle(sprgdr.Rotation-90+i):Resized(32)
					bling:SetColor(Color(2,0.5,0.5,1,0,0,0), 99999, 0, false, false)
					bling:GetSprite():Play("Bling3", true)
				end
			end
			if door.State == 12 then
				if door.StateFrame > 0 then
					door.StateFrame = door.StateFrame - 1
				end
				if sprgdr:IsPlaying("Closed") and door.StateFrame <= 150 then
					sprgdr:Play("Open", true)
				end
				if sprgdr:IsFinished("Open") then
					sprgdr:Play("Opened", true)
					door.State = 14
				end
				if sprgdr:GetFrame() == 5 then
					door:PlaySound(36, 1, 0, false, 1)
				end
			elseif door.State == 14 then
				if door.StateFrame > 0 then
					door.StateFrame = door.StateFrame - 1
				else
					data.greedieropen = false
				end
				if sprgdr:IsPlaying("Opened") then
					if not data.greedieropen then
						sprgdr:Play("Close", true)
					end
				end
			end
		end
    end

	if door.State == 14 then
		if sprgdr:IsPlaying("Opened") then
			if denpnapi then
				if door.FrameCount % 55 == 0 then
					if math.random(1,6) ~= 1 then
						Isaac.Spawn(554, Isaac.GetEntityVariantByName("Greedier Gaper"), 0, door.Position, Vector(0,0), door)
					else
						Isaac.Spawn(554, Isaac.GetEntityVariantByName("Greedier Fatty"), 0, door.Position, Vector(0,0), door)
					end
				end
			else
				if door.FrameCount % 7 == 0 then
					Isaac.Spawn(299, 0, 0, door.Position, Vector(0,0), door)
				end
			end
		else
			door.State = 3
		end
	end

  end
  end

----------------------------
--Add Boss Pattern:Hush
----------------------------
  function bpattern:Hush(boss)
  if boss.Variant == 0 and Game().Difficulty % 2 == 1 then

  	local sprhs = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local angle = (target.Position - boss.Position):GetAngleDegrees()
	local Room = Game():GetRoom()

	if not data.NumSpit then
		data.NumSpit = 0
	end

	if boss.State == 150 then
		if sprhs:IsPlaying("DissapearLong") then
			if sprhs:GetFrame() >= 8 then
				if sprhs:GetFrame() == 11 then
					boss:PlaySound(314, 1, 0, false, 1)
					Game():ShakeScreen(10)
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
			Game():ShakeScreen(15)
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
				local bvessel = Game():Spawn(608, 0, Vector(Room:GetCenterPos().X*0.5,Room:GetCenterPos().Y), Vector(0,0), boss, 0, 1)
				bvessel.SpawnerEntity = boss
			elseif boss.StateFrame == 53 then
				local bvessel2 = Game():Spawn(608, 0, Vector(Room:GetCenterPos().X*1.5,Room:GetCenterPos().Y), Vector(0,0), boss, 1, 2)
				bvessel2.SpawnerEntity = boss
			elseif boss.StateFrame == 60 then
				local bvessel3 = Game():Spawn(608, 0, Vector(Room:GetCenterPos().X,Room:GetCenterPos().Y*0.73), Vector(0,0), boss, 2, 3)
				bvessel3.SpawnerEntity = boss
			elseif boss.StateFrame == 67 then
				local bvessel4 = Game():Spawn(608, 0, Vector(Room:GetCenterPos().X,Room:GetCenterPos().Y*1.27), Vector(0,0), boss, 3, 4)
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
				local Eye = ProjectileParams()
				Eye.FallingAccelModifier = -0.165
				Eye.FallingSpeedModifier = 0
				Eye.HeightModifier = -6
				Eye.BulletFlags = ProjectileFlags.CONTINUUM
				Eye.Scale = 1.5
				Eye.Color = Color(0.3,0,0.5,1,0,0,0)
				Eye.Variant = REPENTANCE and 6 or 0
				boss:FireProjectiles(bltpos2, Vector.FromAngle(direction - (35 - boss.FrameCount % 50) * 2):Resized(7), 0, Eye)
				boss:FireProjectiles(bltpos3, Vector.FromAngle(direction + (35 - boss.FrameCount % 50) * 2):Resized(7), 0, Eye)
			end
			if sprhs:IsPlaying("AttackLoop"..data.FAW.."2")
			and boss.ProjectileCooldown <= 139 then
				local Mouth = ProjectileParams()
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
				local eye = ProjectileParams()
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

				local eye1 = ProjectileParams()
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

				local eye2 = ProjectileParams()
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
			local mouth = ProjectileParams()
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

----------------------------
--Add Boss Pattern:Delirium
----------------------------
function bpattern:Delirium(npc)

	boss = npc:ToNPC()
	local sprdlr = boss:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local player = Game():GetPlayer(1)
	local data = boss:GetData()
	local rng = boss:GetDropRNG()
	local Room = Game():GetRoom()
	boss.SplatColor = Color(1,1,1,1,255,255,255)

	if Game().Difficulty % 2 == 1 then

	if boss.State == 0 then
		sound:Stop(bpattern.sounds.TVnoise)
		data.ChangedHP = true
		DlrHasExist = true
		boss.EntityCollisionClass = 4
		DlrCopiedPlrForm = {}
		for k, v in pairs(Isaac:GetRoomEntities()) do
			if v.Type == 1 then
				local p = v:ToPlayer()
				for i=1, 13 do
					if p:HasPlayerForm(i) then
						DlrCopiedPlrForm[i] = true
					end
				end
			end
		end
	end

	if Room:GetFrameCount() == 0 then
		boss.MaxHitPoints = boss.MaxHitPoints*0.9
		boss.HitPoints = boss.HitPoints*0.9
	end

	if DlrCopiedPlrForm[11] and not AdultForm then
		--DlrHPIncrease = DlrHPIncrease * 1.1
		AdultForm = true
	end
	if DlrCopiedPlrForm[13] and boss.FrameCount == 1 then
		local wave = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss)
		wave.Parent = boss
		wave:ToEffect().Timeout = 10
		wave:ToEffect().MaxRadius = 60
	end
	if Room:GetFrameCount() % 8 == 0 then
		if DlrCopiedPlrForm[4] then
			local creepG = Isaac.Spawn(1000, 23, 0, boss.Position, Vector(0,0), boss)
			if boss.Size*0.075 >= 3 then
				creepG.SpriteScale = Vector(3,3)
			else
				creepG.SpriteScale = Vector(boss.Size*0.075,boss.Size*0.075)
			end
			creepG:ToEffect().Timeout = 50
		end
	end

	if denpnapi and HMBPENTS then

	if DPhase == 3 and #Isaac.FindByType(551, -1, -1, true, true) == 0 then
		Isaac.Spawn(551, 0, 0, boss.Position, Vector(0,0), boss)
	end

	if (sprdlr:GetDefaultAnimation() == "Delirium" and (Room:GetFrameCount() % 36 == 3) or sprdlr:GetDefaultAnimation() ~= "Delirium" and (Room:GetFrameCount() % 60 == 3))
	and DPhase <= 2 and boss.State ~= 0 and HMBPENTS then
		local params = HMBPEnts.ProjParams()
		params.FallingAccelModifier = -0.09
		params.Scale = 2.3
		params.HMBPBulletFlags = HMBPEnts.ProjFlags.GRAVITY_VERT
		HMBPEnts.FireProjectile(boss, Isaac.GetEntityVariantByName("Delirium Projectile"), boss.Position, Vector(4 - (math.random(0, 1) * 8), 0), params)
	end

	if Room:GetFrameCount() % 50 == 0 and boss.State > 0 and math.random(1,2) == 1 and DlrCopiedPlrForm[12] and #Isaac.FindByType(85, -1, -1, true, true) <= 10 then
		boss:PlaySound(181, 1, 0, false, 1)
		EntityNPC.ThrowSpider(boss.Position, boss, boss.Position + Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(80,200)), false, -45)
	end
	if Room:GetFrameCount() % 75 == 0 and math.random(0,6) == 1 and DlrCopiedPlrForm[6] and boss.State > 0 then
		boss:PlaySound(252, 1, 0, false, 1)
		Isaac.Spawn(70, 70, 0, player.Position, Vector(0,0), boss)
	end

	if DlrCopiedPlrForm[7] and #Isaac.FindByType(546, -1, -1, true, true) <= 0 then
		for i=0, 1 do
			local triplet = Isaac.Spawn(546, 0, i, boss.Position, Vector(0,0), boss)
			triplet.Parent = boss
			triplet:GetData().prt = boss
		end
	end

	if DlrCopiedPlrForm[3] and Room:GetFrameCount() % 120 == 0 and boss.EntityCollisionClass ~= 0 then
		local lightwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, boss.Position, Vector(0,0), boss)
		lightwave.Parent = boss
		lightwave:ToEffect().Rotation = (player.Position - boss.Position):GetAngleDegrees()
	end

	if DlrCopiedPlrForm[1] and #Isaac.FindByType(550, -1, -1, true, true) <= 1 then
		for i=0, 1 do
			if #Isaac.FindByType(550, -1, i, true, true) < 1 then
				local dfly = Isaac.Spawn(550, 0, i, boss.Position, Vector(0,0), boss)
				dfly.Parent = boss
				dfly:GetData().prt = boss
			end
		end
	end

	end

	if sprdlr:GetDefaultAnimation() == "Delirium" and denpnapi and HMBPENTS then
		if data.AtkCooldown then
			if data.AtkCooldown > 0 then
				data.AtkCooldown = data.AtkCooldown - 1
			end
		else
			if boss.SpawnerType == 412 then
				data.AtkCooldown = 50
			else
				data.AtkCooldown = 25
			end
		end
		if boss.HitPoints > 1 then
			if (boss.State ~= 3 and not (boss.State >= 8 and boss.State <= 14)
			and boss.State ~= 25 and boss.State ~= 33) or boss.FrameCount <= 10 or Room:GetFrameCount() <= 100 then
				boss.State = 3
			end
		end
		if DPhase == 1 and Room:GetFrameCount() % 300 == 0 and boss.State <= 4 and #Isaac.FindByType(554, Isaac.GetEntityVariantByName("Memories III"), 1, true, true) == 0
		and boss.State ~= 0 and boss.HitPoints > 1 then
			boss.State = 10
		end
		if sprdlr:IsPlaying("Blink") and data.AtkCooldown < 1 and boss.State < 4 then
			if sprdlr:GetFrame() == 1 then
				if math.random(0,22) >= (boss.HitPoints/boss.MaxHitPoints) * 9
				and boss.State ~= 33 then
					if math.random(1,5) == 1 then
						boss.State = 8
					elseif math.random(1,5) == 2 then
						if DPhase <= 2 then
							boss.State = 12
						end
					elseif math.random(1,5) == 3 then
						if DPhase == 4 and boss.Position.Y <= 700
						and Room:GetAliveEnemiesCount() <= 5 then
							boss.State = math.random(13,14)
						end
					elseif math.random(1,5) == 4 then
						if DPhase <= 4 and boss.Position.Y <= 700
						and Room:GetAliveEnemiesCount() <= 5 then
							boss.State = math.random(13,14)
						end
					else
						if math.random(1,2) == 1 then
							if DlrCopiedPlrForm[13] then
								boss.State = 33
								data.stompcount = 0
							end
						else
							if DlrCopiedPlrForm[8] and #Isaac.FindByType(666, 412, -1, true, true) < 4 then
								boss.State = 11
							end
						end
					end
					boss.StateFrame = 0
				end
			elseif sprdlr:GetFrame() == 5 then
				if boss.FrameCount % 2 == 0 and DPhase <= 3 and boss.HitPoints > 1 and HMBPENTS then
					local params = HMBPEnts.ProjParams()
					params.FallingAccelModifier = -0.06
					params.Scale = 2.3

					if math.random(1,2) == 1 then
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.CURVE2
					else
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.TURN_RIGHTANGLE
					end

					if DlrCopiedPlrForm[10] and math.random(1,2) == 1 then
						local ShootAngle = rng:RandomInt(3) * 90

						for i=-10, 10, 20 do
							HMBPEnts.FireProjectile(boss, Isaac.GetEntityVariantByName("Delirium Projectile"), boss.Position, Vector.FromAngle(i + ShootAngle):Resized(4), params)
						end
					else
						HMBPEnts.FireProjectile(boss, Isaac.GetEntityVariantByName("Delirium Projectile"), boss.Position, Vector.FromAngle(rng:RandomInt(3) * 90):Resized(4), params)
					end
				end

				if boss.State == 33 then
					boss:PlaySound(48, 1, 0, false, 1)
					Game():SpawnParticles(boss.Position, 88, 10, 16, Color(1,1,1,1,135,126,90), -4)
				end
			end
		end

		if boss.State > 3 then
			boss.StateFrame = boss.StateFrame + 1
		else
			boss.StateFrame = 0
		end

		if sprdlr:IsPlaying("Hurt") and boss.State ~= 25 then
			boss.State = 25
			boss.StateFrame = 1
		end

		if boss.StateFrame >= 30 and boss.StateFrame <= 60 then
			if boss.State == 8 and boss.StateFrame % 5 == 0 then
				local RGBO = REPENTANCE and 1 or 255

				data.angle = rng:RandomInt(359)
				boss:PlaySound(77, 0.7, 0, false, 1)

				local expl = Isaac.Spawn(1000, 2, 2, boss.Position+Vector.FromAngle(data.angle):Resized(70), Vector(0,0), boss)
				expl.Color = Color(1.1, 1.05, 1, 1, RGBO, RGBO, RGBO)

				local hand = Isaac.Spawn(545, 0, 0, boss.Position+Vector.FromAngle(data.angle):Resized(70), Vector(0,0), boss)
				hand:GetSprite().Rotation = data.angle
			elseif boss.State == 12 and boss.StateFrame % 12 == 0 then
				boss:PlaySound(265, 1, 0, false, 1)
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Deliring"), math.random(0,2), boss.Position + Vector.FromAngle(rng:RandomInt(359)):Resized(70), Vector(0,0), boss)
			end
		end

		if boss.State == 8 or boss.State == 12 then
			if not sprdlr:IsPlaying("FallDown") and not sprdlr:IsFinished("FallDown") then
				sprdlr:Play("FallDown", true)
			end
			if sprdlr:IsFinished("FallDown") then
				sprdlr:Play("Idle", true)
				boss.State = 3
			end
			if sprdlr:GetFrame() == 15 then
				boss:PlaySound(118, 1, 0, false, 1)
			elseif sprdlr:GetFrame() == 30 then
				boss:PlaySound(72, 1.5, 0, false, 0.5)
			end
		elseif boss.State == 9 then
			if not sprdlr:IsPlaying("Stomp") and not sprdlr:IsFinished("Stomp") then
				sprdlr:Play("Stomp", true)
			end
			if sprdlr:GetFrame() == 7 then
				boss:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(10)
				for i=0, 270, 90 do
					local cwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss)
					cwave.Parent = boss
					cwave:ToEffect().Rotation = i
				end
			end
			if sprdlr:IsFinished("Stomp") then
				sprdlr:Play("Idle", true)
				boss.State = 3
			end
		elseif boss.State == 10 then
			if not sprdlr:IsPlaying("Launch") and not sprdlr:IsFinished("Launch") then
				sprdlr:Play("Launch", true)
			end
			if sprdlr:GetFrame() == 5 then
				boss:PlaySound(72, 1.5, 0, false, 0.5)
			elseif sprdlr:GetFrame() == 20 then
				boss:PlaySound(265, 1, 0, false, 1)
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Memories III"), 1, boss.Position, Vector(0,0), boss)
				for i=0, 3 do
					Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Escape Trapdoor"), 0, Vector(120+(rng:RandomInt(11)*80),200+(rng:RandomInt(5)*80)), Vector(0,0), boss)
				end
			end
			if sprdlr:IsFinished("Launch") then
				sprdlr:Play("Idle", true)
				boss.State = 3
			end
		elseif boss.State == 11 then
			if not sprdlr:IsPlaying("Summon Heart") and not sprdlr:IsFinished("Summon Heart") then
				sprdlr:Play("Summon Heart", true)
			end

			if sprdlr:GetFrame() == 12 then
				local RGBO = REPENTANCE and 1 or 255

				data.angle = rng:RandomInt(359)
				boss:PlaySound(77, 0.7, 0, false, 1)
				local expl = Isaac.Spawn(1000, 2, 2, boss.Position+Vector.FromAngle(data.angle):Resized(70), Vector(0,0), boss)
				expl.Color = Color(1.1, 1.05, 1, 1, RGBO, RGBO, RGBO)

				local sinheart = Isaac.Spawn(666, 412, 0, boss.Position+Vector.FromAngle(data.angle):Resized(70), Vector.FromAngle(data.angle):Resized(10), boss)
				sinheart.Parent = boss
			end
			if sprdlr:IsFinished("Summon Heart") then
				sprdlr:Play("Idle", true)
				boss.State = 3
			end
		elseif boss.State == 25 then
			if sprdlr:IsPlaying("Hurt") and sprdlr:GetFrame() == 1 then
				boss:BloodExplode()
				Game():ShakeScreen(20)
			end
			if sprdlr:IsFinished("Hurt") then
				boss.StateFrame = 1
				if DPhase == 4 then
					boss.State = math.random(13,14)
				elseif DPhase == 1 then
					boss.State = 10
				else
					if data.DlrForm then
						sprdlr:Load(data.DlrForm, true)
						data.DlrForm = nil
						Isaac.Spawn(1000, 15, 3, boss.Position+Vector(0,1), Vector(0,0), boss)
					else
						sprdlr:Play("Idle", true)
						boss.State = 3
					end
				end
			end
		elseif boss.State == 33 then
			if not sprdlr:IsPlaying("Blink") then
				sprdlr:Play("Blink", true)
				data.stompcount = data.stompcount + 1
				boss:PlaySound(48, 0.75, 0, false, 1)
			end
			if data.stompcount > 3 then
				boss.State = 9
				boss.StateFrame = 1
			end
		end
		if boss.State == 13 or boss.State == 14 then
			if boss.StateFrame == 1 then
				sprdlr:Play("TVMorph", true)
			end
			if sprdlr:IsPlaying("TVMorph") and sprdlr:GetFrame() == 15 then
				boss:PlaySound(72, 1.5, 0, false, 0.5)
			end
			if sprdlr:IsFinished("TVMorph") then
				sprdlr:Play("Television", true)
				boss:PlaySound(bpattern.sounds.TVnoise, 2, 0, false, 1)
			end
			if boss.StateFrame >= 41 and sprdlr:IsPlaying("Television") then
				if boss.State == 14 then
					sprdlr:Play("Television2Angel", true)
				else
					sprdlr:Play("Television2Devil", true)
				end
			end
			if (sprdlr:IsPlaying("Television2Angel") or sprdlr:IsPlaying("Television2Devil")) and sprdlr:GetFrame() == 26 then
				sound:Stop(bpattern.sounds.TVnoise)
				Isaac.Explode(boss.Position+Vector(0,80), boss, 40)
				boss:PlaySound(265, 1, 0, false, 1)
				if boss.State == 14 then
					for i=0, 4 do
						Isaac.Spawn(38, 1, 0, boss.Position+Vector(math.random(-3,3),math.random(78,82)), Vector(0,0), boss)
					end
				else
					for i=0, 4 do
						Isaac.Spawn(252, 0, 0, boss.Position+Vector(math.random(-3,3),math.random(78,82)), Vector(0,0), boss)
					end
				end
			end
			if sprdlr:IsFinished("Television2Angel") or sprdlr:IsFinished("Television2Devil") then
				sprdlr:Play("Idle", true)
				boss.State = 3
			end
		end

		if boss.StateFrame ~= 0 and boss.HitPoints > 1 then
			boss.Velocity = boss.Velocity * 0.1
			if boss:IsDead() then
				boss:Remove()
				local dlr = Isaac.Spawn(412, 0, 0, boss.Position, Vector(0,0), boss)
				dlr:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				dlr.HitPoints = 0
				for k, v in pairs(Entities) do
					if v:IsEnemy() then
						v:Kill()
					end
				end
			end
			return true
		end
	end

	end
end

function bpattern:DlrPhase()
	for k, v in pairs(Isaac:GetRoomEntities()) do
		if v.Type == 412 and Game().Difficulty % 2 == 1 then
			local boss = v:ToNPC()
			local sprdlr = v:GetSprite()
			if v:GetData().MorphedDlr and boss.State < 4 then
				v:Remove()
				local dlr = Isaac.Spawn(412, 0, 0, v.Position, Vector(0,0), v)
				dlr:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				dlr.MaxHitPoints = v.MaxHitPoints
				dlr.HitPoints = v.HitPoints
			end
			if denpnapi and HMBPENTS and DPhase >= 1 + (v.HitPoints / v.MaxHitPoints) * 5
			and DPhase > 1 and v.HitPoints > 1 then
				DPhase = DPhase - 1
				if DPhase <= 6 then
					local bexpl = Isaac.Spawn(1000, 2, 4, v.Position+Vector(0,5), Vector(0,0), v)
					bexpl:SetColor(v.SplatColor, 99999, 0, false, false)
					bexpl:GetSprite().Scale = Vector(2, 2)
					bexpl.PositionOffset = Vector(0,-60)
					if sprdlr:GetDefaultAnimation() ~= "Delirium" then
						v:GetData().MorphedDlr = true
						sprdlr:Load("gfx/412.000_delirium.anm2", true)
					end
					sprdlr:Play("Hurt", true)
					if DPhase == 3 then
						local Start = math.random(0, 1) * 45

						for i=Start, 270 + Start, 90 do
							local lwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, v.Position, Vector(0,0), v)
							lwave:ToEffect().Rotation = i
							lwave.Parent = v
						end
					elseif DPhase == 2 then
						if #Isaac.FindByType(548, -1, -1, true, true) == 0 then
							for i=0, 7 do
								local door = Isaac.Spawn(548, 0, 0,
								Game():GetRoom():GetDoorSlotPosition(i) + Vector.FromAngle((i - (math.floor(i / 4) * 4)) * 90):Resized(20), Vector(0,0), v)
								door:ToNPC().I1 = i
							end
						end
					end
				end
			end
		end
	end
end

  function bpattern:DlrBForm(boss)

  if denpnapi and HMBPENTS and boss:GetSprite():GetDefaultAnimation() ~= "Delirium" then

  	local sprdlr = boss:GetSprite()
	local player = Game():GetPlayer(1)
	local data = boss:GetData()
	local rng = boss:GetDropRNG()
	local Room = Game():GetRoom()

	data.isdelirium = true

	if Game().Difficulty % 2 == 1 then
		if Room:GetFrameCount() % 100 == 0 and rng:RandomInt(18) == 1 then
			Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Blank Polaroid"), 0, Vector(120 + (rng:RandomInt(11) * 80), 200 + (rng:RandomInt(5) * 80)), Vector(0,0), boss)
		end

		if Room:GetFrameCount() % 600 == 0 and DPhase == 1 then
			Isaac.Spawn(554, Isaac.GetEntityVariantByName("Memories III"), 1, boss.Position, Vector(0,0), boss)

			for i=0, 3 do
				Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Escape Trapdoor"), 0, Vector(120+(rng:RandomInt(11)*80),200+(rng:RandomInt(5)*80)), Vector(0,0), boss)
			end
		end
		if boss.EntityCollisionClass ~= 0 then
			if Room:GetFrameCount() % 110 == 0 and DPhase <= 4
			and math.random(1,2) == 1 then
				local params = ProjectileParams()
				params.Variant = Isaac.GetEntityVariantByName("Delirium Projectile")
				params.FallingAccelModifier = -0.19
				params.Scale = 2.5
				params.BulletFlags = ProjectileFlags.SINE_VELOCITY | ProjectileFlags.TRIANGLE
				| ProjectileFlags.SAWTOOTH_WIGGLE
				params.WiggleFrameOffset = 100
				for i = 0, 270, 90 do
					if DlrCopiedPlrForm[10] then
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i+((boss.FrameCount % 2)*45)):Resized(4), 2, params)
					else
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i+((boss.FrameCount % 2)*45)):Resized(4), 0, params)
					end
				end
			end

			if Room:GetFrameCount() % 20 == 0 and DlrCopiedPlrForm[8] and math.random(1,12) == 1 then
				local warn = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Black Circle Warn"), 0, player.Position, Vector(0,0), boss)
				warn:ToEffect().Scale = math.random(4,12) * 0.1
			end

			if Room:GetFrameCount() % 85 == 0 and DPhase <= 3 and HMBPENTS then
				local params = HMBPEnts.ProjParams()
				params.FallingAccelModifier = -0.9
				params.Scale = 2.3

				if math.random(1,2) == 1 then
					params.HMBPBulletFlags = HMBPEnts.ProjFlags.CURVE2
				else
					params.HMBPBulletFlags = HMBPEnts.ProjFlags.TURN_RIGHTANGLE
				end

				if DlrCopiedPlrForm[10] then
					local ShootAngle = rng:RandomInt(3) * 90

					for i=-10, 10, 20 do
						HMBPEnts.FireProjectile(boss, Isaac.GetEntityVariantByName("Delirium Projectile"), boss.Position, Vector.FromAngle(i + ShootAngle):Resized(4), params)
					end
				else
					HMBPEnts.FireProjectile(boss, Isaac.GetEntityVariantByName("Delirium Projectile"), boss.Position, Vector.FromAngle(rng:RandomInt(3) * 90):Resized(4), params)
				end
			end
		end
	end

  end
  end

  function bpattern:DlrBForm2(boss)

  --if boss.Variant == 0 then

  	local sprdlr = boss:GetSprite()
	local player = Game():GetPlayer(1)

	if (boss:GetBossID() == 3 or boss:GetBossID() == 21 or boss:GetBossID() == 27) and boss.FrameCount == 1 then
		boss.HitPoints = boss.HitPoints/0.85
	end

	if Game().Difficulty % 2 == 1 then
		if sprdlr:GetDefaultAnimation() == "MegaSatan" then
			if boss.State < 3 then
				boss.State = 3
				sprdlr:Play("Idle")
				sprdlr.Offset = Vector(0,50)
			end
		elseif sprdlr:GetDefaultAnimation() == "MegaSatanHand" then
			if boss.State < 3 then
				boss.State = 3
				sprdlr:Play("Idle")
			end
			boss.GridCollisionClass = 3
			boss.Velocity = boss.Velocity * 0.8
			if boss.FrameCount > 40 then
				boss:AddVelocity(Vector((boss.Position.X - player.Position.X)*-0.0045,(boss.Position.Y-200)*-0.009))
			end
			if boss.FrameCount % 100 == 0 and boss.FrameCount >= 60 then
				boss.State = 8
				boss:PlaySound(245, 1, 0, false, 1)
			end
			if sprdlr:IsPlaying("SmashHand1") and sprdlr:GetFrame() == 32 then
				for i=0, 180, 90 do
					local shockwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss)
					shockwave.Parent = boss
					shockwave:ToEffect().Rotation = 90
				end
			end
		end
	end

  --end
  end

bpattern:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if DlrHasExist and boss.SubType == 2 then
		boss:Morph(412, 0, 0, -1)
	end
end, 19)

  --bosses--
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.HsBaby, 102)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.MSatan, 274)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.MSHand, 274)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.MSatanS, 275)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Ultigreed, 406)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Ultigreedier, 406)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.UtGreedDoor, 294)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.Hush, 407)
  bpattern:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, bpattern.Delirium, 412)
  bpattern:AddCallback(ModCallbacks.MC_POST_UPDATE, bpattern.DlrPhase)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.DlrBForm, 412)
  bpattern:AddCallback(ModCallbacks.MC_NPC_UPDATE, bpattern.DlrBForm2, 412)
