local addonVer = "1.0.2.5"

function bfprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWLC2c] |cffffffff" .. a)
end

function bfdebug(a)
    wfprint('|cff0070de[BossFrame :' .. time() .. '] |cffffffff[' .. a .. ']')
end

local BossFrame = CreateFrame("Frame")

BossFrame.Bosses = {
    --    Ragefire Chasm – 13-18
    'Taragaman the Hungerer', 'Oggleflint', 'Bazzalan', 'Jergosh the Invoker',

    --Wailing Caverns – 17-24
    'Kresh', 'Skum', 'Lady Anacondra', 'Lord Cobrahn', 'Lord Pythas', 'Lord Serpentis', 'Verdan the Everliving',
    'Mutanus the Devourer', 'Deviate Faerie Dragon',

    --The Deadmines – 18-23
    'Rhahk\'zor', 'Sneed', 'Gilnid', 'Edwin VanCleef', 'Cookie', 'Miner Johnson', 'Mr. Smite', 'Captain Greenskin',

    --Shadowfang Keep – 22-30
    'Razorclaw the Butcher', 'Baron Silverlaine', 'Fenrus the Devourer', 'Odo the Blindwatcher', 'Archmage Arugal', 'Deathsworn Captain',
    'Commander Springvale', 'Wolf Master Nandos', 'Rethilgore',

    --Blackfathom Deeps – 20-30
    'Lorgus Jett', 'Twilight Lord Kelris', 'Gelihast', 'Aku\'mai', 'Ghamoo-ra', 'Baron Aquanis',
    'Old Serra\'kis', 'Lady Sarevess',

    --The Stockade – 22-30
    'Targorr the Dread', 'Kam Deepfury', 'Hamhock', 'Bruegal Ironknuckle', 'Bazil Thredd', 'Dextren Ward',

    --Gnomeregan – 24-34
    'Viscous Fallout', 'Grubbis', 'Crowd Pummeler 9-60', 'Electrocutioner 6000', 'Dark Iron Ambassador', 'Mekgineer Thermaplugg',

    --Razorfen Kraul – 30-40

    'Aggem Thorncurse', 'Agathelos the Raging', 'Charlga Razorflank', 'Roogug', 'Death Speaker Jargba', 'Overlord Ramtusk',
    'Blind Hunter', 'Earthcaller Halmgar',

    --Scarlet Monastery – 26-45

    'Herod',
    'Interrogator Vishas', 'Bloodmage Thalnos', 'Azshir the Sleepless', 'Fallen Champion', 'Ironspire',
    'Houndmaster Loksey', 'Arcanist Doan',
    'High Inquisitor Fairbanks', 'Scarlet Commander Mograine', 'High Inquisitor Whitemane',

    --Razorfen Downs – 40-50
    'Mordresh Fire Eye', 'Ragglesnout', 'Tuten\'kash', 'Glutton', 'Amnennar the Coldbringer', 'Plaguemaw the Rotting',

    --Uldaman – 35-45

    'Revelosh', 'Ironaya', 'Obsidian Sentinel', 'Ancient Stone Keeper',
    'Grimlok', 'Archaedas', 'Galgann Firehammer', 'Baelog', 'Olaf', 'Eric "The Swift"',

    --Zul’Farrak – 42-46
    'Theka the Martyr', 'Antu\'sul', 'Witch Doctor Zum\'rah', 'Sandfury Executioner',
    'Sergeant Bly', 'Ruuzlu', 'Hydromancer Velratha', 'Zerillis',
    'Nekrum Gutchewer', 'Shadowpriest Sezz\'ziz', 'Dustwraith',
    'Gahz\'rilla', 'Chief Ukorz Sandscalp',

    --Maraudon – 46-55
    'Tinkerer Gizlock', 'Lord Vyletongue',
    'Noxxion', 'Razorlash',
    'Landslide', 'Rotgrip', 'Princess Theradras',
    'Celebras the Cursed', 'Meshlok the Harvester',

    --Temple of Atal’Hakkar – 55-60
    'Hazzas', 'Morphaz', 'Jammal\'an the Prophet',
    'Shade of Eranikus', 'Atal\'alarion',
    'Ogom the Wretched', 'Weaver',
    'Morphaz', 'Dreamscythe', 'Avatar of Hakkar', 'Spawn of Hakkar',

    --Blackrock Depths – 52-60
    'High Interrogator Gerstahn', 'Houndmaster Grebmar', 'Lord Roccor', 'Golem Lord Argelmach', 'Hurley Blackbreath',
    'Bael\'Gar', 'General Angerforge', 'Plugger Spazzring', 'Ribbly Screwspigot',
    'Fineous Darkvire', 'Emperor Dagran Thaurissan', 'Panzor the Invincible',
    'Phalanx', 'Lord Incendius', 'Warder Stilgiss', 'Verek', 'Watchman Doomgrip',
    'Pyromancer Loregrain', 'Ambassador Flamelash', 'Magmus', 'Princess Moira Bronzebeard',
    'Gorosh the Dervish', 'Grizzle', 'Eviscerator', 'Ok\'thor the Breaker', 'Anub\'shiah', 'Hedrum the Creeper',

    --Lower Blackrock Spire – 55-60
    'Mother Smolderweb', 'Bannok Grimaxe', 'Crystal Fang', 'Ghok Bashguud', 'Spirestone Butcher',
    'Overlord Wyrmthalak', 'Burning Felguard', 'Spirestone Battle Lord', 'Spirestone Lord Magus',
    'Highlord Omokk', 'Urok Doomhowl', 'Quartermaster Zigris', 'Halycon', 'Gizrul the Slavener', 'War Master Voone',

    --Upper Blackrock Spire – 55-60
    'Jed Runewatcher', 'Gyth', 'Warchief Rend Blackhand',
    'Pyroguard Emberseer', 'Solakar Flamewreath', 'Goraluk Anvilcrack',
    'The Beast', 'General Drakkisath',
    'Lord Valthalak',

    --Dire Maul – 55-60

    'Guard Mol\'dar', 'Stomper Kreeg', 'Guard Fengus', 'Guard Slip\'kik', 'Captain Kromcrush', 'Cho\'Rush the Observer', 'King Gordok',
    'Pusilin', 'Zevrim Thornhoof', 'Hydrospawn', 'Lethtendris', 'Alzzin the Wildshaper',
    'Tendris Warpwood', 'Illyanna Ravenoak', 'Magister Kalendris', 'Immol\'thar', 'Prince Tortheldrin',
    'Tsu\'zee', 'Lord Hel\'nurath',

    --Scholomance – 58 - 60
    'Marduk Blackpool', 'Doctor Theolen Krastinov', 'Lorekeeper Polkelt', 'The Ravenian', 'Darkmaster Gandling',
    'Kirtonos the Herald', 'Blood Steward of Kirtonos', 'Jandice Barov', 'Rattlegore', 'Death Knight Darkreaver',
    'Instructor Malicia', 'Vectus', 'Ras Frostwhisper', 'Lady Illucia Barov', 'Lord Alexei Barov',

    --Stratholme – 58 - 60
    'Stratholme Courier', 'The Unforgiven', 'Cannon Master Wiley', 'Grand Crusader Dathrohan', 'Timmy the Cruel',
    'Archivist Galford', 'Malor the Zealous', 'Hearthsinger Forresten', 'Skul', 'Postmaster Malown',
    'Magistrate Barthilas', 'Ramstein the Gorger', 'Nerub\'enkan', 'Maleki the Pallid', 'Baroness Anastari', 'Baron Rivendare', 'Stonespire',


    --    Zul'Gurub
    'High Priestess Jeklik',
    'High Priest Venoxis',
    'High Priestess Mar\'li',
    'High Priest Thekal',
    'High Priestess Arlokk',
    'Bloodlord Mandokir',
    'Jin\'do the Hexxer',
    'Gahz\'ranka',
    'Gri\'lek',
    'Hazza\'rah',
    'Renataki',
    'Wushoolay',
    'Hakkar the Soulflayer',
    --Ruins of Ahn'Qiraj
    'Kurinnaxx',
    'General Rajaxx',
    'Moam',
    'Buru the Gorger',
    'Ayamiss the Hunter',
    'Ossirian the Unscarred',
    --Molten Core
    'Lucifron',
    'Magmadar',
    'Gehennas',
    'Garr',
    'Baron Geddon',
    'Shazzrah',
    'Golemagg the Incinerator',
    'Sulfuron Harbinger',
    'Majordomo Executus',
    'Ragnaros',
    --Blackwing Lair
    'Razorgore the Untamed',
    'Vaelastrasz the Corrupt',
    'Broodlord Lashlayer',
    'Flamegor',
    'Ebonroc',
    'Firemaw',
    'Chromaggus',
    'Nefarian',
    --Onyxia's Lair
    'Onyxia',
    --The Temple of Ahn'Qiraj
    'The Prophet Skeram',
    'Lord Kri',
    'Princess Yauj',
    'Vem',
    'Battleguard Sartura',
    'Fankriss the Unyielding',
    'Viscidus',
    'Princess Huhuran',
    'Emperor Vek\'lor',
    'Emperor Vek\'nilash',
    'Ouro',
    'C\'Thun',
    --Naxxramas
    'Anub\'Rekhan',
    'Grand Widow Faerlina',
    'Maexxna',
    'Noth the Plaguebringer',
    'Heigan the Unclean',
    'Loatheb',
    'Instructor Razuvious',
    'Gothik the Harvester',
    'The Four Horsemen',
    'Patchwerk',
    'Grobbulus',
    'Gluth',
    'Thaddius',
    'Sapphiron',
    'Kel\'Thuzad',
    --WORLD BOSSES
    'Azuregos',
    'Lord Kazzak',
    'Teremus the Devourer',
    'Emeriss', 'Lethon', 'Taerar', 'Ysondre',
    'Nerubian Overseer',
    'Turtlhu, the Black Turtle of Doom',
    'Snowball'
};

BossFrame:Hide()

BossFrame:RegisterEvent("ADDON_LOADED")
BossFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

BossFrame:SetScript("OnEvent", function()

    if event then
        if event == "ADDON_LOADED" and arg1 == "TWLC2c" then
            getglobal('BossFrame'):Hide()
            if TWLC_BOSS_FRAME == nil then
                TWLC_BOSS_FRAME = true
            end
            if TWLC_BOSS_FRAME then
                bfprint('TWLC2c BossFrame (v' .. addonVer .. ') Loaded and Enabled. Type |cfffff569/tw|cff69ccf0boss |cffffffffto toggle boss frame.')
            else
                bfprint('TWLC2c BossFrame (v' .. addonVer .. ') Loaded and Disabled. Type |cfffff569/tw|cff69ccf0boss |cffffffffto toggle boss frame.')
            end
        end
        if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then

            for i, boss in BossFrame.Bosses do
                if arg1 == boss .. ' dies.' and TWLC_BOSS_FRAME then
                    start_boss_win_anim(boss)
                    return true
                end
            end

        end
    end
end)

BossFrame:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

BossFrame.frameIndex = 0
BossFrame.doAnim = false
BossFrame.active = false

BossFrame:SetScript("OnUpdate", function()

    if BossFrame.active then

        if ((GetTime()) >= (this.startTime) + 0.03) then

            this.startTime = GetTime()

            local frame = getglobal('BossFrameFrames')

            local image = 'bossbanner_';

            if BossFrame.frameIndex < 10 then
                image = image .. '0' .. BossFrame.frameIndex
            else
                image = image .. BossFrame.frameIndex;
            end

            BossFrame.frameIndex = BossFrame.frameIndex + 1

            if BossFrame.doAnim then
                if BossFrame.frameIndex <= 30 then
                    frame:SetTexture('Interface\\AddOns\\TWLC2c\\images\\boss\\' .. image)
                end
            end

            if BossFrame.frameIndex == 29 then --stop and hold last frame
                BossFrame.doAnim = false
            end

            if BossFrame.frameIndex > 12 then
                if (getglobal('BossFrameBossName'):GetAlpha() < 0.9) then
                    getglobal('BossFrameBossName'):SetAlpha(getglobal('BossFrameBossName'):GetAlpha() + 0.16)
                    getglobal('BossFrameHasBeenDefeated'):SetAlpha(getglobal('BossFrameHasBeenDefeated'):GetAlpha() + 0.16)
                end
            end

            if BossFrame.frameIndex > 119 then
                frame:SetAlpha(frame:GetAlpha() - 0.03)
                getglobal('BossFrameBossName'):SetAlpha(frame:GetAlpha())
                getglobal('BossFrameHasBeenDefeated'):SetAlpha(frame:GetAlpha())
            end

            if BossFrame.frameIndex == 150 then
                BossFrame.frameIndex = 0
                BossFrame.active = false
                frame:Hide()
                BossFrame:Hide()
            end
        end
    end
end)

SLASH_TWBOSS1 = "/twboss"
SlashCmdList["TWBOSS"] = function(cmd)
    if cmd then
        TWLC_BOSS_FRAME = not TWLC_BOSS_FRAME
        if TWLC_BOSS_FRAME then
            bfprint('TWLC2c BossFrame Enabled. Type |cfffff569/tw|cff69ccf0boss |cffffffffto toggle boss frame.')
        else
            bfprint('TWLC2c BossFrame Disabled. Type |cfffff569/tw|cff69ccf0boss |cffffffffto toggle boss frame.')
        end
    end
end

function start_boss_win_anim(boss)

    if (not BossFrame:IsVisible()) then

        getglobal('BossFrameBossName'):SetText(boss)

        getglobal('BossFrame'):Show();
        getglobal('BossFrameBossName'):SetAlpha(0);
        getglobal('BossFrameHasBeenDefeated'):SetAlpha(0);

        BossFrame.frameIndex = 0
        BossFrame.doAnim = true
        BossFrame.active = true
        getglobal('BossFrameFrames'):SetTexture('Interface\\AddOns\\TWLC2c\\images\\boss\\bossbanner_01')
        getglobal('BossFrameFrames'):Show()
        getglobal('BossFrameFrames'):SetAlpha(1)

        BossFrame:Show()
    end
end
