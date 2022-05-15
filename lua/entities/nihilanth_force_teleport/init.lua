
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
	self.sprite:SetKeyValue("rendermode","5")
	self.sprite:SetKeyValue("renderamt","200")
	self.sprite:SetKeyValue("model","sprites/exit1.vmt")
	self.sprite:SetKeyValue("scale","3")
	self.sprite:SetKeyValue("spawnflags","1")
	self.sprite:SetPos(self:GetPos())
	self.sprite:SetParent(self)
	self.sprite:Spawn()
	self.sprite:Activate()
	
	self.sound = CreateSound(self, "x/x_teleattack1.wav")
	self.sound:Play()
end

function ENT:OnRemove()
	self.sound:Stop()
	if ValidEntity(self.sprite) then self.sprite:Remove() end
	self.ai_sound:Remove()
end

function ENT:Think()
	if !ValidEntity(self.enemy) then return end
	self:GetPhysicsObject():SetVelocity((self.enemy:GetPos() -self:GetPos()):GetNormal() *self.Speed)
end

function ENT:PhysicsCollide( data, physobj )
	if not data.HitEntity then return true end
	
	if not data.HitEntity:IsPlayer() and not data.HitEntity:IsNPC() then self:EmitSound( "npc/controller/electro4.wav", 100, 100 )
		local rand = math.random(1,4)
		if rand != 4 then
			local tracedata = {}
			tracedata.start = self:GetPos()
			tracedata.endpos = self:GetPos() -Vector(0,0,600)
			tracedata.filter = self
			local trace = util.TraceLine(tracedata)
			if trace.HitWorld then
				self:EmitSound("debris/beamstart7.wav", 100, 100)
				local rand = math.random(1,3)
				local ent
				if rand == 1 then ent = "monster_alien_controller"
				elseif rand == 2 then ent = "monster_alien_grunt"
				else ent = "monster_alien_slave" end
				local npc = ents.Create(ent)
				npc:SetPos(self:GetPos() -data.HitNormal *50)
				if ValidEntity(self.owner) then
					npc.enemy_memory = self.owner.enemy_memory
					if ValidEntity(self.owner.enemy) then
						npc.enemy = self.owner.enemy
					end
					npc:SetOwner(self.owner.hull)
				end
				npc:Spawn()
				npc:Activate()
			end
		end
		self:Remove()
		return true
	end
	self.owner = self.owner or self
	data.HitEntity.attacker = self.owner
	data.HitEntity.inflictor = self
	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( data.HitEntity:Health(), self.owner, self )
	elseif( ( ValidEntity( self.owner ) and ( self.owner:Disposition( data.HitEntity ) == 1 or self.owner:Disposition( data.HitEntity ) == 2 ) ) and data.HitEntity:GetClass() != "npc_turret_floor" ) then
		data.HitEntity:TakeDamage( data.HitEntity:Health(), self.owner, self )
	elseif( data.HitEntity:GetClass() == "npc_turret_floor" ) then
		data.HitEntity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) )
		data.HitEntity:Fire( "selfdestruct", "", 0 )
	end
	self:EmitSound( "npc/controller/electro4.wav", 100, 100 )
	self:Remove()
		
	return true
end

