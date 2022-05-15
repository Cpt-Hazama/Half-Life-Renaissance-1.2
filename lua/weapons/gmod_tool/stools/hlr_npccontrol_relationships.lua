TOOL.Category = "NPC Control"
TOOL.Name = "NPC Relationships"
TOOL.Command = nil
TOOL.ConfigName = ""

if (CLIENT) then
   language.Add("Tool_hlr_npccontrol_relationships_name", "NPC Relationships")
   language.Add("Tool_hlr_npccontrol_relationships_desc", "Change an NPC's relationship to a target")
   language.Add("Tool_hlr_npccontrol_relationships_0", "Left-Click to select the source NPC, Right-Click on the target to apply the relationship")
end

function TOOL.BuildCPanel(panel)
	local label = {}
	label.Text = "Disposition:"
	panel:AddControl("Label", label)
	
	local rls = {}
	table.insert(rls, "Like")
	table.insert(rls, "Hate")
	table.insert(rls, "Fear")
	table.insert(rls, "Neutral")
	local listbox = {}
	listbox.Label = "TOOL_HLR_NPCCONROL_RELATIONSHIPS_DISPOSITION"
	listbox.MenuButton = false
	listbox.Options = {}
	for k, v in pairs(rls) do
		listbox.Options[v] = {HLR_NPCCONTROL_RELATIONSHIPS_SETDISPOSITION = v}
	end
	panel:AddControl("ComboBox", listbox)
	
	local slider = {}
	slider.Label = "Priority"
	slider.min = 1
	slider.max = 100
	slider.Type = "Integer"
	slider.Command = "TOOL_HLR_NPCCONROL_RELATIONSHIPS_SETPRIORITY"
	panel:AddControl("Slider", slider)
end

function TOOL:LeftClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end

	if ValidEntity(trace.Entity) and trace.Entity:IsNPC() then
		local ply = self:GetOwner()
		ply:SendLua("GAMEMODE:AddNotify(\"Selected NPC " .. trace.Entity:GetClass() .. "\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
		self.NPC = trace.Entity
		return true
	end
end

function TOOL:RightClick(trace)
	if CLIENT then return end
	if !ValidEntity(trace.Entity) or (!trace.Entity:IsNPC() and !trace.Entity:IsPlayer()) then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end
	if !ValidEntity(self.NPC) then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"You have to select a source NPC first\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return
	end
	if !HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"No disposition set!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return
	end
	local disp
	Msg( "HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION = " .. HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION .. "\n" )
	if HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION == "Like" then
		disp = 3
	elseif HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION == "Hate" then
		disp = 1
	elseif HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION == "Fear" then
		disp = 2
	elseif HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION == "Neutral" then
		disp = 4
	end
	self.NPC:AddEntityRelationship( trace.Entity, disp, TOOL_HLR_NPCCONROL_RELATIONSHIPS_PRIORITY )
	self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Set relationship of " .. self.NPC:GetClass() .. " to " .. trace.Entity:GetClass() .. " to: " .. string.upper(HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION) .. "\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
end

