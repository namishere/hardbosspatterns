-- Classes

-- Classes doc annotations for constructors are done
-- using a placeholder function that will be replaced
-- immediately after by the actual class object, to make
-- the job of the Lua language server easier

---@param Type string
---@param AllowMultipleInit? boolean
---@return HardBossPatternsClass
function HardBossPatterns.Class(Type, AllowMultipleInit)
end

---@class HardBossPatternsClass
---@field Type string
---@field private AllowMultipleInit number
---@field private Initialized boolean
---@field protected Init fun(self: HardBossPatternsClass, ...: any)
---@field protected PostInit fun(self: HardBossPatternsClass, ...: any)
---@field protected InheritInit fun(self: HardBossPatternsClass, ...: any)
HardBossPatterns.Class = {}

function HardBossPatterns.ClassInit(tbl, ...)
    local inst = {}
    setmetatable(inst, tbl)
    tbl.__index = tbl
    tbl.__call = HardBossPatterns.ClassInit

    if inst.AllowMultipleInit or not inst.Initialized then
        inst.Initialized = true
        if inst.Init then
            inst:Init(...)
        end

        if inst.PostInit then
            inst:PostInit(...)
        end
    else
        if inst.InheritInit then
            inst:InheritInit(...)
        end
    end

    return inst
end

function HardBossPatterns.Class:Init(Type, AllowMultipleInit)
    self.Type = Type
    self.AllowMultipleInit = AllowMultipleInit
    self.Initialized = false
end

setmetatable(HardBossPatterns.Class, {
    ---@generic C : HardBossPatternsClass
    ---@param self C
    ---@return C
    __call = HardBossPatterns.ClassInit
})
