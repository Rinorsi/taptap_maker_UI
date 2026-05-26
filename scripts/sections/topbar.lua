-- sections/topbar.lua
-- CSS 对照：.detail-topbar / .btn-back-top / .btn-drawer-top
-- 原始按钮无固定宽度，只有 padding:0 10px；顶栏两行布局（action行+状态行）

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")
local W  = require("scripts/widgets")

local M = {}

-- ============================================================
-- 顶栏背景色：color-mix(white 86%, card-theme 14%)
-- ≈ #fff 86% + #ffe23a 14%
-- ============================================================
local TB_BG   = {255, 252, 237, 255}
local TB_BD   = C.GRAPHITE

-- ============================================================
-- 顶栏按钮尺寸（fontSize=10 px，计算合适宽度以免文字溢出）
-- 中文字符约 10px，ASCII 约 6px，padding 各 10px，skew 补偿 6px
-- ============================================================
local BTN_H   = 30
local BTN_FS  = 10

local function BackBtn()
    return W.SkewBtn:new({
        width=112, height=BTN_H,
        label="◀ 返回上一页", fontSize=BTN_FS,
        bgC=C.PAPER, fgC=C.GRAPHITE, bdC=C.GRAPHITE,
    })
end

-- ============================================================
-- Build
-- ============================================================
function M.Build()
    -- 按钮行（仅保留返回按钮）
    local actionsRow = UI.Panel {
        width="100%",
        flexDirection="row",
        alignItems="center",
        flexWrap="wrap",
        gap=6,
        children={
            BackBtn(),
        }
    }

    local innerBar = UI.Panel {
        width="100%",
        flexDirection="column",
        paddingLeft=12, paddingRight=12,
        paddingTop=8, paddingBottom=8,
        backgroundColor={TB_BG[1],TB_BG[2],TB_BG[3],255},
        borderWidth=2,
        borderColor={TB_BD[1],TB_BD[2],TB_BD[3],255},
        children={
            actionsRow,
        }
    }

    return UI.Panel {
        width="100%",
        flexDirection="column",
        marginBottom=10,
        -- 硬阴影：用一个偏移的深色 Panel 在底下垫着
        children={ innerBar }
    }
end

return M
