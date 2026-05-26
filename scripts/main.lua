-- main.lua  入口文件  HotSlide 星魅详情页

local UI        = require("urhox-libs/UI")
local TopBar    = require("scripts/sections/topbar")
local Showcase  = require("scripts/sections/showcase")
local Skins     = require("scripts/sections/skins")
local Perf      = require("scripts/sections/performance")
local Tuning    = require("scripts/sections/tuning")
local Traits    = require("scripts/sections/traits")
local PartsM    = require("scripts/sections/parts_modal")
local State     = require("scripts/state")

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
                normal    = "Fonts/Teko-Regular.ttf",
                semibold  = "Fonts/Teko-SemiBold.ttf",
                bold      = "Fonts/Teko-Bold.ttf",
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
        pointerEvents="none",   -- 默认不拦截点击
    }
    ---@type any
    local currentModal = nil

    local function CloseModal()
        if currentModal then
            overlayLayer:RemoveChild(currentModal)
            currentModal = nil
            overlayLayer:SetProp("pointerEvents", "none")
        end
    end

    local function OpenPartsModal(slotKey)
        CloseModal()
        currentModal = PartsM.Build(slotKey, CloseModal, function(sk, part)
            State.Equip(sk, part)
        end)
        overlayLayer:AddChild(currentModal)
        overlayLayer:SetProp("pointerEvents", "auto")
    end

    -- ── 页面内容 ──────────────────────────────────────────────────────
    -- 注：零件槽位已嵌入 showcase 信息栏右侧（参考图1）
    --     点击槽位直接弹出 parts_modal

    local content = UI.Panel {
        width="100%", flexDirection="column", padding=8,
        backgroundColor={C.PAGE_BG[1],C.PAGE_BG[2],C.PAGE_BG[3],255},
    }
    content:AddChild(Showcase.Build({
        onSlotClick = OpenPartsModal,
    }))
    content:AddChild(Skins.Build())
    content:AddChild(Perf.Build())
    content:AddChild(Tuning.Build())
    content:AddChild(Traits.Build())
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
    print("[HotSlide] v7 零件配装 + 响应式性能卡加载完成")
end

function Stop()
    UI.Shutdown()
end
