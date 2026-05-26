-- sections/traits.lua
-- 参考图4：
--   ① 深色卡头"特性词条 / TRAITS MODULE"
--   ② 2列词条卡片网格
--   ③ 每张卡：左侧方形 checkbox（橙色填充=激活）+ 标题 + [基础特性] 解锁 + 描述
--   ④ 激活态：橙色边框 + 淡橙背景
--   ⑤ 非激活：白底灰边

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")
local H  = require("scripts/helpers")

local M = {}

-- 激活色（参考图4：橙色，与 THEME_S 相近）
local ACTIVE_BG  = {255, 220, 120,  35}
local ACTIVE_BD  = {255, 170,  40, 220}

-- 方形 checkbox Widget（参考图4：实色正方形，激活=橙填充）
local sqChkCounter = 0
local function MakeSquareCheck(active)
    sqChkCounter = sqChkCounter + 1
    local ChkW = UI.Widget:Extend("SqChk_tr_"..sqChkCounter)
    function ChkW:Init(p)
        p = p or {}
        self.active_ = p.active or false
        p.active = nil
        UI.Widget.Init(self, p)
    end
    function ChkW:SetActive(v)
        self.active_ = v
        if self.Invalidate then self:Invalidate() end
    end
    function ChkW:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x,y,w,h = l.x,l.y,l.w,l.h
        local s = math.min(w,h)*0.9
        local ox,oy = x+(w-s)/2, y+(h-s)/2
        if self.active_ then
            -- 橙色填充方块
            nvgBeginPath(nvg); nvgRect(nvg,ox,oy,s,s)
            nvgFillColor(nvg,nvgRGBAf(255/255,170/255,40/255,1)); nvgFill(nvg)
            -- 白色勾
            nvgBeginPath(nvg)
            nvgMoveTo(nvg,ox+s*0.18,oy+s*0.52)
            nvgLineTo(nvg,ox+s*0.42,oy+s*0.76)
            nvgLineTo(nvg,ox+s*0.82,oy+s*0.22)
            nvgStrokeColor(nvg,nvgRGBAf(1,1,1,1))
            nvgStrokeWidth(nvg,2.5); nvgLineCap(nvg,2); nvgStroke(nvg)
        else
            -- 白底灰边
            nvgBeginPath(nvg); nvgRect(nvg,ox,oy,s,s)
            nvgFillColor(nvg,nvgRGBAf(1,1,1,1)); nvgFill(nvg)
            nvgStrokeColor(nvg,nvgRGBAf(0.65,0.72,0.80,1))
            nvgStrokeWidth(nvg,1.5); nvgStroke(nvg)
        end
    end
    return ChkW:new({ width=22, height=22, active=active })
end

function M.Build()
    -- 初始状态：C/B 档解锁的默认激活（参考图4：前两个橙色）
    local activeState = {}
    for _, t in ipairs(C.TRAITS) do
        activeState[t.title] = (t.badge == nil)
    end

    -- ── 词条卡片（显式双列，避免 50%+gap 溢出） ──────────────────────
    -- 用左/右两个 flex=1 列，交替分配词条
    local leftCol  = UI.Panel { flex=1, flexDirection="column", gap=8 }
    local rightCol = UI.Panel { flex=1, flexDirection="column", gap=8 }

    for idx, t in ipairs(C.TRAITS) do
        local isActive = activeState[t.title]

        local chkW = MakeSquareCheck(isActive)

        local bdC = isActive and ACTIVE_BD or {200,215,230,255}
        local bgC = isActive and ACTIVE_BG or {248,251,255,255}

        -- "[基础特性]  解锁: X档" 信息行
        local infoRow = UI.Panel {
            flexDirection="row", alignItems="center",
            flexWrap="wrap", gap=4, marginBottom=4,
            children={
                UI.Label {
                    text="[基础特性]", fontSize=10,
                    fontColor={C.MUTED2[1],C.MUTED2[2],C.MUTED2[3],255},
                },
                UI.Label {
                    text=t.unlockDesc, fontSize=10,
                    fontColor={C.MUTED2[1],C.MUTED2[2],C.MUTED2[3],255},
                },
            }
        }

        local titleLbl = UI.Label {
            text=t.title, fontSize=14, fontWeight="bold",
            fontColor={C.INK[1],C.INK[2],C.INK[3],255},
            marginBottom=3,
            whiteSpace="normal",
        }
        local descLbl = UI.Label {
            text=t.desc, fontSize=11,
            fontColor={C.MUTED2[1],C.MUTED2[2],C.MUTED2[3],255},
            whiteSpace="normal", lineHeight=1.4,
        }

        -- 卡片宽度 100%（相对于所在列）
        local card
        local function onCardClick()
            isActive = not isActive
            activeState[t.title] = isActive
            chkW:SetActive(isActive)
            local nb = isActive and ACTIVE_BD or {200,215,230,255}
            local bb = isActive and ACTIVE_BG or {248,251,255,255}
            card:SetProp("borderColor", nb)
            card:SetProp("backgroundColor", bb)
        end

        local content = UI.Panel {
            flex=1, flexShrink=1, flexDirection="column",
            children={ titleLbl, infoRow, descLbl }
        }

        card = UI.Panel {
            width="100%",
            flexDirection="row",
            alignItems="flex-start",
            padding=10, gap=8,
            borderWidth=1.5, borderColor=bdC,
            backgroundColor=bgC,
            borderRadius=4,
            onClick=onCardClick,
            children={ chkW, content },
        }

        -- 奇数 → 左列，偶数 → 右列
        if idx % 2 == 1 then
            leftCol:AddChild(card)
        else
            rightCol:AddChild(card)
        end
    end

    -- 双列容器
    local grid = UI.Panel {
        width="100%", flexDirection="row", gap=8,
        children={ leftCol, rightCol }
    }

    return H.MakeCard({
        titleCN  = "特性词条",
        titleEN  = "TRAITS MODULE",
        children = { grid },
    })
end

return M
