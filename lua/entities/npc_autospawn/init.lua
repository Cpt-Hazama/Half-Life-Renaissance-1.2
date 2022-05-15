
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:DrawShadow(false)
	self.delay = CurTime() +self.spawndelay
	self.ents = {}
	numpad.OnDown( self.owner, self.turnonkey, "NPCAutoSpawnTurnOn", self )
	numpad.OnDown( self.owner, self.turnoffkey, "NPCAutoSpawnTurnOff", self )
	
	local function TurnOn(pl,ent,pid)
		if !ValidEntity(ent) then return end
		ent:Fire("turnon","",0)
	end
	
	local function TurnOff(pl,ent,pid)
		if !ValidEntity(ent) then return end
		ent:Fire("turnoff","",0)
	end
	
	numpad.Register("NPCAutoSpawnTurnOn", TurnOn)
	numpad.Register("NPCAutoSpawnTurnOff", TurnOff)
	
	self.effectscript = ents.Create("env_effectscript")
	self.effectscript:SetPos(self:GetPos())
	self.effectscript:SetParent(self)
	self.effectscript:SetModel("models/Effects/teleporttrail_Alyx.mdl")
	self.effectscript:SetKeyValue("scriptfile", "scripts/effects/testeffect.txt")
	self.effectscript:Spawn()
	self.effectscript:Activate()
	self.effectscript:Fire("SetSequence", "teleport", 0)
	
	self.effectdelay = CurTime() +8
end

function ENT:SpawnNPC()
	local tbl_new = {}
	for k, v in pairs(self.ents) do
		if ValidEntity(v) and v:Health() > 0 then
			table.insert(tbl_new,v)
		end
	end
	self.ents = tbl_new
	
	if #self.ents >= self.maxnpcs then return end
	self:EmitSound("beams/beamstart5.wav", 100, 100)
	local SpawnAngles = Angle(0,self:GetAngles().y,0)
	local SpawnPos = self:GetPos() +self:GetUp() *25
	local npc = ents.Create(self.class)
	npc:SetPos(SpawnPos)
	npc:SetAngles(SpawnAngles)
	npc:Spawn()
	npc:Activate()
	
	table.insert(self.ents, npc)
	
	/*local sprite = ents.Create("env_sprite")
	sprite:SetKeyValue("rendermode", "5")
	sprite:SetKeyValue("model", "sprites/exit1.vmt")
	sprite:SetKeyValue("scale", "0.4")
	sprite:SetKeyValue("spawnflags", "1")
	sprite:SetPos(SpawnPos +Vector(0,0,15))
	sprite:Spawn()
	sprite:Activate()
	sprite:Fire("kill","",0.3)*/
	
	if !self.squad then return end
	npc.squadtable = {}
	npc.squad = self.squad
	npc:SetupSquad()
end

function ENT:Think()
	if CurTime() > self.effectdelay then self.effectscript:Fire("SetSequence", "teleport", 0); self.effectdelay = CurTime() +8 end

	if self.disabled then return end
	if CurTime() > self.delay then self:SpawnNPC(); self.delay = CurTime() +self.spawndelay end
end

function ENT:AcceptInput( cvar_name, activator, caller )
	if cvar_name == "turnon" then
		self.disabled = false
		self.delay = CurTime() +self.spawndelay
	elseif cvar_name == "turnoff" then
		self.disabled = true
	end
end

function ENT:OnRemove()
	self.effectscript:Remove()
	if self.autoremove then
		for k, v in pairs(self.ents) do
			if ValidEntity(v) then v:Remove() end
		end
	end
end