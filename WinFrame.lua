local addonVer = "1.0.3.0"
local me = UnitName('player')
local xmog = false

function wfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function wfdebug(a)
    if me == 'Er' or me == 'Kzktst' then --dev
        wfprint('|cff0070de[Winframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local WinAnimFrame = CreateFrame("Frame")
WinAnimFrame:RegisterEvent("CHAT_MSG_ADDON")
WinAnimFrame:RegisterEvent("CHAT_MSG_LOOT")
WinAnimFrame:RegisterEvent("ADDON_LOADED")
WinAnimFrame:Hide()
WinAnimFrame.wonItems = {}
WinAnimFrame:SetScript("OnEvent", function()
    if (event) then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            WinAnimFrame:HideAnchor()
            if not TWLC_LOOT_THRESHOLD then TWLC_LOOT_THRESHOLD = 3 end
            if TWLC_LOOT_ENABLE_SOUND == nil then TWLC_LOOT_ENABLE_SOUND = true end
            if not TWLC_WIN_VOLUME then TWLC_WIN_VOLUME = 'high' end
            local text = ''
            local qualities = {
                [0] = 'Poor',
                [1] = 'Common',
                [2] = 'Uncommon',
                [3] = 'Rare',
                [4] = 'Epic',
                [5] = 'Legendary'
            }
            for i = TWLC_LOOT_THRESHOLD, 5 do
                local _, _, _, color = GetItemQualityColor(i)
                text = text .. color .. qualities[i] .. ' '
            end
            wfprint('TWLC2c WinFrame (v' .. addonVer .. ') Loaded. Type |cfffff569/tw|cff69ccf0win |cffffffffto show the Anchor window.')
            wfprint('Type |cfffff569/tw|cff69ccf0win <0-5> |cffffffffto change loot window threshold '
                    .. '( current threshhold set at ' .. TWLC_LOOT_THRESHOLD .. ' : ' .. text .. '|cffffffff).')
            if TWLC_LOOT_ENABLE_SOUND then
                wfprint('Win Sound is Enabled(' .. TWLC_WIN_VOLUME .. '). Type |cfffff569/tw|cff69ccf0win|cfffff569sound |cffffffffto toggle win sound on or off.')
            else
                wfprint('Win Sound is Disabled. Type |cfffff569/tw|cff69ccf0win|cfffff569sound |cffffffffto toggle win sound on or off.')
            end
        end
        if (event == "CHAT_MSG_LOOT") then
            --receive
            --eng
            if (string.find(arg1, 'You receive loot', 1, true)) then
                local recEx = string.split(arg1, 'loot: ')
                if (recEx[1]) then
                    addWonItem(recEx[2], recEx[1] .. 'loot:')
                end
            end
            --ger
            if (string.find(arg1, 'Ihr erhaltet Beute:', 1, true)) then
                local recEx = string.split(arg1, 'Beute: ')
                if (recEx[1]) then
                    addWonItem(recEx[2], recEx[1] .. 'Beute:')
                end
            end
            --create
            --eng
            if (string.find(arg1, 'You create', 1, true)) then
                local recEx = string.split(arg1, 'create: ')
                if (recEx[1]) then
                    addWonItem(recEx[2], recEx[1] .. 'create:')
                end
            end
            --ger
            if (string.find(arg1, 'Ihr stellt her', 1, true)) then
                local recEx = string.split(arg1, 'stellt her: ')
                if (recEx[1]) then
                    addWonItem(recEx[2], recEx[1] .. 'stellt her:')
                end
            end
        end
        if (event == "CHAT_MSG_ADDON") then
            if (arg1 == "TWLCNF") then
                --disabled in TWLC2
                if (string.find(arg2, 'youWon=')) then
                    local winEx = string.split(arg2, '=')
                    if (winEx[1] and winEx[2] and winEx[3]) then
                        if (winEx[2] == UnitName('player')) then
                            addWonItem(winEx[3], 'You Won!')
                        end
                    end
                end
            end
            if arg1 == 'TWLC2' then
                if string.find(arg2, 'playerWon#') then
                    local wonData = string.split(arg2, "#")
                    if wonData[5] then
                        if wonData[5] == 'xmog' and wonData[2] == me then
                            xmog = true
                        else
                            xmog = false
                        end
                    end
                end
            end
        end
    end
end)


local delayAddWonItem = CreateFrame("Frame")
delayAddWonItem:Hide()
delayAddWonItem.data = {}

delayAddWonItem:SetScript("OnShow", function()
    this.startTime = GetTime();
end)
delayAddWonItem:SetScript("OnUpdate", function()
    local plus = 0.2
    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then

        local atLeastOne = false
        for id, data in next, delayAddWonItem.data do
            if delayAddWonItem.data[id] then
                atLeastOne = true
                addWonItem(id, data)
                delayAddWonItem.data[id] = nil
            end
        end

        if not atLeastOne then
            delayAddWonItem:Hide()
        end
    end
end)


function addWonItem(linkString, winText)

    local _, _, itemLink = string.find(linkString, "(item:%d+:%d+:%d+:%d+)");

    GameTooltip:SetHyperlink(itemLink)
    GameTooltip:Hide()

    local name, _, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)

    if (not name or not quality) then
        delayAddWonItem.data[linkString] = winText
        delayAddWonItem:Show()
        return false
    end

    if quality < TWLC_LOOT_THRESHOLD then
        return false
    end

    local _, _, _, color = GetItemQualityColor(quality)

    local wonIndex = 0
    for i = 1, table.getn(WinAnimFrame.wonItems), 1 do
        if (not WinAnimFrame.wonItems[i].active) then
            wonIndex = i
            break
        end
    end

    if wonIndex == 0 then
        wonIndex = table.getn(WinAnimFrame.wonItems) + 1
    end


    if (not WinAnimFrame.wonItems[wonIndex]) then
        WinAnimFrame.wonItems[wonIndex] = CreateFrame("Frame", "WinFrame" .. wonIndex, getglobal("WinFrame"), "WonItemTemplate")
    end

    WinAnimFrame.wonItems[wonIndex]:SetPoint("TOP", getglobal("WinFrame"), "TOP", 0, (20 + 100 * wonIndex))
    WinAnimFrame.wonItems[wonIndex].active = true
    WinAnimFrame.wonItems[wonIndex].quality = quality
    WinAnimFrame.wonItems[wonIndex].frameIndex = 0
    WinAnimFrame.wonItems[wonIndex].doAnim = true
    WinAnimFrame.wonItems[wonIndex].xmog = xmog
    xmog = false

    WinAnimFrame.wonItems[wonIndex]:SetAlpha(0)
    WinAnimFrame.wonItems[wonIndex]:Show()


    getglobal('WinFrame' .. wonIndex .. 'Icon'):SetNormalTexture(tex)
    getglobal('WinFrame' .. wonIndex .. 'Icon'):SetPushedTexture(tex)
    getglobal('WinFrame' .. wonIndex .. 'ItemName'):SetText(color .. name)
    getglobal('WinFrame' .. wonIndex .. 'Title'):SetText(winText)
    local ex = string.split(linkString, "|")

    if ex[3] then
        getglobal('WinFrame' .. wonIndex .. 'Icon'):SetScript("OnEnter", function(self)
            LCTooltipWinFrame:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
            LCTooltipWinFrame:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
            LCTooltipWinFrame:Show();
        end)
        getglobal('WinFrame' .. wonIndex .. 'Icon'):SetScript("OnLeave", function(self)
            LCTooltipWinFrame:Hide();
        end)
    else
        wfdebug('wrong itemlink ?')
    end

    start_anim()
end

function test_win_frame()
    --    addWonItem('|cffff8000|Hitem:12583:0:0:0:::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r', 'You Won ! (test message)')
    addWonItem('|cffa335ee|Hitem:19364:0:0:0:0:0:0:0:0|h[Ashkandi, Greatsword of the Brotherhood]|h|r', 'You Won ! (test message)')
end

function start_anim()
    if TWLC_LOOT_ENABLE_SOUND then
        PlaySoundFile("Interface\\AddOns\\TWLC2c\\sound\\win_" .. TWLC_WIN_VOLUME .. ".ogg");
    end
    if (table.getn(WinAnimFrame.wonItems) > 0) then
        WinAnimFrame.showLootWindow = true
    end
    if (not WinAnimFrame:IsVisible()) then
        WinAnimFrame:Show()
    end
end

WinAnimFrame.showLootWindow = false

WinAnimFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)
WinAnimFrame:SetScript("OnUpdate", function()
    if (WinAnimFrame.showLootWindow) then
        if ((GetTime()) >= (this.startTime) + 0.03) then

            this.startTime = GetTime()

            for i, d in next, WinAnimFrame.wonItems do

                if (WinAnimFrame.wonItems[i].active) then

                    local frame = getglobal('WinFrame' .. i)

                    local quality = WinAnimFrame.wonItems[i].quality

                    local image = 'loot_frame_' .. quality .. '_'

                    if (quality < 3) then
                        image = 'loot_frame_012_'
                    end

                    if (quality >= 3) then
                        image = 'loot_frame_345_'
                    end

                    if WinAnimFrame.wonItems[i].xmog then
                        image = 'loot_frame_xmog_'
                        getglobal('WinFrame' .. i .. 'Title'):Hide()
                        getglobal('WinFrame' .. i .. 'QualityBorder'):Hide()
                        getglobal('WinFrame' .. i .. 'Icon'):SetPoint('LEFT', 160, -9)
                        getglobal('WinFrame' .. i .. 'Icon'):SetWidth(36)
                        getglobal('WinFrame' .. i .. 'IconNormalTexture'):SetWidth(36)
                        getglobal('WinFrame' .. i .. 'Icon'):SetHeight(36)
                        getglobal('WinFrame' .. i .. 'IconNormalTexture'):SetHeight(36)

                    else
                        getglobal('WinFrame' .. i .. 'Title'):Show()
                        getglobal('WinFrame' .. i .. 'QualityBorder'):Show()
                        getglobal('WinFrame' .. i .. 'Icon'):SetPoint('LEFT', 148, 0)
                        getglobal('WinFrame' .. i .. 'Icon'):SetWidth(46)
                        getglobal('WinFrame' .. i .. 'IconNormalTexture'):SetWidth(46)
                        getglobal('WinFrame' .. i .. 'Icon'):SetHeight(46)
                        getglobal('WinFrame' .. i .. 'IconNormalTexture'):SetHeight(46)
                    end

                    if WinAnimFrame.wonItems[i].frameIndex < 10 then
                        image = image .. '0' .. WinAnimFrame.wonItems[i].frameIndex
                    else
                        image = image .. WinAnimFrame.wonItems[i].frameIndex;
                    end

                    WinAnimFrame.wonItems[i].frameIndex = WinAnimFrame.wonItems[i].frameIndex + 1

                    getglobal('WinFrame' .. i .. 'QualityBorder'):SetTexture('Interface\\addons\\TWLC2c\\images\\loot\\' .. quality .. '_large')

                    if (WinAnimFrame.wonItems[i].doAnim) then

                        local backdrop = {
                            bgFile = 'Interface\\AddOns\\TWLC2c\\images\\loot\\' .. image,
                            tile = false
                        };
                        if (WinAnimFrame.wonItems[i].frameIndex <= 30) then
                            frame:SetBackdrop(backdrop)
                        end
                        frame:SetAlpha(frame:GetAlpha() + 0.03)
                        getglobal('WinFrame' .. i .. 'Icon'):SetAlpha(frame:GetAlpha() + 0.03)
                    end
                    if (WinAnimFrame.wonItems[i].frameIndex == 35) then --stop and hold last frame
                        WinAnimFrame.wonItems[i].doAnim = false
                    end

                    if (WinAnimFrame.wonItems[i].frameIndex > 119) then
                        frame:SetAlpha(frame:GetAlpha() - 0.03)
                        getglobal('WinFrame' .. i .. 'Icon'):SetAlpha(frame:GetAlpha() + 0.03)
                    end
                    if (WinAnimFrame.wonItems[i].frameIndex == 150) then

                        WinAnimFrame.wonItems[i].frameIndex = 0
                        frame:Hide()
                        WinAnimFrame.wonItems[i].active = false

                        xmog = false

                    end
                end
            end
        end
    end
end)

function close_placement()
    wfprint('Anchor window closed. Type |cfffff569/tw|cff69ccf0win |cffffffffto show the Anchor window.')
    WinAnimFrame:HideAnchor()
end

function WinAnimFrame:ShowAnchor()
    getglobal('WinFrame'):SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
    })
    getglobal('WinFrame'):EnableMouse(true)
    getglobal('WinFrameTitle'):Show()
    getglobal('WinFrameTestPlacement'):Show()
    getglobal('WinFrameClosePlacement'):Show()
end

function WinAnimFrame:HideAnchor()
    getglobal('WinFrame'):SetBackdrop({
        bgFile = "",
        tile = true,
    })
    getglobal('WinFrame'):EnableMouse(false)
    getglobal('WinFrameTitle'):Hide()
    getglobal('WinFrameTestPlacement'):Hide()
    getglobal('WinFrameClosePlacement'):Hide()
end

SLASH_TWWIN1 = "/twwin"
SLASH_TWWIN2 = "/twwinthreshold"
SlashCmdList["TWWIN"] = function(cmd)
    if (cmd) then
        if (tonumber(cmd)) then
            local newT = tonumber(cmd)
            if (newT >= 0 and newT <= 5) then
                TWLC_LOOT_THRESHOLD = newT
                local text = ''
                local qualities = {
                    [0] = 'Poor',
                    [1] = 'Common',
                    [2] = 'Uncommon',
                    [3] = 'Rare',
                    [4] = 'Epic',
                    [5] = 'Legendary'
                }
                for i = newT, 5 do
                    local _, _, _, color = GetItemQualityColor(i)
                    text = text .. color .. qualities[i] .. ' '
                end
                wfprint('Loot threshold changed to ' .. TWLC_LOOT_THRESHOLD .. ', ' .. text)
            else
                wfprint('Accepted range is |cfffff5690-5') -- |cffffffffto show the Anchor window.')
            end
        else
            WinAnimFrame:ShowAnchor()
        end
    end
end

SLASH_TWWINSOUND1 = "/twwinsound"
SlashCmdList["TWWINSOUND"] = function(cmd)
    if cmd then

        if cmd == 'high' or cmd == 'low' then
            TWLC_WIN_VOLUME = cmd
            wfprint('Win Sound Volume set to |cfffff569' .. TWLC_WIN_VOLUME)
            return true
        end

        TWLC_LOOT_ENABLE_SOUND = not TWLC_LOOT_ENABLE_SOUND
        if TWLC_LOOT_ENABLE_SOUND then
            wfprint('Win Sound Enabled')
        else
            wfprint('Win Sound Disabled')
        end
    end
end

function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end
