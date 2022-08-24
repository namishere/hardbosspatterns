HardBossPatterns.RNG = HardBossPatterns.Class("RNG")
function HardBossPatterns.RNG.Init(self)
	self.rng = RNG(s,i)
	self.rng:SetSeed((s or Game():GetFrameCount()), i or 1)
end

function HardBossPatterns.RNG:GetSeed() return self.rng:GetSeed() end
function HardBossPatterns.RNG:Next() self.rng:Next() end
function HardBossPatterns.RNG:RandomFloat() return self.rng:RandomFloat() end
function HardBossPatterns.RNG:RandomInt(i) return self.rng:RandomInt(i) end
function HardBossPatterns.RNG:SetSeed(s,i) self.rng:SetSeed(s,i) end

--math.random using RNG object
function HardBossPatterns.RNG:Random(min,max) return self.rng:RandomInt((max+1)-min)+min end
