# 记忆索引 — HotSlide 绝尘漂移 · 赛车详情页

> 项目：UrhoX Lua 实现的 HotSlide Wiki 赛车详情页（GLAMOUR 星魅）
> 最后更新：2026-05-26

---

## 项目概览

| 字段 | 值 |
|------|-----|
| 项目类型 | UrhoX Lua 游戏 UI（Wiki 赛车详情页） |
| 目标车辆 | GLAMOUR 星魅 |
| 入口文件 | `scripts/main.lua` |
| 参考原型 | Vue 实际渲染页（见 `docs/documents/` 目录的截图和 CSS） |

---

## 文件结构

```
scripts/
├── main.lua              # 入口，页面组装（ScrollView + 各 Section + Modal 逻辑）
├── constants.lua         # 全局常量（MAIN_STATS、SUB_STATS、PARTS_LIBRARY、PART_SLOTS、EQUIPPED_PARTS、RANK_COLORS）
├── state.lua             # 响应式状态模块（零件装备、效果增量计算、刷新回调）
├── helpers.lua           # 通用 Widget 辅助（MakeCardHeader、SecTitle、HSep、SmallBadge、MakeCheckIcon）
├── widgets.lua           # 自定义 Widget 组件库（StatBar、SurfacePanel 等）
├── drawer.lua            # 侧边抽屉（二级导航）
└── sections/
    ├── topbar.lua        # 顶部栏（车名、品阶、分享）
    ├── showcase.lua      # 车辆展示区（3D 模型 + 背景粒子）
    ├── performance.lua   # 性能评估卡片（标准卡片模式）
    ├── tuning.lua        # 调校参数卡片
    ├── traits.lua        # 车辆特性卡片
    ├── skins.lua         # 涂装展示卡片
    ├── parts_modal.lua   # 零件装配弹窗
    └── parts_quad.lua    # 零件 2x2 卡片（已创建但从页面移除，仅备用）
```

---

## 已完成工作（本 session 及上一 session）

### 上一 session（先前上下文）
- 建立页面骨架：topbar、showcase、traits、tuning、skins 卡片
- 建立 `helpers.lua`（MakeCardHeader、HSep 等）
- 建立 `widgets.lua`（StatBar、SurfacePanel）
- 建立 `parts_modal.lua` 初版（弹窗列表 + Tab 过滤 + 装备按钮）

### 本 session
1. **constants.lua 升级**
   - `MAIN_STATS` key 改为 `MetaXxx` 格式（MetaEarlyAcc / MetaMidAcc / MetaMaxSpeed / MetaHandling）
   - `SUB_STATS` 补充 `key` 字段（MetaBoostStrength / MetaBoostDuration / MetaDrift / MetaOffroad / MetaGrip）
   - `PARTS_LIBRARY` 全部 16 个零件补充 `effects` 表
   - `PART_SLOTS` 修复重复 `key2="ecu"` typo

2. **state.lua 创建**
   - 响应式单例：`equippedParts`、`initialEffects`、`ComputeEffects()`
   - `StatDelta(key)`、`TotalDelta()`、`TotalPerf()`、`MainStatValue(stat)`、`SubStatValue(sub)`
   - `OnRefresh(cb)`、`Refresh()`、`Equip(slotKey, part)`

3. **performance.lua 重写**
   - 移除自定义 PerfCard NanoVG Widget + "来源详细" 折叠区
   - 改为标准卡片模式（SurfacePanel + MakeCardHeader + PerfBodyBg 点阵背景）
   - 2×2 stat-block 网格（W.StatBar + 数值标签）
   - sub-stats 行（5 个徽章 + 分隔线）
   - `State.OnRefresh` 响应式更新

4. **parts_quad.lua 创建**（后从页面移除）
   - 2×2 零件槽卡片（已实现但用户要求不显示在页面，仅弹窗展示）
   - 关键 bugfix：`Widget:Invalidate()` 在 Build 阶段不可调用，必须在构造函数直接传入初始值

5. **parts_modal.lua 更新**
   - `onEquip` 回调签名改为 `(slotKey, partRef)` 传完整对象
   - **Header 双行合并**：
     - 移除独立 `subTitle` Panel
     - `ModalHeadBg` NanoVG Widget 接受 `slotLabel` 参数，渲染双行
     - 第一行：`PARTS INVENTORY`（白色斜体，y+26）
     - 第二行：`选择装配的 [ 槽名 ]`（金色，y+58）
     - Header 高度 64 → 80

6. **main.lua 更新**
   - 引入 State 模块
   - `OpenPartsModal` 回调改为 `State.Equip(sk, part)`
   - 移除 `PartsQuad.Build()` 调用

---

## 关键技术决策

### D1: Widget:Invalidate() 时序
**决策**：Widget 的 C++ 方法（Invalidate / SetValue 等）在 `Build()` 阶段（UI.SetRoot 前）不可用。必须：
- 构造函数 `new({rank=x, rankC=y})` 直接传初始值
- 只在 `State.OnRefresh()` 回调（post-mount）中调用这些方法

### D2: 标准卡片模式
**决策**：所有 Section 卡片统一使用 `W.SurfacePanel + H.MakeCardHeader + BodyBg` 模式（与 tuning/traits 一致），不做自定义 NanoVG Widget。

### D3: UI.Widget:Extend("Name") 位置
**决策**：必须在模块级别调用 `Extend`，不能在工厂函数内部每次调用（避免 metatable 重注册崩溃）。

### D4: 弹窗 Header 合并
**决策**：主标题（英文 NanoVG）和副标题（中文槽名）合并到同一个 `ModalHeadBg` Widget 中渲染，通过 `slotLabel_` 实例变量传参，消除两行文字在同一深色背景上无层次感的问题。

---

## 待办 / 下一步

- [ ] 弹窗整体视觉 polish（间距、颜色微调）
- [ ] showcase 区域 3D 模型展示完善
- [ ] 页面响应式测试（不同屏幕分辨率）
- [ ] 性能测试（零件切换后 State.Refresh 延迟）

---

## 已知坑

| 坑 | 描述 | 解决 |
|----|------|------|
| Invalidate nil | Widget C++ 方法在 Build 阶段为 nil | 构造函数传初始值，只在 post-mount 回调调用 |
| PART_SLOTS 重复 key | `key2="ecu"` 是笔误 | 已修复，删除重复字段 |
| Yoga 宽度百分比 | UI.Panel 嵌套时 "100%" 需要父级有明确宽度 | 使用 `width="100%"` + flexShrink=1 |
| UI.Widget:Extend 位置 | 工厂内部重复调用会崩溃 | 移到模块顶层 |
