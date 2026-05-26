-- UIKit/SpringButton.lua
-- 点击时产生弹簧回弹缩放反馈的按钮工厂
--
-- 用法（两种模式）：
--
-- 模式 A：包装现有 Widget，给它注入弹簧回弹行为
--   local SpringButton = require("scripts/UIKit/SpringButton")
--   local btn
--   btn = SpringButton.wrap(someWidget, function()
--       -- 真正的 onClick 逻辑
--   end)
--
-- 模式 B：创建标准 UI.Button 并附加弹簧行为
--   local btn = SpringButton.new({
--       text      = "确认",
--       variant   = "primary",
--       fontSize  = 14,
--       onClick   = function() ... end,
--       -- 以下为可选动画参数
--       pressScale    = 0.88,   -- 按下缩放，默认 0.88
--       pressEasing   = "scale 0.10s easeIn",
--       bounceEasing  = "scale 0.30s easeOutBack",
--   })
--
-- 注意：wrap() 依赖目标 Widget 支持 SetStyle / SetProp，
--       并且目标 Widget 的 onClick 会被替换。

local UI = require("urhox-libs/UI")

local SpringButton = {}

local DEFAULT_PRESS_SCALE  = 0.88
local DEFAULT_PRESS_T      = "scale 0.10s easeIn"
local DEFAULT_BOUNCE_T     = "scale 0.30s easeOutBack"

---内部：给 widget 注入弹簧点击动画
---@param widget any     支持 SetStyle 的 Panel / Widget
---@param onClickFn fun()  真正的点击逻辑
local function injectSpring(widget, onClickFn, pressScale, pressT, bounceT)
    pressScale = pressScale or DEFAULT_PRESS_SCALE
    pressT     = pressT     or DEFAULT_PRESS_T
    bounceT    = bounceT    or DEFAULT_BOUNCE_T

    widget:SetProp("onClick", function(self)
        -- 按下
        widget:SetStyle({ scale = pressScale, transition = pressT })
        -- 下一帧回弹
        local rebounded = false
        SubscribeToEvent("Update", function(et, ed)
            if rebounded then return end
            rebounded = true
            widget:SetStyle({ scale = 1.0, transition = bounceT })
        end)
        -- 执行业务回调
        if onClickFn then onClickFn() end
    end)
end

---包装已有 widget，注入弹簧行为
---@param widget any
---@param onClickFn fun()
---@param cfg? table   { pressScale, pressEasing, bounceEasing }
---@return any         widget 本身（方便链式赋值）
function SpringButton.wrap(widget, onClickFn, cfg)
    cfg = cfg or {}
    injectSpring(widget, onClickFn,
        cfg.pressScale   or DEFAULT_PRESS_SCALE,
        cfg.pressEasing  or DEFAULT_PRESS_T,
        cfg.bounceEasing or DEFAULT_BOUNCE_T)
    return widget
end

---创建带弹簧效果的 UI.Button
---@param opts table  { text, variant, fontSize, onClick, pressScale, pressEasing, bounceEasing, ... }
---@return any  Panel
function SpringButton.new(opts)
    opts = opts or {}
    local onClickFn  = opts.onClick
    local pressScale = opts.pressScale   or DEFAULT_PRESS_SCALE
    local pressT     = opts.pressEasing  or DEFAULT_PRESS_T
    local bounceT    = opts.bounceEasing or DEFAULT_BOUNCE_T

    -- 移除 SpringButton 专属字段，剩余传给 UI.Button
    local btnOpts = {}
    for k, v in pairs(opts) do
        if k ~= "pressScale" and k ~= "pressEasing" and k ~= "bounceEasing" then
            btnOpts[k] = v
        end
    end
    -- 先清空 onClick，稍后由 injectSpring 设置
    btnOpts.onClick = nil

    local btn = UI.Button(btnOpts)
    injectSpring(btn, onClickFn, pressScale, pressT, bounceT)
    return btn
end

return SpringButton
