-- state.lua  全局零件装备状态 + 性能联动（响应式单例）
-- 用法：
--   local State = require("scripts/state")
--   State.Equip("turbo", partObj)   -- 换装零件
--   State.OnRefresh(function() ... end)  -- 注册刷新回调
--   State.MainStatValue(stat)       -- 获取主属性当前值（含零件效果）
--   State.SubStatValue(sub)         -- 获取副属性当前值
--   State.TotalPerf()               -- 获取综合性能值

local C = require("scripts/constants")

local M = {}

-- ── 初始化：从 C.EQUIPPED_PARTS 找到对应的完整零件对象 ──────────────
M.equippedParts = {}
for slotKey, partName in pairs(C.EQUIPPED_PARTS) do
    local lib = C.PARTS_LIBRARY[slotKey]
    if lib and partName then
        for _, p in ipairs(lib) do
            if p.name == partName then
                M.equippedParts[slotKey] = p
                break
            end
        end
    end
end

-- ── 计算所有已装备零件的效果叠加 ────────────────────────────────────
local function computeEffectsFrom(parts)
    local fx = {}
    for _, part in pairs(parts) do
        if part and part.effects then
            for k, v in pairs(part.effects) do
                fx[k] = (fx[k] or 0) + v
            end
        end
    end
    return fx
end

-- 保存初始效果（用于计算 delta）
M.initialEffects = computeEffectsFrom(M.equippedParts)

-- 当前效果缓存（Equip 后失效）
M._effectsCache = nil

function M.ComputeEffects()
    if M._effectsCache then return M._effectsCache end
    M._effectsCache = computeEffectsFrom(M.equippedParts)
    return M._effectsCache
end

-- ── Delta：当前效果相对初始效果的变化量 ─────────────────────────────
function M.StatDelta(key)
    return (M.ComputeEffects()[key] or 0) - (M.initialEffects[key] or 0)
end

-- 总综合性能 delta（处理移除零件的情况）
function M.TotalDelta()
    local cur = M.ComputeEffects()
    local delta = 0
    -- 当前效果 - 初始效果
    for k, v in pairs(cur) do
        delta = delta + v - (M.initialEffects[k] or 0)
    end
    -- 被移除的效果（初始有，当前没有）
    for k, v in pairs(M.initialEffects) do
        if not cur[k] then
            delta = delta - v
        end
    end
    return delta
end

-- ── 属性值计算 ───────────────────────────────────────────────────────
function M.TotalPerf()
    return C.PERF_TOTAL + M.TotalDelta()
end

-- stat: MAIN_STATS 中的一项（含 key, base, bonus）
function M.MainStatValue(stat)
    return stat.base + stat.bonus + M.StatDelta(stat.key)
end

-- sub: SUB_STATS 中的一项（含 key, val）
function M.SubStatValue(sub)
    return sub.val + M.StatDelta(sub.key)
end

-- ── 响应式刷新系统 ───────────────────────────────────────────────────
local refreshCallbacks = {}

function M.OnRefresh(cb)
    table.insert(refreshCallbacks, cb)
end

function M.Refresh()
    for _, cb in ipairs(refreshCallbacks) do
        local ok, err = pcall(cb)
        if not ok then
            print("[State] Refresh callback error: " .. tostring(err))
        end
    end
end

-- ── 换装零件 ─────────────────────────────────────────────────────────
-- slotKey: "turbo"/"ecu"/"susp"/"tyre"
-- part: 完整零件对象（含 effects），或 nil 表示卸下
function M.Equip(slotKey, part)
    M.equippedParts[slotKey] = part
    C.EQUIPPED_PARTS[slotKey] = part and part.name or nil
    M._effectsCache = nil   -- 使缓存失效
    M.Refresh()
    print("[State] 换装 " .. tostring(slotKey) .. " → " ..
          (part and part.name or "nil") ..
          "  综合性能=" .. tostring(M.TotalPerf()))
end

return M
