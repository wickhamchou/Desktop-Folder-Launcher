icons = {}
count = 26           -- total slots displayed in the ring
count1 = 0           -- actual file count in @Resources/Shortcuts
prevCount1 = 0       -- for debug logging
placedCount = 0      -- last count used for positioning
radius = 120
centerX = 150
centerY = 150
expanded = false

bigIcons = {}
smallIcons = {}

local function updateCount1()
    -- Refresh the FileView root measure first
    if SKIN:GetMeasure("MeasureFolder") then
        SKIN:Bang("!UpdateMeasure", "MeasureFolder")
    end

    local n = 0
    for i = 1, count do
        local mIcon = SKIN:GetMeasure("MeasureIcon" .. i)
        if mIcon then
            SKIN:Bang("!UpdateMeasure", "MeasureIcon" .. i)
            local s = mIcon:GetStringValue()
            if s and s ~= "" then
                n = n + 1
            else
                -- stop at first empty slot
                break
            end
        end
    end

    count1 = n
    if count1 > 0 and count1 ~= prevCount1 then
        prevCount1 = count1
    end
    SKIN:Bang("!SetVariable", "count1", count1)
end

function Initialize()
    for i = 1, count do
        bigIcons[i] = SKIN:GetMeter("MeterIcon" .. i)
        smallIcons[i] = SKIN:GetMeter("MeterIconSmall" .. i)
    end

    updateCount1()
    -- Position icons once on load so they don't stack in the top-left
    Expand()
end

function Toggle()
    expanded = not expanded
    Expand()
end

-- Keep count1 in sync with the FileView measure every update
function Update()
    updateCount1()
    if count1 > 0 and count1 ~= placedCount then
        Expand()
        placedCount = count1
    end
end

function Expand()
    local slots = count1
    if slots == 0 then
        Collapse()
        return
    end
    if slots > 26 then
        Collapse()
        return
    end
    local bigSize = 58
    local smallSize = 29
    local bigHalf = 19
    local smallHalf = 14.5
    local innerRadius = radius
    local outerRadius = radius
    local smallRadius = radius / 2

    local innerCount = slots
    local outerCount = 0
    local useOuter = false
    if slots > 10 and slots <= 19 then
        innerCount = 5
        outerCount = slots - innerCount
        useOuter = true
    elseif slots > 19 and slots <= 26 then
        outerCount = 16
        innerCount = slots - outerCount
        useOuter = true
    end

    if useOuter then
        outerRadius = radius * 1.6
    end

    -- Scale the roundline radius when using the outer ring
    if useOuter then
        SKIN:Bang("!SetVariable", "CircleScale", "1.5")
        SKIN:Bang("!SetVariable", "LineLengthScale", "1.1")
        SKIN:Bang("!SetVariable", "LineStartScale", "1.0")
    else
        SKIN:Bang("!SetVariable", "CircleScale", "1.0")
        SKIN:Bang("!SetVariable", "LineLengthScale", "0.7")
        SKIN:Bang("!SetVariable", "LineStartScale", "1.7")
    end

    local innerAngleStep = (2 * math.pi) / innerCount
    local outerAngleStep = (2 * math.pi) / math.max(outerCount, 1)
    local smallSlots = math.min(slots, 10)
    local smallAngleStep = (2 * math.pi) / smallSlots

    -- Keep the ring centered in the 480x480 area even when not using the outer ring
    local baseCenterX = centerX + 20
    local baseCenterY = centerY + 20 - 2
    local offsetX = 240 - baseCenterX
    local offsetY = 240 - baseCenterY

    -- Avoid negative coordinates when the outer ring is used (prevents top/left clipping)
    if useOuter then
        local minX = baseCenterX + offsetX - outerRadius - bigHalf
        local minY = baseCenterY + offsetY - outerRadius - bigHalf
        if minX < 0 then
            offsetX = offsetX - minX
        end
        if minY < 0 then
            offsetY = offsetY - minY
        end
    end

    -- hide unused meters beyond actual file count / small cap
    for i = 1, count do
        if i > slots then
            SKIN:Bang("!HideMeter", "MeterIcon"..i)
        end
        if i > smallSlots then
            local smallMeter = SKIN:GetMeter("MeterIconSmall"..i)
            if smallMeter then
                SKIN:Bang("!HideMeter", "MeterIconSmall"..i)
            end
        end
    end

    for i = 1, slots do
        local angle
        local bigRadius
        if useOuter and i > innerCount then
            local outerIndex = i - innerCount
            angle = (outerIndex - 1) * outerAngleStep
            bigRadius = outerRadius
        else
            angle = (i - 1) * innerAngleStep
            bigRadius = innerRadius
        end

        -- big icon position
        local xBig = centerX +10+ offsetX + bigRadius * math.cos(angle) - bigHalf
        local yBig = centerY +10+ offsetY -2+ bigRadius * math.sin(angle) - bigHalf
        SKIN:Bang("!SetOption", "MeterIcon"..i, "X", xBig)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "Y", yBig)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "W", bigSize)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "H", bigSize)

        -- small icon position
        if i <= smallSlots then
            local angleSmall = (i - 1) * smallAngleStep
            local xSmall = centerX + offsetX +20+ smallRadius * math.cos(angleSmall) - smallHalf
            local ySmall = centerY + offsetY +20+ smallRadius * math.sin(angleSmall) - smallHalf
            SKIN:Bang("!SetOption", "MeterIconSmall"..i, "X", xSmall)
            SKIN:Bang("!SetOption", "MeterIconSmall"..i, "Y", ySmall)
            SKIN:Bang("!SetOption", "MeterIconSmall"..i, "W", smallSize)
            SKIN:Bang("!SetOption", "MeterIconSmall"..i, "H", smallSize)
        end
    end

    SKIN:Bang("!UpdateMeterGroup", "Icons")
    SKIN:Bang("!UpdateMeterGroup", "SmallIcons")
    SKIN:Bang("!Redraw")
end

function Collapse()
    for i = 1, count do
        SKIN:Bang("!HideMeter", "MeterIcon"..i)
        local smallMeter = SKIN:GetMeter("MeterIconSmall"..i)
        if smallMeter then
            SKIN:Bang("!HideMeter", "MeterIconSmall"..i)
        end
    end

    SKIN:Bang("!UpdateMeterGroup", "Icons")
    SKIN:Bang("!UpdateMeterGroup", "SmallIcons")
    SKIN:Bang("!Redraw")
end
