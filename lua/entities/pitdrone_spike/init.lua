
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	timer.Simple(8,function() if ValidEntity(self) then self:Remove() end end)
	self:SetModel("models/pit_drone_spike.mdl")
	self:PhysicsInitBox( Vector(-6,-6,-6), Vector(6,6,6) )
	self:SetCollisionBounds(Vector(-6,-6,-6), Vector(6,6,6)) 
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_CUSTOM )
	self:SetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 1 )
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio( 0.1 )
		phys:Wake()
	end
end

function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:PhysicsCollide( data, physobj )
	if !data.HitEntity then return true end
	
	if !data.HitEntity:IsPlayer() and !data.HitEntity:IsNPC() then self:EmitSound( "weapons/crossbow/hit1.wav", 100, 100 ); self:Remove(); return true end
	self.owner = self.owner or self
	data.HitEntity.attacker = self.owner
	data.HitEntity.inflictor = self
	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( sk_pitdrone_spike_value, self.owner, self )
	elseif( ( ValidEntity( self.owner ) and ( self.owner:Disposition( data.HitEntity ) == 1 or self.owner:Disposition( data.HitEntity ) == 2 ) ) and data.HitEntity:GetClass() != "npc_turret_floor" ) then
		data.HitEntity:TakeDamage( sk_pitdrone_spike_value, self.owner, self )
	elseif( data.HitEntity:GetClass() == "npc_turret_floor" ) then
		data.HitEntity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) )
		data.HitEntity:Fire( "selfdestruct", "", 0 )
	end
	self:EmitSound( "weapons/crossbow/hitbod" .. math.random(1,2) .. ".wav", 100, 100 )
	self:Remove()
		
	return true
end

