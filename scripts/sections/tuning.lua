-- sections/tuning.lua
-- 参考图3：
--   ① 深色卡头"构筑调校 / ECU TUNING"
--   ② 浅灰点阵底纹主体
--   ③ "阶级 RANK" + 方形阶级按钮（S/SS/SSS，当前阶级填色）
--   ④ "等级 LEVEL" + 滑块在左 + 方框数字在右
--   ⑤ "快捷预设" + 全宽描边按钮（文字自动换行）
--   ⑥ "携带皮肤加成" + 方形 checkbox + 文字 + 说明

local UI           = require("urhox-libs/UI")
local C            = require("scripts/constants")
local H            = require("scripts/helpers")
local SpringButton = require("scripts/UIKit/SpringButton")

local M = {}

-- ── 顶层类定义（避免 M.Build 内重复创建类，Invalidate 找不到问题）──

local TierBtn = UI.Widget:Extend("TierBtn_tuning")
function TierBtn:Init(p)
    p = p or {}
    self.active_   = p.active   or false
    self.tierDat_  = p.tierDat  or {}
    p.active  = nil
    p.tierDat = nil
    UI.Widget.Init(self, p)
end
function TierBtn:SetActive(v)
    self.active_ = v
    if self.Invalidate then self:Invalidate() end
end
function TierBtn:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h
    local t = self.tierDat_
    -- 背景
    if self.active_ then
        local rc = t.bg
        nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
        nvgFillColor(nvg,nvgRGBAf(rc[1]/255,rc[2]/255,rc[3]/255,1)); nvgFill(nvg)
    else
        nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
        nvgFillColor(nvg,nvgRGBAf(1,1,1,1)); nvgFill(nvg)
    end
    -- 描边
    nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
    nvgStrokeColor(nvg,nvgRGBAf(C.GRAPHITE[1]/255,C.GRAPHITE[2]/255,C.GRAPHITE[3]/255,1))
    nvgStrokeWidth(nvg,2); nvgStroke(nvg)
    -- 文字
    nvgFontFace(nvg,UI.Theme.FontFace("barlow","bold"))
    nvgFontSize(nvg,UI.Theme.FontSize(15))
    nvgFillColor(nvg,nvgRGBAf(C.GRAPHITE[1]/255,C.GRAPHITE[2]/255,C.GRAPHITE[3]/255,1))
    nvgTextAlign(nvg,2|16); nvgText(nvg,x+w/2,y+h/2,t.label)
end

-- ── LevelBox：等级数字框 ────────────────────────────────────────────
local LevelBox = UI.Widget:Extend("LevelBox_tu")
function LevelBox:Init(p)
    p = p or {}
    self.val_ = p.val or 1
    p.val = nil
    UI.Widget.Init(self, p)
end
function LevelBox:SetVal(v)
    self.val_ = v
    if self.Invalidate then self:Invalidate() end
end
function LevelBox:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h
    nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
    nvgFillColor(nvg,nvgRGBAf(1,1,1,1)); nvgFill(nvg)
    nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
    nvgStrokeColor(nvg,nvgRGBAf(C.GRAPHITE[1]/255,C.GRAPHITE[2]/255,C.GRAPHITE[3]/255,1))
    nvgStrokeWidth(nvg,2); nvgStroke(nvg)
    nvgFontFace(nvg,UI.Theme.FontFace("teko","bold"))
    nvgFontSize(nvg,UI.Theme.FontSize(22))
    nvgFillColor(nvg,nvgRGBAf(C.INK[1]/255,C.INK[2]/255,C.INK[3]/255,1))
    nvgTextAlign(nvg,2|16); nvgText(nvg,x+w/2,y+h/2,tostring(self.val_))
end

-- ── SkinChk：皮肤加成方形 checkbox ──────────────────────────────────
local SkinChk = UI.Widget:Extend("SkinChk_tu")
function SkinChk:Init(p)
    p = p or {}
    self.checked_ = p.checked or false
    p.checked = nil
    UI.Widget.Init(self, p)
end
function SkinChk:SetChecked(v)
    self.checked_ = v
    if self.Invalidate then self:Invalidate() end
end
function SkinChk:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h
    nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
    nvgFillColor(nvg,nvgRGBAf(1,1,1,1)); nvgFill(nvg)
    nvgStrokeColor(nvg,nvgRGBAf(C.GRAPHITE[1]/255,C.GRAPHITE[2]/255,C.GRAPHITE[3]/255,1))
    nvgStrokeWidth(nvg,2); nvgStroke(nvg)
    if self.checked_ then
        local cx,cy,s = x+w/2,y+h/2,w*0.28
        nvgBeginPath(nvg)
        nvgMoveTo(nvg,cx-s,cy); nvgLineTo(nvg,cx-s*0.1,cy+s*0.9)
        nvgLineTo(nvg,cx+s,cy-s*0.8)
        nvgStrokeColor(nvg,nvgRGBAf(C.GRAPHITE[1]/255,C.GRAPHITE[2]/255,C.GRAPHITE[3]/255,1))
        nvgStrokeWidth(nvg,2.5); nvgLineCap(nvg,2); nvgStroke(nvg)
    end
end

function M.Build()
    local selectedTier = 1
    ---@type table[]
    local tierBtnWidgets = {}

    -- ── 方形阶级按钮工厂 ─────────────────────────────────────────────
    local function MakeTierBtn(tier, idx)
        local w = (#tier.label == 1) and 44 or (#tier.label == 2) and 52 or 62
        local btn = TierBtn:new({
            width=w, height=40,
            active=(idx==1),
            tierDat=tier,
            transition = "scale 0.12s easeIn",
        })
        SpringButton.wrap(btn, function()
            selectedTier = idx
            for j, tb in ipairs(tierBtnWidgets) do
                tb:SetActive(j==idx)
            end
        end)
        table.insert(tierBtnWidgets, btn)
        return btn
    end

    -- 阶级区
    local tierLabel = UI.Panel {
        flexDirection="row", alignItems="center", gap=4, marginBottom=10,
        children={
            UI.Label { text="阶级", fontSize=13, fontWeight="bold",
                fontColor={C.INK[1],C.INK[2],C.INK[3],255} },
            UI.Label { text="RANK", fontSize=11, fontFamily="barlow",
                fontColor={C.MUTED[1],C.MUTED[2],C.MUTED[3],255} },
        }
    }
    local tierRow = UI.Panel {
        flexDirection="row", gap=6, marginBottom=18,
    }
    for i, t in ipairs(C.TIERS) do
        tierRow:AddChild(MakeTierBtn(t, i))
    end

    -- ── 等级：滑块左 + 数字框右 ──────────────────────────────────────
    local levelVal = 1
    ---@type any
    local levelBox = LevelBox:new({ width=52, height=40, val=1 })

    local slider = UI.Slider {
        flex=1, height=28,
        value=1, min=1, max=30, step=1,
        trackColor={C.TRACK_C[1],C.TRACK_C[2],C.TRACK_C[3],255},
        thumbColor={C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255},
        activeTrackColor={C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255},
        onChange=function(_, v)
            levelVal = math.floor(v)
            levelBox:SetVal(levelVal)
        end,
    }

    local levelLbl = UI.Panel {
        flexDirection="row", alignItems="center", gap=4, marginBottom=10,
        children={
            UI.Label { text="等级", fontSize=13, fontWeight="bold",
                fontColor={C.INK[1],C.INK[2],C.INK[3],255} },
            UI.Label { text="LEVEL", fontSize=11, fontFamily="barlow",
                fontColor={C.MUTED[1],C.MUTED[2],C.MUTED[3],255} },
        }
    }
    local levelRow = UI.Panel {
        width="100%", flexDirection="row",
        alignItems="center", gap=10, marginBottom=18,
        children={ slider, levelBox }
    }

    -- ── 全宽描边按钮（用 UI.Panel+UI.Label 实现自动换行）────────────
    local function OutlineBtn(label, onClickFn)
        return UI.Panel {
            width="100%", minHeight=46,
            justifyContent="center", alignItems="center",
            paddingHorizontal=14, paddingVertical=10,
            borderWidth=2,
            borderColor={C.GRAPHITE[1],C.GRAPHITE[2],C.GRAPHITE[3],255},
            backgroundColor={255,255,255,255},
            onClick=onClickFn,
            children={
                UI.Label {
                    text=label, fontSize=12, fontWeight="bold",
                    fontColor={C.INK[1],C.INK[2],C.INK[3],255},
                    textAlign="center",
                    whiteSpace="normal",
                    flexShrink=1,
                }
            }
        }
    end

    -- 快捷预设
    local presetLbl = UI.Label {
        text="快捷预设", fontSize=13, fontWeight="bold",
        fontColor={C.INK[1],C.INK[2],C.INK[3],255},
        marginBottom=8,
    }
    local presetBtn = OutlineBtn("满阶性能（SSS / Lv30 / 全特性 / 无皮肤）", function()
        selectedTier = #C.TIERS
        for j, tb in ipairs(tierBtnWidgets) do tb:SetActive(j==#C.TIERS) end
        slider:SetProp("value", 30)
        levelBox:SetVal(30)
    end)

    -- ── 携带皮肤加成 ─────────────────────────────────────────────────
    local skinOn = false
    ---@type any
    local skinChk = SkinChk:new({ width=20, height=20, checked=false })

    ---@type Label
    local skinMainLbl = UI.Label {
        text="携带皮肤加成", fontSize=13, fontWeight="bold",
        fontColor={C.INK[1],C.INK[2],C.INK[3],255},
        marginBottom=8,
    }
    ---@type Label
    local skinSubLbl = UI.Label {
        text="按涂装规则计入属性", fontSize=12,
        fontColor={C.INK[1],C.INK[2],C.INK[3],255},
    }
    ---@type Label
    local skinDescLbl = UI.Label {
        text="未启用：不计入涂装额外属性（用于纯车体对比）",
        fontSize=11, fontColor={C.MUTED2[1],C.MUTED2[2],C.MUTED2[3],255},
        whiteSpace="normal", lineHeight=1.5, marginTop=4,
    }

    local skinChkRow = UI.Panel {
        flexDirection="row", alignItems="center", gap=10, marginBottom=6,
        onClick=function()
            skinOn = not skinOn
            skinChk:SetChecked(skinOn)
            skinDescLbl:SetProp("text",
                skinOn and "已启用：按涂装规则计入属性"
                        or "未启用：不计入涂装额外属性（用于纯车体对比）")
        end,
        children={ skinChk, skinSubLbl }
    }

    return H.MakeCard({
        titleCN  = "构筑调校",
        titleEN  = "ECU TUNING",
        children = {
            tierLabel, tierRow,
            levelLbl, levelRow,
            presetLbl, presetBtn,
            H.HSep(14,10),
            skinMainLbl,
            skinChkRow,
            skinDescLbl,
        },
    })
end

return M
