
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_CUSTOM )
	self:SetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.sprite = ents.Create("env_sprite")
	self.sprite:SetKeyValue("rendermode","5")
	self.sprite:SetKeyValue("renderamt","150")
	self.sprite:SetKeyValue("model","sprites/e-tele1.vmt")
	self.sprite:SetKeyValue("scale","4")
	self.sprite:SetKeyValue("spawnflags","1")
	self.sprite:SetPos(self:GetPos())
	self.sprite:SetParent(self)
	self.sprite:Spawn()
	self.sprite:Activate()
end

function ENT:OnRemove()
	if ValidEntity(self.sprite) then self.sprite:Remove() end
end

function ENT:Think()
end

function ENT:PhysicsCollide( data, physobj )
	return true
end

