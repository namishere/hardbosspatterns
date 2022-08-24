local Level = Game():GetLevel()

----------------------------
--custom functions
----------------------------
function DotEntPack_WalkRandomly_AxisAligned(speed, ent, path)
	local data = ent:GetData()
	local tpos = ent:GetPlayerTarget().Position
	local room = Game():GetRoom()
	local EntityGridPos = room:GetGridPosition(room:GetGridIndex(ent.Position))
	local PathBlocked = math.floor(((math.min(room:GetGridPathFromPos(ent.Position + Vector(40, 0)), 900) / 900)
	+ (math.min(room:GetGridPathFromPos(ent.Position - Vector(40, 0)), 900) / 900) + (math.min(room:GetGridPathFromPos(ent.Position + Vector(0, 40)), 900) / 900)
	+ (math.min(room:GetGridPathFromPos(ent.Position - Vector(0, 40)), 900) / 900)) / 4)
	--Returns 1 if an obstruction is detected in the up, down, left, right 4 directions or 0 if not.

	if not data.WRAAFollowPos then
		data.WRAAFollowPos = EntityGridPos
	end

	if not data.WRAATurnCount then
		data.WRAATurnCount = 0
	end

	if not data.WRAAMinTurnCount then
		data.WRAAMinTurnCount = 0
	end

	local angle = (data.WRAAFollowPos - ent.Position):GetAngleDegrees()
	local angle2 = math.floor(0.5 + (Game():GetNearestPlayer(ent.Position).Position - ent.Position):GetAngleDegrees() / 90) * 90
	local VelAngle = math.floor(0.5 + ent.Velocity:GetAngleDegrees() / 90) * 90

	if (ent:HasEntityFlags(EntityFlag.FLAG_FEAR) or ent:HasEntityFlags(EntityFlag.FLAG_SHRINK)) and not ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION)
	and Game():GetNearestPlayer(ent.Position).Position:Distance(ent.Position) <= 250 then
		if math.abs(((angle2 - VelAngle) % 360) - math.floor(((angle2 - VelAngle) % 360) / 180) * 360) == 0 then
			data.WRAAFear = 2
		else
			data.WRAAFear = 1
		end
	else
		data.WRAAFear = 0
	end

	if PathBlocked == 1 then
		if data.WRAAFollowPos:Distance(EntityGridPos) ~= 0 then
			data.WRAAFollowPos = EntityGridPos
		end

		ent.Velocity = Vector.FromAngle(angle):Resized(math.min(data.WRAAFollowPos:Distance(ent.Position) * (math.min(speed, 1) / 2), speed * 5))
	else
		if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and data.WRAAFear < 1 and not ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
			if room:GetGridIndex(EntityGridPos) == room:GetGridIndex(tpos) then
				ent.Velocity = ent.Velocity * 0.8
			else
				if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					ent.Pathfinder:FindGridPath(tpos, speed * 0.75, 0, false)
				else
					ent.Pathfinder:FindGridPath(tpos, speed * 0.75, path, false)
				end
			end
		else
			if room:GetGridPathFromPos(data.WRAAFollowPos) >= 900 then
				data.WRAATurnCount = 0
				data.WRAAFollowPos = EntityGridPos
			end

			if data.WRAAFollowPos:Distance(EntityGridPos) == 0 then
				if data.WRAATurnCount > 0 then
					data.WRAATurnCount = data.WRAATurnCount - 1

					if room:GetGridPathFromPos(data.WRAAFollowPos + Vector.FromAngle(math.floor((angle / 90) + 0.5) * 90):Resized(40)) >= 900 or data.WRAAFear > 1 then
						data.WRAATurnCount = 0
					else
						data.WRAAFollowPos = EntityGridPos + Vector.FromAngle(math.floor((angle / 90) + 0.5) * 90):Resized(40)
					end
				else
					if ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then --FLAG_CONFUSION = 1 << 9
						data.WRAATurnCount = math.random(1, 4)
						data.WRAAMinTurnCount = 1
					else
						data.WRAATurnCount = math.random(3, 6)
						data.WRAAMinTurnCount = 3
					end

					if data.WRAAFear > 1 then
						for i = 0, 3 do
							local TurnAngle0 = (angle2 + 90 * ((1 - (data.WRAATurnCount % 2) * 2) * (1 - (i % 2) * 2))) + math.floor(i / 2) * 90

							if room:GetGridPathFromPos(EntityGridPos + Vector.FromAngle(TurnAngle0):Resized(40)) < 999 then
								data.WRAAFollowPos = room:GetGridPosition(room:GetGridIndex(EntityGridPos + Vector.FromAngle(TurnAngle0):Resized(40)))
							end
						end
					else
						for i = 0, data.WRAAMinTurnCount - 1 do
							for j = 0, 3 do
								local TurnAngle = ((math.floor((angle / 90) + 0.5) * 90) + 90 * ((1 - (data.WRAATurnCount % 2) * 2) * (1 - (j % 2) * 2))) + math.floor(j / 2) * 90

								for k = data.WRAAMinTurnCount - i, 1, -1 do
									if not room:CheckLine(EntityGridPos, EntityGridPos + Vector.FromAngle(TurnAngle):Resized(k * 40), 0, 0, false, false)
									or room:GetGridPathFromPos(EntityGridPos + Vector.FromAngle(TurnAngle):Resized(k * 40)) >= 900
									or room:GetGridPathFromPos(EntityGridPos) >= 999 then
										break
									end

									data.WRAAFollowPos = room:GetGridPosition(room:GetGridIndex(EntityGridPos + Vector.FromAngle(TurnAngle):Resized(40)))

									if room:GetGridIndex(EntityGridPos) ~= room:GetGridIndex(data.WRAAFollowPos) then
										break
									end
								end

								if room:GetGridIndex(EntityGridPos) ~= room:GetGridIndex(data.WRAAFollowPos) then
									break
								end
							end

							if room:GetGridIndex(EntityGridPos) ~= room:GetGridIndex(data.WRAAFollowPos) then
								break
							end
						end
					end

					if ent.Velocity.X < ent.Velocity.Y then
						if ent.Velocity.Y / math.abs(ent.Velocity.Y) < (data.WRAAFollowPos.Y - EntityGridPos.Y) / math.abs(data.WRAAFollowPos.Y - EntityGridPos.Y) then
							ent.Velocity = Vector(ent.Velocity.X, -ent.Velocity.Y)
						end
					else
						if ent.Velocity.X / math.abs(ent.Velocity.X) < (data.WRAAFollowPos.X - EntityGridPos.X) / math.abs(data.WRAAFollowPos.X - EntityGridPos.X) then
							ent.Velocity = Vector(-ent.Velocity.X, ent.Velocity.Y)
						end
					end
				end
			end

			if data.WRAAFollowPos:Distance(ent.Position) > 80 then
				data.WRAAFollowPos = EntityGridPos + Vector.FromAngle(math.floor(0.5 + (ent.Velocity:GetAngleDegrees() + 180) / 90) * 90):Resized(40)
			end

			ent.Velocity = (ent.Velocity * 0.8) + Vector.FromAngle(angle):Resized(speed)

			if angle % 180 > 45 and angle % 180 <= 135 then
				ent.Velocity = Vector(ent.Velocity.X * 0.8, ent.Velocity.Y)
			else
				ent.Velocity = Vector(ent.Velocity.X, ent.Velocity.Y * 0.8)
			end

			room:SetGridPath(room:GetGridIndex(ent.Position), path)
		end
	end
end

function DotEntPack_ChaseTarget(speed, maxspeed, friction, ent)
	local data = ent:GetData()
	local room = Game():GetRoom()
	local tpos = ent:GetPlayerTarget().Position
	local ppos = Game():GetNearestPlayer(ent.Position).Position

	if not data.RTTFindGridCount then
		data.RTTFindGridCount = 0
	end

	if not data.RTTMovePos then
		data.RTTMovePos = ent.Position
	end

	if data.RTTFindGridCount > 0 then
		if ent:HasEntityFlags(EntityFlag.FLAG_FEAR) or ent:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
			local angle = (ppos - ent.Position):GetAngleDegrees()
			local angle2 = (data.RTTMovePos - ent.Position):GetAngleDegrees()
			local AngleDifference = math.abs(((angle - angle2) % 360) - math.floor(((angle - angle2) % 360) / 180) * 360)

			data.RTTFindGridCount = data.RTTFindGridCount - 1

			if room:GetGridIndex(data.RTTMovePos) == room:GetGridIndex(ent.Position) or AngleDifference > 90 then
				while AngleDifference > 0 do
					data.RTTMovePos = room:GetGridPosition(room:GetGridIndex(room:GetRandomPosition(0)))
					if data.RTTMovePos:Distance(ent.Position) > 250 and room:GetGridIndex(data.RTTMovePos) ~= room:GetGridIndex(ent.Position) and AngleDifference > 90 then
						break
					end
				end
			end
		else
			data.RTTFindGridCount = 0
		end
	end

	if ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
		if not data.RTTMoveAngle or ent.FrameCount % 37 == 0 or ent:CollidesWithGrid() then
			data.RTTMoveAngle = math.random(-180, 179)
		end
	else
		if (ent:HasEntityFlags(EntityFlag.FLAG_FEAR) or ent:HasEntityFlags(EntityFlag.FLAG_SHRINK)) and ppos:Distance(ent.Position) < 250 then
			data.RTTMoveAngle = (ent.Position - ppos):GetAngleDegrees()
		else
			data.RTTMoveAngle = (tpos - ent.Position):GetAngleDegrees()
			data.RTTMovePos = tpos
		end
	end

	if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		data.RTTFriendly = 0
		room:SetGridPath(room:GetGridIndex(ent.Position), 0)
	else
		data.RTTFriendly = 1
		room:SetGridPath(room:GetGridIndex(ent.Position), 900)
	end
	--Set RTTFrendly value to 0 if entity has both charm and friendly flags, or 1 if not.

	if (room:CheckLine(ent.Position, room:GetGridPosition(room:GetGridIndex(tpos)), 0, 200, false, false) or ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION))
	and data.RTTFindGridCount < 1 then
		ent.Velocity = ent.Velocity * friction

		if maxspeed - (speed * friction) > 0 and ent.Velocity:Length() > maxspeed - (speed * friction) then
			ent:AddVelocity(Vector.FromAngle(data.RTTMoveAngle):Resized(maxspeed * (friction * 0.1112)))
		else
			ent:AddVelocity(Vector.FromAngle(data.RTTMoveAngle):Resized(speed))
		end

		if (ent:HasEntityFlags(EntityFlag.FLAG_FEAR) or ent:HasEntityFlags(EntityFlag.FLAG_SHRINK)) and ppos:Distance(ent.Position) < 250 and ent:CollidesWithGrid() then
			data.RTTFindGridCount = 100
		end
	else
		if maxspeed > 0 then
			ent.Pathfinder:FindGridPath(data.RTTMovePos, maxspeed * 0.15, 900 * data.RTTFriendly, false)
		else
			ent.Pathfinder:FindGridPath(data.RTTMovePos, speed * (1.6 / ((1 - friction) * 10)), 900 * data.RTTFriendly, false)
		end
	end
end

--==============--
   --Entities--
--==============--

--MODEnemyType = 554
----------------------------
--New Enemy Variant:Blue Maw
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Blue Maw") then return end

	local sprite = enemy:GetSprite()

	if sprite:IsPlaying("Shoot") then
		if enemy.ProjectileDelay == 1 then
			enemy.ProjectileDelay = -1
		end

		if sprite:GetFrame() == 5 or sprite:IsEventTriggered("Attack") then
			local angle = (enemy:GetPlayerTarget().Position - enemy.Position):GetAngleDegrees()

			enemy:PlaySound(146, 1, 0, false, 1) --SOUND_SHAKEY_KID_ROAR
			local fly = Isaac.Spawn(18, 0, 0, enemy.Position + Vector.FromAngle(angle):Resized(enemy.Size), Vector.FromAngle(angle):Resized(10), enemy) --Attack Fly
			fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end
end, 26)

----------------------------
--New Enemy Variant:Little Fallen
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Little Fallen") then return end

	local sprite = enemy:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local target = enemy:GetPlayerTarget()
	local angle = (target.Position - enemy.Position):GetAngleDegrees()
	local dist = target.Position:Distance(enemy.Position)
	local sound = SFXManager()

	if sprite:IsFinished("Appear") and enemy.State <= 1 then
		enemy.State = 4
	end

	if enemy.State == 3 then
		enemy.State = 4
	end

	if enemy.State == 4 then
		enemy.StateFrame = enemy.StateFrame - 1
		enemy.Velocity = (enemy.Velocity * 0.8) + Vector.FromAngle(angle):Resized(0.2)

		if not sprite:IsPlaying("Move") then
			sprite:Play("Move",true)
		end

		if dist <= 300 and enemy.StateFrame <= 0 then
			enemy.State = 8
		end
	else
		enemy.Velocity = enemy.Velocity * 0.8

		if enemy.State == 8 then
			if not sprite:IsPlaying("Attack") and not sprite:IsFinished("Attack") then
				sprite:Play("Attack",true)
			end

			if sprite:IsFinished("Attack") then
				enemy.State = 4
				enemy.StateFrame = 15
			end

			if sprite:IsPlaying("Attack") then
				if sprite:GetFrame() == 13 then
					enemy:PlaySound(44, 1, 0, false, 1) --SOUND_FLOATY_BABY_ROAR

					local params = ProjectileParams()
					params.FallingAccelModifier = -0.05
					enemy:FireProjectiles(enemy.Position, Vector.FromAngle(angle):Resized(8), 1, params)
				elseif sprite:GetFrame() == 37 then
					sound:Stop(44)
					enemy:PlaySound(44, 1, 0, false, 1)
					enemy:FireProjectiles(enemy.Position, Vector.FromAngle(angle):Resized(10), 0, ProjectileParams())
				end
			end
		end
	end
end, 554)

denpnapi:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Little Fallen") then return end

	enemy:PlaySound(207, 1, 0, false, 1) --SOUND_GOODEATH

	if #Isaac.FindByType(400, 0, -1, true, true) > 0 and HMBPENTS then
		Isaac.Spawn(557, Isaac.GetEntityVariantByName("Lil Fallen's Skull"), 0, enemy.Position, Vector(0, 0), enemy)
	end
end, 554)

----------------------------
--New Enemy Variant:Baby Bone
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Baby Bone") and enemy.Variant ~= Isaac.GetEntityVariantByName("Fallen Baby Bone") then return end

	local sprbbn = enemy:GetSprite()
	local target = enemy:GetPlayerTarget()
	local angle = (target.Position - enemy.Position):GetAngleDegrees()

	if sprbbn:IsFinished("Appear") then
		enemy.State = 4
		sprbbn:Play("Move",true)
	end

	if enemy.State == 4 then
		enemy.Velocity = (enemy.Velocity * 0.9) + Vector.FromAngle(angle):Resized(0.3)

		if enemy.ProjectileCooldown <= 0 then
			sprbbn:Play("Vanish",true)
			enemy.State = 6
		end

		enemy.EntityCollisionClass = 4
	else
		enemy.Velocity = enemy.Velocity * 0.9
	end

	if enemy.State == 0 then
		enemy.ProjectileCooldown = math.random(150,250)
	end

	enemy.ProjectileCooldown = enemy.ProjectileCooldown - 1

	if enemy.State == 6 then
		enemy.EntityCollisionClass = 0

		if sprbbn:IsFinished("Vanish") then
			sprbbn:Play("Vanish2",true)
			enemy.Position = Isaac.GetRandomPosition(0)
		end

		if sprbbn:IsFinished("Vanish2") then
			sprbbn:Play("Move",true)
			enemy.State = 4
			enemy.ProjectileCooldown = math.random(150,250)
		end
	end

end, 554)

denpnapi:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Baby Bone") and enemy.Variant ~= Isaac.GetEntityVariantByName("Fallen Baby Bone") then return end

	for i=45, 315, 90 do
		local params = ProjectileParams()
		params.Variant = 1 --Bone Projectile
		enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i):Resized(10), 0, params)
	end
end, 554)

----------------------------
--New Enemy:Greed Fatty
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Greed Fatty") then return end

	local sprgf = enemy:GetSprite()
	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy.SplatColor = Color(0.7,0.7,0.7,1,0,0,0)

	if enemy.State == 4 then
		enemy.StateFrame = enemy.StateFrame + 1
	end

	if sprgf:IsEventTriggered("Spit") then
		enemy:PlaySound(319, 1, 0, false, 1) --SOUND_LITTLE_SPIT

		local params = ProjectileParams()
		params.HeightModifier = -5
		params.Variant = 7 --Coin Projectile
		enemy:FireProjectiles(enemy.Position, Vector.FromAngle((enemy:GetPlayerTarget().Position - enemy.Position):GetAngleDegrees()):Resized(10), 0, params)
	end

	if enemy:IsDead() then
		if math.random(1, 2) == 1 then
			Isaac.Spawn(5, 20, 1, enemy.Position, Vector(0,0), enemy) --Penny
		end

		for i=45, 315, 90 do
			local params = ProjectileParams()
			params.Variant = 7
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i):Resized(7), 0, params)
		end
	end
end, 208)

----------------------------
--New Enemy:Greedier Gaper
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Greedier Gaper") then return end

  	local sprite = enemy:GetSprite()
	local target = enemy:GetPlayerTarget()
	local dist = target.Position:Distance(enemy.Position)
	local data = enemy:GetData()
	local angle = (target.Position - enemy.Position):GetAngleDegrees()
	local sound = SFXManager()
	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
	enemy:AnimWalkFrame("WalkHori","WalkVert",1)
	DotEntPack_ChaseTarget(0.62, 0, 0.85, enemy)

	if enemy.FrameCount % 4 == 0 then
		local bling = Isaac.Spawn(1000, 103, 0, enemy.Position + Vector(0,1), Vector(0,0), enemy)
		bling.PositionOffset = Vector(math.random(-20,20),math.random(-47,-5))
	end

	if enemy.State == 1 then
		enemy.State = 4
		enemy.StateFrame = math.random(70, 120)
    end

	if not data.attack then
		sprite:PlayOverlay("Head", true)
		enemy.StateFrame = enemy.StateFrame - 1

		if dist <= 200 and enemy.StateFrame <= 0 then
			data.attack = true
		end
	end

	if sprite:IsOverlayPlaying("Head") and sprite:GetOverlayFrame() == 6 then
		enemy:PlaySound(319, 1, 0, false, 1) --SOUND_LITTLE_SPIT

		local params = ProjectileParams()
		params.Variant = 7
		enemy:FireProjectiles(enemy.Position, Vector.FromAngle(angle):Resized(10), 0, params)
	end

	if enemy:IsDead() then
		enemy:PlaySound(427, 1, 0, false, 2) --SOUND_ULTRA_GREED_COIN_DESTROY
		Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Circular Impact"), 0, enemy.Position, Vector(0,0), enemy)

		for i=0, 6, 2 do
			Game():SpawnParticles(enemy.Position, 95, 10, i, Color(1.1,1,1,1,0,0,0), -50)
		end

		if math.random(1,2) == 1 then
			Isaac.Spawn(5, 20, 1, enemy.Position, Vector(0,0), enemy) --Penny
		end
	end

	if dist < 200 and enemy.FrameCount % 80 == 0 and not sound:IsPlaying(165) and data.attack then
		enemy:PlaySound(165, 1, 0, false, 1) --SOUND_ZOMBIE_WALKER_KID
	end
end, 554)

----------------------------
--New Enemy:Greedier Fatty
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Greedier Fatty") then return end

  	local sprite = enemy:GetSprite()
	local target = enemy:GetPlayerTarget()
	local dist = target.Position:Distance(enemy.Position)
	local data = enemy:GetData()
	local rng = enemy:GetDropRNG()
	local sound = SFXManager()
	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
	enemy.StateFrame = enemy.StateFrame - 1

	if enemy.FrameCount % 4 == 0 then
		local bling = Isaac.Spawn(1000, 103, 0, enemy.Position + Vector(0,1), Vector(0,0), enemy)
		bling.PositionOffset = Vector(math.random(-27,27),math.random(-65,-5))
	end

	if enemy.State < 3 then
		enemy.State = 4
		enemy.StateFrame = math.random(120,200)
	elseif enemy.State == 4 then
		DotEntPack_ChaseTarget(0.25, 0, 0.86, enemy)
		enemy:AnimWalkFrame("WalkHori","WalkVert",1)

		if dist <= 200 and enemy.StateFrame <= 0 then
			enemy.State = 8
			sprite:Play("AttackVert", true)
			enemy:PlaySound(167, 1, 0, false, 1)
		end
    end

	if enemy.State ~= 4 then
		enemy.Velocity = enemy.Velocity * 0.7
	end

	if sprite:IsPlaying("AttackVert") and sprite:GetFrame() >= 17 and sprite:GetFrame() <= 42 then
		data.vel = math.random(0, 75)

		if sprite:GetFrame() == 17 then
			enemy:PlaySound(16, 1, 0, false, 1) --SOUND_BOSS_SPIT_BLOB_BARF
		end

		local params = ProjectileParams()
		params.Variant = 7 --Coin Projectile
		params.FallingAccelModifier = 0.5
		params.FallingSpeedModifier = (-125 + data.vel) * 0.2
		params.Scale = math.random(5, 12) * 0.1
		params.HeightModifier = -20
		enemy:FireProjectiles(enemy.Position + Vector(0,5), Vector.FromAngle(rng:RandomInt(359)):Resized(data.vel * 0.1), 0, params)
	end

	if sprite:IsFinished("AttackVert") then
		enemy.State = 4
		enemy.StateFrame = math.random(120,200)
	end

	if enemy:IsDead() then
		enemy:PlaySound(427, 1, 0, false, 2)  --SOUND_ULTRA_GREED_COIN_DESTROY
		Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Circular Impact"), 0, enemy.Position, Vector(0,0), enemy)

		for i=0, 6, 2 do
			Game():SpawnParticles(enemy.Position, 95, 20, i, Color(1.1,1,1,1,0,0,0), -50)
		end

		if math.random(1,2) == 1 then
			Isaac.Spawn(5, 20, 1, enemy.Position, Vector(0,0), enemy) --Penny
		end

		for i=45, 315, 90 do
			local params = ProjectileParams()
			params.Variant = 7
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i):Resized(7), 0, params)
		end
	end

	if dist < 200 and enemy.FrameCount % 120 == 0 and not sound:IsPlaying(116) and enemy.State == 4 then
		enemy:PlaySound(116, 1, 0, false, 1) --SOUND_MONSTER_ROAR_1
	end
end, 554)

----------------------------
--New Enemy:Deliring
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Deliring") then return end

  	local sprite = enemy:GetSprite()
	local data = enemy:GetData()
	enemy.SplatColor = Color(1, 1, 1, 1, 300, 300, 300)

	if sprite:IsFinished("Appear") then
		sprite:Play("Rotate")
		enemy.State = 4
		enemy.StateFrame = math.random(250, 350)

		if enemy.SubType == 1 then
			enemy.Velocity = Vector.FromAngle((math.random(1, 4) * 90) + 45):Resized(0.5)
		end
	end

	if enemy.State == 4 then
		enemy.StateFrame = enemy.StateFrame - 1
		if enemy.SubType == 0 then
			enemy.Velocity = (enemy.Velocity * 0.9) + Vector.FromAngle(enemy.FrameCount*6):Resized(0.8)
		elseif enemy.SubType == 1 then
			enemy.Velocity = enemy.Velocity:Normalized() * 5
		else
			if (enemy.FrameCount % 10 == 0 and math.random(1, 2) == 1) or enemy:CollidesWithGrid() then
				enemy.TargetPosition = Isaac.GetRandomPosition(0)
			end

			enemy.Velocity = (enemy.Velocity * 0.9) + Vector.FromAngle((enemy.TargetPosition - enemy.Position):GetAngleDegrees()):Resized(0.6)
		end
	else
		enemy.Velocity = enemy.Velocity * 0.9
	end

	if enemy.FrameCount % 120 == 0 and enemy.State ~= 5 then
		enemy:PlaySound(178, 1, 0, false, 1) --SOUND_BLOODSHOOT

		local params = ProjectileParams()

		if HMBPENTS then
			params.Variant = Isaac.GetEntityVariantByName("Delirium Projectile")
		end

		for i=0, 240, 120 do
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i + enemy.FrameCount * 60):Resized(6), 0, params)
		end
    end

	if enemy.StateFrame <= 0 and sprite:IsPlaying("Rotate") and sprite:GetFrame() == 15 then
		enemy.State = 5

		if math.random(1, 4) <= 3 then
			sprite:Play("Morph", true)
		else
			sprite:Play("Morph2", true)
		end
	end

	if sprite:IsPlaying("Morph2") and sprite:GetFrame() == 41 then
		enemy.EntityCollisionClass = 0 --ENTCOLL_NONE
	end

	if sprite:IsEventTriggered("Explode") then
		enemy:PlaySound(265, 1, 0, false, 1) --SOUND_SUMMONSOUND

		if sprite:IsPlaying("Morph") then
			enemy:Die()
			Isaac.Spawn(554, math.random(1, 2) == 1 and Isaac.GetEntityVariantByName("Memories I") or Isaac.GetEntityVariantByName("Memories II"), 0, enemy.Position, Vector(0,0), enemy)
		elseif sprite:IsPlaying("Morph2") then
			enemy:PlaySound(28, 1, 0, false, 1) --SOUND_DEATH_BURST_LARGE
			enemy:Remove()
			Isaac.Spawn(554, Isaac.GetEntityVariantByName("Memories III"), 0, enemy.Position, Vector(0,0), enemy)
		end
	end
end, 554)

----------------------------
--New Enemy:Memories I
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Memories I") then return end

  	local sprite = enemy:GetSprite()
	local path = enemy.Pathfinder
	local target = enemy:GetPlayerTarget()
	local Entities = Isaac:GetRoomEntities()
	local dist = target.Position:Distance(enemy.Position)

	if sprite:IsFinished("Appear") then
		sprite:PlayOverlay("Head", true)
		enemy.State = 4
	end

	if dist <= 400 and enemy.FrameCount % 70 == 0 and not SFXManager():IsPlaying(143) then
		enemy:PlaySound(143, 1, 0, false, 1.1) --SOUND_SCARED_WHIMPER
    end

	if sprite:IsOverlayPlaying("Head") and sprite:GetOverlayFrame() == 53 then
		enemy:PlaySound(178, 1, 0, false, 1) --SOUND_BLOODSHOOT

		local params = ProjectileParams()

		if HMBPENTS then
			params.Variant = Isaac.GetEntityVariantByName("Delirium Projectile")
		end

		for i=0, 270, 90 do
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i + enemy.FrameCount * 45):Resized(6), 0, params)
		end
    end

	if enemy.State == 4 then
		DotEntPack_ChaseTarget(0.6, 0, 0.86, enemy)

		if enemy.Velocity:Length() >= 0.5 then
			if math.abs(enemy.Velocity.X) < math.abs(enemy.Velocity.Y) and not sprite:IsPlaying("WalkVert") then
				sprite:Play("WalkVert", true)
			elseif math.abs(enemy.Velocity.X) > math.abs(enemy.Velocity.Y) then
				if enemy.Velocity.X >= 0 and not sprite:IsPlaying("WalkRight") then
					sprite:Play("WalkRight", true)
				elseif enemy.Velocity.X < 0 and not sprite:IsPlaying("WalkLeft") then
					sprite:Play("WalkLeft", true)
				end
			end
		else
			sprite:Play("WalkVert", true)
		end
	end
end, 554)

----------------------------
--New Enemy:Memories II
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Memories II") then return end

  	local sprite = enemy:GetSprite()
	local path = enemy.Pathfinder
	local data = enemy:GetData()
	local rng = enemy:GetDropRNG()
	local Room = Game():GetRoom()
	local sound = SFXManager()

	if enemy.State == 0 then
		enemy.I1 = 9
	end

	enemy.State = 4

	if enemy.I1 > (enemy.HitPoints / enemy.MaxHitPoints) * 10 then
		enemy:PlaySound(181, 1, 0, false, 1) --SOUND_BOIL_HATCH
		enemy.I1 = enemy.I1 - 1
		data.lnth = math.random(30, 100)

		if math.random(1,2) == 1 then
			local fly = Isaac.Spawn(18, 0, 0, enemy.Position, Vector.FromAngle(math.random(0,360)):Resized(math.random(5,10)), enemy) --Attack Fly
			fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		else
			EntityNPC.ThrowSpider(enemy.Position, enemy, enemy.Position + Vector.FromAngle(rng:RandomInt(359)):Resized(data.lnth), false, -data.lnth * 0.6)
		end
	end

	if enemy.FrameCount % 70 == 0 and math.random(1,3) == 1 and not sound:IsPlaying(116) then
		enemy:PlaySound(116, 1, 0, false, 1) --SOUND_MONSTER_ROAR_1
    end

	if enemy.State == 4 then
		DotEntPack_WalkRandomly_AxisAligned(0.6, enemy, 900)

		if enemy.Velocity:Length() >= 0.5 then
			if math.abs(enemy.Velocity.X) < math.abs(enemy.Velocity.Y) then
				if enemy.Velocity.Y >= 0 and not sprite:IsPlaying("WalkDown") then
					sprite:Play("WalkDown", true)
				elseif enemy.Velocity.Y < 0 and not sprite:IsPlaying("WalkUp") then
					sprite:Play("WalkUp", true)
				end
			elseif math.abs(enemy.Velocity.X) > math.abs(enemy.Velocity.Y) then
				if enemy.Velocity.X >= 0 and not sprite:IsPlaying("WalkRight") then
					sprite:Play("WalkRight", true)
				elseif enemy.Velocity.X < 0 and not sprite:IsPlaying("WalkLeft") then
					sprite:Play("WalkLeft", true)
				end
			end
		end
	else
		sprite:Play("WalkDown", true)
		enemy.Velocity = enemy.Velocity * 0.7
	end

end, 554)

----------------------------
--New Enemy:Memories III
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Memories III") then return end

  	local sprite = enemy:GetSprite()
	local target = enemy:GetPlayerTarget()
	local dist = target.Position:Distance(enemy.Position)
	enemy.StateFrame = enemy.StateFrame - 1
	enemy.Velocity = enemy.Velocity * 0.8

	if enemy.State == 0 then
		if enemy.SubType == 1 then
			enemy.StateFrame = 100
			enemy.PositionOffset = Vector(0, -80)
		else
			enemy.StateFrame = math.random(150, 200)
			Game():ShakeScreen(10)
			enemy.I1 = 2
		end

		if math.random(1,2) == 2 then
			enemy.FlipX = true
		end
	end

	if (enemy.SpawnerType == 1000 and enemy.SpawnerVariant == 360) or enemy.SubType == 1 then
		if enemy.State == 0 then
			if enemy.Variant ~= 1 then
				enemy.I1 = 2
			else
				enemy.EntityCollisionClass = 0
			end

			enemy.State = 2
		end

		if sprite:IsFinished("Appear") then
			sprite:Play("Appear2", true)
		end

		if sprite:IsFinished("Appear2") then
			enemy.State = 4

			if enemy.Variant == 1 then
				enemy.PositionOffset = Vector(0,0)
			end
		end
	else
		if enemy.State == 0 then
			enemy.State = 4
			enemy.EntityCollisionClass = 0
			enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		end

		enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end

	if sprite:IsEventTriggered("Up") then
		enemy.EntityCollisionClass = 0 --ENTCOLL_NONE
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		enemy:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		enemy:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end

	if enemy.State == 4 then
		enemy.EntityCollisionClass = 0

		if enemy.StateFrame >= 130 then
			sprite:Play("Falling", true)
		elseif enemy.StateFrame == 0 then
			sprite:Play("Down", true)
		end

		if sprite:IsPlaying("Falling") then
			enemy.Position = (enemy.SubType == 1 and enemy.Target) and enemy.Target.Position or target.Position
			--enemy.TargetPosition = enemy.Position
			--enemy.Position = target.Position
		end
    end

	if enemy.SubType == 1 and enemy.State == 4 then
		enemy.Position = target.Position
	end

	if sprite:IsFinished("Down") then
		sprite:Play("Stuck", true)
		enemy.State = 8
    end

	if sprite:IsFinished("Stuck") then
		if enemy.SubType == 1 then
			sprite:Play("Idle", true)
			enemy.StateFrame = 20
		else
			sprite:Play("PullOut", true)
		end
    end

	if sprite:IsFinished("PullOut") then
		sprite:Play("PullOutLoop", true)
		enemy.StateFrame = 30
    end

	if sprite:IsPlaying("PullOutLoop") then
		if enemy.StateFrame >= 12 then
			enemy.Velocity = (enemy.Velocity * 0.9) + Vector.FromAngle((target.Position - enemy.Position):GetAngleDegrees()):Resized(5)
		end

		if enemy.StateFrame <= 0 then
			sprite:Play("Attack", true)
		end
	end

	if sprite:IsFinished("Attack") then
		if enemy.I1 > 0 then
			sprite:Play("PullOut", true)
			enemy.I1 = enemy.I1 - 1
		else
			sprite:Play("Idle", true)
			enemy.StateFrame = 75
		end
    end

	if sprite:IsPlaying("Idle") and enemy.StateFrame <= 0 then
		sprite:Play("PullOut2", true)
	end

	if sprite:IsFinished("PullOut2") then
		if enemy.SubType == 1 then
			enemy:Remove()
		end

		enemy.StateFrame = math.random(150,200)
		enemy.State = 4
		enemy.I1 = 2
    end

	if sprite:IsEventTriggered("Land") then
		enemy:PlaySound(138, 1, 0, false, 1) --SOUND_POT_BREAK
		SpawnGroundParticle(false, enemy, 8, 6, 1, 7)
		Game():BombDamage(enemy.Position, 40, 20, false, enemy, 0, 0, false)
		enemy.EntityCollisionClass = 4 --ENTCOLL_ALL
		enemy.Velocity = Vector(0, 0)
		enemy.PositionOffset = Vector(0, 0)
		enemy:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end
end, 554)

----------------------------
--New Enemy:Crying Gaper
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Crying Gaper") then return end

  	local sprite = enemy:GetSprite()
	local target = enemy:GetPlayerTarget()
	local dist = target.Position:Distance(enemy.Position)
	enemy:AnimWalkFrame("WalkHori", "WalkVert", 1)
	DotEntPack_ChaseTarget(0.4, 0, 0.88, enemy)

	if sprite:IsFinished("Appear") then
		enemy.State = 4
    end

	if not sprite:IsOverlayPlaying("Head") and not sprite:IsOverlayFinished("Head") then
		sprite:PlayOverlay("Head", true)
	end

	if enemy.FrameCount % 10 == 0 then
		local Div = REPENTANCE and 255 or 1

		local creep = Isaac.Spawn(1000, 22, 0, enemy.Position, Vector(0,0), enemy) --enemy creep (red)
		creep:SetColor(Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div), 99999, 0, false, false)
		creep:Update()
    end

	if dist < 200 and enemy.FrameCount % 80 == 0 and not SFXManager():IsPlaying(143) then
		enemy:PlaySound(143, 1, 0, false, 1.1) --SOUND_SCARED_WHIMPER
	end
end, 554)

----------------------------
--New Enemy:Hushling
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Hushling") then return end

  	local sprite = enemy:GetSprite()
	local data = enemy:GetData()
	local target = enemy:GetPlayerTarget()
	local dist = target.Position:Distance(enemy.Position)
	local angle = (target.Position - enemy.Position):GetAngleDegrees()
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	enemy.StateFrame = enemy.StateFrame - 1
	enemy.I1 = enemy.I1 - 1

	if enemy.State == 3 then
		data.destination = Isaac.GetRandomPosition(0)
	end

	if sprite:IsFinished("Appear") then
		sprite:Play("Appear2", true)
	elseif sprite:IsFinished("Appear2") or sprite:IsFinished("Convex") then
		sprite:Play("Shake", true)
		enemy.State = 3
		enemy.I1 = math.random(50, 300)
	elseif sprite:IsFinished("Concave") then
		sprite:Play("ConcaveMove", true)
		enemy.State = 4
	end

	if (sprite:IsPlaying("Appear2") and sprite:GetFrame() == 2) or ((sprite:IsPlaying("Convex") or sprite:IsPlaying("Concave")) and sprite:GetFrame() == 4) then
		enemy:PlaySound(314, 0.65, 0, false, 1.5) --SOUND_SKIN_PULL
	end

	if sprite:IsPlaying("ConcaveMove") or (sprite:IsPlaying("Concave") and sprite:GetFrame() >= 6) or (sprite:IsPlaying("Convex") and sprite:GetFrame() <= 4)
	or (sprite:IsPlaying("Appear2") and sprite:GetFrame() == 1) or enemy.FrameCount <= 10 then
		enemy.DepthOffset = -40
	else
		enemy.DepthOffset = 0
	end

	if enemy.State == 3 then
		if enemy.I1 <= 0 and not sprite:IsPlaying("Concave") then
			sprite:Play("Concave", true)
		end

		if sprite:IsPlaying("Shake") and dist <= 200 then
			enemy.StateFrame = 15
			enemy.State = 8
		end
	end

	if enemy.State == 8 then
		if enemy.StateFrame <= 0 and sprite:IsPlaying("Shake") then
			sprite:Play("Spit", true)
		end

		if sprite:IsPlaying("Spit") and sprite:GetFrame() == 6 then
			enemy:PlaySound(226, 1, 0, false, 1) --SOUND_MEATHEADSHOOT

			local params = ProjectileParams()
			params.Scale = 1.5
			params.BulletFlags = ProjectileFlags.BURST | ProjectileFlags.ACCELERATE
			params.Acceleration = 0.9
			params.HeightModifier = 10
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(angle):Resized(15), 0, params)
		end

		if sprite:IsFinished("Spit") then
			enemy.I1 = 0
			enemy.State = 3
		end
	end

	if enemy.FrameCount <= 10 or (sprite:IsPlaying("Concave") and sprite:GetFrame() == 5) then
		enemy.EntityCollisionClass = 3
	elseif sprite:IsPlaying("Appear2") or (sprite:IsPlaying("Convex") and sprite:GetFrame() == 5) then
		enemy.EntityCollisionClass = 4
	end

	if enemy.State == 4 then
		enemy.Velocity = Vector.FromAngle((data.destination - enemy.Position):GetAngleDegrees()):Resized(5)

		if enemy:CollidesWithGrid() or data.destination:Distance(enemy.Position) <= 20 then
			sprite:Play("Convex", true)
			enemy.State = 3
			enemy.Velocity = Vector(0,0)
			enemy.I1 = math.random(50,300)
		end
	end

end, 554)
----------------------------
--New Enemy:Hush Spider
----------------------------
denpnapi:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Hush Spider") then return end

	enemy.Velocity = enemy.Velocity * 0.65
end, 85)

denpnapi:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function (_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Hush Spider") then return end

	enemy:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/monster_spider_hush_"..math.random(2, 3)..".png")
	enemy:GetSprite():LoadGraphics()
end, 85)
