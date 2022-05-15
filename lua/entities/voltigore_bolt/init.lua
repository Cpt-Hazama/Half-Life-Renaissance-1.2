
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	timer.Simple(8,function() if ValidEntity(self) then self:Remove() end end)
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_CUSTOM )
	self:SetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass( 1 )
		phys:EnableGravity( false )
		phys:EnableDrag( false )
		phys:Wake()
	end
	
	self.beams = {}
	for i = 1,3 do
		local beam = ents.Create("env_beam")
		beam:SetPos(self:GetPos() +self:GetForward() *40)
		beam:SetParent(self)
		beam:SetName(tostring(self) .. "_laser" .. beam:EntIndex())
		beam:SetKeyValue("life","0.06")
		beam:SetKeyValue("Radius","512")
		beam:SetKeyValue("LightningStart",tostring(self) .. "_laser" .. beam:EntIndex())
		beam:SetKeyValue("NoiseAmplitude","8")
		beam:SetKeyValue("renderamt","200")
		beam:SetKeyValue("rendercolor","244 55 244")
		beam:SetKeyValue("BoltWidth","1.4")
		beam:SetKeyValue("texture","sprites/laserbeam.spr")
		beam:SetKeyValue("spawnflags","5")
		beam:SetKeyValue("StrikeTime","0")
		beam:SetKeyValue("TextureScroll","35")
		beam:Spawn()
		beam:Activate()
		beam:Fire("TurnOn","",0)
		
		table.insert(self.beams,beam)
	end
end

function ENT:OnRemove()
	for k, v in pairs(self.beams) do
		if ValidEntity(v) then v:Remove() end
	end
end

function ENT:Think()
end

function ENT:PhysicsCollide( data, physobj )
	if !data.HitEntity or self.hitentity then return true end
	local function StopMoving()
		physobj:SetVelocity(Vector(0,0,0))
		timer.Simple(0.6, function() self:Remove() end)
		self.hitentity = true
	end
	if not data.HitEntity:IsPlayer() and not data.HitEntity:IsNPC() then StopMoving(); return true end
	self.owner = self.owner or self
	data.HitEntity.attacker = self.owner
	data.HitEntity.inflictor = self
	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( sk_voltigore_shock_value, self.owner, self )
	elseif( ( ValidEntity( self.owner ) and ( self.owner:Disposition( data.HitEntity ) == 1 or self.owner:Disposition( data.HitEntity ) == 2 ) ) and data.HitEntity:GetClass() != "npc_turret_floor" ) then
		data.HitEntity:TakeDamage( sk_voltigore_shock_value, self.owner, self )
	elseif( data.HitEntity:GetClass() == "npc_turret_floor" ) then
		data.HitEntity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) )
		data.HitEntity:Fire( "selfdestruct", "", 0 )
	end
	StopMoving()
		
	return true
end

