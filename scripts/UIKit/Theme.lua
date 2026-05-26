-- UIKit/Theme.lua
-- HotSlide 视觉主题 — 设计 Token
--
-- 用法：
--   local Theme = require("scripts/UIKit/Theme")
--
--   -- 直接使用颜色
--   nvgFillColor(vg, nvgRGBA(table.unpack(Theme.color.accent)))
--
--   -- 获取 rank 对应颜色
--   Theme.rankColor("S")  --> {255, 226, 58, 255}
--
--   -- 获取 stat bar 配色（索引 1~4 对应四条进度条）
--   Theme.statBarColor(2) --> { 40, 185, 255, 255}  蓝色

local M = {}

-- ============================================================
-- 基础色板
-- ============================================================
M.color = {
    -- 背景层
    pageBg      = {  13,  20,  32, 255 },   -- #0d1420  最深背景
    cardBg      = {  17,  27,  46, 255 },   -- #111b2e  卡片背景
    headerBg    = {  24,  37,  53, 255 },   -- #182535  区块头部
    headerBg2   = {  30,  44,  62, 255 },   -- #1e2c3e  头部渐变终点

    -- 文字
    textPrimary = { 255, 255, 255, 255 },   -- 主文字（白）
    textMuted   = {  68,  88, 110, 255 },   -- 次要文字（蓝灰）
    textMuted2  = {  95, 122, 150, 255 },   -- 更浅的辅助文字
    textInk     = {  26,  40,  56, 255 },   -- 深色文字（用于亮色背景）

    -- 强调色
    accent      = { 255, 226,  58, 255 },   -- #ffe23a  金黄主强调
    accentBlue  = {  40, 185, 255, 255 },   -- #28b9ff  蓝色强调
    accentGreen = { 110, 234, 121, 255 },   -- #6eea79  绿色强调

    -- 轨道 / 分割线
    trackBg     = {  30,  44,  62, 128 },   -- 进度条轨道（半透明）
    divider     = {  40,  58,  80, 180 },   -- 分割线

    -- 阴影
    shadow      = {  29,  42,  56,  64 },   -- 卡片阴影（低不透明度）
}

-- ============================================================
-- Rank 品阶颜色（S/A/B/C）
-- ============================================================
local RANK_COLORS = {
    S = { 255, 226,  58, 255 },   -- 金
    A = { 201,  91, 255, 255 },   -- 紫
    B = { 255, 174,  42, 255 },   -- 橙
    C = {  34, 184, 255, 255 },   -- 蓝
}

--- 获取 rank 对应颜色，未知 rank 返回白色
---@param rank string  "S" | "A" | "B" | "C"
---@return number[]
function M.rankColor(rank)
    return RANK_COLORS[rank] or { 255, 255, 255, 255 }
end

-- ============================================================
-- Stat Bar 进度条配色（四条主属性条）
-- ============================================================
local STAT_BAR_COLORS = {
    { 255, 226,  58, 255 },   -- 1 起步    金黄
    {  40, 185, 255, 255 },   -- 2 加速度  蓝
    { 110, 234, 121, 255 },   -- 3 最高时速 绿
    { 255, 226,  58, 255 },   -- 4 操控    金黄
}

--- 获取第 idx 条 stat bar 的颜色（idx 从 1 开始）
---@param idx integer
---@return number[]
function M.statBarColor(idx)
    return STAT_BAR_COLORS[idx] or M.color.accent
end

-- ============================================================
-- 字体
-- ============================================================
M.font = {
    -- 数值专用（Barlow Condensed）
    number  = "Fonts/BarlowCondensed-Bold.ttf",
    numberM = "Fonts/BarlowCondensed-Medium.ttf",
    -- 英文标签（Teko）
    label   = "Fonts/Teko-Regular.ttf",
    labelB  = "Fonts/Teko-SemiBold.ttf",
    -- 中文正文（MiSans）
    body    = "Fonts/MiSans-Regular.ttf",
    bodyB   = "Fonts/MiSans-Semibold.ttf",
}

-- ============================================================
-- 字号基准
-- ============================================================
M.fontSize = {
    heroNumber  = 48,   -- 大数值（起步 154、加速度 190）
    sectionTitle = 22,  -- 区块标题（性能评估、构筑调校）
    cardLabel   = 13,   -- 卡片标签（PERFORMANCE）
    body        = 14,   -- 正文
    small       = 12,   -- 次要信息
    tiny        = 10,   -- 最小标签
}

-- ============================================================
-- 圆角
-- ============================================================
M.radius = {
    card    = 10,   -- 卡片
    tag     = 4,    -- 标签胶囊
    button  = 6,    -- 按钮
    bar     = 3,    -- 进度条
}

-- ============================================================
-- 间距基准
-- ============================================================
M.spacing = {
    pagePad  = 16,   -- 页面左右内边距
    cardPad  = 14,   -- 卡片内边距
    sectionGap = 10, -- 区块间距
    itemGap  = 8,    -- 列表项间距
}

-- ============================================================
-- 点阵纹理参数（DrawDotGrid 用）
-- ============================================================
M.dotGrid = {
    dotR    = 1.0,                      -- 点半径
    gap     = 18,                       -- 点间距
    color   = { 255, 255, 255, 12 },    -- 点颜色（极低透明度白）
}

-- ============================================================
-- AnimModal 预设（可直接传给 AnimModal.new）
-- ============================================================
M.modalPreset = {
    openOverlayT  = "opacity 0.22s easeOut",
    openCardT     = "scale 0.30s easeOutBack, translateY 0.28s easeOut",
    closeOverlayT = "opacity 0.22s easeOut",
    closeCardT    = "scale 0.20s easeIn, translateY 0.20s easeIn",
    closeDelay    = 0.25,
    cardInitScale = 0.88,
    cardInitY     = 14,
}

-- ============================================================
-- StaggerReveal 预设
-- ============================================================
M.staggerPreset = {
    startDelay = 0.08,
    interval   = 0.10,
    initY      = 28,
    transition = "opacity 0.40s easeOut, translateY 0.42s easeOutBack",
}

-- ============================================================
-- SpringButton 预设
-- ============================================================
M.springPreset = {
    pressScale   = 0.88,
    pressEasing  = "scale 0.10s easeIn",
    bounceEasing = "scale 0.30s easeOutBack",
}

return M
