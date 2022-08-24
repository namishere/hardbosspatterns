HardBossPatterns.ProjectileParams = HardBossPatterns.Class("ProjectileParams")
function HardBossPatterns.ProjectileParams.Init(self)
	self.params = ProjectileParams()
	self.Acceleration = self.params.Acceleration
	self.BulletFlags = self.params.BulletFlags
	self.HMBPBulletFlags = 0
-- 	ChangeFlags = self.params.ChangeFlags
	self.ChangeHMBPEntsBFlags = 0
	self.ChangeVelocity = self.params.ChangeVelocity
	self.ChangeTimeout = self.params.ChangeTimeout
	self.Color = self.params.Color
	self.CurvingStrength = self.params.CurvingStrength
	self.DepthOffset = self.params.DepthOffset
	self.DotProductLimit = self.params.DotProductLimit
	self.FallingAccelModifier = self.params.FallingAccelModifier
	self.FallingSpeedModifier = self.params.FallingSpeedModifier
	self.FireDirectionLimit = self.params.FireDirectionLimit
	self.GridCollision = self.params.GridCollision
	self.HeightModifier = self.params.HeightModifier
	self.HomingStrength = self.params.HomingStrength
	self.Parent = nil
	self.PositionOffset = self.params.PositionOffset
	self.Scale = self.params.Scale
	self.Spread = self.params.Spread
	self.TargetPosition = self.params.TargetPosition
	self.Variant = self.params.Variant
	self.VelocityMulti = self.params.VelocityMulti
	self.WiggleFrameOffset = self.params.WiggleFrameOffset
end

function HardBossPatterns.FireProjectiles(entity, Variant, Position, Velocity, mode, PParams)
	local HasCharm = entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and ProjectileFlags.HIT_ENEMIES or 0
	--Returns HIT_ENEMIES for ProjectileFlags if entity has CHARM flag or 0 if not.
	local HasFriendly = entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and ProjectileFlags.CANT_HIT_PLAYER or 0
	--Returns CANT_HIT_PLAYER for ProjectileFlags if entity has FRIENDLY flag or 0 if not.
	PParams.Parent = PParams.Parent and PParams.Parent or (entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and entity or nil)
	PParams.BulletFlags = HasCharm | HasFriendly | PParams.BulletFlags

	if PParams.HMBPBulletFlags or PParams.ChangeHMBPEntsBFlags then
		local proj = Isaac.Spawn(9, Variant, 0, Position, Velocity, entity):ToProjectile()
		local data = proj:GetData()
		data.HMBPEntsBFlags = PParams.HMBPBulletFlags
		data.ChangeHMBPEntsBFlags = PParams.ChangeHMBPEntsBFlags
		proj.Acceleration = PParams.Acceleration
		proj.ChangeFlags = PParams.ChangeFlags
		proj.ChangeTimeout = PParams.ChangeTimeout
		proj.ChangeVelocity = PParams.ChangeVelocity
		proj.Color = PParams.Color
		proj.CurvingStrength = PParams.CurvingStrength
		--proj.Damage = PParams.Damage
		proj.DepthOffset = PParams.DepthOffset
		proj.FallingAccel = PParams.FallingAccelModifier
		proj.FallingSpeed = PParams.FallingSpeedModifier
		proj.Height = -23 + PParams.HeightModifier
		proj.HomingStrength = PParams.HomingStrength
		proj.Parent = PParams.Parent
		proj.ProjectileFlags = PParams.BulletFlags
		proj.Scale = PParams.Scale
		proj.WiggleFrameOffset = PParams.WiggleFrameOffset
	else
		entity:FireProjectiles(Position, Velocity, mode, PParams.params)
	end
end
