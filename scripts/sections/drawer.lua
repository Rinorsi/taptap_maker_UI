-- sections/drawer.lua  属性拆解面板

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")
local W  = require("scripts/widgets")
local H  = require("scripts/helpers")

local M = {}

function M.Build()
    -- BASE 总览行
    local baseRow = UI.Panel {
        width="100%", height=48,
        flexDirection="row", alignItems="center",
        paddingHorizontal=14,
        backgroundColor={C.HEADER_BG[1],C.HEADER_BG[2],C.HEADER_BG[3],255},
        marginBottom=6,
        children={
            UI.Label {
                text="基础值  BASE", fontSize=12, fontWeight="bold",
                fontColor={138,161,186,255},
                flex=1,
            },
            UI.Label {
                text="+"..tostring(C.DRAWER_BASE), fontSize=22, fontWeight="bold",
                fontFamily="teko",
                fontColor={C.THEME_S[1],C.THEME_S[2],C.THEME_S[3],255},
                marginRight=8,
            },
            UI.Label {
                text="/ 0%", fontSize=12,
                fontFamily="teko",
                fontColor={138,161,186,255},
            },
        }
    }

    -- 明细行列表
    local detailRows = {}
    for i, r in ipairs(C.DRAWER_ROWS) do
        local bgC = (i % 2 == 0)
            and {C.CARD_BG[1],C.CARD_BG[2],C.CARD_BG[3],255}
            or  {C.PAPER[1],C.PAPER[2],C.PAPER[3],255}
        table.insert(detailRows, UI.Panel {
            width="100%", height=36,
            flexDirection="row", alignItems="center",
            paddingHorizontal=14,
            backgroundColor=bgC,
            children={
                UI.Label {
                    text=r.label, fontSize=13, fontWeight="bold",
                    fontColor={C.INK[1],C.INK[2],C.INK[3],255},
                    flex=1,
                },
                UI.Label {
                    text="+"..tostring(r.val),
                    fontSize=15, fontWeight="bold",
                    fontFamily="teko",
                    fontColor={C.ACCENT_B[1],C.ACCENT_B[2],C.ACCENT_B[3],255},
                },
            }
        })
    end

    -- 组装卡体
    local bodyChildren = { baseRow }
    for _, row in ipairs(detailRows) do
        table.insert(bodyChildren, row)
    end
    table.insert(bodyChildren, UI.Panel { height=8 })

    return W.SurfacePanel:new({
        width="100%", marginBottom=12,
        flexDirection="column",
        fillC=C.PAPER, strokeC=C.GRAPHITE,
        cut=24, shadow=true, padding=0, overflow="hidden",
        children={
            -- 卡头
            UI.Panel {
                width="100%", padding=16, paddingBottom=8,
                flexDirection="column",
                backgroundColor={C.PAPER[1],C.PAPER[2],C.PAPER[3],255},
                children={ H.SecTitle("属性拆解") }
            },
            -- 卡体
            UI.Panel {
                width="100%", flexDirection="column",
                children=bodyChildren,
            }
        }
    })
end

return M
