-- sections/performance.lua
-- 性能评估卡片：标准 SurfacePanel + MakeCardHeader + BodyBg 结构
-- 与 tuning.lua / traits.lua 统一风格
-- 响应式：注册 State.OnRefresh，零件换装后自动更新数值和进度条

local UI    = require("urhox-libs/UI")
local C     = require("scripts/constants")
local W     = require("scripts/widgets")
local H     = require("scripts/helpers")
local State = require("scripts/state")

local M = {}

-- ── BodyBg：浅底点阵背景（与 tuning.lua 同风格）──────────────────────
local PerfBodyBg = UI.Widget:Extend("PerfBodyBg_pf2")
function PerfBodyBg:Init(p) UI.Widget.Init(self, p) end
function PerfBodyBg:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local x, y, w, h = l.x, l.y, l.w, l.h
    -- 浅灰底
    nvgBeginPath(nvg); nvgRect(nvg, x, y, w, h)
    nvgFillColor(nvg, nvgRGBAf(244/255, 247/255, 250/255, 1)); nvgFill(nvg)
    -- 细点阵
    for dy = 8, h, 16 do
        for dx = 8, w, 16 do
            nvgBeginPath(nvg); nvgCircle(nvg, x+dx, y+dy, 1.0)
            nvgFillColor(nvg, nvgRGBAf(0.69, 0.76, 0.84, 0.35)); nvgFill(nvg)
        end
    end
end

-- ── 单个 stat-block（label + 大值 + StatBar）────────────────────────
-- 返回 { panel, valueLbl, bar } 以供响应式更新
local function MakeStatBlock(stat, initVal)
    local valueLbl = UI.Label {
        text = tostring(initVal),
        fontSize = 36, fontWeight = "bold", fontFamily = "teko",
        fontColor = { C.INK[1], C.INK[2], C.INK[3], 255 },
        marginBottom = 2,
    }
    local bar = W.StatBar:new({
        width = "100%", height = 10,
        value = initVal, maxV = 300, barC = stat.barC,
    })
    local panel = UI.Panel {
        flex = 1, flexDirection = "column",
        paddingHorizontal = 8, paddingBottom = 10,
        children = {
            UI.Label {
                text = stat.label,
                fontSize = 11, fontWeight = "bold",
                fontColor = { C.MUTED[1], C.MUTED[2], C.MUTED[3], 255 },
                marginBottom = 2,
            },
            valueLbl,
            bar,
        }
    }
    return { panel = panel, valueLbl = valueLbl, bar = bar, stat = stat }
end

-- ── 单个 sub-stat pill（label + 值）──────────────────────────────────
local function MakeSubPill(sub, initVal)
    local valLbl = UI.Label {
        text = tostring(initVal),
        fontSize = 20, fontWeight = "bold", fontFamily = "teko",
        fontColor = { C.INK[1], C.INK[2], C.INK[3], 255 },
    }
    local pill = UI.Panel {
        flex = 1, flexDirection = "column",
        alignItems = "center", paddingVertical = 8,
        children = {
            UI.Label {
                text = sub.label,
                fontSize = 10, fontWeight = "bold",
                fontColor = { C.MUTED2[1], C.MUTED2[2], C.MUTED2[3], 255 },
                marginBottom = 2,
            },
            valLbl,
        }
    }
    return { pill = pill, valLbl = valLbl, sub = sub }
end

function M.Build()
    -- ── 综合性能分（卡头右侧）──────────────────────────────────────
    local totalLbl = UI.Label {
        text = tostring(State.TotalPerf()),
        fontSize = 44, fontWeight = "bold", fontFamily = "teko",
        fontColor = { 255, 255, 255, 255 },
    }
    local scorePanel = UI.Panel {
        flexDirection = "column", alignItems = "center",
        justifyContent = "center",
        paddingHorizontal = 12, paddingBottom = 4,
        children = {
            UI.Label {
                text = "综合性能",
                fontSize = 10, fontWeight = "bold",
                fontColor = { 133, 161, 189, 255 },
            },
            totalLbl,
        }
    }

    local cardHead = H.MakeCardHeader({
        titleCN     = "性能评估",
        titleEN     = "PERFORMANCE",
        height      = 72,
        rightWidget = scorePanel,
    })

    -- ── 4 个 stat-block（2 列 × 2 行）────────────────────────────
    local statBlocks = {}
    for _, stat in ipairs(C.MAIN_STATS) do
        table.insert(statBlocks, MakeStatBlock(stat, State.MainStatValue(stat)))
    end

    -- 第一行：起步 + 加速度
    local row1 = UI.Panel {
        width = "100%", flexDirection = "row",
        marginBottom = 4,
        children = { statBlocks[1].panel, statBlocks[2].panel }
    }

    -- 分隔线（横向）
    local hline1 = UI.Panel {
        width = "100%", height = 1, marginBottom = 4,
        backgroundColor = { C.GRAPHITE[1], C.GRAPHITE[2], C.GRAPHITE[3], 18 },
    }

    -- 第二行：最高时速 + 操控
    local row2 = UI.Panel {
        width = "100%", flexDirection = "row",
        marginBottom = 4,
        children = { statBlocks[3].panel, statBlocks[4].panel }
    }

    -- ── sub-stats-row（5 个副属性 pill）──────────────────────────
    local subItems = {}
    for _, sub in ipairs(C.SUB_STATS) do
        table.insert(subItems, MakeSubPill(sub, State.SubStatValue(sub)))
    end

    local subRow = UI.Panel {
        width = "100%", flexDirection = "row",
        borderTopWidth = 1,
        borderColor = { C.GRAPHITE[1], C.GRAPHITE[2], C.GRAPHITE[3], 22 },
        marginTop = 4,
    }
    for _, si in ipairs(subItems) do
        subRow:AddChild(si.pill)
        -- 竖向分隔线（除最后一个）
        if si ~= subItems[#subItems] then
            subRow:AddChild(UI.Panel {
                width = 1, alignSelf = "stretch", marginVertical = 6,
                backgroundColor = { C.GRAPHITE[1], C.GRAPHITE[2], C.GRAPHITE[3], 18 },
            })
        end
    end

    -- ── 卡体（BodyBg 做 absolute 背景，内容层做 relative 前景）──
    local cardBody = PerfBodyBg:new({
        width = "100%",
        flexDirection = "column",
        padding = 8,
        paddingTop = 10,
        children = {
            row1, hline1, row2, subRow,
        }
    })

    -- ── 注册 State 刷新回调 ─────────────────────────────────────
    State.OnRefresh(function()
        -- 更新综合性能分
        totalLbl:SetProp("text", tostring(State.TotalPerf()))
        -- 更新 4 个主属性
        for _, sb in ipairs(statBlocks) do
            local v = State.MainStatValue(sb.stat)
            sb.valueLbl:SetProp("text", tostring(v))
            sb.bar:SetValue(v)
        end
        -- 更新 5 个副属性
        for _, si in ipairs(subItems) do
            si.valLbl:SetProp("text", tostring(State.SubStatValue(si.sub)))
        end
    end)

    -- ── 外层卡片（SurfacePanel）──────────────────────────────────
    return W.SurfacePanel:new({
        width = "100%", marginBottom = 12,
        flexDirection = "column",
        fillC = C.CARD_BG, strokeC = C.GRAPHITE,
        cut = 24, shadow = true, padding = 0, overflow = "hidden",
        children = { cardHead, cardBody }
    })
end

return M
