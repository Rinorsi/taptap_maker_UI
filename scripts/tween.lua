-- tween.lua v2.1.1 - https://github.com/kikito/tween.lua
-- MIT license: Enrique García Cota, Yuichi Tateno, Emmanuel Oga
-- UrhoX adaptation: math.pow replaced with ^ operator

local tween = {}

-- ─── 内部工具 ────────────────────────────────────────────────────────────────

local function copyTables(destination, keysTable, valuesTable)
    valuesTable = valuesTable or keysTable
    local mt = getmetatable(keysTable)
    if mt then setmetatable(destination, mt) end
    for k, v in pairs(keysTable) do
        if type(v) == "table" then
            destination[k] = copyTables({}, v, valuesTable[k])
        else
            destination[k] = valuesTable[k]
        end
    end
    return destination
end

local function checkSubjectAndTargetRecursively(subject, target, path)
    path = path or ""
    local targetType, subjectType
    for k, targetValue in pairs(target) do
        local newPath = path .. "/" .. tostring(k)
        targetType = type(targetValue)
        local subjectValue = subject[k]
        subjectType = type(subjectValue)
        if targetType == "table" then
            checkSubjectAndTargetRecursively(subjectValue, targetValue, newPath)
        elseif targetType ~= "number" then
            error("Parameter '" .. newPath .. "' must be a number. Was " .. tostring(targetValue) .. " (a " .. targetType .. ")")
        elseif subjectType ~= "number" then
            error("Parameter '" .. newPath .. "' is missing from subject or isn't a number (got " .. tostring(subjectValue) .. " [" .. subjectType .. "])")
        end
    end
end

local function getEasingFunction(easing)
    easing = easing or "linear"
    if type(easing) == "function" then return easing end
    assert(type(easing) == "string", "easing must be a function or string. Was " .. tostring(easing) .. " [" .. type(easing) .. "]")
    local f = tween.easing[easing]
    assert(f, "The easing function name '" .. easing .. "' is invalid")
    return f
end

local function checkNewParams(duration, subject, target)
    assert(type(duration) == "number" and duration > 0, "duration must be a positive number. Was " .. tostring(duration) .. " [" .. type(duration) .. "]")
    local subjectType = type(subject)
    assert(subjectType == "table" or subjectType == "userdata", "subject must be a table or userdata. Was " .. tostring(subject) .. " [" .. subjectType .. "]")
    assert(type(target) == "table", "target must be a table. Was " .. tostring(target) .. " [" .. type(target) .. "]")
end

local function performEasingOnSubject(subject, target, initial, clock, duration, easing)
    for k, v in pairs(target) do
        if type(v) == "table" then
            performEasingOnSubject(subject[k], v, initial[k], clock, duration, easing)
        else
            subject[k] = easing(clock, initial[k], v - initial[k], duration)
        end
    end
end

-- ─── Tween 实例 ───────────────────────────────────────────────────────────────

local Tween_mt = {}
Tween_mt.__index = Tween_mt

function Tween_mt:set(clock)
    assert(type(clock) == "number", "clock must be a number. Was " .. tostring(clock))
    if not self.initial then
        self.initial = copyTables({}, self.subject)
    end
    self.clock = clock
    if self.clock <= 0 then
        self.clock = 0
        copyTables(self.subject, self.initial)
    elseif self.clock >= self.duration then
        self.clock = self.duration
        copyTables(self.subject, self.target)
    else
        performEasingOnSubject(self.subject, self.target, self.initial, self.clock, self.duration, self.easing)
    end
    return self.clock >= self.duration
end

function Tween_mt:reset()
    return self:set(0)
end

function Tween_mt:update(dt)
    assert(type(dt) == "number", "dt must be a number. Was " .. tostring(dt))
    return self:set(self.clock + dt)
end

-- ─── easing 函数表 ─────────────────────────────────────────────────────────────

local pow  = function(x, n) return x ^ n end
local sin  = math.sin
local cos  = math.cos
local pi   = math.pi
local sqrt = math.sqrt
local abs  = math.abs
local asin = math.asin

local function linear(t, b, c, d)
    return c * t / d + b
end

local function inQuad(t, b, c, d)
    t = t / d
    return c * t * t + b
end

local function outQuad(t, b, c, d)
    t = t / d
    return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t + b
    end
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

local function outInQuad(t, b, c, d)
    if t < d / 2 then
        return outQuad(t * 2, b, c / 2, d)
    end
    return inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

local function inCubic(t, b, c, d)
    t = t / d
    return c * t * t * t + b
end

local function outCubic(t, b, c, d)
    t = t / d - 1
    return c * (t * t * t + 1) + b
end

local function inOutCubic(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t + b
    end
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
end

local function outInCubic(t, b, c, d)
    if t < d / 2 then
        return outCubic(t * 2, b, c / 2, d)
    end
    return inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

local function inQuart(t, b, c, d)
    t = t / d
    return c * t * t * t * t + b
end

local function outQuart(t, b, c, d)
    t = t / d - 1
    return -c * (t * t * t * t - 1) + b
end

local function inOutQuart(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t * t + b
    end
    t = t - 2
    return -c / 2 * (t * t * t * t - 2) + b
end

local function outInQuart(t, b, c, d)
    if t < d / 2 then
        return outQuart(t * 2, b, c / 2, d)
    end
    return inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

local function inQuint(t, b, c, d)
    t = t / d
    return c * t * t * t * t * t + b
end

local function outQuint(t, b, c, d)
    t = t / d - 1
    return c * (t * t * t * t * t + 1) + b
end

local function inOutQuint(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t * t * t + b
    end
    t = t - 2
    return c / 2 * (t * t * t * t * t + 2) + b
end

local function outInQuint(t, b, c, d)
    if t < d / 2 then
        return outQuint(t * 2, b, c / 2, d)
    end
    return inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

local function inSine(t, b, c, d)
    return -c * cos(t / d * (pi / 2)) + c + b
end

local function outSine(t, b, c, d)
    return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
    return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function outInSine(t, b, c, d)
    if t < d / 2 then
        return outSine(t * 2, b, c / 2, d)
    end
    return inSine((t * 2) - d, b + c / 2, c / 2, d)
end

local function inExpo(t, b, c, d)
    if t == 0 then return b end
    return c * pow(2, 10 * (t / d - 1)) - c * 0.001 + b
end

local function outExpo(t, b, c, d)
    if t == d then return b + c end
    return c * 1.001 * (1 - pow(2, -10 * t / d)) + b
end

local function inOutExpo(t, b, c, d)
    if t == 0 then return b end
    if t == d then return b + c end
    t = t / d * 2
    if t < 1 then
        return c / 2 * pow(2, 10 * (t - 1)) - c * 0.0005 + b
    end
    t = t - 1
    return c / 2 * 1.0005 * (2 - pow(2, -10 * t)) + b
end

local function outInExpo(t, b, c, d)
    if t < d / 2 then
        return outExpo(t * 2, b, c / 2, d)
    end
    return inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

local function inCirc(t, b, c, d)
    t = t / d
    return -c * (sqrt(1 - t * t) - 1) + b
end

local function outCirc(t, b, c, d)
    t = t / d - 1
    return c * sqrt(1 - t * t) + b
end

local function inOutCirc(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return -c / 2 * (sqrt(1 - t * t) - 1) + b
    end
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
end

local function outInCirc(t, b, c, d)
    if t < d / 2 then
        return outCirc(t * 2, b, c / 2, d)
    end
    return inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

local function inElastic(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d
    if t == 1 then return b + c end
    if not p then p = d * 0.3 end
    local s
    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c / a)
    end
    t = t - 1
    return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

local function outElastic(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d
    if t == 1 then return b + c end
    if not p then p = d * 0.3 end
    local s
    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c / a)
    end
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

local function inOutElastic(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d * 2
    if t == 2 then return b + c end
    if not p then p = d * (0.3 * 1.5) end
    if not a then a = 0 end
    local s
    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c / a)
    end
    if t < 1 then
        t = t - 1
        return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
    end
    t = t - 1
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) * 0.5 + c + b
end

local function outInElastic(t, b, c, d, a, p)
    if t < d / 2 then
        return outElastic(t * 2, b, c / 2, d, a, p)
    end
    return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

local function inBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
end

local function outBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inOutBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    s = s * 1.525
    t = t / d * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    end
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

local function outInBack(t, b, c, d, s)
    if t < d / 2 then
        return outBack(t * 2, b, c / 2, d, s)
    end
    return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

local function outBounce(t, b, c, d)
    t = t / d
    if t < 1 / 2.75 then
        return c * (7.5625 * t * t) + b
    elseif t < 2 / 2.75 then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5 / 2.75 then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + 0.9375) + b
    end
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
end

local function inBounce(t, b, c, d)
    return c - outBounce(d - t, 0, c, d) + b
end

local function inOutBounce(t, b, c, d)
    if t < d / 2 then
        return inBounce(t * 2, 0, c, d) * 0.5 + b
    end
    return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
end

local function outInBounce(t, b, c, d)
    if t < d / 2 then
        return outBounce(t * 2, b, c / 2, d)
    end
    return inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

tween.easing = {
    linear      = linear,
    inQuad      = inQuad,      outQuad      = outQuad,      inOutQuad      = inOutQuad,      outInQuad      = outInQuad,
    inCubic     = inCubic,     outCubic     = outCubic,     inOutCubic     = inOutCubic,     outInCubic     = outInCubic,
    inQuart     = inQuart,     outQuart     = outQuart,     inOutQuart     = inOutQuart,     outInQuart     = outInQuart,
    inQuint     = inQuint,     outQuint     = outQuint,     inOutQuint     = inOutQuint,     outInQuint     = outInQuint,
    inSine      = inSine,      outSine      = outSine,      inOutSine      = inOutSine,      outInSine      = outInSine,
    inExpo      = inExpo,      outExpo      = outExpo,      inOutExpo      = inOutExpo,      outInExpo      = outInExpo,
    inCirc      = inCirc,      outCirc      = outCirc,      inOutCirc      = inOutCirc,      outInCirc      = outInCirc,
    inElastic   = inElastic,   outElastic   = outElastic,   inOutElastic   = inOutElastic,   outInElastic   = outInElastic,
    inBack      = inBack,      outBack      = outBack,      inOutBack      = inOutBack,      outInBack      = outInBack,
    inBounce    = inBounce,    outBounce    = outBounce,    inOutBounce    = inOutBounce,    outInBounce    = outInBounce,
}

-- ─── 构造函数 ────────────────────────────────────────────────────────────────

function tween.new(duration, subject, target, easing)
    checkNewParams(duration, subject, target)
    easing = getEasingFunction(easing)
    checkSubjectAndTargetRecursively(subject, target)
    return setmetatable({
        duration = duration,
        subject  = subject,
        target   = target,
        easing   = easing,
        clock    = 0,
    }, Tween_mt)
end

return tween
