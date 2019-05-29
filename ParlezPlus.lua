
-- Config
local PP = ZO_Object:Subclass()
PP.name = "ParlezPlus"

PP.dialog = {}

function PP:clearConversation()
	self.dialog = {}
end

function PP:addResponse(r)
	table.insert(self.dialog, r)
end

function PP:formatConversation()
	local text = ""
	for i = 1, #self.dialog do
		if not (self.dialog[i].from_player == true and Defines.Flags.DisplayPlayerText == false) then
			text = text .. self.dialog[i]:format()
		end
	end
	return text
end

-- AddOn Init
function PP:Initialize()
	Defines:Initialize()

	-- register for dialog events.
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, 			function (event) self:OnDialogBegin(event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, 	function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_OFFERED, 			function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE_DIALOG, 	function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_END, 			function (event) self:OnDialogEnd(event) end)
	
end

-- NPC begins talking.
function PP:OnDialogBegin(event, optionsCount)
	SetDialogTitleHidden(not Defines.Flags.DisplayDialogTitle)
	self:clearConversation()
end

-- NPC continues talking.
function PP:OnDialogUpdate(event, optionCount)
	local name, text = GetDialogNameAndText()
	local playerName = GetUnitName("player")
	local npcName = GetUnitName("interact")

	SetDialogText(self:formatConversation())

	-- is response by player already a duplicate?
	if #self.dialog >= 1 and self.dialog[#self.dialog].is_duplicate then
		self:addResponse(Response:new{
			person = npcName, text = text,
			color = Defines.TextColor.NPCDuplicateText,
			is_duplicate = true})
	else
		self:addResponse(Response:new{
			person = npcName, text = text,
			color = Defines.TextColor.NPCText})
	end

	-- if the npc just started talking, dont delay the npcs text.
	local delay = Defines.Timeout.NPCAfterResponse
	if #self.dialog <= 1 or Defines.Flags.DisplayPlayerText == false then
		delay = 0
	end

	-- wait `delay` milliseconds until npc dialog appears after responding to him
	setTimeout(function ()
		SetDialogText(self:formatConversation())
		end, delay)

	--[[
		-- iterate trough response button handles
		local pao = ZO_InteractWindowPlayerAreaOptions;
		for i = 1, pao:GetNumChildren() do
			local op = pao:GetChild(i)
			if op.optionType and op.optionType ~= 10000 then

			end
		end

		-- iterate trough all options
		for i = 1, GetChatterOptionCount() do
			local oString, oType = GetChatterOption(i)

			--d("Option " .. i .. ": " .. oType)

		end
	]]

end

-- NPC stopped talking.
function PP:OnDialogEnd(event)
	SetDialogTitleHidden(false)
	self:clearConversation()
end


function PP:HandleChatterOptionClicked(label)
	if label.optionIndex and type(label.optionIndex) == "number" then
		-- d("index: " .. label.optionIndex)
		-- d("text: " .. label.optionText)

		local playerName = GetUnitName("player")
		local chosenBefore = label.chosenBefore or false

		if chosenBefore then
			self:addResponse(Response:new{
				person = playerName, text = label.optionText,
				color = Defines.TextColor.PlayerDuplicateResponse,
				is_duplicate = true,
				from_player = true})
		else
			self:addResponse(Response:new{
				person = playerName, text = label.optionText,
				color = Defines.TextColor.PlayerResponse,
				from_player = true})
		end

		SetDialogText(self:formatConversation())
	elseif label.optionIndex and type(label.optionIndex) == "function" then
		
		local playerName = GetUnitName("player")
		local chosenBefore = label.chosenBefore or false

		if chosenBefore then
			self:addResponse(Response:new{
				person = playerName, text = label:GetText(),
				color = Defines.TextColor.PlayerDuplicateResponse,
				is_duplicate = true,
				from_player = true})
		else
			self:addResponse(Response:new{
				person = playerName, text = label:GetText(),
				color = Defines.TextColor.PlayerResponse,
				from_player = true})
		end

		SetDialogText(self:formatConversation())
	end
end

-- Add additional callback handler for ChatterOptionClicked
local ihcoc = INTERACTION.HandleChatterOptionClicked
function INTERACTION:HandleChatterOptionClicked(label)
	-- call base handler
	if Defines.Flags.DelayedNPCResponse and type(label.optionType) == "number" and label.optionType == 10000 then
		setTimeout(function ()
			ihcoc(INTERACTION, label)
		end, Defines.Timeout.NPCAfterResponse)
	else
		ihcoc(INTERACTION, label)
	end

	-- call ParlezPlus handler
	if label.enabled then
		PP.HandleChatterOptionClicked(PP, label)
	end
end


-- Helper functions
function GetDialogNameAndText()
	local name = string.sub(ZO_InteractWindowTargetAreaTitle:GetText(), 2, -2)
	local text = ZO_InteractWindowTargetAreaBodyText:GetText()

	return name, text
end

function SetDialogText(text)
	ZO_InteractWindowTargetAreaBodyText:SetText(text)
end

function SetDialogTitle(title)
	ZO_InteractWindowTargetAreaTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	ZO_InteractWindowTargetAreaTitle:SetText(title)
end

function SetDialogTitleHidden(hide)
	ZO_InteractWindowTargetAreaTitle:SetHidden(hide)
end

function Clamp(n, min, max)
	return math.min(max, math.max(min, n))
end

function ColoredText(text, r, g, b)
	r = Clamp(r, 0, 255)
	g = Clamp(g, 0, 255)
	b = Clamp(b, 0, 255)
	
	return string.format("|c%.2X%.2X%.2X%s|r", r, g, b, text)
end

function UnderlinedText(text, r, g, b)
	solid_or_wavy = 0 -- solid(0), wavy(1)
	thickness = 2

	return string.format("|l%d:1:1:2:%d:%.2X%.2X%.2X|l%s|l",
		solid_or_wavy,
		thickness,
		r, g, b,
		text)
end

-- Register event handler
function PP.OnAddOnLoaded(event, addonName)
	if addonName == PP.name then
		PP:Initialize()
	end
end

-- Register event handler
EVENT_MANAGER:RegisterForEvent(PP.name, EVENT_ADD_ON_LOADED, PP.OnAddOnLoaded)
