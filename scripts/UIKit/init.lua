-- UIKit/init.lua
-- HotSlide UI 工具库统一入口
--
-- 用法：
--   local UIKit = require("scripts/UIKit")
--
--   UIKit.AnimModal    -- 弹窗动画系统
--   UIKit.StaggerReveal -- 错开入场动画
--   UIKit.SpringButton  -- 弹簧回弹按钮
--   UIKit.RollingNumber -- 数字滚动计数器
--
-- 也可以按需单独引用：
--   local AnimModal = require("scripts/UIKit/AnimModal")

local M = {}

M.AnimModal     = require("scripts/UIKit/AnimModal")
M.StaggerReveal = require("scripts/UIKit/StaggerReveal")
M.SpringButton  = require("scripts/UIKit/SpringButton")
M.RollingNumber = require("scripts/UIKit/RollingNumber")
M.Theme         = require("scripts/UIKit/Theme")

return M
