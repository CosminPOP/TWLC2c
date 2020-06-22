local addonVer = "1.0.0"
local me = UnitName('player')

function wfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2] |cffffffff" .. a)
end

function wfdebug(a)
    if (me == 'Er2' or
            me == 'Xerrbear' or
            me == 'Testwarr' or
            me == 'Kzktst' or
            me == 'Tabc') then
        wfprint('|cff0070de[TWLC2Winframe :' .. time() .. '] |cffffffff[' .. a .. ']')
    end
end

local winText = 'You Won!'

local WinAnimFrame = CreateFrame("Frame")
WinAnimFrame:RegisterEvent("CHAT_MSG_ADDON")
WinAnimFrame:RegisterEvent("CHAT_MSG_LOOT")
WinAnimFrame:Hide()
WinAnimFrame.quality = 0
WinAnimFrame:SetScript("OnEvent", function()
    if (event) then
        if (event == "CHAT_MSG_LOOT") then
            --receive
            --eng
            if (string.find(arg1, 'You receive loot', 1, true)) then
                local recEx = string.split(arg1, 'loot: ')
                if (recEx[1]) then
                    winText = recEx[1] .. 'loot:'
                    wfdebug(recEx[1])
                    wfdebug(recEx[2])
                    wfdebug(winText)
                    setWonItem(recEx[2])
                    getglobal('WinFrameTitle'):SetText(winText)
                    start_anim()
                end
            end
        end
        if (event == "CHAT_MSG_ADDON") then
            if (arg1 == "TWLCNF") then
                if (string.find(arg2, 'youWon=')) then
                    local winEx = string.split(arg2, '=')
                    if (winEx[1] and winEx[2] and winEx[3]) then
                        if (winEx[2] == UnitName('player')) then

                            setWonItem(winEx[3])
                            winText = 'You Won!'
                            getglobal('WinFrameTitle').setText(winText)
                            start_anim()
                        end
                    end
                end
            end
        end
    end
end)

function setWonItem(linkString)

    local _, _, itemLink = string.find(linkString, "(item:%d+:%d+:%d+:%d+)");
    local name, _, quality, _, _, _, _, _, tex = GetItemInfo(itemLink)
    local _, _, _, color = GetItemQualityColor(quality)
    WinAnimFrame.quality = quality
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2] |cffffffff" .. arg2)
    getglobal('WinFrameIcon'):SetNormalTexture(tex)
    getglobal('WinFrameIcon'):SetPushedTexture(tex)
    getglobal('WinFrameItemName'):SetText(color .. name)

    local ex = string.split(linkString, "|")

    if ex[3] then
        getglobal('WinFrameIcon'):SetScript("OnEnter", function(self)
            LCTooltipWinFrame:SetOwner(this, "ANCHOR_RIGHT", 0, 0);
            LCTooltipWinFrame:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));
            LCTooltipWinFrame:Show();
        end)
        getglobal('WinFrameIcon'):SetScript("OnLeave", function(self)
            LCTooltipWinFrame:Hide();
        end)
    else
        wfdebug('wrong itemlink ?')
    end
end

function start_anim()
    WinAnimFrame:Hide()
    WinAnimFrame:Show()
    getglobal('WinFrame'):SetAlpha(0)
    getglobal('WinFrame'):Show()
    WinAnimFrame.doAnim = true
    WinAnimFrame.showLootWindow = true
    --    WinAnimFrame.quality = 4 --test
end

WinAnimFrame.doAnim = false
WinAnimFrame.showLootWindow = false

WinAnimFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
    this.frameIndex = 0
end)
WinAnimFrame:SetScript("OnUpdate", function()
    if (WinAnimFrame.showLootWindow) then
        if ((GetTime()) >= (this.startTime) + 0.03) then

            this.startTime = GetTime()

            local frame = getglobal('WinFrame')

            local image = 'loot_frame_' .. WinAnimFrame.quality .. '_';

            if (WinAnimFrame.quality < 3) then --dev
                image = 'loot_frame_012_';
            end

            if this.frameIndex < 10 then
                image = image .. '0' .. this.frameIndex;
            else
                image = image .. this.frameIndex;
            end

            this.frameIndex = this.frameIndex + 1

            if (WinAnimFrame.doAnim) then
                local backdrop = {
                    bgFile = 'Interface\\AddOns\\TWLC2\\images\\loot\\' .. image
                };
                if (this.frameIndex <= 30) then
                    frame:SetBackdrop(backdrop)
                end
                frame:SetAlpha(frame:GetAlpha() + 0.03)
            end
            if (this.frameIndex == 35) then --stop and hold last frame
                WinAnimFrame.doAnim = false
            end

            if (this.frameIndex > 119) then
                frame:SetAlpha(frame:GetAlpha() - 0.03)
            end
            if (this.frameIndex == 150) then
                WinAnimFrame.showLootWindow = false
                this.frameIndex = 0;
                frame:Hide()
            end
        end
    end
end)


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
