local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("EasyFrames")
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Target"
local Target = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local ClassPortraits = EasyFrames.Utils.ClassPortraits
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits

local OnShowHookScript = function(frame)
    frame:Hide()
end

function Target:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Target:OnEnable()
    self:SetScale(db.target.scaleFrame)
    self:ShowTargetFrameToT()
    self:ShowName(db.target.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    -- self:ReverseDirectionLosingHP(db.target.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.target.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.target.attackBackgroundOpacity)
    self:ShowPVPIcon(db.target.showPVPIcon)

    -- self:SecureHook("TextStatusBar_UpdateTextStringWithValues", "UpdateTextStringWithValues")
    self:SecureHook("TextStatusBar_UpdateTextString", "UpdateTextStringWithValues")
    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")
end

function Target:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:SetScale(db.target.scaleFrame)
    self:MakeClassPortraits(TargetFrame)
    self:ShowTargetFrameToT()
    self:ShowName(db.target.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    -- self:ReverseDirectionLosingHP(db.target.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.target.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.target.attackBackgroundOpacity)
    self:ShowPVPIcon(db.target.showPVPIcon)

    self:UpdateTextStringWithValues()
    self:UpdateTextStringWithValues(TargetFrameManaBar)
end

function Target:SetScale(value)
    TargetFrame:SetScale(value)
end

function Target:MakeClassPortraits(frame)
    if (frame.portrait and (frame.unit == "target" or frame.unit == "targettarget")) then
        if (db.target.portrait == "2") then
            ClassPortraits(frame)
        else
            DefaultPortraits(frame)
        end
    end
end

function Target:UpdateTextStringWithValues(statusBar)
    local frame = statusBar or TargetFrameHealthBar

    if (frame.unit == "target") then
        if (frame == TargetFrameHealthBar) then
            UpdateHealthValues(frame, db.target.healthFormat, db.target.customHealthFormat,
                db.target.customHealthFormatFormulas, db.target.useHealthFormatFullValues,
                db.target.useChineseNumeralsHealthFormat)
        elseif (frame == TargetFrameManaBar) then
            UpdateManaValues(frame, db.target.manaFormat, db.target.customManaFormat,
                db.target.customManaFormatFormulas, db.target.useManaFormatFullValues,
                db.target.useChineseNumeralsManaFormat)
        end
    end
end

function Target:ShowTargetFrameToT()
    if (db.target.showToTFrame) then
        TargetFrameToT:SetAlpha(100)
    else
        TargetFrameToT:SetAlpha(0)
    end
end

function Target:ShowName(value)
    if (value) then
        TargetFrame.name:Show()
    else
        TargetFrame.name:Hide()
    end

    self:ShowNameInsideFrame(db.target.showNameInsideFrame)
end

function Target:ShowNameInsideFrame(value)
    local Core = EasyFrames:GetModule("Core")

    local HealthBarTexts = {TargetFrameHealthBar.RightText, TargetFrameHealthBar.LeftText,
                            TargetFrameHealthBar.TextString, TargetFrameTextureFrameDeadText}

    for _, healthBar in pairs(HealthBarTexts) do
        local point, relativeTo, relativePoint, xOffset, yOffset = healthBar:GetPoint()

        if (value and db.target.showName) then
            Core:MoveTargetFrameName(nil, nil, nil, nil, 20)

            Core:MoveRegion(healthBar, point, relativeTo, relativePoint, xOffset, yOffset - 4)
        else
            Core:MoveTargetFrameName()

            Core:MoveRegion(healthBar, point, relativeTo, relativePoint, xOffset, 12)
        end
    end
end

function Target:SetHealthBarsFont()
    local fontSize = db.target.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.target.healthBarFontFamily)
    local fontStyle = db.target.healthBarFontStyle

    TargetFrameHealthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetManaBarsFont()
    local fontSize = db.target.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.target.manaBarFontFamily)
    local fontStyle = db.target.manaBarFontStyle

    TargetFrameManaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.target.targetNameFontFamily)
    local fontSize = db.target.targetNameFontSize
    local fontStyle = db.target.targetNameFontStyle

    TargetFrame.name:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetFrameNameColor()
    local color = db.target.targetNameColor

    EasyFrames.Utils.SetTextColor(TargetFrame.name, color)
end

function Target:ResetFrameNameColor()
    EasyFrames.db.profile.target.targetNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

--[[
function Target:ReverseDirectionLosingHP(value)
    TargetFrameHealthBar:SetReverseFill(value)
    TargetFrameManaBar:SetReverseFill(value)
end
]] --

function Target:ShowAttackBackground(value)
    local frame = TargetFrameFlash

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("target")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Target:SetAttackBackgroundOpacity(value)
    TargetFrameFlash:SetAlpha(value)
end

function Target:ShowPVPIcon(value)
    for _, frame in pairs({TargetFrameTextureFramePVPIcon, TargetFrameTextureFramePrestigeBadge,
                           TargetFrameTextureFramePrestigePortrait}) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (UnitIsPVP("target")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end
