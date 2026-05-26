-- UIKit/AnimModal.lua
-- 通用弹窗动画系统
-- 遮罩层只做 opacity 淡入淡出，弹窗卡片做 scale+translateY 弹入弹出
--
-- 用法：
--   local AnimModal = require("scripts/UIKit/AnimModal")
--
--   -- 初始化（传入宿主容器 Panel，page 级别的 overlayLayer）
--   local modal = AnimModal.new(overlayLayer)
--
--   -- 打开弹窗
--   --   overlay: 全屏遮罩 Panel（由 PartsM.Build 等返回）
--   --   card:    弹窗卡片 Panel（遮罩内部的可见内容）
--   modal:Open(overlay, card)
--
--   -- 关闭弹窗（带动画，动画结束后自动从树中移除）
--   modal:Close()
--
--   -- 当前是否有弹窗打开
--   modal:IsOpen()  --> boolean

local AnimModal = {}
AnimModal.__index = AnimModal

-- 动画参数（可按需在 new() 时覆盖）
local DEFAULT_CFG = {
    openOverlayT  = "opacity 0.22s easeOut",
    openCardT     = "scale 0.30s easeOutBack, translateY 0.28s easeOut",
    closeOverlayT = "opacity 0.22s easeOut",
    closeCardT    = "scale 0.20s easeIn, translateY 0.20s easeIn",
    closeDelay    = 0.25,   -- 移除节点延迟（秒），需 >= 关闭动画时长
    cardInitScale = 0.88,
    cardInitY     = 14,
    cardCloseY    = 10,
}

---@param overlayLayer Panel  宿主容器（全屏 absolute Panel，pointerEvents="none"）
---@param cfg? table          可选覆盖默认动画参数
function AnimModal.new(overlayLayer, cfg)
    local self = setmetatable({}, AnimModal)
    self.layer_   = overlayLayer
    self.cfg_     = cfg or DEFAULT_CFG
    self.overlay_ = nil   -- 当前遮罩
    self.card_    = nil   -- 当前卡片
    return self
end

function AnimModal:IsOpen()
    return self.overlay_ ~= nil
end

---打开弹窗
---@param overlay Panel  全屏遮罩（Build 返回的根节点）
---@param card Panel     弹窗卡片（overlay 内部的浮动内容）
function AnimModal:Open(overlay, card)
    -- 如有旧弹窗强制清理（不走动画，避免重叠）
    if self.overlay_ then
        self.layer_:RemoveChild(self.overlay_)
        self.overlay_ = nil
        self.card_    = nil
    end

    local cfg = self.cfg_

    -- 遮罩初始状态：完全透明
    overlay:SetStyle({
        opacity    = 0,
        transition = cfg.openOverlayT,
    })
    -- 卡片初始状态：缩小 + 向下偏移
    card:SetStyle({
        scale      = cfg.cardInitScale,
        translateY = cfg.cardInitY,
        transition = cfg.openCardT,
    })

    self.layer_:AddChild(overlay)
    self.layer_:SetProp("pointerEvents", "auto")
    self.overlay_ = overlay
    self.card_    = card

    -- 下一帧触发弹入动画
    local triggered = false
    SubscribeToEvent("Update", function(et, ed)
        if triggered then return end
        triggered = true
        overlay:SetStyle({ opacity = 1 })
        card:SetStyle({ scale = 1.0, translateY = 0 })
    end)
end

---关闭弹窗（带动画，延迟后从树中移除）
function AnimModal:Close()
    if not self.overlay_ then return end

    local cfg     = self.cfg_
    local modalRef = self.overlay_
    local cardRef  = self.card_

    modalRef:SetStyle({
        opacity    = 0,
        transition = cfg.closeOverlayT,
    })
    cardRef:SetStyle({
        scale      = cfg.cardInitScale,
        translateY = cfg.cardCloseY,
        transition = cfg.closeCardT,
    })

    self.overlay_ = nil
    self.card_    = nil

    local elapsed = 0
    local removed = false
    SubscribeToEvent("Update", function(et, ed)
        if removed then return end
        elapsed = elapsed + ed["TimeStep"]:GetFloat()
        if elapsed >= cfg.closeDelay then
            removed = true
            self.layer_:RemoveChild(modalRef)
            self.layer_:SetProp("pointerEvents", "none")
        end
    end)
end

return AnimModal
