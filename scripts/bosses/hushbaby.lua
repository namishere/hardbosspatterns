local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--add Boss Pattern:??? (Alt)
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == Isaac.GetEntityVariantByName("??? (Alt)") then
		local data = boss:GetData()
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		data.i3 = 0
	end
end, 102)

function HMBP:HsBaby(boss)
	if boss.Variant == Isaac.GetEntityVariantByName("??? (Alt)")
	and game.Difficulty % 2 == 1 then

		local sprbb = boss:GetSprite()
		local data = boss:GetData()
		local target = boss:GetPlayerTarget()
		local angle = (target.Position - boss.Position):GetAngleDegrees()

		if sprbb:GetFrame() == 1 and sprbb:IsPlaying("3FBAttack4Start") and boss.State == 8 and rng:Random(1,3) == 1 then
			boss.State = 10
			sprbb:Play("3FBAttack4Start", true)
			boss.StateFrame = rng:Random(50,150)
			boss.I1 = rng:Random(1,2)
			boss.ProjectileCooldown = 0
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
						boss:FireProjectiles(boss.Position, Vector(0, 0), 0, params)
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

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.HsBaby, 102)
