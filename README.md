# HotSlide 绝尘漂移 · 星魅详情页

> 用 UrhoX 引擎 + Lua 复刻的赛车 wiki 车辆详情页，附带可复用的 **UIKit 动画组件库**。

---

## 预览

本项目实现了一套完整的竞速游戏 wiki 详情页，包含：

- 车辆展示 + 涂装切换
- 性能评估（综合评分动画滚动）
- 构筑调校（阶级/等级调节）
- 特性词条展示
- 零件装备弹窗（含完整动画）

### 视觉风格

深色深海配色 · 金色强调 · 折角卡片 · 点阵纹理底纹 · Barlow/Teko 数字字体

---

## UIKit 组件库

位于 `scripts/UIKit/`，四个通用动画组件，**与项目业务完全解耦**，可直接复制到任意 UrhoX 项目使用。

```
scripts/UIKit/
  AnimModal.lua      弹窗动画系统
  StaggerReveal.lua  错开入场动画
  SpringButton.lua   弹簧回弹按钮
  RollingNumber.lua  数字滚动计数器
  init.lua           统一入口
```

---

### AnimModal — 弹窗动画系统

遮罩层只做 `opacity` 淡入淡出，弹窗卡片单独做 `scale + translateY` 弹入弹出，两层分离，视觉干净。

```lua
local AnimModal = require("scripts/UIKit/AnimModal")

-- 初始化，传入宿主容器
local modal = AnimModal.new(overlayLayer)

-- 打开（overlay=全屏遮罩，card=弹窗卡片）
modal:Open(overlay, card)

-- 关闭（带动画，自动延迟移除节点）
modal:Close()

-- 判断是否有弹窗打开
modal:IsOpen()
```

**可配置参数：**

```lua
AnimModal.new(overlayLayer, {
    openOverlayT  = "opacity 0.22s easeOut",
    openCardT     = "scale 0.30s easeOutBack, translateY 0.28s easeOut",
    closeOverlayT = "opacity 0.22s easeOut",
    closeCardT    = "scale 0.20s easeIn, translateY 0.20s easeIn",
    closeDelay    = 0.25,    -- 动画结束后移除节点的延迟（秒）
    cardInitScale = 0.88,
    cardInitY     = 14,
})
```

---

### StaggerReveal — 错开入场动画

传入 Panel 数组，自动依次触发淡入 + 向上位移的入场动画。

```lua
local StaggerReveal = require("scripts/UIKit/StaggerReveal")

-- 最简用法
StaggerReveal({ card1, card2, card3, card4, card5 })

-- 自定义配置
StaggerReveal(cards, {
    startDelay = 0.08,   -- 首张触发延迟（秒）
    interval   = 0.10,   -- 相邻卡片间隔（秒）
    initY      = 28,     -- 初始向下偏移量（px）
    transition = "opacity 0.40s easeOut, translateY 0.42s easeOutBack",
})
```

---

### SpringButton — 弹簧回弹按钮

给任意 Widget 注入点击时的 scale 下压 → 弹回动画，无需修改原有类定义。

```lua
local SpringButton = require("scripts/UIKit/SpringButton")

-- 模式 A：包装已有 Widget（最常用）
SpringButton.wrap(myWidget, function()
    -- onClick 逻辑
end)

-- 模式 B：直接创建带弹簧效果的 UI.Button
local btn = SpringButton.new({
    text    = "确认",
    variant = "primary",
    onClick = function() ... end,
    -- 可选动画参数
    pressScale   = 0.88,
    pressEasing  = "scale 0.10s easeIn",
    bounceEasing = "scale 0.30s easeOutBack",
})
```

---

### RollingNumber — 数字滚动计数器

基于 `tween.lua` 驱动，适用于得分、金币、综合性能等任意数值的平滑过渡动画。

```lua
local RollingNumber = require("scripts/UIKit/RollingNumber")

-- 创建计数器
local counter = RollingNumber.new({
    initial  = 0,
    duration = 1.0,
    easing   = "outQuad",
    format   = function(v) return tostring(math.floor(v)) end,
})

-- 每帧驱动（在 Update 事件中）
SubscribeToEvent("Update", function(et, ed)
    counter:Update(ed["TimeStep"]:GetFloat())
end)

-- 设置目标值，触发滚动动画
counter:Set(594)

-- 立即跳到某值（不播动画）
counter:Jump(0)

-- 读取当前显示值（供 NanoVG 或 Label 使用）
counter:Get()   --> "312"
```

**典型场景：NanoVG 文字由闭包驱动，无需手动 Invalidate**

```lua
local perfCounter = RollingNumber.new({ initial = 0 })

-- NanoVG Render 里直接读值
nvgText(nvg, x, y, perfCounter:Get())

-- 数值变化时触发滚动
perfCounter:Set(State.TotalPerf())
```

---

## 项目结构

```
scripts/
  UIKit/                   通用动画组件库（可独立复用）
    AnimModal.lua
    StaggerReveal.lua
    SpringButton.lua
    RollingNumber.lua
    init.lua

  tween.lua                底层缓动引擎（kikito/tween.lua v2.1.1，UrhoX 适配版）

  main.lua                 页面入口，~80 行纯业务逻辑
  state.lua                响应式状态管理（零件换装 → 属性联动）
  constants.lua            颜色系统 + 所有数据
  helpers.lua              MakeCard / MakeCardHeader / SecTitle 等布局工厂
  widgets.lua              SurfacePanel / SkewBtn / StatBar 等 NanoVG 自定义控件

  sections/
    topbar.lua             顶部导航栏
    showcase.lua           车辆展示 + 槽位点击
    skins.lua              涂装切换
    performance.lua        性能评估卡片（使用 RollingNumber）
    tuning.lua             构筑调校（使用 SpringButton.wrap）
    traits.lua             特性词条
    parts_modal.lua        零件选择弹窗（返回 overlay, card 两个值）
    parts_quad.lua         2×N 零件卡片网格

assets/
  Fonts/                   BarlowCondensed / Teko / MiSans / NotoSansSC
  image/                   车辆图片 + UI 贴图
```

---

## 技术栈

| 层 | 技术 |
|----|------|
| 引擎 | [UrhoX](https://developer.xdrnd.cn/)（TapTap 星火编辑器） |
| 脚本 | Lua 5.4 |
| UI 布局 | urhox-libs/UI（Yoga Flexbox） |
| 自定义绘制 | NanoVG（矢量图形） |
| 动画过渡 | 内置 Transition 系统（CSS-like） |
| 缓动引擎 | [tween.lua](https://github.com/kikito/tween.lua) v2.1.1 |

---

## 使用 UIKit

将 `scripts/UIKit/` 目录和 `scripts/tween.lua` 复制到你的项目，即可按需引用：

```lua
-- 统一引入
local UIKit = require("scripts/UIKit")
UIKit.StaggerReveal(cards)
UIKit.SpringButton.wrap(btn, onClick)

-- 或按需单独引入
local AnimModal    = require("scripts/UIKit/AnimModal")
local RollingNumber = require("scripts/UIKit/RollingNumber")
```

---

## License

MIT
