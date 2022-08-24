local HMBP = HardBossPatterns

----------------------------
--Ultra Greed Door
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	local data = boss:GetData()
	data.greedieropen = false
end, 294)

function HMBP:UtGreedDoor(door)
	if door.Type == 294 then
		local sprgdr = door:GetSprite()
		local Entities = Isaac:GetRoomEntities()
		local data = door:GetData()
		for k, v in pairs(Entities) do
			if v.Type == 406 and v.Variant == 1 then
				local greeddist = v.Position:Distance(door.Position)
				if v:GetSprite():IsEventTriggered("Call") then
					data.greedieropen = true
				end
				if door.State == 3 and data.greedieropen then
					door.State = 12
					door.StateFrame = 180
					for i=-15, 15, 30 do
						local bling = Isaac.Spawn(1000, 103, 0, door.Position + Vector.FromAngle(sprgdr.Rotation+90):Resized(1), Vector(0,0), door)
						bling.PositionOffset = Vector.FromAngle(sprgdr.Rotation-90+i):Resized(32)
						bling:SetColor(Color(2,0.5,0.5,1,0,0,0), 99999, 0, false, false)
						bling:GetSprite():Play("Bling3", true)
					end
				end
				if door.State == 12 then
					if door.StateFrame > 0 then
						door.StateFrame = door.StateFrame - 1
					end
					if sprgdr:IsPlaying("Closed") and door.StateFrame <= 150 then
						sprgdr:Play("Open", true)
					end
					if sprgdr:IsFinished("Open") then
						sprgdr:Play("Opened", true)
						door.State = 14
					end
					if sprgdr:GetFrame() == 5 then
						door:PlaySound(36, 1, 0, false, 1)
					end
				elseif door.State == 14 then
					if door.StateFrame > 0 then
						door.StateFrame = door.StateFrame - 1
					else
						data.greedieropen = false
					end
					if sprgdr:IsPlaying("Opened") then
						if not data.greedieropen then
							sprgdr:Play("Close", true)
						end
					end
				end
			end
		end

		if door.State == 14 then
			if sprgdr:IsPlaying("Opened") then
				if denpnapi then
					if door.FrameCount % 55 == 0 then
						if math.random(1,6) ~= 1 then
							Isaac.Spawn(554, Isaac.GetEntityVariantByName("Greedier Gaper"), 0, door.Position, Vector(0,0), door)
						else
							Isaac.Spawn(554, Isaac.GetEntityVariantByName("Greedier Fatty"), 0, door.Position, Vector(0,0), door)
						end
					end
				else
					if door.FrameCount % 7 == 0 then
						Isaac.Spawn(299, 0, 0, door.Position, Vector(0,0), door)
					end
				end
			else
				door.State = 3
			end
		end
	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.UtGreedDoor, 294)
