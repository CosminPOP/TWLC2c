local addonVer = "1.0.3.2"
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
}

function nfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function nfdebug(a)
    if me == 'Earis' or
            me == 'Xerrbear' or
            me == 'Kzktst' or
            me == 'Holystrike' or
            me == 'Rake' then
        nfprint('|cff0070de[Needframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local NeedFrameCountdown = CreateFrame("Frame")

local NeedFrame = CreateFrame("Frame")

NeedFrame.numItems = 0

NeedFrame:RegisterEvent("ADDON_LOADED")
NeedFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
NeedFrame:SetScript("OnEvent", function()
    if event then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            NeedFrame:HideAnchor()
            nfprint('TWLC2c NeedFrame (v' .. addonVer .. ') Loaded. Type |cfffff569/tw|cff69ccf0need |cffffffffto show the Anchor window.')
            if not TWLC_NEED_SCALE then
                TWLC_NEED_SCALE = 1
            end
            getglobal('NeedFrame'):SetScale(TWLC_NEED_SCALE)
            NeedFrame.ResetVars()
        end
        if event == 'PLAYER_TARGET_CHANGED' then
            local master = 'Er'
            if me == master then
                return false
            end
            if not UnitExists('target') or UnitAffectingCombat('player') then
                return
            end
            if UnitName('target') == master and CheckInteractDistance("target", 3) then
                PlaySoundFile("Sound\\Character\\Dwarf\\DwarfVocalFemale\\DwarfFemaleHello0" .. math.random(1, 3) .. ".wav", "Dialog")
            end
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
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
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

    getglobal('NewItemTooltip' .. index):SetHyperlink(itemLink)
    getglobal('NewItemTooltip' .. index):Show()

    local name, _, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if not name or not quality then
        nfdebug('item ' .. data .. ' not cached yet ')
        return false
    else
        nfdebug('item ' .. data .. ' cached')
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

    local buttons = 'mox'
    if item[7] then
        buttons = item[7]
    end

    local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");

    GameTooltip:SetHyperlink(itemLink)
    GameTooltip:Hide()

    local name, _, quality, _, _, _, _, itemSlot, tex = GetItemInfo(itemLink)

    if not name or not quality then
        nfdebug(' name or quality not found for data :' .. data)
        nfdebug(' going to delay add item ')
        delayAddItem.data[index] = data
        delayAddItem:Show()
        return false
    end

    --hide xmog button for necks, rings, trinkets
    if itemSlot and string.find(buttons, 'x', 1, true) then
        if itemSlot == 'INVTYPE_NECK' or itemSlot == 'INVTYPE_FINGER' or itemSlot == 'INVTYPE_TRINKET' or
                itemSlot == 'INVTYPE_RELIC' then
            buttons = gsub(buttons, 'x', '')
        end
    end

    local reward1 = ''
    local reward2 = ''
    local reward3 = ''
    local reward4 = ''

    local _, class = UnitClass('player')
    class = string.lower(class)

    if name == 'Head of Nefarian' then
        reward1 = "\124cffa335ee\124Hitem:19383:0:0:0:0:0:0:0:0\124h[Master Dragonslayer's Medallion]\124h\124r"
        reward2 = "\124cffa335ee\124Hitem:19366:0:0:0:0:0:0:0:0\124h[Master Dragonslayer's Orb]\124h\124r"
        reward3 = "\124cffa335ee\124Hitem:19384:0:0:0:0:0:0:0:0\124h[Master Dragonslayer's Ring]\124h\124r"
    end

    if name == 'Head of Onyxia' then
        reward1 = "\124cffa335ee\124Hitem:18406:0:0:0:0:0:0:0:0\124h[Onyxia Blood Talisman]\124h\124r"
        reward2 = "\124cffa335ee\124Hitem:18403:0:0:0:0:0:0:0:0\124h[Dragonslayer's Signet]\124h\124r"
        reward3 = "\124cffa335ee\124Hitem:18404:0:0:0:0:0:0:0:0\124h[Onyxia Tooth Pendant]\124h\124r"
    end

    -- AQ40 epic tokens
    if name == 'Imperial Qiraji Regalia' then
        reward1 = '\124cffa335ee\124Hitem:21273:0:0:0:0:0:0:0:0\124h[Blessed Qiraji Acolyte Staff]\124h\124r'
        reward2 = '\124cffa335ee\124Hitem:21275:0:0:0:0:0:0:0:0\124h[Blessed Qiraji Augur Staff]\124h\124r'
        reward3 = '\124cffa335ee\124Hitem:21268:0:0:0:0:0:0:0:0\124h[Blessed Qiraji War Hammer]\124h\124r'
    end

    if name == 'Imperial Qiraji Armaments' then
        reward1 = '\124cffa335ee\124Hitem:21242:0:0:0:0:0:0:0:0\124h[Blessed Qiraji War Axe]\124h\124r'
        reward2 = '\124cffa335ee\124Hitem:21272:0:0:0:0:0:0:0:0\124h[Blessed Qiraji Musket]\124h\124r'
        reward3 = '\124cffa335ee\124Hitem:21244:0:0:0:0:0:0:0:0\124h[Blessed Qiraji Pugio]\124h\124r'
        reward4 = '\124cffa335ee\124Hitem:21269:0:0:0:0:0:0:0:0\124h[Blessed Qiraji Bulwark]\124h\124r'
    end

    -- TIER 2.5
    if name == 'Qiraji Bindings of Command' then
        --Warrior, Hunter, Rogue, Priest
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:21333:0:0:0:0:0:0:0:0\124h[Conqueror's Greaves]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21330:0:0:0:0:0:0:0:0\124h[Conqueror's Spaulders]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:21359:0:0:0:0:0:0:0:0\124h[Deathdealer's Boots]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21361:0:0:0:0:0:0:0:0\124h[Deathdealer's Spaulders]\124h\124r"
        end
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:21349:0:0:0:0:0:0:0:0\124h[Footwraps of the Oracle]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21350:0:0:0:0:0:0:0:0\124h[Mantle of the Oracle]\124h\124r"
        end
        if class == 'hunter' then
            reward1 = "\124cffa335ee\124Hitem:21365:0:0:0:0:0:0:0:0\124h[Striker's Footguards]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21367:0:0:0:0:0:0:0:0\124h[Striker's Pauldrons]\124h\124r"
        end
    end

    if name == 'Qiraji Bindings of Dominance' then
        --Paladin, Shaman, Mage, Warlock, Druid
        if class == 'paladin' then
            reward1 = "\124cffa335ee\124Hitem:21388:0:0:0:0:0:0:0:0\124h[Avenger's Greaves]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21391:0:0:0:0:0:0:0:0\124h[Avenger's Pauldrons]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:21338:0:0:0:0:0:0:0:0\124h[Doomcaller's Footwraps]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21335:0:0:0:0:0:0:0:0\124h[Doomcaller's Mantle]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:21344:0:0:0:0:0:0:0:0\124h[Enigma Boots]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21345:0:0:0:0:0:0:0:0\124h[Enigma Shoulderpads]\124h\124r"
        end
        if class == 'druid' then
            reward1 = "\124cffa335ee\124Hitem:21355:0:0:0:0:0:0:0:0\124h[Genesis Boots]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21354:0:0:0:0:0:0:0:0\124h[Genesis Shoulderpads]\124h\124r"
        end
        if class == 'shaman' then
            reward1 = "\124cffa335ee\124Hitem:21373:0:0:0:0:0:0:0:0\124h[Stormcaller's Footguards]\124h\124r"
            reward2 = "\124cffa335ee\124Hitem:21376:0:0:0:0:0:0:0:0\124h[Stormcaller's Pauldrons]\124h\124r"
        end
    end

    if name == "Vek'lor's Diadem" then
        --Paladin, Hunter, Rogue, Shaman, Druid
        if class == 'paladin' then
            reward1 = "\124cffa335ee\124Hitem:21387:0:0:0:0:0:0:0:0\124h[Avenger's Crown]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:21360:0:0:0:0:0:0:0:0\124h[Deathdealer's Helm]\124h\124r"
        end
        if class == 'druid' then
            reward1 = "\124cffa335ee\124Hitem:21353:0:0:0:0:0:0:0:0\124h[Genesis Helm]\124h\124r"
        end
        if class == 'shaman' then
            reward1 = "\124cffa335ee\124Hitem:21372:0:0:0:0:0:0:0:0\124h[Stormcaller's Diadem]\124h\124r"
        end
        if class == 'hunter' then
            reward1 = "\124cffa335ee\124Hitem:21366:0:0:0:0:0:0:0:0\124h[Striker's Diadem]\124h\124r"
        end
    end

    if name == "Vek'nilash's Circlet" then
        --Warrior, Priest, Mage, Warlock
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:21329:0:0:0:0:0:0:0:0\124h[Conqueror's Crown]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:21337:0:0:0:0:0:0:0:0\124h[Doomcaller's Circlet]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:21347:0:0:0:0:0:0:0:0\124h[Enigma Circlet]\124h\124r"
        end
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:21348:0:0:0:0:0:0:0:0\124h[Tiara of the Oracle]\124h\124r"
        end
    end

    if name == "Ouro's Intact Hide" then
        --Warrior, Rogue, Priest, Mage
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:21332:0:0:0:0:0:0:0:0\124h[Conqueror's Legguards]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:21362:0:0:0:0:0:0:0:0\124h[Deathdealer's Leggings]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:21346:0:0:0:0:0:0:0:0\124h[Enigma Leggings]\124h\124r"
        end
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:21352:0:0:0:0:0:0:0:0\124h[Trousers of the Oracle]\124h\124r"
        end
    end

    if name == "Skin of the Great Sandworm" then
        --Paladin, Hunter, Shaman, Warlock, Druid
        if class == 'paladin' then
            reward1 = "\124cffa335ee\124Hitem:21390:0:0:0:0:0:0:0:0\124h[Avenger's Legguards]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:21336:0:0:0:0:0:0:0:0\124h[Doomcaller's Trousers]\124h\124r"
        end
        if class == 'druid' then
            reward1 = "\124cffa335ee\124Hitem:21356:0:0:0:0:0:0:0:0\124h[Genesis Trousers]\124h\124r"
        end
        if class == 'shaman' then
            reward1 = "\124cffa335ee\124Hitem:21375:0:0:0:0:0:0:0:0\124h[Stormcaller's Leggings]\124h\124r"
        end
        if class == 'hunter' then
            reward1 = "\124cffa335ee\124Hitem:21368:0:0:0:0:0:0:0:0\124h[Striker's Leggings]\124h\124r"
        end
    end

    if name == "Carapace of the Old God" then
        --Warrior, Paladin, Hunter, Rogue, Shaman
        if class == 'paladin' then
            reward1 = "\124cffa335ee\124Hitem:21389:0:0:0:0:0:0:0:0\124h[Avenger's Breastplate]\124h\124r"
        end
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:21331:0:0:0:0:0:0:0:0\124h[Conqueror's Breastplate]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:21364:0:0:0:0:0:0:0:0\124h[Deathdealer's Vest]\124h\124r"
        end
        if class == 'shaman' then
            reward1 = "\124cffa335ee\124Hitem:21374:0:0:0:0:0:0:0:0\124h[Stormcaller's Hauberk]\124h\124r"
        end
        if class == 'hunter' then
            reward1 = "\124cffa335ee\124Hitem:21370:0:0:0:0:0:0:0:0\124h[Striker's Hauberk]\124h\124r"
        end
    end

    if name == "Husk of the Old God" then
        --Priest, Mage, Warlock, Druid
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:21334:0:0:0:0:0:0:0:0\124h[Doomcaller's Robes]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:21343:0:0:0:0:0:0:0:0\124h[Enigma Robes]\124h\124r"
        end
        if class == 'druid' then
            reward1 = "\124cffa335ee\124Hitem:21357:0:0:0:0:0:0:0:0\124h[Genesis Vest]\124h\124r"
        end
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:21351:0:0:0:0:0:0:0:0\124h[Vestments of the Oracle]\124h\124r"
        end
    end

    if name == "Eye of C'Thun" then
        reward1 = "\124cffa335ee\124Hitem:21712:0:0:0:0:0:0:0:0\124h[Amulet of the Fallen God]\124h\124r"
        reward2 = "\124cffa335ee\124Hitem:21710:0:0:0:0:0:0:0:0\124h[Cloak of the Fallen God]\124h\124r"
        reward3 = "\124cffa335ee\124Hitem:21709:0:0:0:0:0:0:0:0\124h[Ring of the Fallen God]\124h\124r"
    end

    --naxx tokens
    --bracer
    if name == "Desecrated Bindings" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22519:0:0:0:0:0:0:0:0\124h[Bindings of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22503:0:0:0:0:0:0:0:0\124h[Frostfire Bindings]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22511:0:0:0:0:0:0:0:0\124h[Plagueheart Bindings]\124h\124r"
        end
    end
    if name == "Desecrated Wristguards" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22424:0:0:0:0:0:0:0:0\124h[Redemption Wristguards]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22443:0:0:0:0:0:0:0:0\124h[Cryptstalker Wristguards]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22471:0:0:0:0:0:0:0:0\124h[Earthshatter Wristguards]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22495:0:0:0:0:0:0:0:0\124h[Dreamwalker Wristguards]\124h\124r"
        end
    end
    if name == "Desecrated Bracers" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22423:0:0:0:0:0:0:0:0\124h[Dreadnaught Bracers]\124h\124r";
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22483:0:0:0:0:0:0:0:0\124h[Bonescythe Bracers]\124h\124r";
        end
    end

    --belt
    if name == "Desecrated Belt" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22518:0:0:0:0:0:0:0:0\124h[Belt of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22502:0:0:0:0:0:0:0:0\124h[Frostfire Belt]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22510:0:0:0:0:0:0:0:0\124h[Plagueheart Belt]\124h\124r"
        end
    end
    if name == "Desecrated Girdle" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22431:0:0:0:0:0:0:0:0\124h[Redemption Girdle]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22442:0:0:0:0:0:0:0:0\124h[Cryptstalker Girdle]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22470:0:0:0:0:0:0:0:0\124h[Earthshatter Girdle]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22494:0:0:0:0:0:0:0:0\124h[Dreamwalker Girdle]\124h\124r"
        end
    end
    if name == "Desecrated Waistguard" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22422:0:0:0:0:0:0:0:0\124h[Dreadnaught Waistguard]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22482:0:0:0:0:0:0:0:0\124h[Bonescythe Waistguard]\124h\124r"
        end
    end

    --boots
    if name == "Desecrated Sandals" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22516:0:0:0:0:0:0:0:0\124h[Sandals of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22500:0:0:0:0:0:0:0:0\124h[Frostfire Sandals]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22508:0:0:0:0:0:0:0:0\124h[Plagueheart Sandals]\124h\124r"
        end
    end
    if name == "Desecrated Boots" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22430:0:0:0:0:0:0:0:0\124h[Redemption Boots]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22440:0:0:0:0:0:0:0:0\124h[Cryptstalker Boots]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22468:0:0:0:0:0:0:0:0\124h[Earthshatter Boots]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22492:0:0:0:0:0:0:0:0\124h[Dreamwalker Boots]\124h\124r"
        end
    end
    if name == "Desecrated Sabatons" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22420:0:0:0:0:0:0:0:0\124h[Dreadnaught Sabatons]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22480:0:0:0:0:0:0:0:0\124h[Bonescythe Sabatons]\124h\124r"
        end
    end

    --gloves
    if name == "Desecrated Gloves" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22517:0:0:0:0:0:0:0:0\124h[Gloves of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22501:0:0:0:0:0:0:0:0\124h[Frostfire Gloves]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22509:0:0:0:0:0:0:0:0\124h[Plagueheart Gloves]\124h\124r"
        end
    end
    if name == "Desecrated Handguards" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22426:0:0:0:0:0:0:0:0\124h[Redemption Handguards]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22441:0:0:0:0:0:0:0:0\124h[Cryptstalker Handguards]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22469:0:0:0:0:0:0:0:0\124h[Earthshatter Handguards]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22493:0:0:0:0:0:0:0:0\124h[Dreamwalker Handguards]\124h\124r"
        end
    end
    if name == "Desecrated Gauntlets" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22421:0:0:0:0:0:0:0:0\124h[Dreadnaught Gauntlets]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22481:0:0:0:0:0:0:0:0\124h[Bonescythe Gauntlets]\124h\124r"
        end
    end

    --pants
    if name == "Desecrated Leggings" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22513:0:0:0:0:0:0:0:0\124h[Leggings of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22497:0:0:0:0:0:0:0:0\124h[Frostfire Leggings]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22505:0:0:0:0:0:0:0:0\124h[Plagueheart Leggings]\124h\124r"
        end
    end
    if name == "Desecrated Legguards" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22427:0:0:0:0:0:0:0:0\124h[Redemption Legguards]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22437:0:0:0:0:0:0:0:0\124h[Cryptstalker Legguards]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22465:0:0:0:0:0:0:0:0\124h[Earthshatter Legguards]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22489:0:0:0:0:0:0:0:0\124h[Dreamwalker Legguards]\124h\124r"
        end
    end
    if name == "Desecrated Legplates" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22417:0:0:0:0:0:0:0:0\124h[Dreadnaught Legplates]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22477:0:0:0:0:0:0:0:0\124h[Bonescythe Legplates]\124h\124r"
        end
    end

    --head
    if name == "Desecrated Circlet" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22514:0:0:0:0:0:0:0:0\124h[Circlet of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22498:0:0:0:0:0:0:0:0\124h[Frostfire Circlet]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22506:0:0:0:0:0:0:0:0\124h[Plagueheart Circlet]\124h\124r"
        end
    end
    if name == "Desecrated Headpiece" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22428:0:0:0:0:0:0:0:0\124h[Redemption Headpiece]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22438:0:0:0:0:0:0:0:0\124h[Cryptstalker Headpiece]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22466:0:0:0:0:0:0:0:0\124h[Earthshatter Headpiece]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22490:0:0:0:0:0:0:0:0\124h[Dreamwalker Headpiece]\124h\124r"
        end
    end
    if name == "Desecrated Helmet" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22418:0:0:0:0:0:0:0:0\124h[Dreadnaught Helmet]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22478:0:0:0:0:0:0:0:0\124h[Bonescythe Helmet]\124h\124r"
        end
    end

    --shoulder
    if name == "Desecrated Shoulderpads" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22515:0:0:0:0:0:0:0:0\124h[Shoulderpads of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22499:0:0:0:0:0:0:0:0\124h[Frostfire Shoulderpads]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22507:0:0:0:0:0:0:0:0\124h[Plagueheart Shoulderpads]\124h\124r"
        end
    end
    if name == "Desecrated Spaulders" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22429:0:0:0:0:0:0:0:0\124h[Redemption Spaulders]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22439:0:0:0:0:0:0:0:0\124h[Cryptstalker Spaulders]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22467:0:0:0:0:0:0:0:0\124h[Earthshatter Spaulders]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22491:0:0:0:0:0:0:0:0\124h[Dreamwalker Spaulders]\124h\124r"
        end
    end
    if name == "Desecrated Pauldrons" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22419:0:0:0:0:0:0:0:0\124h[Dreadnaught Pauldrons]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22479:0:0:0:0:0:0:0:0\124h[Bonescythe Pauldrons]\124h\124r"
        end
    end

    --chest
    if name == "Desecrated Robe" then
        if class == 'priest' then
            reward1 = "\124cffa335ee\124Hitem:22512:0:0:0:0:0:0:0:0\124h[Robe of Faith]\124h\124r"
        end
        if class == 'mage' then
            reward1 = "\124cffa335ee\124Hitem:22496:0:0:0:0:0:0:0:0\124h[Frostfire Robe]\124h\124r"
        end
        if class == 'warlock' then
            reward1 = "\124cffa335ee\124Hitem:22504:0:0:0:0:0:0:0:0\124h[Plagueheart Robe]\124h\124r"
        end
    end
    if name == "Desecrated Tunic" then
        if class == "paladin" then
            reward1 = "\124cffa335ee\124Hitem:22425:0:0:0:0:0:0:0:0\124h[Redemption Tunic]\124h\124r"
        end
        if class == "hunter" then
            reward1 = "\124cffa335ee\124Hitem:22436:0:0:0:0:0:0:0:0\124h[Cryptstalker Tunic]\124h\124r"
        end
        if class == "shaman" then
            reward1 = "\124cffa335ee\124Hitem:22464:0:0:0:0:0:0:0:0\124h[Earthshatter Tunic]\124h\124r"
        end
        if class == "druid" then
            reward1 = "\124cffa335ee\124Hitem:22488:0:0:0:0:0:0:0:0\124h[Dreamwalker Tunic]\124h\124r"
        end
    end
    if name == "Desecrated Breastplate" then
        if class == 'warrior' then
            reward1 = "\124cffa335ee\124Hitem:22476:0:0:0:0:0:0:0:0\124h[Bonescythe Breastplate]\124h\124r"
        end
        if class == 'rogue' then
            reward1 = "\124cffa335ee\124Hitem:22416:0:0:0:0:0:0:0:0\124h[Dreadnaught Breastplate]\124h\124r"
        end
    end
    --end naxx tokens

    --KT item
    if name == "The Phylactery of Kel'Thuzad" then
        reward1 = "\124cffa335ee\124Hitem:23206:0:0:0:0:0:0:0:0\124h[Mark of the Champion]\124h\124r"
        reward2 = "\124cffa335ee\124Hitem:23207:0:0:0:0:0:0:0:0\124h[Mark of the Champion]\124h\124r"
    end
    --end KT item

    NeedFrames.execs = 0

    if (index > 0) then
        --test frame position
        -- disable wait=
        -- SendAddonMessage("TWLCNF", "wait=" .. index .. "=0=0=0", "RAID")
    end

    if not NeedFrames.itemFrames[index] then
        NeedFrames.itemFrames[index] = CreateFrame("Frame", "NeedFrame" .. index, getglobal("NeedFrame"), "NeedFrameItemTemplate")
    end

    getglobal("NeedFrame" .. index):Hide()

    local backdrop = {
        bgFile = "Interface\\Addons\\TWLC2c\\images\\need\\need_" .. quality,
        tile = false,
    };

    getglobal('NeedFrame' .. index .. 'BgImage'):SetBackdrop(backdrop)

    getglobal('NeedFrame' .. index .. 'QuestRewardsReward1'):Hide()
    getglobal('NeedFrame' .. index .. 'QuestRewardsReward2'):Hide()
    getglobal('NeedFrame' .. index .. 'QuestRewardsReward3'):Hide()
    getglobal('NeedFrame' .. index .. 'QuestRewardsReward4'):Hide()

    if reward1 ~= '' then
        if not SetQuestRewardLink(reward1, 1, getglobal('NeedFrame' .. index .. 'QuestRewardsReward1')) then
            nfdebug(' quest reward 1 name or quality not found for data :' .. reward1)
            nfdebug(' going to delay add item ')
            delayAddItem.data[index] = data
            delayAddItem:Show()
            return false
        end
    end
    if reward2 ~= '' then
        if not SetQuestRewardLink(reward2, 2, getglobal('NeedFrame' .. index .. 'QuestRewardsReward2')) then
            nfdebug(' quest reward 2 name or quality not found for data :' .. reward2)
            nfdebug(' going to delay add item ')
            delayAddItem.data[index] = data
            delayAddItem:Show()
            return false
        end
    end
    if reward3 ~= '' then
        if not SetQuestRewardLink(reward3, 3, getglobal('NeedFrame' .. index .. 'QuestRewardsReward3')) then
            nfdebug(' quest reward 3 name or quality not found for data :' .. reward3)
            nfdebug(' going to delay add item ')
            delayAddItem.data[index] = data
            delayAddItem:Show()
            return false
        end
    end
    if reward4 ~= '' then
        if not SetQuestRewardLink(reward4, 4, getglobal('NeedFrame' .. index .. 'QuestRewardsReward4')) then
            nfdebug(' quest reward 4 name or quality not found for data :' .. reward4)
            nfdebug(' going to delay add item ')
            delayAddItem.data[index] = data
            delayAddItem:Show()
            return false
        end
    end

    NeedFrames.itemFrames[index]:Show()
    NeedFrames.itemFrames[index]:SetAlpha(0)

    NeedFrames.itemFrames[index]:ClearAllPoints()
    if index < 0 then
        --test items
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
    getglobal('NeedFrame' .. index .. 'XMOGButton'):SetID(index);
    getglobal('NeedFrame' .. index .. 'PassButton'):SetID(index);

    local buttonIndex = -1

    getglobal('NeedFrame' .. index .. 'BISButton'):Hide()
    getglobal('NeedFrame' .. index .. 'MSUpgradeButton'):Hide()
    getglobal('NeedFrame' .. index .. 'OSButton'):Hide()
    getglobal('NeedFrame' .. index .. 'XMOGButton'):Hide()

    if string.find(buttons, 'b', 1, true) then
        buttonIndex = buttonIndex + 1
        getglobal('NeedFrame' .. index .. 'BISButton'):Show()
        getglobal('NeedFrame' .. index .. 'BISButton'):SetPoint('TOPLEFT', 318 + buttonIndex * 38, -40)
    end
    if string.find(buttons, 'm', 1, true) then
        buttonIndex = buttonIndex + 1
        getglobal('NeedFrame' .. index .. 'MSUpgradeButton'):Show()
        getglobal('NeedFrame' .. index .. 'MSUpgradeButton'):SetPoint('TOPLEFT', 318 + buttonIndex * 38, -40)
    end
    if string.find(buttons, 'o', 1, true) then
        buttonIndex = buttonIndex + 1
        getglobal('NeedFrame' .. index .. 'OSButton'):Show()
        getglobal('NeedFrame' .. index .. 'OSButton'):SetPoint('TOPLEFT', 318 + buttonIndex * 38, -40)
    end
    if string.find(buttons, 'x', 1, true) then
        buttonIndex = buttonIndex + 1
        getglobal('NeedFrame' .. index .. 'XMOGButton'):Show()
        getglobal('NeedFrame' .. index .. 'XMOGButton'):SetPoint('TOPLEFT', 318 + buttonIndex * 38, -40)
    end

    local r, g, b = GetItemQualityColor(quality)

    getglobal('NeedFrame' .. index .. 'TimeLeftBar'):SetBackdropColor(r, g, b, .76)

    addOnEnterTooltipNeedFrame(getglobal('NeedFrame' .. index .. 'ItemIcon'), link)

    getglobal('NeedFrame' .. index .. 'QuestRewards'):Hide()
    if reward1 ~= '' then
        getglobal('NeedFrame' .. index .. 'QuestRewards'):Show()
    end

    fadeInFrame(index)
end

function PlayerNeedItemButton_OnClick(id, need)

    if need == 'autopass' then
        fadeOutFrame(id)
        return false
    end

    if id < 0 then
        fadeOutFrame(id)
        return
    end --test items

    local myItem1 = "0"
    local myItem2 = "0"
    local myItem3 = "0"

    local _, _, itemLink = string.find(NeedFrames.itemFrames[id].link, "(item:%d+:%d+:%d+:%d+)");
    local name, link, quality, reqlvl, t1, t2, a7, equip_slot, tex = GetItemInfo(itemLink)
    if equip_slot then
        nfdebug('player need equip_slot frame : ' .. equip_slot)
    else
        nfdebug(' nu am gasit item slot wtffff : ' .. itemLink)

        SendAddonMessage("TWLCNF", need .. "=" .. id .. "=" .. myItem1 .. "=" .. myItem2 .. "=" .. myItem3, "RAID")
        getglobal('NewItemTooltip' .. id):Hide()
        fadeOutFrame(id)

        return false
    end

    if need ~= 'pass' and need ~= 'autopass' then
        for i = 1, 19 do
            if GetInventoryItemLink('player', i) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', i), "(item:%d+:%d+:%d+:%d+)");
                local _, _, _, _, _, _, _, itemSlot = GetItemInfo(eqItemLink)

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
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 16), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
            --ranged/relic weapon fix
            if GetInventoryItemLink('player', 17) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 17), "(item:%d+:%d+:%d+:%d+)");
                myItem2 = eqItemLink
            end
        end

        --Head of Onyxia - melee/hunter neck, bad caster ring, tank trinket
        if name == 'Head of Onyxia' then
            local role = getRole()
            if role == 'healer' or role == 'casterdps' then
                --rings
                if GetInventoryItemLink('player', 11) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
            end
            if role == 'meleedps' or role == 'rangeddps' then
                --neck
                if GetInventoryItemLink('player', 2) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem1 = eqItemLink
                end
            end
            if role == 'tank' then
                --trinket
                if GetInventoryItemLink('player', 13) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 13), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 14) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 14), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
                if GetInventoryItemLink('player', 2) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem3 = eqItemLink
                end
            end
        end
        --Head of Nefarian - tank neck, melee hunter ring, caster/healer offhand
        local role = getRole()
        if name == 'Head of Nefarian' then
            if role == 'healer' or role == 'casterdps' then
                --offhand
                if GetInventoryItemLink('player', 17) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 17), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
            end
            if role == 'meleedps' or role == 'rangeddps' then
                --rings
                if GetInventoryItemLink('player', 11) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
            end
            if role == 'tank' then
                --neck
                if GetInventoryItemLink('player', 2) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");

                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 11) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem3 = eqItemLink
                end
            end
        end

        if name == "Eye of C'Thun" then
            --neck, cloak, ring
            if role == 'healer' then
                if GetInventoryItemLink('player', 2) then
                    --neck
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 2), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 11) then
                    --ring1
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    --ring2
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem3 = eqItemLink
                end
            end

            if role == 'meleedps' or role == 'rangeddps' then

                if GetInventoryItemLink('player', 15) then
                    --cloak
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 15), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end

            end

            if role == 'casterdps' then

                if GetInventoryItemLink('player', 11) then
                    --ring1
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 11), "(item:%d+:%d+:%d+:%d+)");
                    myItem1 = eqItemLink
                end
                if GetInventoryItemLink('player', 12) then
                    --ring1
                    local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 12), "(item:%d+:%d+:%d+:%d+)");
                    myItem2 = eqItemLink
                end
            end

        end

        if name == 'Imperial Qiraji Regalia' then
            --staff/staff/mh
            if GetInventoryItemLink('player', 16) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 16), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end
        if name == 'Imperial Qiraji Armaments' then
            --axe/gun/dagger/shield
            if GetInventoryItemLink('player', 16) then
                --mh
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 16), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
            if GetInventoryItemLink('player', 18) then
                --ranged
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 18), "(item:%d+:%d+:%d+:%d+)");

                myItem2 = eqItemLink
            end
            if GetInventoryItemLink('player', 17) then
                --ranged
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 17), "(item:%d+:%d+:%d+:%d+)");
                myItem3 = eqItemLink
            end
        end

        if name == 'Qiraji Bindings of Command' or name == 'Qiraji Bindings of Dominance' then
            --boot/shoulder
            if GetInventoryItemLink('player', 8) then
                --mh
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 8), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
            if GetInventoryItemLink('player', 3) then
                --ranged
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 3), "(item:%d+:%d+:%d+:%d+)");
                myItem2 = eqItemLink
            end
        end

        if name == "Vek'lor's Diadem" or name == "Vek'nilash's Circlet" then
            --head
            if GetInventoryItemLink('player', 1) then
                --head
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 1), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        if name == "Ouro's Intact Hide" or name == "Skin of the Great Sandworm" then
            -- pants
            if GetInventoryItemLink('player', 7) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 7), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        if name == "Carapace of the Old God" or name == "Husk of the Old God" then
            if GetInventoryItemLink('player', 5) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 5), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --naxx tier tokens
        if name == "Desecrated Bindings" or name == "Desecrated Wristguards" or name == "Desecrated Bracers" then
            if GetInventoryItemLink('player', 9) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 9), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --belt
        if name == "Desecrated Belt" or name == "Desecrated Girdle" or name == "Desecrated Waistguard" then
            if GetInventoryItemLink('player', 6) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 6), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --boots
        if name == "Desecrated Sandals" or name == "Desecrated Boots" or name == "Desecrated Sabatons" then
            if GetInventoryItemLink('player', 8) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 8), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --gloves
        if name == "Desecrated Gloves" or name == "Desecrated Handguards" or name == "Desecrated Gauntlets" then
            if GetInventoryItemLink('player', 10) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 10), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --pants
        if name == "Desecrated Leggings" or name == "Desecrated Legguards" or name == "Desecrated Legplates" then
            if GetInventoryItemLink('player', 7) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 7), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --head
        if name == "Desecrated Circlet" or name == "Desecrated Headpiece" or name == "Desecrated Helmet" then
            if GetInventoryItemLink('player', 1) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 1), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --shoulder
        if name == "Desecrated Shoulderpads" or name == "Desecrated Spaulders" or name == "Desecrated Pauldrons" then
            if GetInventoryItemLink('player', 3) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 3), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end

        --chest
        if name == "Desecrated Robe" or name == "Desecrated Tunic" or name == "Desecrated Breastplate" then
            if GetInventoryItemLink('player', 5) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 5), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
        end
        --end naxx tier tokens

        -- KT item
        if name == "The Phylactery of Kel'Thuzad" then
            if GetInventoryItemLink('player', 13) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 13), "(item:%d+:%d+:%d+:%d+)");
                myItem1 = eqItemLink
            end
            if GetInventoryItemLink('player', 14) then
                local _, _, eqItemLink = string.find(GetInventoryItemLink('player', 14), "(item:%d+:%d+:%d+:%d+)");
                myItem2 = eqItemLink
            end
        end

        -- end KT item
    end

    SendAddonMessage("TWLCNF", need .. "=" .. id .. "=" .. myItem1 .. "=" .. myItem2 .. "=" .. myItem3, "RAID")
    getglobal('NewItemTooltip' .. id):Hide()
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
    if GetTime() >= this.startTime + 0.03 then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeInAnimationFrame.ids do
            if fadeInAnimationFrame.ids[id] then
                atLeastOne = true
                local frame = getglobal("NeedFrame" .. id)
                if frame:GetAlpha() < 1 then
                    frame:SetAlpha(frame:GetAlpha() + 0.1)

                    getglobal("NeedFrame" .. id .. "GlowFrame"):SetAlpha(1 - frame:GetAlpha())
                else
                    fadeInAnimationFrame.ids[id] = false
                    fadeInAnimationFrame.ids[id] = nil
                end
                return
            end
        end
        if not atLeastOne then
            fadeInAnimationFrame:Hide()
        end
    end
end)

fadeOutAnimationFrame:SetScript("OnUpdate", function()
    if GetTime() >= this.startTime + 0.03 then

        this.startTime = GetTime()

        local atLeastOne = false
        for id in next, fadeOutAnimationFrame.ids do
            if fadeOutAnimationFrame.ids[id] then
                atLeastOne = true
                local frame = getglobal("NeedFrame" .. id)
                if frame:GetAlpha() > 0 then
                    frame:SetAlpha(frame:GetAlpha() - 0.15)
                    getglobal("NeedFrame" .. id .. "GlowFrame"):SetAlpha(frame:GetAlpha() - 0.15)
                else
                    fadeOutAnimationFrame.ids[id] = false
                    fadeOutAnimationFrame.ids[id] = nil
                    frame:Hide()
                end
            end
        end
        if not atLeastOne then
            fadeOutAnimationFrame:Hide()
        end
    end
end)

function NeedFrame.ResetVars()

    for index, frame in next, NeedFrames.itemFrames do
        NeedFrames.itemFrames[index]:Hide()
    end

    NewItemTooltip1:Hide()
    NewItemTooltip2:Hide()
    NewItemTooltip3:Hide()
    NewItemTooltip4:Hide()
    NewItemTooltip5:Hide()
    NewItemTooltip6:Hide()
    NewItemTooltip7:Hide()
    NewItemTooltip8:Hide()
    NewItemTooltip9:Hide()
    NewItemTooltip10:Hide()
    NewItemTooltip11:Hide()
    NewItemTooltip12:Hide()
    NewItemTooltip13:Hide()
    NewItemTooltip14:Hide()
    NewItemTooltip15:Hide()

    getglobal('NeedFrame'):Hide()

    NeedFrameCountdown:Hide()
    NeedFrameCountdown.T = 1
    NeedFrame.numItems = 0

    --NeedFrame.ShowAnchor()
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
                if i[2] == me then
                    --i[2] = who requested the who
                    if i[4] then
                        local verColor = ""
                        if nf_ver(i[4]) == nf_ver(addonVer) then
                            verColor = classColors['hunter'].c
                        end
                        if nf_ver(i[4]) < nf_ver(addonVer) then
                            verColor = '|cffff1111'
                        end
                        if (nf_ver(i[4]) + 1 == nf_ver(addonVer)) then
                            verColor = '|cffff8810'
                        end

                        if string.len(i[4]) < 7 then
                            i[4] = '0.' .. i[4]
                        end

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
                    NeedFrame.numItems = NeedFrame.numItems + 1
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

                    SendAddonMessage("TWLCNF", "received=" .. NeedFrame.numItems .. "=items", "RAID")
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
        '\124cffa335ee\124Hitem:22369:0:0:0:0:0:0:0:0\124h[Desecrated Bindings]\124h\124r',
        '\124cffa335ee\124Hitem:22362:0:0:0:0:0:0:0:0\124h[Desecrated Wristguards]\124h\124r',
        '\124cffa335ee\124Hitem:22355:0:0:0:0:0:0:0:0\124h[Desecrated Bracers]\124h\124r',
        '\124cffa335ee\124Hitem:21221:0:0:0:0:0:0:0:0\124h[Eye of C\'Thun]\124h\124r',
        '\124cffa335ee\124Hitem:19347:0:0:0:0:0:0:0:0\124h[Claw of Chromaggus]\124h\124r',
        '\124cffa335ee\124Hitem:19375:0:0:0:0:0:0:0:0\124h[Mish\'undare, Circlet of the Mind Flayer]\124h\124r',
        '\124cffff8000\124Hitem:17204:0:0:0:0:0:0:0:0\124h[Eye of Sulfuras]\124h\124r'
    }

    for i = 1, 7 do
        local _, _, itemLink = string.find(linkStrings[i], "(item:%d+:%d+:%d+:%d+)");
        local name, il, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

        if name and tex then
            NeedFrames.addItem('loot=-' .. i .. '=' .. tex .. '=' .. name .. '=' .. linkStrings[i] .. '=60') --todo add button options
            if (not getglobal('NeedFrame'):IsVisible()) then
                getglobal('NeedFrame'):Show()
                NeedFrameCountdown:Show()
            end
        else
            nfprint('Caching items... please try again.')
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Hide()
        end
    end
end

NeedFrame.withAddon = {}
NeedFrame.withAddonCount = 0
NeedFrame.withoutAddonCount = 0
NeedFrame.olderAddonCount = 0

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
        SendChatMessage('Please check discord #annoucements channel or go to https://github.com/CosminPOP/TWLC2c (latest version v' .. addonVer .. ')', "RAID")
    end
end

function announceOlderAddon()
    local olderAddon = ''
    for n, d in NeedFrame.withAddon do
        if not string.find(d['v'], 'offline', 1, true) and not string.find(d['v'], '-', 1, true) then
            if nf_ver(string.sub(d['v'], 11, 17)) < nf_ver(addonVer) then
                olderAddon = olderAddon .. n .. ', '
            end
        end
    end
    if olderAddon ~= '' then
        SendChatMessage('Players with older versions of TWLC2c addon: ' .. olderAddon, "RAID")
        SendChatMessage('Please check discord #annoucements channel or go to https://github.com/CosminPOP/TWLC2c (latest version v' .. addonVer .. ')', "RAID")
    end
end

function hideNeedFrameList()
    getglobal('NeedFrameList'):Hide()
end

function getRole()
    --roles: meleedps, rangeddps, casterdps, tank, healer
    local _, class = UnitClass('player')
    class = string.lower(class)
    if class == 'warlock' or class == 'mage' then
        return 'casterdps'
    end
    if class == 'hunter' then
        return 'rangeddps'
    end
    if class == 'rogue' then
        return 'meleedps'
    end

    if class == 'paladin' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Illumination" then
                return 'healer'
            end
            if spellName == "Blessing of Sanctuary" then
                return 'tank'
            end
            if spellName == "Vengeance" then
                return 'meleedps'
            end
        end
        return 'meleedps'
    end

    if class == 'druid' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Moonkin Form" then
                return 'casterdps'
            end
            if spellName == "Faerie Fire (Feral)" then
                return 'tank'
            end
            if spellName == "Nature's Swiftness" then
                return 'healer'
            end
        end
        return 'meleedps'
    end

    if class == 'warrior' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Last Stand" then
                return 'tank'
            end
        end
        return 'meleedps'
    end

    if class == 'priest' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if spellName == "Mind Flay" then
                return 'casterdps'
            end
        end
        return 'healer'
    end

    if class == 'shaman' then
        for i = 1, 500 do
            local spellName = GetSpellName(i, BOOKTYPE_SPELL);
            if class == 'shaman' and spellName == "Elemental Mastery" then
                return 'casterdps'
            end
            if class == 'shaman' and spellName == "Stormstrike" then
                return 'meleedps'
            end
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
    if NeedFrame.withoutAddonCount == 0 then
        getglobal('NeedFrameListAnnounceWithoutAddon'):SetText('Notify without ' .. NeedFrame.withoutAddonCount)
        getglobal('NeedFrameListAnnounceWithoutAddon'):Disable()
    else
        getglobal('NeedFrameListAnnounceWithoutAddon'):SetText('Notify without ' .. NeedFrame.withoutAddonCount)
        getglobal('NeedFrameListAnnounceWithoutAddon'):Enable()
    end
end

function nf_ver(ver)
    if string.sub(ver, 7, 7) == '' then
        ver = '0.' .. ver
    end

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

    if not ex[3] then
        return
    end

    frame:SetScript("OnEnter", function(self)
        NeedFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
        NeedFrameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
        NeedFrameTooltip:Show();
    end)
    frame:SetScript("OnClick", function(self)
        if IsControlKeyDown() then
            DressUpItemLink(itemLink)
        end
    end)
    frame:SetScript("OnLeave", function(self)
        NeedFrameTooltip:Hide();
    end)
end

function SetQuestRewardLink(reward, index, frame)

    local _, _, itemLink = string.find(reward, "(item:%d+:%d+:%d+:%d+)");
    local _, link, _, _, _, _, _, _, tex = GetItemInfo(itemLink)
    if link then
        addButtonOnEnterTooltipRewards(frame, link)
        frame:SetNormalTexture(tex)
        frame:SetPushedTexture(tex)
        frame:Show()
        return true
    else
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Hide()
        return false
    end
end

function addButtonOnEnterTooltipRewards(frame, itemLink)

    if (string.find(itemLink, "|", 1, true)) then
        local ex = string.split(itemLink, "|")

        if not ex[2] or not ex[3] then
            twerror('bad addButtonOnEnterTooltip itemLink syntadx')
            twerror(itemLink)
            return false
        end

        frame:SetScript("OnEnter", function(self)
            NeedFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4), -(this:GetHeight() / 4));
            NeedFrameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
            NeedFrameTooltip:Show();
        end)

        frame:SetScript("OnClick", function(self)
            if IsControlKeyDown() then
                DressUpItemLink(string.sub(ex[3], 2, string.len(ex[3])))
            end
        end)

    else
        frame:SetScript("OnEnter", function(self)
            NeedFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4), -(this:GetHeight() / 4));
            NeedFrameTooltip:SetHyperlink(itemLink);
            NeedFrameTooltip:Show();
        end)
        frame:SetScript("OnClick", function(self)
            if IsControlKeyDown() then
                DressUpItemLink(itemLink)
            end
        end)
    end
    frame:SetScript("OnLeave", function(self)
        NeedFrameTooltip:Hide();
    end)
end
