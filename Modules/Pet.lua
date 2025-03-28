local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("EasyFrames")
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Pet"
local Pet = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues

local OnShowHookScript = function(frame)
    frame:Hide()
end

local OnSetTextHookScript = function(frame, text, flag)
    if (flag ~= "EasyFramesHookSetText" and not db.pet.showHitIndicator) then
        frame:SetText(nil, "EasyFramesHookSetText")
    end
end

function Pet:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Pet:OnEnable()
    self:SetScale(db.pet.scaleFrame)
    self:PreSetMovable()
    self:SetMovable(db.pet.lockedMovableFrame)

    self:SetHealthBarsFont()

    self:ShowName(db.pet.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetManaBarsFont()
    self:ShowHitIndicator(db.pet.showHitIndicator)

    self:ShowStatusTexture(db.pet.showStatusTexture)
    self:ShowAttackBackground(db.pet.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.pet.attackBackgroundOpacity)

    self:PetFrameUpdateAnchoring()

    self:SecureHook("PetFrame_Update", "PetFrameUpdate")

    self:SecureHook("TextStatusBar_UpdateTextString", "UpdateTextStringWithValues")
    -- self:SecureHook("TextStatusBar_UpdateTextStringWithValues", "UpdateTextStringWithValues")

end

function Pet:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:SetScale(db.pet.scaleFrame)
    self:PreSetMovable()
    self:SetMovable(db.pet.lockedMovableFrame)

    self:SetHealthBarsFont()

    self:ShowName(db.pet.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetManaBarsFont()
    self:ShowHitIndicator(db.pet.showHitIndicator)

    self:ShowStatusTexture(db.pet.showStatusTexture)
    self:ShowAttackBackground(db.pet.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.pet.attackBackgroundOpacity)

    self:UpdateTextStringWithValues()
    self:UpdateTextStringWithValues(PetFrameManaBar)
end

function Pet:PetFrameUpdate(frame, override)
    if ((not PlayerFrame.animating) or (override)) then
        -- if (UnitIsVisible(frame.unit) and PetUsesPetFrame() and not PlayerFrame.vehicleHidesPet) then
        if (UnitIsVisible(frame.unit) and not PlayerFrame.vehicleHidesPet) then
            if (frame:IsShown()) then
                UnitFrame_Update(frame)
            else
                frame:Show()
            end
            -- frame.flashState = 1
            -- frame.flashTimer = PET_FLASH_ON_TIME
            if (UnitPowerMax(frame.unit) == 0) then
                PetFrameTexture:SetTexture(Media:Fetch("frames", "nomana"))
                PetFrameManaBarText:Hide()
            else
                PetFrameTexture:SetTexture(Media:Fetch("frames", "smalltarget"))
                PetFrameFlash:SetTexture(Media:Fetch("misc", "pet-frame-flash"))
            end
            PetAttackModeTexture:Hide()

            RefreshDebuffs(frame, frame.unit, nil, nil, true)

            PetFrame.portrait:SetTexCoord(0, 1, 0, 1)
            if (frame.unit == "player") then
                EasyFrames:GetModule("Player"):MakeClassPortraits(frame)
            end
        else
            if InCombatLockdown() then
                return
            end

            frame:Hide()
        end
    end

    self:PetFrameUpdateAnchoring()
end

function Pet:PetFrameUpdateAnchoring()
    if (db.pet.customOffset) then
        if InCombatLockdown() then
            return
        end

        local frame = PetFrame
        local x, y = unpack(db.pet.customOffset)

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", x, y)
    end
end

function Pet:SetScale(value)
    PetFrame:SetScale(value)
end

function Pet:PreSetMovable()
    local frame = PetFrame
    local firstGetPoing, secondGetPoint, thirdGetPoint

    frame:SetScript("OnMouseDown", function(frame, button)
        if not db.pet.lockedMovableFrame and button == "LeftButton" and not frame.isMoving then
            firstGetPoing = {frame:GetPoint()}

            frame:StartMoving()
            secondGetPoint = {frame:GetPoint()}

            frame.isMoving = true
        end
    end)
    frame:SetScript("OnMouseUp", function(frame, button)
        if not db.pet.lockedMovableFrame and button == "LeftButton" and frame.isMoving then
            thirdGetPoint = {frame:GetPoint()}

            frame:StopMovingOrSizing()
            frame.isMoving = false

            local _, _, _, x1, y1 = unpack(firstGetPoing)
            local _, _, _, x2, y2 = unpack(secondGetPoint)
            local _, _, _, x3, y3 = unpack(thirdGetPoint)

            frame:SetParent(PlayerFrame)

            db.pet.customOffset = {x1 + (x3 - x2), y1 + (y3 - y2)}
        end
    end)
    frame:SetScript("OnHide", function(frame)
        if (not db.pet.lockedMovableFrame and frame.isMoving) then
            frame:StopMovingOrSizing()
            frame.isMoving = false
        end
    end)
end

function Pet:SetMovable(value)
    PetFrame:SetMovable(not value)
end

function Pet:ResetFramePosition()
    local frame = PetFrame

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75)

    -- local _, class = UnitClass("player")
    -- if ( class == "DEATHKNIGHT" or class == "ROGUE") then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75)
    -- elseif ( class == "SHAMAN" or class == "DRUID" ) then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -100)
    -- elseif ( class == "WARLOCK" ) then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90)
    -- elseif ( class == "PALADIN" ) then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90)
    -- elseif ( class == "PRIEST" ) then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90)
    -- elseif ( class == "MONK" ) then
    --    self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 90, -100)
    -- end

    db.pet.customOffset = false
end

function Pet:UpdateTextStringWithValues(statusBar)
    local frame = statusBar or PetFrameHealthBar

    if (frame.unit == "pet") then
        if (frame == PetFrameHealthBar) then
            UpdateHealthValues(frame, db.pet.healthFormat, db.pet.customHealthFormat, db.pet.customHealthFormatFormulas,
                db.pet.useHealthFormatFullValues, db.pet.useChineseNumeralsHealthFormat)
        elseif (frame == PetFrameManaBar) then
            UpdateManaValues(frame, db.pet.manaFormat, db.pet.customManaFormat, db.pet.customManaFormatFormulas,
                db.pet.useManaFormatFullValues, db.pet.useChineseNumeralsManaFormat)
        end
    end
end

function Pet:SetHealthBarsFont()
    local fontSize = db.pet.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.pet.healthBarFontFamily)
    local fontStyle = db.pet.healthBarFontStyle

    PetFrameHealthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:SetManaBarsFont()
    local fontSize = db.pet.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.pet.manaBarFontFamily)
    local fontStyle = db.pet.manaBarFontStyle

    PetFrameManaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:ShowName(value)
    if (value) then
        PetName:Show()
    else
        PetName:Hide()
    end
end

function Pet:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.pet.petNameFontFamily)
    local fontSize = db.pet.petNameFontSize
    local fontStyle = db.pet.petNameFontStyle

    PetName:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:SetFrameNameColor()
    local color = db.pet.petNameColor

    EasyFrames.Utils.SetTextColor(PetName, color)
end

function Pet:ResetFrameNameColor()
    EasyFrames.db.profile.pet.petNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Pet:ShowHitIndicator(value)
    local frame = PetHitIndicator

    if (not value) then
        frame:SetText(nil)

        if (not frame.EasyFramesHookSetText) then
            hooksecurefunc(frame, "SetText", OnSetTextHookScript)
            frame.EasyFramesHookSetText = true
        end
    end
end

function Pet:ShowStatusTexture(value)
    local frame = PetAttackModeTexture

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Pet:ShowAttackBackground(value)
    local frame = PetFrameFlash

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Pet:SetAttackBackgroundOpacity(value)
    PetFrameFlash:SetAlpha(value)
end
