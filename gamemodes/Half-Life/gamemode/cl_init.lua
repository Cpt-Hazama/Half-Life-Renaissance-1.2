
/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/

include( 'shared.lua' )

/*---------------------------------------------------------
	If false is returned then the spawn menu is never created.
	This saves load times if your mod doesn't actually use the
	spawn menu for any reason.
---------------------------------------------------------*/
function GM:SpawnMenuEnabled()
	return false
end



function GM:Initialize()

	self.BaseClass:Initialize()
	
end
/*---------------------------------------------------------
	Draws on top of VGUI..
---------------------------------------------------------*/
function GM:PostRenderVGUI()

	self.BaseClass:PostRenderVGUI()

end
