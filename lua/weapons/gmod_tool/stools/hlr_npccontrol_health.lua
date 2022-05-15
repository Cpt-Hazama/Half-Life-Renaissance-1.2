TOOL.Category = "NPC Control"
TOOL.Name = "NPC Health"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["SETHEALTH"] = "100"

if (CLIENT) then
   language.Add("Tool_hlr_npccontrol_health_name", "NPC Health")
   language.Add("Tool_hlr_npccontrol_health_desc", "Change an NPC's health")
   language.Add("Tool_hlr_npccontrol_health_0", "Left-Click to change an NPC's health")
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Slider", {Label = "Health: ", min = 1, max = 5000, Command = "HLR_NPCCONTROL_HEALTH_SETHEALTH"})
end

function TOOL:LeftClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCHEALTH and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end

	if ValidEntity(trace.Entity) and trace.Entity:IsNPC() then
		trace.Entity:SetHealth(self:GetClientNumber("SETHEALTH"))
		local ply = self:GetOwner()
		ply:SendLua("GAMEMODE:AddNotify(\"" .. "Set health of NPC " .. trace.Entity:GetClass() .. " to " .. trace.Entity:Health() .. "\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
		return true
	end
end

