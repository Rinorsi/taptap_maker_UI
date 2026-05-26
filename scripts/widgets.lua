-- widgets.lua  自定义 Widget 定义
-- SurfacePanel / SkewBtn / TagItem / StatBar

local UI  = require("urhox-libs/UI")
local C   = require("scripts/constants")

local M = {}

local function nvgC(t)
    return nvgRGBAf(t[1]/255, t[2]/255, t[3]/255, (t[4] or 255)/255)
end
local function nvgCA(t, a)
    return nvgRGBAf(t[1]/255, t[2]/255, t[3]/255, a)
end
M.nvgC  = nvgC
M.nvgCA = nvgCA

-- ============================================================
-- SurfacePanel  clip右上角24px + 6px硬阴影 + 2px描边
-- ============================================================
local SurfacePanel = UI.Widget:Extend("SurfacePanel")
M.SurfacePanel = SurfacePanel

function SurfacePanel:Init(props)
    props = props or {}
    self.fillC_   = props.fillC   or C.PAPER
    self.strokeC_ = props.strokeC or C.GRAPHITE
    self.cut_     = props.cut     or 24
    self.shadow_  = props.shadow  ~= false
    self.headerH_ = props.headerH or 0
    props.fillC=nil; props.strokeC=nil; props.cut=nil
    props.shadow=nil; props.headerH=nil
    UI.Widget.Init(self, props)
end

function SurfacePanel:DrawPoly(nvg, x, y, w, h, cut)
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x,       y)
    nvgLineTo(nvg, x+w-cut, y)
    nvgLineTo(nvg, x+w,     y+cut)
    nvgLineTo(nvg, x+w,     y+h)
    nvgLineTo(nvg, x,       y+h)
    nvgClosePath(nvg)
end

function SurfacePanel:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h,cut = l.x,l.y,l.w,l.h,self.cut_

    if self.shadow_ then
        self:DrawPoly(nvg, x+6, y+6, w, h, cut)
        nvgFillColor(nvg, nvgCA(C.SHADOW_H, 0.25)); nvgFill(nvg)
    end

    self:DrawPoly(nvg, x, y, w, h, cut)
    nvgFillColor(nvg, nvgC(self.fillC_)); nvgFill(nvg)

    if self.headerH_ and self.headerH_ > 0 then
        local hh = self.headerH_
        local g = nvgLinearGradient(nvg, x, y, x+w, y+hh,
            nvgCA(C.HEADER_BG,1), nvgCA(C.HEADER_B2,1))
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, x,       y)
        nvgLineTo(nvg, x+w-cut, y)
        nvgLineTo(nvg, x+w,     y+cut)
        nvgLineTo(nvg, x+w,     y+hh)
        nvgLineTo(nvg, x,       y+hh)
        nvgClosePath(nvg)
        nvgFillPaint(nvg, g); nvgFill(nvg)

        local step = 18
        for dy = 0, hh, step do
            for dx = 0, w, step do
                nvgBeginPath(nvg)
                nvgCircle(nvg, x+dx, y+dy, 1.1)
                nvgFillColor(nvg, nvgRGBAf(0.58,0.69,0.79,0.42))
                nvgFill(nvg)
            end
        end

        nvgBeginPath(nvg)
        nvgRect(nvg, x, y+hh-4, w, 4)
        nvgFillColor(nvg, nvgC(C.THEME_S)); nvgFill(nvg)
    end

    self:DrawPoly(nvg, x, y, w, h, cut)
    nvgStrokeColor(nvg, nvgC(self.strokeC_))
    nvgStrokeWidth(nvg, 2); nvgStroke(nvg)
end

-- ============================================================
-- SkewBtn  skewX(-10deg) 平行四边形
-- ============================================================
local SkewBtn = UI.Widget:Extend("SkewBtn")
M.SkewBtn = SkewBtn

function SkewBtn:Init(props)
    props = props or {}
    self.label_    = props.label    or ""
    self.fs_       = props.fontSize or 14
    self.bgC_      = props.bgC      or C.PAPER
    self.fgC_      = props.fgC      or C.GRAPHITE
    self.bdC_      = props.bdC      or C.GRAPHITE
    self.outlined_ = props.outlined or false
    self.active_   = props.active   or false
    props.label=nil; props.fontSize=nil; props.bgC=nil
    props.fgC=nil; props.bdC=nil; props.outlined=nil; props.active=nil
    UI.Widget.Init(self, props)
end

function SkewBtn:SetActive(on, bgC, fgC)
    self.active_ = on
    if bgC then self.bgC_ = bgC end
    if fgC then self.fgC_ = fgC end
    self:Invalidate()
end

function SkewBtn:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h
    local sk = h * 0.18

    -- 硬阴影 2px
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x+sk+2,y+2); nvgLineTo(nvg, x+w+2,y+2)
    nvgLineTo(nvg, x+w-sk+2,y+h+2); nvgLineTo(nvg, x+2,y+h+2)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBAf(0.11,0.17,0.22,0.20)); nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x+sk,y); nvgLineTo(nvg, x+w,y)
    nvgLineTo(nvg, x+w-sk,y+h); nvgLineTo(nvg, x,y+h)
    nvgClosePath(nvg)
    if self.outlined_ then
        nvgFillColor(nvg, nvgRGBAf(0,0,0,0)); nvgFill(nvg)
    else
        nvgFillColor(nvg, nvgC(self.bgC_)); nvgFill(nvg)
    end
    nvgStrokeColor(nvg, nvgC(self.bdC_))
    nvgStrokeWidth(nvg, 2); nvgStroke(nvg)

    nvgFontFace(nvg, UI.Theme.FontFace("sans","bold"))
    nvgFontSize(nvg, UI.Theme.FontSize(self.fs_))
    nvgTextAlign(nvg, 2|16)
    nvgFillColor(nvg, nvgC(self.fgC_))
    nvgText(nvg, x+w/2, y+h/2, self.label_)
end

-- ============================================================
-- TagItem  skewX(-15deg) 渐变填充
-- ============================================================
local TagItem = UI.Widget:Extend("TagItem")
M.TagItem = TagItem

function TagItem:Init(props)
    props = props or {}
    self.label_ = props.label    or ""
    self.fs_    = props.fontSize or 15
    self.c1_    = props.c1       or C.THEME_S
    self.c2_    = props.c2       or C.THEME_S2
    props.label=nil; props.fontSize=nil; props.c1=nil; props.c2=nil
    UI.Widget.Init(self, props)
end

function TagItem:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h
    local sk = h * 0.27

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x+sk+3,y+3); nvgLineTo(nvg, x+w+3,y+3)
    nvgLineTo(nvg, x+w-sk+3,y+h+3); nvgLineTo(nvg, x+3,y+h+3)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBAf(0.06,0.09,0.13,0.70)); nvgFill(nvg)

    local g = nvgLinearGradient(nvg, x, y+h, x+w, y,
        nvgCA(self.c1_,0.80), nvgCA(self.c2_,0.72))
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x+sk,y); nvgLineTo(nvg, x+w,y)
    nvgLineTo(nvg, x+w-sk,y+h); nvgLineTo(nvg, x,y+h)
    nvgClosePath(nvg)
    nvgFillPaint(nvg, g); nvgFill(nvg)
    nvgStrokeColor(nvg, nvgRGBAf(0.075,0.13,0.19,1))
    nvgStrokeWidth(nvg, 2); nvgStroke(nvg)

    nvgFontFace(nvg, UI.Theme.FontFace("barlow","bold"))
    nvgFontSize(nvg, UI.Theme.FontSize(self.fs_))
    nvgTextAlign(nvg, 2|16)
    nvgFillColor(nvg, nvgC(C.PAPER))
    nvgText(nvg, x+w/2+1, y+h/2, self.label_)
end

-- ============================================================
-- StatBar  skewX(-15deg) + 斜纹填充
-- ============================================================
local StatBar = UI.Widget:Extend("StatBar")
M.StatBar = StatBar

function StatBar:Init(props)
    props = props or {}
    self.value_ = props.value or 0
    self.maxV_  = props.maxV  or 300
    self.barC_  = props.barC  or C.THEME_S
    props.value=nil; props.maxV=nil; props.barC=nil
    UI.Widget.Init(self, props)
end

function StatBar:SetValue(v)
    self.value_ = v
    self:Invalidate()
end

function StatBar:DrawSkewRect(nvg, x, y, w, h)
    local sk = h * 0.27
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x+sk,y); nvgLineTo(nvg, x+w,y)
    nvgLineTo(nvg, x+w-sk,y+h); nvgLineTo(nvg, x,y+h)
    nvgClosePath(nvg)
end

function StatBar:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x,y,w,h = l.x,l.y,l.w,l.h

    self:DrawSkewRect(nvg, x, y, w, h)
    nvgFillColor(nvg, nvgC(C.TRACK_C)); nvgFill(nvg)
    nvgStrokeColor(nvg, nvgC(C.GRAPHITE)); nvgStrokeWidth(nvg,2); nvgStroke(nvg)

    local ratio = math.min(self.value_/self.maxV_, 1)
    local fw    = math.max(w * ratio, h*0.27*2+4)
    local c1    = self.barC_
    local c2    = { math.floor(c1[1]*0.7+255*0.3), math.floor(c1[2]*0.7+255*0.3),
                    math.floor(c1[3]*0.7+255*0.3), 255 }
    local gf = nvgLinearGradient(nvg, x, y, x, y+h, nvgCA(c1,1), nvgCA(c2,1))
    self:DrawSkewRect(nvg, x, y, fw, h)
    nvgFillPaint(nvg, gf); nvgFill(nvg)

    local stripe = 8
    for sx = x-h, x+fw, stripe*2 do
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, sx,      y+h); nvgLineTo(nvg, sx+stripe,y+h)
        nvgLineTo(nvg, sx+stripe+h,y); nvgLineTo(nvg, sx+h,    y)
        nvgClosePath(nvg)
        nvgFillColor(nvg, nvgRGBAf(1,1,1,0.18)); nvgFill(nvg)
    end
end

return M
