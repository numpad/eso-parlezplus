
local PP = ZO_Object:Subclass()
PP.name = "ParlezPlus"

function PP:Initialize()
	self.inCombat = IsUnitInCombat("player")
	self.prevText = ""

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, function (event) self.OnDialogBegin(event) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, function (event) self.OnDialogBegin(event) end)

end


function PP.OnAddOnLoaded(event, addonName)
	if addonName == PP.name then
		PP:Initialize()
	end
end

function PP.OnDialogBegin(event)
	local name = string.sub(ZO_InteractWindowTargetAreaTitle:GetText(), 2, -2)
	local text = ZO_InteractWindowTargetAreaBodyText:GetText()

	d(name .. " says: " .. text)
end

function PP.OnDialogUpdate(event)

end

-- Register event hanlder
EVENT_MANAGER:RegisterForEvent(PP.name, EVENT_ADD_ON_LOADED, PP.OnAddOnLoaded)
