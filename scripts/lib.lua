local game = Game()

function HardBossPatterns.HasBit(v, bit)
	for i= 62, 0, -1 do
		if v >= 1<<i then
			if 1<<i == bit then
				return true
			end

			v = v-(1<<i)
		end
	end
	return false
end

function HardBossPatterns.IsInRoom(p,xsz,ysz)
	local room = game:GetRoom()
	return (p.X >= room:GetTopLeftPos().X+xsz and p.X <= room:GetBottomRightPos().X-xsz
	and p.Y >= room:GetTopLeftPos().Y+ysz and p.Y <= room:GetBottomRightPos().Y-ysz)
end
