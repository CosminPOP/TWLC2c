local LootLCCountdown = CreateFrame("Frame")
local LootLCNeedFrame = CreateFrame("Frame")
local NeedFrameComms = CreateFrame("Frame")
NeedFrameComms:RegisterEvent("CHAT_MSG_ADDON")

LootLCCountdown:Hide()
LootLCCountdown.timeToNeed = 30 --default, will be gotted via addonMessage

LootLCCountdown.T = 1
LootLCCountdown.C = LootLCCountdown.timeToNeed


local LootLCNeedFrames = CreateFrame("Frame")
LootLCNeedFrames.itemFrames = {}
LootLCNeedFrames.execs = 0

local fadeInAnimationFrame = CreateFrame("Frame")
fadeInAnimationFrame:Hide()
fadeInAnimationFrame.ids = {}

local fadeOutAnimationFrame = CreateFrame("Frame")
fadeOutAnimationFrame:Hide()
fadeOutAnimationFrame.ids = {}

local delayAddItem = CreateFrame("Frame")
delayAddItem:Hide()
delayAddItem.data = {}

delayAddItem:SetScript("OnShow", function()
    this.startTime = GetTime();
end)
delayAddItem:SetScript("OnUpdate", function()
    local plus = 1
    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then

        local atLeastOne = false
        for id, data in next, delayAddItem.data do
            if delayAddItem.data[id] then
                atLeastOne = true
                twprint('delay  add item on update')
                LootLCNeedFrames.addItem(data)
                delayAddItem.data[id] = nil
            end
        end

        if not atLeastOne then
            delayAddItem:Hide()
        end
    end
end)

LootLCCountdown:SetScript("OnShow", function()
--    twdebug('NEEDFRAME LootLCCountdown.timeToNeed = ' .. LootLCCountdown.timeToNeed)
    this.startTime = GetTime();
end)

LootLCCountdown:SetScript("OnUpdate", function()
    local plus = 0.03
    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then
        if (LootLCCountdown.T ~= LootLCCountdown.timeToNeed + plus) then

            for index in next, LootLCNeedFrames.itemFrames do
                if (math.floor(LootLCCountdown.C - LootLCCountdown.T + plus) < 0) then
                    getglobal('LCNeedFrame' .. index .. 'TimeLeftBarText'):SetText("CLOSED")
                else
                    getglobal('LCNeedFrame' .. index .. 'TimeLeftBarText'):SetText(math.ceil(LootLCCountdown.C - LootLCCountdown.T + plus) .. "s")
                end

                getglobal('LCNeedFrame' .. index .. 'TimeLeftBar'):SetWidth((LootLCCountdown.C - LootLCCountdown.T + plus) * 190 / LootLCCountdown.timeToNeed)
            end
        end
        LootLCCountdown:Hide()
        if (LootLCCountdown.T < LootLCCountdown.C + plus) then
            --still tick
            LootLCCountdown.T = LootLCCountdown.T + plus
            LootLCCountdown:Show()
        elseif (LootLCCountdown.T > LootLCCountdown.timeToNeed + plus) then

            -- hide frames and send auto pass
            for index in next, LootLCNeedFrames.itemFrames do
                if (LootLCNeedFrames.itemFrames[index]:IsVisible()) then
                    PlayerNeedItemButton_OnClick(index, 'autopass')
                end
            end
            -- end hide frames

            LootLCCountdown:Hide()
            LootLCCountdown.T = 1

        else
            --
        end
    else
        --
    end
end)

function LootLCNeedFrames.addItem(data)
--    twdebug('data : ' .. data)
    local item = string.split(data, "=")

    LootLCCountdown.timeToNeed = tonumber(item[6])
    LootLCCountdown.C = LootLCCountdown.timeToNeed

    LootLCNeedFrames.execs = LootLCNeedFrames.execs + 1
    twprint('additem exec : ' .. LootLCNeedFrames.execs)

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

    LootLCNeedFrames.execs = 0

    SendAddonMessage("TWLCNF", "wait=" .. index .. "=0=0", "RAID")

    if (not LootLCNeedFrames.itemFrames[index]) then
        LootLCNeedFrames.itemFrames[index] = CreateFrame("Frame", "LCNeedFrame" .. index, getglobal("LootLCNeedFrameWindow"), "NeedFrameItemTemplate")
    end

    local backdrop = {
        bgFile = "Interface\\Addons\\TWLC2\\images\\need\\need_" .. quality,
        tile = false,
    };

    getglobal('LCNeedFrame' .. index .. 'BgImage'):SetBackdrop(backdrop)

    LootLCNeedFrames.itemFrames[index]:Show()
    LootLCNeedFrames.itemFrames[index]:SetAlpha(0)
    LootLCNeedFrames.itemFrames[index]:SetPoint("TOP", getglobal("LootLCNeedFrameWindow"), "TOP", 0, (80 * index))
    LootLCNeedFrames.itemFrames[index].link = link

    --todo minimap dropdown, option to show loot anchor, to move

    getglobal('LCNeedFrame' .. index .. 'ItemIcon'):SetNormalTexture(texture);
    getglobal('LCNeedFrame' .. index .. 'ItemIcon'):SetPushedTexture(texture);
    getglobal('LCNeedFrame' .. index .. 'ItemIconItemName'):SetText(link);

    getglobal('LCNeedFrame' .. index .. 'BISButton'):SetID(index);
    getglobal('LCNeedFrame' .. index .. 'MSUpgradeButton'):SetID(index);
    getglobal('LCNeedFrame' .. index .. 'OSButton'):SetID(index);
    getglobal('LCNeedFrame' .. index .. 'PassButton'):SetID(index);

    local r, g, b = GetItemQualityColor(quality)

    getglobal('LCNeedFrame' .. index .. 'TimeLeftBar'):SetBackdropColor(r, g, b, .76)

    addOnEnterTooltipNeedFrame(getglobal('LCNeedFrame' .. index .. 'ItemIcon'), link)

    fadeInFrame(index)
    --    CalcMainWindowHeight()
    --    getglobal('LootLCNeedFrameWindow'):Show()
end

function PlayerNeedItemButton_OnClick(id, need)

    local myItem1 = "0"
    local myItem2 = "0"

    local _, _, itemLink = string.find(LootLCNeedFrames.itemFrames[id].link, "(item:%d+:%d+:%d+:%d+)");
    local name, link, quality, reqlvl, t1, t2, a7, equip_slot, tex = GetItemInfo(itemLink)
    if equip_slot then
        -- twdebug('player need equip_slot frame : ' .. equip_slot)
    else
        twdebug(' nu am gasit item slot wtffff : ' .. itemLink)
    end

    if (need ~= 'pass') then
        for i = 1, 19 do
            if GetInventoryItemLink('player', i) then
                local _, _, itemID = string.find(GetInventoryItemLink('player', i), "item:(%d+):%d+:%d+:%d+")
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', i), "(item:%d+:%d+:%d+:%d+)");

                local _, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(eqItemLink)

                if (itemSlot) then
                    if (equip_slot == itemSlot) then
                        if (myItem1 == "0") then
                            myItem1 = eqItemLink
                        else
                            myItem2 = eqItemLink
                        end
                    end
                else
                    twdebug(' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! itemslot ')
                end
            end
        end
    end

    SendAddonMessage("TWLCNF", need .. "=" .. id .. "=" .. myItem1 .. "=" .. myItem2, "RAID")

    fadeOutFrame(id)

    --    groupNeedFrames()
    --    CalcMainWindowHeight()
end

function fadeInFrame(id)
    fadeInAnimationFrame.ids[id] = true
    fadeInAnimationFrame:Show()
end

function fadeOutFrame(id)
    fadeOutAnimationFrame.ids[id] = true
    fadeOutAnimationFrame:Show()
end

fadeInAnimationFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

fadeOutAnimationFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

fadeInAnimationFrame:SetScript("OnUpdate", function()
    if ((GetTime()) >= (this.startTime) + 0.03) then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeInAnimationFrame.ids do
            if fadeInAnimationFrame.ids[id] then
                atLeastOne = true
                local frame = getglobal("LCNeedFrame" .. id)
                if (frame:GetAlpha() < 1) then
                    frame:SetAlpha(frame:GetAlpha() + 0.2)
                else
                    fadeInAnimationFrame.ids[id] = false
                    fadeInAnimationFrame.ids[id] = nil

                end
                return
            end
        end
        if (not atLeastOne) then
            fadeInAnimationFrame:Hide()
        end
    end
end)

fadeOutAnimationFrame:SetScript("OnUpdate", function()
    if ((GetTime()) >= (this.startTime) + 0.03) then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeOutAnimationFrame.ids do
            if fadeOutAnimationFrame.ids[id] then
                atLeastOne = true
                local frame = getglobal("LCNeedFrame" .. id)
                if (frame:GetAlpha() > 0) then
                    frame:SetAlpha(frame:GetAlpha() - 0.15)
                else
                    fadeOutAnimationFrame.ids[id] = false
                    fadeOutAnimationFrame.ids[id] = nil
                    frame:Hide()
                end
            end
        end
        if (not atLeastOne) then
            fadeOutAnimationFrame:Hide()
        end
    end
end)

function groupNeedFrames()
    local visibleFrames = 0;
    for i = 1, table.getn(LootLCNeedFrames.itemFrames), 1 do
        if (LootLCNeedFrames.itemFrames[i]) then
            if LootLCNeedFrames.itemFrames[i]:IsVisible() then
                visibleFrames = visibleFrames + 1
                LootLCNeedFrames.itemFrames[i]:SetPoint("TOP", getglobal("LootLCNeedFrameWindow"), "TOP", 0, 0 - (55 * visibleFrames))
            end
        end
    end
end

function CalcMainWindowHeight()
    local framesNo = 0
    for index, fr in next, LootLCNeedFrames.itemFrames do
        if (LootLCNeedFrames.itemFrames[index]) then
            if (LootLCNeedFrames.itemFrames[index]:IsVisible()) then
                framesNo = framesNo + 1
            end
        end
    end
    getglobal('LootLCNeedFrameWindow'):SetHeight(55 + 55 * framesNo)

    if (framesNo == 0) then
        getglobal('LootLCNeedFrameWindow'):Hide()
    end
end

function LootLCNeedFrame.ResetVars()
    twdebug('Need reset')
    for index, frame in next, LootLCNeedFrames.itemFrames do
        LootLCNeedFrames.itemFrames[index]:Hide()
    end
    --    CalcMainWindowHeight()
    getglobal('LootLCNeedFrameWindow'):Hide()
    LootLCCountdown.T = 1
end

-- comms

NeedFrameComms:SetScript("OnEvent", function()
    --TWLCNF
    if (event) then
        if (event == 'CHAT_MSG_ADDON' and arg1 == 'TWLCNF') then

            if (twlc2isRL(arg4)) then

                if (string.find(arg2, 'loot=', 1, true)) then
                    LootLCNeedFrames.addItem(arg2)
                    if (not getglobal('LootLCNeedFrameWindow'):IsVisible()) then
                        getglobal('LootLCNeedFrameWindow'):Show()
                        LootLCCountdown:Show()
                    end
                end

                if (string.find(arg2, 'needframe=', 1, true)) then
                    local command = string.split(arg2, '=')
                    if (command[2] == "reset") then
                        LootLCNeedFrame.ResetVars()
                    end
                end
            end
        end
    end
end)

function NFIT_DragStart()
    getglobal('LootLCNeedFrameWindow'):StartMoving();
    getglobal('LootLCNeedFrameWindow').isMoving = true;
end

function NFIT_DragEnd()
    getglobal('LootLCNeedFrameWindow'):StopMovingOrSizing();
    getglobal('LootLCNeedFrameWindow').isMoving = false;
end

-- utils

function addOnEnterTooltipNeedFrame(frame, itemLink)
    local ex = string.split(itemLink, "|")

    if (not ex[3]) then return end

    frame:SetScript("OnEnter", function(self)
        LCTooltipNeedFrame:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
        LCTooltipNeedFrame:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
        LCTooltipNeedFrame:Show();
    end)
    frame:SetScript("OnLeave", function(self)
        LCTooltipNeedFrame:Hide();
    end)
end
