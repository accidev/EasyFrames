local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("EasyFrames")
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Boss"
local Boss = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local BossIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetBossFrames())

function Boss:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Boss:OnEnable()
    self:SetScale(db.boss.scaleFrame)
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    -- Name
    self:ShowName(db.boss.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()

    self:ShowThreatIndicator()

    self:SecureHook("TextStatusBar_UpdateTextString", "UpdateTextStringWithValues")
    -- self:SecureHook("TextStatusBar_UpdateTextStringWithValues", "UpdateTextStringWithValues")
end

function Boss:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:SetScale(db.boss.scaleFrame)
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    -- Name
    self:ShowName(db.boss.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()

    self:ShowThreatIndicator()

    self:UpdateTextStringWithValues()
    self:UpdateTextStringWithValues(Boss1TargetFrameManaBar)
end

function Boss:SetScale(value)
    -- 16 is default size of BOSS_FRAME_CASTBAR_HEIGHT
    BOSS_FRAME_CASTBAR_HEIGHT = ((value - 1) * 80) + 40

    BossIterator(function(frame)
        frame:SetScale(value)
    end)
end

function Boss:UpdateTextStringWithValues(statusBar)
    local frame = statusBar or Boss1TargetFrameHealthBar

    if (frame.unit == "boss1" or frame.unit == "boss2" or frame.unit == "boss3" or frame.unit == "boss4" or frame.unit ==
        "boss5") then
        if (string.find(frame:GetName(), 'HealthBar')) then
            UpdateHealthValues(frame, db.boss.healthFormat, db.boss.customHealthFormat,
                db.boss.customHealthFormatFormulas, db.boss.useHealthFormatFullValues,
                db.boss.useChineseNumeralsHealthFormat)
        elseif (string.find(frame:GetName(), 'ManaBar')) then
            UpdateManaValues(frame, db.boss.manaFormat, db.boss.customManaFormat, db.boss.customManaFormatFormulas,
                db.boss.useManaFormatFullValues, db.boss.useChineseNumeralsManaFormat)
        end
    end
end

function Boss:ShowName(value)
    BossIterator(function(frame)
        if (value) then
            frame.name:Show()
        else
            frame.name:Hide()
        end
    end)

    self:ShowNameInsideFrame(db.boss.showNameInsideFrame)
end

function Boss:ShowNameInsideFrame(value)
    local Core = EasyFrames:GetModule("Core")

    BossIterator(function(frame)
        local HealthBarTexts = {frame.healthbar.RightText, frame.healthbar.LeftText, frame.healthbar.TextString}

        for _, healthBar in pairs(HealthBarTexts) do
            local namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, nameYOffset = frame.name:GetPoint()
            local healthBarPoint, healthBarRelativeTo, healthBarRelativePoint, healthBarXOffset, healthBarYOffset =
                healthBar:GetPoint()

            if (value and db.boss.showName) then
                Core:MoveRegion(frame.name, namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, 20)
                Core:MoveRegion(healthBar, healthBarPoint, healthBarRelativeTo, healthBarRelativePoint,
                    healthBarXOffset, healthBarYOffset - 4)
            else
                Core:MoveRegion(frame.name, namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, 39)
                Core:MoveRegion(healthBar, healthBarPoint, healthBarRelativeTo, healthBarRelativePoint,
                    healthBarXOffset, 12)
            end
        end
    end)
end

function Boss:SetHealthBarsFont()
    local fontSize = db.boss.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.boss.healthBarFontFamily)
    local fontStyle = db.boss.healthBarFontStyle

    BossIterator(function(frame)
        local healthBar = _G[frame:GetName() .. "HealthBar"]

        healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetManaBarsFont()
    local fontSize = db.boss.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.boss.manaBarFontFamily)
    local fontStyle = db.boss.manaBarFontStyle

    BossIterator(function(frame)
        local manaBar = _G[frame:GetName() .. "ManaBar"]

        manaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.boss.bossNameFontFamily)
    local fontSize = db.boss.bossNameFontSize
    local fontStyle = db.boss.bossNameFontStyle

    BossIterator(function(frame)
        frame.name:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetFrameNameColor()
    local color = db.boss.bossNameColor

    BossIterator(function(frame)
        EasyFrames.Utils.SetTextColor(frame.name, color)
    end)
end

function Boss:ResetFrameNameColor()
    EasyFrames.db.profile.boss.bossNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Boss:ShowThreatIndicator()
    local showThreatIndicator = db.boss.showThreatIndicator

    BossIterator(function(frame)
        if (showThreatIndicator) then
            frame.threatNumericIndicator:SetAlpha(1)
        else
            frame.threatNumericIndicator:SetAlpha(0)
        end
    end)
end
