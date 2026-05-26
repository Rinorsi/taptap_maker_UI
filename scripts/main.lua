-- main.lua  入口文件  HotSlide 星魅详情页

local UI           = require("urhox-libs/UI")
local TopBar       = require("scripts/sections/topbar")
local Showcase     = require("scripts/sections/showcase")
local Skins        = require("scripts/sections/skins")
local Perf         = require("scripts/sections/performance")
local Tuning       = require("scripts/sections/tuning")
local Traits       = require("scripts/sections/traits")
local PartsM       = require("scripts/sections/parts_modal")
local State        = require("scripts/state")
local AnimModal    = require("scripts/UIKit/AnimModal")
local StaggerReveal = require("scripts/UIKit/StaggerReveal")

function Start()
    UI.Init({
        fonts = {
            { family = "sans",   weights = {
                normal = "Fonts/MiSans-Regular.ttf",
                bold   = "Fonts/NotoSansSC-Bold.ttf",
            }},
            { family = "barlow", weights = {
                normal = "Fonts/BarlowCondensed-Regular.ttf",
                bold   = "Fonts/BarlowCondensed-Bold.ttf",
                black  = "Fonts/BarlowCondensed-Black.ttf",
            }},
            { family = "teko",   weights = {
                normal   = "Fonts/Teko-Regular.ttf",
                semibold = "Fonts/Teko-SemiBold.ttf",
                bold     = "Fonts/Teko-Bold.ttf",
            }},
        },
        scale = UI.Scale.DEFAULT,
    })

    local C = require("scripts/constants")

    -- ── 弹窗容器（绝对定位，覆盖整个根节点）──────────────────────────
    ---@type Panel
    local overlayLayer = UI.Panel {
        width="100%", height="100%",
        position="absolute", top=0, left=0,
        pointerEvents="none",
    }

    -- ── 弹窗动画系统 ─────────────────────────────────────────────────
    local modal = AnimModal.new(overlayLayer)

    local function CloseModal()
        modal:Close()
    end

    local function OpenPartsModal(slotKey)
        local overlay, card = PartsM.Build(slotKey, CloseModal, function(sk, part)
            State.Equip(sk, part)
        end)
        modal:Open(overlay, card)
    end

    -- ── 构建各 section ────────────────────────────────────────────────
    local showcaseCard = Showcase.Build({ onSlotClick = OpenPartsModal })
    local skinsCard    = Skins.Build()
    local perfCard     = Perf.Build()
    local tuningCard   = Tuning.Build()
    local traitsCard   = Traits.Build()

    -- ── 错开入场动画 ──────────────────────────────────────────────────
    StaggerReveal({ showcaseCard, skinsCard, perfCard, tuningCard, traitsCard })

    -- ── 页面内容 ──────────────────────────────────────────────────────
    local cards = { showcaseCard, skinsCard, perfCard, tuningCard, traitsCard }
    local content = UI.Panel {
        width="100%", flexDirection="column", padding=8,
        backgroundColor={C.PAGE_BG[1],C.PAGE_BG[2],C.PAGE_BG[3],255},
    }
    for _, card in ipairs(cards) do
        content:AddChild(card)
    end
    content:AddChild(UI.Panel { height=40 })

    local scroll = UI.ScrollView {
        width="100%", flex=1,
        flexDirection="column",
        children={ content },
    }

    local root = UI.Panel {
        width="100%", height="100%",
        flexDirection="column",
        backgroundColor={C.PAGE_BG[1],C.PAGE_BG[2],C.PAGE_BG[3],255},
        children={
            TopBar.Build(),
            scroll,
            overlayLayer,
        }
    }

    UI.SetRoot(root)
    print("[HotSlide] v9 UIKit 架构加载完成")
end

function Stop()
    UI.Shutdown()
end
