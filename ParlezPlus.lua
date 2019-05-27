
-- Config
local PP = ZO_Object:Subclass()
PP.name = "ParlezPlus"

-- AddOn Init
function PP:Initialize()
	self.inCombat = IsUnitInCombat("player")
	self.prevText = ""
	self.updateCount = 0

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, function (event, optionCount) self:OnDialogBegin(event, optionCount) self:OnDialogUpdate(event, optionCount) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_END, function (event) self:OnDialogEnd(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, function (event, optionBody, optionCount) self:OnDialogUpdate(event, optionCount) end)
	
end

-- NPC begins talking.
function PP:OnDialogBegin(event, optionsCount)
	self.prevText = ""
	self.updateCount = 0

end
--ZO_InteractWindowPlayerAreaOptions

function PP:HandleChatterOptionClicked(label)
	if label.optionIndex and type(label.optionIndex) == "number" then
		d("Great, OptionClicked: " .. label.optionIndex)
	else
		d("Great, OptionClicked: ???")
	end
end

local ihcoc = INTERACTION.HandleChatterOptionClicked
function INTERACTION:HandleChatterOptionClicked(label)
	ihcoc(INTERACTION, label)

	PP.HandleChatterOptionClicked(PP, label)
end

-- NPC continues talking.
function PP:OnDialogUpdate(event, optionCount)
	local name, text = GetDialogNameAndText()
	self.updateCount = self.updateCount + 1

	SetDialogText(self.prevText .. "\n\n--- --- --- --- ---\n\n" .. text)
	self.prevText = text

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
	
	--d(self.updateCount .. "| " .. name .. ": OnDialogUpdate(" .. optionCount .. ")")
end

-- NPC stopped talking.
function PP:OnDialogEnd(event)
	local name = GetDialogNameAndText()

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

-- Register event handler
function PP.OnAddOnLoaded(event, addonName)
	if addonName == PP.name then
		PP:Initialize()
	end
end

-- Register event handler
EVENT_MANAGER:RegisterForEvent(PP.name, EVENT_ADD_ON_LOADED, PP.OnAddOnLoaded)
