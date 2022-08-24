local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--Add Boss Pattern:Ultra Greed
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.changedHP = false
		data.Phase2 = false
		data.attackcount = 0
		data.Land = false
		data.Stomped = false
		data.Stomped2 = false
		data.SpawnedCoins = false
		data.CoinProjSpawnDelay = 20
		data.CoinProjSpawnPos = {}
	end
end, 406)

function HMBP:Ultigreed(boss)
	if boss.Variant == 0 and Game().Difficulty % 2 == 1 then
		local sprug = boss:GetSprite()
		local data = boss:GetData()
		local target = Game():GetPlayer(1)
		local dist = target.Position:Distance(boss.Position)
		local Entities = Isaac:GetRoomEntities()
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
						params.Scale = rng:Random(13,20)*0.1
						params.FallingSpeedModifier = -rng:Random(15,65)*0.1
						params.FallingAccelModifier = 0.3
						boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(5,15)), 0, params)
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

					boss:PlaySound(HMBP.sounds.AngerScream, 1.2, 0, false, 0.8)
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
				boss:PlaySound(HMBP.sounds.AngerScream, 1, 0, false, 1)
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
					for i=0, rng:Random(1,3) do
						if i ~= 0 then
							if rng:Random(1,3) == 1 then
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
							boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(rng:Random(-10,10)*0.1,rng:Random(-10,10)*0.1), 0, params)
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

					for i=0, rng:Random(2, 4) * (HMBPENTS and 1 or 2) do
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
					if rng:Random(1,2) == 1 then
						sprug:Play("SmashLeft", true)
					else
						sprug:Play("SmashRight", true)
					end
					boss.State = 19
					data.attackcount = rng:Random(4,6)+(boss.I2/3)
					boss:PlaySound(433, 1, 0, false, 1)
				elseif boss.I1 == 2 then
					boss.State = 11
					sprug:Play("BlastStart", true)
					boss.StateFrame = rng:Random(120,135)
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
				for i=0, rng:Random(0,2) do
					params.Scale = 1.5
					params.FallingSpeedModifier = 0
					params.HeightModifier = -300
					params.FallingAccelModifier = 0.6
					params.BulletFlags = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
					params.ChangeTimeout = 10
					params.ChangeFlags = 0
					boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(rng:Random(-10,10)*0.1,rng:Random(-10,10)*0.1), 0, params)
				end
			end

			if sprug:IsPlaying("SpinStart") and sprug:GetFrame() == 1 and rng:Random(1,3) == 1 then
				boss.State = 9
				sprug:Play("SpinOnce2", true)
				data.attackcount = rng:Random(3, 5) + math.floor(boss.I2 / 5)
			end

			if ((sprug:IsPlaying("ShootUp") or sprug:IsPlaying("ShootDown") or sprug:IsPlaying("ShootLeft") or sprug:IsPlaying("ShootRight"))
			and sprug:GetFrame() == 1) or (boss.State >= 3 and boss.State <= 4 and boss.FrameCount % 35 == 0) then
				if rng:Random(1,8) == 1 then
					boss.State = 10
					sprug:Play("JumpReady", true)
					data.attackcount = rng:Random(2, 4) + math.floor(boss.I2 / 5)
					data.Land = false
				elseif rng:Random(1,8) == 2 then
					boss.State = 26
					sprug:Play("JumpUp", true)
					data.attackcount = rng:Random(1, math.ceil(boss.I2 / 7))
					data.Jumped = false
					data.Land = false
				elseif rng:Random(1,8) == 3 and HMBPENTS then
					if rng:Random(1, 2) == 1 then
						sprug:Play("SmashLeft", true)
					else
						sprug:Play("SmashRight", true)
					end

					boss.State = 19
					data.attackcount = rng:Random(2, 4) + math.floor(boss.I2 / 5)
					boss:PlaySound(433, 1, 0, false, 1)
				elseif rng:Random(1,8) == 4 then
					if boss.Position.Y >= 600 then
						boss.I1 = 2
						sprug:Play("JumpReady", true)
						boss.State = 26
						data.Jumped = false
						data.Land = false
					else
						boss.State = 11
						sprug:Play("BlastStart", true)
						boss.StateFrame = rng:Random(120, 135)
					end
				end
			end
		end
	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Ultigreed, 406)
