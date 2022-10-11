local Level = Game():GetLevel()

----------------------------
--Blue Boil (Thrown)
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Blue Boil (Thrown)") then return end
	local sprbbl = enemy:GetSprite()
	local data = enemy:GetData()
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)

	if enemy.FrameCount == 1 then
		sprbbl:Play("Move", true)
		enemy.Velocity = Vector.FromAngle(enemy.Velocity:GetAngleDegrees()):Resized(enemy.Velocity:Length())
	end

	if sprbbl:IsPlaying("Move") then
		data.FallingSpd = data.FallingSpd + 0.3
		enemy.PositionOffset = Vector(enemy.PositionOffset.X, enemy.PositionOffset.Y + data.FallingSpd)
		if enemy.PositionOffset.Y >= 0 then
			enemy.PositionOffset = Vector(enemy.PositionOffset.X, 0)

			if data.FallingSpd <= 2 then
				sprbbl:Play("Land", true)
				enemy.CollisionDamage = 0
			else
				data.FallingSpd = -data.FallingSpd * 0.75
			end
		end
	else
		enemy.Velocity = Vector(0,0)
	end

	if sprbbl:IsFinished("Land") then
		enemy:Morph(298, 0, 0, -1)
		enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end, 552)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Blue Boil (Thrown)") then return end

	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy.EntityCollisionClass = 2
	enemy:GetData().FallingSpd = -4.5
end, 552)

----------------------------
--New Enemy:Mini Lamb
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Mini Lamb") then return end

	local Room = Game():GetRoom()
	enemy.SplatColor = Color(0.13,1.73,2.28,1.5,0,0,0)

	if enemy.FrameCount == 1 then
		enemy:PlaySound(119, 1, 0, false, 1.25)
		enemy.GridCollisionClass = 0
		enemy:GetSprite():Play("Charge", true)
		Isaac.Spawn(1000, 15, 0, enemy.Position, Vector(0,0), enemy)
		enemy.Visible = true
	end

	if enemy.Velocity.X < 0 then
		enemy.FlipX = false
	elseif enemy.Velocity.X > 0 then
		enemy.FlipX = true
	end

	enemy.Velocity = Vector(enemy.Velocity.X+(enemy.Velocity.X/math.abs(enemy.Velocity.X))*0.5, enemy.Velocity.Y)

	if enemy.Position.X <= -300 or enemy.Position.X >= Room:GetBottomRightPos().X + 300 or enemy.Position.Y <= -150
	or enemy.Position.Y >= Room:GetBottomRightPos().Y + 300 then
		enemy:Remove()
	end

end, 555)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Mini Lamb") then return end

	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy.Visible = false
end, 555)

----------------------------
--New Object:Delirium's Sin Heart
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Delirium's Sin Heart") then return end

	local sprdsh = enemy:GetSprite()
	local data = enemy:GetData()
	enemy.SplatColor = Color(0,0,0,1,0,0,0)

	if not sprdsh:IsPlaying("Heart") then
		sprdsh:Play("Heart", true)
	end

	if enemy.Parent then
		if enemy.Parent:IsDead() then
			data.dlr = nil
		else
			data.dlr = enemy.Parent
		end
		if enemy.Position:Distance(enemy.Parent.Position) >= enemy.Parent.Size + 150 then
			enemy.Velocity = (enemy.Velocity * 0.95) + Vector.FromAngle((enemy.Parent.Position-enemy.Position):GetAngleDegrees()):
			Resized((enemy.Parent.Position:Distance(enemy.Position)-(enemy.Parent.Size + 150))*0.007)
		else
			enemy.Velocity = enemy.Velocity * 0.95
		end

		if enemy.FrameCount == 1 then
			data.dlr = enemy.Parent
			for i=-3, 3 do
				local cord = Isaac.Spawn(556, Isaac.GetEntityVariantByName("Sin Heart Cord"), i+3, enemy.Position, Vector(0,0), boss):ToNPC()
				cord.SpawnerEntity = enemy
				cord.Parent = enemy.Parent
				cord.StateFrame = i+3
				cord.I1 = math.abs(i)
				cord.I2 = 2
			end
		end
	else
		if data.dlr then
			enemy.Parent = data.dlr
		else
			if #Isaac.FindByType(412, -1, -1, true, true) > 0 then
				for k, v in pairs(Isaac:GetRoomEntities()) do
					if v.Type == 412 then
						data.dlr = v
						break
					end
				end
			else
				enemy:Kill()
			end
		end
	end

	if enemy:IsDead() then
		enemy:PlaySound(33, 1, 0, false, 1.2)
		local params = ProjectileParams()
		params.FallingAccelModifier = -0.1
		params.Variant = 6
		params.Color = Color(0,0,0,1,0,0,0)
		for i=0, 315, 45 do
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(i):Resized(7.5), 0, params)
		end
	end
end, 666)

--Cords

HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Sin Heart Cord") then return end
	local sprdsh = enemy:GetSprite()
	local data = enemy:GetData()
	enemy.Velocity = Vector(0,0)

	if enemy.Parent then
		data.parsize = enemy.Parent.Size
		enemy.PositionOffset = Vector(enemy.PositionOffset.X,
		-15+((math.abs(enemy.I1-3)-(math.abs(enemy.I1-3)*math.abs(enemy.I1-3))*0.1)*1.7))
	else
		if enemy.SpawnerEntity:GetData().dlr then
			enemy.Parent = enemy.SpawnerEntity.Parent
		end
	end

	if enemy.FrameCount < 2+enemy.StateFrame then
		sprdsh.PlaybackSpeed = 0
	else
		sprdsh.PlaybackSpeed = 1
	end

	if enemy.SpawnerEntity and enemy.Parent then
		enemy.Position = enemy.Parent.Position + Vector.FromAngle((enemy.SpawnerEntity.Position-enemy.Parent.Position):GetAngleDegrees())
		:Resized(data.parsize+(enemy.SubType*0.142)*(enemy.Parent.Position:Distance(enemy.SpawnerEntity.Position)-data.parsize))
	end

	if not enemy.SpawnerEntity then
		enemy.I2 = 0
	elseif not enemy.Parent then
		enemy.I2 = enemy.I2 - 1
	end

	if enemy.I2 < 1 then
		enemy:Remove()
		enemy:BloodExplode()
	end

	if enemy.SpawnerEntity then
		if enemy.SpawnerEntity:HasEntityFlags(EntityFlag.FLAG_FREEZE) or
		enemy.SpawnerEntity:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then
			sprdsh.PlaybackSpeed = 0
		else
			sprdsh.PlaybackSpeed = 1
		end
	end

	if enemy.FrameCount % 25 == 1+enemy.StateFrame or enemy.FrameCount == 1 then
		if enemy.SubType > 4 then
			sprdsh:Play("Cord01", true)
			enemy.SplatColor = Color(1,1,1,1,255,255,255)
		elseif enemy.SubType > 2 then
			sprdsh:Play("Cord02", true)
			enemy.SplatColor = Color(0.5,0.5,0.5,1,125,125,125)
		else
			sprdsh:Play("Cord03", true)
			enemy.SplatColor = Color(0,0,0,1,0,0,0)
		end
	end
end, 666)

 HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant == Isaac.GetEntityVariantByName("Delirium's Sin Heart") then
		enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	elseif enemy.Variant == Isaac.GetEntityVariantByName("Sin Heart Cord") then
		enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		enemy.EntityCollisionClass = 0
	end
end, 666)

----------------------------
--New Object:Lamb II Clone
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, boss)
  if boss.Variant ~= Isaac.GetEntityVariantByName("Lamb II Clone") then return end

	local sprl2 = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local Room = Game():GetRoom()
	boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	boss.GridCollisionClass = 0
	boss.EntityCollisionClass = 1

	if boss.State == 0 then
		boss.State = 8
		boss:PlaySound(119, 1, 0, false, 1)
		boss.Visible = true
		if math.abs(boss.Velocity.X) >= math.abs(boss.Velocity.Y) then
			sprl2:Play("HeadDashHori", true)
			if boss.Velocity.X < 0 then
				local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(Room:GetTopLeftPos().X, boss.Position.Y), Vector(0,0), boss)
				wallholext:GetSprite().Rotation = 270
				wallholext.Parent = boss
				wallholext.PositionOffset = Vector(0,-20)
				boss.FlipX = true
			else
				local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(Room:GetBottomRightPos().X, boss.Position.Y), Vector(0,0), boss)
				wallholext:GetSprite().Rotation = 90
				wallholext.Parent = boss
				wallholext.PositionOffset = Vector(0,-20)
			end
		else
			if boss.Velocity.Y < 0 then
				sprl2:Play("HeadDashUp", true)
				local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(boss.Position.X, Room:GetTopLeftPos().Y), Vector(0,0), boss)
				wallholext.Parent = boss
			else
				sprl2:Play("HeadDashDown", true)
				local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(boss.Position.X, Room:GetBottomRightPos().Y), Vector(0,0), boss)
				wallholext.Parent = boss
				wallholext:GetSprite().Rotation = 180
			end
		end
	end

	if sprl2:IsPlaying("HeadDashHori") then
		data.dashanim = "Hori"
		if not boss.FlipX then
			boss.Velocity = Vector(33, boss.Velocity.Y * 0.9)
			if boss.Position.X >= Room:GetBottomRightPos().X + 10 then
				boss.I1 = 1
			end
		else
			boss.Velocity = Vector(-33, boss.Velocity.Y * 0.9)
			if boss.Position.X <= Room:GetTopLeftPos().X - 10 then
				boss.I1 = 1
			end
		end
	elseif sprl2:IsPlaying("HeadDashUp") then
		data.dashanim = "Up"
		boss.Velocity = Vector(boss.Velocity.X * 0.9, -33)
		if boss.Position.Y <= Room:GetTopLeftPos().Y - 10 then
			boss.I1 = 1
		end
	elseif sprl2:IsPlaying("HeadDashDown") then
		data.dashanim = "Down"
		boss.Velocity = Vector(boss.Velocity.X * 0.9, 33)
		if boss.Position.Y >= Room:GetBottomRightPos().Y + 10 then
			boss.I1 = 1
		end
	end

	if boss.I1 == 1 then
		boss:Remove()
		boss:PlaySound(28, 1, 0, false, 1)
		Game():ShakeScreen(10)
		local xplsn = Isaac.Spawn(1000, 2, 2, boss.Position, Vector(0,0), boss)
		xplsn:SetColor(Color(0.13,1.73,2.28,1.5,0,0,0), 99999, 0, false, false)
		xplsn.PositionOffset = Vector(0,-20)
	end

end, 555)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant ~= Isaac.GetEntityVariantByName("Lamb II Clone") then return end

	local sprl2 = boss:GetSprite()
	boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	sprl2:Play("HeadDashDown", true)

	for i=1, 9, 8 do
		sprl2:ReplaceSpritesheet(i, "gfx/bosses/afterbirthplus/lamb2_body.png")
	end

	sprl2:LoadGraphics()
end, 555)

----------------------------
--New Object:Lamb Body(Dead)
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, object)
	if object.Variant ~= Isaac.GetEntityVariantByName("Lamb Body(Dead)") then return end

	local sprdlb = object:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	object.SplatColor = Color(0.13,1.73,2.28,1.5,0,0,0)

	object.Velocity = object.Velocity * 0.7

	if object.FrameCount == 1 then
		sprdlb:Play("death", true)
		object:GetData().ChangedHP = true
		object.MaxHitPoints = 550
		object.HitPoints = 275
	end

	if object.FrameCount >= 230 and (#Isaac.FindByType(273, 0, -1, true, true) > 0
	or #Isaac.FindByType(555, 0, -1, true, true) > 0) then
		object:Morph(400, 0, 0, -1)
		object.CanShutDoors = true
		local poof = Isaac.Spawn(1000, 15, 0, object.Position, Vector(0,0), object)
		poof.SpriteOffset = Vector(20, 0)
		poof:SetColor(Color(0,0,6,1,0,0,0), 99999, 0, false, false)
		object.EntityCollisionClass = 4
		object:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		object:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end

end, 400)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, object)
	if object.Variant ~= Isaac.GetEntityVariantByName("Lamb Body(Dead)") then return end

	local sprdlb = object:GetSprite()
	sprdlb:Play("death", true)
	object:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	object:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	object:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	object.EntityCollisionClass = 1
end, 400)

----------------------------
--New Enemy:Delirium's Hand
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, hand)
  if hand.Variant ~= Isaac.GetEntityVariantByName("Delirium's Hand") then return end

  	local sprdh = hand:GetSprite()
	local data = hand:GetData()
	sprdh.Offset = Vector(0,-13)
	hand.EntityCollisionClass = 2
	hand.Velocity = Vector.FromAngle(sprdh.Rotation):Resized(13)

	if hand.FrameCount % 3 == 0 then
		local cords = Isaac.Spawn(545, 1, 0, hand.Position, Vector(0,0), hand)
		cords.SpawnerEntity = hand
	end
	if hand.FrameCount == 1 then
		sprdh:Play("Move", true)
    end

	if hand:CollidesWithGrid() then
		hand:Remove()
		hand:BloodExplode()
	end
end, 545)

HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, cord)
  if cord.Variant ~= Isaac.GetEntityVariantByName("Delirium's Hand Cord") then return end

  	local sprdc = cord:GetSprite()
	local player = Game():GetPlayer(1)
	local dist = player.Position:Distance(cord.Position)
	cord.EntityCollisionClass = 0
	cord.Velocity = Vector(0,0)

	if cord.SpawnerEntity then
		cord.StateFrame = cord.FrameCount
	end

	if cord.FrameCount == 2 then
		sprdc:Play("Wiggle", true)
	elseif cord.FrameCount >= cord.StateFrame + 50 then
		cord:Remove()
		cord:PlaySound(30, 1, 0, false, 1)
		local poof = Isaac.Spawn(1000, 2, 2, cord.Position, Vector(0,0), cord)
		poof:SetColor(cord.SplatColor, 99999, 0, false, false)
    end

	if player.EntityCollisionClass >= 3 and dist <= 13 + player.Size then
		player:TakeDamage(1, 0, EntityRef(cord), 5)
	end
end, 545)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, ent)
	if ent.Variant ~= Isaac.GetEntityVariantByName("Delirium's Hand") and ent.Variant ~= Isaac.GetEntityVariantByName("Delirium's Hand Cord") then return end

	ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	ent.SplatColor = Color(1,1,1,1,300,300,300)
end, 545)

----------------------------
--New Enemy:Delirium's Triplets
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Delirium's Triplets") then return end

  	local sprdt = enemy:GetSprite()
	local data = enemy:GetData()
	enemy.SplatColor = Color(1,1,1,1,300,300,300)
	enemy.StateFrame = enemy.StateFrame + 1

	if sprdt:IsFinished("Appear") then
		enemy.State = 3
		data.endframe = 0
	end

	if enemy.Parent then
		local EParent = enemy.Parent
		if EParent:IsDead() then
			data.prt = nil
		else
			data.prt = EParent
		end
		if EParent.Size * 2 >= 100 then
			data.radi = 100
		else
			data.radi = EParent.Size * 2
		end
		local pos = EParent.Position + Vector.FromAngle((EParent.Velocity):GetAngleDegrees()+(-45+enemy.SubType*90)+enemy.I2):Resized(data.radi)
		local angle = (EParent.Position - enemy.Position):GetAngleDegrees()
		if EParent.Velocity:Length() == 0 then
			enemy.I2 = 90
		else
			enemy.I2 = 0
		end
		if EParent.HitPoints > 1 then
			data.endframe = 98
		else
			data.endframe = 14
		end

		if enemy.StateFrame > data.endframe then
			enemy.StateFrame = 0
		end

		data.dist2 = pos:Distance(enemy.Position)
		enemy.Velocity = (enemy.Velocity * 0.5) + Vector.FromAngle((pos - enemy.Position):GetAngleDegrees()):Resized(data.dist2*0.2)
		if angle >= -157.5 and angle < -112.5 then
			enemy:SetSpriteFrame("HoriDown", enemy.StateFrame)
			enemy.FlipX = true
		elseif angle >= -112.5 and angle < -67.5 then
			enemy:SetSpriteFrame("Down", enemy.StateFrame)
		elseif angle >= -67.5 and angle < -22.5 then
			enemy:SetSpriteFrame("HoriDown", enemy.StateFrame)
			enemy.FlipX = false
		elseif angle >= -22.5 and angle < 22.5 then
			enemy:SetSpriteFrame("Hori", enemy.StateFrame)
			enemy.FlipX = false
		elseif angle >= 22.5 and angle < 67.5 then
			enemy:SetSpriteFrame("HoriUp", enemy.StateFrame)
			enemy.FlipX = false
		elseif angle >= 67.5 and angle < 112.5 then
			enemy:SetSpriteFrame("Up", enemy.StateFrame)
		elseif angle >= 112.5 and angle < 157.5 then
			enemy:SetSpriteFrame("HoriUp", enemy.StateFrame)
			enemy.FlipX = true
		else
			enemy:SetSpriteFrame("Hori", enemy.StateFrame)
			enemy.FlipX = true
		end
		if sprdt:GetFrame() == 84 then
			enemy:PlaySound(25, 1, 0, false, 1)
			local params = ProjectileParams()
			params.Variant = Isaac.GetEntityVariantByName("Delirium Projectile")
			params.FallingAccelModifier = -0.165
			params.Scale = 1.5
			enemy:FireProjectiles(enemy.Position, Vector.FromAngle(angle+180):Resized(6), 4, params)
		end
	else
		if data.prt then
			enemy.Parent = data.prt
		else
			if #Isaac.FindByType(412, -1, -1, true, true) > 0 then
				for k, v in pairs(Isaac:GetRoomEntities()) do
					if v.Type == 412 then
						data.prt = v
						break
					end
				end
			else
				enemy:Kill()
			end
		end
	end

end, 546)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Delirium's Triplets") then return end

	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	enemy.EntityCollisionClass = 0
end, 546)

----------------------------
--Mom (Delirium)
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Mom (Delirium)") then return end

  	local sprdm = enemy:GetSprite()
	local data = enemy:GetData()
	local player = Game():GetPlayer(1)
	local Entities = Isaac:GetRoomEntities()
	local dist = player.Position:Distance(enemy.Position)
	local Room = Game():GetRoom()
	enemy.Velocity = Vector(0,0)
	enemy.SplatColor = Color(1,1,1,1,255,255,255)
	enemy.GridCollisionClass = 0

	if enemy.I1 < 4 then
		sprdm.Rotation = -90+enemy.I1*90
	else
		sprdm.Rotation = -90+(enemy.I1-4)*90
	end

	if enemy.State == 0 then
		enemy.TargetPosition = Room:GetDoorSlotPosition(enemy.I1) + Vector.FromAngle(sprdm.Rotation+90):Resized(20)
	end

	enemy.Velocity = Vector.FromAngle((enemy.TargetPosition-enemy.Position):GetAngleDegrees()):Resized(enemy.TargetPosition:Distance(enemy.Position) * 0.5)

	if sprdm:IsFinished("Appear") and enemy.State <= 2 then
		enemy.State = 3
		enemy.StateFrame = math.random(350,1000)
		enemy.CollisionDamage = 2
	end

	if enemy.State == 3 then
		enemy.EntityCollisionClass = 0
		enemy.StateFrame = enemy.StateFrame - 1
		if enemy.StateFrame <= 0 and dist <= 450 then
			if math.random(1,3) == 1 then
				enemy.State = 9
			else
				enemy.State = 8
			end
		end
	end

	if enemy.State >= 8 and enemy.State <= 11 then
		if enemy.State == 8 and not sprdm:IsPlaying("Eye") then
			sprdm:Play("Eye", true)
		elseif enemy.State == 9 and not sprdm:IsPlaying("ArmOpen") then
			sprdm:Play("ArmOpen", true)
		end
		if enemy.State == 8 then
			if sprdm:GetFrame() == 17 then
				enemy.EntityCollisionClass = 1
			elseif sprdm:GetFrame() == 55 then
				for i=5, 60 do
					if i == 5 or i == 60 then
						local creep = Isaac.Spawn(1000, 25, 0, enemy.Position + Vector.FromAngle(sprdm.Rotation+90):Resized(i+20), Vector(0,0), enemy)
						creep.SpriteScale = Vector(1+(i*0.015),1+(i*0.015))
					end
				end
				local params = ProjectileParams()
				params.HeightModifier = 20
				params.FallingAccelModifier = 0.5
				params.Variant = Isaac.GetEntityVariantByName("Delirium Projectile")
				for i=0, math.random(5,10) do
					params.Scale = math.random(10,18) * 0.1
					params.FallingSpeedModifier = math.random(40,100) * -0.1
					enemy:FireProjectiles(enemy.Position + Vector.FromAngle(sprdm.Rotation+90):Resized(10),
					Vector.FromAngle(sprdm.Rotation+90+math.random(-22,22)):Resized(math.random(7,14)), 0, params)
				end
				enemy:PlaySound(153, 1, 0, false, 1)
			elseif sprdm:GetFrame() == 76 then
				enemy.EntityCollisionClass = 0
			end
		elseif enemy.State == 9 then
			if sprdm:GetFrame() == 20 then
				enemy:PlaySound(36, 1, 0, false, 1)
			elseif sprdm:GetFrame() == 49 then
				enemy.EntityCollisionClass = 1
				enemy:PlaySound(48, 1, 0, false, 1)
				local shockwave = Isaac.Spawn(1000, 72, 0, enemy.Position + Vector.FromAngle(sprdm.Rotation+90):Resized(15), Vector(0,0), enemy)
				shockwave:ToEffect().Rotation = sprdm.Rotation+90
				shockwave:ToEffect().Timeout = 200
				local creep = Isaac.Spawn(1000, 25, 0, enemy.Position + Vector.FromAngle(sprdm.Rotation+90):Resized(15), Vector(0,0), enemy)
				creep.SpriteScale = Vector(3,3)
			elseif sprdm:GetFrame() == 86 then
				enemy.EntityCollisionClass = 0
			end
		end
		if (sprdm:IsPlaying("Eye") and sprdm:GetFrame() == 77)
		or (sprdm:IsPlaying("ArmOpen") and sprdm:GetFrame() == 95) then
			enemy.State = 3
			enemy.StateFrame = math.random(350,600)
		end
	end

	if DPhase and DPhase <= 1 then
		local bexpl = Isaac.Spawn(1000, 2, 0, enemy.Position+Vector.FromAngle(sprdm.Rotation-90):Resized(10), Vector(0,0), enemy)
		bexpl:SetColor(enemy.SplatColor, 99999, 0, false, false)
		enemy:BloodExplode()
		enemy:Remove()
	end

end, 548)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Mom (Delirium)") then return end

	enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	enemy.EntityCollisionClass = 0
end, 548)
----------------------------
--New Enemy:Delirium Fly
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("Delirium Fly") then return end

  	local sprdfl = enemy:GetSprite()
	local data = enemy:GetData()
	enemy:RemoveStatusEffects()
	enemy.GridCollisionClass = 0
	enemy.EntityCollisionClass = 2

	if enemy.State == 0 then
		enemy.State = 4
		sprdfl:Play("Idle", true)
	end

	if enemy.Parent then
		local EParent = enemy.Parent
		if EParent:IsDead() then
			data.prt = nil
		else
			data.prt = EParent
		end
		if EParent.Size * 2 >= 100 then
			data.angle = 100
		else
			data.angle = EParent.Size * 2
		end
		local pos = EParent.Position + Vector.FromAngle(enemy.StateFrame+enemy.SubType*180):Resized(data.angle)
		local dist = pos:Distance(enemy.Position)
		enemy.StateFrame = enemy.StateFrame + 2
		if enemy.StateFrame >= 360 then
			enemy.StateFrame = 0
		end
		enemy.Velocity = (enemy.Velocity * 0.5) + Vector.FromAngle((pos - enemy.Position):GetAngleDegrees()):Resized(dist*0.14)
	else
		if data.prt then
			enemy.Parent = data.prt
		else
			if #Isaac.FindByType(412, -1, -1, true, true) > 0 then
				for k, v in pairs(Isaac:GetRoomEntities()) do
					if v.Type == 412 then
						data.prt = v
						break
					end
				end
			else
				enemy:Kill()
			end
		end
	end

end, 550)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant ~= Isaac.GetEntityVariantByName("Delirium Fly") then return end

	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	enemy:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
end, 550)

----------------------------
--New Enemy:Delirium GodHead
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant ~= Isaac.GetEntityVariantByName("GodHead (Delirium)") then return end

  	local sprdghd = enemy:GetSprite()
	local data = enemy:GetData()
	local player = Isaac.GetPlayer(0)

	if not denpnapi then
		enemy:Remove()
	end

	enemy.PositionOffset = Vector(0,-50)
	enemy.EntityCollisionClass = 0

	if sprdghd:IsFinished("Appear") then
		sprdghd:Play("Idle",true)
	end
	if enemy.FrameCount % 30 == math.random(0,10) or enemy:CollidesWithGrid() or enemy.TargetPosition:Distance(enemy.Position) <= 75 then
		enemy.TargetPosition = Isaac.GetRandomPosition(0)
	end

	enemy.Velocity = (enemy.Velocity * 0.9) + Vector.FromAngle((enemy.TargetPosition-enemy.Position):GetAngleDegrees()):Resized(math.random(5,15) * 0.02)

	if not sprdghd:IsPlaying("Appear") then
		if enemy.FrameCount % 200 == 0 and sprdghd:IsPlaying("Idle") then
			sprdghd:Play("Attack",true)
		end
		if sprdghd:IsPlaying("Attack") and sprdghd:GetFrame() == 27 then
			if math.random(1,2) == 1 then
				for i=0, 270, 90 do
					local lwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, enemy.Position, Vector(0,0), enemy)
					lwave:ToEffect().Rotation = i
					lwave.Parent = enemy
				end
			else
				for i=45, 315, 90 do
					local lwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, enemy.Position, Vector(0,0), enemy)
					lwave:ToEffect().Rotation = i
					lwave.Parent = enemy
				end
			end
		end
		if sprdghd:IsFinished("Attack") then
			sprdghd:Play("Idle",true)
		end
		if DPhase < 3 and not sprdghd:IsPlaying("Removing") then
			sprdghd:Play("Removing",true)
		end
	end
	if sprdghd:IsPlaying("Removing") and sprdghd:GetFrame() == 15 then
		enemy:Remove()
	end

end, 551)

----------------------------
--Lil Fallen's Skull
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, obj)
  if obj.Variant ~= Isaac.GetEntityVariantByName("Lil Fallen's Skull") then return end

	local sprfls = obj:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	obj.Velocity = obj.Velocity * 0.75

	if obj.State <= 2 and sprfls:IsFinished("Drop") then
		sprfls:Play("Drop", true)
		obj.State = 3
	end

	if sprfls:IsPlaying("Drop") and sprfls:GetFrame() == 11 then
		obj:PlaySound(467, 1, 0, false, 0.35)
	end

	for k, v in pairs(Entities) do
		local vspr = v:GetSprite()
		if v.Type == 400 and v:ToNPC().State == 13 and vspr:IsPlaying("Rebirth")
		and vspr:GetFrame() > 5 and vspr:GetFrame() <= 10 then
			obj.I1 = 1
		end
		if v.Type == 1000 and v.Variant == 93 then
			if v.Position:Distance(obj.Position) < v.Size-obj.Size then
				obj.I2 = 1
			else
				obj.I2 = 0
			end
		end
	end

	if #Isaac.FindByType(1000, 93, -1, true, true) < 1 then
		obj.I2 = 0
	end

	if obj.I2 == 1 then
		obj.StateFrame = obj.StateFrame - 1
	else
		obj.StateFrame = 50
	end

	if (obj.I1 ~= 0 and denpnapi) or (obj.StateFrame < 1 and obj.I2 == 1 and obj.FrameCount > 3) then
		local flnskl = Isaac.Spawn(554, Isaac.GetEntityVariantByName("Fallen Baby Bone"), 0, obj.Position, Vector(0,0), obj)
		if obj.StateFrame < 1 then
			flnskl:AddCharmed(66666666)
			flnskl:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			flnskl:SetColor(Color(1,1,1,1,0,0,0), 99999, 0, false, false)
			obj:PlaySound(265, 1, 0, false, 1)
		end
		obj:Remove()
	end

	if #Isaac.FindByType(273, -1, -1, true, true) < 1 and #Isaac.FindByType(400, 0, -1, true, true) < 1 and #Isaac.FindByType(555, -1, -1, true, true) < 1 then
		Isaac.Spawn(1000, 15, 1, obj.Position, Vector(0,0), obj)
		obj:PlaySound(137, 1, 0, false, 1.5)
		Game():SpawnParticles(obj.Position, 35, math.random(5,10), 5, Color(1,1,1,1,0,0,0), -10)
		obj:Remove()
	end
end, 557)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, obj)
	if obj.Variant ~= Isaac.GetEntityVariantByName("Lil Fallen's Skull") then return end

	obj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	obj:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	obj:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	obj.EntityCollisionClass = 1
end, 557)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, obj)
	if not obj.Variant == Isaac.GetEntityVariantByName("Lil Fallen's Skull") then return end

	obj:Remove()
	obj:PlaySound(137, 1, 0, false, 1.5)
	Game():SpawnParticles(obj.Position, 35, math.random(5,10), 5, Color(1,1,1,1,0,0,0), -10)
end, 557)
----------------------------
--New Enemy:Hush's Hand
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, enemy)
  if enemy.Variant > 1 then return end

  	local sprhhn = enemy:GetSprite()
	local player = Game():GetNearestPlayer(enemy.Position)
	local Entities = Isaac:GetRoomEntities()
	local data = enemy:GetData()
	local ppos = player.Position
	local pardata = enemy.Parent:GetData()
	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
	enemy.StateFrame = enemy.StateFrame - 1
	enemy.Velocity = enemy.Velocity * 0.8

	if enemy.Variant == 1 and not enemy.FlipX then
		enemy.FlipX = true
	end

	if sprhhn:IsFinished("Appear") then
		if enemy.SpawnerType == 407 and enemy.FrameCount == 1 then
			sprhhn:Play("Appear", true)
		end

		if enemy.State < 1 and enemy.FrameCount > 3 then
			enemy.State = 3
		end
	end

	if enemy.State == 0 then
		enemy.StateFrame = math.random(250,325)
		enemy.EntityCollisionClass = 0
		data.caughtenemy = nil
		data.shkwavepos = Vector(0,0)
		enemy.DepthOffset = -50
		data.tgpos = 0
		data.SpawnPos = Vector(150-enemy.Variant*300,100)
	elseif enemy.State == 3 then
		enemy.TargetPosition = enemy.Parent.Position + Vector(150-enemy.Variant*300, 100)
		enemy.Position = enemy.TargetPosition
		enemy.EntityCollisionClass = 0
		if enemy.StateFrame <= 0 then
			if not pardata.handatck then
				if ppos:Distance(enemy.Parent.Position) <= 300 then
					enemy.State = 4
					enemy.StateFrame = 35
					pardata.handatck = true
					enemy.I1 = math.random(0,1)
				end
			else
				enemy.StateFrame = math.random(250,325)
			end
		end
	elseif enemy.State == 4 then
		data.tgpos = ppos + Vector(0,-85*enemy.I1)
		if enemy.StateFrame > -15 or enemy.I1 ~= 0 then
			enemy:AddVelocity(Vector.FromAngle((data.tgpos-enemy.Position):GetAngleDegrees()):Resized(2))
		end

		if enemy.StateFrame <= 0 and not (sprhhn:IsPlaying("Convex Punch") or sprhhn:IsPlaying("Become Convex")) then
			if enemy.I1 == 0 then
				sprhhn:Play("Convex Punch", true)
			else
				sprhhn:Play("Become Convex", true)
			end
			enemy.Position = ppos + Vector(0,-85*enemy.I1)
		end

		if sprhhn:GetFrame() == 30 then
			enemy.Velocity = Vector(0,0)
			if enemy.I1 == 0 then
				enemy.State = 8
			else
				enemy.State = 9
			end
		end
	elseif enemy.State == 8 then
		if sprhhn:IsPlaying("Convex Punch") then
			if sprhhn:GetFrame() == 33 then
				enemy.DepthOffset = 0
				enemy:PlaySound(182, 1, 0, false, 1)
				enemy.EntityCollisionClass = 4
				Game():BombDamage(enemy.Position, 25, enemy.Size, true, enemy, 0, 1, true)
			elseif sprhhn:GetFrame() == 50 and math.random(1,2) == 1 then
				sprhhn:Play("Throw", true)
			end
		elseif sprhhn:IsPlaying("Throw") then
			if sprhhn:GetFrame() == 13 then
				enemy.DepthOffset = 0
				enemy:PlaySound(252, 1, 0, false, 1)
				local bboil = Isaac.Spawn(552, 298, 0, enemy.Position, Vector.FromAngle((ppos-enemy.Position):GetAngleDegrees()):Resized(8), enemy)
				bboil.PositionOffset = Vector(0,-57)
				bboil:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end

		if sprhhn:IsFinished("Convex Punch") or sprhhn:IsFinished("Throw") then
			enemy.State = 3
			enemy.StateFrame = math.random(170,250)

			if enemy.Parent:ToNPC().State ~= 350 then
				pardata.handatck = false
			end

			enemy.DepthOffset = -50
			enemy.EntityCollisionClass = 0
		end
	elseif enemy.State == 9 then
		if sprhhn:IsPlaying("Become Convex") then
			if sprhhn:GetFrame() == 33 then
				enemy.DepthOffset = 0

				for k, v in pairs(Entities) do
					if v:IsEnemy() and not v:IsBoss() and v.Position:Distance(enemy.Position) <= enemy.Size * 1.1 and v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
						data.caughtenemy = v
						v.Position = enemy.Position
						v.PositionOffset = Vector(0, -52)
						v.Velocity = Vector(0,0)
						v.EntityCollisionClass = 0
						v:GetSprite().PlaybackSpeed = 0
					end
				end
			end
		elseif sprhhn:IsPlaying("Stomp") then
			if sprhhn:IsEventTriggered("Stomp") then
				enemy:PlaySound(48, 1, 0, false, 1)
				enemy.I1 = enemy.I1 + 1
				data.shkwangle = ((enemy.Variant == 0 and -(enemy.I1 - 1) or (enemy.I1 + 1)) * 45) % 135
				data.shkwpos = Vector(45, 0):Rotated(data.shkwangle + 45)

				for i=data.shkwangle, data.shkwangle+90, 10 do
					local Swave = Isaac.Spawn(1000, 61, 1, enemy.Position+data.shkwpos, Vector.FromAngle(i):Resized(8), enemy):ToEffect()
					Swave.Parent = enemy
					Swave.Timeout = 20
					Swave:SetRadii(6,6)
				end
			end
		end

		if data.caughtenemy then
			HMBPENTS.EnemyStopMove(data.caughtenemy)

			if sprhhn:GetFrame() == 34 then
				data.caughtenemy.PositionOffset = Vector(0, -60)
			end
		end

		if sprhhn:IsFinished("Become Convex") then
			if data.caughtenemy then
				sprhhn:Play("Mangle", true)
			else
				sprhhn:Play("Stomp", true)
				enemy.I1 = 0
			end
		elseif sprhhn:IsFinished("Stomp") or sprhhn:IsFinished("Mangle") then
			if data.caughtenemy then
				data.caughtenemy = nil
			end
			enemy.State = 3
			enemy.StateFrame = math.random(170,250)
			enemy.I1 = 0
			if enemy.Parent:ToNPC().State ~= 350 then
				pardata.handatck = false
			end
			enemy.DepthOffset = -50
		end
    end

	if data.caughtenemy then
		HMBPENTS.EnemyStopMove(data.caughtenemy)
		if sprhhn:IsPlaying("Mangle") then
			if sprhhn:GetFrame() == 2 then
				data.caughtenemy.Visible = false
				data.caughtenemy.PositionOffset = Vector(0, -40)
			elseif sprhhn:GetFrame() == 30 then
				enemy:PlaySound(462, 0.8, 0, false, 1)
				data.caughtenemy:Kill()
			end
		end
		if enemy:IsDead() or not enemy:Exists() then
			data.caughtenemy.PositionOffset = Vector(0, 0)
			data.caughtenemy.Velocity = Vector.FromAngle(enemy.Velocity:GetAngleDegrees()):Resized(10)
			data.caughtenemy.Visible = true
			data.caughtenemy.EntityCollisionClass = 4
			data.caughtenemy:GetSprite().PlaybackSpeed = 1
			data.caughtenemy = nil
		end
	end

	if enemy.Parent:GetSprite():IsPlaying("Hurt") then
		enemy.State = 17
		sprhhn:Play("Hurt", true)
		enemy.DepthOffset = 0
		pardata.handatck = false
	else
		if enemy.Parent:IsDead() then
			enemy:Kill()
			enemy.DepthOffset = 0
		end
	end

	if sprhhn:IsEventTriggered("Convex") then
		enemy:PlaySound(314, 1, 0, false, 1)
		if sprhhn:IsPlaying("Become Convex") then
			enemy.EntityCollisionClass = 2
		else
			enemy.EntityCollisionClass = 4
		end
	elseif sprhhn:IsEventTriggered("Concave") then
		enemy:PlaySound(314, 1, 0, false, 1)
		enemy.EntityCollisionClass = 0
	end

	if enemy:IsDead() then
		pardata.handatck = false
	end

end, 506)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant > 1 then return end

	HMBPENTS.NoDlrForm(enemy)
end, 506)

----------------------------
--New Enemy:Hush's BloodVessel
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, vessel)
  if vessel.Variant ~= Isaac.GetEntityVariantByName("Hush's BloodVessel") then return end

  	local sprvsl = vessel:GetSprite()
	local rng = vessel:GetDropRNG()
	local data = vessel:GetData()
	local path = vessel.Pathfinder
	vessel.Velocity = Vector(0,0)

	if ((sprvsl:IsPlaying("Swelling") or sprvsl:IsPlaying("Subsides1")
	or sprvsl:IsPlaying("Subsides2")) and sprvsl:GetFrame() < 16)
	or sprvsl:IsPlaying("Swell") or sprvsl:IsPlaying("SwellLoop")
	or sprvsl:IsPlaying("Burst") or sprvsl:IsPlaying("BurstLoop") then
		vessel.DepthOffset = 0
	else
		vessel.DepthOffset = -100
	end

	data.height = math.random(15,50)

	if sprvsl:IsFinished("Appear") then
		if vessel.SubType >= 3 then
			sprvsl:ReplaceSpritesheet(0, "gfx/effects/bloodvessel_hush3.png")
			sprvsl:LoadGraphics()
		elseif vessel.SubType == 2 then
			sprvsl:ReplaceSpritesheet(0, "gfx/effects/bloodvessel_hush2.png")
			sprvsl:LoadGraphics()
		elseif vessel.SubType == 1 then
			vessel.FlipX = true
		end
		sprvsl:Play("Swelling", true)
	elseif sprvsl:IsFinished("Swell") then
		sprvsl:Play("SwellLoop", true)
	elseif sprvsl:IsFinished("Burst") then
		sprvsl:Play("BurstLoop", true)
	end

	if vessel.FrameCount == 16 then
		vessel.EntityCollisionClass = 1
	elseif vessel.FrameCount == 65 then
		sprvsl:Play("Swell", true)
	end

	if sprvsl:IsFinished("Subsides1") or sprvsl:IsFinished("Subsides2") then
		vessel.EntityCollisionClass = 0
	end

	if vessel.StateFrame >= 400 then
		vessel.State = 12
	end

	if vessel.SpawnerEntity then
		local spawner = vessel.SpawnerEntity:ToNPC()
		if vessel.State ~= 12 then
			if spawner.StateFrame >= 191
			and sprvsl:IsPlaying("SwellLoop") then
				sprvsl:Play("Burst", true)
				vessel:PlaySound(211, 1, 0, false, 1)
				vessel:PlaySound(52, 1.5, 0, false, 1)
				Game():ShakeScreen(30)
				local expl = Isaac.Spawn(1000, 2, 0, vessel.Position, Vector(0,0), vessel)
				expl.SpriteOffset = Vector(0,-24)
			end
			if sprvsl:IsPlaying("BurstLoop") then
				if spawner.StateFrame >= 401 then
					sprvsl:Play("Subsides1", true)
					vessel.StateFrame = math.random(800,1000)
				end
			end
			if (sprvsl:IsPlaying("Burst") or sprvsl:IsPlaying("BurstLoop")) then
				if vessel.FrameCount % 2 == 0 and spawner.StateFrame <= 381 then
					local params = ProjectileParams()
					params.HeightModifier = -4
					params.FallingSpeedModifier = -data.height * 1.2
					params.FallingAccelModifier = 1
					params.Scale = math.random(10,15) * 0.1
					vessel:FireProjectiles(vessel.Position,
					Vector.FromAngle(rng:RandomInt(359)):Resized(10 - (data.height * 0.2)), 0, params)
				end
				if vessel.FrameCount % 40 == 0 and spawner.StateFrame <= 321 then
					EntityNPC.ThrowSpider(vessel.Position, vessel,
					vessel.Position + Vector.FromAngle(rng:RandomInt(359)):Resized(100 - (data.height * 0.2)), false, -data.height)
				end
			end
		else
			vessel.StateFrame = vessel.StateFrame - 1
			if vessel.StateFrame <= 0 and spawner.State ~= 350 and (sprvsl:IsFinished("Subsides1") or sprvsl:IsFinished("Summon"))
			and vessel.SpawnerEntity.Position:Distance(vessel.Position) > 110 and #Isaac.FindByType(85, Isaac.GetEntityVariantByName("Hush Spider"), -1, true, true) < 10 then
				sprvsl:Play("Summon", true)
			end
			if sprvsl:IsPlaying("Summon") and sprvsl:GetFrame() == 70 then
				if not spawner:GetSprite():IsPlaying("Death") and spawner.Position:Distance(vessel.Position) > 110
				and #Isaac.FindByType(85, Isaac.GetEntityVariantByName("Hush Spider"), -1, true, true) < 10 then
					Isaac.Spawn(85, Isaac.GetEntityVariantByName("Hush Spider"), 0, vessel.Position, Vector(0,0), vessel)
					vessel:PlaySound(181, 1, 0, false, 1)
				end
				vessel.StateFrame = math.random(800,1000)
			end
		end
	else
		if sprvsl:IsPlaying("Swell") or sprvsl:IsPlaying("SwellLoop") then
			sprvsl:Play("Subsides2", true)
		elseif sprvsl:IsPlaying("BurstLoop") then
			sprvsl:Play("Subsides1", true)
		end

		if sprvsl:IsFinished("Subsides1") or sprvsl:IsFinished("Subsides2")
		or sprvsl:IsFinished("Summon") then
			vessel:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
		end
	end
end, 608)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, vessel)
	if vessel.Variant ~= Isaac.GetEntityVariantByName("Hush's BloodVessel") then return end

	vessel:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	vessel:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	vessel:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	vessel:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	vessel:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	vessel:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
	vessel.EntityCollisionClass = 0
end, 608)

----------------------------
--New Enemy:Lamb Stomp
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, object)
  if object.Variant ~= Isaac.GetEntityVariantByName("Lamb Stomp") then return end

  	local sprlf = object:GetSprite()
	object.Velocity = object.Velocity * 0.8

	object.GridCollisionClass = 3

	if object.FrameCount == 1 then
		object.State = 8
		if object.SubType < 2 then
			local Div = REPENTANCE and 255 or 1

			local mark = Isaac.Spawn(1000, 764, 0, object.Position, Vector(0,0), object)
			mark:SetColor(Color(1, 1, 1, 1, 200 / Div, 50 / Div, 240 / Div), 99999, 0, false, false)
		else
			sprlf:PlayOverlay("Mark", true)
		end
		if object.SubType ~= 1 then
			sprlf:Play("Stomp", true)
		end
		if object.I1 < 50 then
			object.I1 = 125
		end
	elseif object.FrameCount == 15 and object.SubType == 1 then
		sprlf:Play("Stomp", true)
	end

	if object.SubType == 2 and sprlf:GetFrame() < 28 then
		object:AddVelocity(Vector.FromAngle((Game():GetNearestPlayer(object.Position).Position-object.Position):GetAngleDegrees()):Resized(1.1))
	end

	if object.FrameCount > 15 and sprlf:IsFinished("Stomp") then
		object:Remove()
	end

	if sprlf:GetFrame() == 30 then
		local Div = REPENTANCE and 255 or 1

		sprlf:RemoveOverlay()
		object:PlaySound(52, 1.5, 0, false, 1)
		Game():BombDamage(object.Position, 40, 75, true, object, 0, 1<<2, true)
		Game():SpawnParticles(object.Position, 88, 10, 20, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
		local wave = Isaac.Spawn(1000, 61, 0, object.Position, Vector(0,0), object):ToEffect()
		wave.Parent = object
		wave.Timeout = 16
		wave.MaxRadius = object.I1
		Game():ShakeScreen(20)
	end

	if sprlf:GetFrame() >= 30 and sprlf:GetFrame() <= 55 then
		object.EntityCollisionClass = 1
	else
		object.EntityCollisionClass = 0
	end

end, 507)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, object)
	if object.Variant ~= Isaac.GetEntityVariantByName("Lamb Stomp") then return end

	object:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	object:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	object:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	object:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	object:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
	object.EntityCollisionClass = 0
end, 507)

----------------------------
--New Entity:Big Knife
----------------------------
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, knife)
  if knife.Variant ~= Isaac.GetEntityVariantByName("Big Knife") then return end

  	local sprkf = knife:GetSprite()
	local data = knife:GetData()
	local path = knife.Pathfinder
	local Entities = Isaac:GetRoomEntities()
	local Room = Game():GetRoom()
	knife:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	knife:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
	knife:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	knife:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	knife:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	path:FindGridPath(knife.Position, 0, 900, false)

	if knife.FrameCount <= 1 and sprkf:IsFinished("Falling") then
		sprkf:Play("Falling", true)
		knife.State = 8
		if knife.Position.X <= Room:GetCenterPos().X then
			knife.FlipX = true
		end
	end

	if knife.SubType == 1 and knife.FrameCount <= 1 then
		local mark = Isaac.Spawn(1000, 764, 0, knife.Position, Vector(0,0), knife)
		mark:SetColor(Color(1, 1, 1, 1, 155 / (REPENTANCE and 255 or 1), 0, 0), 99999, 0, false, false)
	end

	if sprkf:GetFrame() < 20 then
		knife.EntityCollisionClass = 0
	else
		knife.EntityCollisionClass = 4
		knife.CollisionDamage = 1
	end

	if sprkf:GetFrame() == 20 then
		if denpnapi then
			SpawnGroundParticle(false, knife, 8, 6, 1, 0)
		else
			if Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 13 then
				knife:PlaySound(77, 1, 0, false, 1)
			else
				knife:PlaySound(138, 1, 0, false, 1)
			end
		end
		Game():BombDamage(knife.Position, 40, 10, false, knife, 0, 1<<7, false)
	end

	for k, v in pairs(Entities) do
		if v:IsVulnerableEnemy() and v.Type ~= 70 and v.Variant ~= 70
		and knife.FrameCount > 20 then
			if v.Position:Distance(knife.Position) <= knife.Size + v.Size then
				v:TakeDamage(1.5, 0, EntityRef(knife), 1)
			end
		end
		if v:IsBoss() and v.Size >= 20
		and v.Position:Distance(knife.Position) <= knife.Size + v.Size
		and knife.EntityCollisionClass == 4 and v.EntityCollisionClass >= 3 then
			knife:Kill()
		end
	end

end, 70)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, knife)
	if knife.Variant ~= Isaac.GetEntityVariantByName("Big Knife") then return end

	knife.EntityCollisionClass = 0
end, 70)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, knife)
	if knife.Variant ~= Isaac.GetEntityVariantByName("Big Knife") then return end

	knife:PlaySound(138, 1, 0, false, 1)
	Isaac.Spawn(1000, 97, 0, knife.Position, Vector(0,0), knife)
	Game():SpawnParticles(knife.Position, 27, 10, 3, Color(1, 1, 1, 1, 0, 0, 0), -80)
	Game():SpawnParticles(knife.Position, 35, 20, 6, Color(0.7, 0.7, 0.7, 1, 0, 0, 0), -8)
end, 70)
