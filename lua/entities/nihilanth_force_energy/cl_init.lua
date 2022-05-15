include('shared.lua')

language.Add("nihilanth_force_energy", "Nihilanth")
killicon.Add("nihilanth_force_energy","HUD/killicons/monster_nihilanth",Color ( 255, 80, 0, 255 ) )
function ENT:Initialize()
	self.col = Color( 255, 141, 15, 255 )
end

function ENT:Draw()
	local pos = self.Entity:GetPos()
	local vel = self.Entity:GetVelocity()
	
	render.SetMaterial( Material( "sprites/nhth1" ) ) 
	
	local lcolor = render.GetLightColor( pos ) * 2
	lcolor.x = self.col.r * mathx.Clamp( lcolor.x, 0, 1 )
	lcolor.y = self.col.g * mathx.Clamp( lcolor.y, 0, 1 )
	lcolor.z = self.col.b * mathx.Clamp( lcolor.z, 0, 1 )
		
	// Fake motion blur
	/*for i = 1, 20 do
	
		local col = Color( lcolor.x, lcolor.y, lcolor.z, 255 / (i / 2) )
		render.DrawSprite( pos + vel*(i*-0.01), 50, 50, col )
		
	end*/
		
	//render.DrawSprite( pos, 50, 50, lcolor )
end