SWEP.Author = "Silverlan"
SWEP.Contact = "Silverlan@gmx.de"
SWEP.Purpose = "Take control over a NPC"
SWEP.Instructions = "Aim at a NPC and use primary fire to possess it. Use jump key to stop the possession. More instructions are in the readme."

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/v_hgun.mdl"
SWEP.WorldModel = "models/w_hgun.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	if SERVER then
		self.Weapon:SetWeaponHoldType("smg")
	end
end

/*---------------------------------------------------------
Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end


/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
end

/*---------------------------------------------------------
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
---------------------------------------------------------*/
function SWEP:GetCapabilities()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.2)
	if CLIENT then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang*8000)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata) 
	if trace.Entity and ValidEntity( trace.Entity ) and trace.Entity:Health() > 0 then
		self.Owner:PossessNPC(trace.Entity)
	end
	
	local trace = util.TraceLine(tracedata)
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.1)
end 

function SWEP:OnRemove( )
end
