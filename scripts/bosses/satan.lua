local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--add Boss pattern:The Lamb
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.creeptime = 0
		data.NoEntCollide = false
	end
end, 84)

----------------------------
--add Boss Pattern:Satan
----------------------------
function HMBP:Satan(boss)
	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then
		local sprst = boss:GetSprite()
		local target = boss:GetPlayerTarget()
		local data = boss:GetData()
		local Entities = Isaac:GetRoomEntities()
		local angle = (target.Position - boss.Position):GetAngleDegrees()
		local Room = game:GetRoom()

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

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Satan, 84)
