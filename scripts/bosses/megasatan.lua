local HMBP = HardBossPatterns
local game = game
local rng = HMBP.RNG()

----------------------------
--Add Boss Pattern:Mega Satan
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.isdelirium = false
		data.i3 = rng:Random(1,3)
		data.angle = 0
		data.random = rng:Random(4,14)*10
	end
end, 274)

function HMBP:MSatan(boss)
	if boss.Variant == 0 then

		local sprms = boss:GetSprite()
		local target = game:GetPlayer(1)
		local dist = target.Position:Distance(boss.Position)
		local data = boss:GetData()
		local angle = (target.Position - boss.Position):GetAngleDegrees()

		if boss.State == 13 and game.Difficulty % 2 == 1 then
		if sprms:IsPlaying("Hide") then
			boss.I2 = 0
			boss.ProjectileCooldown = rng:Random(150,200)
		else
			if boss.I2 == 0 then
				boss.ProjectileCooldown = boss.ProjectileCooldown - 1
				if boss.ProjectileCooldown <= 0 then
					boss.StateFrame = 0
					if data.isdelirium then
						data.i3 = rng:Random(1,3)
						boss.I2 = rng:Random(1,2)
					else
						data.i3 = rng:Random(1,3)
						if #Isaac.FindByType(274, 1, -1, true, true) == 0
						and #Isaac.FindByType(274, 2, -1, true, true) == 0 then
							boss.I2 = 2
						else
							boss.I2 = rng:Random(2,3)
						end
					end
				end
			else
				boss.StateFrame = boss.StateFrame + 1
				if boss.I2 == 1 then
					if boss.StateFrame >= 94 then
						boss.I2 = 0
						boss.ProjectileCooldown = rng:Random(150,200)
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
						boss.ProjectileCooldown = rng:Random(150,200)
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
						boss.ProjectileCooldown = rng:Random(150,200)
					end
					if boss.StateFrame == 1 then
						boss:PlaySound(239, 1, 0, false, 1)
					end
				end
			end
			if boss.I2 > 3 then
				boss.I2 = 0
				if data.isdelirium then
					boss.ProjectileCooldown = rng:Random(110,160)
				else
					boss.ProjectileCooldown = rng:Random(150,200)
				end
			end
		end
		end

		if game.Difficulty % 2 == 1 then

			if sprms:IsEventTriggered("ShootStart") and rng:Random(1,5) <= 2 then
				boss.State = 10
				boss.I2 = rng:Random(1,3)
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
						data.random = rng:Random(4,14) * 10
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


HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Msatan, 274)
