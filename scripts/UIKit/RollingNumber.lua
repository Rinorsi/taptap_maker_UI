-- UIKit/RollingNumber.lua
-- 数字滚动计数器（tween 驱动）
-- 适用于：得分、金币、血量、综合性能等任意数值的平滑动画过渡
--
-- 用法：
--   local RollingNumber = require("scripts/UIKit/RollingNumber")
--
--   -- 创建计数器实例
--   local counter = RollingNumber.new({
--       initial  = 0,        -- 初始值，默认 0
--       duration = 1.0,      -- 动画时长（秒），默认 1.0
--       easing   = "outQuad",-- 缓动函数，默认 "outQuad"
--       format   = function(v) return tostring(math.floor(v)) end
--                            -- 格式化函数，默认整数
--   })
--
--   -- 读取当前显示值（字符串，可直接用于 Label）
--   counter:Get()       --> "0"
--
--   -- 设置目标值并触发动画
--   counter:Set(594)
--
--   -- 在 Update 中每帧驱动（必须调用）
--   counter:Update(dt)
--
-- 典型集成（NanoVG 文字由闭包驱动，无需手动 Invalidate）：
--   local perfScore = RollingNumber.new({ initial = State.TotalPerf() })
--
--   -- 注册 Update 驱动（只注册一次）
--   SubscribeToEvent("Update", function(et, ed)
--       perfScore:Update(ed["TimeStep"]:GetFloat())
--   end)
--
--   -- NanoVG Render 里直接读值
--   nvgText(nvg, x, y, perfScore:Get())
--
--   -- 换装后刷新
--   perfScore:Set(State.TotalPerf())

local tween = require("scripts/tween")

local RollingNumber = {}
RollingNumber.__index = RollingNumber

local function defaultFormat(v)
    return tostring(math.floor(v + 0.5))
end

---@param opts table  { initial, duration, easing, format }
function RollingNumber.new(opts)
    opts = opts or {}
    local initial = opts.initial or 0
    local self = setmetatable({
        proxy_    = { v = initial },
        tween_    = nil,
        duration_ = opts.duration or 1.0,
        easing_   = opts.easing   or "outQuad",
        format_   = opts.format   or defaultFormat,
    }, RollingNumber)
    return self
end

---每帧驱动（在 Update 事件中调用）
---@param dt number  时间步长（秒）
function RollingNumber:Update(dt)
    if self.tween_ then
        local done = self.tween_:update(dt)
        if done then self.tween_ = nil end
    end
end

---设置目标值，触发滚动动画
---@param targetVal number
function RollingNumber:Set(targetVal)
    self.tween_ = tween.new(self.duration_, self.proxy_, { v = targetVal }, self.easing_)
end

---立即跳到指定值，不播动画
---@param val number
function RollingNumber:Jump(val)
    self.proxy_.v = val
    self.tween_   = nil
end

---读取当前显示值（格式化字符串）
---@return string
function RollingNumber:Get()
    return self.format_(self.proxy_.v)
end

---读取当前原始浮点值
---@return number
function RollingNumber:Raw()
    return self.proxy_.v
end

return RollingNumber
