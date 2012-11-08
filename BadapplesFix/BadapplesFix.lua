--[[--------------------------------------------------------------------
	Badapples Fix
	by Phanx <addons@phanx.net>
	Fixes Cirk's Badapples for WoW Patch 3.3.5+, and adds more detailed
	tooltips to each entry in the Badapples list panel.
----------------------------------------------------------------------]]

if not BADAPPLES_VERSION or tonumber(BADAPPLES_VERSION:match("(%d+%.%d+)%.")) > 3.2 then
	return print("Badapples has been updated. You probably don't need Badapples Fix anymore.")
end

------------------------------------------------------------------------

local VERTICAL_OFFSET = 19

BadapplesFrameNameColumnHeader:SetPoint("TOPLEFT", FriendsFrame, 6, -84)

BadapplesFrameButton1:SetPoint("TOPLEFT", BadapplesFrameNameColumnHeader, "BOTTOMLEFT", 0, 0)

BadapplesListScrollFrame:ClearAllPoints()
BadapplesListScrollFrame:SetPoint("TOPLEFT", BadapplesFrameNameColumnHeader, "BOTTOMLEFT", 0, -4)
BadapplesListScrollFrame:SetPoint("TOPRIGHT", BadapplesFrameReasonColumnHeader, "BOTTOMRIGHT", -26, -4)
BadapplesListScrollFrame:SetHeight(BADAPPLES_DISPLAY_COUNT * BadapplesFrameButton1:GetHeight())

BadapplesFrameTotals:ClearAllPoints()
BadapplesFrameTotals:SetPoint("TOPLEFT", BadapplesFrameNameColumnHeader, "BOTTOMLEFT", 0, -2 - BADAPPLES_DISPLAY_COUNT * BadapplesFrameButton1:GetHeight())

BadapplesFrameColorButton:ClearAllPoints()
BadapplesFrameColorButton:SetPoint("TOPLEFT", BadapplesFrameTotals, "BOTTOMLEFT", 0, -2)

BadapplesFrameAddButton:ClearAllPoints()
BadapplesFrameAddButton:SetPoint("LEFT", BadapplesFrameColorButton, "RIGHT", 0, 0)

BadapplesFrameRemoveButton:ClearAllPoints()
BadapplesFrameRemoveButton:SetPoint("LEFT", BadapplesFrameAddButton, "RIGHT", 0, 0)

for i = 1, 4 do
	local tab = _G["BadapplesFrameToggleTab"..i]
	tab:Hide()
	tab.Show = tab.Hide
end

local o = CreateFrame("Frame", "otest", UIParent)
o:SetFrameStrata("DIALOG")
o:SetBackdrop({ bgFile = [[Interface\BUTTONS\WHITE8X8]] })
o:SetBackdropColor(1, 0, 1, 0.25)

------------------------------------------------------------------------

local FriendsTabHeaderTab4 = CreateFrame("Button", "FriendsTabHeaderTab4", FriendsTabHeader, "TabButtonTemplate")

FriendsTabHeaderTab4:SetPoint("LEFT", FriendsTabHeaderTab3:IsShown() and FriendsTabHeaderTab3 or FriendsTabHeaderTab2, "RIGHT", 0, 0)
FriendsTabHeaderTab4:SetText("Badapples")
FriendsTabHeaderTab4:SetID(4)

FriendsTabHeaderTab4:SetScript("OnClick", function(self)
	PanelTemplates_Tab_OnClick(self, FriendsTabHeader)
	FriendsFrame_Update()
	PlaySound("igMainMenuOptionCheckBoxOn")
end)

PanelTemplates_TabResize(FriendsTabHeaderTab4, 0)
FriendsTabHeaderTab4:SetWidth(FriendsTabHeaderTab4:GetTextWidth() + 31)

PanelTemplates_SetNumTabs(FriendsTabHeader, 4)
PanelTemplates_SetTab(FriendsTabHeader, 1)

------------------------------------------------------------------------

local hook_FriendsFrame_Update = FriendsFrame_Update

function FriendsFrame_Update()
	if FriendsFrame.selectedTab ~= 1 or FriendsTabHeader.selectedTab ~= 4 then
		return hook_FriendsFrame_Update()
	end

	FriendsFrameTitleText:SetText("Badapples List")
	FriendsFrame_ShowSubFrame("BadapplesFrame")

	FriendsTabHeader:Show() -- not sure why it sometimes hides itself
end

------------------------------------------------------------------------
--	Improved tooltips!
------------------------------------------------------------------------

local _playerName = UnitName("player")
local _serverName = GetRealmName()

function Badapples.GetSource(name)
	-- Returns the name of the character logged in when the given player name
	-- was added to the Badapples list.
	if not name or name == "" then
		return
	end
	local player = Badapples.FormatName(name)
	if BadapplesState.Servers[_serverName].List[player] then
		return BadapplesState.Servers[_serverName].List[player].Source
	end
end

local Badapples_Add = Badapples.Add

function Badapples.Add(name_and_reason)
	Badapples_Add(name_and_reason)

	local player = Badapples.FormatName(Badapples.GetNextParam(name_and_reason))
	if BadapplesState.Servers[_serverName].List[player] then
		BadapplesState.Servers[_serverName].List[player].Source = _playerName
	end
end

local BadapplesButton_OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local name = _G[self:GetName() .. "Name"]:GetText()
	local color = BadapplesState.Colors
	GameTooltip:SetText(name, color.r, color.g, color.b, 1, 1)

	local reason = _G[self:GetName() .. "Reason"]:GetText()
	if reason then
		GameTooltip:AddLine(reason, 1, 1, 1, 1, 1)
	end

	local date = Badapples.GetDateAdded(name)
	local source = Badapples.GetSource(name)
	if date and source then
		GameTooltip:AddLine("Added by " .. source .. " on " .. date, nil, nil, nil, 1, 1)
	elseif date then
		GameTooltip:AddLine("Added on " .. date, nil, nil, nil, 1, 1)
	elseif source then
		GameTooltip:AddLine("Added by " .. source, nil, nil, nil, 1, 1)
	end

	GameTooltip:Show()
end

local BadapplesButton_OnClick = function(self, button)
	Badapples.FrameButton_OnClick(self, button)
	PlaySound("igMainMenuCheckBoxOn")
end

for i = 1, 17 do
	local b = _G["BadapplesFrameButton" .. i]
	b.OnEnterFunction = BadapplesButton_OnEnter
	b:SetScript("OnClick", BadapplesButton_OnClick)
end