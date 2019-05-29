
Response = {
	person = "",
	text = "",
	color = Defines.TextColor.NPCText,
	is_duplicate = false,
	from_player = false
}

function Response:new(r)
	r = r or {}
	setmetatable(r, self)
	self.__index = self
	return r
end

function Response:format()
	return ColoredText(
		self:getName()
		.. self:getText(), self.color[1], self.color[2], self.color[3]) .. "\n"
		.. self:getNewline()
end

function Response:getText()
	return self.text
end

function Response:getOwnLine()
	if self.from_player and Defines.Flags.PlayerNameOwnLine then
		return "\n"
	elseif self.from_player == false and Defines.Flags.NPCNameOwnLine then
		return "\n"
	end

	return ""
end

function Response:getNewline()
	if self.from_player and Defines.Flags.NewlineAfterPlayerText then
		return "\n"
	elseif self.from_player == false and Defines.Flags.NewlineAfterNPCText then
		return "\n"
	end

	return ""
end

function Response:getName()

	local display_name = nil
	local format_string = nil
	if self.from_player then
		display_name = Defines.Flags.DisplayPlayerName
		format_string = Defines.FormatString.PlayerNameFormat
	else
		display_name = Defines.Flags.DisplayNPCName
		format_string = Defines.FormatString.NPCNameFormat
	end

	if not display_name then
		return ""
	end

	return Defines.Format(format_string, {
		name = self.person,
		color = self.color})
		.. self:getOwnLine()
end
