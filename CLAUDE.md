# 项目状态 — HotSlide 绝尘漂移 · 赛车详情页

> 自动生成，勿手动编辑
> 最后更新：2026-05-26

---

## 当前状态

**项目**：UrhoX Lua Wiki 赛车详情页（GLAMOUR 星魅）
**阶段**：核心功能完成，UI 细节打磨中

---

## 恢复指令

```
1. 读 docs/memory/memory-index.md（完整上下文）
2. 自测：这个项目做什么？上次改了什么？下一步？
3. 简要告知用户记忆恢复状态，然后处理请求
```

---

## 上次完成

- `parts_modal.lua` Header 双行合并（PARTS INVENTORY + 选择装配的[槽名]，NanoVG 渲染，高度 80）
- `performance.lua` 重写为标准卡片模式
- `state.lua` 创建（响应式零件效果增量系统）
- `constants.lua` MetaXxx key 迁移 + 16 个零件 effects 补全

## 可能的下一任务

- 弹窗整体视觉优化（间距/颜色）
- showcase 3D 模型区域
- 响应式适配测试

---

## 避雷清单

- `Widget:Invalidate()` / `SetValue()` 不能在 `Build()` 阶段调用（C++ 未初始化）
- `UI.Widget:Extend("Name")` 必须在模块顶层，不能放工厂函数内
- `PART_SLOTS` 不能有重复字段（之前 `key2="ecu"` 是笔误）
- NanoVG 中文文本需用 `sans` 字体族（barlow 不含中文字形）
- `width="100%"` 需要父节点有明确宽度才生效
