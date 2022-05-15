TOOL.Category = "NPC Control"
TOOL.Name = "NPC Movement"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.NPCs = {}

TOOL.ClientConVar["WALK"] = 0

if (CLIENT) then
	language.Add("Tool_hlr_npccontrol_move_name", "NPC Movement")
	language.Add("Tool_hlr_npccontrol_move_desc", "Make a NPC move to a position")
	language.Add("Tool_hlr_npccontrol_move_0", "Left-Click to de/select a NPC, Right-Click to make it move")
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("CheckBox", {Label = "Walk to position", Command = "HLR_NPCCONTROL_MOVE_WALK"})
end

function TOOL:LeftClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCMOVEMENT and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end
	if ValidEntity(trace.Entity) and trace.Entity:IsNPC() and !table.HasValue(self.NPCs, trace.Entity) then
		local ply = self:GetOwner()
		ply:SendLua("GAMEMODE:AddNotify(\"" .. "NPC " .. trace.Entity:GetClass() .. " selected!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
		table.insert(self.NPCs, trace.Entity)
		return true
	elseif table.HasValue(self.NPCs, trace.Entity) then
		local tbl_new = {}
		for k, v in pairs(self.NPCs) do
			if v != trace.Entity then
				table.insert(tbl_new,v)
			end
		end
		self.NPCs = tbl_new
		local ply = self:GetOwner()
		ply:SendLua("GAMEMODE:AddNotify(\"" .. "NPC " .. trace.Entity:GetClass() .. " deselected!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
		return true
	end
end

function TOOL:RightClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCMOVEMENT and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end
	for k, v in pairs(self.NPCs) do
		if ValidEntity(v) then
			local schedule = SCHED_FORCED_GO_RUN
			if self:GetClientNumber("WALK") == 1 then
				schedule = SCHED_FORCED_GO
			end
            v:SetLastPosition(trace.HitPos)
            v:SetSchedule(schedule)
		end
	end
end