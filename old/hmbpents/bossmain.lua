local snd = SFXManager()
local Level = Game():GetLevel()
local music = MusicManager()

----------------------------
--Mom (Hard)
----------------------------
  function HMBPENTS:HardMom(mom)

	if mom.Variant == 0 then

	local sprm = mom:GetSprite()
	local target = mom:GetPlayerTarget()
	local player = Game():GetNearestPlayer(mom.Position)
	local Entities = Isaac:GetRoomEntities()
	local data = mom:GetData()
	mom:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	mom:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	mom.DepthOffset = -30

	mom.Velocity = Vector.FromAngle((mom.TargetPosition-mom.Position):GetAngleDegrees())
	:Resized(mom.TargetPosition:Distance(mom.Position)*0.1)

	if not data.init then
		data.init = true
		data.eyeHp = 15
		data.hurt = false
		data.doorbroken = false
		data.handpos = Vector(0,0)
		if mom.SubType > 10 then
			data.numspider = 2
		else
			data.numspider = 1
		end
		mom.I1 = 0
		mom.ProjectileCooldown = math.random(35,250)
	end

	if not data.spawnpos then
		data.spawnpos = mom.Position+Vector.FromAngle(sprm.Rotation+90):Resized(60)
	end

	if mom.StateFrame > 0 and mom.State ~= 10 then
		mom.StateFrame = mom.StateFrame - 1
	end

	if mom.ProjectileCooldown > 0 then
		mom.ProjectileCooldown = mom.ProjectileCooldown - 1
	end

	if mom.State == 3 and mom.FrameCount >= 100 and not MomStomping then
		if mom.StateFrame <= 40 then
			if math.abs(mom.Position.X-player.Position.X) <= 10 and math.abs(mom.Position.Y-player.Position.Y) <= 35
			and data.doorbroken and player:GetDamageCooldown() <= 0 then
				data.cplayer = player
				mom.I2 = 0
				sprm:SetFrame("Damaging", 50)
				data.cplayer.Velocity = Vector(0,0)
				if data.cplayer.Variant == 0 then
					if denpnapi then
						if sprm.Rotation == -90 then
							data.cplayer:GetData().playmodanim = 2
						elseif sprm.Rotation == 90 then
							data.cplayer:GetData().playmodanim = 3
						end
					else
						Isaac.Spawn(1000, 15, 0, data.cplayer.Position, Vector(0,0), data.cplayer)
						data.cplayer.Visible = false
					end
				else
					Isaac.Spawn(1000, 15, 0, data.cplayer.Position, Vector(0,0), data.cplayer)
					data.cplayer.Visible = false
				end
				data.cplayer.ControlsEnabled = true
				mom.StateFrame = 50
				mom.State = 32
				data.cplayer.EntityCollisionClass = 0
				HMBPMom_Hand = HMBPMom_Hand + 1
			end

			if math.abs(mom.Position.X-player.Position.X) <= 140 and math.abs(mom.Position.Y-player.Position.Y) <= 35
			and math.random(1,50) == 1 and data.doorbroken then
				sprm:Play("Grab", true)
				HMBPMom_Hand = HMBPMom_Hand + 1
				mom.State = 29
				mom:SetSize(35,Vector(1,1),0)
			end

			if not data.doorbroken and player.Position:Distance(mom.Position) <= 35 + player.Size and  HMBPMom_Hand < 2 then
				mom.State = 11
				sprm:Play("ArmOpen", true)
				HMBPMom_Hand = HMBPMom_Hand + 1
			end
		end
		if mom.StateFrame <= 0 then
			if math.random(1,4) == 1 then
				if HMBPMom_Eye < 2 then
					mom.State = 8
					if mom.SubType > 10 then
						sprm:Play("EyeAttackEternal", true)
					else
						sprm:Play("EyeAttack", true)
					end
					HMBPMom_Eye = HMBPMom_Eye + 1
				end
			elseif math.random(1,4) == 2 then
				if not HMBPMom_Wig then
					HMBPMom_Wig = true
					mom.State = 10
					sprm:Play("Wig", true)
				end
			elseif math.random(1,4) == 3 then
				if mom:GetAliveEnemyCount() <= 7 and mom.I1 ~= 1 and mom.SubType < 2 then
					mom.State = 9
					sprm:Play("Fat0"..math.random(1,2), true)
				end
			else
				for k, v in pairs(Entities) do
					if v.Type == 396 and v:GetData().doorbroken and v:ToNPC().State <= 3
					and v:ToNPC().StateFrame > 40 and v ~= mom then
						if data.doorbroken and HMBPMom_Hand < 1 then
							mom.State = 30
							sprm:Play("KnifeThrow", true)
							HMBPMom_Hand = HMBPMom_Hand + 1
						end
					end
				end
			end
		end
	end

	if mom.I1 == 2 and not data.doorbroken and math.abs(sprm.Rotation) == 90 then
		HMBPMom_Hand = HMBPMom_Hand + 1
		data.doorbroken = true
		sprm:Load("gfx/Mom_hardmode_doorbroken.anm2", true)
		if mom.SubType > 10 then
			for i=0, 1 do
				sprm:ReplaceSpritesheet(i, "gfx/bosses/classic/boss_mom_eternal.png")
			end
			sprm:LoadGraphics()
		end
		sprm:Play("DoorBreak", true)
		mom.State = 25
		mom.EntityCollisionClass = 0
		data.numspider = data.numspider + 1
		mom.CollisionDamage = 2
	end

	for k, v in pairs(Entities) do
		if v.Type == 396 then
			if v.Variant == 10 then
				if mom.HitPoints > v.HitPoints then
					mom.HitPoints = v.HitPoints
				end
				if mom.I1 == 3 then
					mom:Remove()
					v:Kill()
				end
			end
		end
	end

	if mom.HitPoints <= 0 or mom:IsDead() then
		mom.I1 = 3
		mom:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
		if mom:IsDead() then
			mom.HitPoints = 0
		end
	end

	if mom.HitPoints/mom.MaxHitPoints <= 0.5 and mom.I1 == 0 then
		if sprm:IsPlaying("EyeAttack") or sprm:IsPlaying("EyeAttackEternal") or sprm:IsPlaying("EyeHurt") then
			sprm:Play("EyeClose", true)
			HMBPMom_Eye = 0
		elseif sprm:IsPlaying("Fat01") then
			sprm:Play("Fat01Close", true)
		elseif sprm:IsPlaying("Fat02") then
			sprm:Play("Fat02Close", true)
		elseif sprm:IsPlaying("ArmOpen") then
			sprm:Play("ArmClose", true)
			HMBPMom_Hand = 0
		end
		if mom.State == 10 then
			sprm:Play("WigClose", true)
			HMBPMom_Wig = false
		end
		mom.I1 = 1
		mom.CollisionDamage = 0
		for k, v in pairs(Entities) do
			if v:IsEnemy() and not v:IsBoss() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				v:Kill()
			end
		end
	end

	if mom.I1 == 1 then
		mom.State = 15
	end

	if mom.State == 15 then
		if mom.I1 == 2 then
			mom.State = 3
			mom.CollisionDamage = 2
			mom.StateFrame = 80
		end
	elseif mom.State == 9 then
		if (not data.doorbroken and sprm:IsEventTriggered("Open"))
		or (data.doorbroken and sprm:IsEventTriggered("Close")) then
			mom:PlaySound(265 , 1, 0, false, 1)
			if mom.SubType == 1 then
				if math.random(1,7) == 1 then
					Isaac.Spawn(24, 2, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 2 then
					Isaac.Spawn(256, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 3 then
					Isaac.Spawn(257, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 4 then
					Isaac.Spawn(258, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 5 then
					Isaac.Spawn(279, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 6 then
					Isaac.Spawn(280, 0, 0, data.spawnpos, Vector(0,0), mom)
				else
					Isaac.Spawn(284, 0, 0, data.spawnpos, Vector(0,0), mom)
				end
			else
				if math.random(1,7) == 1 then
					Isaac.Spawn(208, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 2 then
					Isaac.Spawn(214, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 3 then
					Isaac.Spawn(215, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 4 then
					Isaac.Spawn(217, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 5 then
					Isaac.Spawn(220, 0, 0, data.spawnpos, Vector(0,0), mom)
				elseif math.random(1,7) == 6 then
					Isaac.Spawn(227, 0, 0, data.spawnpos, Vector(0,0), mom)
				else
					Isaac.Spawn(244, 0, 0, data.spawnpos, Vector(0,0), mom)
				end
			end
		end
	elseif mom.State == 8 then
		if sprm:IsPlaying("EyeAttack") then
			if data.eyeHp <= 0 then
				sprm:Play("EyeHurt", true)
				data.eyeHp = 15
				mom:PlaySound(97, 1, 0, false, 1)
			end
		end
		if sprm:IsEventTriggered("Shoot") then
			for i=-15, 15, 30 do
				EntityLaser.ShootAngle(1, mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(16) + Vector(0,1), sprm.Rotation + 90 + i, 27, Vector(0,-5), mom)
			end
		end
		if sprm:IsPlaying("EyeHurt") and sprm:GetFrame() == 38 then
			local ShootAngle = mom.SubType == 2 and (target.Position - mom.Position):GetAngleDegrees() or (sprm.Rotation + 90)

			if HMBPEPTTN then
				local params = HMBPEnts.ProjParams()
				params.Height = 20
				params.FallingSpeedModifier = -math.random(25,75) * 0.1
				params.FallingAccelModifier = 0.5

				for i=0, math.random(6, 10) do
					if math.random(1, 3) == 1 and i >= 5 then
						params.Scale = 1.65
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.LEAVES_ACID
					else
						params.Scale = 0.7 + math.random(0, 2) * 0.3
						params.HMBPBulletFlags = 0
					end

					HMBPEnts.FireProjectile(mom, mom.SubType == 2 and 4 or 0, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
					Vector(math.random(45, 120) * 0.1, 0):Rotated(ShootAngle  + math.random(-30, 30)), params)
				end
			else
				local params = ProjectileParams()
				params.Height = 20
				params.FallingSpeedModifier = -math.random(25,75) * 0.1
				params.FallingAccelModifier = 0.5

				for i=0, math.random(8, 14) do
					params.Scale = 0.7 + math.random(0, 3) * 0.3
					params.Variant = mom.SubType == 2 and 4 or 0

					HMBPEnts.FireProjectile(mom, mom.Position + Vector.FromAngle(sprm.Rotation + 90):Resized(6),
					Vector(math.random(45, 120) * 0.1, 0):Rotated(ShootAngle  + math.random(-30, 30)), 0, params)
				end
			end

			mom:PlaySound(153, 1, 0, false, 1)
		end
		if sprm:IsFinished("EyeAttack") or sprm:IsFinished("EyeAttackEternal") or sprm:IsFinished("EyeHurt") then
			HMBPMom_Eye = HMBPMom_Eye - 1
			mom.State = 3
			mom.StateFrame = math.random(35,200)
		end
	end

	if mom.State ~= 3 then
		if sprm:IsFinished("Fat01") or sprm:IsFinished("Fat02")
		or sprm:IsFinished("KnifeThrow") then
			mom.State = 3
			mom.StateFrame = math.random(35,200)
			if sprm:IsFinished("KnifeThrow") then
				HMBPMom_Hand = HMBPMom_Hand - 1
			end
		end
	elseif mom.State ~= 30 or mom.State ~= 15 then
		mom.CollisionDamage = 2
	end

	if sprm:IsEventTriggered("Open") then
		mom.EntityCollisionClass = 4
	elseif sprm:IsEventTriggered("Close") then
		mom.EntityCollisionClass = 0
	end

	if mom.State == 10 then
		mom.StateFrame = mom.StateFrame + 1
		mom.CollisionDamage = 0
		if mom.StateFrame >= 139 and not sprm:IsPlaying("WigClose")
		and not sprm:IsFinished("WigClose") then
			sprm:Play("WigClose", true)
		end
		if sprm:IsFinished("WigClose") then
			mom.State = 3
			HMBPMom_Wig = false
			mom.StateFrame = 50
			mom.CollisionDamage = 2
		end
	elseif mom.State == 11 then
		if sprm:IsPlaying("ArmOpen") then
			if sprm:GetFrame() == 7 then
				mom:PlaySound(48, 1, 0, false, 1)
			end
		else
			mom.State = 3
			mom.StateFrame = 50
			HMBPMom_Hand = HMBPMom_Hand - 1
			mom.StateFrame = math.random(35,250)
		end
	end

	if data.doorbroken then
		if mom.State == 10 then
			mom:SetSize(35,Vector(1.25,1.25),0)
		end
		if sprm:IsPlaying("Fat01") or sprm:IsPlaying("Fat02") then
			mom:SetSize(35,Vector(1.25,1),0)
			if sprm:IsEventTriggered("Open") then
				mom:PlaySound(48, 1, 0, false, 1)
				Game():ShakeScreen(8)
				local wave = Isaac.Spawn(1000, 61, 0, mom.Position, Vector(0,0), mom):ToEffect()
				wave.Parent = mom
				wave.MaxRadius = 70
			end
		end
		if sprm:IsPlaying("EyeAttack") or sprm:IsPlaying("EyeAttackEternal") then
			mom:SetSize(35,Vector(1,0.2),0)
		end
	end
	if mom.State == 32 then
		if data.cplayer then
			data.cplayer.ControlsEnabled = false
			data.cplayer.Position = mom.Position
			if mom.StateFrame <= 0 and sprm:IsFinished("Damaging") then
				if mom.I2 >= 5 then
					data.cplayer.Position = mom.Position
					data.cplayer.Velocity = Vector.FromAngle(sprm.Rotation+90+math.random(-15,15))
					:Resized(math.random(12,15))
					data.cplayer.EntityCollisionClass = 4
					data.cplayer:TakeDamage(1, 0, EntityRef(mom), 5)
					data.cplayer:SetColor(Color(1,1,1,1,0,0,0), 99999, 0, false, false)
					data.cplayer.Visible = true
					data.cplayer.ControlsEnabled = true
					HMBPMom_Hand = HMBPMom_Hand - 1
					mom.State = 3
					mom.StateFrame = 50
					data.catch = false
				else
					sprm:Play("Damaging", true)
					mom:PlaySound(28, 0.6, 0, false, 1)
					mom.I2 = mom.I2 + 1
				end
			end
			if mom:IsDead() then
				data.cplayer.Velocity = Vector.FromAngle(sprm.Rotation+90+math.random(-15,15))
				:Resized(math.random(12,15))
				data.cplayer.Visible = true
				data.cplayer:SetColor(Color(1,1,1,1,0,0,0), 99999, 0, false, false)
				data.cplayer.EntityCollisionClass = 4
				data.cplayer.ControlsEnabled = true
			end
		else
			mom.State = 3
			mom.StateFrame = math.random(35,250)
		end
	elseif mom.State == 30 then
		if sprm:GetFrame() == 20 then
			mom:PlaySound(252, 1, 0, false, 1)
			local params = ProjectileParams()
			params.HeightModifier = 28
			params.FallingAccelModifier = -0.19
			params.Variant = Isaac.GetEntityVariantByName("Knife Projectile")
			params.HeightModifier = 13
			mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(70),
			Vector.FromAngle(sprm.Rotation+90):Resized(30), 0, params)
		end
	elseif mom.State == 29 then
		if sprm:GetFrame() >= 22 and sprm:GetFrame() <= 24 then
			mom.CollisionDamage = 0
			if mom.EntityCollisionClass == 4 and data.handpos:Distance(target.Position) <= 35 + target.Size then
				if target:IsVulnerableEnemy() then
					target:Remove()
				elseif target:ToPlayer() and target:ToPlayer():GetDamageCooldown() <= 0 then
					data.catch = true
				end
			end
		else
			mom.CollisionDamage = 2
		end
		if sprm:GetFrame() == 22 then
			mom:PlaySound(252, 0.5, 0, false, 0.6)
			data.handpos = mom.Position
		elseif sprm:GetFrame() == 23 then
			mom:SetSize(35,Vector(1,4),0)
			data.handpos = mom.Position+Vector.FromAngle(sprm.Rotation+90):Resized(105)
		elseif sprm:GetFrame() == 25 then
			mom:PlaySound(48, 0.6, 0, false, 1.25)
		elseif sprm:GetFrame() == 44 then
			mom:SetSize(35,Vector(1,1),0)
		end
		if sprm:IsFinished("Grab") then
			if data.catch then
				data.catch = false
				sprm:Play("Damaging", true)
				mom.State = 32
				mom:PlaySound(28, 0.6, 0, false, 1)
				mom.I2 = 0
			else
				mom.State = 3
				HMBPMom_Hand = HMBPMom_Hand - 1
				mom.StateFrame = math.random(35,250)
			end
		end
		if data.catch and target:ToPlayer() then
			data.cplayer = target:ToPlayer()
			data.cplayer.EntityCollisionClass = 0
			data.cplayer:SetColor(Color(1,1,1,0,0,0,0), 99999, 0, false, false)
			data.cplayer.Visible = false
			data.cplayer.ControlsEnabled = false
			if sprm:GetFrame() >= 32 then
				target.Velocity = Vector.FromAngle((mom.Position-data.cplayer.Position):GetAngleDegrees())
				:Resized(data.cplayer.Position:Distance(mom.Position)*0.1)
			end
		end
	elseif mom.State == 25 then
		if sprm:GetFrame() == 7 then
			mom:PlaySound(52, 1, 0, false, 1)
			Game():ShakeScreen(15)
			Game():BombDamage(mom.Position, 35, 20, false, mom, 0, 1<<2, false)
			for i=0, math.random(5,10) do
				local piece = Isaac.Spawn(1000, 35, 0, mom.Position,
				Vector.FromAngle(sprm.Rotation+90+math.random(-20,20)):Resized(math.random(15,20)), mom):ToEffect()
				piece.m_Height = -math.random(5,35)
				piece:SetColor(Color(0.39,0.31,0.35,1,0,0,0), 99999, 0, false, false)
			end
		elseif sprm:GetFrame() == 39 then
			mom:SetSize(35,Vector(1,4),0)
			Game():BombDamage(mom.Position+Vector.FromAngle(sprm.Rotation+90):Resized(105), 35, 20, false, mom, 0, 1<<2, false)
			mom:PlaySound(137, 1, 0, false, 0.33)
			mom:PlaySound(52, 1.4, 0, false, 1.15)
			Game():ShakeScreen(25)
			for i=0, math.random(10,15) do
				local params = ProjectileParams()
				params.FallingSpeedModifier = -math.random(18,45) * 0.1
				params.FallingAccelModifier = 0.25
				params.HeightModifier = -10
				params.Scale = math.random(5,13) * 0.1
				params.Variant = 999
				mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(9),
				Vector.FromAngle(sprm.Rotation+90+math.random(-60,60)):Resized(math.random(35,140) * 0.1), 0, params)
			end
			for i=0, math.random(10,15) do
				local piece = Isaac.Spawn(1000, 35, 0, mom.Position,
				Vector.FromAngle(sprm.Rotation+90+math.random(-60,60)):Resized(math.random(20,27)), mom):ToEffect()
				piece.m_Height = -math.random(5,35)
				piece:SetColor(Color(0.39,0.31,0.35,1,0,0,0), 99999, 0, false, false)
			end
		elseif sprm:GetFrame() == 62 then
			mom:SetSize(35,Vector(1,1),0)
		end
		if sprm:IsFinished("DoorBreak") then
			mom.State = 3
			HMBPMom_Hand = HMBPMom_Hand - 1
			mom.EntityCollisionClass = 0
			mom.StateFrame = math.random(35,250)
		end
	elseif mom.State == 3 then
		mom.EntityCollisionClass = 0
	end

	if sprm:IsEventTriggered("Tear") then
		local params = ProjectileParams()
		params.HeightModifier = 20
		params.FallingAccelModifier = -0.1
		if mom.SubType ~= 2 then
			params.Variant = 4
			mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
			Vector.FromAngle(sprm.Rotation+90):Resized(10), 1, params)
		else
			mom:FireProjectiles(mom.Position + Vector.FromAngle(sprm.Rotation+90):Resized(6),
			Vector.FromAngle((target.Position - mom.Position):GetAngleDegrees()):Resized(10), 4, params)
		end
		mom:PlaySound(153, 1, 0, false, 1)
	end

	if HMBPMom_Eye and HMBPMom_Eye < 0 then
		HMBPMom_Eye = 0
	end

  end
  end

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, mom)
	if not mom.Variant == Isaac.GetEntityVariantByName("Mom (Hard)") then
	return
	end
		local sprm = mom:GetSprite()
		mom.State = 3
		mom.TargetPosition = mom.Position
		HMBPENTS.NoDlrForm(mom)
  end, 396)

----------------------------
--Mom Stomp(Hard)
----------------------------
function HMBPENTS:HardMomf(mom)

	if mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp (Hard)") then

	local sprmf = mom:GetSprite()
	local target = mom:GetPlayerTarget()
	local player = Isaac.GetPlayer(0)
	local data = mom:GetData()
	local Entities = Isaac:GetRoomEntities()
	local Room = Game():GetRoom()

	mom.Velocity = mom.Velocity * 0.7

	if data.isdelirium then
		if mom.StateFrame > 0 then
			mom.StateFrame = mom.StateFrame - 1
		end
		if mom.State == 0 then
			for i=0, 1 do
				sprmf:ReplaceSpritesheet(i, "gfx/bosses/afterbirthplus/deliriumforms/classic/boss_mom.png")
			end
			sprmf:LoadGraphics()
			mom.State = 3
		elseif mom.State == 3 then
			if mom.StateFrame <= 0 and mom.FrameCount >= 30 then
				mom:PlaySound(252, 1, 0, false, 1)
				if mom.SubType == 2 then
					local knife = Isaac.Spawn(70, 70, 1, Isaac.GetRandomPosition(0), Vector(0,0), mom)
					knife.HitPoints = 30
					knife.MaxHitPoints = 30
				else
					local knife = Isaac.Spawn(70, 70, 0, player.Position, Vector(0,0), mom)
					knife.HitPoints = 30
					knife.MaxHitPoints = 30
				end
				mom.StateFrame = math.random(140,200)
			end
		end
	end

	if not data.phase2 then
		data.phase2 = false
	end

	if mom.HitPoints/mom.MaxHitPoints <= 0.5 and data.phase2 == false and not data.isdelirium then
		data.phase2 = true

		if mom.State == 7 and ((sprmf:IsPlaying("Stomp") and sprmf:GetFrame() >= 27 and sprmf:GetFrame() <= 63)
		or (sprmf:IsPlaying("Stronger Stomp") and sprmf:GetFrame() >= 57 and sprmf:GetFrame() <= 101)) then
			mom.Visible = true
		else
			mom.Visible = false
		end

		sprmf:Play("Hurt", true)
		mom.State = 8
		mom:PlaySound(97, 1, 0, false, 1)
		mom:PlaySound(28, 1, 0, false, 1)
		Room:EmitBloodFromWalls(5,10)
		Game():ShakeScreen(20)
	end

	if mom.FrameCount <= 1 then
		mom:PlaySound(101, 1, 0, false, 1)
	end
	if mom.SubType > 10 then
		if data.isdelirium then
			mom:SetColor(Color(1,1,1,1.5,0,0,0), 99999, 0, false, false)
		else
			for i=0,1 do
				sprmf:ReplaceSpritesheet(i, "gfx/bosses/classic/boss_mom_eternal.png")
			end
			sprmf:LoadGraphics()
		end
	end

	if mom.ProjectileCooldown > 0 then
		mom.ProjectileCooldown = mom.ProjectileCooldown - 1
	end

	if mom.State == 3 then
		MomStomping = false
		if mom.FrameCount == 30 then
			mom.State = 7
			sprmf:Play("Stomp", true)
			--if mom.SubType == 2 then
			--	mom.ProjectileCooldown = math.random(20,45)
			--else
				--if data.isdelirium then
				--	mom.ProjectileCooldown = math.random(60,100)
				--else
				--	mom.ProjectileCooldown = math.random(140,190)
				--end
			--end
			mom:PlaySound(93, 1, 0, false, 1)
		end
		if mom.FrameCount >= 30 and ((mom.SubType ~= 2 and mom.FrameCount % 80 == 0 and mom.ProjectileCooldown <= 0)
		or (mom.SubType == 2 and mom.FrameCount % 40 == 0 and mom.ProjectileCooldown <= 0)) and (not HMBPMom_Eye or HMBPMom_Eye <= 0) and (not HMBPMom_Hand or HMBPMom_Hand <= 0) then
			if mom.SubType == 2 or (mom.SubType ~= 2 and math.random(1,5) >= 4)
			or data.isdelirium then
				mom.State = 7
				if math.random(1,4) > 1 or mom.SubType == 2 then
					mom:PlaySound(93, 1, 0, false, 1)
					if math.random(1,2) == 1 and data.phase2 then
						sprmf:Play("Stomp2",true)
					else
						sprmf:Play("Stomp",true)
					end
					if mom.FrameCount > 30 then
						mom.Position = target.Position
					end
				else
					sprmf:Play("Stronger Stomp",true)
					mom:PlaySound(84, 1, 0, false, 1)
				end
			else
				if not snd:IsPlaying(101) then
					mom:PlaySound(101, 1, 0, false, 1)
				end
			end
			if mom.SubType == 2 then
				if not data.phase2 then
					mom.ProjectileCooldown = math.random(20,45)
				else
					mom.ProjectileCooldown = math.random(10,22)
				end
			else
				if data.isdelirium then
					mom.ProjectileCooldown = 90
				else
					mom.ProjectileCooldown = math.random(75,120)
				end
			end
		end
	elseif mom.State == 7 then
		MomStomping = true
		if sprmf:IsPlaying("Stomp2") then
			if sprmf:GetFrame() == 67 then
				mom:PlaySound(93, 1.3, 0, false, 1.03)
			elseif sprmf:GetFrame() == 69 then
				Game():ShakeScreen(20)
				mom:PlaySound(138, 1, 0, false, 1)
				Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
				player:AnimatePitfallOut()
				player.ControlsEnabled = false
				player.Velocity = player.Velocity * 3
				for i=0, math.random(4,8) do
					Game():SpawnParticles(Isaac.GetRandomPosition(0), 35, 1, 0, Color(0.35,0.35,0.35,1,0,0,0), -1)
				end
			end
		elseif sprmf:IsPlaying("Stronger Stomp") then
			mom.Position = Room:GetCenterPos()
			if sprmf:GetFrame() == 58 then
				local Div = REPENTANCE and 255 or 1

				mom:PlaySound(52, 1, 0, false, 1)
				Game():ShakeScreen(20)
				Game():SpawnParticles(mom.Position, 88, 10, 20, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
				Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
				local shockwave1 = Isaac.Spawn(1000, 61, 0, mom.Position, Vector(0,0), mom):ToEffect()
				shockwave1.Parent = mom
				shockwave1.Timeout = 10
				shockwave1.MaxRadius = 90
				if mom.SubType > 10 then
					for i=20, 335, 45 do
						local shockwave2 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom):ToEffect()
						shockwave2.Parent = mom
						shockwave2.Timeout = 120
						shockwave2:SetRadii(6,6)
					end
				else
					for i=30, 150, 120 do
						for j=0, 1 do
							local shockwave2 = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i+j*180):Resized(8), mom):ToEffect()
							shockwave2.Parent = mom
							shockwave2.Timeout = 120
							shockwave2:SetRadii(6,6)
						end
					end
				end
			end
		end
	elseif mom.State == 8 then
		if sprmf:IsFinished("Hurt") then
			mom.I1 = 5
			mom.Visible = true
			sprmf:Play("Faster Stomp",true)
			mom:PlaySound(93, 1, 0, false, 1)
			mom.Position = target.Position
		end
		if sprmf:IsFinished("Faster Stomp") then
			if mom.I1 > 0 then
				mom.I1 = mom.I1 - 1
				sprmf:Play("Faster Stomp",true)
				mom:PlaySound(93, 1, 0, false, 1)
				mom.Position = target.Position + Vector(target.Velocity.X*30, target.Velocity.Y*30)
			else
				mom.State = 7
				sprmf:Play("Stronger Stomp",true)
				mom:PlaySound(84, 1, 0, false, 1)
			end
		end
	end

	if mom.FrameCount > 30 and mom.State ~= 3 and (sprmf:IsFinished("Stronger Stomp")
	or sprmf:IsFinished("Stomp") or sprmf:IsFinished("Stomp2")) then
		mom.State = 3
		mom.I2 = 2
		for k, v in pairs(Entities) do
			if v.Type == 396 and v.Variant == 0 then
				if v:ToNPC().I1 == 1 and sprmf:IsFinished("Stronger Stomp") then
					v:ToNPC().I1 = 2
				end
				if v:ToNPC().State <= 3 and mom.SubType == 2 and math.random(1,2) == 1 then
					v:ToNPC().StateFrame = 150
				end
			end
		end
	end

	if sprmf:IsEventTriggered("Stomp") then
		mom:PlaySound(52, 1, 0, false, 1)
		Game():ShakeScreen(20)
		Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
		if mom.SubType == 2 then
			local shockwave1 = Isaac.Spawn(1000, 61, 0, mom.Position, Vector(0,0), mom)
			shockwave1.Parent = mom
			shockwave1:ToEffect().MaxRadius = 80
		end
		if mom.SubType > 10 then
			if math.random(1,2) == 1 then
				for i=45, 315, 90 do
					local shockwave = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
					shockwave.Parent = mom
					shockwave:ToEffect().Timeout = 13
					shockwave:ToEffect():SetRadii(6,6)
				end
			else
				for i=0, 270, 90 do
					local shockwave = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
					shockwave.Parent = mom
					shockwave:ToEffect().Timeout = 13
					shockwave:ToEffect():SetRadii(6,6)
				end
			end
		end
	end

	for k, v in pairs(Entities) do
		if v.Type == 396 and v.Variant == 0 and mom.FrameCount >= 1 then
			if mom.HitPoints > v.HitPoints then
				mom.HitPoints = v.HitPoints
			end
		end
	end

	if mom:IsDead() then
		if not data.UsedBible and Room:GetType() == 5 then
			Room:EmitBloodFromWalls(5,10)
			mom:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			music:Fadeout()
			Isaac.Spawn(396, 20, mom.SubType, Room:GetCenterPos()+Vector(-25,-80), Vector(0,0), mom)
		else
			Room:EmitBloodFromWalls(10,20)
			mom:PlaySound(82, 1, 0, false, 1)
		end
	end

	if (sprmf:IsPlaying("Stomp") and sprmf:GetFrame() >= 28 and sprmf:GetFrame() <= 61)
	or (sprmf:IsPlaying("Stronger Stomp") and sprmf:GetFrame() >= 58 and sprmf:GetFrame() <= 101)
	or (sprmf:IsPlaying("Faster Stomp") and sprmf:GetFrame() >= 12 and sprmf:GetFrame() <= 30)
	or (sprmf:IsPlaying("Hurt") and mom.Visible and sprmf:GetFrame() <= 34)
	or (sprmf:IsPlaying("Stomp2") and ((sprmf:GetFrame() >= 28 and sprmf:GetFrame() <= 56)
	or (sprmf:GetFrame() >= 69 and sprmf:GetFrame() <= 97))) then
		mom.EntityCollisionClass = 4
	else
		mom.EntityCollisionClass = 0
	end

	for k, v in pairs(Entities) do
		if (mom.HitPoints <= 0 or mom:IsDead())
		and v.Type == 396 and v.Variant == 0 then
			v:ToNPC().I1 = 3
			mom:PlaySound(141, 1, 0, false, 1)
		end
		if v:IsVulnerableEnemy() or v:IsBoss() then
			if mom:IsDead() then
				v:Kill()
			end
			if sprmf:IsPlaying("Stomp2") and sprmf:GetFrame() == 69
			and not v:IsFlying() and v:IsVulnerableEnemy() then
				if v.Type == 56 or v.Type == 58 or v.Type == 244 or v.Type == 255
				or v.Type == 276 or v.Type == 289 or v.Type == 300 then
					v:AddFreeze(EntityRef(mom),30)
				else
					v:AddVelocity(Vector.FromAngle(v.Velocity:GetAngleDegrees()):Resized(v.Velocity:Length()*2.5))
				end
			end
		end
	end

  end
  end

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, mom)
	if not mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp (Hard)") then
	return
	end
		local sprmf = mom:GetSprite()
		sprmf:SetFrame("Stomp", 75)
		mom.State = 3
  end, 396)

----------------------------
--Mom Stomp(Last Ditch)
----------------------------
function HMBPENTS:MomFLD(mom)

	if mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp (Last Ditch)") then

	local sprmf2 = mom:GetSprite()
	local target = mom:GetPlayerTarget()
	local player = Game():GetNearestPlayer(mom.Position)
	local data = mom:GetData()
	local Entities = Isaac:GetRoomEntities()
	local rng = mom:GetDropRNG()
	local Room = Game():GetRoom()

	if sprmf2.PlaybackSpeed == 0 then
		sprmf2.PlaybackSpeed = 1
	end

	if mom.FrameCount <= 1 then
		mom.TargetPosition = mom.Position
		mom:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
		if not mom.Parent then
			local ldmom = Isaac.Spawn(396, Isaac.GetEntityVariantByName("Mom Stomp (Last Ditch)"), mom.SubType, Room:GetCenterPos()+Vector(25,80), Vector(0,0), mom)
			ldmom:ToNPC().StateFrame = 32
			ldmom.Parent = mom
		else
			mom.Parent.Child = mom
		end
	elseif mom.FrameCount <= 75 then
		mom.EntityCollisionClass = 0
	end

	local angle = (mom.TargetPosition-mom.Position):GetAngleDegrees()
	local dist = mom.TargetPosition:Distance(mom.Position)

	if mom.SubType == 1 then
		mom:SetColor(Color(0.5,0.7,1,1,0,0,0), 99999, 0, false, false)
	elseif mom.SubType == 2 then
		mom:SetColor(Color(1.2,0.7,0.7,1,0,0,0), 99999, 0, false, false)
	elseif mom.SubType > 10 then
		for i=0, 1 do
			sprmf2:ReplaceSpritesheet(i, "gfx/bosses/classic/boss_mom_eternal.png")
		end
		sprmf2:LoadGraphics()
	end

	if mom.FrameCount == 75 then
		sprmf2:Play("Stomp", true)
		if music:GetCurrentMusicID() ~= HMBPEnts.musics.MomLastDitch and Room:GetType() == 5 then
			music:Play(HMBPEnts.musics.MomLastDitch, 0)
			music:UpdateVolume()
		end
		mom:ClearEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
	end

	if sprmf2:IsPlaying("Stomp") and sprmf2:GetFrame() >= 40 and mom.FrameCount >= 75 then
		mom.State = 7
		sprmf2:SetFrame("Stomp", 40)
	end

	if mom.State == 7 then
		mom.StateFrame = mom.StateFrame - 1
		mom.ProjectileCooldown = mom.ProjectileCooldown - 1
		if mom.SubType == 2 then
			sprmf2.PlaybackSpeed = 1.5
		end
		if sprmf2:IsPlaying("Phase2Stomp") then
			if (mom.SubType == 2 and sprmf2:GetFrame() <= 9) or (mom.SubType ~= 2 and sprmf2:GetFrame() <= 12) then
				mom.TargetPosition = target.Position
			end
		else
			if mom.ProjectileCooldown == 0 and math.random(1,5) == 1
			and #Isaac.FindByType(70, 70, -1, true, true) <= 3 then
				mom:PlaySound(252, 1, 0, false, 1)
				local knife = Isaac.Spawn(70, 70, 0, target.Position
				+Vector.FromAngle(rng:RandomInt(359)):Resized(rng:RandomInt(80)), Vector(0,0), boss)
				knife.HitPoints = 30
				knife.MaxHitPoints = 30
			end
			if mom.StateFrame <= 0 then
				mom:PlaySound(93, 1, 0, false, 1)
				sprmf2:Play("Phase2Stomp", true)
				if mom.SubType == 2 then
					mom.ProjectileCooldown = 45
				else
					mom.ProjectileCooldown = 50
				end
				mom.StateFrame = 64
			end
		end
	end

	if mom.SubType == 2 then
		mom.Velocity = Vector.FromAngle(angle):Resized(dist*0.2)
	else
		mom.Velocity = Vector.FromAngle(angle):Resized(dist*0.1)
	end

	if sprmf2:IsEventTriggered("Stomp") then
		mom:PlaySound(52, 1, 0, false, 1)
		Game():ShakeScreen(20)
		Game():BombDamage(mom.Position, 41, 40, false, mom, 0, 1<<2, true)
		mom.TargetPosition = mom.Position
		if mom.SubType > 10 then
			for i=0, 270, 90 do
				local shockwave = Isaac.Spawn(1000, 61, 1, mom.Position, Vector.FromAngle(i):Resized(8), mom)
				shockwave.Parent = mom
				shockwave:ToEffect().Timeout = 13
				shockwave:ToEffect():SetRadii(6,6)
			end
		end
	end

	if (sprmf2:IsPlaying("Stomp") and sprmf2:GetFrame() == 28)
	or (sprmf2:IsPlaying("Phase2Stomp") and sprmf2:GetFrame() == 21) then
		mom.EntityCollisionClass = 4
	elseif (sprmf2:IsPlaying("Stomp") and sprmf2:GetFrame() == 61)
	or (sprmf2:IsPlaying("Phase2Stomp") and sprmf2:GetFrame() == 7) then
		mom.EntityCollisionClass = 0
	end

  end
  end

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, mom)
	if mom.Variant == Isaac.GetEntityVariantByName("Mom Stomp (Last Ditch)") then
		local sprmf2 = mom:GetSprite()
		mom:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		sprmf2:SetFrame("Stomp", 75)
		HMBPENTS.NoDlrForm(mom)
		mom.EntityCollisionClass = 0
	end
  end, 396)

  HMBPENTS:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, mom)
	if mom.Variant == 20 then
		if mom:IsDead() then
			mom:PlaySound(82, 1, 0, false, 1)
			if mom.Parent then
				mom.Parent:Kill()
			end
			if mom.Child then
				Game():GetRoom():EmitBloodFromWalls(10,20)
				mom.Child:Kill()
			end
		end

		if (mom.Child and (mom.Child:HasEntityFlags(1<<5) or mom.Child:HasEntityFlags(1<<10)))
		or (mom.Parent and (mom.Parent:HasEntityFlags(1<<5) or mom.Parent:HasEntityFlags(1<<10))) then
			mom:GetSprite().PlaybackSpeed = 0
			mom.Velocity = Vector(0,0)
			return true
		end
	end
  end, 396)

----------------------------
--Snapped Womb Chapter Major Bosses
----------------------------
local MomHeartVari = Isaac.GetEntityVariantByName("Snapped Mom's Heart")
local ItLivesVari = Isaac.GetEntityVariantByName("Snapped It Lives")
local LivesHeadVari = Isaac.GetEntityVariantByName("It Lives Head")

HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, boss)
	if not (boss.Variant == MomHeartVari or boss.Variant == ItLivesVari) then return end

	local sprite = boss:GetSprite()
	local data = boss:GetData()
	local Target = boss:GetPlayerTarget()
	local rng = boss:GetDropRNG()
	local TAngle = (Target.Position - boss.Position):GetAngleDegrees()
	local HPLeft = boss.HitPoints / boss.MaxHitPoints
	local Room = Game():GetRoom()

	if boss.FrameCount % 5 == 0 then
		boss:MakeSplat(math.random(5, 10) * 0.1)
	end

	if sprite:IsFinished("Appear") or (boss.State < 3 and boss.FrameCount > 2) then
		boss.State = 4 --STATE_MOVE
	end

	if sprite:IsEventTriggered("Heartbeat") then
		Game():ShakeScreen(10)
		boss:PlaySound(323, 1, 0, false, 1) --HEARTBEAT_FASTEST
		boss:PlaySound(72, 0.5, 0, false, 0.21) --MEAT_JUMPS
	end

	if HPLeft <= 1 / 3 and not data.Hurted then
		data.Hurted = true
		sprite:Play("Hurt", true)
		boss.State = 15

		if boss.Variant == MomHeartVari then
			data.MoveDiag = true
			data.MoveDiagStrength = 0.8
		else
			data.MoveDiag = false
		end
	end

	if sprite:IsEventTriggered("Burst") then
		boss:PlaySound(87, 1, 0, false, 1) --MOM_VOX_FILTERED_HURT
		boss.Velocity = Vector(0, 0)

		if boss.Variant == MomHeartVari then
			boss:BloodExplode()
			Isaac.Spawn(1000, 2, 4, boss.Position + Vector(0, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -50) --BLOOD_EXPLOSION
		else
			local HeadSpawnVelAngle = 45 + math.floor(TAngle / 90) * 90

			boss:PlaySound(28, 1, 0, false, 1) --DEATH_BURST_LARGE
			Isaac.Spawn(1000, 2, 4, boss.Position + Vector(0, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -80)
			local Head = Isaac.Spawn(555, LivesHeadVari, 0, boss.Position + Vector(60, 0):Rotated(HeadSpawnVelAngle), Vector(15, 0):Rotated(HeadSpawnVelAngle), boss):ToNPC()
			Head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			Head.State = 9
			Head.StateFrame = 50
			Head:GetSprite():ReplaceSpritesheet(0, "gfx/blank.png")
			Head:GetSprite():LoadGraphics()
			Head:GetSprite():Play("DivideStartRef", true)
			Head:GetData().RotateFrame = 0
			Head.Parent = boss
			Head.EntityCollisionClass = 2
		end
	end

	if data.MoveDiag and data.MoveDiagStrength then
		boss:AddVelocity(Vector(data.MoveDiagStrength, 0):Rotated(45 + math.floor(boss.Velocity:GetAngleDegrees() / 90) * 90))
	end

	if boss.State == 3 or boss.State == 4 then --STATE_IDLE, STATE_MOVE
		local params = ProjectileParams()

		if not (sprite:IsPlaying("Heartbeat") or sprite:IsPlaying("Heartbeat2") or sprite:IsPlaying("Shoot") or sprite:IsPlaying("Jump")) then
			sprite:Play("Heartbeat"..((boss.Variant == ItLivesVari and data.Hurted) and 2 or ""), true)
		end

		if not data.RerolledPattern then
			data.RerolledPattern = true
			data.MoveDiag = true
			data.MoveDiagStrength = (data.Hurted and 1.95 or 1.65) + ((boss.Variant == MomHeartVari and not (boss.SubType == 1 and REPENTANCE)) and 0.1 or 0)
			boss.I1 = data.Hurted and 1 or math.random(0, 1)
			boss.StateFrame = math.random(220, 250)
		end

		boss.Velocity = boss.Velocity * 0.87

		if (HPLeft > 1 / 3 and boss.FrameCount % 4 == 0) or (HPLeft <= 1 / 3 and boss.FrameCount % 3 == 0) then
			local BloodTrail = Isaac.Spawn(1000, 111, 0, boss.Position + Vector(boss.Size, 0):Rotated(math.random(-179, 180)),
			Vector(-3, 0):Rotated(boss.Velocity:GetAngleDegrees()), boss) --HAEMO_TRAIL
			BloodTrail.PositionOffset = Vector(0, -math.random(20, 100))
			BloodTrail.SpriteScale = Vector(1, 1) * (math.random(30, 75) / 100)
		end

		if boss.Variant == ItLivesVari and boss.StateFrame % 100 > 93 and sprite:IsPlaying("Heartbeat") and sprite:GetFrame() == 5 then
			sprite:Play("Shoot", true)
		end

		if sprite:IsEventTriggered("Shoot") then
			boss:PlaySound(25, 1, 0, false, 1) --CUTE_GRUNT
			boss:PlaySound(178, 1, 0, false, 1) --BLOODSHOOT

			params.Scale = 2
			params.FallingAccelModifier = -0.145
			boss:FireProjectiles(boss.Position, Vector(7, 0):Rotated(TAngle), 0, params)

			if REPENTANCE then
				local BExpl = Isaac.Spawn(1000, 2, 5, boss.Position + Vector(0, 1), Vector(0, 0), boss) --BLOOD_EXPLOSION
				BExpl:ToEffect():FollowParent(boss)
				BExpl:GetSprite().Offset = Vector(0, -35)
			end
		end

		if boss:CollidesWithGrid() and boss.Velocity:Length() > 4 then
			boss:PlaySound(48, 1, 0, false, 1) --FORESTBOSS_STOMPS
			boss.Velocity = Vector(boss.Velocity:Length() * 1.5, 0):Rotated(boss.Velocity:GetAngleDegrees())

			for i=0, 270, 90 do
				local CollidedGrid = Room:GetGridEntityFromPos(boss.Position + Vector(45, 0):Rotated(i))

				if CollidedGrid and (CollidedGrid:GetType() == 15 or CollidedGrid:GetType() == 16) then --GRID_WALL or GRID_DOOR
					params.FallingSpeedModifier = 2
					params.FallingAccelModifier = -0.14

					if boss.Variant == MomHeartVari and boss.SubType == 1 and REPENTANCE then
						for j=90, 270, 30 do
							params.Scale = j % 60 == 30 and 1.8 or 1
							boss:FireProjectiles(CollidedGrid.Position - Vector(30, 0):Rotated(i), Vector(j % 60 == 30 and 5 or 4, 0):Rotated(i + j), 0, params)
						end
					else
						params.Scale = 1.8

						for j=90, 270, 60 do
							boss:FireProjectiles(CollidedGrid.Position - Vector(30, 0):Rotated(i), Vector(5, 0):Rotated(i + j), 0, params)
						end
					end

					Game():SpawnParticles(CollidedGrid.Position - Vector(20, 0):Rotated(i), 111, math.random(5, 7), 5, Color(1, 1, 1, 1, 0, 0, 0), 0)

					break
				end
			end
		end

		if boss.StateFrame > 0 then
			boss.StateFrame = boss.StateFrame - 1

			if boss.StateFrame == 20 and not (boss.Variant == MomHeartVari and not data.Hurted and boss.I1 == 1 and not (boss.SubType == 1 and REPENTANCE)) then
				boss:PlaySound(90, 1, 0, false, 1) --MOM_VOX_FILTERED_ISAAC
			end
		else
			if boss.I1 == 0 then
				boss.State = 6 --STATE_JUMP
				data.MoveDiag = false

				if boss.Variant == MomHeartVari and boss.SubType == 1 and REPENTANCE then
					sprite:Play("Jump2", true)
					data.StompStack = 0
				else
					sprite:Play("Jump", true)
				end
			else
				if math.abs(boss.Position.Y - Target.Position.Y) < 50 or (boss.SubType == 1 and REPENTANCE and not data.Hurted) then
					boss.State = 8 --STATE_ATTACK
					boss.I2 = data.Hurted and 1 or 0
					data.MoveDiag = false

					if boss.Variant == ItLivesVari and data.Hurted then
						sprite:Play("Shoot2Ready", true)
					else
						sprite:Play("ChargeReady", true)

						if boss.SubType == 1 and REPENTANCE then
							data.DashReady = true
						end
					end
				end
			end
		end
	else
		data.RerolledPattern = false
	end

	if boss.State == 6 then --STATE_JUMP
		if boss.EntityCollisionClass ~= 0 then
			boss.Velocity = boss.Velocity * 0.87
		end

		if sprite:IsEventTriggered("Jump") then
			boss:PlaySound(72, 1, 0, false, 1) --MEAT_JUMPS
			boss.EntityCollisionClass = 0
			boss.Velocity = Vector(boss.Position:Distance(Target.Position) / 29, 0):Rotated(TAngle)
			data.MoveDiagStrength = 1

			if boss.Variant == ItLivesVari then
				boss:PlaySound(25, 1, 0, false, 1) --CUTE_GRUNT
			end
		elseif sprite:IsEventTriggered("Stomp") then
			boss:PlaySound(52, 1, 0, false, 1) --HELLBOSS_GROUNDPOUND
			boss.Velocity = Vector(0, 0)
			boss.EntityCollisionClass = 4
			Game():ShakeScreen(20)

			if REPENTANCE then
				for i=3, 4 do
					Isaac.Spawn(1000, 16, i, boss.Position + Vector(0, 1), Vector(0, 0), boss) --POOF02(large Blood Poof)
				end
			else
				Isaac.Spawn(1000, 2, 4, boss.Position, Vector(0, 0), boss) --BLOOD_EXPLOSION
			end

			local params = ProjectileParams()
			params.FallingAccelModifier = -0.12

			if REPENTANCE and boss.SubType == 1 then
				data.StompStack = data.StompStack + 1

				for i=1, math.max(1, data.StompStack - 1) do
					local Space = 40 - i * 10
					params.Scale = i == math.max(1, data.StompStack - 1) and 1.8 or 1.5
					params.BulletFlags = 1 << (11 + (i + data.StompStack) % 2) --ORBIT_CW or ORBIT_CCW
					params.TargetPosition = boss.Position

					for j=0, 360 - Space, Space do
						boss:FireProjectiles(boss.Position, Vector(data.StompStack ~= 3 and 6 or (i * 4), 0):Rotated(j), 0, params)
					end
				end
			else
				for i=0, 2 do
					local Start = i == 1 and 12 or 0
					params.Scale = 1 + i / 2

					for j=Start, 336 + Start, 24 do
						boss:FireProjectiles(boss.Position, Vector(3 + i * 3, 0):Rotated(j), 0, params)
					end
				end
			end
		elseif sprite:IsEventTriggered("Move") then
			data.MoveDiag = true
		end

		if sprite:IsFinished("Jump") or sprite:IsFinished("Jump2") then
			boss.State = 4
		end
	elseif boss.State == 8 then --STATE_ATTACK
		if sprite:IsFinished("ChargeReady") or sprite:IsFinished("Shoot2Ready") or sprite:IsFinished("AppearChargeReady") or sprite:IsFinished("Dash") then
			boss:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

			if boss.Variant == MomHeartVari then
				if math.abs(boss.Position.Y - Target.Position.Y) < 50 and not data.Hurted then
					data.DashReady = false
				end

				if not data.Hurted and not (boss.SubType == 1 and REPENTANCE) then
					boss:PlaySound(90, 1, 0, false, 1) --MOM_VOX_FILTERED_ISAAC
				end

				if data.DashReady and boss.I2 < 1 then
					if data.Hurted then
						local CAngle = (Room:GetCenterPos() - boss.Position):GetAngleDegrees(CAngle)
						sprite:Play("DashAndShootReady", true)
						EntityLaser.ShootAngle(1, boss.Position + Vector(35, 0):Rotated(CAngle + 180), CAngle + 180, 3, Vector(0, -50), boss) --Thick Red Laser
						boss.State = 9
					else
						sprite:Play("Dash", true)
						boss.TargetPosition = Target.Position
						boss:PlaySound(213, 1, 0, false, 1) --HEARTOUT
						data.ShootCooldown = 0
					end

					data.DashReady = false
				else
					sprite:Play("Charge", true)
					data.Charging = true
					data.ShootCooldown = 0

					if data.Hurted then
						data.Acceleration = true
						data.ShootLaser = true
						data.MoveY = (boss.SubType == 1 and REPENTANCE) and 1 or 0
					else
						boss.I2 = 0
						data.Acceleration = false
					end
				end
			else
				if sprite:IsFinished("ChargeReady") then
					sprite:Play("ChargeStart"..(Target.Position.X > boss.Position.X and "Right" or "Left"), true)
					boss:PlaySound(313, 1, 0, false, 1) --MULTI_SCREAM
				else
					sprite:Play("Shoot2"..(Room:GetCenterPos().X > boss.Position.X and "Left" or "Right").."Start", true)
					data.ShootLaser = true
					data.MoveY = 1
				end

				data.Acceleration = true
				data.Charging = true
			end

			if data.Acceleration then
				if boss.Variant == ItLivesVari and not data.Hurted then
					data.XDashVel = Target.Position.X > boss.Position.X and 1 or -1
				else
					data.XDashVel = Room:GetCenterPos().X > boss.Position.X and 1.3 or -1.3
				end
			else
				data.XDashVel = Target.Position.X > boss.Position.X and 18 or -18
			end
		end

		if sprite:IsFinished("ChargeStartLeft") or sprite:IsFinished("ChargeStartRight") then
			sprite:Play("ChargeLoop"..(data.XDashVel > 0 and "Right" or "Left"), true)
		end

		if sprite:IsFinished("Shoot2LeftStart") or sprite:IsFinished("Shoot2RightStart") then
			sprite:Play("Shoot2"..(data.XDashVel > 0 and "Left" or "Right").."Loop", true)
		end

		if data.Charging then
			local CollidedColumnGrid = Room:GetGridEntityFromPos(boss.Position + Vector(data.XDashVel > 0 and 45 or -45, 0))

			if data.ShootLaser then
				local Laser = EntityLaser.ShootAngle(1, boss.Position + Vector((data.XDashVel > 0 and -15 or 15) * (boss.Variant == MomHeartVari and 2 or 1), 1),
				data.XDashVel > 0 and 180 or 0, 0, Vector(0, -55), boss) --Thick Red Laser
				boss.Child = Laser
				data.ShootLaser = false
			end

			if data.Acceleration then
				local YVel = Target.Position.Y > boss.Position.Y and 1 or -1
				boss.Velocity = boss.Velocity * 0.97

				if boss.Variant == ItLivesVari and not data.Hurted then
					boss:AddVelocity(Vector(data.XDashVel, 0.4 * YVel))
				else
					boss:AddVelocity(Vector(data.XDashVel, data.MoveY == boss.I2 and (0.3 * YVel) or 0))
				end
			else
				boss.Velocity = Vector(data.XDashVel, boss.Velocity.Y)

				if boss.SubType == 1 and REPENTANCE and not data.Hurted then
					local XVelabs = math.abs(data.XDashVel)
					data.ShootCooldown = data.ShootCooldown - XVelabs

					if data.ShootCooldown <= 0 then
						local params = ProjectileParams()
						params.Scale = 1.8
						params.FallingSpeedModifier = 2
						params.FallingAccelModifier = -0.15
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params.ChangeFlags = 0
						params.ChangeTimeout = 19
						params.Acceleration = 1.15

						for i=-0.5, 0.5 do
							boss:FireProjectiles(boss.Position + Vector(data.ShootCooldown * (boss.Velocity.X > 0 and 1 or -1), 0), Vector(0, i), 0, params)
						end

						data.ShootCooldown = data.ShootCooldown + 80
					end
				end
			end

			if boss:CollidesWithGrid() and CollidedColumnGrid and (CollidedColumnGrid:GetType() == 15 or CollidedColumnGrid:GetType() == 16) then --15 = Wall, 16 = Door
				local VX = data.XDashVel > 0 and 1 or -1
				local params = ProjectileParams()
				params.FallingSpeedModifier = 2
				params.FallingAccelModifier = -0.15

				for i=0, 2 do
					local Space = 30 - i * 7.5
					local Start = i == 1 and (Space / 2) or 0
					params.Scale = 1 + i / 2

					for j=90 + Start, 270 - Start, Space do
						boss:FireProjectiles(CollidedColumnGrid.Position - Vector(30 * VX, 0), Vector((4 + i * 3) * VX, 0):Rotated(j), 0, params)
					end
				end

				if REPENTANCE then
					Isaac.Spawn(1000, 16, 5, boss.Position + Vector(data.XDashVel > 0 and 35 or -35, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -57) --POOF02(Blood Cloud)
				else
					Isaac.Spawn(1000, 2, 4, boss.Position + Vector(data.XDashVel > 0 and 35 or -35, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -57) --BLOOD_EXPLOSION
				end

				if boss.Child and boss.Child:ToLaser() then
					boss.Child:ToLaser().Timeout = 1
				end

				if boss.Variant == ItLivesVari and data.Hurted then
					sprite:Play("Shoot2Collide"..(data.XDashVel > 0 and "Left" or "Right"), true)
				else
					sprite:Play("Collide"..(data.XDashVel > 0 and "Right" or "Left"), true)
				end

				Game():ShakeScreen(20)
				boss:PlaySound(52, 1, 0, false, 1) --HELLBOSS_GROUNDPOUND
				data.Charging = false
				boss.Velocity = Vector(0, 0)
			end
		else
			if sprite:IsPlaying("Dash") then
				boss.Velocity = Vector(0, (boss.TargetPosition.Y - boss.Position.Y) / 4)

				local YVel = boss.Velocity.Y

				while math.abs(YVel) ~= 0 do
					local YVelabs = math.abs(YVel)

					if data.ShootCooldown <= YVelabs then
						YVel = YVel - (YVel > 0 and data.ShootCooldown or -data.ShootCooldown)
						data.ShootCooldown = 60

						local params = ProjectileParams()
						params.Scale = 1.8
						params.FallingSpeedModifier = 2
						params.FallingAccelModifier = -0.15
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params.ChangeFlags = 0
						params.ChangeTimeout = 19
						params.Acceleration = 1.15

						for i=-0.5, 0.5 do
							boss:FireProjectiles(boss.Position - Vector(0, YVel), Vector(i, 0), 0, params)
						end
					else
						data.ShootCooldown = data.ShootCooldown - YVelabs
						YVel = 0
					end
				end
			else
				boss.Velocity = boss.Velocity * 0.8
			end
		end

		if sprite:IsFinished("Shoot2CollideLeft") or sprite:IsFinished("Shoot2CollideRight") or sprite:IsFinished("CollideLeft") or sprite:IsFinished("CollideRight")
		or sprite:IsFinished("CollidesHeadLeft") or sprite:IsFinished("CollidesHeadRight") then
			if boss.I2 < 1 then
				boss.State = 4
				boss:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				boss.Velocity = -boss.Velocity
			else
				boss.I2 = boss.I2 - 1
				sprite:Play(boss.Variant == MomHeartVari and "ChargeReady" or "Shoot2Ready", true)
			end
		end
	elseif boss.State == 9 then --STATE_ATTACK2
		local CAngle = (Room:GetCenterPos() - boss.Position):GetAngleDegrees()

		if sprite:IsPlaying("DashAndShootReady") then
			boss.Velocity = Vector(boss.Position:Distance(Room:GetCenterPos()) / 8, 0):Rotated(CAngle)

			if sprite:GetFrame() == 12 then
				boss.V2 = Vector(TAngle + 180, 0)
				boss.TargetPosition = Room:GetCenterPos() + Vector(80, 0):Rotated(boss.V2.X)

				local LaserWarn = Isaac.Spawn(1000, 198, 0, boss.Position + Vector(30, 0):Rotated(boss.V2.X + 180), Vector(0, 0), E):ToEffect() --Generic Tracer
				LaserWarn.Timeout = 37
				LaserWarn.LifeSpan = 27
				LaserWarn:GetSprite().Scale = Vector(12, 1.2)
				LaserWarn.TargetPosition = Vector.FromAngle(boss.V2.X + 180)
				LaserWarn.Color = Color(0.6, 0, 0, 1, 0, 0, 0)
				LaserWarn.Parent = boss
				LaserWarn.PositionOffset = Vector(0, -55)
				LaserWarn:Update()
			end
		elseif sprite:IsPlaying("Charge") then
			local CTAngle = (Room:GetCenterPos() - Target.Position):GetAngleDegrees()
			local AngleDiff = ((CTAngle - boss.V2.X) % 360) - math.floor(((CTAngle - boss.V2.X) % 360) / 180) * 360

			boss.V2 = Vector(boss.V2.X + boss.V2.Y, (AngleDiff > 0 and 1.5 or -1.5))
			boss.TargetPosition = Room:GetCenterPos() + Vector(80, 0):Rotated(boss.V2.X)
			boss.Velocity = Vector(boss.Position:Distance(boss.TargetPosition) / 8, 0):Rotated((boss.TargetPosition - boss.Position):GetAngleDegrees())

			if boss.Child and boss.Child:ToLaser() then
				local Laser = boss.Child:ToLaser()

				Laser.Position = boss.Position + Vector(boss.Size, 0):Rotated(boss.V2.X + 180)
				Laser.RotationDegrees = boss.V2.X + 180
				Laser.RotationSpd = (((Laser.RotationDegrees - Laser.Angle) % 360) - math.floor(((Laser.RotationDegrees - Laser.Angle) % 360) / 180) * 360) / 2
				Laser.IsActiveRotating = true

				if Laser.FrameCount % 14 == 0 then
					local ShootPos = Vector(math.min(math.max(Room:GetTopLeftPos().X + 15, Laser.EndPoint.X), Room:GetBottomRightPos().X - 15),
					math.min(math.max(Room:GetTopLeftPos().Y + 15, Laser.EndPoint.Y), Room:GetBottomRightPos().Y - 15))

					local params = ProjectileParams()
					params.Scale = 1.8
					params.FallingSpeedModifier = 2
					params.FallingAccelModifier = -0.15

					for i=0, 324, 36 do
						local GridEntIdx = Room:GetGridEntityFromPos(ShootPos + Vector(20, 0):Rotated(i + boss.FrameCount))

						if not GridEntIdx or (GridEntIdx and not (GridEntIdx:GetType() == 15 or GridEntIdx:GetType() == 16)) then --15 = Wall, 16 = Door
							boss:FireProjectiles(ShootPos, Vector(5.5, 0):Rotated(i + boss.FrameCount), 0, params)
						end
					end
				end

				if boss.StateFrame > 0 then
					Laser.Timeout = 2
				end
			end

			if boss.StateFrame > 0 then
				boss.StateFrame = boss.StateFrame - 1
			else
				sprite:Play("Dash", true)
			end
		else
			boss.Velocity = boss.Velocity * 0.8
		end

		if sprite:IsFinished("DashAndShootReady") then
			local SpawnPos = boss.Position + Vector(30, 0):Rotated(boss.TargetPosition:GetAngleDegrees())

			sprite:Play("Charge", true)
			boss.StateFrame = 200
			Isaac.Spawn(1000, 16, 5, SpawnPos, Vector(0, 0), boss).PositionOffset = Vector(0, -55) --POOF02(Blood Cloud)

			local Laser = EntityLaser.ShootAngle(6, SpawnPos, boss.V2.X + 180, 2, Vector(0, -55), boss) --Giant Red Laser
			Laser.Parent = boss
			Laser.DisableFollowParent = true
			boss.Child = Laser
		elseif sprite:IsFinished("Dash") then
			boss.State = 4
			boss:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		end
	elseif boss.State == 15 then --STATE_SPECIAL(2-2 Phase Start)
		boss.Velocity = boss.Velocity * 0.8

		if sprite:IsFinished("Hurt") then
			boss.State = 4
		end
	end

	if boss:IsDead() then
		local Level = Game():GetLevel()

		boss:PlaySound(85, 1, 0, false, 1) --MOM_VOX_FILTERED_DEATH_1

		if boss.SubType == 1 and REPENTANCE and Level:GetStage() == LevelStage.STAGE3_2 and Level:GetStageType() > 3 --Rep Stage
		and Level:GetCurrentRoomIndex() == -10 then
			boss:PlaySound(578, 1, 0, false, 1) --SOUND_GROUND_TREMOR
			Game():SetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED, true)
			Game():ShakeScreen(50)
			MusicManager():Fadeout()
			HMBPEnts.KilledSnappedHeart = true
			Level:ApplyBlueMapEffect()
			Level:ApplyCompassEffect()
			Level:ApplyMapEffect()

			for i=0, 168 do
				Level:GetRoomByIdx(i).Clear = true
			end
		end
	end
end, 555)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, boss)
	if boss.Variant ~= MomHeartVari and boss.Variant ~= ItLivesVari then return end

	local sprite = boss:GetSprite()
	local data = boss:GetData()

	if boss.Variant == ItLivesVari and data.Hurted and sprite:IsPlaying("Death") then
		sprite:Play("Death2", true)
	end

	if sprite:IsEventTriggered("Explosion") and not data.BloodExplosion then
		data.BloodExplosion = true

		for i=0, 360, 360 / 14 do
			local params = ProjectileParams()
			params.Scale = 1.5
			params.FallingSpeedModifier = 2
			params.FallingAccelModifier = -0.15
			boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(5), 0, params)
		end
	end
end, 555)

local LivesHeadRotateScale = {Vector(1.3, 0.7), Vector(1.05, 0.95), Vector(0.8, 1.2), Vector(0.95, 1.05), Vector(1.1, 0.9),
Vector(1.075, 0.925), Vector(0.95, 1.05), Vector(0.99, 1.01), --Start
Vector(1.03, 0.97), Vector(1.025, 0.975), Vector(1.02, 0.98), Vector(1.01, 0.99), Vector(1, 1), Vector(0.99, 1.01), Vector(0.98, 1.02), Vector(0.975, 1.025),
Vector(0.97, 1.03), Vector(0.975, 1.025), Vector(0.98, 1.02), Vector(0.99, 1.01), Vector(1, 1), Vector(1.01, 0.99), Vector(1.02, 0.98), Vector(1.025, 0.975), --Loop
Vector(1, 1), Vector(0.9, 1.1), Vector(0.8, 1.2), Vector(1.05, 0.95) --End
}

--It Lives Head
HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, boss)
  if boss.Variant ~= LivesHeadVari then return end

	local sprite = boss:GetSprite()
	local Target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local TAngle = (Target.Position - boss.Position):GetAngleDegrees()
	local rng = boss:GetDropRNG()
	local Room = Game():GetRoom()

	if sprite:IsFinished("Appear") then
		boss.State = 4
	end

	if boss.State == 4 then --STATE_MOVE
		if not (sprite:IsPlaying("Float") or sprite:IsPlaying("Shoot")) then
			sprite:Play("Float", true)
		end

		if boss.Parent then
			local ParentNPC = boss.Parent:ToNPC()
			local PDist = boss.Position:Distance(ParentNPC.Position)

			boss.TargetPosition = ParentNPC.Position + Vector(100, 0):Rotated(ParentNPC.Velocity:GetAngleDegrees() + 180)
			boss.Velocity = Vector(math.min(PDist / 5, ParentNPC.Velocity:Length()), 0):Rotated((boss.TargetPosition - boss.Position):GetAngleDegrees())

			if ParentNPC.State == 8 then
				boss.State = 8
			end
		end
	elseif boss.State == 8 then --STATE_ATTACK
		if boss.Parent then
			local ParentNPC = boss.Parent:ToNPC()
			local pspr = ParentNPC:GetSprite()

			if sprite:IsFinished("ShootStart") then
				sprite:Play("ShootLoop", true)
			end

			if not data.Charging then
				boss.Velocity = boss.Velocity * 0.85

				if (pspr:IsPlaying("Shoot2Ready") and pspr:GetFrame() == 1) and ParentNPC.I2 < 1 then
					sprite:Play("ShootStart", true)
				end

				if sprite:IsEventTriggered("Shoot") then
					data.Charging = true
					data.XDashVel = Room:GetCenterPos().X > boss.Position.X and 1.3 or -1.3
					local Laser = EntityLaser.ShootAngle(1, boss.Position + Vector((data.XDashVel > 0 and -35 or 35) * (boss.Variant == MomHeartVari and 2 or 1), 1),
					data.XDashVel > 0 and 180 or 0, 0, Vector(0, -45), boss) --Thick Red Laser
					boss.Child = Laser
					data.ShootLaser = false

					if data.XDashVel < 0 then
						boss.FlipX = false
					else
						boss.FlipX = true
					end
				end

				if sprite:IsFinished("CollidesWall") or sprite:IsFinished("CollidesBody") then
					sprite:Play("Float", true)
					boss.FlipX = false
				end

				if sprite:IsPlaying("Float") and ParentNPC.State == 4 then
					boss.State = 4
				end
			else
				local CollidedColumnGrid = Room:GetGridEntityFromPos(boss.Position + Vector(data.XDashVel > 0 and 40 or -40, 0))
				local YVel = Target.Position.Y > boss.Position.Y and 1 or -1

				boss.Velocity = boss.Velocity * 0.97
				boss:AddVelocity(Vector(data.XDashVel, 0))

				if boss:CollidesWithGrid() and CollidedColumnGrid and (CollidedColumnGrid:GetType() == 15 or CollidedColumnGrid:GetType() == 16) then --15 = Wall, 16 = Door
					local VX = data.XDashVel > 0 and 1 or -1
					local params = ProjectileParams()
					params.FallingSpeedModifier = 2
					params.FallingAccelModifier = -0.15
					params.Scale = 1.8

					for j=90, 270, 18 do
						boss:FireProjectiles(CollidedColumnGrid.Position - Vector(30 * VX, 0), Vector(8 * VX, 0):Rotated(j), 0, params)
					end

					if REPENTANCE then
						Isaac.Spawn(1000, 16, 5, boss.Position + Vector(data.XDashVel > 0 and 35 or -35, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -39) --POOF02(Blood Cloud)
					else
						Isaac.Spawn(1000, 2, 4, boss.Position + Vector(data.XDashVel > 0 and 35 or -35, 1), Vector(0, 0), boss).PositionOffset = Vector(0, -39) --BLOOD_EXPLOSION
					end

					boss.Child:ToLaser().Timeout = 1
					sprite:Play("CollidesWall", true)
					Game():ShakeScreen(15)
					boss:PlaySound(52, 1, 0, false, 1.15) --HELLBOSS_GROUNDPOUND
					data.Charging = false
					boss.Velocity = Vector(0, 0)
				end
			end
		end
	elseif boss.State == 9 then --STATE_ATTACK2
		if sprite:IsPlaying("DivideStartRef") or sprite:IsPlaying("DivideLoopRef") then
			data.RotateFrame = data.RotateFrame + boss.Velocity:Length() / (boss.Velocity.X > 0 and -10 or 10)
		end

		if boss:CollidesWithGrid() then
			if boss.Velocity:Length() > 5 then
				boss:PlaySound(28, math.min(boss.Velocity:Length() / 15, 1), 0, false, 1) --DEATH_BURST_LARGE
			else
				boss:PlaySound(72, math.min(boss.Velocity:Length() / 5, 1), 0, false, 1) --MEAT_JUMPS
			end
		end

		if boss.StateFrame > 0 then
			boss.StateFrame = boss.StateFrame - 1
			boss.Velocity = Vector(math.max(boss.Velocity:Length(), 15), 0):Rotated(boss.Velocity:GetAngleDegrees())
		else
			boss.Velocity = boss.Velocity * 0.95

			if boss.Velocity:Length() < 1 and sprite:IsPlaying("DivideLoopRef") then
				sprite:Play("DivideEndRef", true)
			end
		end

		if sprite:IsPlaying("DivideStartRef") and sprite:GetFrame() == 7 then
			sprite:Play("DivideLoopRef", true)
		end

		if (sprite:IsPlaying("DivideEndRef") and sprite:GetFrame() == 3) or boss:IsDead() then
			data.RotateFrame = nil
			sprite:ReplaceSpritesheet(0, "gfx/bosses/mod/itlives_head.png")
			sprite:LoadGraphics()
		end

		if sprite:IsFinished("DivideEndRef") then
			boss.State = 4
		end
	end
end, 555)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, boss)
	if boss.Variant ~= LivesHeadVari then return end

	local sprite = boss:GetSprite()
	local data = boss:GetData()

	if boss.Parent then
		--HP share
		if boss.HitPoints > boss.Parent.HitPoints then
			boss.HitPoints = boss.Parent.HitPoints
		end

		if boss.Parent.HitPoints > boss.HitPoints then
			boss.Parent.HitPoints = boss.HitPoints
		end

		--If head collides with body
		if data.Charging and boss.Parent:GetData().Charging and boss.Position:Distance(boss.Parent.Position) < boss.Size + boss.Parent.Size
		and math.abs(boss.Position.Y - boss.Parent.Position.Y) < 50 and math.abs(boss.Velocity.X + boss.Parent.Velocity.X) < math.abs(boss.Velocity.X) then
			local pspr = boss.Parent:GetSprite()
			local Dist = boss.Position:Distance(boss.Parent.Position)
			local Angle = (boss.Position - boss.Parent.Position):GetAngleDegrees()

			Game():ShakeScreen(12)
			boss:PlaySound(28, 1, 0, false, 1) --DEATH_BURST_LARGE
			boss.Velocity = Vector(boss.Velocity:Length() / 2, 0):Rotated(Angle)
			boss.Parent.Velocity = Vector(boss.Parent.Velocity:Length() / 2, 0):Rotated((boss.Parent.Position - boss.Position):GetAngleDegrees())
			boss.Child:ToLaser().Timeout = 1
			boss.Parent.Child:ToLaser().Timeout = 1
			data.Charging = false
			boss.Parent:GetData().Charging = false
			sprite:Play("CollidesBody", true)

			if boss.Parent.Velocity.X > 0 then
				pspr:Play("CollidesHeadLeft", true)
			else
				pspr:Play("CollidesHeadRight", true)
			end

			if REPENTANCE then
				Isaac.Spawn(1000, 16, 5, boss.Position + Vector(Dist / 2, 0):Rotated(Angle), Vector(0, 0), boss).PositionOffset = Vector(0, -39) --POOF02(Blood Cloud)
			else
				Isaac.Spawn(1000, 2, 4, boss.Position + Vector(Dist / 2, 0):Rotated(Angle), Vector(0, 0), boss).PositionOffset = Vector(0, -39) --BLOOD_EXPLOSION
			end

			local params = ProjectileParams()
			params.FallingSpeedModifier = 2
			params.FallingAccelModifier = -0.15

			for i=0, 2 do
				local Start = (i % 2) * 10
				params.Scale = 1 + i / 2

				for j=Start, 340 + Start, 20 do
					boss:FireProjectiles(boss.Position, Vector.FromAngle(j):Resized(4 + i * 3), 0, params)
				end
			end
		end

		--If head or body is died
		if boss.Parent:IsDead() then
			boss:Kill()
		elseif boss:IsDead() then
			boss.Parent:Kill()
		end
	end

	--Head rotate render
	if data.RotateFrame then
		local RndSpr = Sprite()

		RndSpr:Load("gfx/boss_itlives_head.anm2", true)
		RndSpr:SetFrame("Rotate", math.floor(data.RotateFrame) % 19)
		RndSpr.Scale = LivesHeadRotateScale[sprite:GetFrame() + (sprite:IsPlaying("DivideStartRef") and 0 or (sprite:IsPlaying("DivideLoopRef") and 8 or 24)) + 1]
		RndSpr.Offset = Vector(0, -39)
		RndSpr:Render(Isaac.WorldToScreen(boss.Position), Vector(0, 0), Vector(0, 0))
	end

	--Shoot bullets when died
	if sprite:IsEventTriggered("Explosion") and not data.BloodExplosion then
		data.BloodExplosion = true

		local params = ProjectileParams()
		params.Scale = 1.4
		params.FallingSpeedModifier = 2
		params.FallingAccelModifier = -0.15

		for i=0, 320, 40 do
			boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(5), 0, params)
		end
	end
end, 555)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if (boss.Variant ~= MomHeartVari and boss.Variant ~= ItLivesVari and boss.Variant ~= LivesHeadVari) or REPENTANCE then return end

	HMBPENTS.NoDlrForm(boss)
end, 555)

----------------------------
--The Lamb II
----------------------------
  function HMBPENTS:Lamb2(boss)

  if boss.Variant == Isaac.GetEntityVariantByName("The Lamb II") then

	local sprl2 = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local Entities = Isaac:GetRoomEntities()
	local dist = target.Position:Distance(boss.Position)
	local rng = boss:GetDropRNG()
	local angle = (target.Position - boss.Position):GetAngleDegrees()
	local Room = Game():GetRoom()
	boss.SplatColor = Color(0.13,1.73,2.28,1.5,0,0,0)

	if not denpnapi then
		boss:Remove()
	end

	if not data.dashanim then
		data.dashanim = "none"
		data.darkness = 0
		data.dashcooldown = 200
	end

	if sprl2:IsFinished("Appear") or (boss.State < 2 and boss.FrameCount > 5) then
		boss.State = 4
		boss.StateFrame = math.random(80,100)
		boss.TargetPosition = boss.Position
	end

	if boss.Visible then
		if sprl2:IsPlaying("HeadDashHori") or sprl2:IsPlaying("HeadDashUp") or sprl2:IsPlaying("HeadDashDown") then
			if sprl2:IsPlaying("HeadDashHori") then
				data.dashanim = "Hori"
			elseif sprl2:IsPlaying("HeadDashUp") then
				data.dashanim = "Up"
			elseif sprl2:IsPlaying("HeadDashDown") then
				data.dashanim = "Down"
			end
		end
	end

	if boss.State ~= 21 and data.dashcooldown then
		data.dashcooldown = data.dashcooldown - 1
	end

	if boss.State == 4 then
		boss.EntityCollisionClass = 4
		boss.FlipX = false
		boss.StateFrame = boss.StateFrame - 1
		boss.GridCollisionClass = 3
		boss.ProjectileCooldown = boss.ProjectileCooldown - 1
		if not sprl2:IsPlaying("HeadIdle") then
			sprl2:Play("HeadIdle", true)
			data.spawnpos = Vector(0,0)
			data.WallholeRotate = 0
			data.ExtWallHolePos = Vector(0,0)
			data.WhRtt2 = 0
			data.EntWhPos = Vector(0,0)
			data.projangle = 0
		end
		if boss:HasEntityFlags(1<<11) then
			boss.Velocity = (boss.Velocity * 0.95) + Vector.FromAngle(angle+180):Resized(0.35)
		elseif boss:HasEntityFlags(1<<9) then
			if boss.FrameCount % 100 then
				data.cfvel =  Vector.FromAngle(math.random(0,359)):Resized(0.3)
			end
			boss.Velocity = (boss.Velocity * 0.95) + data.cfvel
		else
			if #Isaac.FindInRadius(boss.Position, 160, 1<<2) > 0 then
				boss.Velocity = (boss.Velocity * 0.95)+Vector.FromAngle(angle):Resized(0.1)
			else
				boss.Velocity = (boss.Velocity * 0.95)+Vector.FromAngle(angle):Resized(0.3)
			end
		end

		if boss.HitPoints/boss.MaxHitPoints <= 0.5 and not data.sucklight and not data.isdelirium then
			boss.State = 28
			sprl2:Play("HeadSuckingStart", true)
		end

		if boss.StateFrame <= 0 and dist <= 500 then
			if math.random(1,8) == 1 then
				if math.random(1,2) == 1 then
					sprl2:Play("HeadDashCharge", true)
					boss.State = 10
					boss.I2 = math.random(2,4)
					boss:PlaySound(14, 1, 0, false, 1)
					data.chargestart = false
				else
					if denpnapi then
						sprl2:Play("HeadCharge", true)
						boss.State = 8
						if math.random(0,1) == 0 and Room:GetCenterPos():Distance(boss.Position) <= ((Room:GetBottomRightPos().Y-140)/2)-50 then
							boss.I1 = 0
						else
							boss.I1 = math.random(1,4)
							boss:PlaySound(104, 1, 0, false, 1)
						end
					end
				end
			elseif math.random(1,8) == 2 then
				sprl2:Play("HeadSummon", true)

				if Room:GetAliveEnemiesCount() < 5 and denpnapi and math.random(1,2) == 1 then
					boss.State = 13
				else
					boss.State = 11
					boss.StateFrame = 315
				end
			elseif math.random(1,8) == 3 then
				if not (Room:IsLShapedRoom() and Room:GetRoomShape() == 2 and Room:GetRoomShape() == 3 and Room:GetRoomShape() == 5 and Room:GetRoomShape() == 7)
				and not data.isdelirium and data.dashcooldown < 1 then
					sprl2:Play("HeadCharge2Start", true)
					boss.State = 21
					boss:PlaySound(312, 1, 0, false, 1)
					data.dashcooldown = 200
					if boss.Position.X > target.Position.X then
						boss.FlipX = true
						boss.Velocity = Vector(5,0)
						local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(Room:GetTopLeftPos().X, boss.Position.Y), Vector(0,0), boss)
						wallholext:GetSprite().Rotation = 270
						wallholext.PositionOffset = Vector(0,-20)
						wallholext.Parent = boss
					else
						boss.FlipX = false
						boss.Velocity = Vector(-5,0)
						local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, Vector(Room:GetBottomRightPos().X, boss.Position.Y), Vector(0,0), boss)
						wallholext:GetSprite().Rotation = 90
						wallholext.PositionOffset = Vector(0,-20)
						wallholext.Parent = boss
					end
				end
			elseif math.random(1,8) == 4 then
				if #Isaac.FindByType(400, -1, -1, true, true) < 1 then
					sprl2:Play("HeadCharge3", true)
					boss.State = 12
					boss.I2 = 3
				end
			elseif math.random(1,8) == 5 or math.random(1,8) == 6 then
				if math.abs(target.Position.X-boss.Position.X) < math.abs(target.Position.Y-boss.Position.Y) then
					if target.Position.Y >= boss.Position.Y then
						sprl2:Play("HeadShootDown", true)
					else
						sprl2:Play("HeadShootUp", true)
					end
				else
					sprl2:Play("HeadShootHori", true)
					if target.Position.X <= boss.Position.X then
						boss.FlipX = true
					end
				end
				boss.State = 9
			else
				if boss.HitPoints/boss.MaxHitPoints <= 0.5 then
					boss.State = 13
					sprl2:Play("HeadSummon3", true)
				end
			end
		else
			if #Isaac.FindInRadius(boss.Position, 100, 1<<2) > 0
			and boss.ProjectileCooldown <= 0 then
				if #Isaac.FindInRadius(boss.Position, 15, 1<<2) > 0 then
					boss.State = 6
					boss.ProjectileCooldown = 13
				else
					boss.Velocity = Vector.FromAngle
					((target.Position-boss.Position):GetAngleDegrees()):Resized(-14)
					if math.abs(boss.Position.X-target.Position.X) < math.abs(boss.Position.Y-target.Position.Y) then
						if boss.Position.X < target.Position.X then
							boss:AddVelocity(Vector(-math.abs(boss.Position.X-target.Position.X)*0.075,0))
						else
							boss:AddVelocity(Vector(math.abs(boss.Position.X-target.Position.X)*0.075,0))
						end
					else
						if boss.Position.Y < target.Position.Y then
							boss:AddVelocity(Vector(0,-math.abs(boss.Position.X-target.Position.X)*0.075))
						else
							boss:AddVelocity(Vector(0,math.abs(boss.Position.X-target.Position.X)*0.075))
						end
					end
					boss.State = 25
					boss.I1 = math.random(1,5)
					boss.ProjectileCooldown = 13
					boss:PlaySound(14, 1, 0, false, 1.3)
				end
			end
		end
	else
		boss.Velocity = boss.Velocity * 0.9
		if boss.State == 6 then
			if not sprl2:IsFinished("HeadJump2") and not sprl2:IsPlaying("HeadJump2")
			and not sprl2:IsFinished("HeadAppear") and not sprl2:IsPlaying("HeadAppear") then
				sprl2:Play("HeadJump2", true)
			end
			if sprl2:IsFinished("HeadJump2") then
				sprl2:Play("HeadAppear", true)
				boss.Position = Isaac.GetRandomPosition(0)
				boss:PlaySound(214, 1, 0, false, 1)
			elseif sprl2:IsFinished("HeadAppear") then
				boss.State = 4
			end
			if sprl2:IsPlaying("HeadJump2") then
				if sprl2:GetFrame() == 5 then
					boss:PlaySound(215, 1, 0, false, 1)
					boss.EntityCollisionClass = 0
				end
			elseif sprl2:IsPlaying("HeadAppear") then
				if sprl2:GetFrame() == 6 then
					boss.EntityCollisionClass = 4
				end
			end
		elseif boss.State == 8 then
			if sprl2:IsFinished("HeadCharge") then
				if boss.I1 == 1 then
					sprl2:Play("HeadShoot", true)
				else
					sprl2:Play("HeadShoot2Start", true)
				end
			elseif sprl2:IsFinished("HeadShoot2Start") then
				sprl2:Play("HeadShoot2Loop", true)
			elseif sprl2:IsFinished("HeadShoot") or sprl2:IsFinished("HeadShoot2End") then
				boss.State = 4
				boss.StateFrame = math.random(80,100)
			end
			if sprl2:IsPlaying("HeadShoot") and sprl2:GetFrame() == 3 then
				local Rotation = math.random(0, 1)

				boss:PlaySound(226, 1, 0, false, 1)

				local params = ProjectileParams()
				params.TargetPosition = boss.Position
				params.Scale = 1.5
				params.HeightModifier = -5
				params.FallingSpeedModifier = 3
				params.FallingAccelModifier = -0.179
				params.Color = Color(0.11,1.5,2,1,0,0,0)

				for i=0, 1 do
					local Space = 20 + i * 10
					params.BulletFlags = Rotation == i and ProjectileFlags.ORBIT_CW or ProjectileFlags.ORBIT_CCW

					for j=0, 360 - Space, Space do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(j):Resized(6 - i * 3), 0, params)
					end
				end
			end
			if sprl2:IsEventTriggered("Shoot") then
				if boss.I1 == 0 then
					boss.StateFrame = 208
					local laser = EntityLaser.ShootAngle(1, boss.Position+Vector(0,1), 90, 160, Vector(0,-50), boss)
					laser:SetActiveRotation(30, 360*(1-((boss.StateFrame % 2)*2)), 4*(1-((boss.StateFrame % 2)*2)), false)
				else
					boss.StateFrame = math.random(160,250)
				end
				boss.I2 = boss.StateFrame % 50
			end
			if boss.I1 ~= 1 then
				if boss.StateFrame > 0 then
					boss.StateFrame = boss.StateFrame - 1
					if boss.StateFrame % 50 == boss.I2 and boss.I1 ~= 0 then
						boss:PlaySound(116 , 1, 0, false, 1)
					end
					if boss.I1 == 2 and boss.FrameCount % 30 == 0 then
						local params = ProjectileParams()
						params.BulletFlags = math.random(1, 2) == 1 and ProjectileFlags.ORBIT_CW or ProjectileFlags.ORBIT_CCW
						params.TargetPosition = boss.Position
						params.Scale = 1.5
						params.HeightModifier = -10
						params.Color = Color(0.11,1.5,2,1,0,0,0)
						params.FallingSpeedModifier = 3
						params.FallingAccelModifier = -0.185
						for i=0, 324, 36 do
							boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(4), 0, params)
						end
					elseif boss.I1 == 3 then
						if boss.FrameCount % 11 == 0 then
							boss.ProjectileCooldown = rng:RandomInt(359)

							local params = ProjectileParams()
							params.Scale = 1.5
							params.HeightModifier = -10
							params.Color = Color(0.11,1.5,2,1,0,0,0)
							params.FallingSpeedModifier = 3
							params.FallingAccelModifier = -0.16
							for i=-30, 30, 10 do
								boss:FireProjectiles(boss.Position, Vector.FromAngle(i+boss.ProjectileCooldown):Resized(5), 0, params)
							end
						end
					elseif boss.I1 == 4 and boss.FrameCount % 30 == 0 then
						local params = HMBPEnts.ProjParams()
						params.Scale = 1.5
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.TURN_RIGHTANGLE
						params.HeightModifier = -10
						params.Color = Color(0.11, 1.5, 2, 1, 0, 0, 0)
						params.FallingSpeedModifier = 2
						params.FallingAccelModifier = -0.1
						for i=0, 270, 90 do
							HMBPEnts.FireProjectile(boss, 0, boss.Position, Vector.FromAngle(i + (math.random(0, 1) * 45)):Resized(4), params)
						end
					end
				else
					if sprl2:IsPlaying("HeadShoot2Loop") then
						sprl2:Play("HeadShoot2End", true)
						boss.ProjectileCooldown = 0
					end
				end
			end
		elseif boss.State == 9 then
			if sprl2:IsEventTriggered("Shoot2") then
				boss:PlaySound(226, 1, 0, false, 1)
				boss:PlaySound(28, 1, 0, false, 1)
				local params = ProjectileParams()
				params.Scale = 2
				params.Color = Color(0.11,1.5,2,1,0,0,0)
				params.BulletFlags = ProjectileFlags.CONTINUUM
				params.FallingSpeedModifier = 3
				params.FallingAccelModifier = -0.19
				params.HeightModifier = -7
				if sprl2:IsPlaying("HeadShootDown") or sprl2:IsPlaying("HeadShootUp") then
					if sprl2:IsPlaying("HeadShootUp") then
						data.spawnpos = Vector(0,-27)
					else
						data.spawnpos = Vector(0,27)
					end
					boss:FireProjectiles(boss.Position+data.spawnpos,
					Vector(((target.Position.X-boss.Position.X)*0.01)*0.8,data.spawnpos.Y*0.3), 0, params)
					local xplsn = Isaac.Spawn(1000, 2, 2, boss.Position+data.spawnpos, Vector(0,0), boss)
					xplsn:SetColor(Color(0.13,1.73,2.28,1.5,0,0,0), 99999, 0, false, false)
					xplsn.PositionOffset = Vector(0,-50)
					boss.Velocity = Vector(-((target.Position.X-boss.Position.X)*0.01)*0.8,-data.spawnpos.Y*0.3)
				elseif sprl2:IsPlaying("HeadShootHori") then
					if boss.FlipX then
						data.spawnpos = Vector(-27,0)
					else
						data.spawnpos = Vector(27,0)
					end
					boss:FireProjectiles(boss.Position+data.spawnpos,
					Vector(data.spawnpos.X*0.3,((target.Position.X-boss.Position.X)*0.01)*0.8), 0, params)
					local xplsn = Isaac.Spawn(1000, 2, 2, boss.Position+data.spawnpos, Vector(0,0), boss)
					xplsn:SetColor(Color(0.13,1.73,2.28,1.5,0,0,0), 99999, 0, false, false)
					xplsn.PositionOffset = Vector(0,-50)
					boss.Velocity = Vector(-data.spawnpos.X*0.3, -((target.Position.X-boss.Position.X)*0.01)*0.8)
				end
			end
			if sprl2:IsFinished("HeadShootUp") or sprl2:IsFinished("HeadShootDown")
			or sprl2:IsFinished("HeadShootHori") then
				boss.State = 4
				boss.StateFrame = math.random(50,60)
			end
		elseif boss.State == 10 then
			if sprl2:IsFinished("HeadDashCharge") or sprl2:IsFinished("HeadChargeShort") then
				boss.TargetPosition = target.Position
				boss.I2 = boss.I2 - 1
				data.chargestart = true
				boss.StateFrame = 0
				boss:PlaySound(119, 1, 0, false, 1)
			end
			if sprl2:IsFinished("HeadWallCollide") then
				if boss.I2 <= 0 then
					boss.State = 4
					boss.StateFrame = math.random(80,100)
				else
					sprl2:Play("HeadChargeShort", true)
				end
			end
			if math.abs(boss.Position.X-Room:GetCenterPos().X) > math.abs(boss.Position.Y-Room:GetCenterPos().Y) then
				if boss.Position.X > Room:GetCenterPos().X then
					data.projangle = 0
				else
					data.projangle = 180
				end
			else
				if boss.Position.Y > Room:GetCenterPos().Y then
					data.projangle = 90
				else
					data.projangle = 270
				end
			end
			if data.chargestart then
				boss.StateFrame = boss.StateFrame + 1
				if math.abs(boss.Velocity.X) < math.abs(boss.Velocity.Y) then
					if boss.Velocity.Y >= 0 then
						data.hv = "Down"
					else
						data.hv = "Up"
					end
				else
					data.hv = "Hori"
					if boss.Velocity.X <= 0 then
						boss.FlipX = true
					else
						boss.FlipX = false
					end
				end
				if not sprl2:IsPlaying("HeadDash"..data.hv) then
					sprl2:Play("HeadDash"..data.hv, true)
				end
				boss.Velocity = Vector.FromAngle((boss.TargetPosition-boss.Position):GetAngleDegrees()):Resized(22)
				boss.TargetPosition = boss.TargetPosition + boss.Velocity
				if boss.StateFrame <= 25 then
					if boss.StateFrame >= 5 then
						if boss:CollidesWithGrid() then
							data.chargestart = false
							boss:PlaySound(52, 1, 0, false, 1)
							Game():ShakeScreen(10)
							local params = ProjectileParams()
							params.Variant = 999
							params.Color = Color(0.5,0.5,0.5,1,0,0,0)
							params.HeightModifier = -10
							params.FallingAccelModifier = 0.2
							for i=7, 15 do
								params.Scale = math.random(70,160)*0.01
								params.FallingSpeedModifier = math.random(-100,-10)*0.1
								boss:FireProjectiles(boss.Position-boss.Velocity,
								Vector.FromAngle(data.projangle - math.random(-55,55)):Resized(-math.random(40,130)*0.1), 0, params)
							end
							if data.hv == "Hori" then
								if boss.Velocity.X <= 0 then
									boss.FlipX = true
								else
									boss.FlipX = false
								end
							end
							sprl2:Play("HeadWallCollide", true)
						end
					end
				else
					boss.Velocity = boss.Velocity * 0.75
					data.chargestart = false
					sprl2:Play("HeadChargeShort", true)
					if boss.I2 <= 0 then
						boss.State = 4
						boss.StateFrame = math.random(80,100)
					end
				end
			end
		elseif boss.State == 11 then
			boss.Velocity = boss.Velocity * 0.9
			boss.StateFrame = boss.StateFrame - 1
			if sprl2:IsPlaying("HeadSummon") then
				if sprl2:GetFrame() == 15 then
					boss:PlaySound(122 , 1, 0, false, 1)
				elseif sprl2:GetFrame() == 32 then
					boss:PlaySound(265, 1, 0, false, 1)
					Isaac.Spawn(1000, 15, 0, boss.Position, Vector(0,0), boss)
					for i=1, 16 do
						local fclone = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("The Lamb II's Clone2"), 0, boss.Position, Vector(0,0), boss)
						fclone.Parent = boss
						fclone:ToEffect().Timeout = 16 + (i*15) - math.random(0,12)
						fclone.TargetPosition = Isaac.GetRandomPosition(0)
					end
				end
			end
			if sprl2:IsFinished("HeadJump") and boss.StateFrame <= 0 then
				sprl2:Play("HeadFalling", true)
			elseif sprl2:IsFinished("HeadSummon") then
				sprl2:Play("HeadJump", true)
			elseif sprl2:IsFinished("HeadFalling") then
				sprl2:Play("HeadLandStomp", true)
			elseif sprl2:IsFinished("HeadLandStomp") then
				boss.State = 4
				boss.StateFrame = math.random(80,100)
			end
			if sprl2:IsPlaying("HeadJump") and sprl2:GetFrame() == 19 then
				boss:PlaySound(14, 1, 0, false, 1)
				boss.EntityCollisionClass = 0
			elseif sprl2:IsPlaying("HeadLandStomp") then
				if sprl2:IsEventTriggered("Stomp") then
					SpawnGroundParticle(true, boss, 10, 10, 3, 20)
					local wave = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss):ToEffect()
					wave.Parent = boss
					wave.Timeout = 16
					wave.MaxRadius = 110
				end
			elseif sprl2:IsPlaying("HeadFalling") then
				if sprl2:GetFrame() <= 90 then
					boss:AddVelocity(Vector.FromAngle(angle):Resized(1.6))
				end
			end
		elseif boss.State == 12 then
			if sprl2:IsFinished("HeadCharge3") or sprl2:GetFrame() == 40 and boss.I2 > 0 then
				if (angle >= -135 and angle <= -45) or (angle >= 45 and angle <= 135) then
					if boss.Position.Y < target.Position.Y then
						sprl2:Play("HeadStompDown", true)
					else
						sprl2:Play("HeadStompUp", true)
					end
				else
					sprl2:Play("HeadStompHori", true)
					if boss.Position.X < target.Position.X then
						boss.FlipX = false
					else
						boss.FlipX = true
					end
				end
				local lstmp = Isaac.Spawn(507, 0, 0, target.Position, Vector(0,0), boss)
				lstmp:ToNPC().I1 = 175
			end

			if not sprl2:IsPlaying("HeadCharge3") and sprl2:GetFrame() == 25 then
				boss:PlaySound(306 , 1, 0, false, 1)
				boss.I2 = boss.I2 - 1
			end

			if sprl2:IsFinished("HeadStompUp") or sprl2:IsFinished("HeadStompDown") or sprl2:IsFinished("HeadStompHori") then
				boss.State = 4
				boss.StateFrame = math.random(80,100)
			end
		elseif boss.State == 13 then
			if sprl2:IsPlaying("HeadSummon") then
				if sprl2:GetFrame() == 15 then
					boss:PlaySound(122 , 1, 0, false, 1)
				elseif sprl2:GetFrame() == 32 then
					boss:PlaySound(265 , 1, 0, false, 1)
					for i=-90, 90, 180 do
						local lfallen = Isaac.Spawn(554, Isaac.GetEntityVariantByName("Little Fallen"), 0, boss.Position+Vector(i,0), Vector(0,0), boss)
						lfallen.HitPoints = 25
						lfallen.MaxHitPoints = 25
					end
				end
			elseif sprl2:IsPlaying("HeadSummon3") then
				if sprl2:GetFrame() == 15 then
					boss:PlaySound(265 , 1, 0, false, 1)
					for i=-3, 3, 6 do
						for j=-1.5, 1.5, 1.5 do
							local mnlamb = Isaac.Spawn(555, Isaac.GetEntityVariantByName("Mini Lamb"), 0, boss.Position+Vector(i*12,j*17), Vector(i*0.05,j), boss)
							if data.isdelirium then
								for n=0, 1 do
									mnlamb:GetSprite():ReplaceSpritesheet(n, "gfx/enemies/minilamb_dlrform.png")
								end
								mnlamb:GetSprite():LoadGraphics()
							end
						end
					end
				end
			end
			if sprl2:IsFinished("HeadSummon") then
				boss.State = 4
				boss.StateFrame = math.random(80,100)
			elseif sprl2:IsFinished("HeadSummon3") then
				boss.State = 4
				boss.StateFrame = math.random(50,60)
			end
		elseif boss.State == 21 then
			if sprl2:IsFinished("HeadCharge2Start") then
				sprl2:Play("HeadCharge2Loop", true)
				boss.StateFrame = 50
			elseif sprl2:IsFinished("HeadBrake") then
				boss.State = 4
				boss.StateFrame = math.random(80,100)
			end
			if sprl2:IsPlaying("HeadBrake") then
				boss.Velocity = boss.Velocity * 0.9
			elseif sprl2:IsPlaying("HeadCharge2Loop") then
				boss.Velocity = boss.Velocity * 0.98
			end
			if sprl2:IsPlaying("HeadCharge2Loop") then
				boss.StateFrame = boss.StateFrame - 1
				if boss.StateFrame <= 0 then
					sprl2:Play("HeadDashHori", true)
					Game():ShakeScreen(5)
					boss:PlaySound(115 , 1, 0, false, 1)
					boss.I2 = 13
					boss.GridCollisionClass = 0
				end
			elseif sprl2:IsPlaying("HeadDashHori") or sprl2:IsPlaying("HeadDashUp") or sprl2:IsPlaying("HeadDashDown") then
				if boss.Visible then
					if sprl2:IsPlaying("HeadDashHori") then
						boss.GridCollisionClass = 1
						if boss.FlipX then
							boss.Velocity = Vector(-30, 0)
						else
							boss.Velocity = Vector(30, 0)
						end
						if boss.I2 <= 0 then
							boss.StateFrame = boss.StateFrame + 1
							if boss.StateFrame >= 35 then
								sprl2:Play("HeadBrake", true)
							end
						end
					elseif sprl2:IsPlaying("HeadDashUp") then
						boss.Velocity = Vector(0, -30)
					elseif sprl2:IsPlaying("HeadDashDown") then
						boss.Velocity = Vector(0, 30)
					end
					if (sprl2:IsPlaying("HeadDashHori") and ((boss.FlipX
					and boss.Position.X <= Room:GetTopLeftPos().X)))
					or (not boss.FlipX and boss.Position.X >= Room:GetBottomRightPos().X)
					or (sprl2:IsPlaying("HeadDashUp") and boss.Position.Y <= Room:GetTopLeftPos().Y)
					or (sprl2:IsPlaying("HeadDashDown") and boss.Position.Y >= Room:GetBottomRightPos().Y)	then
						boss:PlaySound(28, 1, 0, false, 1)
						Game():ShakeScreen(10)
						boss.Visible = false
						boss.EntityCollisionClass = 0
						boss.StateFrame = 0
						boss.I2 = boss.I2 - 1
						local xplsn = Isaac.Spawn(1000, 2, 2, boss.Position, Vector(0,0), boss)
						xplsn:SetColor(Color(0.13,1.73,2.28,1.5,0,0,0), 99999, 0, false, false)
						xplsn.PositionOffset = Vector(0,-20)
						boss.Velocity = Vector(0, 0)
					end
				else
					boss.StateFrame = boss.StateFrame + 1
					if boss.StateFrame == 6 then
						if boss.I2 <= 1 then
							boss.I1 = 3
						else
							boss.I1 = math.random(0,3)
						end
						data.WallholeRotate = 90 * boss.I1
						if boss.I1 == 0 then
							boss.TargetPosition = Room:GetTopLeftPos() + Vector(10+(((Room:GetBottomRightPos().X-80)*math.random(1,10))/10), 0)
							data.ExtWallHolePos = Vector(boss.TargetPosition.X, Room:GetBottomRightPos().Y)
						elseif boss.I1 == 1 then
							boss.TargetPosition = Room:GetBottomRightPos() - Vector(0, 10+(((Room:GetBottomRightPos().Y-160)*math.random(1,5))/5))
							data.ExtWallHolePos = Vector(Room:GetTopLeftPos().X, boss.TargetPosition.Y)
						elseif boss.I1 == 2 then
							boss.TargetPosition = Room:GetBottomRightPos() - Vector(10+(((Room:GetBottomRightPos().X-80)*math.random(1,10))/10), 0)
							data.ExtWallHolePos = Vector(boss.TargetPosition.X, Room:GetTopLeftPos().Y)
						else
							boss.TargetPosition = Room:GetTopLeftPos() + Vector(0, 10+(((Room:GetBottomRightPos().Y-160)*math.random(1,5))/5))
							data.ExtWallHolePos = Vector(Room:GetBottomRightPos().X, boss.TargetPosition.Y)
						end
						boss.Position = boss.TargetPosition
						local wallholent = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 0, boss.Position, Vector(0,0), boss)
						wallholent:GetSprite().Rotation = data.WallholeRotate
						wallholent.PositionOffset = Vector(0,-20)
						if boss.I2 > 0 then
							local wallholext = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 1, data.ExtWallHolePos, Vector(0,0), boss)
							wallholext:GetSprite().Rotation = data.WallholeRotate + 180
							wallholext.PositionOffset = Vector(0,-20)
							wallholext.Parent = boss
						end
					elseif boss.StateFrame == 19 + boss.I2 then
						if boss.I2 > 0 and boss.I2 <= 8 then
							data.WhRtt2 = math.random(0,3) * 90
							if data.WhRtt2/90 == 0 then
								data.EntWhPos = Room:GetTopLeftPos() + Vector(10+((Room:GetBottomRightPos().X-80)*math.random(1,10))/10, 0)
							elseif data.WhRtt2/90 == 1 then
								data.EntWhPos = Room:GetBottomRightPos() - Vector(0, 10+(((Room:GetBottomRightPos().Y-160)*math.random(1,5))/5))
							elseif data.WhRtt2/90 == 2 then
								data.EntWhPos = Room:GetBottomRightPos() - Vector(10+(((Room:GetBottomRightPos().X-80)*math.random(1,10))/10), 0)
							else
								data.EntWhPos = Room:GetTopLeftPos() + Vector(0, 10+(((Room:GetBottomRightPos().Y-160)*math.random(1,5))/5))
							end
							local wallholent = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Wall Hole"), 2, data.EntWhPos, Vector(0,0), boss)
							wallholent:GetSprite().Rotation = data.WhRtt2
							wallholent.PositionOffset = Vector(0,-20)
						end
					end
					if boss.StateFrame >= 28 + boss.I2 then
						boss.Visible = true
						boss.EntityCollisionClass = 4
						boss:PlaySound(28, 1, 0, false, 1)
						boss:PlaySound(119, 1, 0, false, 1)
						Game():ShakeScreen(10)
						if boss.I1 == 0 then
							sprl2:Play("HeadDashDown", true)
						elseif boss.I1 == 1 then
							sprl2:Play("HeadDashHori", true)
							boss.FlipX = true
						elseif boss.I1 == 2 then
							sprl2:Play("HeadDashUp", true)
						else
							sprl2:Play("HeadDashHori", true)
							boss.FlipX = false
						end
						local xplsn = Isaac.Spawn(1000, 2, 2, boss.Position, Vector(0,0), boss)
						xplsn:SetColor(Color(0.13,1.73,2.28,1.5,0,0,0), 99999, 0, false, false)
						xplsn.PositionOffset = Vector(0,-20)
					end
				end
			end
		elseif boss.State == 25 then
			boss.Velocity = boss.Velocity * 0.95
			if boss.I1 ~= 5 then
				if boss.I1 < 5 then
					if not sprl2:IsPlaying("HeadBackDash") and not sprl2:IsFinished("HeadBackDash") then
						sprl2:Play("HeadBackDash", true)
						if boss.Velocity.X < 0 then
							boss.FlipX = true
						end
					end
					if sprl2:IsFinished("HeadBackDash") then
						boss.State = 4
						boss.FlipX = false
					end
				elseif boss.I1 == 6 then
					if sprl2:IsFinished("HeadBackDash2") then
						sprl2:Play("HeadDashHori", true)
						if boss.FlipX then
							boss.FlipX = false
						else
							boss.FlipX = true
						end
					elseif sprl2:IsFinished("HeadWallCollideHori") then
						boss.State = 4
						boss.FlipX = false
					end
					if sprl2:IsPlaying("HeadDashHori") or sprl2:IsPlaying("HeadBackDash2") then
						if boss.FlipX then
							if sprl2:IsPlaying("HeadDashHori") then
								boss.Velocity = Vector(-22, boss.Velocity.Y * 0.8)
							else
								boss.Velocity = Vector(22, boss.Velocity.Y * 0.8)
							end
						else
							if sprl2:IsPlaying("HeadDashHori") then
								boss.Velocity = Vector(22, boss.Velocity.Y * 0.8)
							else
								boss.Velocity = Vector(-22, boss.Velocity.Y * 0.8)
							end
						end
					end
					if sprl2:IsPlaying("HeadDashHori") then
						if boss.Position.Y > target.Position.Y then
							boss:AddVelocity(Vector(0,-1))
						else
							boss:AddVelocity(Vector(0,1))
						end
						if (not boss.FlipX and boss.Position.X >= Room:GetBottomRightPos().X - 30)
						or (boss.FlipX and boss.Position.X <= Room:GetTopLeftPos().X + 30) then
							boss:PlaySound(52, 1, 0, false, 1)
							Game():ShakeScreen(10)
							local params = ProjectileParams()
							params.Variant = 999
							params.HeightModifier = -10
							params.FallingAccelModifier = 0.2
							for i=7, 15 do
								params.Scale = math.random(70,160)*0.01
								params.FallingSpeedModifier = math.random(-100,-10)*0.1
								boss:FireProjectiles(boss.Position-boss.Velocity, Vector.FromAngle(boss.Velocity:GetAngleDegrees()
								+ math.random(-70,70)):Resized(-math.random(40,130)*0.1), 0, params)
							end
							sprl2:Play("HeadWallCollideHori", true)
							boss.Velocity = Vector(0,0)
						end
					end
				end
			else
				if not sprl2:IsPlaying("HeadBackDash2") and not sprl2:IsFinished("HeadBackDash2") then
					sprl2:Play("HeadBackDash2", true)
					if boss.Velocity.X < 0 then
						boss.FlipX = true
					end
				end
				if sprl2:IsPlaying("HeadBackDash2") and sprl2:GetFrame() == 20 then
					boss.I1 = 6
					boss:PlaySound(119, 1, 0, false, 1)
				end
			end
		elseif boss.State == 28 then
			if sprl2:IsPlaying("HeadSuckingStart") and sprl2:GetFrame() == 23 then
				boss:PlaySound(182, 1, 0, false, 0.05)
				data.sucking = true
				data.sucklight = true
				boss.StateFrame = 175
				sprl2:PlayOverlay("DarkGlow", true)
				boss:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
			if data.sucking then
				boss.StateFrame = boss.StateFrame - 1
				Game():UpdateStrangeAttractor(boss.Position)
				if boss.StateFrame % 5 == 0 then
					local BlkHoleRay = Isaac.Spawn(1000, 107, 1, boss.Position, Vector(0,0), boss)
					BlkHoleRay.PositionOffset = Vector(0,-57)
					BlkHoleRay:GetSprite().Rotation = rng:RandomInt(359)
				end
				if boss.StateFrame % 3 == 0 and boss.StateFrame > 35 then
					if math.random(1,2) == 1 then
						boss.TargetPosition = Vector(math.random(70,Room:GetBottomRightPos().X-80), 150+(Room:GetBottomRightPos().Y-160)*math.random(0,1))
					else
						boss.TargetPosition = Vector(70+(Room:GetBottomRightPos().X-80)*math.random(0,1), math.random(150,Room:GetBottomRightPos().Y-10))
					end
					local shnproj = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Appearing Projectile"), 0, boss.TargetPosition, Vector(0,0), boss):ToEffect()
					shnproj.Scale = math.random(1,10)*0.1
				end
				if boss.StateFrame % 3 == 0 then
					data.darkness = data.darkness + 1.5
					if Room:GetLightingAlpha() < data.darkness/87.5 then
						Game():Darken(data.darkness/87.5, 2)
					end
				end
				for k, v in pairs(Entities) do
					if (v:IsEnemy() and v.Type ~= 555) or v.Type == 1 or v.Type == 2 or v.Type == 9 then
						if v.Type == 400 and v.Variant == 0 then
							local vspr = v:GetSprite()
							if v:ToNPC().State ~= 15 then
								v:ToNPC().State = 15
								vspr:Play("Being Sucked Start", true)
							else
								if boss.StateFrame > 0 then
									if boss.Position.X > v.Position.X then
										v.FlipX = false
									else
										v.FlipX = true
									end
									if v:ToNPC().I1 ~= 999 then
										v.Velocity = Vector.FromAngle((boss.Position-v.Position):GetAngleDegrees()):Resized(1)
									end
								end
								if boss.StateFrame <= 0 or boss:IsDead() then
									if vspr:IsPlaying("Being Sucked Loop") then
										vspr:Play("Being Sucked End", true)
									else
										vspr:Play("Idle", true)
										v:ToNPC().State = 4
										v:ToNPC().StateFrame = math.random(60,70)
									end
									v:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
									v:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
									v:ToNPC().I1 = 0
								end
							end
						else
							if 6/(v.Position:Distance(boss.Position)/10) < 0.3 then
								v:AddVelocity(Vector.FromAngle((boss.Position-v.Position):GetAngleDegrees())
								:Resized(6/(v.Position:Distance(boss.Position)/10)))
							else
								v:AddVelocity(Vector.FromAngle((boss.Position-v.Position):GetAngleDegrees()):Resized(0.3))
							end
						end
						if v.Position:Distance(boss.Position) <= boss.Size + v.Size and not v:IsBoss()
						and (v:IsEnemy() or v.Type == 2 or v.Type == 9) and v.Type ~= 400 then
							if v:IsEnemy() then
								v:Kill()
							else
								v:Remove()
							end
						end
					end
				end
				if boss.StateFrame <= 0 then
					sprl2:Play("HeadSuckingEnd", true)
					boss:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
					boss:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
					data.sucking = false
					if Room:GetLightingAlpha() < 1 then
						Game():Darken(1, 40)
					end
				end
			end
			if sprl2:IsFinished("HeadSuckingStart") then
				sprl2:Play("HeadSuckingLoop", true)
			elseif sprl2:IsFinished("HeadSuckingEnd") then
				sprl2:Play("HeadHoldingLoop", true)
				boss.State = 29
			end
		elseif boss.State == 29 then
			if sprl2:IsPlaying("HeadHoldingLoop") then
				boss.StateFrame = boss.StateFrame - 1
				if boss.StateFrame % 20 == 0 or (target.Position:Distance(boss.Position) <= 200
				and target.Position:Distance(boss.TargetPosition) <= 200) then
					boss.TargetPosition = Isaac.GetRandomPosition(0)
				end
				boss.Velocity = (boss.Velocity * 0.95) +
				Vector.FromAngle((boss.TargetPosition-boss.Position):GetAngleDegrees()):Resized(0.58)
				if boss.StateFrame <= 0 then
					sprl2:Play("HeadSummon2", true)
					boss.StateFrame = 60
				end
				if boss.HitPoints/boss.MaxHitPoints <= 0.25 then
					sprl2:Play("HeadSpit", true)
				end
			elseif sprl2:IsPlaying("HeadSummon2") and sprl2:GetFrame() == 15 then
				boss:PlaySound(265, 1, 0, false, 1)
				for i=-35, 35, 70 do
					for j=-1, 1, 2 do
						Isaac.Spawn(555, Isaac.GetEntityVariantByName("Mini Lamb"), 0, boss.Position+Vector(i,j*10), Vector(i*0.05,j), boss)
					end
				end
			elseif sprl2:IsPlaying("HeadSpit") and sprl2:GetFrame() == 21 then
				local RGBO = REPENTANCE and 1 or 255

				boss:PlaySound(12, 1, 0, false, 1)

				local params = ProjectileParams()
				params.Variant = 6
				for i=0, 15 do
					params.Scale = math.random(1, 20) * 0.1
					params.Color = Color(1, 1, 1, 1, RGBO, RGBO, RGBO)
					boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(-math.random(40,130)*0.1), 0, params)
				end
				data.darkness = 0
			end
			if data.darkness > 0 then
				Game():Darken(1, 2)
			end
			if sprl2:IsFinished("Hold Light In Mouth") or sprl2:IsFinished("HeadSummon2") then
				sprl2:Play("HeadHoldingLoop", true)
			elseif sprl2:IsFinished("HeadSpit") then
				sprl2:Play("HeadIdle", true)
				boss.State = 4
			end
		end
	end

	if sprl2:IsOverlayFinished("DarkGlow") then
		sprl2:RemoveOverlay()
	end

  end
  end
----------------------------
--New Entity:Mega Satan 2's Hands
----------------------------
function HMBPENTS:MSHandS(enemy)

	if (enemy.Variant == 1 or enemy.Variant == 2) and enemy.SpawnerEntity then

	local sprshn = enemy:GetSprite()
	local sents = enemy.SpawnerEntity
	local target = Game():GetPlayer(1)
	local Entities = Isaac:GetRoomEntities()
	local data = enemy:GetData()
	local sdt = sents:GetData()
	local sspr = enemy.SpawnerEntity:GetSprite()
	local tangle = (target.Position - enemy.Position):GetAngleDegrees()
	local Room = Game():GetRoom()
	enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	enemy:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	enemy:RemoveStatusEffects()
	enemy.GridCollisionClass = 0

	if sprshn:IsFinished("Appear") then
		sprshn:Play("TrueAppear", true)
		enemy.State = 22
	end

	if enemy.Variant % 2 == 1 then
		enemy.FlipX = false
	else
		enemy.FlipX = true
	end

	if sprshn:IsFinished("TrueAppear") and ((sspr:IsPlaying("Appear") and sspr:GetFrame() >= 114) or not sspr:IsPlaying("Appear")) then
		sprshn:Play("Idle1", true)
		enemy.State = 3
		enemy.EntityCollisionClass = 4
	end

	if enemy.State == 8 then
		if enemy.Variant % 2 == 0 then
			data.dist = (sents.Position + Vector(150,115)):Distance(enemy.Position)
			data.angle = ((sents.Position + Vector(150,115))-enemy.Position):GetAngleDegrees()
		else
			data.dist = (sents.Position + Vector(-150,115)):Distance(enemy.Position)
			data.angle = ((sents.Position + Vector(-150,115))-enemy.Position):GetAngleDegrees()
		end
	else
		if enemy.Variant % 2 == 0 then
			data.dist = (sents.Position + Vector(40,115)):Distance(enemy.Position)
			data.angle = ((sents.Position + Vector(40,115))-enemy.Position):GetAngleDegrees()
		else
			data.dist = (sents.Position + Vector(-40,115)):Distance(enemy.Position)
			data.angle = ((sents.Position + Vector(-40,115))-enemy.Position):GetAngleDegrees()
		end
	end

	if enemy.State == 3 or enemy.State == 8 then
		enemy.EntityCollisionClass = 4
		enemy.Velocity = (enemy.Velocity * 0.7) + Vector.FromAngle(data.angle)
		:Resized(data.dist*0.03)
	end

	if sspr:IsPlaying("Idle1") or sspr:IsPlaying("Idle2")
	or sspr:IsPlaying("Idle3") then
		enemy.State = 3
	elseif sspr:IsPlaying("Shoot1Start") or sspr:IsPlaying("Shoot2Start")
	or sspr:IsPlaying("Shoot3Start") then
		enemy.State = 8
	elseif sspr:IsPlaying("Up1") or sspr:IsPlaying("Up2")
	or sspr:IsPlaying("Up3") then
		enemy.State = 15
		if enemy.State == 15 and sprshn:IsPlaying("Idle1") then
			sprshn:Play("Up", true)
			enemy.Velocity = Vector(0,0)
		end
	elseif sspr:IsPlaying("Down1") or sspr:IsPlaying("Down2")
	or sspr:IsPlaying("Down3") then
		if sspr:GetFrame() == 1 then
			sprshn:Play("Down", true)
		end
	end

	if sprshn:IsPlaying("Up") or sprshn:IsPlaying("Down")
	or sprshn:IsPlaying("Vanish") or enemy.FrameCount <= 114 then
		enemy.EntityCollisionClass = 0
	end

	if sprshn:IsFinished("Up") then
		if enemy.Variant == 1 then
			enemy.Position = Vector(0,target.Position.Y)
			sprshn:Play("Appear2", true)
			sdt.handattacking = true
			sdt.side = "Right"
		end
	end

	if sprshn:IsFinished("Appear2") then
		sprshn:Play("PunchReady", true)
	end

	if sprshn:IsPlaying("PunchReady") then
		enemy.EntityCollisionClass = 4
		enemy.StateFrame = enemy.StateFrame - 1
		if enemy.Variant == 1 then
			enemy.Position = Vector(0,enemy.Position.Y)
		else
			enemy.Position = Vector(660,enemy.Position.Y)
		end
		if enemy.Position.Y + target.Position.Y < 0
		or enemy.Position.Y - target.Position.Y < 0  then
			enemy.Velocity = (enemy.Velocity * 0.96) + Vector.FromAngle(90):Resized(1)
		else
			enemy.Velocity = (enemy.Velocity * 0.96) + Vector.FromAngle(270):Resized(1)
		end
		if enemy.StateFrame <= 0
		and (target.Position.Y - enemy.Position.Y >= -15
		or target.Position.Y + enemy.Position.Y <= 15) then
			sprshn:Play("Punchstart", true)
		end
	end


	if sprshn:IsPlaying("Punchstart") then
		if sprshn:GetFrame() == 1 or sprshn:GetFrame() == 32 then
			enemy.Velocity = Vector(0,0)
		elseif sprshn:GetFrame() >= 26 and sprshn:GetFrame() <= 31 then
			--Game():BombDamage(enemy.Position, 40, 46, false, enemy, 0, 1<<2, false)
			if enemy.Variant == 1 then
				enemy.Velocity = Vector(60,0)
			else
				enemy.Velocity = Vector(-60,0)
			end
		end

		if sprshn:GetFrame() == 26 then
			enemy:PlaySound(182, 1, 0, false, 1)
		end
		enemy.Velocity = enemy.Velocity * 0.8
	end

	if sprshn:IsFinished("Punchstart") then
		if enemy.Variant == 1 then
			if enemy.Position.X >= 0 then
				enemy.Velocity = (enemy.Velocity * 0.96) + Vector.FromAngle(180):Resized(1)
			else
				enemy.Velocity = enemy.Velocity * 0.7
				sprshn:Play("Vanish", true)
			end
		else
			if enemy.Position.X <= Room:GetBottomRightPos().X then
				enemy.Velocity = (enemy.Velocity * 0.96) + Vector.FromAngle(0):Resized(1)
			else
				enemy.Velocity = enemy.Velocity * 0.7
				sprshn:Play("Vanish", true)
				enemy.EntityCollisionClass = 0
			end
		end
	end

	if sprshn:IsPlaying("Appear2") or sprshn:IsPlaying("Vanish") then
		enemy.StateFrame = math.random(75,110)
		enemy.Velocity = enemy.Velocity * 0.6
	end

	if sprshn:IsPlaying("Down") and sprshn:GetFrame() == 1 then
		if enemy.Variant % 2 == 1 then
			enemy.Position = sents.Position + Vector(-50,115)
		else
			enemy.Position = sents.Position + Vector(50,115)
		end
	end

	if sprshn:IsFinished("Down") then
		enemy.EntityCollisionClass = 4
	end

	if sprshn:IsPlaying("Vanish") then
		if sprshn:GetFrame() == 15 then
			sdt.handattacking = false
		elseif sprshn:GetFrame() == 30 then
			if sdt.side == "Left" then
				sdt.side = "Right"
			elseif sdt.side == "Right" then
				sdt.side = "Left"
			end
			if math.random(1,2) == 1 then
				sents:ToNPC().ProjectileCooldown = math.random(259,309)
				if sdt.side == "Left" then
					sents:ToNPC().I2 = 1
					sdt.side = "Right"
				elseif sdt.side == "Right" then
					sents:ToNPC().I2 = 2
					sdt.side = "Left"
				end
			end
		end
	end

	if (sprshn:IsFinished("Vanish") or sprshn:IsFinished("Up"))
	and sents:ToNPC().ProjectileCooldown <= 0 then
		if enemy.Variant % 2 == 0 and sdt.side == "Left" then
			enemy.Position = Vector(660,target.Position.Y)
			sprshn:Play("Appear2", true)
			sdt.handattacking = true
		elseif enemy.Variant % 2 == 1 and sdt.side == "Right" then
			enemy.Position = Vector(0,target.Position.Y)
			sprshn:Play("Appear2", true)
			sdt.handattacking = true
		end
	end

	if enemy:IsDead() then
		sdt.handattacking = false
		enemy:PlaySound(242, 1, 0, false, 1)
	end

	--if sprshn:IsFinished("Vanish") and ((sdt.left > 0 and enemy.Variant % 2 == 0)
	--or (sdt.right > 0 and enemy.Variant % 2 == 1)) and sents:ToNPC().I2 == 0 then
		--sprshn:Play("Appear2", true)
		--sdt.handattacking = true
		--if enemy.Variant == 2 then
			--enemy.Position = Vector(660,target.Position.Y)
		--else
			--enemy.Position = Vector(0,target.Position.Y)
		--end
	--end

	for k, v in pairs(Entities) do
		if v:IsVulnerableEnemy() and v.Type ~= 399 and v.Type ~= 275 then
			if v.Position:Distance(enemy.Position) <= 45 + v.Size and enemy.Velocity:Length() >= 5 and sprshn:IsPlaying("Punchstart") then
				v:TakeDamage(25, 0, EntityRef(enemy), 5)
			end
		end
	end

	if enemy.SpawnerEntity:GetSprite():IsPlaying("Death") then
		enemy:Kill()
	end

  end
  end

HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, enemy)
	if enemy.Variant > 0 and enemy.Variant < 3 then
		HMBPENTS.NoDlrForm(enemy)
	end
end, 399)

--[[HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, enemy)
	if (enemy.Variant == 1 or enemy.Variant == 2) and enemy.SpawnerEntity then
		if enemy.Variant == 1 then
			enemy.SpawnerEntity:GetData().rhandcooldown = enemy.SpawnerEntity.FrameCount
		else
			enemy.SpawnerEntity:GetData().lhandcooldown = enemy.SpawnerEntity.FrameCount
		end
	end
end, 399)]]

----------------------------
--New Boss:Lamb Body(Hard)
----------------------------
  function HMBPENTS:LambBody(boss)

	if boss.Variant == Isaac.GetEntityVariantByName("Lamb Body(Hard)") then

	local sprlb = boss:GetSprite()
	local target = boss:GetPlayerTarget()
	local data = boss:GetData()
	local Entities = Isaac:GetRoomEntities()
	local dist = target.Position:Distance(boss.Position)
	local rng = boss:GetDropRNG()
	local Room = Game():GetRoom()
	boss:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	boss.StateFrame = boss.StateFrame - 1
	local angle = (target.Position - boss.Position):GetAngleDegrees()
	boss.SplatColor = Color(0.13,1.73,2.28,1.5,0,0,0)

	if boss.State == 9 then
		boss.Velocity = boss.Velocity * 0.999
	else
		boss.Velocity = boss.Velocity * 0.9
	end

	if not data.speed then
		data.ChangedHP = false
		sprlb:Play("TrueAppear", true)
		boss.State = 3
		local flame = Isaac.Spawn(1000, 10, 0, boss.Position ,Vector(0,0), boss):ToEffect()
		flame.Parent = boss
		flame:FollowParent(boss)
		flame.Visible = false
		flame.PositionOffset = Vector(0,-42)
		data.speed = 0
		data.angle2 = angle
	end

	if boss.State ~= 4 and (sprlb:IsFinished("TrueAppear") or sprlb:IsFinished("Attack")
	or sprlb:IsFinished("ShootEnd") or sprlb:IsFinished("Shoot") or sprlb:IsFinished("Rebirth")
	or sprlb:IsFinished("Being Sucked End") or sprlb:IsFinished("Shoot2")) or sprlb:IsFinished("Shock") then
		sprlb:Play("Idle", true)
		boss.State = 4
		boss.StateFrame = math.random(60,70)-data.speed
	end

	if boss.Parent then
		local BParent = boss.Parent:ToNPC()
		local prspr = BParent:GetSprite()
		if boss.State ~= 12 then
			if boss.State > 3 and BParent.State == 12 then
				if prspr:IsPlaying("HeadAttackReady") and prspr:GetFrame() == 1 then
					sprlb:Play("StompReady", true)
				end
				boss:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
				boss.State = 12
				boss.I1 = 0
			end
		else
			if BParent.State == 12 and (BParent.StateFrame == 50 or prspr:GetFrame() == 75) and BParent.I2 > 0 then
				if BParent.I2 % 2 == 1 then
					sprlb:Play("StompHori", true)
				else
					sprlb:Play("StompVert", true)
				end
			end
		end
	end

	if boss.State == 4 then
		if boss:HasEntityFlags(1<<11) then
			data.angle2 = angle+180
		elseif boss:HasEntityFlags(1<<9) and boss.FrameCount % 100 then
			data.angle2 = math.random(0,359)
		else
			data.angle2 = angle
		end
		if data.speed == 0 then
			boss:AddVelocity(Vector.FromAngle(data.angle2):Resized(0.1))
		else
			boss:AddVelocity(Vector.FromAngle(data.angle2):Resized(0.25))
		end
		if data.hurtattack then
			sprlb:Play("Shoot2", true)
			boss.State = 10
			data.hurtattack = false
		end
		if data.speed == 0 and #Isaac.FindByType(555, 0, -1, true, true) < 1 and #Isaac.FindByType(273, 0, -1, true, true) < 1
		and #Isaac.FindByType(412, -1, -1, true, true) < 1 then
			if boss.SpawnerType == 273 and not data.isdelirium then
				sprlb:Play("Shock", true)
				boss.State = 15
			end
			data.speed = 30
		end
	end

	if boss.State == 4 and boss.StateFrame <= 0 and dist <= 500 then
		--[[if math.random(0,5) == 0 then
			if #Isaac.FindByType(557, 0, -1, true, true) > 0 and denpnapi then
				boss.State = 13
				sprlb:Play("Charge", true)
				boss.I1 = 0
			end
		elseif math.random(0,5) == 1 then
			if math.abs(target.Position.X-boss.Position.X) <= 80 and not data.isdelirium then
				sprlb:Play("ShootStart", true)
				boss.State = 9
				boss:PlaySound(310 , 1, 0, false, 1)
			end
		elseif math.random(0,5) == 2 and denpnapi then
			sprlb:Play("Throw", true)
			boss.State = 11
			boss.I2 = math.random(1,4)+data.speed/10
		elseif math.random(0,5) == 3 then
			if #Isaac.FindByType(273, 0, -1, true, true) < 1 then]]
				sprlb:Play("StompReady", true)
				boss.State = 12
				boss.I1 = 1 + data.speed/30
			--[[end
		elseif math.random(0,5) == 4 then
			sprlb:Play("Shoot2", true)
			boss.State = 10
		else
			sprlb:Play("Charge", true)
			boss.I1 = math.random(0,2)
			boss.State = 8
			boss:PlaySound(14 , 1, 0, false, 1)
		end]]
	end

	if sprlb:IsFinished("Charge") and boss.State == 13 then
		sprlb:Play("Rebirth", true)
		boss:PlaySound(265 , 1, 0, false, 1)
	end

	if boss.State == 11 then
		if sprlb:IsPlaying("Throw") and sprlb:GetFrame() == 24 then
			boss:PlaySound(252, 1, 0, false, 1)
			local params = HMBPEnts.ProjParams()
			params.BulletFlags = ProjectileFlags.ACCELERATE
			params.HMBPBulletFlags = HMBPEnts.ProjFlags.BLACKCIRCLE
			params.Acceleration = 0.9
			HMBPEnts.FireProjectile(boss, 6, boss.Position, Vector.FromAngle(angle):Resized(dist*0.1), params)
		end
		if sprlb:IsPlaying("Throw") and sprlb:GetFrame() == 37 then
			if boss.I2 > 0 then
				sprlb:Play("Throw", true)
				boss.I2 = boss.I2 - 1
				if boss.FlipX then
					boss.FlipX = false
				else
					boss.FlipX = true
				end
			end
		end
		if sprlb:IsFinished("Throw") then
			sprlb:Play("Idle", true)
			boss.State = 4
			boss.StateFrame = math.random(60,70)
			boss.FlipX = false
		end
	elseif boss.State == 10 then
		if sprlb:IsPlaying("Shoot2") and sprlb:GetFrame() == 11 then
			boss:PlaySound(226, 1, 0, false, 1)
			local params = ProjectileParams()
			params.HeightModifier = -13
			params.FallingAccelModifier = 0.45
			params.Color = Color(0.11,1.5,2,1,0,0,0)
			for i=0, math.random(8,17)+data.speed/5 do
				params.Scale = math.random(7,16)*0.1
				params.FallingSpeedModifier = -math.random(15,100)*0.1
				boss:FireProjectiles(boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(50,100)*0.08), 0, params)
			end
			for i=0, math.random(1,3)+data.speed/15 do
				if i >= 1 then
					local fly = Isaac.Spawn(18, 0, 0, boss.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(math.random(50,80)*0.1), boss)
					fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				end
			end
		end
	elseif boss.State == 8 then
		if sprlb:IsFinished("Charge") then
			boss:PlaySound(304 , 1, 0, false, 1)
			sprlb:Play("Attack", true)
		end

		if sprlb:IsPlaying("Attack") then
			if sprlb:IsEventTriggered("shoot") then
				if boss.I1 == 0 then
					local params = ProjectileParams()
					params.HeightModifier = -13
					params.Variant = 2
					params.Color = Color(0.5,0.5,2,1,0,0,0)
					if data.speed ~= 0 then
						params.BulletFlags = math.random(1, 2) == 1 and ProjectileFlags.ORBIT_CW or ProjectileFlags.ORBIT_CCW
						params.TargetPosition = boss.Position
						params.FallingAccelModifier = -0.1
					end
					for i=0, 315+data.speed/2, 45-data.speed/2 do
						boss:FireProjectiles(boss.Position, Vector.FromAngle(i):Resized(9), 0, params)
					end
				elseif boss.I1 == 1 then
					for i=36-(data.speed/30)*18, 324+(data.speed/30)*18, 72-(data.speed/30)*36 do
						local flame = Isaac.Spawn(1000, 10, 10, boss.Position ,Vector.FromAngle(i):Resized(10), boss):ToEffect()
						flame.EntityCollisionClass = 4
						flame.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
						flame.Timeout = 100
					end
				end
			end
			if boss.I1 == 2 and boss.FrameCount % 3 == 0 and sprlb:GetFrame() < 13 then
				local params = ProjectileParams()
				params.HeightModifier = -13
				params.Variant = 2
				params.Color = Color(0.5,0.5,2,1,0,0,0)
				boss:FireProjectiles(boss.Position, Vector.FromAngle(angle):Resized(10), data.speed/10, params)
			end
		end
	elseif boss.State == 15 then
		if sprlb:IsPlaying("Being Sucked Start") and sprlb:GetFrame() == 53 then
			boss:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			boss:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
			boss.I1 = 999
		end
		if boss.I1 == 999 then
			boss.Velocity = Vector(0,0)
		end
		if sprlb:IsFinished("Being Sucked Start") then
			sprlb:Play("Being Sucked Loop", true)
		end
	end

	if data.isdelirium then
		data.deliriumspeed = 0.5
	else
		data.deliriumspeed = 1
	end

	if sprlb:IsPlaying("StompReady") and boss.I1 ~= 0 then
		boss.I2 = 3
	end
	if sprlb:IsFinished("StompReady") then
		if boss.I1 == 0 then
			sprlb:Play("StpReadyLoop", true)
		else
			sprlb:Play("StompStart", true)
		end
	end

	if boss.State == 9 then
		if sprlb:GetFrame() == 20 then
			EntityLaser.ShootAngle(3, boss.Position+Vector(0,10), 90, 3, Vector(-2,-50), boss)
		end
		if sprlb:GetFrame() >= 20 then
			boss.Velocity = (boss.Velocity * 0.999) + Vector((0.3*(math.abs(target.Position.X-boss.Position.X)/(target.Position.X-boss.Position.X))), -0.85*data.deliriumspeed)

			if boss:CollidesWithGrid() then
				sprlb:Play("ShootEnd", true)
				boss:PlaySound(48, 1, 0, false, 1)
			end
		end
	elseif boss.State == 12 then
		if not sprlb:IsPlaying("StompReady") and boss.I1 == 0 then
			boss.Velocity = Vector.FromAngle((Room:GetCenterPos() - boss.Position):GetAngleDegrees()):Resized(Room:GetCenterPos():Distance(boss.Position)*0.14)
			if sprlb:GetFrame() == 1 then
				if sprlb:IsPlaying("StompVert") then
					for i=-75, 75, 150 do
						Isaac.Spawn(507, 0, 1, Room:GetCenterPos()+Vector(0,i), Vector(0,0), boss)
					end
				elseif sprlb:IsPlaying("StompHori") then
					for i=-170, 170, 340 do
						Isaac.Spawn(507, 0, 1, Room:GetCenterPos()+Vector(0,i), Vector(0,0), boss)
					end
				end
			end
		end

		if sprlb:IsPlaying("StompStart") and sprlb:GetFrame() == 3 then
			Isaac.Spawn(507, 0, boss.I1, target.Position, Vector(0,0), boss)
			boss.StateFrame = 29
		elseif sprlb:IsPlaying("StompLoop") and boss.StateFrame < 1 then
			sprlb:Play("StompEnd", true)
		elseif sprlb:IsPlaying("StompEnd") and sprlb:GetFrame() == 23 and boss.I2 > 0 then
			boss.I2 = boss.I2 - 1
			sprlb:Play("StompStart", true)
		end

		if sprlb:IsFinished("StompStart") then
			sprlb:Play("StompLoop", true)
		end

		if sprlb:IsFinished("StompVert") or sprlb:IsFinished("StompHori")
		or sprlb:IsFinished("StompEnd") then
			sprlb:Play("Idle", true)
			boss.State = 4
			boss.StateFrame = math.random(60,70)
			boss.I1 = 0
			boss:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	end

	if boss:IsDead() then
		local poof = Isaac.Spawn(1000, 15, 0, boss.Position, Vector(0,0), boss)
		poof.SpriteOffset = Vector(0, -40)
		boss:PlaySound(261, 1, 0, false, 1)
		Game():Darken(1,230)
		if #Isaac.FindByType(273, 0, -1, true, true) > 0 or #Isaac.FindByType(555, 0, -1, true, true) > 0 then
			local dbody = Isaac.Spawn(400, 1, 0, boss.Position, Vector(0,0), boss)
			dbody.FlipX = boss.FlipX
			dbody.Parent = boss.Parent
			boss:Remove()
		end
	end

  end
  end

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == Isaac.GetEntityVariantByName("Lamb Body(Hard)") then
		boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
  end, 400)

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, boss)
	if not boss.Variant == Isaac.GetEntityVariantByName("Lamb Body(Hard)") then return end

	local sprlb = boss:GetSprite()

	if sprlb:IsFinished("Death") then
		local Div = REPENTANCE and 255 or 1

		Game():SpawnParticles(boss.Position, 88, 10, 15, Color(1, 1, 1, 1, 135 / Div, 126 / Div, 90 / Div), -4)
	end
  end, 400)

----------------------------
--New Boss:Satan 666
----------------------------
function HMBPENTS:Satan666(boss)

	if boss.Variant == Isaac.GetEntityVariantByName("Satan666") then

	local spr666 = boss:GetSprite()
	local data = boss:GetData()
	local player = Game():GetNearestPlayer(boss.Position)
	local Entities = Isaac:GetRoomEntities()
	local Room = Game():GetRoom()
	boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	boss:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	boss:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	boss.Velocity = Vector(0,0)

	boss.Visible = false

	if boss.Parent and boss.Parent:GetSprite():IsFinished("Death") then
		boss:ClearEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)

		if not data.Y then
			for i=0, 1 do
				local Foot = Isaac.Spawn(666, 667+i, 0, Vector(boss.Position.X, boss.Position.Y-60+(i*120)), Vector(0,0), boss)
				Foot.Parent = boss
				Foot:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			end
			data.Y = 0
			data.TPosX = Room:GetTopLeftPos().X+65
			data.datainitseed = boss.InitSeed
			spr666:Play("FootAppear", true)
			boss.State = 2
			data.feetjump = 1
			data.yvel = 1
			data.speed = 1
		end
	end

	if boss.StateFrame > 0 then
		boss.StateFrame = boss.StateFrame - 1
	end

	if boss.ProjectileCooldown >= 0 then
		boss.ProjectileCooldown = boss.ProjectileCooldown - 1
	end

	if data.freeze then
		data.freeze = false
	end

	if boss.State == 2 and spr666:IsFinished("FootAppear") then
		boss.State = 3
		boss.StateFrame = 80
	elseif boss.State == 3 then
		if boss.HitPoints/boss.MaxHitPoints < 0.4 and data.speed == 1 then
			data.speed = 2
		end

		if math.abs(player.Position.Y-boss.Position.Y) > 70 and boss.ProjectileCooldown <= 0 then
			boss.State = 4
			boss.I2 = 96 - data.speed * 24
			if player.Position.Y < boss.Position.Y then
				boss.I1 = 667+data.Y--Left Foot
			else
				boss.I1 = 668-data.Y--Right Foot
			end
			if math.abs(player.Position.Y-boss.Position.Y) > 150 then
				if player.Position.Y < boss.Position.Y then
					boss.Position = Vector(boss.Position.X, boss.Position.Y-150)
				else
					boss.Position = Vector(boss.Position.X, boss.Position.Y+150)
				end
			else
				boss.Position = Vector(boss.Position.X, player.Position.Y)
			end
		end

		if boss.StateFrame <= 0 then
			if math.random(1,5) == 1 and data.speed == 2 then
				boss.State = 12
			elseif math.random(1,5) == 2 and boss.I1 ~= 0 then
				boss.State = 9
				boss.I2 = 0
				data.feetjump = 3
			elseif math.random(1,5) == 3 then
				boss.State = 6
				data.feetjump = 1
				if data.TPosX <= Room:GetCenterPos().X then
					data.TPosX = Room:GetBottomRightPos().X-65
				else
					data.TPosX = Room:GetTopLeftPos().X+65
				end
				boss.Position = Vector(boss.Position.X, Room:GetCenterPos().Y)
			else
				boss.State = 8
				if player.Position:Distance(boss.Position) <= 150 then
					boss.I2 = 1
				else
					if boss.HitPoints/boss.MaxHitPoints > 0.4 then
						boss.I2 = 0
					else
						boss.I2 = 2
					end
				end
				if player.Position.Y < boss.Position.Y then
					boss.I1 = 667+data.Y--Left Foot
				else
					boss.I1 = 668-data.Y--Right Foot
				end
			end
		end

		if (not boss.FlipX and boss.Position.X > player.Position.X) or
		(boss.FlipX and boss.Position.X < player.Position.X) then
			boss.State = 6
			data.feetjump = 2
			if boss.FlipX then
				boss.FlipX = false
			else
				boss.FlipX = true
			end
			if data.Y == 1 then data.Y = 0 else data.Y = 1 end
		end
	elseif boss.State == 4 then
		boss.I2 = boss.I2 - 1

		if boss.I2 < 1 then
			boss.State = 3
		end
	end

	if boss.ProjectileCooldown > 40 and boss.ProjectileCooldown % 4 == 0 then
		local params = ProjectileParams()
		params.FallingAccelModifier = 0.85
		params.HeightModifier = -300
		params.Scale = math.random(20,27) * 0.1
		if denpnapi then
			params.Variant = 9
		else
			params.Variant = 3
			params.Color = Color(0.6,0.8,1,1,0,0,0)
		end
		params.BulletFlags = 1 << 1 | 1 << 31 | 1 << 32
		params.ChangeTimeout = 5
		params.ChangeFlags = 1 << 1
		if boss.ProjectileCooldown % 12 == 0 then
			boss:FireProjectiles(player.Position, Vector(0,0), 0, params)
		else
			boss:FireProjectiles(Isaac.GetRandomPosition(0), Vector(0,0), 0, params)
		end
	end

	if data.feetjump and data.feetjump >= 1 then
		for k, v in pairs(Entities) do
			if v.Type == 666 and v.Parent and v.Parent:GetData().datainitseed == boss.InitSeed then
				local vspr = v:GetSprite()
				if data.feetjump == 1 then
					vspr:Play("Jump", true)
				else
					vspr:Play("Jump"..data.feetjump, true)
				end
			end
		end
		data.feetjump = 0
	end

	if data.TPosX then
		boss.Position = Vector(data.TPosX, boss.Position.Y)
	end

	if boss.Position.Y > Room:GetBottomRightPos().Y-80 then
		boss.Position = Vector(data.TPosX, Room:GetBottomRightPos().Y-80)
	end

	if boss.Position.Y < Room:GetTopLeftPos().Y+60 then
		boss.Position = Vector(data.TPosX, Room:GetTopLeftPos().Y+80)
	end

  end
  end

  function HMBPENTS:Satan666Foot(boss)

	if boss.Variant == Isaac.GetEntityVariantByName("Satan666 Left Foot") or boss.Variant == Isaac.GetEntityVariantByName("Satan666 Right Foot") then

	local spr666 = boss:GetSprite()
	local data = boss:GetData()
	local player = Game():GetNearestPlayer(boss.Position)
	local Room = Game():GetRoom()
	boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	boss:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
	boss:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

	if not (spr666:IsPlaying("HandAppear") or spr666:IsPlaying("Hand")
	or spr666:IsPlaying("HandVanish")) then
		boss.Velocity = Vector(0,0)
	end

	if spr666.PlaybackSpeed == 0 then
		spr666.PlaybackSpeed = 1
	end

	if boss.StateFrame > 0 then
		boss.StateFrame = boss.StateFrame - 1
	end

	if boss.Parent then
		local BParent = boss.Parent:ToNPC()
		local parpos = BParent.Position
		local pardata = BParent:GetData()
		local pardist = BParent.Position:Distance(boss.Position)

		if boss.FrameCount == 1 then
			spr666:Play("FootAppear", true)
			data.TPosUdt = true
			data.TPosFlw = true
			data.rotation = 0
			data.x = 1
			if boss.Variant == 667 then
				data.footangle = 270
			else
				data.footangle = 90
			end
		end

		if boss.State ~= BParent.State then
			if BParent.State == 8 then
				if boss.Variant == BParent.I1 then
					boss.I2 = 1
					if BParent.I2 == 1 then
						boss:PlaySound(246, 1, 0, false, 1)
					else
						boss:PlaySound(240, 1, 0, false, 1)
					end
				else
					boss.I2 = 2
				end
				spr666:Play("Stomp"..BParent.I2..boss.I2, true)
			end
			boss.State = BParent.State
		end

		if data.TPosUdt then
			boss.TargetPosition = parpos + Vector.FromAngle(data.footangle):Resized(45)
		end

		local angle = (boss.TargetPosition - boss.Position):GetAngleDegrees()

		if data.TPosFlw then
			boss.Position = boss.Position + Vector.FromAngle(angle):Resized(boss.TargetPosition:Distance(boss.Position)/6)
		end

		if boss.State == 4 then
			if (spr666:IsPlaying("Walk1") and spr666:GetFrame() == 23) or (spr666:IsPlaying("Walk2") and spr666:GetFrame() == 15) then
				data.TPosUdt = false
			end
			if (spr666:IsPlaying("Walk1") and spr666:GetFrame() == 35) or (spr666:IsPlaying("Walk2") and spr666:GetFrame() == 23) then
				if BParent.I1 == 667 then
					BParent.I1 = 668
				else
					BParent.I1 = 667
				end
				boss.I2 = 2
			end
		end

		if boss.State == 3 then
			boss.EntityCollisionClass = 4
			boss.I2 = boss.I2 - 1
			if not spr666:IsPlaying("Idle") and boss.I2 < 1 then
				spr666:Play("Idle", true)
				data.TPosUdt = false
				data.TPosFlw = true
				spr666.PlaybackSpeed = 1
				if boss.HitPoints/boss.MaxHitPoints > 0.4 then
					pardata.yvel = 2
				end
				boss.StateFrame = 2
			end
		elseif boss.State == 4 then
			if boss.Variant == BParent.I1 and BParent.I2 > 2 then
				boss.I2 = boss.I2 - 1
				if boss.I2 < 1 and not spr666:IsPlaying("Walk"..pardata.speed) then
					spr666:Play("Walk"..pardata.speed, true)
					data.TPosFlw = true
					data.TPosUdt = true
				end
			else
				data.TPosUdt = false
			end
		elseif boss.State == 6 then
			if spr666:IsFinished("Jump") or spr666:IsFinished("Jump2") then
				BParent.State = 3
				BParent.StateFrame = 50
				data.TPosUdt = false
			end
			if spr666:IsPlaying("Jump2") then
				if spr666:GetFrame() == 23 then
					boss:PlaySound(246, 1, 0, false, 1)
					data.TPosUdt = true
				elseif spr666:GetFrame() == 49 then
					boss.EntityCollisionClass = 4
				end

				if spr666:GetFrame() >= 23 and spr666:GetFrame() <= 48 then
					data.footangle = data.footangle + 180/26
					boss.Position = boss.TargetPosition
				end
				if spr666:GetFrame() == 27 then
					data.rotation = data.rotation + 180
					data.x = -data.x
					if boss.FlipX then
						boss.FlipX = false
					else
						boss.FlipX = true
					end
				end
			elseif spr666:IsPlaying("Jump") then
				if spr666:GetFrame() >= 15 then
					data.TPosUdt = true
				end
			end
		elseif boss.State == 8 then
			if spr666:IsPlaying("Stomp21") then
				if spr666:GetFrame() > 40 and spr666:GetFrame() < 43 then
					if boss.FlipX then
						boss.TargetPosition = boss.TargetPosition - Vector(20,0)
					else
						boss.TargetPosition = boss.TargetPosition + Vector(20,0)
					end
					boss.Position = boss.TargetPosition
				end
				if spr666:GetFrame() == 63 then
					boss.TargetPosition = parpos + Vector.FromAngle(data.footangle):Resized(45)
				end
			end

			if spr666:IsFinished("Stomp"..BParent.I2..boss.I2) then
				BParent.State = 3
				BParent.StateFrame = 50
				boss.I2 = 0
			end

			data.TPosUdt = false
		elseif boss.State == 9 then
			if spr666:IsPlaying("Jump3") then
				boss.I2 = 0
			elseif spr666:IsPlaying("Hand") then
				boss.Velocity = (boss.Velocity * 0.915) +
				Vector.FromAngle((player.Position - boss.Position):GetAngleDegrees()):Resized(0.8)

				if BParent.StateFrame % 17 == 0 then
					boss:PlaySound(153, 1, 0, false, 1)
					local params = HMBPEnts.ProjParams()
					params.FallingAccelModifier = 0.9
					params.HeightModifier = -180
					params.Scale = 1.25
					params.BulletFlags = 1 << 31 | 1 << 32
					params.HMBPBulletFlags = HMBPEnts.ProjFlags.BLACKCIRCLE
					params.ChangeTimeout = 5
					params.ChangeFlags = 0
					HMBPEnts.FireProjectile(boss, 6, boss.Position, Vector(0, 0), params)
				end

				if BParent.StateFrame <= 70 then
					spr666:Play("HandVanish", true)
				end
			end

			if spr666:IsFinished("Jump3") then
				if boss.I2 == 0 then
					boss.I2 = 1
					data.TPosFlw = false
					if boss.Variant == 667 then
						boss.Position = Vector(Room:GetBottomRightPos().X-45, Room:GetTopLeftPos().Y+45)
					else
						boss.Position = Room:GetTopLeftPos() + Vector(45, 45)
					end
					boss.StateFrame = 250
				else
					boss.StateFrame = boss.StateFrame - 1
					if boss.StateFrame == 200 + ((boss.Variant-666)*20) then
						local laser = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Giant Red Laser From Above"), 4, boss.Position, Vector(0,0), boss):ToEffect()
						laser.Rotation = 90
						laser.Timeout = 75
						laser:GetData().creeptimeout = 380
						laser.State = 3
						laser.LifeSpan = 10
						laser:GetData().num = 8
					end
					if boss.Variant == 668 and boss.StateFrame <= 0 then
						spr666:Play("HandAppear", true)
						boss.FlipX = true
						boss.Position = player.Position
						BParent.StateFrame = 270
						boss:PlaySound(246, 1, 0, false, 1)
					end
				end
			elseif spr666:IsFinished("HandAppear") then
				spr666:Play("Hand", true)
			elseif spr666:IsFinished("HandVanish") and BParent.StateFrame == 0 then
				BParent.I2 = 1
			elseif spr666:IsFinished("FootAppear") then
				BParent.State = 3
				BParent.StateFrame = 50
			end
			if (spr666:IsFinished("HandVanish") or spr666:IsFinished("Jump3")) and BParent.I2 == 1 then
				spr666:Play("FootAppear", true)
				data.TPosFlw = true
				data.TPosUdt = true
				BParent.Position = Vector(BParent.Position.X, Room:GetCenterPos().Y)
				boss.Position = boss.TargetPosition
				boss.FlipX = BParent.FlipX
			end
		elseif boss.State == 12 then
			if not spr666:IsPlaying("Summon") and not spr666:IsFinished("Summon") then
				spr666:Play("Summon", true)
				boss.I2 = math.random(0,2)
			end
			if spr666:IsPlaying("Summon") and boss.Variant == 667 then
				if spr666:GetFrame() == 25 then
					boss:PlaySound(239, 1, 0, false, 0.75)
					Game():ShakeScreen(50)
				end
				if spr666:GetFrame() > 53 and spr666:GetFrame() < 59 and spr666:GetFrame() % 2 == 0 then
					boss:PlaySound(265, 1, 0, false, 1)
					if boss.I2 == 0 then
						Isaac.Spawn(252, 0, 0, Vector(boss.Position.X+(85*data.x), 118+54*((spr666:GetFrame() % 6)+1)), Vector(0,0), boss)
					elseif boss.I2 == 1 and denpnapi then
						Isaac.Spawn(558, 0, 0, Vector(boss.Position.X+(85*data.x), 118+54*((spr666:GetFrame() % 6)+1)), Vector(0,0), boss)
					else
						if spr666:GetFrame() % 6 == 2 then
							Isaac.Spawn(259, 0, 0, Vector(boss.Position.X+(85*data.x), 280), Vector(0,0), boss)
						else
							Isaac.Spawn(251, 0, 0, Vector(boss.Position.X+(85*data.x), 118+54*((spr666:GetFrame() % 6)+1)), Vector(0,0), boss)
						end
					end
				end
			end
			if spr666:IsFinished("Summon") then
				BParent.State = 3
				BParent.StateFrame = 65
				BParent.ProjectileCooldown = 40
				boss.I2 = 0
			end
		end

		if spr666:IsEventTriggered("Stomp") then
			Game():ShakeScreen(10)
			boss:PlaySound(48, 1, 0, false, 0.75)
		elseif spr666:IsEventTriggered("Stomp2") then
			Game():ShakeScreen(20)
			boss:PlaySound(52, 1.2, 0, false, 1)
			boss.EntityCollisionClass = 4
			if spr666:IsPlaying("Stomp01") then
				boss:PlaySound(245, 1, 0, false, 1)
				for i=-12, 12, 24 do
					local wave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss):ToEffect()
					wave.Parent = boss
					wave.Rotation = (player.Position-boss.Position):GetAngleDegrees()+i
				end
			elseif spr666:IsPlaying("Stomp11") then
				local rwave = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss)
				rwave.Parent = boss
			elseif spr666:IsPlaying("Stomp21") then
				boss:PlaySound(239, 1, 0, false, 1)
				Game():BombExplosionEffects(boss.Position, 40, 1<<2, Color(1,1,1,1,0,0,0), boss, 1.2, true, true)
				for i=-25, 25, 25 do
					local wave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss):ToEffect()
					wave.Parent = boss
					wave.Rotation = (player.Position-boss.Position):GetAngleDegrees()+i
				end
			elseif spr666:IsPlaying("Jump") or (spr666:IsPlaying("FootAppear") and boss.State > 2) then
				boss.Velocity = Vector(0,0)
				BParent.ProjectileCooldown = 80
				local wave = Isaac.Spawn(1000, 61, 0, boss.Position, Vector(0,0), boss)
				wave.Parent = boss
			end
		elseif spr666:IsEventTriggered("NoEntCollide") then
			boss.EntityCollisionClass = 0
			if spr666:IsPlaying("Jump") or spr666:IsPlaying("Jump2") or spr666:IsPlaying("Jump3") then
				Game():ShakeScreen(10)
				if not snd:IsPlaying(246) then
					boss:PlaySound(246, 1, 0, false, 1)
				end
			end
		end
	else
		boss:Remove()
	end

  end
  end

  HMBPENTS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == Isaac.GetEntityVariantByName("Satan666") or boss.Variant == Isaac.GetEntityVariantByName("Satan666 Left Foot")
	or boss.Variant == Isaac.GetEntityVariantByName("Satan666 Right Foot") then
		HMBPENTS.NoDlrForm(boss)
		boss.EntityCollisionClass = 0
	end
  end, 666)

  HMBPENTS:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, boss)
	if boss.Variant == 666 then
		local Room = Game():GetRoom()
		local data = boss:GetData()
		if boss:IsDead() then
			Game():ShakeScreen(20)
			Room:EmitBloodFromWalls(4,7)
			boss:PlaySound(245, 1, 0, false, 1)
			data.freeze = false
		end

		if boss:GetData().UsedBible then
			boss:GetData().UsedBible = false
			for k, v in pairs(Isaac:GetRoomEntities()) do
				if v.Type == 1 then v:Kill() end
			end
		end

		if (data.lfoot and (data.lfoot:HasEntityFlags(1<<5) or data.lfoot:HasEntityFlags(1<<10))) or (data.rfoot and (data.rfoot:HasEntityFlags(1<<5) or data.rfoot:HasEntityFlags(1<<10))) then
			boss.Velocity = Vector(0,0)
			boss:GetData().freeze = true
			return true
		end
	end
	if boss.Variant > 666 and boss.Variant < 669 then
		if boss.Parent then
			local BPrt = boss.Parent
			if boss.Variant == 667 then
				BPrt:GetData().lfoot = boss
			else
				BPrt:GetData().rfoot = boss
			end
			for k, v in pairs(Isaac:GetRoomEntities()) do
				if not boss:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and boss:IsDead()
				and (v:IsEnemy() or v.Type == 9) and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					v:Kill()
				end
			end
			if BPrt:GetData().freeze then
				boss:GetSprite().PlaybackSpeed = 0
				boss.Velocity = Vector(0,0)
				return true
			end
		end
	end
  end, 666)

HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, boss)
	local sprdlr = boss:GetSprite()
	local data = boss:GetData()

	if not data.ChangedGraphic then
		if sprdlr:GetFilename() == "gfx/273.002_TheLamb.anm2" then
			for i=1, 8, 7 do
				sprdlr:ReplaceSpritesheet(i, "gfx/bosses/afterbirthplus/deliriumforms/rebirth/thelamb_hmbp.png")
			end
			sprdlr:LoadGraphics()
			boss.State = 4
		elseif sprdlr:GetFilename() == "gfx/273.000_TheLamb2.anm2" then
			sprdlr:ReplaceSpritesheet(0, "gfx/bosses/deliriumforms/lamb_bareface.png")
			for i=2, 3 do
				sprdlr:ReplaceSpritesheet(i, "gfx/bosses/deliriumforms/lamb2_body.png")
			end
			sprdlr:LoadGraphics()
			boss.State = 4
		end

		data.ChangedGraphic = true
	end
end, 412)

   --bosses--
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.HardMom, 396)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.HardMomf, 396)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.MomFLD, 396)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.MSHandS, 399)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.LambBody, 400)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.Lamb2, 555)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.Satan666, 666)
  HMBPENTS:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBPENTS.Satan666Foot, 666)
