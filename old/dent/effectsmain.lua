local Level = Game():GetLevel()
----------------------------
--Effects
----------------------------

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft) --Crack The Sky
	local edt = eft:GetData()

	if edt.InitPos and eft.Position.X ~= edt.InitPos.X and eft.Position.Y ~= edt.InitPos.Y then
		eft.Position = Vector(edt.InitPos.X, edt.InitPos.Y)
	end
end, 19)

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft) --Laser Impact
	local espr = eft:GetSprite()

	if eft.SubType == 1 and eft.Parent then
		if eft.Parent.Type == 7 and eft.Parent.Variant == 1 and eft.Parent.Size >= 80 and eft.Parent.SpawnerType ~= 406 then
			if espr:GetFilename() ~= "gfx/brimstoneimpact_red.anm2" then
				espr:Load("gfx/brimstoneimpact_red.anm2", true)
				espr:Play("Start", true)
			end

			if espr:IsFinished("Start") then
				espr:Play("Loop", true)
			end
		end
	end
end, 50)

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft) --ShockWave(Radial)
	if eft.SubType == 1 then --and eft.SubType <= 4 then
		local Room = Game():GetRoom()
		local gi = Room:GetGridIndex(eft.Position)
		local ge = Room:GetGridEntity(gi)
		--if eft.FrameCount <= 50 then
			--if eft.SubType == 2 then
				--eft.Velocity = Vector.FromAngle((eft.Velocity):GetAngleDegrees()+(eft.Velocity:Length()*0.25))
				--:Resized(eft.Velocity:Length())
			--elseif eft.SubType == 3 then
				--eft.Velocity = Vector.FromAngle((eft.Velocity):GetAngleDegrees()-(eft.Velocity:Length()*0.25))
				--:Resized(eft.Velocity:Length())
			--end
		--end
		if ge then
			if ge:GetType() == 3 or ge:GetType() == 7
			or ge:GetType() == 11 or ge:GetType() == 15 or ge:GetType() == 16 then
				eft:Remove()
			end
		end
		if eft.Position.X <= Room:GetTopLeftPos().X + 24 or eft.Position.X >= Room:GetBottomRightPos().X or eft.Position.Y <= Room:GetTopLeftPos().Y
		or eft.Position.Y >= Room:GetBottomRightPos().Y then
			eft:Remove()
		end
	end
end, 61)

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	if eft:GetSprite():IsFinished("Impact") then
		eft:Remove()
	end
end, Isaac.GetEntityVariantByName("Circular Impact"))

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, eft)
	local espr = eft:GetSprite()
	local sound = SFXManager()

	if eft.SubType == 1 then
		espr:Play("Falling", true)
	elseif eft.SubType == 2 then
		espr:Play("FallInLeft", true)
	elseif eft.SubType == 3 then
		espr:Play("FallInRight", true)
	elseif eft.SubType == 4 then
		espr:Play("Golden", true)
		eft.Timeout = 180
		sound:Play(427, 1, 0, false, 2) --SOUND_ULTRA_GREED_COIN_DESTROY
	end
end, Isaac.GetEntityVariantByName("Player Mod Anim"))

denpnapi:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, eft)
	if eft.Parent.Type == 1 then
		local espr = eft:GetSprite()
		local edt = eft:GetData()
		local player = eft.Parent:ToPlayer()
		local pldata = player:GetData()
		local sound = SFXManager()

		if eft.FrameCount == 1 then
			player.ControlsEnabled = false
			player.FireDelay = 10
			player:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 99999, 0, false, false)
		end

		eft.Position = player.Position
		eft.Velocity = player.Velocity

		if player:GetData().playingmodanim ~= eft.SubType then
			eft:Remove()
		end
		--eft:AddEntityFlags(EntityFlag.FLAG_INTERPOLATION_UPDATE)

		if espr:IsPlaying("Falling") and espr:GetFrame() == 65 then
			sound:Play(69, 1, 0, false, 1) --SOUND_MEAT_IMPACTS
		end

		if player:GetName() == "???" then edt.plname = "Bluebaby"
		elseif player:GetName() == "Lazarus II" and eft.SubType == 4 then edt.plname = "Lazarus"
		else edt.plname = player:GetName() end

		for i=0, 1 do
			espr:ReplaceSpritesheet(i, "gfx/effects/characters/character_"..edt.plname..".png")
		end

		espr:ReplaceSpritesheet(2, "gfx/effects/characters/"..edt.plname.."_golden.png")
		espr:LoadGraphics()

		if eft.SubType == 4 then
			player.ControlsEnabled = false

			if not espr:IsPlaying("Golden") and (Input.IsActionTriggered(0, player.ControllerIndex)
			or Input.IsActionTriggered(1, player.ControllerIndex) or Input.IsActionTriggered(2, player.ControllerIndex)
			or Input.IsActionTriggered(3, player.ControllerIndex) or Input.IsActionTriggered(4, player.ControllerIndex)
			or Input.IsActionTriggered(5, player.ControllerIndex) or Input.IsActionTriggered(6, player.ControllerIndex)
			or Input.IsActionTriggered(7, player.ControllerIndex)) then
				espr:Play("GoldStruggle", true)
				eft.Timeout = eft.Timeout - 15
				sound:Play(138, 0.75, 0, false, 1.75)

				if player:GetName() == "_NULL" then
					if math.random(1,5) == 1 then
						eft.FlipX = true
					elseif math.random(1,5) == 2 then
						eft.FlipX = false
					elseif math.random(1,5) == 3 then
						espr.FlipY = true
					elseif math.random(1,5) == 4 then
						espr.FlipY = false
					end
				end
			end
		end

		if (espr:IsFinished("Falling") or espr:IsFinished("FallInLeft") or espr:IsFinished("FallInRight") or (eft.SubType == 4
		and (player:GetSprite():IsPlaying("Hit") or eft.Timeout <= 0))) then
			if eft.SubType == 4 then
				Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Circular Impact"), 0, eft.Position, Vector(0,0), eft) --Circular Impact
				Game():SpawnParticles(eft.Position, 95, 20, 7, Color(1.1, 1, 1, 1, 0, 0, 0), 0) --Gold Particle
				sound:Play(427, 1, 0, false, 1) --SOUND_ULTRA_GREED_COIN_DESTROY
				player:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 99999, 0, false, false)

				if not player:GetSprite():IsPlaying("Hit") then
					player:PlayExtraAnimation("Jump")
					player:SetMinDamageCooldown(90)
				end
			end

			if eft.SubType == 1 or eft.SubType == 4 then
				player.ControlsEnabled = true
			end

			player.FireDelay = 0
			player:GetData().playingmodanim = 0
			player:GetData().playmodanim = 0
			eft:Remove()
		end
	end
end, Isaac.GetEntityVariantByName("Player Mod Anim"))
