
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = (tr.HitPos - tr.HitNormal * 14)
	local SpawnAngles = tr.HitNormal:Angle()
	SpawnAngles.pitch = SpawnAngles.pitch +90
	
	local ent = ents.Create( "nihilanth_crystal" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAngles )
	ent:Spawn()
	ent:Activate()
	
	
	return ent
end

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetHealth(225)
	
	self:SetModel( "models/crystal.mdl" )
	
	self:SetCollisionBounds( Vector( -20, 22, 14 ), Vector( 28, -22, 95 ) )	
	
	self.lighttarget = ents.Create( "light_dynamic" )
	self.lighttarget:SetKeyValue( "_light", "255 130 4 750" )//137 65 0 100" )
	self.lighttarget:SetKeyValue( "brightness", "6" )
	self.lighttarget:SetKeyValue( "distance", "0" )
	self.lighttarget:SetKeyValue( "_cone", "0" )
	self.lighttarget:SetPos(self:GetPos() +Vector(0,0,55))
	self.lighttarget:SetParent( self )
	self.lighttarget:Spawn()
	self.lighttarget:Activate()
	self.lighttarget:Fire( "TurnOn", "", 0 )
	
	self.sound = CreateSound(self, "ambience/alien_cycletone.wav") 
	self.sound:Play()
	
	/*self.bullseye = ents.Create("npc_bullseye")
	self.bullseye:SetKeyValue("spawnflags","131072")
	self.bullseye:SetPos(self:GetPos() +Vector(0,0,100))
	self.bullseye:SetParent(self)
	self.bullseye:Spawn()
	self.bullseye:Activate()*/
end

function ENT:Break()
	local sprite = ents.Create("env_sprite")
	sprite:SetKeyValue("spawnflags","2")
	sprite:SetKeyValue("scale","15")
	sprite:SetKeyValue("framerate","10")
	sprite:SetKeyValue("model","sprites/Fexplo1.spr")
	sprite:SetKeyValue("rendercolor","255 128 0")
	sprite:SetKeyValue("rendermode","5")
	sprite:SetKeyValue("renderfx","14")
	sprite:SetPos(self:GetPos() +Vector(0,0,55))
	sprite:Spawn()
	sprite:Fire("kill", "", 2)
	sprite:Fire("ShowSprite", "", 0)
	
	local shooter = ents.Create("env_shooter")
	shooter:SetPos(self:GetPos() +Vector(0,0,14))
	shooter:SetAngles(self:GetAngles())
	shooter:SetKeyValue("spawnflags","1")
	shooter:SetKeyValue("m_flGibLife","1")
	shooter:SetKeyValue("renderamt","150")
	shooter:SetKeyValue("rendermode","5")
	shooter:SetKeyValue("shootsounds","-1")
	shooter:SetKeyValue("shootmodel","sprites/hotglow.spr")
	shooter:SetKeyValue("m_flVariance","0.5")
	shooter:SetKeyValue("m_flVelocity","200")
	shooter:SetKeyValue("delay","0")
	shooter:SetKeyValue("m_iGibs","2")
	shooter:SetKeyValue("gibgravityscale","1")
	shooter:SetKeyValue("renderfx","0")
	shooter:Spawn()
	shooter:Activate()
	shooter:Fire("Shoot","",0)
	shooter:Fire("kill","",1)
	
	self:EmitSound("debris/bustglass" .. math.random(1,3) .. ".wav",100,100)
	self:EmitSound("weapons/mortarhit.wav",100,100)
	self:EmitSound("ambience/xtal_down1.wav",100,100)
	self:Remove()
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() -dmg:GetDamage())
	if self:Health() <= 0 then
		self:Break()
	end
end

function ENT:Think()
end

function ENT:OnRemove()
	if ValidEntity(self.bullseye) then self.bullseye:Remove() end
	self.sound:Stop()
	self.lighttarget:Remove()
end
