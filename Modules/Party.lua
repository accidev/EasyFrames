local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("EasyFrames")
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Party"
local Party = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local PartyIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetPartyFrames())

function Party:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Party:OnEnable()
    self:SetScale(db.party.scaleFrame)
    self:ShowName(db.party.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    --    self:ShowPetFrames(db.party.showPetFrames)

    self:SecureHook("PartyMemberFrame_OnEvent", "PartyFrame_UpdateAuras")
    self:SecureHook("TextStatusBar_UpdateTextString", "UpdateTextStringWithValues")
    -- self:SecureHook("TextStatusBar_UpdateTextStringWithValues", "UpdateTextStringWithValues")
end

function Party:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:SetScale(db.party.scaleFrame)
    self:ShowName(db.party.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    --    self:ShowPetFrames(db.party.showPetFrames)

    self:UpdateTextStringWithValues()
    self:UpdateTextStringWithValues(PartyMemberFrame1ManaBar)
end

function Party:SetScale(value)
    PartyIterator(function(frame)
        frame:SetScale(value)
    end)
end

function Party:UpdateTextStringWithValues(statusBar)
    local frame = statusBar or PartyMemberFrame1HealthBar

    if (frame.unit == "party1" or frame.unit == "party2" or frame.unit == "party3" or frame.unit == "party4") then
        if (string.find(frame:GetName(), 'HealthBar')) then
            UpdateHealthValues(frame, db.party.healthFormat, db.party.customHealthFormat,
                db.party.customHealthFormatFormulas, db.party.useHealthFormatFullValues,
                db.party.useChineseNumeralsHealthFormat)
        elseif (string.find(frame:GetName(), 'ManaBar')) then
            UpdateManaValues(frame, db.party.manaFormat, db.party.customManaFormat, db.party.customManaFormatFormulas,
                db.party.useManaFormatFullValues, db.party.useChineseNumeralsManaFormat)
        end
    end
end

function Party:ShowName(value)
    PartyIterator(function(frame)
        if (value) then
            frame.name:Show()
        else
            frame.name:Hide()
        end
    end)
end

function Party:SetHealthBarsFont()
    local fontSize = db.party.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.party.healthBarFontFamily)
    local fontStyle = db.party.healthBarFontStyle

    PartyIterator(function(frame)
        local healthBar = _G[frame:GetName() .. "HealthBar"]

        healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Party:SetManaBarsFont()
    local fontSize = db.party.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.party.manaBarFontFamily)
    local fontStyle = db.party.manaBarFontStyle

    PartyIterator(function(frame)
        local manaBar = _G[frame:GetName() .. "ManaBar"]

        manaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Party:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.party.partyNameFontFamily)
    local fontSize = db.party.partyNameFontSize
    local fontStyle = db.party.partyNameFontStyle

    PartyIterator(function(frame)
        frame.name:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Party:SetFrameNameColor()
    local color = db.party.partyNameColor

    PartyIterator(function(frame)
        EasyFrames.Utils.SetTextColor(frame.name, color)
    end)
end

function Party:ResetFrameNameColor()
    EasyFrames.db.profile.party.partyNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Party:ShowPetFrames(value)
    PartyIterator(function(frame)
        if (value) then
            _G[frame:GetName() .. "PetFrame"]:Show()
        else
            _G[frame:GetName() .. "PetFrame"]:Hide()
        end
    end)
end

function Party:PartyFrame_UpdateAuras(frame, event)
    if (event == "UNIT_AURA") then
        local selfName = frame:GetName()

        local firstDebuffFrame = _G[selfName .. 'Debuff1']

        if (firstDebuffFrame) then
            local point, relativeTo, relativePoint, xOffset, _ = firstDebuffFrame:GetPoint()

            firstDebuffFrame:ClearAllPoints()
            firstDebuffFrame:SetPoint(point, relativeTo, relativePoint, xOffset, -44)
        end
    end
end
