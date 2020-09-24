local addonVer = "1.0.2.6"

function pfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function pfdebug(a)
    wfprint('|cff0070de[PullFrame :' .. time() .. '] |cffffffff[' .. a .. ']')
end

local PullFrame = CreateFrame("Frame")
PullFrame:RegisterEvent("CHAT_MSG_ADDON")
PullFrame:RegisterEvent("CHAT_MSG_RAID")
PullFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
PullFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
PullFrame:RegisterEvent("ADDON_LOADED")
PullFrame:Hide()

PullFrame.started = false;

PullFrame:SetScript("OnEvent", function()
    if (event) then
        if (event == "ADDON_LOADED" and arg1 == 'TWLC2c') then
            if TWLC_PULL == nil then
                TWLC_PULL = true
            end
            if TWLC_PULL_SOUND == nil then
                TWLC_PULL_SOUND = true
            end

            if TWLC_PULL then
                wfprint('TWLC2c PullFrame (v' .. addonVer .. ') Loaded and Enabled. Type |cfffff569/tw|cff69ccf0pull |cffffffffto toggle pull frame.')
            else
                wfprint('TWLC2c PullFrame (v' .. addonVer .. ') Loaded and Disabled. Type |cfffff569/tw|cff69ccf0pull |cffffffffto toggle pull frame.')
            end

            if TWLC_PULL_SOUND then
                wfprint('Pull Sound is Enabled. Type |cfffff569/tw|cff69ccf0pull|cfffff569sound |cffffffffto toggle pull sound on or off.')
            else
                wfprint('Pull Sound is Disabled. Type |cfffff569/tw|cff69ccf0win|cfffff569sound |cffffffffto toggle win sound on or off.')
            end
        end

        if event == "CHAT_MSG_ADDON" then
            if arg1 == 'BigWigs' and string.find(string.lower(arg2), 'pull') and TWLC_PULL then
                if not PullFrame.started and pullframeIsAssistOrRL(arg4) then
                    local bwEx = string.split(arg2, ' ')
                    PullFrame.started = true
                    start_pull_countdown(tonumber(bwEx[2]))
                end
            end
        end
        if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_WARNING" or event == "CHAT_MSG_RAID_LEADER" then
            if string.find(string.lower(arg1), 'pulling in ') and TWLC_PULL then
                if not PullFrame.started and pullframeIsAssistOrRL(arg2) then
                    local bwEx = string.split(arg1, ' ')
                    local exEx = string.split(bwEx[3], '!')
                    if tonumber(exEx[1]) then
                        PullFrame.started = true
                        start_pull_countdown(tonumber(exEx[1]))
                    end
                end
            end
        end
    end
end)

PullFrame.countFrom = 6
PullFrame.start = 0

function start_pull_countdown(x)
    PullFrame.bwTimerDuration = x
    PullFrame.countFrom = x
    getglobal('PullFrameNumbers'):SetTexture('Interface\\addons\\TWLC2c\\images\\pull\\5.blp')
    PullFrame.start = GetTime()
    PullFrame:Show();
end

PullFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

PullFrame.lastNumer = 0

PullFrame:SetScript("OnUpdate", function()

    local plus = 0.01

    local gt = GetTime() * 1000 --22.123 -> 22123
    local st = (this.startTime + plus) * 1000 -- (22.123 + 0.1) * 1000 =  22.223 * 1000 = 22223
    if gt >= st then

        PullFrame:Show()
        PullFrame.countFrom = PullFrame.bwTimerDuration - (PullFrame.start - GetTime()) * -1

        if (math.floor(PullFrame.countFrom) >= 0 and math.floor(PullFrame.countFrom) <= 5) then

            getglobal('PullFrame'):Show()

            if (PullFrame.countFrom - math.floor(PullFrame.countFrom) >= 0.5) then
                getglobal('PullFrame'):SetScale(PullFrame.countFrom - math.floor(PullFrame.countFrom))
            end

            if (math.floor(PullFrame.countFrom) == 0) then
                if (PullFrame.countFrom - math.floor(PullFrame.countFrom) < 0.5) then
                    getglobal('PullFrame'):SetScale(1 - PullFrame.countFrom - math.floor(PullFrame.countFrom))
                end
            end

            if (math.floor(PullFrame.countFrom) >= 0 and math.floor(PullFrame.countFrom) <= (PullFrame.bwTimerDuration - 1)) then
                getglobal('PullFrameNumbers'):SetTexture('Interface\\addons\\TWLC2c\\images\\pull\\' .. math.floor(PullFrame.countFrom) .. '.blp')
                if PullFrame.lastNumber ~= math.floor(PullFrame.countFrom) then
                    if TWLC_PULL_SOUND then
                        PlaySoundFile("Interface\\AddOns\\TWLC2c\\sound\\tick.ogg");
                    end
                    PullFrame.lastNumber = math.floor(PullFrame.countFrom)
                end
            else
                PullFrame:Hide()
                getglobal('PullFrame'):Hide()
            end
        end
    end
    if PullFrame.countFrom < 0 then
        PullFrame:Hide()
        getglobal('PullFrame'):Hide()
        PullFrame.started = false
    end
end)

SLASH_TWPULL1 = "/twpull"
SlashCmdList["TWPULL"] = function(cmd)
    if (cmd) then
        TWLC_PULL = not TWLC_PULL
        if TWLC_PULL then
            wfprint('TWLC2c PullFrame Enabled. Type |cfffff569/tw|cff69ccf0pull |cffffffffto toggle pull frame.')
        else
            wfprint('TWLC2c PullFrame Disabled. Type |cfffff569/tw|cff69ccf0pull |cffffffffto toggle pull frame.')
        end
    end
end

SLASH_TWPULLSOUND1 = "/twpullsound"
SlashCmdList["TWPULLSOUND"] = function(cmd)
    if (cmd) then
        TWLC_PULL_SOUND = not TWLC_PULL_SOUND
        if TWLC_PULL_SOUND then
            wfprint('Pull Sound is Enabled. Type |cfffff569/tw|cff69ccf0pull|cfffff569sound |cffffffffto toggle pull sound on or off.')
        else
            wfprint('Pull Sound is Disabled. Type |cfffff569/tw|cff69ccf0win|cfffff569sound |cffffffffto toggle win sound on or off.')
        end
    end
end

function pullframeIsAssistOrRL(name)
    if not UnitInRaid('player') then return false end
    for i = 0, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local n, r = GetRaidRosterInfo(i);
            if n == name and (r == 1 or r == 2) then
                return true
            end
        end
    end
    return false
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
