local HMBP = HardBossPatterns
local game = game

----------------------------
--Add Boss Pattern:Mega Satan
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant ~= 0 then
		local data = boss:GetData()
		data.tpos = Vector(473,370)
		data.canattack = false
	end
end, 274)

function HMBP:MSHand(boss)
	if boss.Variant ~= 0 and Game().Difficulty % 2 == 1 and not boss:GetData().isdelirium then

		local sprshnd = boss:GetSprite()
		local target = Game():GetPlayer(1) --TODO: closest player
		local dist = target.Position:Distance(boss.Position)
		local data = boss:GetData()
		local Entities = Isaac:GetRoomEntities()
		--angle = (target.Position - boss.Position):GetAngleDegrees()

		if boss.State == 13 then
			if boss.Variant == 1 then
				data.tpos = Vector(203,370)
			else
				data.tpos = Vector(473,370)
			end
			if boss.I2 == 1 then
				boss.Velocity = Vector.FromAngle((data.tpos - boss.Position):GetAngleDegrees()):Resized(data.tpos:Distance(boss.Position)*0.1)
				boss.ProjectileCooldown = boss.ProjectileCooldown + 1
				boss:SetSpriteFrame("HidingSmash", boss.ProjectileCooldown + 1)
				if boss.ProjectileCooldown == 31 then
					boss:PlaySound(52, 1, 0, false, 1)
					Game():ShakeScreen(20)
					if #Isaac.FindByType(271, -1, -1, true, true) > 0 or #Isaac.FindByType(272, -1, -1, true, true) > 0 then
						for i=45, 135, 90 do
							local shockwave = Isaac.Spawn(1000, 72, 0, boss.Position, Vector(0,0), boss):ToEffect()
							shockwave.Parent = boss
							shockwave.Rotation = i
						end
					else
						local shockwave = Isaac.Spawn(1000, 67, 0, boss.Position, Vector(0,0), boss)
						shockwave.Parent = boss
					end
				end
				if boss.ProjectileCooldown >= 31 and boss.ProjectileCooldown <= 54 then
					boss.EntityCollisionClass = 4
				end
			end
		elseif boss.State == 10 then
			boss.GridCollisionClass = 0
			if sprshnd:IsFinished("Charging2") then
				sprshnd:Play("Blast", true)
			end
			if sprshnd:IsPlaying("Blast") and sprshnd:GetFrame() == 6 then
				EntityLaser.ShootAngle(6, boss.Position, 90, 40, Vector(0,-40), boss)
			end
			if sprshnd:IsFinished("Blast") then
				boss.State = 3
			end
		end

		for k, v in pairs(Entities) do
			if v.Type == 274 then
				if v.Variant == 0 then
					if boss.State == 11 then
						if sprshnd:IsPlaying("Punch") then
							if sprshnd:GetFrame() == 1 then
								boss.TargetPosition = v.Position + Vector(120+((boss.Variant-2)*240),-20)
							elseif sprshnd:GetFrame() == 25 then
								boss.Velocity = Vector(2.4+((boss.Variant-2)*4.8),-3)
							elseif sprshnd:GetFrame() == 54 then
								boss.TargetPosition = v.Position + Vector(30+((boss.Variant-2)*60),20)
							end
							if sprshnd:GetFrame() > 27 and sprshnd:GetFrame() < 36 then
								if sprshnd:GetFrame() == 28 then
									boss:PlaySound(182, 1, 0, false, 1)
								end
								boss.TargetPosition = v.Position + Vector(0,300)
								boss.Velocity = Vector.FromAngle((boss.TargetPosition-boss.Position):GetAngleDegrees()):Resized(boss.TargetPosition:Distance(boss.Position)*0.3)
							end
							if sprshnd:GetFrame() == 65 then
								boss.TargetPosition = v.Position + Vector(120+((boss.Variant-2)*240),100)
							end
						else
							boss.State = 3
						end
					elseif boss.State == 10 then
						boss.TargetPosition = v.Position + Vector(boss.Variant == 1 and -240 or 240,80)
					end
					if v:ToNPC().State == 13 and v:ToNPC().I2 == 3 and boss.State == 13 then
						boss.I2 = 1
					else
						boss.I2 = 0
						boss.ProjectileCooldown = 0
					end
					if boss.I2 == 0 and boss.State == 13 and
					(v:GetSprite():IsPlaying("Hiding") or v:ToNPC().I2 > 0)
					and not sprshnd:IsPlaying("Hide") then
						sprshnd:Play("Hiding", true)
					end
					if v:ToNPC().State == 8 and v:GetSprite():IsPlaying("Charging")
					and boss.State == 3 then
						sprshnd:Play("Charging2", true)
						boss.State = 10
					end
					if v:ToNPC().State == 3 and boss.State == 3 and boss.TargetPosition:Distance(boss.Position) < 50
					and boss.FrameCount % 130 == 0 and data.canattack then
						if boss.Variant == 1 or (boss.Variant == 2 and #Isaac.FindByType(274, 1, -1, true, true) == 0) then
							boss.State = 11
							sprshnd:Play("Punch", true)
						end
					end
				elseif v.Variant == 1 then
					if v:ToNPC().State == 8 then
						if boss.Variant == 2 then
							data.canattack = false
							if boss.State == 11 then
								v:ToNPC().State = 3
							end
						end
					else
						if boss.Variant == 2 then
							data.canattack = true
						end
					end
				elseif v.Variant == 2 then
					if v:ToNPC().State == 8 then
						if boss.Variant == 1 then
							data.canattack = false
							if boss.State == 11 then
								v:ToNPC().State = 3
							end
						end
					else
						if boss.Variant == 1 then
							data.canattack = true
						end
					end
				end
			end
		end
	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.MSHand, 274)
