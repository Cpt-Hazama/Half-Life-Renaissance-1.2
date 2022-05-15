include('shared.lua')

language.Add("nihilanth_force_teleport", "Nihilanth")
killicon.Add("nihilanth_force_teleport","HUD/killicons/monster_nihilanth",Color ( 255, 80, 0, 255 ) )
function ENT:Initialize()
	self.col = Color( 255, 141, 15, 255 )
end

function ENT:Draw()
end