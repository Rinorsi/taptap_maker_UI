-- sections/showcase.lua
-- 参考图1：橙色渐变图片区 + 深色底部信息栏
-- 右侧：2×2 深色零件槽（"+"号 + 标签）
-- 左侧：车名斜体金色 + 车型/阶级标签

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")
local W  = require("scripts/widgets")

local M = {}
M.carSpritePanel = nil

-- onSlotClick: function(slotKey) — 点击零件槽位时的回调（由 main.lua 注入）
function M.Build(opts)
    opts = opts or {}
    local onSlotClick = opts.onSlotClick or nil

    -- ── 图片区域 ──────────────────────────────────────────────────────
    M.carSpritePanel = UI.Panel {
        position="absolute", top=0, left=0,
        width="100%", height=230,
        backgroundImage=C.SKINS[1].img,
        backgroundFit="contain",
        backgroundPositionX="center",
        backgroundPositionY="center",
    }

    local mediaBg = UI.Panel {
        position="absolute", top=0, left=0,
        width="100%", height=230,
        backgroundImage="image/limited-skin-bg.png",
        backgroundFit="cover",
        backgroundPositionX="center",
        backgroundPositionY="center",
    }

    local tierBadge = UI.Panel {
        position="absolute", top=12, right=10,
        width=58, height=58,
        backgroundImage="image/Tier5.png",
        backgroundFit="contain",
        backgroundPositionX="center",
        backgroundPositionY="center",
    }

    local limitedLabel = UI.Panel {
        position="absolute", top=14, left=14,
        width=90, height=90,
        backgroundImage="image/limited-icon-cn.png",
        backgroundFit="contain",
        backgroundPositionX="left",
        backgroundPositionY="top",
    }

    local imageArea = UI.Panel {
        width="100%", height=230, overflow="hidden",
        children={ mediaBg, M.carSpritePanel, limitedLabel, tierBadge }
    }

    -- ── 深色信息栏（参考图1下半部）────────────────────────────────────
    local InfoBar = UI.Widget:Extend("InfoBar_sc")
    function InfoBar:Init(p) UI.Widget.Init(self, p) end
    function InfoBar:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x,y,w,h = l.x,l.y,l.w,l.h
        -- 深色渐变背景
        local g = nvgLinearGradient(nvg, x,y, x+w*0.6,y+h,
            nvgRGBAf(24/255,37/255,53/255,1),
            nvgRGBAf(37/255,55/255,78/255,1))
        nvgBeginPath(nvg); nvgRect(nvg,x,y,w,h)
        nvgFillPaint(nvg,g); nvgFill(nvg)
        -- 点阵纹理
        for dy=8,h,16 do
            for dx=8,w,16 do
                nvgBeginPath(nvg); nvgCircle(nvg,x+dx,y+dy,1.0)
                nvgFillColor(nvg,nvgRGBAf(1,1,1,0.18)); nvgFill(nvg)
            end
        end
        -- 顶部金色线条
        nvgBeginPath(nvg); nvgRect(nvg,x,y,w,3)
        nvgFillColor(nvg,nvgRGBAf(255/255,226/255,58/255,1)); nvgFill(nvg)
    end

    -- ── 零件槽（参考图1右侧：深色小方块 + "+" + 标签）────────────────
    local function PartSlotBtn(slotLabel, onClickFn)
        local SlotW = UI.Widget:Extend("PartSlot_"..slotLabel)
        function SlotW:Init(p) UI.Widget.Init(self, p) end
        function SlotW:Render(nvg)
            local l = self:GetAbsoluteLayout()
            local x,y,w,h = l.x,l.y,l.w,l.h
            -- 深色圆角方块背景
            nvgBeginPath(nvg); nvgRoundedRect(nvg,x,y,w,h,4)
            nvgFillColor(nvg,nvgRGBAf(0.08,0.14,0.22,0.85)); nvgFill(nvg)
            nvgStrokeColor(nvg,nvgRGBAf(1,1,1,0.25)); nvgStrokeWidth(nvg,1.5); nvgStroke(nvg)
            -- "+" 号
            local cx,cy = x+w/2, y+h/2-8
            local ps = 7
            nvgBeginPath(nvg)
            nvgMoveTo(nvg,cx-ps,cy); nvgLineTo(nvg,cx+ps,cy)
            nvgMoveTo(nvg,cx,cy-ps); nvgLineTo(nvg,cx,cy+ps)
            nvgStrokeColor(nvg,nvgRGBAf(1,1,1,0.75)); nvgStrokeWidth(nvg,2)
            nvgLineCap(nvg,2); nvgStroke(nvg)
            -- 标签文字
            nvgFontFace(nvg,UI.Theme.FontFace("sans","normal"))
            nvgFontSize(nvg,UI.Theme.FontSize(10))
            nvgFillColor(nvg,nvgRGBAf(0.65,0.76,0.88,1))
            nvgTextAlign(nvg,2|8)   -- center|top
            nvgText(nvg,x+w/2,y+h-18,slotLabel)
        end

        return SlotW:new({
            width=54, height=58,
            onClick=onClickFn,
        })
    end

    -- ── 左侧：车名 + 标签 ─────────────────────────────────────────────
    -- 车名使用 UI.Label（Yoga 原生文字测量），彻底避免 GetAbsoluteLayout 坐标偏移问题
    local carNameW = UI.Label {
        text = "星魅",
        fontSize = 36, fontWeight = "bold",
        fontColor = {255,226,58,255},
    }

    -- 车型/阶级标签：高度需能容纳实际字体大小 + 上下内边距
    local fs12 = UI.Theme.FontSize(12)
    local fs11 = UI.Theme.FontSize(11)
    local tagH  = math.ceil(math.max(fs12, fs11) + 10)  -- 字体 + 上下各5px内边距

    -- 车型标签（"轿跑" 黄色），阶级标签（"RANK S" 深色）
    local typeTag = W.SkewBtn:new({
        width=52, height=tagH, label="轿跑", fontSize=12,
        bgC=C.THEME_S, fgC=C.GRAPHITE, bdC=C.GRAPHITE,
    })
    local rankTag = W.SkewBtn:new({
        width=72, height=tagH, label="RANK S", fontSize=11,
        fontFamily="barlow",
        bgC=C.GRAPHITE, fgC=C.PAPER, bdC={255,255,255,60},
    })

    local leftCol = UI.Panel {
        flex=1, flexDirection="column", justifyContent="center",
        gap=10,
        children={
            carNameW,
            UI.Panel {
                flexDirection="row", gap=8,
                children={ typeTag, rankTag }
            }
        }
    }

    -- ── 右侧：2×2 零件槽 ──────────────────────────────────────────────
    local rightGrid = UI.Panel {
        flexDirection="column", gap=6, alignItems="flex-end",
        children={
            UI.Panel {
                flexDirection="row", gap=6,
                children={
                    PartSlotBtn("涡轮", onSlotClick and function() onSlotClick("turbo") end or nil),
                    PartSlotBtn("电控", onSlotClick and function() onSlotClick("ecu") end or nil),
                }
            },
            UI.Panel {
                flexDirection="row", gap=6,
                children={
                    PartSlotBtn("减震", onSlotClick and function() onSlotClick("susp") end or nil),
                    PartSlotBtn("轮胎", onSlotClick and function() onSlotClick("tyre") end or nil),
                }
            },
        }
    }

    -- InfoBar：不设固定高度，由 Yoga 根据内容自动计算（leftCol 和 rightGrid 中较高者）
    local infoBar = UI.Panel {
        width="100%",
        flexDirection="row",
        alignItems="center",
        paddingLeft=18, paddingRight=14, paddingVertical=12,
        gap=12,
        children={
            InfoBar:new({
                position="absolute", top=0, left=0,
                width="100%", height="100%",
            }),
            leftCol,
            rightGrid,
        }
    }

    -- SurfacePanel 改为 UI.Panel（Yoga 原生），SurfacePanel Widget 仅做 absolute 背景
    return UI.Panel {
        width="100%", marginBottom=12,
        flexDirection="column",
        overflow="hidden",
        children={
            W.SurfacePanel:new({
                position="absolute", top=0, left=0,
                width="100%", height="100%",
                fillC=C.PAPER, strokeC=C.GRAPHITE,
                cut=24, shadow=true,
            }),
            imageArea,
            infoBar,
        }
    }
end

return M
