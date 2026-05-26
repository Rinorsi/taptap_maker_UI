-- sections/parts_modal.lua
-- 参考图5：PARTS INVENTORY 弹窗
-- 根本修法：Modal 容器、行、标签全部改用 UI.Panel（Yoga 原生支持百分比宽度）
-- 只有圆形图标、关闭按钮、弹窗 Header 保留 NanoVG Widget

local UI = require("urhox-libs/UI")
local C  = require("scripts/constants")

local M = {}

-- 品阶 Tab 文字颜色
local TAB_RANK_TXT = {
    S = {255, 226,  58, 255},  -- 黄
    A = {201,  91, 255, 255},  -- 紫
    B = {255, 174,  42, 255},  -- 橙
    C = { 34, 184, 255, 255},  -- 青
}

-- partType 行背景颜色
local TYPE_ROW_BG = {
    ["A型"] = {210, 230, 255,  40},
    ["B型"] = {150, 230, 180,  40},
    ["C型"] = {255, 200, 210,  40},
}
-- partType 标签颜色（背景）
local TYPE_TAG_BG = {
    ["A型"] = { 40, 140, 255, 200},
    ["B型"] = { 40, 190, 110, 200},
    ["C型"] = {220,  80, 120, 200},
}

-- ============================================================
-- 构建弹窗
-- ============================================================
function M.Build(slotKey, onClose, onEquip)
    slotKey = slotKey or "turbo"

    local slotLabel = slotKey
    for _, s in ipairs(C.PART_SLOTS) do
        if s.key == slotKey then slotLabel = s.label; break end
    end

    local parts       = C.PARTS_LIBRARY[slotKey] or {}
    local equippedName = C.EQUIPPED_PARTS[slotKey]

    local filterRank = "全部"
    ---@type table[]
    local tabBtns = {}
    ---@type Panel
    local listPanel

    -- ── 品阶 Tab（NanoVG 绘制，仅此保留） ─────────────────────────
    local function MakeTabBtn(rk)
        local TabW = UI.Widget:Extend("PartTab2_" .. rk)
        function TabW:Init(p)
            p = p or {}
            self.active_ = p.initActive or false
            p.initActive = nil
            UI.Widget.Init(self, p)
        end
        function TabW:SetActive(v)
            self.active_ = v
            self:Invalidate()
        end
        function TabW:Render(nvg)
            local l = self:GetAbsoluteLayout()
            local x, y, w, h = l.x, l.y, l.w, l.h
            if self.active_ then
                nvgBeginPath(nvg); nvgRoundedRect(nvg, x, y, w, h, 4)
                nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 1)); nvgFill(nvg)
                nvgFontFace(nvg, UI.Theme.FontFace("sans", "bold"))
                nvgFontSize(nvg, UI.Theme.FontSize(13))
                nvgFillColor(nvg, nvgRGBAf(24/255, 37/255, 53/255, 1))
                nvgTextAlign(nvg, 2|16); nvgText(nvg, x+w/2, y+h/2, rk)
            else
                nvgBeginPath(nvg); nvgRoundedRect(nvg, x, y, w, h, 4)
                nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 0.10)); nvgFill(nvg)
                nvgStrokeColor(nvg, nvgRGBAf(1, 1, 1, 0.20))
                nvgStrokeWidth(nvg, 1); nvgStroke(nvg)
                local tc = TAB_RANK_TXT[rk] or {255, 255, 255, 255}
                nvgFontFace(nvg, UI.Theme.FontFace("barlow", "bold"))
                nvgFontSize(nvg, UI.Theme.FontSize(14))
                nvgFillColor(nvg, nvgRGBAf(tc[1]/255, tc[2]/255, tc[3]/255, 1))
                nvgTextAlign(nvg, 2|16); nvgText(nvg, x+w/2, y+h/2, rk)
            end
        end

        local bw = (rk == "全部") and 58 or 42
        ---@type any
        local btn
        btn = TabW:new({
            width = bw, height = 34,
            initActive = (rk == filterRank),
            onClick = function()
                filterRank = rk
                for _, tb in ipairs(tabBtns) do
                    tb:SetActive(tb == btn)
                end
                RefreshList()
            end,
        })
        table.insert(tabBtns, btn)
        return btn
    end

    -- ── 圆形图标（保留 NanoVG） ────────────────────────────────────
    local function MakeCircleIcon(rank, size)
        local rc = C.RANK_COLORS[rank] or {150, 150, 150, 255}
        local nm = "CIcon2_" .. rank .. (size or 36)
        local IconW = UI.Widget:Extend(nm)
        function IconW:Init(p) UI.Widget.Init(self, p) end
        function IconW:Render(nvg)
            local l = self:GetAbsoluteLayout()
            local x, y, w, h = l.x, l.y, l.w, l.h
            local cx, cy, r = x+w/2, y+h/2, math.min(w, h)/2 - 2
            local g = nvgRadialGradient(nvg, cx, cy, 0, r,
                nvgRGBAf(math.min(rc[1]/255+0.25, 1), math.min(rc[2]/255+0.15, 1), rc[3]/255, 1),
                nvgRGBAf(rc[1]/255*0.6, rc[2]/255*0.6, rc[3]/255*0.6, 1))
            nvgBeginPath(nvg); nvgCircle(nvg, cx, cy, r)
            nvgFillPaint(nvg, g); nvgFill(nvg)
            nvgBeginPath(nvg); nvgCircle(nvg, cx, cy, r)
            nvgStrokeColor(nvg, nvgRGBAf(1, 1, 1, 0.35))
            nvgStrokeWidth(nvg, 1.5); nvgStroke(nvg)
            nvgFontFace(nvg, UI.Theme.FontFace("barlow", "bold"))
            nvgFontSize(nvg, UI.Theme.FontSize(15))
            nvgFillColor(nvg, nvgRGBAf(24/255, 37/255, 53/255, 1))
            nvgTextAlign(nvg, 2|16); nvgText(nvg, cx, cy, rank)
        end
        return IconW:new({ width = size or 36, height = size or 36 })
    end

    -- ── 标签：UI.Panel + UI.Label（保证中文渲染） ─────────────────
    local function MakeTag(label, bgColor, fgColor)
        local bg = bgColor or {150, 150, 150, 200}
        local fg = fgColor or {255, 255, 255, 255}
        return UI.Panel {
            paddingLeft = 6, paddingRight = 6,
            paddingTop = 3, paddingBottom = 3,
            borderRadius = 3,
            backgroundColor = bg,
            justifyContent = "center",
            alignItems = "center",
            children = {
                UI.Label {
                    text = label,
                    fontSize = 10,
                    fontWeight = "bold",
                    fontColor = fg,
                }
            }
        }
    end

    -- ── 刷新列表 ──────────────────────────────────────────────────
    function RefreshList()
        if not listPanel then return end
        listPanel:RemoveAllChildren()

        for idx, p in ipairs(parts) do
            if filterRank ~= "全部" and p.rank ~= filterRank then
                -- skip
            else
                local rankC   = C.RANK_COLORS[p.rank] or {150, 150, 150, 255}
                local typeBg  = TYPE_ROW_BG[p.partType or "C型"] or {180, 180, 180, 30}
                local typeTbg = TYPE_TAG_BG[p.partType or "C型"] or {150, 150, 150, 200}
                local isEq    = (p.name == equippedName)

                -- 右侧内容（Panel + Label，不用 NanoVG Widget）
                local rightPanel
                if isEq then
                    rightPanel = MakeTag("装备中", {40, 190, 110, 220}, {255, 255, 255, 255})
                elseif not p.owned then
                    rightPanel = MakeTag("未获得", {140, 155, 175, 180}, {255, 255, 255, 255})
                else
                    -- 装备按钮：使用唯一名称的 Widget，避免类名冲突
                    local btnName = "EqBtn_pm_" .. tostring(idx)
                    local EqBtnW = UI.Widget:Extend(btnName)
                    function EqBtnW:Init(pp) UI.Widget.Init(self, pp) end
                    function EqBtnW:Render(nvg)
                        local l = self:GetAbsoluteLayout()
                        local x2, y2, w2, h2 = l.x, l.y, l.w, l.h
                        nvgBeginPath(nvg); nvgRoundedRect(nvg, x2, y2, w2, h2, 4)
                        nvgFillColor(nvg, nvgRGBAf(255/255, 226/255, 58/255, 1)); nvgFill(nvg)
                        nvgFontFace(nvg, UI.Theme.FontFace("sans", "bold"))
                        nvgFontSize(nvg, UI.Theme.FontSize(11))
                        nvgFillColor(nvg, nvgRGBAf(24/255, 37/255, 53/255, 1))
                        nvgTextAlign(nvg, 2|16); nvgText(nvg, x2+w2/2, y2+h2/2, "装备")
                    end
                    local pRef = p
                    rightPanel = EqBtnW:new({
                        width = 52, height = 28,
                        onClick = function()
                            equippedName = pRef.name
                            C.EQUIPPED_PARTS[slotKey] = pRef.name
                            RefreshList()
                            if onEquip then onEquip(slotKey, pRef) end
                        end,
                    })
                end

                -- 行主体：UI.Panel（Yoga 原生，百分比宽度有效）
                local rowMain = UI.Panel {
                    width = "100%",
                    flexDirection = "row",
                    alignItems = "center",
                    backgroundColor = typeBg,
                    children = {
                        -- 左侧品阶颜色竖条（4px）
                        UI.Panel {
                            width = 4,
                            alignSelf = "stretch",
                            backgroundColor = { rankC[1], rankC[2], rankC[3], 215 },
                        },
                        -- 主内容区
                        UI.Panel {
                            flex = 1,
                            flexShrink = 1,
                            flexDirection = "row",
                            alignItems = "center",
                            paddingLeft = 10,
                            paddingRight = 10,
                            paddingTop = 8,
                            paddingBottom = 8,
                            gap = 8,
                            children = {
                                MakeCircleIcon(p.rank, 38),
                                -- 中间：名称 + 标签行 + 描述
                                UI.Panel {
                                    flex = 1,
                                    flexShrink = 1,
                                    flexDirection = "column",
                                    gap = 3,
                                    children = {
                                        UI.Label {
                                            text = p.name,
                                            fontSize = 12,
                                            fontWeight = "bold",
                                            fontColor = {255, 255, 255, 255},
                                            flexShrink = 1,
                                        },
                                        UI.Panel {
                                            flexDirection = "row",
                                            gap = 4,
                                            alignItems = "center",
                                            children = {
                                                MakeTag(p.rank .. "阶", rankC, {24, 37, 53, 255}),
                                                MakeTag(p.partType or "C型", typeTbg, {255, 255, 255, 255}),
                                            }
                                        },
                                        UI.Label {
                                            text = p.desc,
                                            fontSize = 10,
                                            fontColor = {160, 185, 210, 255},
                                            flexShrink = 1,
                                        },
                                    }
                                },
                                -- 右侧状态/按钮（固定宽度，不被压缩）
                                UI.Panel {
                                    width = 72,
                                    flexShrink = 0,
                                    flexDirection = "column",
                                    alignItems = "flex-end",
                                    justifyContent = "center",
                                    children = { rightPanel },
                                }
                            }
                        },
                    }
                }

                -- 行 + 底部分隔线（UI.Panel）
                local rowWithDiv = UI.Panel {
                    width = "100%",
                    flexDirection = "column",
                    children = {
                        rowMain,
                        UI.Panel {
                            width = "100%",
                            height = 1,
                            backgroundColor = {255, 255, 255, 20},
                        },
                    }
                }

                listPanel:AddChild(rowWithDiv)
            end
        end
    end

    -- ── Tab 行 ────────────────────────────────────────────────────
    local RANK_TABS = { "全部", "S", "A", "B", "C" }
    local tabRow = UI.Panel {
        width = "100%",
        flexDirection = "row",
        gap = 6,
        marginBottom = 12,
    }
    for _, rk in ipairs(RANK_TABS) do
        tabRow:AddChild(MakeTabBtn(rk))
    end

    -- ── 列表 + ScrollView ─────────────────────────────────────────
    listPanel = UI.Panel { width = "100%", flexDirection = "column" }
    local scrollArea = UI.ScrollView {
        width = "100%",
        height = 360,
        flexDirection = "column",
        showScrollbar = false,
        children = { listPanel },
    }
    RefreshList()

    -- ── 关闭按钮（NanoVG 圆形） ───────────────────────────────────
    local CloseX = UI.Widget:Extend("CloseX_pm4")
    function CloseX:Init(p) UI.Widget.Init(self, p) end
    function CloseX:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x, y, w, h = l.x, l.y, l.w, l.h
        local cx, cy = x+w/2, y+h/2
        nvgBeginPath(nvg); nvgCircle(nvg, cx, cy, w/2-2)
        nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 0.15)); nvgFill(nvg)
        nvgStrokeColor(nvg, nvgRGBAf(1, 1, 1, 0.35))
        nvgStrokeWidth(nvg, 1); nvgStroke(nvg)
        local s = 6
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx-s, cy-s); nvgLineTo(nvg, cx+s, cy+s)
        nvgMoveTo(nvg, cx+s, cy-s); nvgLineTo(nvg, cx-s, cy+s)
        nvgStrokeColor(nvg, nvgRGBAf(1, 1, 1, 0.85))
        nvgStrokeWidth(nvg, 2); nvgLineCap(nvg, 2); nvgStroke(nvg)
    end
    local closeBtn = CloseX:new({
        width = 36, height = 36,
        onClick = function() if onClose then onClose() end end,
    })

    -- ── 弹窗 Header（NanoVG 绘制全部内容，高度 90 保证两行间距） ──
    local ModalHeadBg = UI.Widget:Extend("ModalHeadBg_pm4")
    function ModalHeadBg:Init(p)
        self.slotLabel_ = p.slotLabel or ""
        p.slotLabel = nil
        UI.Widget.Init(self, p)
    end
    function ModalHeadBg:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x, y, w, h = l.x, l.y, l.w, l.h
        local dpr = graphics:GetDPR()
        -- 深色背景
        nvgBeginPath(nvg); nvgRect(nvg, x, y, w, h)
        nvgFillColor(nvg, nvgRGBAf(24/255, 37/255, 53/255, 1)); nvgFill(nvg)
        -- 点阵装饰（步距随 DPR 缩放）
        local step = 14 * dpr
        for dy = 6*dpr, h, step do
            for dx = 6*dpr, w, step do
                nvgBeginPath(nvg); nvgCircle(nvg, x+dx, y+dy, 0.9*dpr)
                nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 0.12)); nvgFill(nvg)
            end
        end
        -- 底部金色线
        local lineH = 3 * dpr
        nvgBeginPath(nvg); nvgRect(nvg, x, y+h-lineH, w, lineH)
        nvgFillColor(nvg, nvgRGBAf(255/255, 226/255, 58/255, 1)); nvgFill(nvg)
        -- 第一行：PARTS INVENTORY（斜体，垂直居 33% 处）
        -- 用 h 的百分比定位，DPR 无关
        nvgSave(nvg)
        nvgTranslate(nvg, x + 20*dpr, y + h * 0.33)
        nvgSkewX(nvg, -0.20)
        nvgFontFace(nvg, UI.Theme.FontFace("barlow", "black"))
        nvgFontSize(nvg, UI.Theme.FontSize(20))
        nvgFillColor(nvg, nvgRGBAf(1, 1, 1, 1))
        nvgTextAlign(nvg, 1|8)   -- LEFT | MIDDLE
        nvgText(nvg, 0, 0, "PARTS INVENTORY")
        nvgRestore(nvg)
        -- 第二行：中文副标题（垂直居 72% 处）
        nvgFontFace(nvg, UI.Theme.FontFace("sans", "bold"))
        nvgFontSize(nvg, UI.Theme.FontSize(12))
        nvgFillColor(nvg, nvgRGBAf(255/255, 208/255, 58/255, 0.85))
        nvgTextAlign(nvg, 1|8)   -- LEFT | MIDDLE
        nvgText(nvg, x + 20*dpr, y + h * 0.63, "选择装配的  [ " .. self.slotLabel_ .. " ]")
    end

    local modalHead = UI.Panel {
        width = "100%",
        height = 90,
        children = {
            ModalHeadBg:new({
                position = "absolute", top = 0, left = 0,
                width = "100%", height = "100%",
                slotLabel = slotLabel,
            }),
            UI.Panel {
                position = "absolute", top = 0, right = 0,
                width = 50, height = 90,
                justifyContent = "center", alignItems = "center",
                children = { closeBtn },
            },
        }
    }

    -- ── 弹窗背景 Widget（absolute，仅绘制圆角深色卡片+金色边框） ──
    local ModalBgW = UI.Widget:Extend("ModalBg_pm4")
    function ModalBgW:Init(p) UI.Widget.Init(self, p) end
    function ModalBgW:Render(nvg)
        local l = self:GetAbsoluteLayout()
        local x, y, w, h = l.x, l.y, l.w, l.h
        nvgBeginPath(nvg); nvgRoundedRect(nvg, x, y, w, h, 8)
        nvgFillColor(nvg, nvgRGBAf(18/255, 28/255, 42/255, 0.97)); nvgFill(nvg)
        nvgBeginPath(nvg); nvgRoundedRect(nvg, x, y, w, h, 8)
        nvgStrokeColor(nvg, nvgRGBAf(255/255, 226/255, 58/255, 0.40))
        nvgStrokeWidth(nvg, 1.5); nvgStroke(nvg)
    end

    -- ── 弹窗主体：UI.Panel（Yoga 原生，"92%" 百分比宽度有效） ─────
    local modalContent = UI.Panel {
        width = "92%",
        flexDirection = "column",
        overflow = "hidden",
        children = {
            -- 背景绘制层（absolute，不参与 Yoga 布局流）
            ModalBgW:new({
                position = "absolute", top = 0, left = 0,
                width = "100%", height = "100%",
            }),
            modalHead,
            UI.Panel {
                width = "100%",
                padding = 18,
                paddingTop = 14,
                flexDirection = "column",
                children = {
                    tabRow,
                    scrollArea,
                }
            }
        }
    }

    -- ── 全屏半透明遮罩 ────────────────────────────────────────────
    local overlay = UI.Panel {
        width = "100%", height = "100%",
        position = "absolute", top = 0, left = 0,
        backgroundColor = {0, 0, 0, 160},
        justifyContent = "center",
        alignItems = "center",
        children = { modalContent },
    }

    return overlay, modalContent
end

-- BuildSlots 已废弃，保留空实现防止旧引用出错
function M.BuildSlots(onSlotClick)
    return UI.Panel { width = "100%", height = 0 }
end

return M
