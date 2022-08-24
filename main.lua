local mod = RegisterMod("HardBossPatterns", 1)
HardBossPatterns = mod

--TODO:
--	So much. God help me
--	Magic numbers abound!
--	Probably implement bosses one at a time

--local game = Game()

--Extended RNG class
include("scripts.class")
include("scripts.rng")
include("scripts.projectile")

include("scripts.lib")

---------------------------------------
--Probably move to a projectile script along w/ others
function HardBossPatterns.SpawnLaserWarn(P, To, A, C, Pr, Os, SS, Ls, E)
	--(Vector(float X, float Y) Position, int Timeout, float Angle, color Color, entity Parent, Vector Offset, Vector(float X, float Y) SpriteScale, int Lifespan, entity Entity)--
	local LaserWarn = Isaac.Spawn(1000, 198, 0, P, Vector(0, 0), E):ToEffect() --Generic Tracer
	LaserWarn.Timeout = To
	LaserWarn.LifeSpan = Ls
	LaserWarn:GetSprite().Scale = SS
	LaserWarn.TargetPosition = Vector.FromAngle(A)
	LaserWarn.Color = C
	LaserWarn.Parent = Pr
	LaserWarn:Update()
end
---------------------------------------

---------------------------------------
--Do these need to use callbacks?
function HardBossPatterns.NoDlrForm(e)
	HardBossPatterns:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
        if DlrHasExist and npc.Variant == e.Variant and npc.SubType == e.SubType then
			npc:Morph(412, 0, 0, -1)
        end
    end, e.Type)
end

function HardBossPatterns.EnemyStopMove(e)
	if not e:GetData().StopMove then
		e:GetData().StopMove = true
	end
	HardBossPatterns:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
		if npc:GetData().StopMove and npc.Variant == e.Variant and npc.SubType == e.SubType then
			return true
        end
    end, e.Type)
end
---------------------------------------
HardBossPatterns.sounds = {
	TVnoise = Isaac.GetSoundIdByName("TV Noise"),
	AngerScream = Isaac.GetSoundIdByName("Anger Scream"),

	--From HMBPENTS. Unused?
	MultiScream02 = Isaac.GetSoundIdByName("Multi Scream02")
}

HardBossPatterns.music = {
	MomLastDitch = Isaac.GetMusicIdByName("Mom's Last Ditch")
}

HardBossPatterns.ProjFlags = {
	BLACKCIRCLE = 1,
	WAVE = 1 << 1,
	LEAVES_ACID = 1 << 2,
	BURST_BLOODVESSEL = 1 << 3,
	TURN_RIGHTANGLE = 1 << 4,
	CURVE2 = 1 << 5,
	GRAVITY_VERT = 1 << 6,
	SMART2 = 1 << 7,
	CHANGE_HMBPENTSFLAGS_AFTER_TIMEOUT = 1 << 8,
	NOFALL = 1 << 9
}

---------------------------------------
include("scripts.bosses.mom")
include("scripts.bosses.momsheart")
include("scripts.bosses.satan")
include("scripts.bosses.satanfoot")
include("scripts.bosses.lamb")
include("scripts.bosses.isaac-bb") --TODO: Separate
include("scripts.bosses.megasatan")
include("scripts.bosses.megahand")
include("scripts.bosses.megasatan2")
include("scripts.bosses.hushbaby")
include("scripts.bosses.hush")

--TODO: not convinced these are working properly
include("scripts.bosses.delirium") -- would it even be delirium if it worked right?
include("scripts.bosses.ultragreed")
include("scripts.bosses.ultragreedier")
include("scripts.entities.ultradoor")
