
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	timer.Simple(32,function() if ValidEntity(self) then self:Remove() end end)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_CUSTOM )
	self:SetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.ai_sound = ents.Create( "ai_sound" )
	self.ai_sound:SetPos( self:GetPos() )
	self.ai_sound:SetKeyValue( "volume", "80" )
	self.ai_sound:SetKeyValue( "duration", "8" )
	self.ai_sound:SetKeyValue( "soundtype", "8" )
	self.ai_sound:SetParent( self )
	self.ai_sound:Spawn()
	self.ai_sound:Activate()
	self.ai_sound:Fire( "EmitAISound", "", 0 )
	
	self.sprite = ents.Create("env_sprite")
	self.sprite:SetKeyValue("rendermode","9")
	self.sprite:SetKeyValue("renderamt","255")
	self.sprite:SetKeyValue("model","sprites/d-tele1.vmt")
	self.sprite:SetKeyValue("scale","1.5")
	self.sprite:SetKeyValue("spawnflags","1")
	self.sprite:SetPos(self:GetPos())
	self.sprite:SetParent(self)
	self.sprite:Spawn()
	self.sprite:Activate()
	
	self.nextdamage = CurTime()
	self.beams = {}
end

function ENT:OnRemove()
	if ValidEntity(self.sprite) then self.sprite:Remove() end
	self.ai_sound:Remove()
	for k, v in pairs(self.beams) do
		for l, w in pairs(v) do
			w:Remove()
		end
	end
end

function ENT:Think()
	if ValidEntity(self.enemy) then
		self.Entity:GetPhysicsObject():ApplyForceCenter( (((self.enemy:NearestPoint( self.enemy:GetPos() + Vector(0,0,1000) ) + self.enemy:NearestPoint( self.enemy:GetPos() + Vector(0,0,-1000) )) / 2 ) - self.Entity:GetPos()):GetNormal() * self.Speed )
	end
end

function ENT:PhysicsCollide( data, physobj )
	if not data.HitEntity then return true end
	
	if not data.HitEntity:IsPlayer() and not data.HitEntity:IsNPC() then self:EmitSound( "npc/controller/electro4.wav", 100, 100 ); self:Remove(); return true end
	self.owner = self.owner or self
	data.HitEntity.attacker = self.owner
	data.HitEntity.inflictor = self
	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( 100, self.owner, self )
	elseif( ( ValidEntity( self.owner ) and ( self.owner:Disposition( data.HitEntity ) == 1 or self.owner:Disposition( data.HitEntity ) == 2 ) ) and data.HitEntity:GetClass() != "npc_turret_floor" ) then
		data.HitEntity:TakeDamage( 100, self.owner, self )
	elseif( data.HitEntity:GetClass() == "npc_turret_floor" ) then
		data.HitEntity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) )
		data.HitEntity:Fire( "selfdestruct", "", 0 )
	end
	self:EmitSound( "npc/controller/electro4.wav", 100, 100 )
	self:Remove()
		
	return true
end

