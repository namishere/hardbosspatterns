local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

--TODO:
--	Where did the code for eyehurt and eyeHp go????

----------------------------
--add Boss Pattern:Mom
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		local data = boss:GetData()
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		data.eyeHp = 15
		data.eyehurt = false
	end
end, 45)

function HMBP:Mom(mom)
	if mom.Variant == 0 and Game().Difficulty % 2 == 1 then

		local sprm = mom:GetSprite()
		local target = mom:GetPlayerTarget()
		local player = Game():GetNearestPlayer(mom.Position)
		local Entities = Isaac:GetRoomEntities()
		local data = mom:GetData()

		if mom.SubType == 33 and sprm:GetFilename() ~= "gfx/Mom_hard_eternal.anm2" then
			sprm:Load("gfx/Mom_hard_eternal.anm2", true)
			sprm:SetFrame("Eye", 64)
		end

		if sprm:IsPlaying("Eye") then
			if mom.SubType == 33 then
				sprm:Play("EyeAttackEternal",true)
			else
				sprm:Play("EyeAttack",true)
			end
			data.eyeHp = 15
		end

		if data.eyehurt then
			mom.State = 8
			mom.ProjectileCooldown = mom.ProjectileCooldown + 2
			mom:SetSpriteFrame("EyeHurt", mom.ProjectileCooldown)

			if mom.ProjectileCooldown == 38 then
				local ShootPos = mom.SubType == 2 and (target.Position - mom.Position):GetAngleDegrees() or (sprm.Rotation + 90)

				if HMBPEPTTN then
					local params = HMBPEnts.ProjParams()
					params.Height = 20
					params.FallingSpeedModifier = -rng:Random(25,75) * 0.1
					params.FallingAccelModifier = 0.5

					for i=0, rng:Random(6, 10) do
						if rng:Random(1, 3) == 1 and i >= 5 then
							params.Scale = 1.65
							params.HMBPBulletFlags = HMBPEnts.ProjFlags.LEAVES_ACID
						else
							params.Scale = 0.7 + rng:Random(0, 2) * 0.3
							params.HMBPBulletFlags = 0
						end

						HMBPEnts.FireProjectile(mom, mom.SubType == 2 and 4 or 0, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
						Vector(rng:Random(45, 120) * 0.1, 0):Rotated(ShootAngle  + rng:Random(-30, 30)), params)
					end
				else
					local params = ProjectileParams()
					params.Height = 20
					params.FallingSpeedModifier = -rng:Random(25,75) * 0.1
					params.FallingAccelModifier = 0.5

					for i=0, rng:Random(8, 14) do
						params.Scale = 0.7 + rng:Random(0, 3) * 0.3
						params.Variant = mom.SubType == 2 and 4 or 0

						HMBPEnts.FireProjectile(mom, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
						Vector(rng:Random(45, 120) * 0.1, 0):Rotated(ShootAngle  + rng:Random(-30, 30)), 0, params)
					end
				end

				mom:PlaySound(153, 1, 0, false, 1)
			elseif mom.ProjectileCooldown == 57 then
				mom.EntityCollisionClass = 0
			elseif mom.ProjectileCooldown >= 61 then
				data.eyehurt = false
			end
		end

		if sprm:IsPlaying("EyeAttack") then
			if sprm:GetFrame() == 3 then
				mom.EntityCollisionClass = 4
			elseif sprm:GetFrame() == 41 and mom.SubType < 3 then
				local params = ProjectileParams()
				params.HeightModifier = 20
				params.FallingAccelModifier = -0.1
				if mom.SubType ~= 2 then
					params.Variant = 4
					mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
					Vector.FromAngle(sprm.Rotation+90):Resized(10), 1, params)
				else
					mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
					Vector.FromAngle((target.Position - mom.Position):GetAngleDegrees()):Resized(10), 1, params)
				end
				mom:PlaySound(153, 1, 0, false, 1)
			elseif sprm:GetFrame() == 45 and mom.SubType > 10 then
				for i=-15, 15, 30 do
					EntityLaser.ShootAngle(1, mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(16) + Vector(0,1)
					, sprm.Rotation + 90 + rng:Random(-10,10) + i, 27, Vector(0,-5), mom)
				end
			elseif sprm:GetFrame() == 62 then
				mom.EntityCollisionClass = 0
			end

			if data.eyeHp <= 0 then
				mom.ProjectileCooldown = 0
				data.eyeHp = math.max(15, 1*GetPlayerDps)
				mom:PlaySound(97, 1, 0, false, 1)
			end
		elseif sprm:IsPlaying("EyeAttackEternal") then
			if sprm:GetFrame() == 3 then
				mom.EntityCollisionClass = 4
			elseif sprm:GetFrame() == 64 then
				mom.EntityCollisionClass = 0
			end
		end

		if eye and eye < 0 then
			eye = 0
		end

	end
end

----------------------------
--add Boss Pattern:Mom Stomp
----------------------------
function HMBP:Momf(mom)
	if mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp") and Game().Difficulty % 2 == 1 then

		local sprmf = mom:GetSprite()
		local target = mom:GetPlayerTarget()
		local player = Game():GetNearestPlayer(mom.Position)
		local data = mom:GetData()
		local Room = Game():GetRoom()
		local Entities = Isaac:GetRoomEntities()

		if data.isdelirium then
			if mom.State == 3 then
				if mom.FrameCount % 50 == 0 and mom.FrameCount >= 30 then
					mom:PlaySound(252, 1, 0, false, 1)
					if mom.SubType == 2 then
						Isaac.Spawn(70, 70, 1, Isaac.GetRandomPosition(0), Vector(0,0), mom)
					else
						Isaac.Spawn(70, 70, 0, player.Position, Vector(0,0), mom)
					end
				end
			end
		end

		if mom.SubType == 33 then
			if data.isdelirium then
				mom:SetColor(Color(1,1,1,1.5,0,0,0), 99999, 0, false, false)
			else
				if sprmf:GetFilename() ~= "gfx/Mom stomp_hard_eternal.anm2" then
					sprmf:Load("gfx/Mom stomp_hard_eternal.anm2", true)
				end
			end
		end

		if mom.State < 7 and mom.HitPoints/mom.MaxHitPoints <= 0.85 and rng:Random(1,3) ~= 1
		and mom.FrameCount % 200 == 0 then
			sprmf:Play("Stronger Stomp", true)
			mom:PlaySound(84, 1, 0, false, 1)
			mom.State = 8
		end

		if mom.State == 7 then
			if sprmf:IsPlaying("Stomp") and sprmf:GetFrame() == 1 and rng:Random(1,3) == 1
			and mom.HitPoints/mom.MaxHitPoints <= 0.5 then
				sprmf:Play("Stomp2", true)
			end
			if sprmf:IsPlaying("Stomp2") then
				if sprmf:GetFrame() == 28 then
					mom:PlaySound(52, 1, 0, false, 1)
					Game():ShakeScreen(20)
					Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
				elseif sprmf:GetFrame() == 67 then
					mom:PlaySound(93, 1.3, 0, false, 1.03)
				elseif sprmf:GetFrame() == 69 then
					Game():ShakeScreen(20)
					mom:PlaySound(138, 1, 0, false, 1)
					Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
					player:AnimatePitfallOut()
					player.ControlsEnabled = false
					player.Velocity = player.Velocity * 3
					for i=0, rng:Random(4,8) do
						Game():SpawnParticles(Isaac.GetRandomPosition(0), 35, 1, 0, Color(0.35,0.35,0.35,1,0,0,0), -1)
					end
				end
			end
		elseif mom.State == 8 then
			mom.Position = Room:GetCenterPos()
			if sprmf:GetFrame() == 58 then
				local Div = REPENTANCE and 255 or 1

				mom:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(20)
				Game():SpawnParticles(mom.Position, 88, 10, 20, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
				Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
				local shockwave1 = Isaac.Spawn(1000, 61, 0, mom.Position, Vector(0,0), mom)
				shockwave1.Parent = mom
				shockwave1:ToEffect().Timeout = 10
				shockwave1:ToEffect().MaxRadius = 90
				if mom.SubType > 10 then
					for i=20, 335, 45 do
						local shockwave2 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
						shockwave2.Parent = mom
						shockwave2:ToEffect().Timeout = 120
						shockwave2:ToEffect():SetRadii(6,6)
					end
				else
					for i=30, 330, 60 do
						if i == 30 or i == 150 or i == 210 or i == 330 then
							local shockwave3 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
							shockwave3.Parent = mom
							shockwave3:ToEffect().Timeout = 120
							shockwave3:ToEffect():SetRadii(6,6)
						end
					end
				end
			end
		end

		if (sprmf:IsFinished("Stronger Stomp") or sprmf:IsFinished("Stomp2")) and mom.State > 3 then
			mom.State = 3
		end

		if sprmf:IsPlaying("Stronger Stomp") and sprmf:IsPlaying("Stomp2") then
			if (sprmf:IsPlaying("Stronger Stomp") and sprmf:GetFrame() >= 58 and sprmf:GetFrame() <= 101)
			or (sprmf:IsPlaying("Stomp2") and ((sprmf:GetFrame() >= 28 and sprmf:GetFrame() <= 56) or (sprmf:GetFrame() >= 69 and sprmf:GetFrame() <= 97))) then
				mom.EntityCollisionClass = 4
			else
				mom.EntityCollisionClass = 0
			end
		end

		for k, v in pairs(Entities) do
			if v:IsVulnerableEnemy() then
				if sprmf:IsPlaying("Stomp2") and sprmf:GetFrame() == 69
				and not v:IsFlying() then
					v:AddFreeze(EntityRef(mom),30)
				end
			end
		end

	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Mom, 45)
HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Momf, 45)
