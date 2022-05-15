
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
	self.sprite:SetKeyValue("rendermode","5")
	self.sprite:SetKeyValue("renderamt","255")
	self.sprite:SetKeyValue("model","sprites/nhth1.vmt")
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
			if ValidEntity(w) then
				w:Remove()
			end
		end
	end
end

function ENT:Think()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
		if ValidEntity(v) and (!ValidEntity(self.owner) or (v != self.owner and (self.owner:Disposition(v) == 1 or self.owner:Disposition(v) == 2))) and (v:IsNPC() or v:IsPlayer()) and !self.beams[v] then
			self:CreateBeam(v)
		end
	end
	local hit
	for k, v in pairs(self.beams) do
		if !ValidEntity(k) or k:Health() <= 0 or k:GetPos():Distance(self:GetPos()) > 256 then
			self:RemoveBeam(k)
		elseif CurTime() >= self.nextdamage then
			hit = true
			k:TakeDamage(3, self.owner, self)
		end
	end
	if hit then self.nextdamage = CurTime() +0.25 end
end

function ENT:RemoveBeam(ent)
	local tbl_new = {}
	for k, v in pairs(self.beams) do
		if k != ent then
			tbl_new[k] = v
		else
			for k, v in pairs(self.beams[ent]) do
				v:Remove()
			end
		end
	end
	self.beams = tbl_new
end

function ENT:CreateBeam(ent)
	local beam_target = ents.Create("info_target")
	beam_target:SetName(tostring(self.owner) .. "_laser" .. beam_target:EntIndex() .. "_target")
	beam_target:Spawn()
	beam_target:Activate()
	beam_target:SetPos(ent:GetPos())
	beam_target:SetParent(ent)

	local beam = ents.Create("env_beam")
	beam:SetName(tostring(self.owner) .. "_laser" .. beam:EntIndex())
	beam:SetKeyValue("life","0")
	beam:SetKeyValue("LightningEnd",tostring(self.owner) .. "_laser" .. beam_target:EntIndex() .. "_target")
	beam:SetKeyValue("LightningStart",tostring(self.owner) .. "_laser" .. beam:EntIndex())
	beam:SetKeyValue("NoiseAmplitude","4")
	beam:SetKeyValue("renderamt","255")
	beam:SetKeyValue("rendercolor","0 183 239")
	beam:SetKeyValue("BoltWidth","2")
	beam:SetKeyValue("texture","sprites/laserbeam.spr")
	beam:SetKeyValue("spawnflags","1")
	beam:SetKeyValue("TextureScroll","35")
	beam:SetPos(self:GetPos())
	beam:SetParent(self)
	beam:Spawn()
	beam:Activate()
	
	self.beams[ent] = {beam, beam_target}
end

function ENT:PhysicsCollide( data, physobj )
	if not data.HitEntity then return true end
	
	if not data.HitEntity:IsPlayer() and not data.HitEntity:IsNPC() then self:EmitSound( "npc/controller/electro4.wav", 100, 100 ); self:Remove(); return true end
	self.owner = self.owner or self
	data.HitEntity.attacker = self.owner
	data.HitEntity.inflictor = self
	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( sk_nihilanth_attack_value, self.owner, self )
	elseif( ( ValidEntity( self.owner ) and ( self.owner:Disposition( data.HitEntity ) == 1 or self.owner:Disposition( data.HitEntity ) == 2 ) ) and data.HitEntity:GetClass() != "npc_turret_floor" ) then
		data.HitEntity:TakeDamage( sk_nihilanth_attack_value, self.owner, self )
	elseif( data.HitEntity:GetClass() == "npc_turret_floor" ) then
		data.HitEntity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) )
		data.HitEntity:Fire( "selfdestruct", "", 0 )
	end
	self:EmitSound( "npc/controller/electro4.wav", 100, 100 )
	self:Remove()
		
	return true
end

