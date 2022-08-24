local HMBP = HardBossPatterns
local game = game
local rng = HMBP.RNG()

----------------------------
--change Boss AI:Mega Satan 2
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.rhandcooldown = 0
		data.lhandcooldown = 0
		data.handattacking = false
		data.i3 = 0
		data.i4 = 0
		data.summonpattern = false
	end
end, 275)

function HMBP:MSatanS(boss)

	if boss.Variant == 0 and game.Difficulty % 2 == 1 then

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

		if sprss:IsEventTriggered("ShootStart") and rng:Random(1,5) <= 2 then
			boss.State = 10

			if HMBPENTS then
				boss.I1 = rng:Random(1,3)
			else
				boss.I1 = 1 + (rng:Random(0, 1) * 2)
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

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.MsatanS, 275)
