local lco = CreateFrame("Frame")
local me = UnitName('player')

lco.enabled = false
lco.targetNameEnable = 'Loatheb'
--lco.debuffIcon = 'Interface\\Icons\\Spell_Holy_AshesToAshes' --
lco.debuffIcon = 'Interface\\Icons\\Spell_Shadow_AuraOfDarkness'

lco.casterFrames = {}
lco.healCooldown = 60

local _, class = UnitClass('player')
class = string.lower(class)

local cooldownFrame = CreateFrame("Frame")
cooldownFrame:Hide()

function lcoprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2cLCO] |cffffffff" .. a)
end

lco:RegisterEvent("ADDON_LOADED")
lco:RegisterEvent("CHAT_MSG_ADDON")
lco:RegisterEvent("PLAYER_TARGET_CHANGED")
--lco:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

local classColors = {
    ["warrior"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
    ["mage"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
    ["rogue"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
    ["druid"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
    ["hunter"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
    ["shaman"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
    ["priest"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
    ["warlock"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
    ["paladin"] = { r = 0.96, g = 0.55, b = 0.73, c = "|cfff58cba" }
}

lco.healers = {}
lco.bossDied = false

lco:SetScript("OnEvent", function()
    if event then
        if event == "ADDON_LOADED" and arg1 == 'TWLC2c' then

            if lco.twlc2isRL(me) then
                getglobal('LCOAddHealer'):Show()
                getglobal('LCOResetHealers'):Show()
                getglobal('LCOSyncHealers'):Show()
            else
                getglobal('LCOAddHealer'):Hide()
                getglobal('LCOResetHealers'):Hide()
                getglobal('LCOSyncHealers'):Hide()
            end

        end

        if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
            if arg1 == lco.targetNameEnable .. " dies." then
                if lco.twlc2isRL(me) then
                    SendAddonMessage("TWLClco", "lcoCast=disable", "RAID")
                end
            end
        end

        if event == "PLAYER_TARGET_CHANGED" then
            if UnitName('target') == lco.targetNameEnable then
                if lco.twlc2isRL(me) then
                    SendAddonMessage("TWLClco", "lcoCast=enable", "RAID")
                end
            end
        end

        if event == 'CHAT_MSG_ADDON' and arg1 == 'TWLClco' then

            local sender = arg4
            local t = arg2

            if not string.find(t, 'lcoCooldown', 1, true) then
                --lcoprint('recv ' .. t .. ' ' .. sender)
            end

            if t == "lcoCast=enable" then
                if not lco.enabled then
                    lco.enabled = true
                end

                if lco.twlc2isRL(me) then
                    lco.show()
                    lco.init()
                    --lcoprint('enabled')
                    cooldownFrame:Show()
                end
                return true
            end

            if t == "lcoCast=disable" then
                lco.enabled = false
                cooldownFrame:Hide()
            end


            if string.find(t, "lcoCooldown=", 1, true) then
                local ex = string.split(t, "=")
                for index, f in next, lco.casterFrames do
                    if f.name == sender then
                        f.cooldown = math.floor(tonumber(ex[2]))
                    end
                end
                lco.updateCooldowns()
            end

            if string.find(t, 'rotSync=reset') then
                lco.healers = {}

                getglobal('LCO'):Hide()

                --lcoprint('Healer list reset.')
                getglobal('LCONextHealer'):SetText('Next: _')
                for index in next, lco.casterFrames do
                    lco.casterFrames[index]:Hide()
                end
                getglobal('LCO'):SetHeight(table.getn(lco.healers) * 21 + 57)
                if sender ~= me then

                end
            elseif string.find(t, 'rotSync=start') then
                if sender ~= me then
                    lco.healers = {}
                end
            elseif string.find(t, 'rotSync=end') then
                if sender ~= me then

                    for i, healer in next, lco.healers do
                        if healer.name == me then

                            lco.enabled = true
                            lco.init()
                            lco.show()
                            cooldownFrame:Show()

                            break

                        end
                    end

                end
            elseif string.find(t, 'rotSync=') then
                if sender ~= me then
                    local ex = string.split(t, '=')
                    lco.healers[tonumber(ex[2])] = {
                        name = ex[3],
                        class = ex[4]
                    }
                end

            end

        end
    end
end)

function lco.init()

    for index in next, lco.casterFrames do
        lco.casterFrames[index]:Hide()
    end

    for index, healer in next, lco.healers do

        if not lco.casterFrames[index] then
            lco.casterFrames[index] = CreateFrame('Frame', 'LCOCaster' .. index, getglobal("LCO"), 'LCOCaster')
        end

        local itemOffset = 1

        lco.casterFrames[index]:SetPoint("TOPLEFT", getglobal("LCO"), "TOPLEFT", 2, -21 * (index - itemOffset) - 55)
        lco.casterFrames[index]:Show()
        lco.casterFrames[index].cooldown = 0
        lco.casterFrames[index].name = healer.name
        lco.casterFrames[index].class = healer.class

        if healer.name == me then
            getglobal("LCOCaster" .. index .. 'PlayerName'):SetText(classColors[healer.class].c .. healer.name .. ' ' .. classColors['priest'].c .. ' (YOU)')
        else
            getglobal("LCOCaster" .. index .. 'PlayerName'):SetText(classColors[healer.class].c .. healer.name)
        end

        getglobal("LCOCaster" .. index):SetBackdropColor(classColors[healer.class].r, classColors[healer.class].g, classColors[healer.class].b)

    end

    getglobal('LCO'):SetHeight(table.getn(lco.healers) * 21 + 57)

    lco.updateCooldowns()

end

function lco.updateCooldowns()
    for i, f in next, lco.casterFrames do
        if f.cooldown == 0 then
            getglobal("LCOCaster" .. i .. 'Cooldown'):SetText(classColors['hunter'].c .. 'READY')
            getglobal("LCOCaster" .. i):SetBackdropColor(classColors[f.class].r, classColors[f.class].g, classColors[f.class].b, 1)
        elseif f.cooldown == 100 then
            getglobal("LCOCaster" .. i .. 'Cooldown'):SetText(classColors['warrior'].c .. 'DEAD')
            getglobal("LCOCaster" .. i):SetBackdropColor(classColors[f.class].r, classColors[f.class].g, classColors[f.class].b, 0)
        else
            getglobal("LCOCaster" .. i .. 'Cooldown'):SetText(f.cooldown)
            getglobal("LCOCaster" .. i):SetBackdropColor(classColors[f.class].r, classColors[f.class].g, classColors[f.class].b, 1 - f.cooldown / lco.healCooldown)
        end
    end
end

function lco.updateNext()

    local minCooldown = lco.healCooldown + 1
    local nextHealer = ''
    local nextHealerClass = ''
    local you = '(YOU)'

    if table.getn(lco.healers) > 0 then
        for i, f in next, lco.casterFrames do
            if f.cooldown == 0 or f.cooldown == 60 and f:IsVisible() then
                if f.name ~= me then
                    you = ''
                end
                getglobal('LCONextHealer'):SetText('Next: ' .. classColors[f.class].c .. f.name .. you)
                return true
            end
            if f.cooldown < minCooldown then
                minCooldown = f.cooldown
                nextHealer = f.name
                nextHealerClass = f.class
            end
        end
    end

    if nextHealer ~= '' then
        if nextHealer ~= me then
            you = ''
        end
        getglobal('LCONextHealer'):SetText('Next: ' .. classColors[nextHealerClass].c .. nextHealer .. you)
        return true
    end

    getglobal('LCONextHealer'):SetText('Next: Panik!!')

end

function ResetHealers_OnClick()
    if lco.twlc2isRL(me) then
        SendAddonMessage("TWLClco", "rotSync=reset", "RAID")
    end
end

function AddHealer_OnClick()

    if not UnitIsPlayer('target') then
        lcoprint('Target is not a player.')
        return false
    end

    local name = UnitName('target')

    for _, healer in next, lco.healers do
        if healer.name == name then
            lcoprint('Healer ' .. name .. ' already exists.')
            return false
        end
    end

    local _, c = UnitClass('target')
    local halerClass = string.lower(c)

    lco.healers[table.getn(lco.healers) + 1] = {
        name = name,
        class = halerClass
    }

    SendAddonMessage("TWLClco", "rotSync=start", "RAID")
    for i, healer in next, lco.healers do
        SendAddonMessage("TWLClco", "rotSync=" .. i .. "=" .. healer.name .. "=" .. healer.class, "RAID")
    end
    SendAddonMessage("TWLClco", "rotSync=end", "RAID")
    lco.init()
end

function SyncData_OnClick()
    SendAddonMessage("TWLClco", "rotSync=start", "RAID")
    for i, healer in next, lco.healers do
        SendAddonMessage("TWLClco", "rotSync=" .. i .. "=" .. healer.name .. "=" .. healer.class, "RAID")
    end
    SendAddonMessage("TWLClco", "rotSync=end", "RAID")
end

cooldownFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

cooldownFrame:SetScript("OnHide", function()
end)

cooldownFrame:SetScript("OnUpdate", function()

    if lco.enabled then

        if GetTime() >= this.startTime + 0.5 then

            this.startTime = GetTime()

            local debuffTimeLeft = 0

            if UnitIsDead('player') then
                debuffTimeLeft = 100 --dead
            else
                for i = 0, 31 do
                    local id = GetPlayerBuff(i, "HARMFUL")
                    if id > -1 then
                        local timeleft = GetPlayerBuffTimeLeft(id)
                        local texture = GetPlayerBuffTexture(GetPlayerBuff(i, "HARMFUL"))
                        if texture == lco.debuffIcon then
                            debuffTimeLeft = timeleft
                        end
                    end
                end
            end

            SendAddonMessage("TWLClco", "lcoCooldown=" .. debuffTimeLeft, "RAID")

            lco.updateNext()

        end

    end
end)

function lco.show()
    getglobal('LCO'):Show()
    if lco.twlc2isRL(me) then
        getglobal('LCOAddHealer'):Show()
        getglobal('LCOResetHealers'):Show()
        getglobal('LCOSyncHealers'):Show()
    else
        getglobal('LCOAddHealer'):Hide()
        getglobal('LCOResetHealers'):Hide()
        getglobal('LCOSyncHealers'):Hide()
    end
end

-- /lco set 1 Er
SLASH_LCO1 = "/lco"
SlashCmdList["LCO"] = function(cmd)
    if cmd then
        if string.find(cmd, 'show', 1, true) then
            lco.show()
        end
        if string.find(cmd, 'hide', 1, true) then
            getglobal('LCO'):Hide()
        end
    end

end

function lco.twlc2isRL(name)
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
