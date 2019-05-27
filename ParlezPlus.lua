
-- Config
local PP = ZO_Object:Subclass()
PP.name = "ParlezPlus"

-- AddOn Init
function PP:Initialize()
	self.prevText = ""
	self.response = ""

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, 			function (event) self:OnDialogBegin(event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, 	function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_OFFERED, 			function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE_DIALOG, 	function (event) self:OnDialogUpdate(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_END, 			function (event) self:OnDialogEnd(event) end)
	
end

-- NPC begins talking.
function PP:OnDialogBegin(event, optionsCount)
	self.prevText = ""
	self.response = ""
	SetDialogTitleHidden(true)
end

-- NPC continues talking.
function PP:OnDialogUpdate(event, optionCount)
	local name, text = GetDialogNameAndText()
	local playerName = GetUnitName("player")
	local npcName = GetUnitName("interact")

	SetDialogTitle("Unterhaltung mit " .. npcName)
	if self.response ~= "" and self.prevText ~= "" then
		SetDialogText(npcName .. ": " .. self.prevText .. "\n\n\n"
			.. playerName .. ": " .. self.response .. "\n\n\n"
			.. npcName .. ": " .. text)

	else
		-- begins talking
		SetDialogText(npcName .. ": " .. text)

	end

	self.prevText = text

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
end


function PP:HandleChatterOptionClicked(label)
	if label.optionIndex and type(label.optionIndex) == "number" then
		-- d("index: " .. label.optionIndex)
		-- d("text: " .. label.optionText)

		self.response = label.optionText

	end
end

-- Add additional callback handler for ChatterOptionClicked
local ihcoc = INTERACTION.HandleChatterOptionClicked
function INTERACTION:HandleChatterOptionClicked(label)
	-- call base handler
	ihcoc(INTERACTION, label)

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

-- Register event handler
function PP.OnAddOnLoaded(event, addonName)
	if addonName == PP.name then
		PP:Initialize()
	end
end

-- Register event handler
EVENT_MANAGER:RegisterForEvent(PP.name, EVENT_ADD_ON_LOADED, PP.OnAddOnLoaded)
