local addonVer = "1.0.0.5"
local me = UnitName('player')

function rfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function rfdebug(a)
    if (me == 'Xerrbear' or me == 'Kzktst') then
        nfprint('|cff0070de[Rollframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local RollFrame = CreateFrame("Frame")

RollFrame.watchRolls = false
RollFrame.rolls = {}

RollFrame:RegisterEvent("ADDON_LOADED")
RollFrame:RegisterEvent("CHAT_MSG_SYSTEM")
RollFrame:SetScript("OnEvent", function()
    if (event) then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            RollFrame:HideAnchor()
            if not TWLC_ROLL_ENABLE_SOUND then TWLC_ROLL_ENABLE_SOUND = true end
            if not TWLC_ROLL_VOLUME then TWLC_ROLL_VOLUME = 'high' end
            rfprint('TWLC2c RollFrame (v' .. addonVer .. ') Loaded. Type |cfffff569/tw|cff69ccf0roll |cffffffffto show the Anchor window.')
            if TWLC_ROLL_ENABLE_SOUND then
                rfprint('Roll Sound is Enabled(' .. TWLC_ROLL_VOLUME .. '). Type |cfffff569/tw|cff69ccf0roll|cfffff569sound |cffffffffto toggle win sound on or off.')
            else
                rfprint('Roll Sound is Disabled. Type |cfffff569/tw|cff69ccf0roll|cfffff569sound |cffffffffto toggle win sound on or off.')
            end

            if TWLC_TROMBONE == nil then TWLC_TROMBONE = true end

            if TWLC_TROMBONE then
                wfprint('Sad Trombone Sound is Enabled. Type |cfffff569/tw|cff69ccf0trombone |cffffffffto toggle sad trombone sound on or off.')
            else
                wfprint('Sad Trombone Sound is Disabled. Type |cfffff569/tw|cff69ccf0trombone |cffffffffto toggle sad trombone sound on or off.')
            end

            RollFrame.ResetVars()
        end
        if (event == "CHAT_MSG_SYSTEM" and RollFrame.watchRolls) then


            if ((string.find(arg1, "rolls", 1, true) or string.find(arg1, "würfelt. Ergebnis", 1, true)) and string.find(arg1, "(1-100)", 1, true)) then --vote tie rolls
                --en--Er rolls 47 (1-100)
                --de--Er würfelt. Ergebnis: 47 (1-100)
                local r = string.split(arg1, " ")

                if not r[2] or not r[3] then
                    return false
                end

                local name = r[1]
                local roll = tonumber(r[3])

                if string.find(arg1, "würfelt. Ergebnis", 1, true) then
                    if not r[4] then
                        return false
                    end
                    roll = tonumber(r[4])
                end

                RollFrame.rolls[name] = roll
--                rfprint('recorded roll '..name..' ' .. roll)
            end

        end
    end
end)

local RollFrameComms = CreateFrame("Frame")
RollFrameComms:RegisterEvent("CHAT_MSG_ADDON")

local RollFrameCountdown = CreateFrame("Frame")

RollFrameCountdown:Hide()
RollFrameCountdown.timeToRoll = 30 --default, will be gotted via addonMessage

RollFrameCountdown.T = 1
RollFrameCountdown.C = RollFrameCountdown.timeToRoll


local RollFrames = CreateFrame("Frame")
RollFrames.itemFrames = {}
RollFrames.execs = 0
RollFrames.itemQuality = {}

local fadeInAnimationFrameRF = CreateFrame("Frame")
fadeInAnimationFrameRF:Hide()
fadeInAnimationFrameRF.ids = {}
fadeInAnimationFrameRF.frameIndex = {}

local fadeOutAnimationFrameRF = CreateFrame("Frame")
fadeOutAnimationFrameRF:Hide()
fadeOutAnimationFrameRF.ids = {}

local delayAddItem = CreateFrame("Frame")
delayAddItem:Hide()
delayAddItem.data = {}

delayAddItem:SetScript("OnShow", function()
    this.startTime = GetTime();
end)
delayAddItem:SetScript("OnUpdate", function()
    local plus = 1
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then

        local atLeastOne = false
        for id, data in next, delayAddItem.data do
            if delayAddItem.data[id] then
                atLeastOne = true
                rfprint('delay  add item on update')
                RollFrames.addRolledItem(data)
                delayAddItem.data[id] = nil
            end
        end

        if not atLeastOne then
            delayAddItem:Hide()
        end
    end
end)

RollFrameCountdown:SetScript("OnShow", function()
    this.startTime = GetTime();
end)

RollFrameCountdown:SetScript("OnUpdate", function()
    local plus = 0.03
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000

    if gt >= st then
        if (RollFrameCountdown.T ~= RollFrameCountdown.timeToRoll + plus) then

            for index in next, RollFrames.itemFrames do
                if (math.floor(RollFrameCountdown.C - RollFrameCountdown.T + plus) < 0) then
                    getglobal('RollFrame' .. index .. 'TimeLeftBarText'):SetText("CLOSED")
                else
                    getglobal('RollFrame' .. index .. 'TimeLeftBarText'):SetText(math.ceil(RollFrameCountdown.C - RollFrameCountdown.T + plus) .. "s")
                end

                getglobal('RollFrame' .. index .. 'TimeLeftBar'):SetWidth((RollFrameCountdown.C - RollFrameCountdown.T + plus) * 190 / RollFrameCountdown.timeToRoll)
            end
        end
        RollFrameCountdown:Hide()
        if (RollFrameCountdown.T < RollFrameCountdown.C + plus) then
            --still tick
            RollFrameCountdown.T = RollFrameCountdown.T + plus
            RollFrameCountdown:Show()
        elseif (RollFrameCountdown.T > RollFrameCountdown.timeToRoll + plus) then

            -- hide frames and send auto pass
            for index in next, RollFrames.itemFrames do
                if (RollFrames.itemFrames[index]:IsVisible()) then
                    PlayerRollItemButton_OnClick(this:GetID(), 'roll');
                end
            end
            -- end hide frames

            RollFrameCountdown:Hide()
            RollFrameCountdown.T = 1

        else
            --
        end
    else
        --
    end
end)

RollFrames.freeSpots = {}

function RollFrames.addRolledItem(data)
    local item = string.split(data, "=")

    RollFrameCountdown.timeToRoll = tonumber(item[6])
    RollFrameCountdown.C = RollFrameCountdown.timeToRoll

    RollFrames.execs = RollFrames.execs + 1

    local index = tonumber(item[2])
    local texture = item[3]
    local name = item[4]
    local link = item[5]

    local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");

    GameTooltip:SetHyperlink(itemLink)
    GameTooltip:Hide()

    local name, _, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if (not name or not quality) then
        delayAddItem.data[index] = data
        delayAddItem:Show()
        return false
    end

    RollFrames.itemQuality[index] = quality
    RollFrames.execs = 0

    if RollFrames.itemFrames[index] then
        if RollFrames.itemFrames[index]:IsVisible() then
            RollFrames.itemFrames[index]:Hide()
            RollFrames.addRolledItem(data)
            return false
        end
    else
        RollFrames.itemFrames[index] = CreateFrame("Frame", "RollFrame" .. index, getglobal("RollFrame"), "RollFrameItemTemplate")
    end

    RollFrames.itemFrames[index]:Show()
    RollFrames.itemFrames[index]:SetAlpha(0)

    RollFrames.itemFrames[index]:ClearAllPoints()
    if (index == 0) then --test button
        RollFrames.itemFrames[index]:SetPoint("TOP", getglobal("RollFrame"), "TOP", 0, 40 + (80 * 1))
    else
        RollFrames.itemFrames[index]:SetPoint("TOP", getglobal("RollFrame"), "TOP", 0, 40 + (80 * firstFree(index)))
    end
    RollFrames.itemFrames[index].link = link

    getglobal('RollFrame' .. index .. 'ItemIcon'):SetNormalTexture(texture);
    getglobal('RollFrame' .. index .. 'ItemIcon'):SetPushedTexture(texture);
    getglobal('RollFrame' .. index .. 'ItemIconItemName'):SetText(link);

    getglobal('RollFrame' .. index .. 'Roll'):SetID(index);
    getglobal('RollFrame' .. index .. 'Pass'):SetID(index);

    local r, g, b = GetItemQualityColor(quality)

    getglobal('RollFrame' .. index .. 'TimeLeftBar'):SetBackdropColor(r, g, b, .76)

    addOnEnterTooltipRollFrame(getglobal('RollFrame' .. index .. 'ItemIcon'), link)

    FadeInFrameRF(index)
end

function PlayerRollItemButton_OnClick(id, roll)

    for i = 1, table.getn(RollFrames.freeSpots) do
        if RollFrames.freeSpots[i] == id then
            RollFrames.freeSpots[i] = 0
            break
        end
    end

    if (id == 0) then
        fadeOutFrameRF(id)
        return
    end

    if (roll == 'pass') then
        SendAddonMessage("TWLCNF", "rollChoice=" .. id .. "=-1", "RAID")
    end

    if (roll == 'roll') then
        --        SendAddonMessage("TWLCNF", "rollChoice=" .. id, "RAID")
        RandomRoll(1, 100)
    end

    fadeOutFrameRF(id)
end


function FadeInFrameRF(id)
    if TWLC_ROLL_ENABLE_SOUND then
        PlaySoundFile("Interface\\AddOns\\TWLC2c\\sound\\please_roll_" .. TWLC_ROLL_VOLUME .. ".ogg");
    end
    fadeInAnimationFrameRF.ids[id] = true
    fadeInAnimationFrameRF.frameIndex[id] = 0
    fadeInAnimationFrameRF:Show()
end

function fadeOutFrameRF(id)
    fadeOutAnimationFrameRF.ids[id] = true
    fadeOutAnimationFrameRF:Show()
end

fadeInAnimationFrameRF:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

fadeOutAnimationFrameRF:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

fadeInAnimationFrameRF:SetScript("OnUpdate", function()
    if ((GetTime()) >= (this.startTime) + 0.03) then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeInAnimationFrameRF.ids do
            if fadeInAnimationFrameRF.ids[id] then
                atLeastOne = true
                local frame = getglobal("RollFrame" .. id)

                local frameNr = fadeInAnimationFrameRF.frameIndex[id]
                if (fadeInAnimationFrameRF.frameIndex[id] < 10) then
                    frameNr = '0' .. fadeInAnimationFrameRF.frameIndex[id]
                end

                if fadeInAnimationFrameRF.frameIndex[id] > 30 then
                    frameNr = 30
                end

                frame:SetBackdrop({
                    bgFile = "Interface\\addons\\TWLC2c\\images\\roll\\roll_frame_" .. RollFrames.itemQuality[id] .. "_" .. frameNr,
                    tile = false,
                })

                --fadein
                if fadeInAnimationFrameRF.frameIndex[id] >= 0 and fadeInAnimationFrameRF.frameIndex[id] <= 5 then
                    frame:SetAlpha(fadeInAnimationFrameRF.frameIndex[id] * 0.2)
                end

                --fadeout
                if fadeInAnimationFrameRF.frameIndex[id] >= (RollFrameCountdown.timeToRoll - 1) * 30 and fadeInAnimationFrameRF.frameIndex[id] <= RollFrameCountdown.timeToRoll * 30 then
                    frame:SetAlpha(frame:GetAlpha() - 0.2)
                end

                if (fadeInAnimationFrameRF.frameIndex[id] < RollFrameCountdown.timeToRoll * 30) then
                    getglobal('RollFrame' .. id .. 'TimeLeftBarText'):SetText(math.ceil(RollFrameCountdown.timeToRoll - fadeInAnimationFrameRF.frameIndex[id] / 30) - 1 .. "s")
                    getglobal('RollFrame' .. id .. 'TimeLeftBar'):SetWidth(math.ceil(RollFrameCountdown.timeToRoll - fadeInAnimationFrameRF.frameIndex[id] / 30 - 1) * 190 / RollFrameCountdown.timeToRoll)
                    fadeInAnimationFrameRF.frameIndex[id] = fadeInAnimationFrameRF.frameIndex[id] + 1
                else
                    if frame:IsVisible() then
                        rfdebug('auto roll because it ended')
                        PlayerRollItemButton_OnClick(id, 'roll');
                    else
                        rfdebug('timer ended and frame is invisible, should not roll')
                    end
                    fadeInAnimationFrameRF.ids[id] = false
                    fadeInAnimationFrameRF.ids[id] = nil


                    if RollFrame.watchRolls == true then --and enabled global var

                        local maxRoll = 0
                        for name, roll in next, RollFrame.rolls do
                            if maxRoll < roll then maxRoll = roll end
                        end

                        rfdebug(' maxroll = ' .. maxRoll)

                        if RollFrame.rolls[me] ~= maxRoll and TWLC_TROMBONE then
                            PlaySoundFile("Interface\\AddOns\\TWLC2c\\sound\\sadtrombone.ogg")
                            RollFrame.watchRolls = false
                        end

                    end

                end
                --                return
            end
        end
        if (not atLeastOne) then
            fadeInAnimationFrameRF:Hide()
        end
    end
end)

fadeOutAnimationFrameRF:SetScript("OnUpdate", function()
    if ((GetTime()) >= (this.startTime) + 0.03) then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeOutAnimationFrameRF.ids do
            if fadeOutAnimationFrameRF.ids[id] then
                atLeastOne = true
                local frame = getglobal("RollFrame" .. id)
                if (frame:GetAlpha() > 0) then
                    frame:SetAlpha(frame:GetAlpha() - 0.15)
                else
                    fadeOutAnimationFrameRF.ids[id] = false
                    fadeOutAnimationFrameRF.ids[id] = nil
                    frame:Hide()
                end
            end
        end
        if (not atLeastOne) then
            fadeOutAnimationFrameRF:Hide()
        end
    end
end)

function RollFrame.ResetVars()

    for index, frame in next, RollFrames.itemFrames do
        RollFrames.itemFrames[index]:Hide()
    end

    RollFrames.freeSpots = {}


    getglobal('RollFrame'):Hide()

    RollFrameCountdown:Hide()
    RollFrameCountdown.T = 1

    fadeInAnimationFrameRF:Hide()

    fadeInAnimationFrameRF.ids = {}
    RollFrames.itemQuality = {}

    RollFrame.watchRolls = false
    RollFrame.rolls = {}
end



RollFrameComms:SetScript("OnEvent", function()
    --TWLCNF
    if (event) then
        if (event == 'CHAT_MSG_ADDON' and arg1 == 'TWLCNF') then

            if (RollFrame:twlc2isRL(arg4)) then

                if (string.find(arg2, 'rollFor=', 1, true)) then

                    -- 'rollFor=' .. itemindex.. '=' .. tex .. '=' .. iname .. '=' .. link .. '=' .. TIME_TO_ROLL .. '=' .. me?'
                    local rfEx = string.split(arg2, '=')
                    if rfEx[7] then
                        if rfEx[7] == me then
                            RollFrames.addRolledItem(arg2)
                            if (not getglobal('RollFrame'):IsVisible()) then
                                getglobal('RollFrame'):Show()
                            end
                            RollFrame.watchRolls = true
                        end
                    end
                end

                if (string.find(arg2, 'rollframe=', 1, true)) then
                    local command = string.split(arg2, '=')
                    if (command[2] == "reset") then
                        RollFrame.ResetVars()
                    end
                    if (command[2] == "whoRF") then
                        ChatThrottleLib:SendAddonMessage("NORMAL", "TWLCNF", "withAddonRF=" .. arg4 .. "=" .. me .. "=" .. addonVer, "RAID")
                    end
                end
            end
        end
    end
end)

function RFIT_DragStart()
    getglobal('RollFrame'):StartMoving();
    getglobal('RollFrame').isMoving = true;
end

function RFIT_DragEnd()
    getglobal('RollFrame'):StopMovingOrSizing();
    getglobal('RollFrame').isMoving = false;
end


function RollFrame:ShowAnchor()
    getglobal('RollFrame'):SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
    })
    getglobal('RollFrame'):Show()
    getglobal('RollFrame'):EnableMouse(true)
    getglobal('RollFrameTitle'):Show()
    getglobal('RollFrameTestPlacement'):Show()
    getglobal('RollFrameClosePlacement'):Show()
end

function RollFrame:HideAnchor()
    getglobal('RollFrame'):SetBackdrop({
        bgFile = "",
        tile = true,
    })
    getglobal('RollFrame'):Hide()
    getglobal('RollFrame'):EnableMouse(false)
    getglobal('RollFrameTitle'):Hide()
    getglobal('RollFrameTestPlacement'):Hide()
    getglobal('RollFrameClosePlacement'):Hide()
end

function roll_frame_close()
    rfprint('Anchor window closed. Type |cfffff569/tw|cff69ccf0roll |cffffffffto show the Anchor window.')
    RollFrame:HideAnchor()
end

function roll_frame_test()

    --    local linkString = '|cffff8000|Hitem:19364:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r'
    local linkString = '|cffa335ee|Hitem:19364:0:0:0:0:0:0:0:0|h[Ashkandi, Greatsword of the Brotherhood]|h|r'
    local _, _, itemLink = string.find(linkString, "(item:%d+:%d+:%d+:%d+)");
    local name, il, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if (name and tex) then
        RollFrames.addRolledItem('rollFor=0=' .. tex .. '=' .. name .. '=' .. linkString .. '=30=' .. me)
        if (not getglobal('RollFrame'):IsVisible()) then
            getglobal('RollFrame'):Show()
        end
    else
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Hide()
    end
end

function roll_frame_test2()

    --    local linkString = '|cffff8000|Hitem:19364:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r'
    local linkString = '|cffa335ee|Hitem:1717:0:0:0:0:0:0:0:0|h[Ashkandi, Greatsword of the Brotherhood]|h|r'
    local _, _, itemLink = string.find(linkString, "(item:%d+:%d+:%d+:%d+)");
    local name, il, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if (name and tex) then
        RollFrames.addRolledItem('rollFor=0=' .. tex .. '=' .. name .. '=' .. linkString .. '=30=' .. me)
        if (not getglobal('RollFrame'):IsVisible()) then
            getglobal('RollFrame'):Show()
        end
    else
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Hide()
    end
end

SLASH_TWTROMBONE1 = "/twtrombone"
SlashCmdList["TWTROMBONE"] = function(cmd)
    if cmd then
        TWLC_TROMBONE = not TWLC_TROMBONE
        if TWLC_TROMBONE then
            wfprint('Sad Trombone Sound is Enabled. Type |cfffff569/tw|cff69ccf0trombone |cffffffffto toggle sad trombone sound on or off.')
        else
            wfprint('Sad Trombone Sound is Disabled. Type |cfffff569/tw|cff69ccf0trombone |cffffffffto toggle sad trombone sound on or off.')
        end
    end
end

SLASH_TWROLL1 = "/twroll"
SlashCmdList["TWROLL"] = function(cmd)
    if cmd then
        RollFrame:ShowAnchor()
    end
end

SLASH_TWROLLSOUND1 = "/twrollsound"
SlashCmdList["TWROLLSOUND"] = function(cmd)
    if cmd then
        if cmd == 'high' or cmd == 'low' then
            TWLC_ROLL_VOLUME = cmd
            wfprint('Roll Sound Volume set to |cfffff569' .. TWLC_ROLL_VOLUME)
            return true
        end
        TWLC_ROLL_ENABLE_SOUND = not TWLC_ROLL_ENABLE_SOUND
        if TWLC_ROLL_ENABLE_SOUND then
            rfprint('Roll Sound Enabled')
        else
            rfprint('Roll Sound Disabled')
        end
    end
end

-- utils

function RollFrame:twlc2isRL(name)
    for i = 0, GetNumRaidMembers() do
        if (GetRaidRosterInfo(i)) then
            local n, r = GetRaidRosterInfo(i);
            if (n == name and r == 2) then
                return true
            end
        end
    end
    return false
end

function tablen(t)
    local count = 0
    for i in next, RollFrames.itemFrames do
        count = count + 1
    end
    return count
end

function firstFree(index)
    for i = 1, table.getn(RollFrames.freeSpots) do
        if RollFrames.freeSpots[i] == 0 then
            return i
        end
    end

    RollFrames.freeSpots[table.getn(RollFrames.freeSpots) + 1] = index
    return table.getn(RollFrames.freeSpots)
end

function addOnEnterTooltipRollFrame(frame, itemLink)
    local ex = string.split(itemLink, "|")

    if (not ex[3]) then return end

    frame:SetScript("OnEnter", function(self)
        RollFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
        RollFrameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
        RollFrameTooltip:Show();
    end)
    frame:SetScript("OnLeave", function(self)
        RollFrameTooltip:Hide();
    end)
end
