-- helpers.lua  通用辅助组件

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")

local M = {}

-- ============================================================
-- CardHeader  深色点阵背景 + 斜体中文标题 + 英文副标题 + 金色底边
-- opts: { titleCN, titleEN, rightWidget, height }
-- 使用 UI.Panel + UI.Label（Yoga 原生），避免 NanoVG 坐标偏移导致文字叠加
-- ============================================================
function M.MakeCardHeader(opts)
    opts = opts or {}
    local hh = opts.height or 72

    -- 背景层（点阵渐变 + 金色底边）—— 纯 NanoVG，不含文字
    local BgW = UI.Widget:Extend("CardHBg_" .. (opts.titleEN or "x"):gsub("%s",""))
    function BgW:Init(p) UI.Widget.Init(self, p) end
    function BgW:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x,y,w,h = l.x,l.y,l.w,l.h
        -- 渐变背景
        local g = nvgLinearGradient(nvg, x, y, x+w*0.7, y+h,
            nvgRGBAf(24/255, 37/255, 53/255, 1),
            nvgRGBAf(37/255, 55/255, 78/255, 1))
        nvgBeginPath(nvg); nvgRect(nvg, x, y, w, h)
        nvgFillPaint(nvg, g); nvgFill(nvg)
        -- 点阵纹理
        for dy = 8, h, 16 do
            for dx = 8, w, 16 do
                nvgBeginPath(nvg); nvgCircle(nvg, x+dx, y+dy, 1.0)
                nvgFillColor(nvg, nvgRGBAf(0.6, 0.72, 0.82, 0.40)); nvgFill(nvg)
            end
        end
        -- 金色底边条 (4px)
        nvgBeginPath(nvg); nvgRect(nvg, x, y+h-4, w, 4)
        nvgFillColor(nvg, nvgRGBAf(255/255, 226/255, 58/255, 1)); nvgFill(nvg)
    end

    -- 前景文字区（Yoga Label，绝对定位覆盖背景）
    local fgChildren = {
        -- 左侧：中文大标题 + 英文副标题
        UI.Panel {
            flex=1, flexDirection="column",
            justifyContent="center", gap=3,
            paddingLeft=18, paddingBottom=4,
            children={
                UI.Label {
                    text=opts.titleCN or "",
                    fontSize=22, fontWeight="bold",
                    fontColor={255,255,255,255},
                },
                UI.Label {
                    text=opts.titleEN or "",
                    fontSize=11, fontWeight="bold", fontFamily="barlow",
                    fontColor={133,158,186,255},
                },
            }
        },
    }

    -- 右侧自定义控件
    if opts.rightWidget then
        table.insert(fgChildren, opts.rightWidget)
        table.insert(fgChildren, UI.Panel { width=12 })  -- 右边距
    end

    return UI.Panel {
        width="100%", height=hh,
        flexDirection="row", alignItems="center",
        children={
            -- 背景层（absolute，不占 flex 流）
            BgW:new({
                position="absolute", top=0, left=0,
                width="100%", height="100%",
            }),
            -- 前景文字层
            table.unpack(fgChildren),
        }
    }
end

-- ============================================================
-- SecTitle: 左侧 4px THEME_S 竖线 + 标题文字（用于卡片内部分组）
-- ============================================================
function M.SecTitle(text)
    return UI.Panel {
        width="100%", height=34,
        flexDirection="row", alignItems="center",
        marginBottom=10,
        children={
            UI.Panel {
                width=4, height=18, marginRight=10,
                backgroundColor={C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255},
            },
            UI.Label {
                text=text, fontSize=15, fontWeight="bold",
                fontColor={C.INK[1],C.INK[2],C.INK[3],255},
            },
        }
    }
end

-- ============================================================
-- HSep: 1px 半透明分隔线
-- ============================================================
function M.HSep(mt, mb)
    return UI.Panel {
        width="100%", height=1,
        marginTop=mt or 8, marginBottom=mb or 8,
        backgroundColor={C.GRAPHITE[1],C.GRAPHITE[2],C.GRAPHITE[3],30},
    }
end

-- ============================================================
-- SmallBadge: 状态小标签
-- ============================================================
function M.SmallBadge(text, bgRGBA, fgRGBA)
    bgRGBA = bgRGBA or {255,226,58,40}
    fgRGBA = fgRGBA or {140,110,0,255}
    return UI.Panel {
        flexDirection="row", alignItems="center",
        paddingLeft=8, paddingRight=8, paddingTop=3, paddingBottom=3,
        marginTop=4,
        backgroundColor=bgRGBA,
        borderRadius=3,
        children={
            UI.Label {
                text=text, fontSize=10,
                fontColor=fgRGBA,
                whiteSpace="normal",
            }
        }
    }
end

-- ============================================================
-- CheckIcon: NanoVG Checkbox 图标 Widget（圆角正方形 + 勾/叉）
-- opts: { size, checked, borderC, fillC, checkC }
-- ============================================================
function M.MakeCheckIcon(opts)
    opts = opts or {}
    local sz   = opts.size    or 20
    local CheckIcon = UI.Widget:Extend("CheckIcon_" .. tostring(sz))
    function CheckIcon:Init(p)
        p = p or {}
        self.checked_  = p.checked or false
        self.borderC_  = p.borderC or C.GRAPHITE
        self.fillC_    = p.fillC   or C.THEME_S
        self.checkC_   = p.checkC  or C.GRAPHITE
        p.checked=nil; p.borderC=nil; p.fillC=nil; p.checkC=nil
        UI.Widget.Init(self, p)
    end
    function CheckIcon:SetChecked(v)
        self.checked_ = v
        self:Invalidate()
    end
    function CheckIcon:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x,y,w,h = l.x,l.y,l.w,l.h
        local cx,cy,s = x+w/2, y+h/2, math.min(w,h)*0.78
        local r = 3

        -- 背景框
        if self.checked_ then
            nvgBeginPath(nvg); nvgRoundedRect(nvg, cx-s/2, cy-s/2, s, s, r)
            nvgFillColor(nvg, nvgRGBAf(self.fillC_[1]/255, self.fillC_[2]/255,
                self.fillC_[3]/255, 1))
            nvgFill(nvg)
        else
            nvgBeginPath(nvg); nvgRoundedRect(nvg, cx-s/2, cy-s/2, s, s, r)
            nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 0.08)); nvgFill(nvg)
            nvgStrokeColor(nvg, nvgRGBAf(self.borderC_[1]/255, self.borderC_[2]/255,
                self.borderC_[3]/255, 0.6))
            nvgStrokeWidth(nvg, 1.5); nvgStroke(nvg)
        end

        -- 勾
        if self.checked_ then
            local sc = self.checkC_
            nvgBeginPath(nvg)
            nvgMoveTo(nvg, cx-s*0.25, cy+0.02*s)
            nvgLineTo(nvg, cx-0.05*s, cy+s*0.28)
            nvgLineTo(nvg, cx+s*0.30, cy-s*0.22)
            nvgStrokeColor(nvg, nvgRGBAf(sc[1]/255, sc[2]/255, sc[3]/255, 1))
            nvgStrokeWidth(nvg, 2.0); nvgLineCap(nvg, 2); nvgStroke(nvg)
        end
    end

    return CheckIcon:new({
        width=sz, height=sz,
        checked=opts.checked or false,
        borderC=opts.borderC or C.GRAPHITE,
        fillC=opts.fillC or C.THEME_S,
        checkC=opts.checkC or C.GRAPHITE,
    })
end

return M
