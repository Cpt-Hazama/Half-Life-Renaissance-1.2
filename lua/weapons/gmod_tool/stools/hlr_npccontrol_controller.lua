TOOL.Category = "NPC Control"
TOOL.Name = "NPC Controller"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.nextthink = 0

TOOL.ClientConVar["WALK"] = 0
TOOL.ClientConVar["CANATTACK"] = 0
TOOL.ClientConVar["NPCSELECTED"] = 0

if (CLIENT) then
	language.Add("Tool_hlr_npccontrol_controller_name", "NPC Controller")
	language.Add("Tool_hlr_npccontrol_controller_desc", "Control a NPC")
	language.Add("Tool_hlr_npccontrol_controller_0", "Left-Click to de/select a NPC, or make the selected NPC move to a position/attack a NPC; Right-Click to possess the selected NPC")
	
	function TOOL:DrawHUD()
		if self:GetClientNumber("NPCSELECTED") == 0 then return end
		local tex = surface.GetTextureID("HUD/crosshairs/hlr_stool_commander_crosshair1")
		if self:GetClientNumber("CANATTACK") == 0 then
			tex = surface.GetTextureID("HUD/crosshairs/hlr_stool_commander_crosshair2")
		end
		surface.SetTexture(tex)
		surface.SetDrawColor(255,0,0,255)
		surface.DrawTexturedRect(ScrW() *0.5 -12, ScrH() *0.5 -12, 24, 24 )
	end
end

function TOOL:Think()
	if self.NPC and !self.NPC:IsValid() then self.NPC = nil; self:GetOwner():ConCommand("HLR_NPCCONTROL_CONTROLLER_NPCSELECTED 0") end
	if SERVER or self:GetClientNumber("NPCSELECTED") == 0 or CurTime() < self.nextthink then return end
	self.nextthink = CurTime() +0.1
	local canattack = self:GetClientNumber("CANATTACK")
	local ply = self:GetOwner()
	local pos = ply:GetShootPos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +ply:GetAimVector() *9999
	tracedata.filter = ply
	local trace = util.TraceLine(tracedata)
	if ValidEntity(trace.Entity) and trace.Entity:IsNPC() then
		if canattack == 0 then ply:ConCommand("HLR_NPCCONTROL_CONTROLLER_CANATTACK 1") end
	elseif canattack == 1 then ply:ConCommand("HLR_NPCCONTROL_CONTROLLER_CANATTACK 0") end
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("CheckBox", {Label = "Walk to position", Command = "HLR_NPCCONTROL_CONTROLLER_WALK"})
end

function TOOL:StartControl(ent)
	self.NPC = ent
	
	if self.NPC:Disposition(self:GetOwner()) != 1 then
		self.NPC_alliedwithply = true
	end
	
	if self.NPC.scripted then
		self.NPC.enemyTable_old = self.NPC.enemyTable
		self.NPC.enemyTable = {}
		self.NPC.enemy_memory = {}
		self.NPC.enemy = nil
	end
	for k, v in pairs(GetAllNPCClasses()) do
		self.NPC:AddRelationship(v .. " D_LI 100")
	end
	self.NPC.controlled = true
end

local relationships = {}
relationships["D_LI"] = {}
relationships["D_LI"]["combine"] = {"npc_combine_s", "npc_cscanner", "npc_hunter", "npc_manhack", "npc_mortarsynth", "npc_rollermine", "npc_clawscanner", "npc_turret_floor", "npc_metropolice"}
relationships["D_LI"]["zombies"] = {"npc_fastzombie_torso", "npc_fastzombie",  "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "monster_babycrab", "monster_headcrab", "monster_bigmomma", "monster_gonome", "monster_zombie", "monster_zombie_barney", "monster_zombie_soldier"}
relationships["D_LI"]["humans"] = {"npc_gman", "monster_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_breen", "npc_dog", "npc_eli", "npc_fisherman", "monster_scientist", "monster_sitting_scientist", "npc_kleiner", "npc_magnusson", "npc_mossman", "player", "npc_dobermann", "monster_barney"}
relationships["D_LI"]["antlion"] = {"npc_antlion", "npc_antlion_worker", "npc_antlionguard"}

function TOOL:StopControl()
	if !ValidEntity(self.NPC) then return end
	if self.NPC.scripted then
		self.NPC.enemyTable = self.NPC.enemyTable_old
		self.NPC.enemyTable_old = nil
	else
		for k, v in pairs(GetAllNPCClasses()) do
			self.NPC:AddRelationship(v .. " D_HT 100")
		end
		for k, v in pairs(relationships["D_LI"]) do
			if table.HasValue(v, self.NPC:GetClass()) then
				for k, v in pairs(v) do
					self.NPC:AddRelationship(v .. " D_LI 100")
				end
			end
		end
	end
	self.NPC.controlled = false
	self:GetOwner():ConCommand("HLR_NPCCONTROL_CONTROLLER_NPCSELECTED 0")
	
	if !self.NPC_alliedwithply then
		for k, v in pairs(player:GetAll()) do
			self.NPC:AddEntityRelationship( v, 1, 10 )
		end
	end
	self.NPC = nil
	self.NPC_alliedwithply = nil
end

function TOOL:LeftClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCCONTROLLER and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end
	if ValidEntity(trace.Entity) and (trace.Entity:IsNPC() or trace.Entity:IsPlayer()) then
		local ply = self:GetOwner()
		if trace.Entity:IsNPC() then
			if !self.NPC then
				if trace.Entity.controlled then
					ply:SendLua("GAMEMODE:AddNotify(\"You can't control this NPC, it's already controlled by someone else!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
					return false
				elseif trace.Entity.possessed then
					ply:SendLua("GAMEMODE:AddNotify(\"You can't control this NPC, it's possessed by " .. trace.Entity.master:GetName() .. "!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
					return false
				end
				ply:SendLua("GAMEMODE:AddNotify(\"" .. "NPC " .. trace.Entity:GetClass() .. " selected!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
				self:StartControl(trace.Entity)
				for k, v in pairs(player:GetAll()) do
					self.NPC:AddEntityRelationship( v, 3, 10 )
				end
				ply:ConCommand("HLR_NPCCONTROL_CONTROLLER_NPCSELECTED 1")
				return true
			elseif self.NPC == trace.Entity then
				ply:SendLua("GAMEMODE:AddNotify(\"" .. "NPC " .. trace.Entity:GetClass() .. " deselected!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
				self:StopControl()
				return true
			end
		end
		if trace.Entity != self.NPC then
			ply:SendLua("GAMEMODE:AddNotify(\"Set " .. trace.Entity:GetClass() .. " to enemy!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button14.wav\" )") 
			trace.Entity:AddEntityRelationship( self.NPC, 1, 10 )
			self.NPC:AddEntityRelationship( trace.Entity, 1, 10 )
			self.NPC.enemy = trace.Entity
			self.NPC:SetEnemy(trace.Entity)
			self.NPC:SetLastPosition(trace.Entity:GetPos())
		end
	elseif self.NPC then
		local schedule = SCHED_FORCED_GO_RUN
		if self:GetClientNumber("WALK") == 1 then
			schedule = SCHED_FORCED_GO
		end
		self.NPC:SetLastPosition(trace.HitPos)
		self.NPC:SetSchedule(schedule)
	end
end

function TOOL:RightClick( trace )
	if CLIENT then return end
	if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCCONTROLLER and !self:GetOwner():IsAdmin() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return false
	end
	if !ValidEntity(self.NPC) then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"You have to select a NPC first\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
		return
	end
	if self:GetOwner():PossessNPC(self.NPC, true) then self:StopControl() end
end

function TOOL:Holster()
	if ValidEntity(self.NPC) then
		self:StopControl()
	end
end