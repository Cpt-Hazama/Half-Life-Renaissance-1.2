
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
	if !self.scale then self.scale = "1" end
	self.sprite = ents.Create("env_sprite")
	self.sprite:SetKeyValue("rendermode", "5")
	self.sprite:SetKeyValue("model", "sprites/muz2.spr")
	self.sprite:SetKeyValue("scale", self.scale)
	self.sprite:SetKeyValue("spawnflags", "1")
	self.sprite:SetPos(self:GetPos())
	self.sprite:SetParent(self)
	self.sprite:Spawn()
	self.sprite:Activate()
end

function ENT:Absorb()
	self.radius = 0
	self.speed = self.speed *2
	self.ab_beam_target = ents.Create("info_target")
	self.ab_beam_target:SetName(tostring(self.owner) .. "_laser" .. self.ab_beam_target:EntIndex() .. "_target")
	self.ab_beam_target:Spawn()
	self.ab_beam_target:Activate()
	self.ab_beam_target:SetParent(self.owner)
	self.ab_beam_target:Fire("SetParentAttachment", "0",0)

	self.ab_beam = ents.Create("env_beam")
	self.ab_beam:SetName(tostring(self.owner) .. "_laser" .. self.ab_beam:EntIndex())
	self.ab_beam:SetKeyValue("life","0")
	self.ab_beam:SetKeyValue("LightningEnd",tostring(self.owner) .. "_laser" .. self.ab_beam_target:EntIndex() .. "_target")
	self.ab_beam:SetKeyValue("LightningStart",tostring(self.owner) .. "_laser" .. self.ab_beam:EntIndex())
	self.ab_beam:SetKeyValue("NoiseAmplitude","0.75")
	self.ab_beam:SetKeyValue("renderamt","255")
	self.ab_beam:SetKeyValue("rendercolor","255 149 43")
	self.ab_beam:SetKeyValue("BoltWidth","4")
	self.ab_beam:SetKeyValue("texture","sprites/laserbeam.spr")
	self.ab_beam:SetKeyValue("spawnflags","1")
	self.ab_beam:SetKeyValue("TextureScroll","35")
	self.ab_beam:SetPos(self:GetPos())
	self.ab_beam:SetParent(self)
	self.ab_beam:Spawn()
	self.ab_beam:Activate()
	timer.Simple(8, function() if ValidEntity(self) then self:Remove() end end)
end

function ENT:OnRemove()
	if ValidEntity(self.ab_beam) then self.ab_beam:Remove() end
	if ValidEntity(self.ab_beam_target) then self.ab_beam_target:Remove() end
	if ValidEntity(self.sprite) then self.sprite:Remove() end
end

function ENT:Think()
	if !ValidEntity(self.owner) then self:Remove(); return end
	local Pos = self.owner:GetPos() +self.owner:GetForward() *100
	local filter = {self,self.owner}
	if self.owner.hull then table.insert(filter,self.owner.hull) end
	local Trace = util.QuickTrace(Pos, Vector(0, 0, 70), filter)
			
	Pos.z = Pos.z + Trace.Fraction *self.height
			
	local AimVec = self.owner:GetForward()//GetAimVector()
	AimVec.z = AimVec.z/-3
	Pos = Pos + AimVec * -80
			
	local Offset = 6.2832
	if self.direction == "right" then
		Pos.x = Pos.x + math.cos(CurTime() + self.delay + Offset) *self.radius
		Pos.y = Pos.y + math.sin(CurTime() + self.delay + Offset) *self.radius
	else
		Pos.x = Pos.x + math.sin(CurTime() + self.delay + Offset) *self.radius
		Pos.y = Pos.y + math.cos(CurTime() + self.delay + Offset) *self.radius
	end
		
	Pos.z = Pos.z + math.sin(CurTime()) * 10
			
	local Angle = Pos - self:GetPos()
	local Distance = Angle:Length()
	local PhysObj = self:GetPhysicsObject()
	local Velocity = PhysObj:GetVelocity()

	PhysObj:ApplyForceCenter(Angle * Distance/self.speed + Velocity/3 * -1)
end

function ENT:PhysicsCollide( data, physobj )
	return true
end

