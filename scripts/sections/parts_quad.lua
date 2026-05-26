-- sections/parts_quad.lua
-- 零件配装区：4 槽位 2×2 网格
-- 标准卡片结构：SurfacePanel + MakeCardHeader + BodyBg
-- 响应式：注册 State.OnRefresh，换装后立即刷新槽位显示

local UI    = require("urhox-libs/UI")
local C     = require("scripts/constants")
local W     = require("scripts/widgets")
local H     = require("scripts/helpers")
local State = require("scripts/state")

local M = {}

-- ── BodyBg：与 performance.lua 统一的浅底点阵背景 ─────────────────
local PartsBodyBg = UI.Widget:Extend("PartsBodyBg_pq")
function PartsBodyBg:Init(p) UI.Widget.Init(self, p) end
function PartsBodyBg:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x, y, w, h = l.x, l.y, l.w, l.h
    nvgBeginPath(nvg); nvgRect(nvg, x, y, w, h)
    nvgFillColor(nvg, nvgRGBAf(244/255, 247/255, 250/255, 1)); nvgFill(nvg)
    for dy = 8, h, 16 do
        for dx = 8, w, 16 do
            nvgBeginPath(nvg); nvgCircle(nvg, x+dx, y+dy, 1.0)
            nvgFillColor(nvg, nvgRGBAf(0.69, 0.76, 0.84, 0.35)); nvgFill(nvg)
        end
    end
end

-- ── 品阶徽章（NanoVG 圆形）────────────────────────────────────────
-- 必须定义在工厂函数外部，避免每次 Build 重复注册类名
local RankBadge = UI.Widget:Extend("RankBadge_pq")
function RankBadge:Init(p)
    p = p or {}
    self.rank_  = p.rank  or "C"
    self.rankC_ = p.rankC or { 34, 184, 255, 255 }
    p.rank = nil; p.rankC = nil
    UI.Widget.Init(self, p)
end
function RankBadge:SetRank(rank, rankC)
    self.rank_  = rank
    self.rankC_ = rankC or C.RANK_COLORS[rank] or { 150, 150, 150, 255 }
    self:Invalidate()
end
function RankBadge:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x, y, w, h = l.x, l.y, l.w, l.h
    local cx, cy = x + w/2, y + h/2
    local r = math.min(w, h)/2 - 1
    local rc = self.rankC_
    local g = nvgRadialGradient(nvg, cx, cy, 0, r,
        nvgRGBAf(math.min(rc[1]/255+0.20, 1), math.min(rc[2]/255+0.10, 1), rc[3]/255, 1),
        nvgRGBAf(rc[1]/255*0.65, rc[2]/255*0.65, rc[3]/255*0.65, 1))
    nvgBeginPath(nvg); nvgCircle(nvg, cx, cy, r)
    nvgFillPaint(nvg, g); nvgFill(nvg)
    nvgBeginPath(nvg); nvgCircle(nvg, cx, cy, r)
    nvgStrokeColor(nvg, nvgRGBAf(1, 1, 1, 0.30))
    nvgStrokeWidth(nvg, 1.5); nvgStroke(nvg)
    nvgFontFace(nvg, UI.Theme.FontFace("barlow", "bold"))
    nvgFontSize(nvg, UI.Theme.FontSize(14))
    nvgFillColor(nvg, nvgRGBAf(24/255, 37/255, 53/255, 1))
    nvgTextAlign(nvg, 2|16)
    nvgText(nvg, cx, cy, self.rank_)
end

-- ── 单个槽位（empty 或 equipped 两种状态）────────────────────────
-- 返回 { container, refresh } 以供 State.OnRefresh 调用
local function MakeSlotItem(slotDef, onSlotClick)
    -- 内容容器（AddChild/RemoveChild 切换状态内容）
    local contentBox = UI.Panel {
        width = "100%", flex = 1,
        flexDirection = "column",
        justifyContent = "center", alignItems = "center",
    }

    -- ── empty 状态 ───────────────────────────────────────────────
    local emptyView = UI.Panel {
        width = "100%", flex = 1,
        flexDirection = "column",
        justifyContent = "center", alignItems = "center",
        gap = 4,
        children = {
            UI.Label {
                text = "+", fontSize = 28, fontWeight = "bold",
                fontColor = { C.MUTED2[1], C.MUTED2[2], C.MUTED2[3], 160 },
            },
            UI.Label {
                text = slotDef.label,
                fontSize = 10, fontWeight = "bold",
                fontColor = { C.MUTED2[1], C.MUTED2[2], C.MUTED2[3], 200 },
            },
        }
    }

    -- ── equipped 状态 ────────────────────────────────────────────
    -- 用初始零件的 rank/rankC 直接初始化徽章，避免在挂载前调用 Invalidate
    local part0    = State.equippedParts[slotDef.key]
    local initRank = (part0 and part0.rank) or "C"
    local initRankC = (part0 and C.RANK_COLORS[part0.rank]) or C.RANK_COLORS["C"]

    local eqBadge = RankBadge:new({
        width = 34, height = 34,
        rank  = initRank,
        rankC = initRankC,
    })
    local eqNameLbl = UI.Label {
        text = (part0 and part0.name) or "",
        fontSize = 11, fontWeight = "bold",
        fontColor = { C.INK[1], C.INK[2], C.INK[3], 255 },
        textAlign = "center",
    }
    local eqDescLbl = UI.Label {
        text = (part0 and part0.desc) or "",
        fontSize = 9,
        fontColor = { C.MUTED2[1], C.MUTED2[2], C.MUTED2[3], 255 },
        textAlign = "center",
        whiteSpace = "normal",
    }
    local equippedView = UI.Panel {
        width = "100%", flex = 1,
        flexDirection = "column",
        justifyContent = "center", alignItems = "center",
        gap = 3, paddingHorizontal = 4,
        children = {
            eqBadge,
            eqNameLbl,
            eqDescLbl,
        }
    }

    -- ── 刷新函数（State.OnRefresh 中调用，此时 widget 已挂载）────
    -- Invalidate 在 widget 挂载后才可用，因此只在 refresh 中调用 SetRank
    local function refresh()
        local part = State.equippedParts[slotDef.key]
        contentBox:RemoveAllChildren()
        if part then
            local rc = C.RANK_COLORS[part.rank] or { 150, 150, 150, 255 }
            eqBadge:SetRank(part.rank, rc)
            eqNameLbl:SetProp("text", part.name)
            eqDescLbl:SetProp("text", part.desc or "")
            contentBox:AddChild(equippedView)
        else
            contentBox:AddChild(emptyView)
        end
    end

    -- ── 槽位外层容器 ─────────────────────────────────────────────
    local initBorderC = part0
        and (C.RANK_COLORS[part0.rank] or { C.GRAPHITE[1], C.GRAPHITE[2], C.GRAPHITE[3], 100 })
        or  { C.GRAPHITE[1], C.GRAPHITE[2], C.GRAPHITE[3], 40 }

    -- 初始内容（直接 AddChild，不调用 SetRank/Invalidate）
    if part0 then
        contentBox:AddChild(equippedView)
    else
        contentBox:AddChild(emptyView)
    end

    -- 槽位英文标签（顶部）
    local slotLabelPanel = UI.Panel {
        width = "100%",
        flexDirection = "row", alignItems = "center",
        paddingHorizontal = 8, paddingTop = 6, paddingBottom = 4,
        gap = 4,
        children = {
            UI.Panel {
                width = 3, height = 10,
                backgroundColor = { C.THEME_S[1], C.THEME_S[2], C.THEME_S[3], 255 },
            },
            UI.Label {
                text = slotDef.labelEN,
                fontSize = 9, fontWeight = "bold", fontFamily = "barlow",
                fontColor = { C.MUTED2[1], C.MUTED2[2], C.MUTED2[3], 255 },
            },
        }
    }

    local slotContainer = UI.Panel {
        flex = 1,
        flexDirection = "column",
        minHeight = 90,
        borderWidth = 1.5,
        borderColor = { initBorderC[1], initBorderC[2], initBorderC[3], initBorderC[4] or 80 },
        borderRadius = 4,
        backgroundColor = { 255, 255, 255, 180 },
        overflow = "hidden",
        onClick = function()
            if onSlotClick then onSlotClick(slotDef.key) end
        end,
        children = {
            slotLabelPanel,
            contentBox,
        }
    }

    return { container = slotContainer, refresh = refresh }
end

-- ============================================================
-- M.Build
-- opts: { onSlotClick = function(slotKey) end }
-- ============================================================
function M.Build(opts)
    opts = opts or {}
    local onSlotClick = opts.onSlotClick

    local slots = C.PART_SLOTS   -- 4 items: turbo/ecu/susp/tyre

    local slotItems = {}
    for _, slotDef in ipairs(slots) do
        table.insert(slotItems, MakeSlotItem(slotDef, onSlotClick))
    end

    -- 2×2 网格（两行，每行两个槽位）
    local row1 = UI.Panel {
        width = "100%", flexDirection = "row",
        gap = 8, marginBottom = 8,
        children = { slotItems[1].container, slotItems[2].container }
    }
    local row2 = UI.Panel {
        width = "100%", flexDirection = "row",
        gap = 8,
        children = { slotItems[3].container, slotItems[4].container }
    }

    local cardBody = PartsBodyBg:new({
        width = "100%",
        flexDirection = "column",
        padding = 12,
        children = { row1, row2 }
    })

    local cardHead = H.MakeCardHeader({
        titleCN = "零件配装",
        titleEN = "EQUIPPED PARTS",
        height  = 72,
    })

    -- 注册响应式刷新
    State.OnRefresh(function()
        for _, si in ipairs(slotItems) do
            si.refresh()
        end
    end)

    return W.SurfacePanel:new({
        width = "100%", marginBottom = 12,
        flexDirection = "column",
        fillC = C.CARD_BG, strokeC = C.GRAPHITE,
        cut = 24, shadow = true, padding = 0, overflow = "hidden",
        children = { cardHead, cardBody }
    })
end

return M
