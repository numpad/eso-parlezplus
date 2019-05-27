
-- Config
local PP = ZO_Object:Subclass()
PP.name = "ParlezPlus"

-- AddOn Init
function PP:Initialize()
	self.inCombat = IsUnitInCombat("player")
	self.prevText = ""

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, function (event, optionCount) self.OnDialogBegin(event, optionCount) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_END, function (event) self.OnDialogEnd(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, function (event, bodyText, optionCount) self.OnDialogUpdate(event, bodyText, optionCount) end)

end

-- Begin Talking to NPC
function PP.OnDialogBegin(event, optionsCount)
	local name, text = GetDialogNameAndText()

	--d(name .. " says: " .. text)
	d(name .. " OnDialogBegin(" .. optionsCount .. ")")
end

-- NPC continues talking.
function PP.OnDialogUpdate(event, bodyText, optionCount)
	local name, text = GetDialogNameAndText()
	
	d(name .. "OnDialogUpdate(" .. optionCount .. ")")
end

-- NPC stopped talking.
function PP.OnDialogEnd(event)
	local name, text = GetDialogNameAndText()
	
	--d(name .. " says: " .. text)
	d(name .. " OnDialogEnd")
end

-- Helper functions
function GetDialogNameAndText()
	local name = string.sub(ZO_InteractWindowTargetAreaTitle:GetText(), 2, -2)
	local text = ZO_InteractWindowTargetAreaBodyText:GetText()

	return name, text
end

-- Register event handler
function PP.OnAddOnLoaded(event, addonName)
	if addonName == PP.name then
		PP:Initialize()
	end
end

-- Register event handler
EVENT_MANAGER:RegisterForEvent(PP.name, EVENT_ADD_ON_LOADED, PP.OnAddOnLoaded)
