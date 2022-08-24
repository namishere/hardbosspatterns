local HMBP = HardBossPatterns
local game = game
local rng = HMBP.RNG()
local sound = SFXManager()
local lrCopiedPlrForm = {}

----------------------------
--Add Boss Pattern:Mega Satan
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 0 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.ChangedHP = false
		data.AtkCooldown = 0
		data.angle = rng:RandomInt(359)
		data.DlrForm = nil
		data.stompcount = 0
		data.isdelirium = true
	end
end, 412)

----------------------------
--Add Boss Pattern:Delirium
----------------------------
function HMBP:Delirium(npc)
	boss = npc:ToNPC()
	local sprdlr = boss:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local player = Game():GetPlayer(1)
	local data = boss:GetData()
	local Room = Game():GetRoom()
	boss.SplatColor = Color(1,1,1,1,255,255,255)

	if Game().Difficulty % 2 == 1 then
		if boss.State == 0 then
			sound:Stop(HMBP.sounds.TVnoise)
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
					boss:PlaySound(HMBP.sounds.TVnoise, 2, 0, false, 1)
				end
				if boss.StateFrame >= 41 and sprdlr:IsPlaying("Television") then
					if boss.State == 14 then
						sprdlr:Play("Television2Angel", true)
					else
						sprdlr:Play("Television2Devil", true)
					end
				end
				if (sprdlr:IsPlaying("Television2Angel") or sprdlr:IsPlaying("Television2Devil")) and sprdlr:GetFrame() == 26 then
					sound:Stop(HMBP.sounds.TVnoise)
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

function HMBP:DlrPhase()
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

function HMBP:DlrBForm(boss)
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

function HMBP:DlrBForm2(boss)
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
end

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if DlrHasExist and boss.SubType == 2 then
		boss:Morph(412, 0, 0, -1)
	end
end, 19)

HMBP:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, HMBP.Delirium, 412)
HMBP:AddCallback(ModCallbacks.MC_POST_UPDATE, HMBP.DlrPhase)
HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.DlrBForm, 412)
HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.DlrBForm2, 412)
