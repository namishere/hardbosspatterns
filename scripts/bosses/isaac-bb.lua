local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--Isaac And His Fate
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)
end, 102)

function HMBP:IsaacAndBlueBaby(isaac)

	local sprme = isaac:GetSprite()
	local target = isaac:GetPlayerTarget()
	local data = isaac:GetData()

	if game.Difficulty % 2 == 1 then
		if sprme:IsPlaying("1Idle") and isaac.State == 8
		and rng:Random(1,3) == 1 then
			isaac.State = 20
			isaac.StateFrame = 70
		end

		if isaac.State == 20 then
			if sprme:IsPlaying("1Idle") then
				sprme:Play("1Attack2",true)
			elseif sprme:IsPlaying("1Attack2") then
				if sprme:GetFrame() == 56 then
					isaac:PlaySound(267, 1, 0, false, 1)
					if isaac.Variant == 0 then
						if HMBPENTS then
							local params = HMBPEnts.ProjParams()
							params.FallingAccelModifier = 0.5

							for i=0, rng:Random(7,10) do
								if i >= 7 then
									params.Scale = 1.5
									params.HMBPBulletFlags = HMBPEnts.ProjFlags.LEAVES_ACID
								else
									params.Scale = rng:Random(7, 13) * 0.1
								end

								params.FallingSpeedModifier = -rng:Random(130, 180) * 0.1
								HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(10,70) * 0.1), params)
							end
						else
							local params = ProjectileParams()
							params.Variant = 4
							params.FallingAccelModifier = 0.5

							for i=0, rng:Random(7, 13) do
								params.Scale = 0.7 + rng:Random(0, 3) * 0.3
								params.FallingSpeedModifier = -rng:Random(130, 180) * 0.1
								isaac:FireProjectiles(isaac.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(10, 70) * 0.1), 0, params)
							end
						end
					elseif isaac.Variant == 1 then
						local params = ProjectileParams()
						params.Scale = 1.3
						params.BulletFlags = 1
						params.FallingAccelModifier = -0.05
						for i=0, 330, 30 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+
							(target.Position-isaac.Position):GetAngleDegrees()):Resized(10), 0, params)
						end
					elseif isaac.Variant == 2 then
						local params = ProjectileParams()
						params.Scale = 1.3
						params.Variant = 6
						params.FallingAccelModifier = -0.165
						params.BulletFlags = rng:Random(1, 2) == 1 and ProjectileFlags.ORBIT_CW or ProjectileFlags.ORBIT_CCW
						params.Color = Color(0.8, 0.8, 1.3, 1, 0, 0, 0)
						params.TargetPosition = isaac.Position

						for i=0, 340, 20 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(6), 0, params)
						end
					end
				end
			end
			if sprme:IsFinished("1Attack2") then
				sprme:SetFrame("1Attack", 15)
				isaac.State = 8
			end
		end
		if isaac.Variant < 2 and (isaac.State == 9 or isaac.State == 20 or isaac.State == 66)  then
			for k, v in pairs(Isaac.FindByType(9, -1, -1, true, true)) do
				if v.SpawnerType == 102 and v.FrameCount < 2 and v:ToProjectile().ProjectileFlags < 2 and v:ToProjectile().FallingAccel == 0
				and isaac.Position:Distance(v.Position) < 2 then
					v:Remove()
				end
			end
		end
	end

	if denpnapi then
		if sprme:IsEventTriggered("Feather") then
			game:SpawnParticles(isaac.Position, Isaac.GetEntityVariantByName("Feather Particle"), rng:Random(6,13), 13, Color(1,1,1,1,0,0,0), -20)
		end

		if game.Difficulty % 2 == 1 then
			if not data.finalform and isaac.HitPoints / isaac.MaxHitPoints <= 0.3
			and isaac.Variant <= 1 then
				data.finalform = true
				isaac.State = 155
				sprme:Play("4Evolve",true)
				isaac.FlipX = false
			end

			if data.finalform and isaac.State < 33 then
				isaac.Visible = true
				isaac.State = 155
				sprme:Play("4Evolve",true)
			end

			if isaac.State == 155 then
				if sprme:IsPlaying("4Evolve") then
					if sprme:GetFrame() == 24 then
						isaac:PlaySound(266, 1, 0, false, 1.05)
						if isaac.Variant == 1 then
							isaac.I1 = 2
						end
					end
				else
					isaac.State = 33
					isaac.TargetPosition = Isaac.GetRandomPosition(0)
				end
			end
		end
	end

	end

----------------------------
--add Boss Pattern:Isaac
----------------------------
function HMBP:Isaac(isaac)

	if isaac.Variant == 0 and game.Difficulty % 2 == 1 then

	local spri = isaac:GetSprite()
	local Entities = Isaac:GetRoomEntities()
	local target = isaac:GetPlayerTarget()
	local data = isaac:GetData()
	local Room = game:GetRoom()

	if not data.door then
		if Room:GetRoomShape() >= 8 then
			data.door = 8
		elseif Room:GetRoomShape() >= 6 then
			data.door = 6
		elseif Room:GetRoomShape() >= 4 then
			data.door = 6
		else
			data.door = 4
		end
	end

	if ((spri:IsPlaying("2Idle") and isaac.State == 3) or (spri:IsPlaying("2Attack") and isaac.State == 8))
	and isaac.FrameCount % 90 == 0 and Room:GetAliveEnemiesCount() <= 3 and denpnapi then
		Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0,
		isaac.Position + Vector(rng:Random(10, 30), 0):Rotated((target.Position - isaac.Position):GetAngleDegrees()), Vector(0,0), isaac)
	end

	if spri:IsFinished("2Evolve") then
		data.i3 = rng:Random(4,7)
	end

	if isaac.State == 100 then
		if not spri:IsPlaying("4FBAttack4") then
			spri:Play("4FBAttack4",true)
		else
			if spri:GetFrame() == 17 then
				isaac:PlaySound(129, 1, 0, false, 1)
				local rlwv = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave (Radial)"), 0, isaac.Position, Vector(0,0), isaac):ToEffect()
				rlwv.Timeout = 150
				rlwv.Scale = 1.15
			elseif spri:GetFrame() == 51 then
				isaac.State = 33
				isaac.StateFrame = rng:Random(70,170)
			end
		end
	elseif isaac.State == 99 then
		isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
		if isaac.ProjectileCooldown == 200 then
			spri:Play("4FBAttack3Ready",true)
		elseif isaac.ProjectileCooldown == 134 then
			isaac:PlaySound(129, 1, 0, false, 1)
		elseif isaac.ProjectileCooldown == 30 then
			spri:Play("4FBAttack3End",true)
		elseif isaac.ProjectileCooldown <= 0 then
			isaac.State = 33
			isaac.StateFrame = rng:Random(70,170)
		end
		if spri:IsFinished("4FBAttack3Ready") then
			spri:Play("4FBAttack3Start",true)
		elseif spri:IsFinished("4FBAttack3Start") then
			spri:Play("4FBAttack3Loop2",true)
		end
		if isaac.ProjectileCooldown >= 50 and isaac.ProjectileCooldown <= 134 and isaac.ProjectileCooldown % 2 == 0 then
			isaac:PlaySound(267, 1, 0, false, 1)

			for i=0, 240, 120 do
				local Proj = Isaac.Spawn(557, Isaac.GetEntityVariantByName("Pupula Tear Projectile"), 0, isaac.Position, Vector.FromAngle(i+isaac.FrameCount*6):Resized(7), isaac)
				Proj:GetData().PNPCScale = 2.5
			end
		end
	elseif isaac.State == 88 then
		if spri:IsPlaying("4Appear") then
			isaac.Visible = true
			if spri:GetFrame() == 1 then
				isaac.I1 = isaac.I1 - 1
				isaac.Position = target.Position
			elseif spri:GetFrame() == 10 then
				isaac.EntityCollisionClass = 4
				isaac:PlaySound(52, 1, 0, false, 1)

				for i=0, 1 do
					local Start = i == 0 and 30 or 0

					for j=Start, 300 + Start, 60 do
						local lwavel = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 27 + i, isaac.Position + Vector.FromAngle(j):Resized(20), Vector(0,0), isaac)
						lwavel.Parent = isaac
						lwavel:ToEffect().Rotation = j
						lwavel:ToEffect().LifeSpan = 70
					end
				end
			end
		end
		if spri:IsFinished("4Appear") then
			if isaac.I1 > 0 then
				spri:Play("4FBAttack",true)
			else
				isaac.State = 33
				isaac.StateFrame = rng:Random(70,170)
			end
		end
		if spri:IsPlaying("4FBAttack") then
			if spri:GetFrame() >= 24 then
				isaac.Visible = false
				isaac.EntityCollisionClass = 0
			elseif spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
			end
		end
		if spri:IsFinished("4FBAttack") then
			spri:Play("4Appear",true)
			isaac:PlaySound(214, 1, 0, false, 1)
		end
	elseif isaac.State == 80 then
		isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
		if isaac.ProjectileCooldown <= 0 and spri:IsPlaying("4FBAttack2Loop") then
			spri:Play("4FBAttack2End",true)
		end
		if isaac.ProjectileCooldown > 0 and isaac.FrameCount % 5 == 0 then
			isaac:PlaySound(267, 0.65, 0, false, 1)

			local params = ProjectileParams()
			params.Variant = 4
			params.FallingSpeedModifier = 0

			if isaac.I1 == 1 then
				params.BulletFlags = ProjectileFlags.SAWTOOTH_WIGGLE
				params.FallingAccelModifier = -0.175
				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(7), 0, params)
				end
				if isaac.FrameCount % 2 == 0 then
					local params2 = ProjectileParams()
					params2.Variant = 4
					params2.FallingSpeedModifier = 0
					params2.FallingAccelModifier = -0.175
					for i=0, 315, 45 do
						isaac:FireProjectiles(isaac.Position,
						Vector.FromAngle(i+((isaac.FrameCount % 4)/2)*22.5):Resized(7), 0, params2)
					end
				end
			elseif isaac.I1 == 2 then
				params.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE
				params.CurvingStrength = 0.014
				params.FallingAccelModifier = -0.16
				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(9), 0, params)
				end
			elseif isaac.I1 == 3 then
				params.BulletFlags = 1 << (18 + isaac.FrameCount % 2) | ProjectileFlags.NO_WALL_COLLIDE
				| ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.ACCELERATE
				params.CurvingStrength = 0.014
				params.Acceleration = 0.98
				params.FallingAccelModifier = -0.165
				params.ChangeTimeout = 42
				params.ChangeFlags = 0

				for i=0, 315, 45 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+isaac.ProjectileCooldown*3):Resized(15), 0, params)
				end
			end
		end
		if spri:IsPlaying("4FBAttack2Start") and spri:GetFrame() == 21 then
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac.ProjectileCooldown = rng:Random(20,50)
		end
		if spri:IsFinished("4FBAttack2Start") then
			spri:Play("4FBAttack2Loop",true)
		elseif spri:IsFinished("4FBAttack2End") then
			isaac.State = 33
			isaac.StateFrame = rng:Random(70,170)
		end
	elseif isaac.State == 33 then
		isaac.StateFrame = isaac.StateFrame - 1
		if not spri:IsPlaying("4Idle") then
			spri:Play("4Idle",true)
		end
		if ((data.isdelirium and isaac.FrameCount % 100 == 0) or (not data.isdelirium and isaac.FrameCount % 50 == 0)) and spri:IsPlaying("4Idle") then
			isaac:PlaySound(267, 0.65, 0, false, 1)
			local params = ProjectileParams()
			params.Scale = 1.3
			params.Variant = 4
			params.FallingSpeedModifier = 0
			params.FallingAccelModifier = -0.12
			for i=0, 330, 30 do
				isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(6), 0, params)
			end
		end
		if isaac.StateFrame <= 0 then
			if rng:Random(1,4) == 1 and not data.isdelirium then
				spri:Play("4FBAttack",true)
				isaac.State = 88
				isaac.I1 = rng:Random(1,3)
			elseif rng:Random(1,4) == 2 and denpnapi then
				isaac.State = 99
				isaac.ProjectileCooldown = 201
			elseif rng:Random(1,4) == 3 and HMBPENTS then
				isaac.State = 100
			else
				spri:Play("4FBAttack2Start",true)
				isaac.State = 80
				isaac.I1 = rng:Random(1,3)
				isaac.ProjectileCooldown = 0
			end
		end
		if isaac.TargetPosition:Distance(isaac.Position) <= 75 then
			isaac.TargetPosition = Isaac.GetRandomPosition(0)
		end
		if spri:IsPlaying("4Idle") then
			if data.isdelirium then
				data.vlength = 0.4
			else
				data.vlength = 0.9
			end
			isaac.Velocity = (isaac.Velocity * 0.9999) + Vector.FromAngle((isaac.TargetPosition - isaac.Position):GetAngleDegrees()):Resized(data.vlength)
		else
			isaac.Velocity = isaac.Velocity * 0.99
		end
	elseif isaac.State == 28 then
		if spri:IsPlaying("3FBAppear2") then
			if spri:GetFrame() == 1 then
				isaac:PlaySound(214, 1, 0, false, 1)
			elseif spri:GetFrame() == 26 then
				isaac:PlaySound(52, 1, 0, false, 1)
				for i = 0, 315, 45 do
					local lwave = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("BeamWave"), 0, isaac.Position + Vector.FromAngle(i):Resized(20), Vector(0,0), isaac)
					lwave.Parent = isaac
					lwave:ToEffect().Rotation = i
				end
			end
			if spri:GetFrame() <= 25 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end

		if spri:IsFinished("3FBAttack3") then
			spri:Play("3FBAppear2",true)
			isaac.Position = target.Position
		elseif spri:IsFinished("3FBAppear2") then
			isaac.State = 3
		end
	elseif isaac.State == 15 then
		isaac.StateFrame = isaac.StateFrame + 1
		if isaac.Velocity.X < 0 then
			isaac.FlipX = true
		else
			isaac.FlipX = false
		end
		if spri:IsFinished("3FBAttack6Ready") then
			isaac.StateFrame = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac.Velocity = Vector.FromAngle((target.Position-isaac.Position):GetAngleDegrees()):
			Resized(32)
		end
		if not spri:IsPlaying("3FBAttack6Ready") then
			if isaac.Velocity.Y < 0 then
				isaac:SetSpriteFrame("3FBAttack6Up", isaac.StateFrame+1)
			else
				isaac:SetSpriteFrame("3FBAttack6Down", isaac.StateFrame+1)
			end
			if isaac.FrameCount % 3 == 0 and isaac.StateFrame <= 15 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.Acceleration = 0.94
				for i=90, 130, 40 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()-i):Resized(13), 0, params)
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()+i):Resized(13), 0, params)
				end
			end
			if isaac.StateFrame >= 36 then
				isaac.FlipX = false
				if isaac.I1 <= 0 then
					spri:SetFrame("3FBAttack4End", 27)
					isaac.State = 8
				else
					isaac.I1 = isaac.I1 - 1
					spri:Play("3FBAttack6Ready",true)
				end
			end
		end
	elseif isaac.State == 12 then
		if spri:IsPlaying("3FBAttack3") then
			if spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
				isaac.I1 = 6
				for i=1, 3 do
					Isaac.Spawn(1000, 19, 999, Isaac.GetRandomPosition(0), Vector(0,0), isaac)
				end
			elseif spri:GetFrame() == 26 then
				isaac.Visible = false
			end
			if spri:GetFrame() >= 22 then
				isaac.EntityCollisionClass = 0
			end
		end
		if not isaac.Visible then
			if Room:GetAliveEnemiesCount() <= 4 and isaac.FrameCount % 30 == 0 then
				isaac.I1 = isaac.I1 - 1
				if isaac.I1 > 1 then
					Isaac.Spawn(1000, 19, 999, Isaac.GetRandomPosition(0), Vector(0,0), isaac)
				end
			end
			if isaac.I1 <= 0 and Room:GetAliveEnemiesCount() <= 1 then
				isaac.Visible = true
				isaac.State = 28
				spri:Play("3FBAppear2",true)
				isaac.Position = target.Position
			end
		end
		if spri:IsPlaying("3Summon") and spri:GetFrame() == 11 then
			isaac.I1 = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac:PlaySound(265, 1, 0, false, 1)

			if rng:Random(1, 2) == 2 and denpnapi then
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0, isaac.Position+Vector.FromAngle(90):Resized(40), Vector(0,0), isaac)
			else
				Isaac.Spawn(38, 1, 0, isaac.Position+Vector.FromAngle(90):Resized(40), Vector(0,0), isaac)
			end
		end
		if spri:IsFinished("3Summon") then
			spri:Play("3Idle",true)
			isaac.State = 3
		end
	elseif isaac.State == 10 then
		if spri:IsFinished("3FBAttack3") then
			if isaac.I1 > 0 then
				spri:Play("3Appear",true)
				data.i3 = rng:Random(0,7)
				data.dash = false
				if data.i3 == 0 then
					isaac.Position = Room:GetTopLeftPos()
				elseif data.i3 == 1 then
					isaac.Position = Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y)
				elseif data.i3 == 2 then
					isaac.Position = Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y)
				elseif data.i3 == 3 then
					isaac.Position = Room:GetBottomRightPos()
				else
					isaac.Position = Room:GetDoorSlotPosition(rng:Random(0,data.door))
					isaac.StateFrame = 55
				end
			else
				if HMBPENTS then
					isaac.State = 28
					isaac.EntityCollisionClass = 0
				else
					spri:Play("3Appear",true)
					isaac.Position = Isaac.GetRandomPosition(0)
				end
			end
		end
		if spri:IsFinished("3Appear") then
			if isaac.I1 > 0 then
				if data.i3 > 3 then
					spri:Play("3Idle",true)
					isaac.StateFrame = 50
				else
					spri:Play("3FBAttack6Ready",true)
				end
			else
				isaac.State = 3
			end
		end
		if data.i3 < 4 then
			isaac.StateFrame = isaac.StateFrame + 1
		if isaac.Velocity.X < 0 then
			isaac.FlipX = true
		else
			isaac.FlipX = false
		end
		if spri:IsFinished("3FBAttack6Ready") and not data.dash then
			isaac.StateFrame = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			data.dash = true
			if data.i3 == 0 then
				isaac.Velocity = Vector.FromAngle((Room:GetBottomRightPos()-isaac.Position)
				:GetAngleDegrees()):Resized(Room:GetBottomRightPos():Distance(isaac.Position)*0.11)
			elseif data.i3 == 1 then
				isaac.Velocity = Vector.FromAngle((Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y)-isaac.Position)
				:GetAngleDegrees()):Resized(Vector(Room:GetTopLeftPos().X,Room:GetBottomRightPos().Y):Distance(isaac.Position)*0.11)
			elseif data.i3 == 2 then
				isaac.Velocity = Vector.FromAngle((Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y)-isaac.Position)
				:GetAngleDegrees()):Resized(Vector(Room:GetBottomRightPos().X,Room:GetTopLeftPos().Y):Distance(isaac.Position)*0.11)
			elseif data.i3 == 3 then
				isaac.Velocity = Vector.FromAngle((Room:GetTopLeftPos()-isaac.Position)
				:GetAngleDegrees()):Resized(Room:GetTopLeftPos():Distance(isaac.Position)*0.11)
			end
		end
		if data.dash then
			if isaac.Velocity.Y < 0 then
				isaac:SetSpriteFrame("3FBAttack6Up", isaac.StateFrame+1)
			else
				isaac:SetSpriteFrame("3FBAttack6Down", isaac.StateFrame+1)
			end
			if isaac.FrameCount % 2 == 0 and isaac.StateFrame <= 20 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.Acceleration = 1.075
				params.FallingAccelModifier = -0.1
				for i=-90, 90, 180 do
					isaac:FireProjectiles(isaac.Position, Vector.FromAngle((isaac.Velocity):GetAngleDegrees()+i):Resized(0.5), 0, params)
				end
			end
			if isaac.StateFrame >= 36 and not spri:IsPlaying("3FBAttack3") then
				isaac.FlipX = false
				isaac.I1 = isaac.I1 - 1
				data.i3 = 0
				spri:Play("3FBAttack3",true)
				data.dash = false
			end
		end
		else
		if spri:IsPlaying("3Idle") then
			isaac.StateFrame = isaac.StateFrame - 1
			if isaac.StateFrame > 0 then
				if isaac:HasEntityFlags(1<<9) then
					angle = angle + 3
				else
					angle = (target.Position - isaac.Position):GetAngleDegrees()
				end
			end
			isaac.Velocity = (isaac.Velocity * 0.9) + Vector.FromAngle(angle):Resized(2.05)
			if isaac.FrameCount % 8 == 0 and isaac.I1 > 0 then
				isaac:PlaySound(153, 1, 0, false, 1)
				local params = ProjectileParams()
				params.Scale = 1.5
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.BURST
				isaac:FireProjectiles(isaac.Position, Vector(0,0), 0, params)
			end
			if isaac.StateFrame <= 0 then
				isaac.I1 = isaac.I1 - 1
				spri:Play("3FBAttack3",true)
			end
		end
		end
	elseif isaac.State == 9 then
		if spri:IsPlaying("2Attack2") and spri:GetFrame() == 28 then
			for i=10, 280, 90 do
				local Laser = EntityLaser.ShootAngle(3, isaac.Position+Vector(0,1), i+(math.floor(data.i3/(10^((i-10)/90))) % 10)*7, 20, Vector(0,-20), isaac)
				Laser.CollisionDamage = 22.5
			end
		end
		if spri:IsFinished("2Attack2") then
			data.i3 = 0
			isaac.I1 = -1
			spri:SetFrame("2Attack", 29)
			isaac.State = 8
		end
		if spri:IsPlaying("3Appear") and not data.isdelirium and HMBPETNS then
			isaac.State = 28
			spri:Play("3FBAppear2",true)
			isaac.Position = target.Position
			isaac.EntityCollisionClass = 0
		end
		if spri:IsPlaying("3FBAttack3") and spri:GetFrame() == 1 then
			if rng:Random(1,3) == 1 then
				isaac.State = 10
				isaac.I1 = rng:Random(2, 4)
			elseif rng:Random(1,3) == 2 then
				isaac.State = 12
			end
		end
		if spri:IsPlaying("1Attack") then
			if data.i3 > 0 then
				if isaac.I1 == 1 then
					if (data.i3 < data.start and spri:GetFrame() == 5) or (data.i3 >= data.start and spri:GetFrame() == 9) then
						spri:Play("1Attack",true)
					end
				elseif isaac.I1 == 2 then
					if spri:GetFrame() == 12 then
						spri:Play("1Attack",true)
					end
				end
				if spri:GetFrame() == 1 then
					data.i3 = data.i3 - 1
				end
			end
			if data.i3 < data.start and spri:GetFrame() == 1 then
				isaac:PlaySound(267, 0.65, 0, false, 1)
				local params = ProjectileParams()
				params.Variant = 4

				if isaac.I1 == 1 then
					if HMBPENTS then
						local params2 = HMBPEnts.ProjParams()
						params2.FallingSpeedModifier = -30
						params2.FallingAccelModifier = 1.2
						params2.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params2.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params2.ChangeTimeout = 28
						params2.ChangeFlags = 0
						params2.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.NOFALL
						params2.CurvingStrength = 0.016

						for i=0, 315, 45 do
							HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(i):Resized(13), params2)
						end
					else
						params.FallingSpeedModifier = -30
						params.FallingAccelModifier = 1.2
						params.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						params.ChangeTimeout = 28
						params.ChangeFlags = 0
						params.CurvingStrength = 0.016

						for i=0, 315, 45 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(13), 0, params)
						end
					end
				elseif isaac.I1 == 2 then
					params.FallingSpeedModifier = -40
					params.FallingAccelModifier = 1
					params.BulletFlags = ProjectileFlags.ACCELERATE
					params.Acceleration = 0.945
					params.Scale = 1
					for i=-3.5, 3.5, 1 do
						isaac:FireProjectiles(isaac.Position, Vector(12*1.2,(i*1.2)*2), 0, params)
						isaac:FireProjectiles(isaac.Position, Vector(-12*1.2,(i*1.2)*2), 0, params)
					end
					for i=-6, 6, 1 do
						isaac:FireProjectiles(isaac.Position, Vector((i*1.2)*2,7*1.2), 0, params)
						isaac:FireProjectiles(isaac.Position, Vector((i*1.2)*2,-7*1.2), 0, params)
					end
				end
			end
		end
		if spri:IsFinished("1Attack") then
			isaac.State = 8
		end
	elseif isaac.State == 8 then
		if spri:IsPlaying("1Idle") and rng:Random(1,2) == 1 then
			isaac.State = 9
			spri:Play("1Attack",true)
			isaac.I1 = rng:Random(1, 2)
			data.i3 = isaac.I1 == 2 and rng:Random(3, 4) or  rng:Random(4, 7)
			data.start = data.i3 - 1
		end
		if spri:IsPlaying("2Attack") then
			if data.LsrReady and spri:GetFrame() == 1 then
				data.LsrReady = false
				spri:Play("2Attack2",true)
				isaac.State = 9
				data.i3 = 0
				for i=0, 3 do
					data.i3 = data.i3+rng:Random(0,9)*(10^i)
				end
				local params = ProjectileParams()
				params.Variant = 4
				params.BulletFlags = ProjectileFlags.ACCELERATE
				params.HeightModifier = -12
				params.FallingAccelModifier = 0.1
				params.Acceleration = 0.9
				for i=10, 280, 90 do
					isaac:FireProjectiles(isaac.Position,
					Vector.FromAngle(i+(math.floor(data.i3/(10^((i-10)/90))) % 10)*7):Resized(10), 0, params)
				end
			end
			if isaac.I1 == 1 and spri:GetFrame() == 2 then
				data.LsrReady = true
			end
		end
		if spri:IsPlaying("3FBAttack4Start") and spri:GetFrame() == 1 then
			if rng:Random(1,3) == 2 and Room:GetAliveEnemiesCount() <= 2 and isaac.FrameCount % 100 <= 30 then
				spri:Play("3Summon",true)
				isaac.State = 12
			elseif rng:Random(1,3) == 3 then
				targetangle = (target.Position - isaac.Position):GetAngleDegrees()
				isaac.State = 15
				isaac.I1 = rng:Random(1,3)
				spri:Play("3FBAttack6Ready",true)
			end
		end
	elseif isaac.State == 0 then
		data.LsrReady = false
	end

	if isaac.State > 9 then
		if spri:IsPlaying("3Appear") then
			if spri:GetFrame() == 1 then
				isaac:PlaySound(214, 1, 0, false, 1)
			end
			if spri:GetFrame() <= 7 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end
		if spri:IsPlaying("3FBAttack3") then
			if spri:GetFrame() == 20 then
				isaac:PlaySound(215, 1, 0, false, 1)
			end
			if spri:GetFrame() >= 22 then
				isaac.EntityCollisionClass = 0
			else
				isaac.EntityCollisionClass = 4
			end
		end
	end

end
end

HMBP:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft) --Crack The Sky
	if eft.SubType == 999 and eft.FrameCount == 18 and eft.SpawnerType == 102 then
		SFXManager():Play(265, 0.85, 0, false, 1)

		if rng:Random(1, 2) == 1 and denpnapi then
			Isaac.Spawn(554, Isaac.GetEntityVariantByName("Crying Gaper"), 0, eft.Position, Vector(0,0), eft) --Crying Gaper
		else
			Isaac.Spawn(38, 1, 0, eft.Position, Vector(0,0), eft) --Angelic Baby
		end
	end
end, 19)

----------------------------
--add Boss Pattern:???
----------------------------
function HMBP:BBaby(isaac)
	if isaac.Variant == 1 and game.Difficulty % 2 == 1 then

		local spr = isaac:GetSprite()
		local Entities = Isaac:GetRoomEntities()
		local target = isaac:GetPlayerTarget()
		local data = isaac:GetData()
		local angle = (target.Position - isaac.Position):GetAngleDegrees()
		local Room = game:GetRoom()

		if isaac.State == 8 and spr:IsPlaying("1Idle") and rng:Random(1,2) == 1 then
			if denpnapi then
				spr:Play("1Attack",true)
				isaac.State = 9
				isaac.I1 = rng:Random(1,2)
				data.i3 = rng:Random(5,9)
				data.start = data.i3 - 1
			end
		end

		if not data.init then
			data.init = true
			data.Xsttpos = Vector(0,0)
			data.Ysttpos = Vector(0,0)
			data.intervalX = 0
			data.intervalY = 0
			data.lrtt = 0
			data.Xendpos = 0
			data.Yendpos = 0
		end

		if (spr:IsFinished("2Attack") and rng:Random(1,2) == 1) or (isaac.HitPoints/isaac.MaxHitPoints < 0.5 and isaac.FrameCount % 110 == 0) then
			local sucker = Isaac.Spawn(61, 0, 0, isaac.Position + Vector.FromAngle(rng:Random(0,360)):Resized(70), Vector(0,0), isaac)
			sucker:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end

		if spr:IsPlaying("4FBAttackStart") and spr:GetFrame() == 21 then
			isaac:PlaySound(215, 1, 0, false, 1)
			isaac.EntityCollisionClass = 0
		end

		if isaac.State == 157 then
			if spr:IsFinished("4FBAttackStart") then
				spr:Play("4Appear", true)
				isaac:PlaySound(214, 1, 0, false, 1)
				isaac.I1 = rng:Random(1,4)
				if isaac.I1 == 1 then
					isaac.Position = Vector(Room:GetCenterPos().X*(0.3+(rng:Random(0,1)*1.4)),
					Room:GetCenterPos().Y)
				else
					isaac.Position = Isaac.GetRandomPosition(0)
					for i=0, 3 do
						if game:GetNearestPlayer(isaac.Position).Position:Distance(isaac.Position) <= 70 then
							isaac.Position = Isaac.GetRandomPosition(0)
						else
							break
						end
					end
				end
			elseif spr:IsFinished("4Appear") then
				if isaac.I1 == 1 then
					spr:Play("4FBAttack3", true)
					isaac.State = 99
				else
					if rng:Random(1,2) == 1 and isaac:GetAliveEnemyCount() <= 2 then
						spr:Play("4Summon", true)
						isaac.State = 120
					else
						spr:Play("4FBAttack2Start", true)
						isaac.I1 = rng:Random(1,4)
						isaac.State = 88
						data.pangle = angle
						if isaac.I1 == 4 and not data.isdelirium then
							local params = ProjectileParams()
							params.BulletFlags = ProjectileFlags.ACCELERATE
							params.FallingAccelModifier = 0.05
							params.Acceleration = 0.96
							params.HeightModifier = -20
							params.Variant = 4
							for i=0, 315, 45 do
								isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+angle):Resized(7), 0, params)
							end
						end
					end
				end
			end
			if spr:IsPlaying("4Appear") and spr:GetFrame() == 5 then
				isaac.EntityCollisionClass = 4
			end
		elseif isaac.State == 120 then
			if spr:IsPlaying("4Summon") and spr:GetFrame() == 24 then
				isaac:PlaySound(129, 1, 0, false, 1)
				isaac:PlaySound(265, 1, 0, false, 1)
				for i=0, 270, 90 do
					Isaac.Spawn(26, Isaac.GetEntityVariantByName("Blue Maw"), 0, isaac.Position + Vector.FromAngle(i):Resized(40), Vector(0,0), isaac)
				end
			end
			if spr:IsFinished("4Summon") then
				spr:Play("4FBAttackStart", true)
				isaac.State = 157
			end
		elseif isaac.State == 99 then
			if spr:IsPlaying("4FBAttack3") then
				if spr:GetFrame() >= 32 and spr:GetFrame() <= 55 then
					if spr:GetFrame() == 32 then
						isaac:PlaySound(129, 1, 0, false, 1)
						if isaac.Position.X >= Room:GetCenterPos().X then
							isaac.FlipX = true
							isaac.Velocity = Vector(((Room:GetCenterPos().X*0.1)-isaac.Position.X)*0.1,0)
						else
							isaac.Velocity = Vector(57,0)
							isaac.Velocity = Vector(((Room:GetCenterPos().X*1.9)-isaac.Position.X)*0.1,0)
						end
					end
					if spr:GetFrame() % 4 == 1 then
						isaac:PlaySound(267, 0.65, 0, false, 1)
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.185
						params.BulletFlags = ProjectileFlags.ACCELERATE
						params.Acceleration = 1.07
						params.Variant = 4
						for i=45, 315, 90 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(0.1), 0, params)
						end
					end
				end
			end
			if spr:IsFinished("4FBAttack3") then
				spr:Play("4FBAttackStart", true)
				isaac.State = 157
				isaac.FlipX = false
			end
		elseif isaac.State == 88 then
			if spr:IsFinished("4FBAttack2Start") then
				spr:Play("4FBAttack2Loop", true)
				isaac:PlaySound(129, 1, 0, false, 1)
				isaac.ProjectileCooldown = 0
				if isaac.I1 == 4 and not data.isdelirium then
					isaac.StateFrame = 70
					for i=0, 315, 45 do
						local tlaser = EntityLaser.ShootAngle(3, isaac.Position, i+data.pangle, 55, Vector(0,-20), isaac)
						if isaac.Position.X < target.Position.X then
							tlaser:SetActiveRotation(15, -45, -0.5, false)
						else
							tlaser:SetActiveRotation(15, 45, 0.5, false)
						end
					end
				else
					isaac.StateFrame = rng:Random(20,50)
				end
			elseif spr:IsFinished("4FBAttack2End") then
				isaac.State = 33
			end
			if spr:IsPlaying("4FBAttack2Loop") and isaac.StateFrame <= 0 then
				spr:Play("4FBAttack2End", true)
			end

			if isaac.StateFrame > 0 then
				isaac.StateFrame = isaac.StateFrame - 1
				isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1

				if isaac.ProjectileCooldown < 1 then
					isaac:PlaySound(267, 0.65, 0, false, 1)

					if isaac.I1 == 1 then
						isaac.ProjectileCooldown = 4
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.185
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						| ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
						params.ChangeTimeout = 75
						params.ChangeFlags = 0
						params.ChangeVelocity = 7
						params.Acceleration = 0.9
						params.Variant = 4
						for i=0, 315, 45 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.StateFrame*5)):Resized(10), 0, params)
						end
					elseif isaac.I1 == 2 then
						isaac.ProjectileCooldown = 5

						if HMBPENTS then
							local params = HMBPEnts.ProjParams()
							params.FallingAccelModifier = -0.083
							params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
							params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
							params.ChangeTimeout = 75
							params.ChangeFlags = ProjectileFlags.NO_WALL_COLLIDE
							params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
							params.Acceleration = 0.9
							params.HomingStrength = 0.6
							params.Color = Color(1,1,1,5,0,0,0)
							HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(isaac.StateFrame * 10):Resized(10), params)
						else
							local params = ProjectileParams()
							params.FallingAccelModifier = -0.083
							params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
							params.ChangeTimeout = 75
							params.ChangeFlags = ProjectileFlags.SMART | ProjectileFlags.NO_WALL_COLLIDE
							params.ChangeVelocity = 6
							params.Acceleration = 0.9
							params.HomingStrength = 0.6
							params.Variant = 4
							params.Color = Color(1,1,1,5,0,0,0)
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(isaac.StateFrame * 10):Resized(10), 0, params)
						end
					elseif isaac.I1 == 3 then
						isaac.ProjectileCooldown = 4
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.168
						params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
						| ProjectileFlags.CURVE_LEFT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
						params.ChangeTimeout = 75
						params.ChangeFlags = ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
						params.ChangeVelocity = 6
						params.Acceleration = 0.95
						params.Variant = 4
						params.CurvingStrength = 0.005
						for i=0, 270, 90 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.StateFrame*13)):Resized(8), 0, params)
						end
					elseif isaac.I1 == 4 then
						if not data.isdelirium then
							isaac.ProjectileCooldown = 20
						else
							isaac.ProjectileCooldown = 10
						end

						local params = ProjectileParams()
						params.FallingAccelModifier = -0.175
						params.Variant = 4

						for i=0, 300, 60 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(5), 0, params)
						end
					end
				end
			end
		elseif isaac.State == 66 then
			if spr:IsPlaying("Jump") then
				if isaac.FrameCount % 2 == 0 then
					local Div = REPENTANCE and 255 or 1

					local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
					creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
					creep:ToEffect().Timeout = 70
					creep:Update()
				end
				isaac.Velocity = isaac.Velocity * 0.33
				if spr:GetFrame() == 16 then
					if target.Position:Distance(isaac.Position) < 240 then
						isaac.TargetPosition = target.Position
					else
						isaac.TargetPosition = isaac.Position + Vector.FromAngle(angle):Resized(240)
					end
				elseif spr:GetFrame() == 30 then
					local Div = REPENTANCE and 255 or 1

					isaac:PlaySound(69, 1, 0, false, 1)
					isaac:PlaySound(153, 1.3, 0, false, 1)
					local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
					creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
					creep.SpriteScale = Vector(3,3)
					creep:Update()
					local params = ProjectileParams()
					params.Variant = 4
					params.FallingAccelModifier = 0.2
					for i=0, rng:Random(6,9) do
						params.Scale = rng:Random(5, 13) * 0.1
						params.FallingSpeedModifier = -rng:Random(30, 120) * 0.1
						isaac:FireProjectiles(isaac.Position, Vector.FromAngle(rng:RandomInt(359)):Resized(rng:Random(40,85)*0.1), 0, params)
					end
				end
			end
			if spr:IsFinished("Jump") then
				isaac.State = 3
				isaac.Velocity = Vector(0,0)
			end
		elseif isaac.State == 33 then
			isaac.StateFrame = isaac.StateFrame - 1
			if not spr:IsPlaying("4Idle") then
				spr:Play("4Idle", true)
				if isaac.HitPoints/isaac.MaxHitPoints >= 0.19 then
					isaac.StateFrame = 80
				elseif isaac.HitPoints/isaac.MaxHitPoints >= 0.13 then
					isaac.StateFrame = 55
				else
					isaac.StateFrame = 35
				end
				if data.isdelirium then
					isaac.StateFrame = isaac.StateFrame * 2
				end
			end
			if isaac.StateFrame <= 0 and spr:IsPlaying("4Idle") then
				spr:Play("4FBAttackStart", true)
				isaac.State = 157
			end
		elseif isaac.State == 11 then
			isaac.StateFrame = isaac.StateFrame - 1
			isaac.ProjectileCooldown = isaac.ProjectileCooldown - 1
			if spr:IsFinished("3FBAttack4Start") then
				spr:Play("3FBAttack4Loop", true)
			elseif spr:IsFinished("3FBAttack4End") then
				spr:Play("Idle3", true)
				isaac.State = 8
			end
			if spr:IsPlaying("3FBAttack4Start") and spr:GetFrame() == 21 then
				isaac:PlaySound(129, 1, 0, false, 1)
				data.attacking = true
			elseif spr:IsPlaying("3FBAttack4Loop") and isaac.StateFrame <= 0 then
				spr:Play("3FBAttack4End", true)
				data.attacking = false
			end
			if data.attacking then
				if isaac.I1 == 1 then
					if isaac.ProjectileCooldown <= 0 then
						isaac.ProjectileCooldown = 8
					elseif isaac.ProjectileCooldown == 1 then
						local angle = rng:RandomInt(359)
						isaac:PlaySound(267, 0.65, 0, false, 1)
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.165
						params.Variant = 4

						for i=-5.75, 5.75, 11.5 do
							for j=0, 25, 5 do
								isaac:FireProjectiles(isaac.Position,Vector.FromAngle(j + angle):Resized(i), 0, params)
							end
						end
					end
				elseif isaac.I1 == 2 then
					if isaac.ProjectileCooldown <= 0 then
						isaac.ProjectileCooldown = 19
						isaac:PlaySound(267, 0.65, 0, false, 1)
						local params = ProjectileParams()
						params.BulletFlags = 1
						params.Scale = 1.5
						for i=0, 300, 60 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i+(isaac.FrameCount % 2)*45):Resized(9), 0, params)
						end
					end
				end
			end
		elseif isaac.State == 9 then
			if spr:IsPlaying("1Attack") then
				if data.i3 > 0 then
					if isaac.I1 == 1 then
						if (data.i3 < data.start and spr:GetFrame() == 3) or (data.i3 >= data.start and spr:GetFrame() == 6) then
							spr:Play("1Attack",true)
						end
					elseif isaac.I1 == 2 then
						if spr:GetFrame() == 8 then
							spr:Play("1Attack",true)
						end
					end
					if spr:GetFrame() == 1 then
						data.i3 = data.i3 - 1
					end
				end
				if data.i3 < data.start and spr:GetFrame() == 1 then
					isaac:PlaySound(267, 0.65, 0, false, 1)

					if isaac.I1 == 1 then
						local params = HMBPEnts.ProjParams()
						params.FallingSpeedModifier = -20
						params.FallingAccelModifier = 0.5
						params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
						params.ChangeTimeout = 20
						params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
						params.Scale = 1.3
						params.HomingStrength = 1.2
						params.Color = Color(1,1,1,5,0,0,0)
						HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle((target.Position - isaac.Position):GetAngleDegrees() + rng:Random(-20, 20)):Resized(-5), params)
					elseif isaac.I1 == 2 then
						local params = HMBPEnts.ProjParams()
						params.FallingAccelModifier = -0.1
						params.HMBPBulletFlags = HMBPEnts.ProjFlags.GRAVITY_VERT

						for i=-3, 3, 6 do
							HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector(i / rng:Random(1, 2), rng:Random(-20, 20) * 0.1), params)
						end
					end
				end
			end
			if spr:IsFinished("1Attack") then
				isaac.State = 8
			end
		elseif isaac.State == 8 then
			if spr:IsPlaying("3FBAttack4Start") and spr:GetFrame() == 1 then
				if rng:Random(1,4) == 1 and denpnapi then
					if Room:GetAliveEnemiesCount() <= 20 and isaac.FrameCount % 150 <= 50 then
						spr:Play("3Summon",true)
						isaac.State = 12
					end
				elseif rng:Random(1,4) == 2 and HMBPENTS then
					isaac.I1 = rng:Random(2,4)
					data.i3 = rng:Random(1,6)
					spr:Play("3FBAttack5w"..data.i3,true)
					isaac.State = 10
				elseif rng:Random(1,4) == 3 then
					isaac.State = 11
					isaac.StateFrame = rng:Random(50,100)
					isaac.I1 = rng:Random(1,2)
					isaac.ProjectileCooldown = 0
				end
			end
			if spr:IsPlaying("2Attack") then
				if spr:GetFrame() == 2 then
					if data.i3 == 1 then
						if isaac.I1 == 0 then
							isaac.I1 = 2
						elseif isaac.I1 == 1 then
							isaac.I1 = 3
							data.i3 = 0
						end
					else
						if isaac.I1 == 1 then
							data.i3 = 1
						end
					end
				elseif spr:GetFrame() == 8 then
					if isaac.I1 == 2 then
						if HMBPENTS then
							local params = HMBPEnts.ProjParams()
							params.FallingSpeedModifier = 0
							params.FallingAccelModifier = -0.135
							params.Scale = 1.5
							params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.NO_WALL_COLLIDE
							params.HMBPBulletFlags = HMBPEnts.ProjFlags.CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT
							params.ChangeTimeout = 40
							params.ChangeFlags = ProjectileFlags.NO_WALL_COLLIDE
							params.ChangeHMBPEntsBFlags = HMBPEnts.ProjFlags.SMART2
							params.Acceleration = 0.92
							params.Color = Color(1,1,1,5,0,0,0)

							for i=0, 300, 60 do
								HMBPEnts.FireProjectile(isaac, 4, isaac.Position, Vector.FromAngle(i):Resized(10), params)
							end
						else
							local params = ProjectileParams()
							params.FallingSpeedModifier = 0
							params.FallingAccelModifier = -0.135
							params.BulletFlags = 1
							params.Scale = 1.5
							params.Color = Color(1,1,1,5,0,0,0)

							for i=0, 300, 60 do
								isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(10), 0, params)
							end
						end
					elseif isaac.I1 == 3 then
						local params = ProjectileParams()
						params.Variant = 4
						params.BulletFlags = ProjectileFlags.BURST3
						params.FallingAccelModifier = -0.15
						params.Scale = 1.5

						for i=0, 270, 90 do
							isaac:FireProjectiles(isaac.Position, Vector.FromAngle(i):Resized(2), 0, params)
						end
					end
				end
			end
			if spr:IsFinished("2Attack") then
				if isaac.I1 == 3 then
					isaac.I1 = 1
				elseif isaac.I1 == 2 then
					isaac.I1 = 0
				end
			end
		elseif isaac.State == 3 then
			if spr:IsFinished("2Idle") then
				if isaac.FrameCount % 70 == 0 then
					local Div = REPENTANCE and 255 or 1

					local creep = Isaac.Spawn(1000, 22, 0, isaac.Position, Vector(0,0), isaac)
					creep.Color = Color(1, 1, 1, 1, 19 / Div, 208 / Div, 255 / Div)
					creep:ToEffect().Timeout = 70
					creep:Update()
				end
				if isaac.FrameCount % 85 == 0 then
					spr:Play("Jump",true)
					isaac.State = 66
				end
			end
		end

		if isaac.State == 10 then
		if spr:GetFrame() == 1 then
			if data.i3 == 1 then
				data.intervalX = 120
				data.lrtt = 270
				if Room:GetRoomShape() >= 6 then
					data.Xendpos = 1080
				else
					data.Xendpos = 480
				end
				if (Room:GetRoomShape() >= 4 and Room:GetRoomShape() <= 6)
				or Room:GetRoomShape() >= 8 then
					data.Xsttpos = Vector(120,720)
				else
					data.Xsttpos = Vector(120,440)
				end
			elseif data.i3 == 2 then
				data.Xsttpos = Vector(80,120)
				data.intervalX = 120
				data.lrtt = 90
				if Room:GetRoomShape() >= 6 then
					data.Xendpos = 1120
				else
					data.Xendpos = 560
				end
			elseif data.i3 == 3 then
				data.Xsttpos = Vector(200,120)
				data.intervalX = 200
				data.intervalY = 200
				data.lrtt = 135
				if Room:GetRoomShape() >= 6 then
					data.Xendpos = 1000
					data.Ysttpos = Vector(1120,0)
					if Room:GetRoomShape() >= 8 then
						data.Yendpos = 600
					else
						data.Yendpos = 400
					end
				else
					data.Xendpos = 600
					data.Ysttpos = Vector(600,-80)
					if Room:GetRoomShape() >= 4 then
						data.Yendpos = 520
					else
						data.Yendpos = 320
					end
				end
			elseif data.i3 == 4 then
				data.Xsttpos = Vector(40,120)
				data.Ysttpos = Vector(40,240)
				data.intervalX = 200
				data.intervalY = 100
				data.lrtt = 45
				if Room:GetRoomShape() >= 6 then
					data.Xendpos = 1040
				else
					data.Xendpos = 440
				end
				if Room:GetRoomShape() == 4 or Room:GetRoomShape() == 5
				or Room:GetRoomShape() >= 8 then
					data.Yendpos = 540
				else
					data.Yendpos = 340
				end
			elseif data.i3 == 5 then
				data.intervalY = 120
				data.lrtt = 180
				if Room:GetRoomShape() <= 5 then
					data.Ysttpos = Vector(600,100)
				else
					data.YsttposX = Vector(1120,100)
				end
				if (Room:GetRoomShape() >= 4 and Room:GetRoomShape() <= 6)
				or Room:GetRoomShape() >= 8 then
					data.Yendpos = 700
				else
					data.Yendpos = 340
				end
			else
				data.Ysttpos = Vector(40,40)
				data.intervalY = 120
				data.lrtt = 0
				if (Room:GetRoomShape() == 4 or Room:GetRoomShape() == 5)
				or Room:GetRoomShape() >= 8 then
					data.Yendpos = 760
				else
					data.Yendpos = 400
				end
			end
			if data.i3 < 5 then
				for i=data.Xsttpos.X, data.Xendpos, data.intervalX do
					local light = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("HolyBeam Warn"), 0, Vector(i,data.Xsttpos.Y), Vector(0,0), isaac)
					light:ToEffect().Rotation = data.lrtt
					light.SpawnerEntity = isaac
				end
			end
			if data.i3 > 2 then
				for i=data.Ysttpos.Y, data.Yendpos, data.intervalY do
					if i >= data.Ysttpos.Y + data.intervalY then
						local light = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("HolyBeam Warn"), 0, Vector(data.Ysttpos.X,i), Vector(0,0), isaac)
						light:ToEffect().Rotation = data.lrtt
						light.SpawnerEntity = isaac
					end
				end
			end
		end

		if spr:IsFinished("3FBAttack5w"..data.i3) then
			isaac.I1 = isaac.I1 - 1
			if isaac.I1 <= 0 then
				isaac.State = 3
			end
			data.i4 = data.i3
			for i=1, 20 do
				data.i3 = rng:Random(1,6)
				if data.i3 ~= data.i4 then
					break
				end
			end
			spr:Play("3FBAttack5w"..data.i3, true)
		end
		end

		if spr:IsPlaying("3Summon") and spr:GetFrame() == 11 then
			isaac.I1 = 0
			isaac:PlaySound(129, 1, 0, false, 1)
			isaac:PlaySound(265, 1, 0, false, 1)

			for i=0, 90, 90 do
				Isaac.Spawn(26, Isaac.GetEntityVariantByName("Blue Maw"), 0, isaac.Position+Vector.FromAngle(45+i):Resized(70), Vector(0,0), isaac)
			end
		end

		if spr:IsFinished("3Summon") then
			isaac.State = 3
		end
	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.IsaacAndBlueBaby, 102)
HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.Isaac, 102)
HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.BBaby, 102)
