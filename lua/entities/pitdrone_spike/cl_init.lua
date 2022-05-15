include('shared.lua')

killicon.Add("pitdrone_spike","HUD/killicons/monster_pitdrone",Color ( 255, 80, 0, 255 ) )
function ENT:Initialize()
	self.col = Color( 255, 141, 15, 255 )
end

function ENT:Draw()
	self.Entity:DrawModel()
end