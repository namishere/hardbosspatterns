local snd = SFXManager()
local Level = Game():GetLevel()

----------------------------
--Effects
----------------------------
--Blue Flame--
HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	for k, p in pairs(Isaac.FindByType(1, -1, -1, true, true)) do
		if eft.SubType == 10 and p.Position:Distance(eft.Position) <= 13 + p.Size then
			p:TakeDamage(1, 0, EntityRef(eft), 1)
		end
	end

	if eft.SubType == 10 and eft.Timeout == 1 then
		local poof = Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft) --Poof01
		poof:SetColor(Color(0.3, 0.3, 1.5, 2, 0, 0, 0), 99999, 0, false, false)
	end

	if eft.SpawnerType == 273 and eft.SpawnerVariant == 10 and Game().Difficulty % 2 == 1 then
		eft:Remove()
	end

	if (eft.SpawnerType == 400 or eft.SpawnerType == 273) and eft.SpawnerVariant == 0 and eft.Parent and eft.Parent:IsDead() then
		eft:Remove()
	end
end, 10)

--BrimStone Impact--
HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()

	if eft.SubType == (REPENTANCE and 6 or 1) and eft.Parent then
		local prdata = eft.Parent:GetData()

		if eft.SubType == (REPENTANCE and 6 or 1) and eft.Parent.Type == 7 and eft.Parent.Variant == eft.SubType then
			if eft.Parent.Size >= (REPENTANCE and 70 or 80) and eft.Parent.SpawnerType == 406 then
				if espr:GetFilename() ~= "gfx/brimstoneimpact coin.anm2" then
					espr:Load("gfx/brimstoneimpact coin.anm2", true)
					espr:Play("Start", true)
				end

				if espr:IsFinished("Start") then
					espr:Play("Loop", true)
				end
			end
		end

		if eft.Parent:ToLaser().Timeout > 0 and eft.FrameCount % 11 == 3 and prdata.lflag then
			if prdata.lflag == 1 then
				for i=0, 360 - 360 / prdata.pdensity, 360 / prdata.pdensity do
					local proj = Isaac.Spawn(9, 0, 0, eft.Position + eft.PositionOffset + Vector.FromAngle(espr.Rotation + 90):Resized(30),
					Vector.FromAngle(i + (eft.FrameCount % 2)*(180 / prdata.pdensity)):Resized(prdata.pvl), eft):ToProjectile()
					proj.FallingAccel = -0.09
				end
			end
		end
	end
end, 50)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	local espr = eft:GetSprite()

	if math.random(1, 2) == 1 then
		eft.FlipX = true
		Game():SpawnParticles(eft.Position, 4, math.random(6, 13), 13, Color(1, 1, 1, 1, 0, 0, 0), 0) --Rock Particle
	end
end, Isaac.GetEntityVariantByName("Ultra Greed Coin (Burst)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	if eft.SpawnerType == 1000 and eft.SpawnerVariant == 368 and eft.FrameCount <= 1 then
		Game():SpawnParticles(eft.Position, 95, 3, 8, Color(1.1, 1, 1, 1, 0, 0, 0), 0) --Diamond Particle
	end

	if espr:IsPlaying("Move") and espr:GetFrame() == 38 then
		if eft.SubType == 1 then
			Isaac.Explode(eft.Position, eft.Parent, 40)
			eft:Remove()
		else
			SFXManager():Play(427, 1, 0, false, 1) --SOUND_ULTRA_GREED_COIN_DESTROY

			for i=0, 270, 90 do
				local cproj = Isaac.Spawn(9, 7, 0, eft.Position, Vector.FromAngle(i):Resized(9), eft):ToProjectile() --Coin Projectile
				cproj.FallingSpeed = -5
				cproj.FallingAccel = 0.1
			end
		end

		eft.Velocity = Vector(0,0)
	end

	if espr:IsFinished("Move") then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Ultra Greed Coin (Burst)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	for i=1, 9, 8 do
		eft:GetSprite():ReplaceSpritesheet(i, "gfx/bosses/afterbirthplus/lamb2_body.png")
	end

	eft:GetSprite():LoadGraphics()
end, Isaac.GetEntityVariantByName("The Lamb II's Clone2"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local Room = Game():GetRoom()

	if not eft.TargetPosition then
		eft.TargetPosition = eft.Position
	end

	eft.Velocity = Vector.FromAngle((eft.TargetPosition-eft.Position):GetAngleDegrees()):Resized(eft.TargetPosition:Distance(eft.Position)*0.075)

	if eft.FrameCount == 15 then
		espr:Play("HeadJump", true)
	end

	if espr:IsFinished("HeadJump") and eft.Timeout <= 0 then
		local Div = REPENTANCE and 255 or 1

		espr:Play("HeadFallVanish", true)

		local mark = Isaac.Spawn(1000, 764, 0, eft.Position, Vector(0,0), eft)
		mark.Color = Color(1, 1, 1, 1, 200 / Div, 50 / Div, 240 / Div)
	elseif espr:IsFinished("HeadFallVanish") then
		eft:Remove()
	end

	if eft.Position.X >= Room:GetBottomRightPos().X or eft.Position.X <= Room:GetTopLeftPos().X then
		eft.Velocity = Vector(0, eft.Velocity.Y)
	end

	if eft.Position.Y >= Room:GetBottomRightPos().Y or eft.Position.Y <= Room:GetTopLeftPos().Y then
		eft.Velocity = Vector(eft.Velocity.X, 0)
	end

	if espr:IsPlaying("HeadFallVanish") then
		if espr:IsEventTriggered("Stomp") then
			local wave = Isaac.Spawn(1000, 61, 0, eft.Position, Vector(0,0), eft):ToEffect() --ShockWave(Radial)
			wave.Parent = eft.Parent
			wave.Timeout = 10
			wave.MaxRadius = 80

			if denpnapi then
				SpawnGroundParticle(true, eft, 10, 10, 3, 15)
			end
		end
	end
end, Isaac.GetEntityVariantByName("The Lamb II's Clone2"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	eft.Timeout = 10
end, Isaac.GetEntityVariantByName("Afterimage"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local data = eft:GetData()

	if not data.Sub then
		data.Sub = eft.Color.A / 10
	end

	if eft.Timeout <= 0 then
		eft:Remove()
	end

	eft.Color = Color(eft.Color.R, eft.Color.G, eft.Color.B, eft.Color.A - data.Sub, eft.Color.RO, eft.Color.GO, eft.Color.BO)
end, Isaac.GetEntityVariantByName("Afterimage"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	if eft.SubType ~= 1 then return end

	eft:GetSprite():Play("Break", true)
end, Isaac.GetEntityVariantByName("Golden Ground Break"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	if eft.SubType == 1 and eft.FrameCount == 1 then
		eft.SpriteScale = Vector(eft.Scale,eft.Scale)
	end

	if espr:IsFinished(espr:GetDefaultAnimationName()) then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Golden Ground Break"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	if espr:IsFinished(espr:GetDefaultAnimationName()) then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Bullet Poof(Delirium)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	if eft.FrameCount <= 1 then
		if eft.SubType == 4 then
			eft.m_Height = -40
			espr:Play("Piece5",true)
			eft.Velocity = Vector(-1, -1)
			eft.FallingAcceleration = -4
		elseif eft.SubType == 5 then
			eft.m_Height = -20
			espr:Play("Piece6",true)
			eft.Velocity = Vector(0, -4)
			eft.FallingAcceleration = -1
		else
			eft.FallingAcceleration = -2
			eft.m_Height = -30

			if eft.SubType == 1 then
				espr:Play("Piece2",true)
				eft.Velocity = Vector(-3, 3)
			elseif eft.SubType == 2 then
				espr:Play("Piece3",true)
				eft.Velocity = Vector(3, -3)
			elseif eft.SubType == 3 then
				espr:Play("Piece4",true)
				eft.Velocity = Vector(-3, -3)
			else
				eft.Velocity = Vector(3, 3)
			end
		end
	end

	if eft.m_Height >= 0 then
		eft:Remove()
		Game():SpawnParticles(eft.Position, 35, 13, 5, Color(1, 0.95, 0.9, 1, 0, 10 / (REPENTANCE and 255 or 1), 0), -24) --Tooth Particle
	end

	eft.FallingAcceleration = eft.FallingAcceleration + 0.3
	eft.m_Height = eft.m_Height + eft.FallingAcceleration
	eft.PositionOffset = Vector(0, eft.m_Height)
end, Isaac.GetEntityVariantByName("Pieces of Lamb"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()

	eft.DepthOffset = -40

	if espr:IsFinished("Appear") and eft.State == 0 then
		eft.State = 3

		if eft.SubType == 1 then
			eft.Timeout = 35
		else
			eft.Timeout = 150
			espr:PlayOverlay("In", true)
		end
	end

	if eft.State == 3 then
		if eft.SubType == 1 then
			if eft.Timeout == 10 then
				if edt.player.Variant == 0 then
					edt.player:AnimatePitfallOut()
				else
					Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft) --Poof01
				end

				edt.player.EntityCollisionClass = 4
				edt.player.ControlsEnabled = true
				edt.player.Visible = true
			end

			if eft.Timeout > 10 and eft:Exists() then
				edt.player.Position = eft.Position
				edt.player.Velocity = Vector(0,0)
			end
		else
			if espr:IsOverlayPlaying("In") and espr:GetOverlayFrame() == 52 and Isaac.GetPlayer(0).Position:Distance(eft.Position) > 500 then
				espr:PlayOverlay("In", true)
			end
		end

		if eft.Timeout <= 0 and eft.FrameCount > 12 then
			eft:Remove()
			Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft)
		end
	end

	if eft.State == 15 then
		if eft.Timeout <= edt.frame - 16  then
			edt.player.Visible = false
		end

		if eft.Timeout <= 0 then
			eft:Remove()
			edt.player:SetMinDamageCooldown(210)
		end

		if eft:IsDead() then
			edt.randpos = Isaac.GetRandomPosition(0)
			edt.player.Position = edt.randpos

			local etrapdoor = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Escape Trapdoor"), 1, edt.randpos, Vector(0,0), eft)
			etrapdoor:GetData().player = edt.player
			Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft)
		end
	end

	if not edt.Closed then
		for k, v in pairs(Isaac.FindByType(1, -1, -1, true, true)) do
			if v:ToPlayer() then

			local dist = v.Position:Distance(eft.Position)

			if eft.State == 3 and eft.SubType ~= 1 then
				if dist <= 32 then
					edt.player = v:ToPlayer()

					if edt.player.Variant == 0 then
						edt.player:AnimateTrapdoor()

						for k, v in pairs(Isaac.FindByType(1000, eft.Variant, 0, true, true)) do
							v:ToEffect().Timeout = 30
							v:GetData().Closed = true
						end

						for k, v in pairs(Isaac.FindByType(554, Isaac.GetEntityVariantByName("Memories III"), 1, true, true)) do
							v:ToNPC().StateFrame = 10
							v.Target = edt.player
						end
					else
						Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft)
						edt.player.Visible = false
					end

					edt.player.EntityCollisionClass = 0
					edt.player.ControlsEnabled = false
					edt.player:SetMinDamageCooldown(400)
					edt.player.Position = eft.Position
					edt.player.Velocity = Vector(0,0)
					eft.State = 15

					if eft.Timeout < 20 then
						eft.Timeout = 20
						edt.frame = 20
					else
						edt.frame = eft.Timeout
					end


				end
			end

			end
		end
	end
end, Isaac.GetEntityVariantByName("Escape Trapdoor"))

--Lamb Laser and Satan Downing Laser--
HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	eft.Timeout = 250
end, 759)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local player = Game():GetNearestPlayer(eft.Position)

	eft.Velocity = eft.Velocity * 0.9

	if espr:IsFinished("Start") then
		espr:Play("Loop", true)
	elseif espr:IsFinished("End") then
		eft:Remove()
	end

	if player.Position:Distance(eft.Position) <= 13 + player.Size and espr:IsPlaying("Loop") then
		player:TakeDamage(1, 0, EntityRef(eft), 1)
	end

	if espr:IsPlaying("Loop") and eft.Timeout <= 0 then
		espr:Play("End", true)
	end

	if eft.SubType == 0 then
		eft:AddVelocity(Vector.FromAngle((Game():GetNearestPlayer(eft.Position).Position - eft.Position):GetAngleDegrees()):Resized(1))

		for k, v in pairs(Isaac:GetRoomEntities()) do
			if v.Type == 1000 and v.Variant == eft.Variant and v.SubType == eft.SubType and v.Position:Distance(eft.Position) < 125 and v.Position:Distance(eft.Position) > 1 then
				v:AddVelocity(Vector.FromAngle((v.Position - eft.Position):GetAngleDegrees()):Resized(0.4))
			end
		end
	end
end, 759)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()

	if eft.SubType == 0 then
		edt.vel = 1.1
		edt.side = "Right"
	else
		edt.vel = -1.1
		edt.side = "Left"
	end

	if eft.FrameCount == 1 then
		espr:Play("AppearB"..eft.LifeSpan..edt.side, true)
	end

	if espr:IsFinished("AppearB"..eft.LifeSpan..edt.side) then
		espr:Play("ShootB"..eft.LifeSpan.."Loop"..edt.side, true)
	elseif espr:IsFinished("ShootB"..eft.LifeSpan.."End"..edt.side) then
		eft:Remove()
	end

	if espr:IsEventTriggered("ShootStart2") then
		edt.attacking = true
		eft.State = math.random(1, 2)
	elseif espr:IsEventTriggered("ShootStop2") then
		edt.attacking = false
	end

	if edt.attacking then
		if eft.State == 1 then
			if (eft.Position.X > 300 and eft.Position.Y <= 450) or (eft.Position.X < 300 and eft.Position.Y >= 600) then
				eft.Velocity = Vector(0,0)
			else
				eft.Velocity = Vector(0,edt.vel)
			end
		else
			eft.Velocity = Vector(0,edt.vel)
		end

		if eft.Timeout > 0 then
			if eft.FrameCount % 40 == 0 then
				SFXManager():Play(245, 1, 0, false, 1) --SOUND_SATAN_SPIT
			end

			if eft.State == 1 then
				if eft.FrameCount % 2 == 0 then
					--Purple Fire Projectile--
					local proj = Isaac.Spawn(9, 2, 0, eft.Position + Vector(10 * edt.vel, math.random(-20, 20)), Vector(math.random(11, 17) * edt.vel, 0), eft):ToProjectile()
					proj.Height = -30
					proj.Color = Color(1, 0.5, 0.5, 1, 0, 0, 0)
				end
			else--if eft.State == 2 then
				if eft.FrameCount % 4 == 0 then
					for i=-0.1, 0.1, 0.2 do
						local proj = Isaac.Spawn(9, 2, 0, eft.Position + Vector(10 * edt.vel, math.random(-20, 20)), Vector(8 * edt.vel, math.random(25, 60) * i), eft):ToProjectile()
						proj.Height = -30
						proj.FallingAccel = -0.05
						proj.Color = Color(0.8, 1, 0.5, 1, 0, 0, 0)
					end
				end
			--else
				--if eft.FrameCount % 20 == 0 then
					--for i=-45, 45, 22.5 do
						--if eft.SubType == 1 then
							--local proj = Isaac.Spawn(9, 2, 0, eft.Position+Vector(10*edt.vel,0),
							--Vector.FromAngle(i*edt.vel):Resized(-7.5), eft):ToProjectile()
						--	proj.Height = -30
						--	proj.FallingAccel = -0.07
						--	proj.Color = Color(0.8,1.3,0.7,1,0,0,0)
						--else
						--	local proj = Isaac.Spawn(9, 2, 0, eft.Position+Vector(10*edt.vel,0),
						--	Vector.FromAngle(i*edt.vel):Resized(7.5), eft):ToProjectile()
						--	proj.Height = -30
						--	proj.FallingAccel = -0.07
						--	proj.Color = Color(0.8,1.3,0.7,1,0,0,0)
						--end
					--end
				--end
			end
		else
			if not espr:IsPlaying("ShootB"..eft.LifeSpan.."End"..edt.side) then
				espr:Play("ShootB"..eft.LifeSpan.."End"..edt.side, true)
			end
		end
	else
		eft.Velocity = eft.Velocity * 0.8
	end
end, Isaac.GetEntityVariantByName("Mega Satan 2's Head (Side)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()
	local Room = Game():GetRoom()

	eft.DepthOffset = -1

	if Room:GetBackdropType() == 3 then
		espr.Color = Color(1, 0.471, 0.471, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 6 or Room:GetBackdropType() == 27 then
		espr.Color = Color(0.55, 0.55, 0.784, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 7 or Room:GetBackdropType() == 8 or Room:GetBackdropType() == 14 then
		espr.Color = Color(0.61, 0.61, 0.61, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 9 then
		espr.Color = Color(0.4, 0.4, 0.4, 1, 0, 0, 0)
	elseif (Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 12) or Room:GetBackdropType() == 24 then
		espr.Color = Color(1, 0.352, 0.352, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 13 then
		espr.Color = Color(0.51, 0.59, 1, 1.3, 0, 0, 0)
	elseif Room:GetBackdropType() == 15 then
		espr.Color = Color(0.431, 0.75, 1, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 15 then
		espr.Color = Color(0.431, 0.75, 1, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 16 then
		espr.Color = Color(0.63, 0.4, 0.863, 1, 0, 0, 0)
	elseif Room:GetBackdropType() == 18 or Room:GetBackdropType() == 26 then
		espr.Color = Color(1, 1, 1, 1, 0, 0, 0)
	else
		espr.Color = Color(0.784, 0.51, 0.51, 1, 0, 0, 0)
	end

	if eft.SubType ~= 1 and eft.FrameCount == 45 then
		espr:Play("Remove"..edt.backdrop, true)
	end

	if Room:GetBackdropType() >= 10 and Room:GetBackdropType() <= 13 then
		edt.backdrop = "W"
	else
		edt.backdrop = "N"
	end

	if eft.Parent then
		if eft.SubType == 1 then
			if espr.Rotation == 90 or espr.Rotation == 270 then
				eft.Position = Vector(eft.Position.X, eft.Parent.Position.Y)
			elseif espr.Rotation == 0 or espr.Rotation == 180 then
				eft.Position = Vector(eft.Parent.Position.X, eft.Position.Y)
			end
		end

		if espr:IsFinished("Appear"..edt.backdrop) and eft.Parent.Position:Distance(eft.Position) <= 65 then
			espr:Play("Remove"..edt.backdrop, true)
		end
	else
		if eft.SubType == 1 and espr:IsFinished("Appear"..edt.backdrop) then
			espr:Play("Remove"..edt.backdrop, true)
		end
	end

	if eft.SubType == 2 and eft.FrameCount == 25 then
		Game():ShakeScreen(10)
		SFXManager():Play(28, 1, 0, false, 1) --SOUND_DEATH_BURST_LARGE
		Isaac.Spawn(555, Isaac.GetEntityVariantByName("Lamb II Clone"), 0, eft.Position, Vector.FromAngle(espr.Rotation + 90):Resized(33), eft)

		local xplsn = Isaac.Spawn(1000, 2, 2, eft.Position, Vector(0,0), eft) --Blood Explosion
		xplsn:SetColor(Color(0.13, 1.73, 2.28, 1.5, 0, 0, 0), 99999, 0, false, false)
		xplsn.PositionOffset = Vector(0, -20)
	end

	if espr:IsFinished("Remove"..edt.backdrop) then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Wall Hole"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	eft.Visible = false

	if eft.Timeout <= 0 then
		eft.Timeout = 20
	end

	eft:GetData().interval = 60
	eft:GetData().radi = 0
end, Isaac.GetEntityVariantByName("Coin Wave"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local edt = eft:GetData()

	if eft.FrameCount % 8 == 1 then
		SFXManager():Play(138, 1, 0, false, 1) --SOUND_POT_BREAK
		edt.radi = edt.radi + 53
		edt.interval = edt.interval * 0.8

		for i=0, 359, edt.interval do
			if HMBPENTS.IsInRoom(eft.Position + Vector.FromAngle(i):Resized(edt.radi), 25, 25) then
				Game():BombDamage(eft.Position + Vector.FromAngle(i):Resized(edt.radi), 10, 10, true, eft.Parent, 0, DamageFlag.DAMAGE_EXPLOSION, false)
				local bstcoin = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Ultra Greed Coin (Burst)"), 1, eft.Position+Vector.FromAngle(i):Resized(edt.radi), Vector(0, 0), eft)
				bstcoin.Parent = eft.Parent
				bstcoin:ToEffect().Scale = 0.5
			end
		end
	end

	if eft.Timeout <= 0 then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Coin Wave"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local edt = eft:GetData()
	local snd = SFXManager()

	if not edt.initimeout then
		edt.initimeout = eft.Timeout
		edt.BrkScale = math.max(20, ((4 / edt.initimeout) * eft.MaxRadius) * 0.5) / 17
		edt.radi = 0
	end

	if eft.Timeout > 0 and eft.Timeout % 2 == 0 then
		snd:Play(138, 0.7, 0, false, 1.5) --SOUND_POT_BREAK
		edt.radi = edt.radi + ((4 / edt.initimeout) * eft.MaxRadius)

		for i=0, 359, 360/(edt.radi/7) do
			if HMBPENTS.IsInRoom(eft.Position + Vector.FromAngle(i):Resized(edt.radi), 15, 15) then
				local gbreak = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Golden Ground Break"), 1, eft.Position+Vector.FromAngle(i):Resized(edt.radi), Vector(0, 0), eft)
				gbreak:ToEffect().Scale = edt.BrkScale
			end
		end

		for k, v in pairs(Isaac:GetRoomEntities()) do
			local vdist = v.Position:Distance(eft.Position)
			if (vdist >= edt.radi - (30 * edt.BrkScale) - v.Size and vdist <= edt.radi + (30 * edt.BrkScale) + v.Size) and v.Type ~= 406
			and not v:HasEntityFlags(1<<10) and v.EntityCollisionClass > 0 then
				if v:ToPlayer() then
					if v.Variant == 0 and denpnapi then
						if not v:GetData().playingmodanim or v:GetData().playingmodanim <= 0 then
							v:GetData().playmodanim = 4
						end
					else
						v:ToPlayer():PlayExtraAnimation("Hit")
						v:AddMidasFreeze(EntityRef(eft), 40)
					end
				elseif v:IsVulnerableEnemy() then
					v:AddMidasFreeze(EntityRef(eft.Parent), 40)
					snd:Play(427, 1, 0, false, 2) --SOUND_ULTRA_GREED_COIN_DESTROY
				end
			end
		end
	end

	if eft.Timeout <= 0 then
		eft:Remove()
	end

end, Isaac.GetEntityVariantByName("Golden Wave (Radial)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	eft.Visible = false

	if eft.Timeout < 4 then
		eft.Timeout = 12
	end

	if eft.MaxRadius <= 3 then
		eft.MaxRadius = 100
	end

	eft:GetData().radi = 0
end, Isaac.GetEntityVariantByName("Golden CrackWave"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local edt = eft:GetData()
	local snd = SFXManager()

	eft.Visible = false

	if not edt.removing and eft.FrameCount % 2 == 1 then
		eft.Position = eft.Position + Vector.FromAngle((eft.Rotation - 5) + (math.random(-12, 12) * 6) + ((eft.FrameCount % 2) * 10)):Resized(30)
		snd:Play(138, 0.7, 0, false, 1.5) --SOUND_POT_BREAK
		Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Golden Ground Break"), 1, eft.Position, Vector(0,0), eft) --Golden Ground Break

		for k, v in pairs(Isaac:GetRoomEntities()) do
			if v.Position:Distance(eft.Position) <= 30 + v.Size and v.Type ~= 406 and not v:HasEntityFlags(1<<10) and v.EntityCollisionClass > 0 then
				if v:ToPlayer() then
					if v.Variant == 0 and denpnapi then
						if not v:GetData().playingmodanim or v:GetData().playingmodanim <= 0 then
							v:GetData().playmodanim = 4
						end
					else
						v:ToPlayer():PlayExtraAnimation("Hit")
						v:AddMidasFreeze(EntityRef(eft), 70)
					end
				elseif v:IsVulnerableEnemy() then
					v:AddMidasFreeze(EntityRef(eft.Parent), 70)
					snd:Play(427, 1, 0, false, 2) --SOUND_ULTRA_GREED_COIN_DESTROY
				end
			end
		end
	end

	if not HMBPENTS.IsInRoom(eft.Position, 15, 15) and not edt.removing then
		edt.removing = true
		eft.Timeout = 6
	end

	if edt.removing and eft.Timeout <= 0 then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Golden CrackWave"))

--Red Creep--
HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	if eft:GetData().massingblood then
		local edt = eft:GetData()

		eft.Timeout = eft.Timeout + 1

		if not edt.spawnproj then
			edt.spawnproj = true

			local proj = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Massing Blood"), 0, eft.Position, Vector(0,0), eft)
			proj.Parent = eft
			proj:ToEffect().Rotation = eft.Rotation
		end

		eft.SpriteScale = Vector(eft.SpriteScale.X - 0.091, eft.SpriteScale.Y - 0.091)

		if eft.SpriteScale.X < 0.091 or eft.SpriteScale.Y < 0.091 then
			eft:Remove()
		end
	end
end, 22)

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	if not eft.Parent then
		local proj = Isaac.Spawn(9, 0, 0, eft.Position, Vector(0,0), eft):ToProjectile()
		proj.Height = -5
		proj.FallingSpeed = -4
		proj.FallingAccel = 0
		proj.Scale = 0.091 * espr:GetFrame()
		proj:GetData().shootangle = eft.Rotation
		eft:Remove()
	end

	if espr:IsFinished("Massing") then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Massing Blood"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	eft:GetSprite():Play("Appear"..math.ceil((eft.Scale / (1 / 3)) + 2), true)
	eft.PositionOffset = Vector(0, -23)
end, Isaac.GetEntityVariantByName("Appearing Projectile"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	if eft.FrameCount == 20 then
		local RGBO = REPENTANCE and 1 or 255

		local proj = Isaac.Spawn(9, 6, 0, eft.Position, eft.Velocity, eft):ToProjectile() --Hush Projectile
		proj.FallingAccel = -0.09
		proj.Scale = eft.Scale
		proj.Color = Color(1, 1, 1, 1, RGBO, RGBO, RGBO)
		--proj.FallingSpeed = eft.FallingSpeed
	elseif eft.FrameCount == 21 then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Appearing Projectile"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local edt = eft:GetData()
	local Room = Game():GetRoom()
	local gi = Room:GetGridIndex(eft.Position)
	local ge = Room:GetGridEntity(gi)

	eft.Visible = false

	if eft.FrameCount == 1 and eft.Timeout <= 0 then
		eft.Timeout = 200
	end

	if eft.LifeSpan > 0 then
		eft.LifeSpan = eft.LifeSpan - 1
	end

	if eft.SubType > 0 and eft.LifeSpan > 0 then
		if eft.SubType % 2 == 1 then
			eft.Rotation = eft.Rotation + (eft.SubType / 20)
		else
			eft.Rotation = eft.Rotation - ((eft.SubType - 1) / 20)
		end
	end

	eft.Velocity = Vector.FromAngle(eft.Rotation):Resized(7)

	if eft.FrameCount % 7 == 0 then
		if not REPENTANCE then
			SFXManager():Play(133, 0.5, 0, false, 1) --SOUND_REDLIGHTNING_ZAP
		end

		if AngelLightTweaks_Enabled and not REPENTANCE then
			local l = Isaac.Spawn(1000, 2319, 0, eft.Position, Vector(0,0), eft)
			local ld = l:GetData()
			l.Parent = eft.Parent
			ld.CrackSkySpawnFrame = 2
			l:GetSprite():Play("Appear", true)
			ld.CrackSkySpawnPosition = eft.Position
			ld.CrackSkySpawnVelocity = Vector(0,0)
			ld.CrackSkySpawnSpawner = eft.Parent
		else
			local light = Isaac.Spawn(1000, 19, 0, eft.Position, Vector(0,0), eft)
			light.Parent = eft.Parent
		end
	end

	if ge and (ge:GetType() == 15 or ge:GetType() == 16) then
		eft:Remove()
	end

	if eft.Position.X <= Game():GetRoom():GetTopLeftPos().X or eft.Position.X >= Game():GetRoom():GetBottomRightPos().X or eft.Position.Y <= Game():GetRoom():GetTopLeftPos().Y
	or eft.Position.Y >= Game():GetRoom():GetBottomRightPos().Y or (eft.FrameCount > 1 and eft.Timeout <= 0) then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("BeamWave"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local edt = eft:GetData()
	local Room = Game():GetRoom()

	if Room:GetRoomShape() >= 6 then
		edt.maxr = 560
	elseif Room:GetRoomShape() >= 4 then
		edt.maxr = 440
	else
		if Room:GetRoomShape() == 3 then
			edt.maxr = 240
		else
			edt.maxr = 320
		end
	end

	eft.Visible = false

	if eft.FrameCount == 1 then
		if eft.Timeout <= 0 then
			eft.Timeout = 155
		end
		if eft.LifeSpan <= 1 then
			eft.LifeSpan = 30
		end
	end

	if eft.FrameCount % eft.LifeSpan == 1 then
		if not REPENTANCE then
			sound:Play(133, 0.5, 0, false, 1) --SOUND_REDLIGHTNING_ZAP
		end

		for i=0, 359.9, 15/(eft.Scale*(eft.FrameCount/eft.LifeSpan)) do
			local gi = Room:GetGridIndex(eft.Position+Vector.FromAngle(i):Resized((eft.FrameCount/eft.LifeSpan)*(eft.Scale*125)))
			local spawnpos = eft.Position+Vector.FromAngle(i):Resized((eft.FrameCount/eft.LifeSpan)*(eft.Scale*125))

			if (not Room:GetGridEntity(gi) or Room:GetGridEntity(gi):GetType() ~= 15)
			and spawnpos.X <= Room:GetBottomRightPos().X-5 and spawnpos.Y <= Room:GetBottomRightPos().Y-5
			and spawnpos.X >= Room:GetTopLeftPos().X+5 and spawnpos.Y >= Room:GetTopLeftPos().Y+5 then
				if AngelLightTweaks_Enabled and not REPENTANCE then
					local l = Isaac.Spawn(1000, 2319, 0, spawnpos, Vector(0,0), eft)
					local ld = l:GetData()
					l.Parent = eft.Parent
					ld.CrackSkySpawnFrame = 2
					l:GetSprite():Play("Appear", true)
					ld.CrackSkySpawnPosition = spawnpos
					ld.CrackSkySpawnVelocity = Vector(0,0)
					ld.CrackSkySpawnSpawner = eft.Parent
				else
					local light = Isaac.Spawn(1000, 19, REPENTANCE and 2 or 0, spawnpos, Vector(0,0), eft)
					light.Parent = eft.Parent
				end
			end
		end
	end

	if (eft.FrameCount >= 1 and eft.Timeout <= 0) or (eft.FrameCount/eft.LifeSpan)*(eft.Scale*125) > edt.maxr then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("BeamWave (Radial)"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()
	local Room = Game():GetRoom()
	if eft.FrameCount == 1 then
		edt.rt = math.random(0,1)
		eft.SpriteRotation = math.random(0,359)
	end
	if eft.FallingAcceleration <= 0.7 then
		eft.FallingAcceleration = eft.FallingAcceleration + 0.05
	end
	eft.m_Height = eft.m_Height + eft.FallingAcceleration
	if eft.m_Height < 0 then
		eft.PositionOffset = Vector(0,eft.m_Height)
		if edt.rt == 0 then
			eft.SpriteRotation = eft.SpriteRotation + (eft.Velocity:Length()+1)
		else
			eft.SpriteRotation = eft.SpriteRotation - (eft.Velocity:Length()+1)
		end
	end
	if (eft.Position.X >= Room:GetBottomRightPos().X-10 or eft.Position.X <= Room:GetTopLeftPos().X+10)
	and eft.Velocity.X ~= 0 then
		eft.Velocity = Vector(0,eft.Velocity.Y)
	end
	if (eft.Position.Y >= Room:GetBottomRightPos().Y-10 or eft.Position.Y <= Room:GetTopLeftPos().Y+10)
	and eft.Velocity.Y ~= 0 then
		eft.Velocity = Vector(eft.Velocity.X,0)
	end
	eft.Velocity = eft.Velocity * 0.9
	if eft.m_Height >= 0 then
		eft:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
	end
end, Isaac.GetEntityVariantByName("Feather Particle"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local Room = Game():GetRoom()

	eft.DepthOffset = -1
	eft.SpriteScale = Vector(eft.Scale, eft.Scale)

	if eft.FrameCount == 1 then
		SFXManager():Play(316, 1, 0, false, 1) --SOUND_DEVILROOM_DEAL

		if Game():GetRoom():GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 then
			eft.Color = Color(1, 1, 1, 1, 45 / (REPENTANCE and 255 or 1), 0, 0)
		end
	elseif eft.FrameCount == 45 then
		for i=0, 340, 20 do
			--Hush Projectile--
			local Dproj = Isaac.Spawn(9, 6, 0, eft.Position + Vector.FromAngle(i):Resized(15*eft.Scale), Vector.FromAngle(i):Resized(11 * eft.Scale), eft):ToProjectile()
			Dproj:AddProjectileFlags(ProjectileFlags.ACCELERATE)
			Dproj.Acceleration = 0.9
			Dproj.Scale = 1.4

			if Game():GetRoom():GetBackdropType() == 7 or Room:GetBackdropType() == 9 or Room:GetBackdropType() == 14 then
				Dproj.Color = Color(0, 0, 0, 1, 45 / (REPENTANCE and 255 or 1), 0, 0)
			else
				Dproj.Color = Color(0, 0, 0, 1, 0, 0, 0)
			end
		end
	end
	if eft.FrameCount >= 85 then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Black Circle Warn"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()

	espr.Rotation = eft.Rotation

	if eft.FrameCount == 37 then
		if eft.SpawnerEntity then
			EntityLaser.ShootAngle(5, eft.Position, espr.Rotation, 3, Vector(0,0), eft.SpawnerEntity)
		else
			EntityLaser.ShootAngle(5, eft.Position, espr.Rotation, 3, Vector(0,0), eft)
		end
	end

	if espr:IsFinished("Warn") then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("HolyBeam Warn"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()
	local plrpos = Isaac.GetPlayer(0).Position
	local sound = SFXManager()

	if eft.FrameCount == 1 then
		if eft.Timeout <= 31 then
			eft.Timeout = 95
		end

		if not edt.num then
			edt.num = 2
		end

		espr:Play("Warn")
		sound:Play(240, 1, 0, false, 1) --SOUND_SATAN_CHARGE_UP

		if not edt.creeptimeout then edt.creeptimeout = 100 end
	elseif eft.FrameCount == 26 then
		sound:Play(211, 2, 0, false, 1) --SOUND_HAND_LASERS
		espr:PlayOverlay("LaserDownLoop",true)
	end

	if eft.Timeout <= 0 and espr:IsOverlayPlaying("LaserDownLoop") then
		espr:PlayOverlay("LaserDownEnd",true)
	end

	if espr:IsOverlayFinished("LaserDownEnd") then
		eft:Remove()
	end

	if espr:IsOverlayPlaying("LaserDownLoop") then
		Game():BombDamage(eft.Position, 10, 60, false, eft, 0, DamageFlag.DAMAGE_LASER, true)

		if eft.State == 1 then
			if eft.FrameCount % 2 == 0 then
				local proj = Isaac.Spawn(9, 0, 0, eft.Position, Vector.FromAngle(eft.FrameCount * 15):Resized(6), eft):ToProjectile()
				proj.FallingAccel = -0.085
			end
		elseif	eft.State == 2 then
			local proj = Isaac.Spawn(9, 0, 0, eft.Position, Vector.FromAngle(eft.FrameCount * 20):Resized(6), eft):ToProjectile()
			proj.FallingAccel = -0.085
		elseif	eft.State == 3 then
			if eft.FrameCount % eft.LifeSpan == 0 and eft.LifeSpan > 0 then
				for i=0, 360 - (360 / edt.num), 360 / edt.num do
					local proj = Isaac.Spawn(9, 0, 0, eft.Position, Vector.FromAngle(i):Resized(6), eft):ToProjectile()
					proj.FallingAccel = -0.085
				end
			end
		end

		if eft.SubType > 0 then
			if eft.FrameCount % 5 == 0 then
				local creep = Isaac.Spawn(1000, 22, 0, eft.Position, Vector(0, 0), eft):ToEffect()
				creep.SpriteScale = Vector(3, 3)
				creep.Timeout = edt.creeptimeout
			end

			if eft.SubType == 1 then
				eft.Velocity = (eft.Velocity * 0.9) + Vector.FromAngle((plrpos - eft.Position):GetAngleDegrees()):Resized(0.85)
			else
				eft.Velocity = Vector.FromAngle(eft.Rotation):Resized(eft.Velocity:Length() + 0.2)
			end
		end

		if math.abs(eft.Position.X - plrpos.X) <= 150 and eft.Position.Y > plrpos.Y then
			eft.Color = Color(1, 1, 1, 0.5, 0, 0, 0)
		else
			eft.Color = Color(1, 1, 1, 1, 0, 0, 0)
		end
	end
end, Isaac.GetEntityVariantByName("Giant Red Laser From Above"))

HMBPENTS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	local espr = eft:GetSprite()
	local edt = eft:GetData()

	if eft.FrameCount == 1 then
		eft.PositionOffset = Vector(0, math.random(-350, -300))

		if math.random(1,2) == 1 then
			eft.FlipX = true
			edt.xvel = -1
		else
			edt.xvel = 1
		end

		if not edt.anmno or edt.anmno < 1 or edt.anmno > 2 then
			edt.anmno = math.random(1,2)
		end

		espr:Play("Appear0"..edt.anmno, true)
	end

	if espr:IsFinished("Appear0"..edt.anmno) then
		espr:Play("Falling0"..edt.anmno, true)
	end

	if eft.PositionOffset.Y >= 0 then
		eft.Velocity = eft.Velocity * 0.9
		eft.DepthOffset = -10

		if eft.Timeout < 0 then
			eft.Timeout = 110
			eft.PositionOffset = Vector(0, 0)
		end

		if espr:IsPlaying("Falling0"..edt.anmno) and (espr:GetFrame() == 16 or espr:GetFrame() == 49) then
			if espr:GetFrame() == 16 + 33*math.abs(1 - edt.anmno) then
				eft.Velocity = Vector(-2 * edt.xvel,0)
			elseif espr:GetFrame() == 49 - 33*math.abs(1 - edt.anmno) then
				eft.Velocity = Vector(2 * edt.xvel,0)
			end

			espr:SetFrame("Falling0"..edt.anmno, espr:GetFrame())
		end
	else
		eft.PositionOffset = Vector(0, eft.PositionOffset.Y + 2)
	end

	if eft.Timeout == 40 then
		if (eft.SpawnerType == 0 or (eft.SpawnerType > 1 and #Isaac.FindByType(eft.SpawnerType, eft.SpawnerVariant, -1, true, true) > 0)) and denpnapi then
			SFXManager():Play(265, 1, 0, false, 1) --SOUND_SUMMONSOUND

			if math.random(1,4) <= 3 then
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Memories I"), 0, eft.Position, Vector(0,0), eft) --Memories I
			else
				Isaac.Spawn(554, Isaac.GetEntityVariantByName("Memories II"), 0, eft.Position, Vector(0,0), eft) --Memories II
			end
		end
	elseif eft.Timeout == 0 then
		local poof = Isaac.Spawn(1000, 15, 0, eft.Position, Vector(0,0), eft) --POOF01
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Blank Polaroid"))
