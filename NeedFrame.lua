local addonVer = "1.0.2.2"
local me = UnitName('player')

local equipSlots = {
    ["INVTYPE_AMMO"] = 'Ammo', --	0', --
    ["INVTYPE_HEAD"] = 'Head', --	1',
    ["INVTYPE_NECK"] = 'Neck', --	2',
    ["INVTYPE_SHOULDER"] = 'Shoulder', --	3',
    ["INVTYPE_BODY"] = 'Shirt', --	4',
    ["INVTYPE_CHEST"] = 'Chest', --	5',
    ["INVTYPE_ROBE"] = 'Chest', --	5',
    ["INVTYPE_WAIST"] = 'Waist', --	6',
    ["INVTYPE_LEGS"] = 'Legs', --	7',
    ["INVTYPE_FEET"] = 'Feet', --	8',
    ["INVTYPE_WRIST"] = 'Wrist', --	9',
    ["INVTYPE_HAND"] = 'Hands', --	10',
    ["INVTYPE_FINGER"] = 'Ring', --	11,12',
    ["INVTYPE_TRINKET"] = 'Trinket', --	13,14',
    ["INVTYPE_CLOAK"] = 'Cloak', --	15',
    ["INVTYPE_WEAPON"] = 'One-Hand', --	16,17',
    ["INVTYPE_SHIELD"] = 'Shield', --	17',
    ["INVTYPE_2HWEAPON"] = 'Two-Handed', --	16',
    ["INVTYPE_WEAPONMAINHAND"] = 'Main-Hand Weapon', --	16',
    ["INVTYPE_WEAPONOFFHAND"] = 'Off-Hand Weapon', --	17',
    ["INVTYPE_HOLDABLE"] = 'Held In Off-Hand', --	17',
    ["INVTYPE_RANGED"] = 'Ranged Slot', --'Bow', --	18',
    ["INVTYPE_THROWN"] = 'Ranged Slot', --'Ranged', --	18',
    ["INVTYPE_RANGEDRIGHT"] = 'Ranged Slot', --'Wands, Guns, and Crossbows', --	18',
    ["INVTYPE_RELIC"] = 'Ranged Slot', --'Relic', --	18',
    ["INVTYPE_TABARD"] = 'Tabard', --	19',
    ["INVTYPE_BAG"] = 'Container', --	20,21,22,23',
    ["INVTYPE_QUIVER"] = 'Quiver', --	20,21,22,23',
}

local classColors = {
    ["warrior"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
    ["mage"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
    ["rogue"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
    ["druid"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
    ["hunter"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
    ["shaman"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
    ["priest"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
    ["warlock"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
    ["paladin"] = { r = 0.96, g = 0.55, b = 0.73, c = "|cfff58cba" },
    ["krieger"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
    ["magier"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
    ["schurke"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
    ["druide"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
    ["jäger"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
    ["schamane"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
    ["priester"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
    ["hexenmeister"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
}

function nfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function nfdebug(a)
    if me == 'Earis' or
            me == 'Xerrbear' or
            me == 'Kzktst' or
            me == 'Hpriesttest' or
            me == 'Rake' then
        nfprint('|cff0070de[Needframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local NeedFrameCountdown = CreateFrame("Frame")

local NeedFrame = CreateFrame("Frame")
NeedFrame:RegisterEvent("ADDON_LOADED")
--NeedFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
NeedFrame:SetScript("OnEvent", function()
    if event then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            NeedFrame:HideAnchor()
            nfprint('TWLC2c NeedFrame (v' .. addonVer .. ') Loaded. Type |cfffff569/tw|cff69ccf0need |cffffffffto show the Anchor window.')
            if not TWLC_NEED_SCALE then TWLC_NEED_SCALE = 1 end
            getglobal('NeedFrame'):SetScale(TWLC_NEED_SCALE)
            NeedFrame.ResetVars()
        end
        --        if event == 'PLAYER_TARGET_CHANGED' then
        --            if UnitName('target') == 'Kzktst' or UnitName('target') == 'Er' then
        --                getglobal('TargetFrameTexture'):SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Elite')
        --            end
        --        end
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
    local plus = 0.5
    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then

        local atLeastOne = false
        for id, data in next, delayAddItem.data do
            if delayAddItem.data[id] then
                atLeastOne = true
                nfdebug('delay add item on update for item id ' .. id .. ' data:[' .. data)
                delayAddItem.data[id] = nil
                NeedFrames.addItem(data)
            end
        end

        if not atLeastOne then
            delayAddItem:Hide()
        end
    end
end)

NeedFrameCountdown:SetScript("OnShow", function()
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
                if (NeedFrames.itemFrames[index]:GetAlpha() == 1) then
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

function NeedFrames.cacheItem(data)
    local item = string.split(data, "=")

    local index = tonumber(item[2])
    local texture = item[3]
    local name = item[4]
    local link = item[5]

    local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");

    GameTooltip:SetHyperlink(itemLink)
    GameTooltip:Hide()

    local name, _, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if (not name or not quality) then
        nfdebug('item ' .. data .. ' not cached yet ')
        return false
    end
end

function NeedFrames.addItem(data)
    local item = string.split(data, "=")

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

    if (index > 0) then --test frame position
        SendAddonMessage("TWLCNF", "wait=" .. index .. "=0=0=0", "RAID")
    end

    if (not NeedFrames.itemFrames[index]) then
        NeedFrames.itemFrames[index] = CreateFrame("Frame", "NeedFrame" .. index, getglobal("NeedFrame"), "NeedFrameItemTemplate")
    end

    local backdrop = {
        bgFile = "Interface\\Addons\\TWLC2c\\images\\need\\need_" .. quality,
        tile = false,
    };

    getglobal('NeedFrame' .. index .. 'BgImage'):SetBackdrop(backdrop)

    NeedFrames.itemFrames[index]:Show()
    NeedFrames.itemFrames[index]:SetAlpha(0)

    NeedFrames.itemFrames[index]:ClearAllPoints()
    if index < 0 then --test items
        NeedFrames.itemFrames[index]:SetPoint("TOP", getglobal("NeedFrame"), "TOP", 0, 20 + (80 * index * -1))
    else
        NeedFrames.itemFrames[index]:SetPoint("TOP", getglobal("NeedFrame"), "TOP", 0, 20 + (80 * index))
    end
    NeedFrames.itemFrames[index].link = link

    getglobal('NeedFrame' .. index .. 'ItemIcon'):SetNormalTexture(texture);
    getglobal('NeedFrame' .. index .. 'ItemIcon'):SetPushedTexture(texture);
    getglobal('NeedFrame' .. index .. 'ItemIconItemName'):SetText(link);

    getglobal('NeedFrame' .. index .. 'BISButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'MSUpgradeButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'OSButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'PassButton'):SetID(index);

    local r, g, b = GetItemQualityColor(quality)

    getglobal('NeedFrame' .. index .. 'TimeLeftBar'):SetBackdropColor(r, g, b, .76)

    addOnEnterTooltipNeedFrame(getglobal('NeedFrame' .. index .. 'ItemIcon'), link)

    fadeInFrame(index)
end

function PlayerNeedItemButton_OnClick(id, need)

    if id < 0 then fadeOutFrame(id) return end --test items

    local myItem1 = "0"
    local myItem2 = "0"
    local myItem3 = "0"

    local _, _, itemLink = string.find(NeedFrames.itemFrames[id].link, "(item:%d+:%d+:%d+:%d+)");
    local name, link, quality, reqlvl, t1, t2, a7, equip_slot, tex = GetItemInfo(itemLink)
    if equip_slot then
        -- nfdebug('player need equip_slot frame : ' .. equip_slot)
    else
        nfdebug(' nu am gasit item slot wtffff : ' .. itemLink)
    end

    if need ~= 'pass' and need ~= 'autopass' then
        for i = 1, 19 do
            if GetInventoryItemLink('player', i) then
                local _, _, itemID = string.find(GetInventoryItemLink('player', i), "item:(%d+):%d+:%d+:%d+")
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', i), "(item:%d+:%d+:%d+:%d+)");
                local _, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(eqItemLink)

                if (itemSlot) then
                    if (equipSlots[equip_slot] == equipSlots[itemSlot]) then
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



        --mh/oh fix
        if (equip_slot == 'INVTYPE_WEAPON' or equip_slot == 'INVTYPE_SHIELD' or equip_slot == 'INVTYPE_WEAPONMAINHAND'
                or equip_slot == 'INVTYPE_WEAPONOFFHAND' or equip_slot == 'INVTYPE_HOLDABLE' or equip_slot == 'INVTYPE_2HWEAPON') then
            if GetInventoryItemLink('player', 16) then
                local _, _, itemID = string.find(GetInventoryItemLink('player', 16), "item:(%d+):%d+:%d+:%d+")
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 16), "(item:%d+:%d+:%d+:%d+)");

                myItem1 = eqItemLink
            end
            --ranged/relic weapon fix
            if GetInventoryItemLink('player', 17) then
                local _, _, itemID = string.find(GetInventoryItemLink('player', 17), "item:(%d+):%d+:%d+:%d+")
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 17), "(item:%d+:%d+:%d+:%d+)");

                myItem2 = eqItemLink
            end
        end

        --Head of Onyxia - melee/hunter neck, bad caster ring, tank trinket
        if name == 'Head of Onyxia' then
            local role = getRole()
            if role == 'healer' or role == 'casterdps' then --rings
                if GetInventoryItemLink('player', 11) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 11), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 12), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
            end
            if role == 'meleedps' or role == 'rangeddps' then --neck
                if GetInventoryItemLink('player', 2) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 2), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem1 = eqItemLink
                end
            end
            if role == 'tank' then --trinket
                if GetInventoryItemLink('player', 13) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 13), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 13), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 14) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 14), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 14), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
                if GetInventoryItemLink('player', 2) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 2), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem3 = eqItemLink
                end
            end
        end
        --Head of Nefarian - tank neck, melee hunter ring, caster/healer offhand
        if name == 'Head of Nefarian' then
            local role = getRole()
            if role == 'healer' or role == 'casterdps' then --offhand
                if GetInventoryItemLink('player', 17) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 17), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 17), "(item:%d+:%d+:%d+:%d+)");

                    myItem1 = eqItemLink
                end
            end
            if role == 'meleedps' or role == 'rangeddps' then --rings
                if GetInventoryItemLink('player', 11) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 11), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 12), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
            end
            if role == 'tank' then --neck
                if GetInventoryItemLink('player', 2) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 2), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 11) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 11), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, itemID = string.find(GetInventoryItemLink('player', 12), "item:(%d+):%d+:%d+:%d+")
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem3 = eqItemLink
                end
            end
        end

        --Head of Ossirian the Unscarred - necks
        if name == 'Head of Ossirian the Unscarred' then
            if GetInventoryItemLink('player', 2) then
                local _, _, itemID = string.find(GetInventoryItemLink('player', 2), "item:(%d+):%d+:%d+:%d+")
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                myItem1 = eqItemLink
            end
        end
    end

    SendAddonMessage("TWLCNF", need .. "=" .. id .. "=" .. myItem1 .. "=" .. myItem2 .. "=" .. myItem3, "RAID")

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

    for index, frame in next, NeedFrames.itemFrames do
        NeedFrames.itemFrames[index]:Hide()
    end

    getglobal('NeedFrame'):Hide()

    NeedFrameCountdown:Hide()
    NeedFrameCountdown.T = 1
end

-- comms

NeedFrameComms:SetScript("OnEvent", function()
    --TWLCNF
    if event then
        if event == 'CHAT_MSG_ADDON' and arg1 == 'TWLCNF' then

            local sender = arg4
            local t = arg2

            if string.find(arg2, 'withAddonNF=', 1, true) then
                local i = string.split(arg2, "=")
                if (i[2] == me) then --i[2] = who requested the who
                    if (i[4]) then
                        local verColor = ""
                        if (nf_ver(i[4]) == nf_ver(addonVer)) then verColor = classColors['hunter'].c end
                        if (nf_ver(i[4]) < nf_ver(addonVer)) then verColor = '|cffff1111' end
                        if (nf_ver(i[4]) + 1 == nf_ver(addonVer)) then verColor = '|cffff8810' end

                        if string.len(i[4]) < 7 then i[4] = '0.' .. i[4] end

                        NeedFrame.withAddon[arg4]['v'] = verColor .. i[4]

                        NeedFrame.withAddonCount = NeedFrame.withAddonCount + 1
                        NeedFrame.withoutAddonCount = NeedFrame.withoutAddonCount - 1
                        updateWithAddon()
                    end
                end
            end
            if string.find(arg2, 'needframe=', 1, true) then
                local command = string.split(arg2, '=')
                if (command[2] == "whoNF") then
                    SendAddonMessage("TWLCNF", "withAddonNF=" .. arg4 .. "=" .. me .. "=" .. addonVer, "RAID")
                end
                if (command[2] == "OnyCloakQuery") then

                    if GetInventoryItemLink('player', 15) then
                        local _, _, itemID = string.find(GetInventoryItemLink('player', 15), "item:(%d+):%d+:%d+:%d+")
                        local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 15), "(item:%d+:%d+:%d+:%d+)");
                        local itemName, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(eqItemLink)

                        if itemID ~= '15138' then
                            SendAddonMessage("TWLCNF", "OnyCloakQuery=not_equipped", "RAID")
                        else
                            SendAddonMessage("TWLCNF", "OnyCloakQuery=equipped", "RAID")
                        end

                    else
                        SendAddonMessage("TWLCNF", "OnyCloakQuery=none", "RAID")
                    end
                end
            end
            if string.find(arg2, 'OnyCloakQuery=', 1, true) then
                if arg2 == 'OnyCloakQuery=not_equipped' or arg2 == 'OnyCloakQuery=none' then
                    NeedFrame.withoutCloak = NeedFrame.withoutCloak + 1
                    table.insert(NeedFrame.playersWithoutCloak, arg4)
                end
                if arg2 == 'OnyCloakQuery=equipped' then
                    NeedFrame.withCloak = NeedFrame.withCloak + 1
                end
            end

            if NeedFrame:twlc2isRL(arg4) then
                if string.find(arg2, 'loot=', 1, true) then
                    NeedFrames.addItem(arg2)
                    if (not getglobal('NeedFrame'):IsVisible()) then
                        getglobal('NeedFrame'):Show()
                        NeedFrameCountdown:Show()
                    end
                end

                if string.find(arg2, 'preSend=', 1, true) then
                    NeedFrames.cacheItem(arg2)
                end

                if string.find(arg2, 'doneSending=', 1, true) then
                    local nrItems = string.split(arg2, '=')
                    if not nrItems[2] or not nrItems[3] then
                        nfdebug('wrong doneSending syntax')
                        nfdebug(arg2)
                        return false
                    end

                    SendAddonMessage("TWLCNF", "received=" .. table.getn(NeedFrames.itemFrames) .. "=items", "RAID")
                end

                if string.find(arg2, 'needframe=', 1, true) then
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
    getglobal('NeedFrame'):Show()
    getglobal('NeedFrame'):EnableMouse(true)
    getglobal('NeedFrameTitle'):Show()
    getglobal('NeedFrameTestPlacement'):Show()
    getglobal('NeedFrameClosePlacement'):Show()
    getglobal('NeedFrameBackground'):Show()
    getglobal('NeedFrameScaleDown'):Show()
    getglobal('NeedFrameScaleUp'):Show()
    getglobal('NeedFrameScaleText'):Show()
end

function NeedFrame:HideAnchor()
    getglobal('NeedFrame'):Hide()
    getglobal('NeedFrame'):EnableMouse(false)
    getglobal('NeedFrameTitle'):Hide()
    getglobal('NeedFrameTestPlacement'):Hide()
    getglobal('NeedFrameClosePlacement'):Hide()
    getglobal('NeedFrameBackground'):Hide()
    getglobal('NeedFrameScaleDown'):Hide()
    getglobal('NeedFrameScaleUp'):Hide()
    getglobal('NeedFrameScaleText'):Hide()
end

function NeedFrame_Scale(dir)
    if dir == 'up' then
        if getglobal('NeedFrame'):GetScale() < 1.4 then
            getglobal('NeedFrame'):SetScale(getglobal('NeedFrame'):GetScale() + 0.05)
        end
    end
    if dir == 'down' then
        if getglobal('NeedFrame'):GetScale() > 0.4 then
            getglobal('NeedFrame'):SetScale(getglobal('NeedFrame'):GetScale() - 0.05)
        end
    end

    TWLC_NEED_SCALE = getglobal('NeedFrame'):GetScale()

    nfprint('Frame re-scaled. Type |cfffff569/tw|cff69ccf0need resetscale |cffffffffif the frame is offscreen')
end

function need_frame_close()
    nfprint('Anchor window closed. Type |cfffff569/tw|cff69ccf0need |cffffffffto show the Anchor window.')
    NeedFrame:HideAnchor()
end

function need_frame_test()

    local linkStrings = {
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r',
        '|cffff8000|Hitem:19019:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r'
    }

    for i = 1, 7 do
        local _, _, itemLink = string.find(linkStrings[i], "(item:%d+:%d+:%d+:%d+)");
        local name, il, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

        if (name and tex) then
            NeedFrames.addItem('loot=-' .. i .. '=' .. tex .. '=' .. name .. '=' .. linkStrings[i] .. '=60')
            if (not getglobal('NeedFrame'):IsVisible()) then
                getglobal('NeedFrame'):Show()
                NeedFrameCountdown:Show()
            end
        else
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Hide()
        end
    end
end

NeedFrame.withAddon = {}
NeedFrame.withAddonCount = 0
NeedFrame.withoutAddonCount = 0

NeedFrame.withCloak = 0
NeedFrame.withoutCloak = 0
NeedFrame.playersWithoutCloak = {}

SLASH_TWNEED1 = "/twneed"
SlashCmdList["TWNEED"] = function(cmd)
    if (cmd) then
        if string.find(cmd, 'onycloak') then

            if not UnitInRaid('player') then
                nfprint('You are not in a raid.')
                return false
            end

            twprint('Sending out Ony Cloak Check... Type |cfffff569/twneed onyreport |cffffffff to see results.')
            queryOnyCloak()
        elseif string.find(cmd, 'onyreport') then
            local players = ''
            if NeedFrame.withoutCloak > 0 then
                for _, n in next, NeedFrame.playersWithoutCloak do
                    players = players .. n .. ' '
                end
                twprint('Without Onyxia Scale Cloak : ' .. NeedFrame.withoutCloak .. ' (' .. players .. ')')
            else
                twprint('Everyone has Onyixia Scale Cloak on.')
            end
        elseif string.find(cmd, 'resetscale') then

            getglobal('NeedFrame'):SetScale(1)
            getglobal('NeedFrame'):ClearAllPoints()
            getglobal('NeedFrame'):SetPoint("CENTER", getglobal("UIParent"), "CENTER", 0, 100)
            nfprint('Frame scale reset to 1x.')
            TWLC_NEED_SCALE = 1

        elseif string.find(cmd, 'who') then

            if not UnitInRaid('player') then
                nfprint('You are not in a raid.')
                return false
            end

            queryWho()

        else
            NeedFrame:ShowAnchor()
        end
    end
end

function queryWho()
    NeedFrame.withAddon = {}
    NeedFrame.withAddonCount = 0
    NeedFrame.withoutAddonCount = 0

    getglobal('NeedFrameListTitle'):SetText('NeedFrame v' .. addonVer)

    getglobal('NeedFrameList'):Show()

    ChatThrottleLib:SendAddonMessage("NORMAL", "TWLCNF", "needframe=whoNF=" .. addonVer, "RAID")

    local i
    for i = 0, GetNumRaidMembers() do
        if (GetRaidRosterInfo(i)) then
            local n, _, _, _, _, _, z = GetRaidRosterInfo(i);
            local _, class = UnitClass('raid' .. i)

            NeedFrame.withAddon[n] = {
                ['class'] = string.lower(class),
                ['v'] = '|cff888888   -   '
            }
            if z == 'Offline' then
                NeedFrame.withAddon[n]['v'] = '|cffff0000offline'
            else
                NeedFrame.withoutAddonCount = NeedFrame.withoutAddonCount + 1
            end
        end
    end

    updateWithAddon()
end

function queryOnyCloak()
    NeedFrame.withCloak = 0
    NeedFrame.withoutCloak = 0
    NeedFrame.playersWithoutCloak = {}

    ChatThrottleLib:SendAddonMessage("NORMAL", "TWLCNF", "needframe=OnyCloakQuery", "RAID")
end

function announceWithoutAddon()
    local withoutAddon = ''
    for n, d in NeedFrame.withAddon do
        if string.find(d['v'], '-', 1, true) then
            withoutAddon = withoutAddon .. n .. ', '
        end
    end
    if withoutAddon ~= '' then
        SendChatMessage('Players without TWLC2c addon: ' .. withoutAddon, "RAID")
        SendChatMessage('Please check discord #annoucements or #bwl channel or go to https://github.com/CosminPOP/TWLC2c', "RAID")
    end
end

function hideNeedFrameList()
    getglobal('NeedFrameList'):Hide()
end

function getRole()
    --roles: meleedps, rangeddps, casterdps, tank, healer
    local _, class = UnitClass('player')
    class = string.lower(class)
    if class == 'warlock' or class == 'mage' then return 'casterdps' end
    if class == 'hunter' then return 'rangeddps' end
    if class == 'rogue' then return 'meleedps' end

    if class == 'paladin' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Illumination" then return 'healer' end
            if spellName == "Blessing of Sanctuary" then return 'tank' end
            if spellName == "Vengeance" then return 'meleedps' end
        end
        return 'meleedps'
    end

    if class == 'druid' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Moonkin Form" then return 'casterdps' end
            if spellName == "Faerie Fire (Feral)" then return 'tank' end
            if spellName == "Nature's Swiftness" then return 'healer' end
        end
        return 'meleedps'
    end

    if class == 'warrior' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Last Stand" then return 'tank' end
        end
        return 'meleedps'
    end

    if class == 'priest' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Mind Flay" then return 'casterdps' end
        end
        return 'healer'
    end

    if class == 'shaman' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if class == 'shaman' and spellName == "Elemental Mastery" then return 'casterdps' end
            if class == 'shaman' and spellName == "Stormstrike" then return 'meleedps' end
        end
        return 'healer'
    end

    return false
end

-- utils

function updateWithAddon()
    local rosterList = ''
    local i = 0
    for n, data in next, NeedFrame.withAddon do
        i = i + 1
        rosterList = rosterList .. classColors[data['class']].c .. n .. string.rep(' ', 12 - string.len(n)) .. ' ' .. data['v'] .. ' |cff888888| '
        if i == 3 then
            rosterList = rosterList .. '\n'
            i = 0
        end
    end
    getglobal('NeedFrameListText'):SetText(rosterList)
    getglobal('NeedFrameListWith'):SetText('With addon: ' .. NeedFrame.withAddonCount)
    getglobal('NeedFrameListWithout'):SetText('Without addon: ' .. NeedFrame.withoutAddonCount)
end

function nf_ver(ver)
    if string.sub(ver, 7, 7) == '' then ver = '0.' .. ver end

    return tonumber(string.sub(ver, 1, 1)) * 1000 +
            tonumber(string.sub(ver, 3, 3)) * 100 +
            tonumber(string.sub(ver, 5, 5)) * 10 +
            tonumber(string.sub(ver, 7, 7)) * 1
end

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
