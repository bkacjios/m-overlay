require("smash.enums")

local util = {}

function util.getTeamName(id)
	return TEAM_NAMES[id] or "UNKNOWN TEAM"
end

function util.getCharacterName(id)
	return CHARACTER_NAMES[id] or "UNKNOWN CHARACTER"
end

function util.getCSSCharacterName(id)
	return CHARACTER_NAMES_CSS[id] or "UNKNOWN CHARACTER"
end

function util.getInternalCharacterName(id)
	return CHARACTER_NAMES_INTERNAL[id] or "UNKNOWN CHARACTER"
end

function util.getStageName(id)
	return STAGE_NAMES[id] or "UNKNOWN STAGE"
end

return util