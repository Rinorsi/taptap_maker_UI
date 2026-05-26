-- constants.lua  颜色系统 + 所有数据常量

local M = {}

-- ============================================================
-- 颜色（来自 CSS Variables）
-- ============================================================
M.PAGE_BG   = {245,248,252,255}
M.PAPER     = {255,255,255,255}
M.GRAPHITE  = { 29, 42, 56,255}
M.THEME_S   = {255,226, 58,255}
M.THEME_S2  = {110,234,121,255}
M.INK       = { 26, 40, 56,255}
M.MUTED     = { 68, 88,110,255}
M.MUTED2    = { 95,122,150,255}
M.HEADER_BG = { 24, 37, 53,255}
M.HEADER_B2 = { 30, 44, 62,255}
M.ACCENT_B  = { 40,185,255,255}
M.TRACK_C   = {229,233,240,255}
M.CARD_BG   = {244,247,250,255}
M.BODY_BG   = {245,248,252,255}
M.SHADOW_H  = { 29, 42, 56, 64}
-- tier 颜色（来自 Vue GRADE_COLORS）
M.COLOR_S   = {255,226, 58,255}   -- #ffe23a
M.COLOR_A   = {201, 91,255,255}   -- #c95bff
M.COLOR_B   = {255,174, 42,255}   -- #ffae2a
M.COLOR_C   = { 34,184,255,255}   -- #22b8ff

-- ============================================================
-- 涂装数据（仅 3 项，来自 real-rendered-assets.json）
-- ============================================================
M.SKINS = {
    { img="image/GLAMOUR.png",    nameCN="默认涂装", owned=true  },
    { img="image/GLAMOUR_sk2.png",nameCN="活力黄",   owned=false },
    { img="image/GLAMOUR_sk3.png",nameCN="竞速",     owned=false },
}

-- ============================================================
-- 性能数据（来自 real-rendered-text.txt）
-- 综合性能 594；S 阶数值
-- ============================================================
-- base = 调校值，bonus = tier S 加成，pct = 百分比字符串
-- key 与零件 effects 对应（MetaXxx 命名）
M.MAIN_STATS = {
    { key="MetaEarlyAcc",  label="起步",     base=130, bonus=24, pct="+22.64%", barC={255,226,58,255}  },
    { key="MetaMidAcc",    label="加速度",   base=151, bonus=39, pct="+34.82%", barC={ 40,185,255,255} },
    { key="MetaMaxSpeed",  label="最高时速", base=115, bonus=24, pct="+26.37%", barC={110,234,121,255} },
    { key="MetaHandling",  label="操控",     base=128, bonus=24, pct="+23.08%", barC={255,226,58,255}  },
}
M.PERF_TOTAL = 594   -- 综合性能

-- 副属性（sub-stat pills）
M.SUB_STATS = {
    { key="MetaBoostStrength", label="氮气强度", val=10 },
    { key="MetaBoostDuration", label="氮气时长", val=10 },
    { key="MetaDrift",         label="漂移",     val=30 },
    { key="MetaOffroad",       label="越野",     val=10 },
    { key="MetaGrip",          label="抓地",     val=10 },
}

-- ============================================================
-- 调校：阶级（仅 S/SS/SSS，来自 real-rendered-text.txt）
-- ============================================================
M.TIERS = {
    { label="S",   bg={255,226,58,255},  fg={ 29,42,56,255} },
    { label="SS",  bg={255,226,58,255},  fg={ 29,42,56,255} },
    { label="SSS", bg={255,226,58,255},  fg={ 29,42,56,255} },
}

-- ============================================================
-- 特性词条（来自 real-rendered-text.txt）
-- ============================================================
M.TRAITS = {
    {
        tierLabel="C", tierColor=M.COLOR_C,
        typeTag="基础特性", unlockDesc="解锁: C档",
        title="氮气触发",
        desc="当在漂移时，氮气触发",
        badge=nil,
    },
    {
        tierLabel="B", tierColor=M.COLOR_B,
        typeTag="基础特性", unlockDesc="解锁: B档",
        title="漂移+15",
        desc="漂移+15  加速度+24%",
        badge=nil,
    },
    {
        tierLabel="A", tierColor=M.COLOR_A,
        typeTag="基础特性", unlockDesc="解锁: A档",
        title="加速度+24%",
        desc="漂移大于等于32时，加速度+24%  操控+24%",
        badge="需求未达标，不计入面板",
    },
    {
        tierLabel="S", tierColor=M.COLOR_S,
        typeTag="基础特性", unlockDesc="解锁: S档",
        title="操控+24%",
        desc="当在漂移时，操控+24%",
        badge="局内生效，不计入面板",
    },
}

-- ============================================================
-- 零件系统（装备槽位 + 零件库存）
-- ============================================================
-- 槽位定义（4个）
M.PART_SLOTS = {
    { key="turbo",  label="涡轮",  labelEN="TURBO" },
    { key="ecu",    label="电控",  labelEN="ECU"   },
    { key="susp",   label="减震",  labelEN="SUSP." },
    { key="tyre",   label="轮胎",  labelEN="TYRE"  },
}

-- 零件库存（按槽位类型）
-- partType: "A型"(蓝/电子强化)/"B型"(绿/机械升级)/"C型"(粉/轻量改造)
-- effects: 装备后对 MetaXxx 属性的加成值（与 MAIN_STATS/SUB_STATS key 对应）
M.PARTS_LIBRARY = {
    turbo = {
        { name="三菱TD05涡轮",   rank="S", partType="A型", type="涡轮", desc="起步+18  加速+14",  owned=true,
          effects={ MetaEarlyAcc=18, MetaMidAcc=14 } },
        { name="博格华纳EFR",    rank="A", partType="B型", type="涡轮", desc="加速+10  最高速+8", owned=true,
          effects={ MetaMidAcc=10, MetaMaxSpeed=8 } },
        { name="HKS GT3 套件",   rank="B", partType="A型", type="涡轮", desc="起步+12  漂移+5",   owned=false,
          effects={ MetaEarlyAcc=12, MetaDrift=5 } },
        { name="标准涡轮 T2",    rank="C", partType="C型", type="涡轮", desc="起步+6",             owned=true,
          effects={ MetaEarlyAcc=6 } },
    },
    ecu = {
        { name="Link G4X ECU",   rank="S", partType="A型", type="电控", desc="加速+16  操控+20",  owned=true,
          effects={ MetaMidAcc=16, MetaHandling=20 } },
        { name="Motec M150",     rank="A", partType="A型", type="电控", desc="操控+12  漂移+8",   owned=false,
          effects={ MetaHandling=12, MetaDrift=8 } },
        { name="Haltech Elite",  rank="B", partType="B型", type="电控", desc="操控+8",             owned=true,
          effects={ MetaHandling=8 } },
        { name="OEM电控",        rank="C", partType="C型", type="电控", desc="操控+4",             owned=true,
          effects={ MetaHandling=4 } },
    },
    susp = {
        { name="Ohlins TTX36",   rank="S", partType="B型", type="减震", desc="操控+22  抓地+15",  owned=false,
          effects={ MetaHandling=22, MetaGrip=15 } },
        { name="KW V3 套件",     rank="A", partType="B型", type="减震", desc="操控+14  越野+10",  owned=true,
          effects={ MetaHandling=14, MetaOffroad=10 } },
        { name="Bilstein B8",    rank="B", partType="C型", type="减震", desc="抓地+8  越野+6",    owned=true,
          effects={ MetaGrip=8, MetaOffroad=6 } },
        { name="标准减震",       rank="C", partType="C型", type="减震", desc="抓地+4",             owned=true,
          effects={ MetaGrip=4 } },
    },
    tyre = {
        { name="普利司通RE-71RS", rank="S", partType="B型", type="轮胎", desc="抓地+20  操控+18",  owned=true,
          effects={ MetaGrip=20, MetaHandling=18 } },
        { name="邓禄普 Z3",      rank="A", partType="A型", type="轮胎", desc="抓地+12  漂移+6",   owned=true,
          effects={ MetaGrip=12, MetaDrift=6 } },
        { name="锦湖 RS-3",      rank="B", partType="C型", type="轮胎", desc="抓地+8",             owned=false,
          effects={ MetaGrip=8 } },
        { name="原厂轮胎",       rank="C", partType="C型", type="轮胎", desc="抓地+4",             owned=true,
          effects={ MetaGrip=4 } },
    },
}

-- 当前装备的零件（key=slotKey, val=零件名或nil）
M.EQUIPPED_PARTS = {
    turbo = "三菱TD05涡轮",
    ecu   = "Link G4X ECU",
    susp  = "KW V3 套件",
    tyre  = "普利司通RE-71RS",
}

-- 零件品阶颜色
M.RANK_COLORS = {
    S = {255, 226,  58, 255},   -- 金
    A = {201,  91, 255, 255},   -- 紫
    B = {255, 174,  42, 255},   -- 橙
    C = { 34, 184, 255, 255},   -- 蓝
}

-- ============================================================
-- 属性拆解 Drawer（来自 real-rendered-text.txt）
-- ============================================================
M.DRAWER_BASE = 468
M.DRAWER_ROWS = {
    { label="起步",     val=106 },
    { label="加速度",   val=112 },
    { label="最高时速", val= 91 },
    { label="操控",     val=104 },
    { label="漂移",     val= 15 },
    { label="抓地",     val= 10 },
    { label="越野",     val= 10 },
    { label="氮气时长", val= 10 },
}

return M
