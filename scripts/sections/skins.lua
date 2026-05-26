-- sections/skins.lua

local UI  = require("urhox-libs/UI")
local C   = require("scripts/constants")
local W   = require("scripts/widgets")
local H   = require("scripts/helpers")
local SC  = require("scripts/sections/showcase")

local M = {}

function M.Build()
    local selectedSkin = 1
    ---@type Panel[]
    local cardPanels = {}

    -- 水平滚动区域内的卡片列表
    local cardRow = UI.Panel {
        flexDirection="row", alignItems="flex-start",
        paddingHorizontal=4, gap=8,
    }

    for i, skin in ipairs(C.SKINS) do
        local idx = i
        local isActive = (i == 1)

        local card = UI.Panel {
            width=92, flexDirection="column",
            borderWidth=isActive and 2 or 1,
            borderColor=isActive
                and {C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255}
                or  {180,195,210,255},
            backgroundColor=C.PAPER,
            overflow="hidden",
            onClick=function()
                selectedSkin = idx
                -- 切换车图
                if SC.carSpritePanel then
                    SC.carSpritePanel:SetProp("backgroundImage", C.SKINS[idx].img)
                end
                -- 更新卡片高亮
                for j, cp in ipairs(cardPanels) do
                    local active = (j == idx)
                    cp:SetProp("borderWidth", active and 2 or 1)
                    cp:SetProp("borderColor", active
                        and {C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255}
                        or  {180,195,210,255})
                end
            end,
            children={
                -- 涂装图
                UI.Panel {
                    width="100%", height=70,
                    backgroundColor={C.BODY_BG[1],C.BODY_BG[2],C.BODY_BG[3],255},
                    backgroundImage=skin.img,
                    backgroundFit="contain",
                    backgroundPositionX="center",
                    backgroundPositionY="center",
                },
                -- 名称
                UI.Panel {
                    width="100%", paddingHorizontal=4, paddingTop=5, paddingBottom=6,
                    justifyContent="center", alignItems="center",
                    children={
                        UI.Label {
                            text=skin.nameCN, fontSize=11, fontWeight="bold",
                            fontColor={C.INK[1],C.INK[2],C.INK[3],255},
                            textAlign="center",
                            whiteSpace="normal",
                            flexShrink=1,
                        },
                    }
                },
            }
        }
        table.insert(cardPanels, card)
        cardRow:AddChild(card)
    end

    -- ◀ ▶ 滚动按钮（纯装饰，水平滚动由 ScrollView 负责）
    local function ArrowBtn(lbl)
        return W.SkewBtn:new({
            width=28, height=36,
            label=lbl, fontSize=14,
            bgC=C.GRAPHITE, fgC=C.PAPER, bdC=C.GRAPHITE,
        })
    end

    local skinScroll = UI.ScrollView {
        flex=1, height=148,
        scrollDirection="horizontal",
        children={ cardRow },
    }

    local skinRow = UI.Panel {
        width="100%", flexDirection="row",
        alignItems="center", gap=6,
        children={
            ArrowBtn("◀"),
            skinScroll,
            ArrowBtn("▶"),
        }
    }

    -- 标题行（SKINS / 涂装  外观图鉴）
    local titleRow = UI.Panel {
        width="100%", flexDirection="row",
        alignItems="center", marginBottom=10,
        children={
            UI.Label {
                text="SKINS / 涂装", fontSize=14, fontWeight="bold",
                fontColor={C.INK[1],C.INK[2],C.INK[3],255},
            },
            UI.Panel { flex=1 },
            W.SkewBtn:new({
                width=64, height=28,
                label="外观图鉴", fontSize=11,
                bgC=C.GRAPHITE, fgC=C.PAPER, bdC=C.GRAPHITE,
            }),
        }
    }

    return W.SurfacePanel:new({
        width="100%", padding=14, marginBottom=12,
        flexDirection="column",
        fillC=C.PAPER, strokeC=C.GRAPHITE,
        cut=24, shadow=true,
        children={
            titleRow,
            skinRow,
        }
    })
end

return M
