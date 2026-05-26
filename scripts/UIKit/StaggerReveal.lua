-- UIKit/StaggerReveal.lua
-- 卡片/元素错开入场动画
--
-- 用法：
--   local StaggerReveal = require("scripts/UIKit/StaggerReveal")
--
--   -- 最简用法（使用默认配置）
--   StaggerReveal(cards)
--
--   -- 自定义配置
--   StaggerReveal(cards, {
--       startDelay = 0.08,   -- 首张触发延迟（秒），默认 0.08
--       interval   = 0.10,   -- 相邻元素间隔（秒），默认 0.10
--       transition = "opacity 0.40s easeOut, translateY 0.42s easeOutBack",
--       initY      = 28,     -- 初始向下偏移（px），默认 28
--   })

local DEFAULT_CFG = {
    startDelay = 0.08,
    interval   = 0.10,
    transition = "opacity 0.40s easeOut, translateY 0.42s easeOutBack",
    initY      = 28,
}

---@param panels table   Panel 数组（Yoga 节点）
---@param cfg?   table   可选配置，覆盖 DEFAULT_CFG
local function StaggerReveal(panels, cfg)
    if not panels or #panels == 0 then return end
    cfg = cfg or DEFAULT_CFG

    local startDelay = cfg.startDelay or DEFAULT_CFG.startDelay
    local interval   = cfg.interval   or DEFAULT_CFG.interval
    local transition = cfg.transition or DEFAULT_CFG.transition
    local initY      = cfg.initY      or DEFAULT_CFG.initY

    -- 设置初始隐藏状态
    for _, panel in ipairs(panels) do
        panel:SetStyle({
            opacity    = 0,
            translateY = initY,
            transition = transition,
        })
    end

    -- 构建触发序列
    local pending = {}
    for i, panel in ipairs(panels) do
        table.insert(pending, {
            panel = panel,
            t     = startDelay + (i - 1) * interval,
            done  = false,
        })
    end

    local clock = 0
    SubscribeToEvent("Update", function(et, ed)
        if #pending == 0 then return end
        clock = clock + ed["TimeStep"]:GetFloat()
        local allDone = true
        for _, entry in ipairs(pending) do
            if not entry.done then
                if clock >= entry.t then
                    entry.panel:SetStyle({ opacity = 1, translateY = 0 })
                    entry.done = true
                else
                    allDone = false
                end
            end
        end
        if allDone then pending = {} end
    end)
end

return StaggerReveal
