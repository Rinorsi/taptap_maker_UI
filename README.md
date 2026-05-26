# UIKit · UrhoX 动画组件库

> 轻量、零依赖的 UrhoX / Lua 通用动画组件库，基于引擎内置 Transition 系统 + tween.lua 构建。
> 附带完整业务示例：**HotSlide 绝尘漂移 · 车辆详情页**。

---

## 组件一览

| 组件 | 文件 | 用途 |
|------|------|------|
| `AnimModal` | `UIKit/AnimModal.lua` | 弹窗动画（遮罩淡入 + 卡片弹入分离） |
| `StaggerReveal` | `UIKit/StaggerReveal.lua` | 多卡片错开入场动画 |
| `SpringButton` | `UIKit/SpringButton.lua` | 按钮弹簧回弹效果 |
| `RollingNumber` | `UIKit/RollingNumber.lua` | 数字平滑滚动计数器 |

依赖：`tween.lua`（已附带，kikito/tween.lua v2.1.1，UrhoX Lua 5.4 适配版）

---

## 快速开始

将 `scripts/UIKit/` 和 `scripts/tween.lua` 复制到你的项目：

```
your-project/scripts/
  UIKit/
    AnimModal.lua
    StaggerReveal.lua
    SpringButton.lua
    RollingNumber.lua
    init.lua
  tween.lua
```

统一引入或按需单独引入：

```lua
-- 统一引入
local UIKit = require("scripts/UIKit")

-- 按需引入
local AnimModal     = require("scripts/UIKit/AnimModal")
local StaggerReveal = require("scripts/UIKit/StaggerReveal")
local SpringButton  = require("scripts/UIKit/SpringButton")
local RollingNumber = require("scripts/UIKit/RollingNumber")
```

---

## API 文档

### AnimModal — 弹窗动画系统

遮罩层仅做 `opacity` 淡入淡出，弹窗卡片单独做 `scale + translateY` 弹入弹出，两层分离，避免遮罩随卡片一起缩放的视觉问题。

```lua
-- 初始化，传入宿主容器（弹窗挂载到哪个层）
local modal = AnimModal.new(overlayLayer)

-- 打开弹窗
-- overlay = 全屏遮罩节点，card = 弹窗卡片节点（由业务代码创建）
modal:Open(overlay, card)

-- 关闭弹窗（带动画，自动延迟移除节点）
modal:Close()

-- 判断是否有弹窗在显示
modal:IsOpen()  --> boolean
```

**全部配置项（均可选）：**

```lua
AnimModal.new(overlayLayer, {
    openOverlayT  = "opacity 0.22s easeOut",
    openCardT     = "scale 0.30s easeOutBack, translateY 0.28s easeOut",
    closeOverlayT = "opacity 0.22s easeOut",
    closeCardT    = "scale 0.20s easeIn, translateY 0.20s easeIn",
    closeDelay    = 0.25,     -- 动画结束后移除节点的延迟（秒）
    cardInitScale = 0.88,     -- 弹入前卡片的初始缩放
    cardInitY     = 14,       -- 弹入前卡片的初始向下偏移（px）
})
```

---

### StaggerReveal — 错开入场动画

传入 Panel 数组，自动依次触发淡入 + 向上位移入场。适合仪表盘、卡片列表的首次出现动画。

```lua
-- 最简用法（默认参数）
StaggerReveal({ card1, card2, card3, card4 })

-- 自定义配置
StaggerReveal(cards, {
    startDelay = 0.08,   -- 第一张触发前的延迟（秒）
    interval   = 0.10,   -- 相邻卡片之间的间隔（秒）
    initY      = 28,     -- 初始向下偏移量（px，入场前的位置）
    transition = "opacity 0.40s easeOut, translateY 0.42s easeOutBack",
})
```

---

### SpringButton — 弹簧回弹按钮

给任意 Widget 注入点击时的 scale 下压 → 弹回动画，无需修改原有类定义。

```lua
-- 模式 A：包装已有 Widget（推荐，非侵入）
SpringButton.wrap(existingWidget, function()
    -- 点击回调
end)

-- 模式 B：直接创建带弹簧效果的新按钮
local btn = SpringButton.new({
    text    = "确认",
    variant = "primary",
    onClick = function() ... end,
    -- 可选：覆盖动画参数
    pressScale   = 0.88,
    pressEasing  = "scale 0.10s easeIn",
    bounceEasing = "scale 0.30s easeOutBack",
})
```

---

### RollingNumber — 数字滚动计数器

基于 `tween.lua` 驱动，适用于得分、金币、综合评分等数值的平滑过渡动画。

```lua
-- 创建计数器
local counter = RollingNumber.new({
    initial  = 0,
    duration = 1.0,
    easing   = "outQuad",
    format   = function(v) return tostring(math.floor(v)) end,  -- 可选，自定义格式
})

-- 每帧驱动（在 Update 事件中调用）
SubscribeToEvent("Update", function(et, ed)
    counter:Update(ed["TimeStep"]:GetFloat())
end)

-- 触发滚动到新值
counter:Set(594)

-- 立即跳到某值（不播动画）
counter:Jump(0)

-- 读取当前显示值（字符串，供 Label 或 NanoVG 使用）
counter:Get()   --> "312"

-- 读取当前原始浮点值
counter:Raw()   --> 312.47
```

**与 NanoVG 配合（闭包驱动，无需手动刷新）：**

```lua
local score = RollingNumber.new({ initial = 0 })

-- NanoVGRender 事件里直接读，每帧自动更新
function HandleNanoVGRender(et, ed)
    nvgBeginFrame(vg, w, h, 1.0)
    nvgText(vg, x, y, score:Get())
    nvgEndFrame(vg)
end

-- 数值变化时触发滚动
score:Set(newScore)
```

---

## 示例项目：HotSlide 绝尘漂移 · 车辆详情页

`scripts/` 目录中包含完整的业务示例，展示 UIKit 在真实 UI 项目中的用法：

```
scripts/
  UIKit/                   ← 组件库（本体，可直接复制复用）
    AnimModal.lua
    StaggerReveal.lua
    SpringButton.lua
    RollingNumber.lua
    init.lua

  tween.lua                ← 缓动引擎（UIKit 依赖，一并复制）

  main.lua                 ← 示例入口（~80 行，演示 AnimModal + StaggerReveal）
  state.lua                ← 响应式状态（零件换装 → 属性联动）
  constants.lua            ← 颜色系统 + 数据
  helpers.lua              ← 布局工厂（MakeCard / MakeCardHeader 等）
  widgets.lua              ← NanoVG 自定义控件（SurfacePanel / StatBar 等）

  sections/
    topbar.lua             ← 顶部导航栏
    showcase.lua           ← 车辆展示 + 槽位点击
    skins.lua              ← 涂装切换（演示 SpringButton.wrap）
    performance.lua        ← 性能评估（演示 RollingNumber）
    tuning.lua             ← 构筑调校（演示 SpringButton.wrap）
    traits.lua             ← 特性词条
    parts_modal.lua        ← 零件选择弹窗（演示 AnimModal，返回 overlay, card）
    parts_quad.lua         ← 2×N 零件卡片网格

assets/
  Fonts/                   ← BarlowCondensed / Teko / MiSans / NotoSansSC
  image/                   ← 车辆图片 + UI 贴图
```

### 示例视觉风格

深色深海配色 · 金色强调 · 折角卡片 · 点阵纹理底纹 · Barlow/Teko 数字字体

---

## 技术栈

| 层 | 技术 |
|----|------|
| 引擎 | UrhoX（TapTap 星火编辑器） |
| 脚本 | Lua 5.4 |
| UI 布局 | urhox-libs/UI（Yoga Flexbox） |
| 自定义绘制 | NanoVG（矢量图形） |
| 动画过渡 | 引擎内置 Transition 系统（CSS-like） |
| 缓动引擎 | tween.lua v2.1.1（kikito） |

---

## License

MIT
