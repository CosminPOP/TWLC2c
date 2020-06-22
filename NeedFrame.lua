local addonVer = "1.0.0"
local me = UnitName('player')

function nfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function nfdebug(a)
    if (me == 'Er2' or
            me == 'Xerrbear' or
            me == 'Testwarr' or
            me == 'Kzkts1t' or
            me == 'Tabc') then
        nfprint('|cff0070de[Needframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local NeedFrameCountdown = CreateFrame("Frame")

local NeedFrame = CreateFrame("Frame")
NeedFrame:RegisterEvent("ADDON_LOADED")
NeedFrame:SetScript("OnEvent", function()
    if (event) then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            NeedFrame:HideAnchor()
            wfprint('TWLC2c NeedFrame (v' .. addonVer .. ') Loaded. Type |cfffff569/tw|cff69ccf0need |cffffffffto show the Anchor window.')
        end
    end
end)

local NeedFrameComms = CreateFrame("Frame")
NeedFrameComms:RegisterEvent("CHAT_MSG_ADDON")

NeedFrameCountdown:Hide()
NeedFrameCountdown.timeToNeed = 30 --default, will be gotted via addonMessage

NeedFrameCountdown.T = 1
NeedFrameCountdown.C = NeedFrameCountdown.timeToNeed


local NeedFrames = CreateFrame("Frame")
NeedFrames.itemFrames = {}
NeedFrames.execs = 0

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
                nfprint('delay  add item on update')
                NeedFrames.addItem(data)
                delayAddItem.data[id] = nil
            end
        end

        if not atLeastOne then
            delayAddItem:Hide()
        end
    end
end)

NeedFrameCountdown:SetScript("OnShow", function()
    --    nfdebug('NEEDFRAME NeedFrameCountdown.timeToNeed = ' .. NeedFrameCountdown.timeToNeed)
    this.startTime = GetTime();
end)

NeedFrameCountdown:SetScript("OnUpdate", function()
    local plus = 0.03
    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then
        if (NeedFrameCountdown.T ~= NeedFrameCountdown.timeToNeed + plus) then

            for index in next, NeedFrames.itemFrames do
                if (math.floor(NeedFrameCountdown.C - NeedFrameCountdown.T + plus) < 0) then
                    getglobal('NeedFrame' .. index .. 'TimeLeftBarText'):SetText("CLOSED")
                else
                    getglobal('NeedFrame' .. index .. 'TimeLeftBarText'):SetText(math.ceil(NeedFrameCountdown.C - NeedFrameCountdown.T + plus) .. "s")
                end

                getglobal('NeedFrame' .. index .. 'TimeLeftBar'):SetWidth((NeedFrameCountdown.C - NeedFrameCountdown.T + plus) * 190 / NeedFrameCountdown.timeToNeed)
            end
        end
        NeedFrameCountdown:Hide()
        if (NeedFrameCountdown.T < NeedFrameCountdown.C + plus) then
            --still tick
            NeedFrameCountdown.T = NeedFrameCountdown.T + plus
            NeedFrameCountdown:Show()
        elseif (NeedFrameCountdown.T > NeedFrameCountdown.timeToNeed + plus) then

            -- hide frames and send auto pass
            for index in next, NeedFrames.itemFrames do
                if (NeedFrames.itemFrames[index]:IsVisible()) then
                    PlayerNeedItemButton_OnClick(index, 'autopass')
                end
            end
            -- end hide frames

            NeedFrameCountdown:Hide()
            NeedFrameCountdown.T = 1

        else
            --
        end
    else
        --
    end
end)

function NeedFrames.addItem(data)
    local item = string.split(data, "=")

    nfdebug('additem call with : ' .. data)

    NeedFrameCountdown.timeToNeed = tonumber(item[6])
    NeedFrameCountdown.C = NeedFrameCountdown.timeToNeed

    NeedFrames.execs = NeedFrames.execs + 1

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

    NeedFrames.execs = 0

    SendAddonMessage("TWLCNF", "wait=" .. index .. "=0=0", "RAID")

    if (not NeedFrames.itemFrames[index]) then
        nfdebug('should createframe')
        NeedFrames.itemFrames[index] = CreateFrame("Frame", "NeedFrame" .. index, getglobal("NeedFrame"), "NeedFrameItemTemplate")
    end

    nfdebug('additem call index : ' .. index)

    local backdrop = {
        bgFile = "Interface\\Addons\\TWLC2c\\images\\need\\need_" .. quality,
        tile = false,
    };

    getglobal('NeedFrame' .. index .. 'BgImage'):SetBackdrop(backdrop)

    NeedFrames.itemFrames[index]:Show()
    NeedFrames.itemFrames[index]:SetAlpha(1)

    if (NeedFrames.itemFrames[index]:IsVisible()) then
        nfdebug('visible and alpha = ' .. NeedFrames.itemFrames[index]:GetAlpha())
    end

    NeedFrames.itemFrames[index]:ClearAllPoints()
    NeedFrames.itemFrames[index]:SetPoint("TOP", getglobal("NeedFrame"), "TOP", 0, 20 + (80 * index))
    NeedFrames.itemFrames[index].link = link

    nfdebug('additem call backdrop : ' .. getglobal('NeedFrame' .. index .. 'BgImage'):GetBackdrop().bgFile)
    nfdebug('additem call link : ' .. link)
    nfdebug('additem call texture : ' .. texture)

    getglobal('NeedFrame' .. index .. 'ItemIcon'):SetNormalTexture(texture);
    getglobal('NeedFrame' .. index .. 'ItemIcon'):SetPushedTexture(texture);
    getglobal('NeedFrame' .. index .. 'ItemIconItemName'):SetText(link);

    getglobal('NeedFrame' .. index .. 'BISButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'MSUpgradeButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'OSButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'PassButton'):SetID(index);

    local r, g, b = GetItemQualityColor(quality)

    getglobal('NeedFrame' .. index .. 'TimeLeftBar'):SetBackdropColor(r, g, b, .76)

    --    addOnEnterTooltipNeedFrame(getglobal('NeedFrame' .. index .. 'ItemIcon'), link)


    --    fadeInFrame(index)
end

function PlayerNeedItemButton_OnClick(id, need)

    local myItem1 = "0"
    local myItem2 = "0"

    local _, _, itemLink = string.find(NeedFrames.itemFrames[id].link, "(item:%d+:%d+:%d+:%d+)");
    local name, link, quality, reqlvl, t1, t2, a7, equip_slot, tex = GetItemInfo(itemLink)
    if equip_slot then
        -- nfdebug('player need equip_slot frame : ' .. equip_slot)
    else
        nfdebug(' nu am gasit item slot wtffff : ' .. itemLink)
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
                    nfdebug(' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! itemslot ')
                end
            end
        end
    end

    SendAddonMessage("TWLCNF", need .. "=" .. id .. "=" .. myItem1 .. "=" .. myItem2, "RAID")

    fadeOutFrame(id)
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
                local frame = getglobal("NeedFrame" .. id)
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
                local frame = getglobal("NeedFrame" .. id)
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

function NeedFrame.ResetVars()
    nfdebug('Need reset')
    for index, frame in next, NeedFrames.itemFrames do
        NeedFrames.itemFrames[index]:Hide()
    end

    getglobal('NeedFrame'):Hide()
    NeedFrameCountdown.T = 1
end

-- comms

NeedFrameComms:SetScript("OnEvent", function()
    --TWLCNF
    if (event) then
        if (event == 'CHAT_MSG_ADDON' and arg1 == 'TWLCNF') then

            if (NeedFrame:twlc2isRL(arg4)) then

                if (string.find(arg2, 'loot=', 1, true)) then
                    NeedFrames.addItem(arg2)
                    if (not getglobal('NeedFrame'):IsVisible()) then
                        getglobal('NeedFrame'):Show()
                        NeedFrameCountdown:Show()
                    end
                end

                if (string.find(arg2, 'needframe=', 1, true)) then
                    local command = string.split(arg2, '=')
                    if (command[2] == "reset") then
                        NeedFrame.ResetVars()
                    end
                end
            end
        end
    end
end)

function NFIT_DragStart()
    getglobal('NeedFrame'):StartMoving();
    getglobal('NeedFrame').isMoving = true;
end

function NFIT_DragEnd()
    getglobal('NeedFrame'):StopMovingOrSizing();
    getglobal('NeedFrame').isMoving = false;
end


function NeedFrame:ShowAnchor()
    getglobal('NeedFrame'):SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
    })
    getglobal('NeedFrame'):EnableMouse(true)
    getglobal('NeedFrameTitle'):Show()
    getglobal('NeedFrameTestPlacement'):Show()
    getglobal('NeedFrameClosePlacement'):Show()
end

function NeedFrame:HideAnchor()
    getglobal('NeedFrame'):SetBackdrop({
        bgFile = "",
        tile = true,
    })
    getglobal('NeedFrame'):EnableMouse(false)
    getglobal('NeedFrameTitle'):Hide()
    getglobal('NeedFrameTestPlacement'):Hide()
    getglobal('NeedFrameClosePlacement'):Hide()
end

function need_frame_close()
    wfprint('Anchor window closed. Type |cfffff569/tw|cff69ccf0need |cffffffffto show the Anchor window.')
    NeedFrame:HideAnchor()
end

function need_frame_test()

    local linkString = '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r'
    local _, _, itemLink = string.find(linkString, "(item:%d+:%d+:%d+:%d+)");
    local name, il, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    --    SendAddonMessage("TWLCNF", "loot=" .. id .. "=" .. lootIcon .. "=" .. lootName .. "=" .. GetLootSlotLink(id) .. "=" .. TWLCCountDownFRAME.countDownFrom, "RAID")
    NeedFrames.addItem('loot=1=' .. tex .. '=' .. name .. '=' .. linkString .. '=30')
    if (not getglobal('NeedFrame'):IsVisible()) then
        getglobal('NeedFrame'):Show()
        NeedFrameCountdown:Show()
    end
end

SLASH_TWNEED1 = "/twneed"
SlashCmdList["TWNEED"] = function(cmd)
    if (cmd) then
        NeedFrame:ShowAnchor()
    end
end

-- utils

function NeedFrame:twlc2isRL(name)
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

function addOnEnterTooltipNeedFrame(frame, itemLink)
    local ex = string.split(itemLink, "|")

    if (not ex[3]) then return end

    frame:SetScript("OnEnter", function(self)
        NeedFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
        NeedFrameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
        NeedFrameTooltip:Show();
    end)
    frame:SetScript("OnLeave", function(self)
        NeedFrameTooltip:Hide();
    end)
end
