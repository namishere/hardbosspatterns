local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()
local sound = SFXManager()

----------------------------
--add Boss pattern:The Lamb
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.angle = 0
		data.DetonateDist = 0
		data.planc = false
		data,skill = false
	end
end, 273)

function HMBP:Lamb(boss)
	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then
		local sprl = boss:GetSprite()
		local target = boss:GetPlayerTarget()
		local data = boss:GetData()
		local dist = target.Position:Distance(boss.Position)
		local targetangle = (target.Position - boss.Position):GetAngleDegrees()
		local Room = game:GetRoom()

		data.planc = false

		if boss.State ~= 4 then
			if sprl:GetFrame() == 1 then
				if sprl:IsPlaying("Charge") then
					if rng:Random(1,3) == 1 then
						if rng:Random(1,3) == 1 and boss.HitPoints / boss.MaxHitPoints <= 0.75 and HMBPENTS then
							sprl:Play("AttackReady", true)
							boss.State = 12
							boss.StateFrame = 138
						else
							sprl:Play("Charge3", true)
							boss.State = 11
						end
					end
				elseif sprl:IsPlaying("HeadCharge") then
					if rng:Random(1,3) == 1 then
						sprl:Play("HeadCharge2", true)
						boss.State = 11
						boss:PlaySound(312 , 1, 0, false, 1)
						if sound:IsPlaying(106) then
							sound:Stop(106)
						elseif sound:IsPlaying(108) then
							sound:Stop(108)
						end
					elseif rng:Random(1,3) == 2 then
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
							if v.Parent and v.Parent.InitSeed == boss.InitSeed and rng:Random(0,2) == 1 and HMBPENTS and not data.isdelirium then
								sprl:Play("HeadAttackReady", true)
								boss.State = 12
								boss.StateFrame = 0
								boss.I2 = rng:Random(4,7)

								break
							end
						end
					end
				end
			end

			if sprl:IsFinished("Charge2") then
				sprl:Play("Blast", true)
				boss.I2 = 0
				boss.StateFrame = rng:Random(80,120)
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
							if rng:Random(1,2) == 1 then
								sprl:Play("HeadStompUp", true)
							else
								sprl:Play("HeadStompDown", true)
							end
						else
							sprl:Play("HeadStompHori", true)
							if rng:Random(0,1) == 1 then
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
				boss.StateFrame = rng:Random(90,140)
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
			boss.StateFrame = rng:Random(90,140)
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
			boss.StateFrame = rng:Random(90,140)
			boss.EntityCollisionClass = 4
		end

		if (sprl:IsPlaying("Swarm3") or sprl:IsPlaying("HeadShoot3")) and sprl:IsEventTriggered("Shoot2") then
			boss:PlaySound(305 , 1, 0, false, 1)
		elseif (sprl:IsPlaying("Swarm3") or sprl:IsPlaying("HeadShoot3")) and sprl:GetFrame() == 35 then
			boss.StateFrame = rng:Random(80,120)
		end

		if (sprl:IsPlaying("Swarm2Start") or sprl:IsPlaying("HeadShoot2Start")) and sprl:GetFrame() == 2 and rng:Random(1,5) <= 2 and boss.I2 ~= 0 then
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
				--boss.Child:Remove() --What child?
			end
			if boss.FrameCount % 3 == 0 then
				local params = ProjectileParams()
				params.FallingSpeedModifier = -50
				params.FallingAccelModifier = 2
				params.HeightModifier = -15
				params.Scale = rng:Random(10,20) * 0.1
				params.Color = Color(0.11,1.5,2,1,0,0,0)
				params.BulletFlags = 2
				if rng:Random(1,3) == 1 then
					boss:FireProjectiles(boss.Position, Vector.FromAngle(targetangle+rng:Random(-2,2)):Resized(dist*(20 * 0.0015)), 0, params)
				else
					boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(30,55)*0.1), 0, params)
				end
			end
		elseif sprl:IsPlaying("HeadShoot3") and boss.FrameCount % 2 == 0 then
			local params = ProjectileParams()
			params.GridCollision = false
			params.FallingSpeedModifier = -rng:Random(3,7)
			params.FallingAccelModifier = -0.1
			params.HeightModifier = -24
			params.Scale = rng:Random(10,20) * 0.1
			params.Color = Color(0.11,1.5,2,1,0,0,0)
			params.BulletFlags = ProjectileFlags.CONTINUUM
			boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(4,8)), 0, params)
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

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Lamb, 273)
