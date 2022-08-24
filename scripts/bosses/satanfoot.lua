local HMBP = HardBossPatterns
local game = Game()
local rng = HMBP.RNG()

----------------------------
--add Boss Pattern:Satan Stomp
----------------------------

HMBP:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, boss)
	if boss.Variant == 10 then
		rng:SetSeed(boss:GetDropRNG():GetSeed(), 35)

		local data = boss:GetData()
		data.StAttackReady = 0
		data.NullsPosition = Isaac.GetRandomPosition(0)
	end
end, 84)

function HMBP:SatanFoot(boss)
	if boss.Variant == 10 and Game().Difficulty % 2 == 1 then
		local sprstf = boss:GetSprite()
		local data = boss:GetData()

		if not StAttackReady then
			StAttackReady = 0
		end

		if boss.State < 8 then
			if boss.FrameCount % 60 == 0 and rng:Random(1,6) == 1 then
				for k, v in pairs(Isaac:GetRoomEntities()) do
					for i=0, 30 do
						data.NullsPosition = Isaac.GetRandomPosition(0)
						if v.Type == 1 and data.NullsPosition:Distance(v.Position) > 170 then
							Isaac.Spawn(252, 0, 0, data.NullsPosition, Vector(0,0), boss)
							break
						end
					end
				end
			end

			if sprstf:GetFrame() == 30 and rng:Random(1,3) == 1 and boss.FrameCount >= boss.StateFrame + 350 and HMBPENTS then
				StAttackReady = rng:Random(1,2)
			end

			if StAttackReady > 0 and sprstf:GetFrame() == 80 then
				boss.StateFrame = boss.FrameCount
				boss.State = 8
			end
		end
		if not boss:GetData().isdelirium then
			if boss.State == 8 then
				if boss.FrameCount == boss.StateFrame + 50 and #Isaac.FindByType(1000, 356, -1, true, true) < math.abs(StAttackReady-3) then
					local BigDownLaser = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("Giant Red Laser From Above"), StAttackReady-1, Isaac.GetRandomPosition(0), Vector(0,0), boss):ToEffect()
					BigDownLaser.Timeout = 50-StAttackReady*23
					BigDownLaser.State = 4-StAttackReady*2
				end

				if boss.FrameCount >= boss.StateFrame + 200 then
					boss.State = 3
					StAttackReady = 0
				end
			end

			if boss:IsDead() then
				StAttackReady = 0
			end
		end

		if boss:IsDead() then
			boss:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)

			if HMBPENTS and #Isaac.FindByType(666, 666, 0, true, true) < 1 then
				local Room = Game():GetRoom()

				local satan666 = Isaac.Spawn(666, 666, 0, Room:GetCenterPos()+Vector(Room:GetCenterPos().X/4,0), Vector(0,0), boss)
				satan666:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
				satan666.Parent = boss
			end
		end

	end
end

HMBP:AddCallback(ModCallbacks.MC_NPC_UPDATE, HMBP.SatanFoot, 84)
