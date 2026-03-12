icons = {}
count = 20           -- total slots displayed in the ring
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
    local angleStep = (2 * math.pi) / slots
    local bigSize = 58
    local smallSize = 29
    local bigHalf = 19
    local smallHalf = 14.5
    local bigRadius = radius
    local smallRadius = radius / 2

    -- hide unused meters beyond actual file count
    for i = slots + 1, count do
        SKIN:Bang("!HideMeter", "MeterIcon"..i)
        SKIN:Bang("!HideMeter", "MeterIconSmall"..i)
    end

    for i = 1, slots do
        local angle = (i - 1) * angleStep

        -- big icon position
        local xBig = centerX + bigRadius * math.cos(angle) - bigHalf
        local yBig = centerY -2+ bigRadius * math.sin(angle) - bigHalf
        SKIN:Bang("!SetOption", "MeterIcon"..i, "X", xBig)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "Y", yBig)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "W", bigSize)
        SKIN:Bang("!SetOption", "MeterIcon"..i, "H", bigSize)

        -- small icon position
        local xSmall = centerX +10+ smallRadius * math.cos(angle) - smallHalf
        local ySmall = centerY +10+ smallRadius * math.sin(angle) - smallHalf
        SKIN:Bang("!SetOption", "MeterIconSmall"..i, "X", xSmall)
        SKIN:Bang("!SetOption", "MeterIconSmall"..i, "Y", ySmall)
        SKIN:Bang("!SetOption", "MeterIconSmall"..i, "W", smallSize)
        SKIN:Bang("!SetOption", "MeterIconSmall"..i, "H", smallSize)
    end

    SKIN:Bang("!UpdateMeterGroup", "Icons")
    SKIN:Bang("!UpdateMeterGroup", "SmallIcons")
    SKIN:Bang("!Redraw")
end

function Collapse()
    for i = 1, count do
        SKIN:Bang("!HideMeter", "MeterIcon"..i)
        SKIN:Bang("!HideMeter", "MeterIconSmall"..i)
    end

    SKIN:Bang("!UpdateMeterGroup", "Icons")
    SKIN:Bang("!UpdateMeterGroup", "SmallIcons")
    SKIN:Bang("!Redraw")
end
