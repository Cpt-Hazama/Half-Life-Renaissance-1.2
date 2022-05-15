
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	self:DrawShadow( false )
	
	self:SetCollisionBounds( Vector(300, 160, 590), Vector(-300, -160, -590) )
	
	self:SetKeyValue("gmod_allowphysgun", "0")
	self:SetKeyValue("gmod_allowtools", "")
	/*self.mdl1 = ents.Create("prop_dynamic_override")
	self.mdl1:SetPos(self:GetPos() +Vector(300, 160, 590))
	self.mdl1:SetModel("models/props_junk/watermelon01.mdl")
	self.mdl1:SetParent(self)
	self.mdl1:Spawn()
	self.mdl1:Activate()
	
	self.mdl2 = ents.Create("prop_dynamic_override")
	self.mdl2:SetPos(self:GetPos() +Vector(-300, -160, -590))
	self.mdl2:SetModel("models/props_junk/watermelon01.mdl")
	self.mdl2:SetParent(self)
	self.mdl2:Spawn()
	self.mdl2:Activate()*/
end


function ENT:Think()
	self:SetPos(self.owner:GetPos())
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmg)
	self.owner:OnTakeDamageHull(dmg)
end
